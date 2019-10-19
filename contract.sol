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
    
    enum State {created, Voting,Ended }
        State public state;
        
    Party[] public parties;
    Voter[] public requestedVoters;
    mapping (address => Voter) votersRegister;
    mapping (address => Voter) requestedVotersregister;
    
    constructor (address _secondControllingAouthority,string memory _description ) public {
        controllingAuthority = msg.sender;
        secondControllingAuthority = _secondControllingAouthority;
        description = _description;
        totalVotes = 0;
        numberOfVoters = 0;
        state = State.created;
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
                numberOfVoters++;
            }    
        }
    }
}













