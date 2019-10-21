pragma solidity ^0.4.25 ;


 
contract eVote{
    
    // struct Campaign{
        
    //     uint numberOfParties;
    //     address controllingAuthority;
    //     address secondControllingAuthority;
    //     mapping (address => bool) voted;
    //     mapping (bytes32 => uint) votes;
    // }
    string description;
    bool completed;
    address public controllingAuthority;
    address public secondControllingAuthority;
    uint totalVotes;
    uint numberOfVoters;
    uint foundParty;
    string winningParty;
    string _partyName;
    struct Party{
        string name;
        string description;
        uint voteCount;
        mapping (address => bool) voted;
        
    }
    
    struct Voter{
        string hashId;
        uint canVote;
        bool requestedtoregister;
        bool votingToken ;
        mapping (string => bool) voted ;    
    }
    
    enum State {created, Voting, Ended }
        State public state;
        
    Party[] public parties;
    Voter[] public requestedVotersArray;
    Voter[] public confirmedVotersArray;
    address[] public requestedVotersAddress;
    address[] public confirmedVotersAddress;
    
    mapping (string => Party)  partyMapping;
    mapping (address => Voter) public votersRegister;
    mapping (address => Voter) public requestedVotersregister;
    
    constructor (address _secondControllingAouthority,string memory _description ) public {
        controllingAuthority = msg.sender;
        secondControllingAuthority = _secondControllingAouthority;
        description = _description;
        totalVotes = 0;
        numberOfVoters = 0;
        state = State.created;
        foundParty = 0;
    } 
    
    modifier firstControllingOfficial() {
		require(msg.sender ==controllingAuthority);
		_;
	}
	modifier secondControllingOfficial() {
		require(msg.sender ==secondControllingAuthority);
		_;
	}
	modifier inState(State _state){
	    require(state == _state);
	    _;
	}
    
    function addParty(string memory _name, string memory _description) public inState(State.created) firstControllingOfficial {
            Party memory p = Party({
            description : _description,
            name : _name,
            voteCount : 0
        });    
        parties.push(p);
        partyMapping[_name]=p;
    }
    // voter requests to register him/her as a valid voter
    // function requestedVoterAdditionr(string memory _hashId) public inState(State.created) {
    //     Voter memory v = Voter({
            
    //     });
    // }
    function addRequestedVoter(string memory _hashId) public inState(State.created){
        
        Voter storage sender = requestedVotersregister[msg.sender];
        if(sender.requestedtoregister){
            delete(requestedVotersregister[msg.sender]);
        }
        Voter memory v = Voter({
            hashId : _hashId,
            canVote : 0,
            votingToken : false,
            requestedtoregister : true
        });
        requestedVotersregister[msg.sender]=v;
        requestedVotersAddress.push(msg.sender);
        requestedVotersArray.push(v); 
        
        
        // requestedVoters.push(v);
    }
    // include functionality to removed allowed voters from requestedtovoteRegister
    function addToVoterRegister(address _voterAddress) public firstControllingOfficial secondControllingOfficial inState(State.created) {
        Voter storage sender = requestedVotersregister[_voterAddress];
        if(sender.requestedtoregister){
            if(sender.canVote<2){
                sender.canVote++;
            }
            if(sender.canVote == 2){
                sender.requestedtoregister = false;
                sender.votingToken = true ;
                
                Voter memory v ;
                v.hashId = sender.hashId;
                v.canVote = sender.canVote;
                v.votingToken = sender.votingToken;
                v.requestedtoregister = sender.requestedtoregister;
                votersRegister[_voterAddress] = v;
                confirmedVotersAddress.push(_voterAddress);
                confirmedVotersArray.push(v);
                numberOfVoters++;
            }    
        }
    }
    
    function startVoting() public firstControllingOfficial inState(State.created){
        state = State.Voting ;
    }
    
    function castVote(string  _partyName) public inState(State.Voting) returns(bool _voted) {
        bool voted = false;
        for(uint prop=0; prop<parties.length;prop++){
            if(keccak256(abi.encodePacked((parties[prop].name))) == keccak256(abi.encodePacked(_partyName))){
                foundParty = 1;
                break;
            }
            else{
                revert("Wrond Party name entered. Please enter Party name again");
            }
            
        }
        if(foundParty==1){
            Party storage partyobj = partyMapping[_partyName];
            if(!partyobj.voted[msg.sender]){
                partyobj.voteCount+=1;
                partyobj.voted[msg.sender]=true;
                totalVotes+=1;
                voted = true; 
            }
            foundParty=0;
        }
        
        return voted;
        
        // if(partyobj){}
        
    }
    
    function endVote() public firstControllingOfficial inState(State.Voting){
        state = State.Ended;
    }
    
    //error
    function showParty(uint _index) public view returns(string){
        
        return parties[_index].name;
    }
    
    function calculateResult() public firstControllingOfficial inState(State.Ended){
        uint _voteCount=0;
        
        
        for(uint i=0;i<parties.length ;i++){
            _partyName = parties[i].name;
            Party memory p = partyMapping[_partyName];
            if(p.voteCount>_voteCount){
                _voteCount = p.voteCount;
                winningParty = p.name;
            }
            
        }
    }
    
}













