pragma solidity ^0.5.0;

contract Tagging {
    // Sentence for tagging
    struct Sentence {
        bytes32 id;
        string content;
        uint numOfTags;
        uint numOfAns;
        uint numRequired;
        mapping(address => bool) workerList;
        address requester;
        bool completed;
    }

    struct TagLog {
        mapping(address => uint) choice;
    }

    address public owner;

    mapping(bytes32 => Sentence) public SentenceList;
    mapping(bytes32 => uint[]) private ResultList;
    mapping(bytes32 => TagLog) private TagLogList;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier openforTag(bytes32 _id) {
        require(isCompleted(_id) == false);
        _;
    }

    // add sentence event
    event NewSentence(bytes32 _id, string _content);
    // tag event
    event AddTag(address indexed _from, bytes32 _id, uint _choice);

    constructor() public {
        // The owner address is maintained.
        owner = msg.sender;
    }

    // check existence
    function isCompleted(bytes32 _id) public returns (bool){
        if (SentenceList[_id].completed == true) {
            return true;
        } else {
            return false;
        }
    }


    // Create a new request sentence
    function create(string memory _content, uint _numOfTags, uint _numRequired) public returns (bool){
        // hash function
        bytes32 _id = keccak256(abi.encodePacked(_content));

        SentenceList[_id].completed = false;
        SentenceList[_id].id = _id;
        SentenceList[_id].content = _content;
        SentenceList[_id].numOfTags = _numOfTags;
        SentenceList[_id].numOfAns = 0;
        SentenceList[_id].numRequired = _numRequired;
        SentenceList[_id].completed = false;

        ResultList[_id].length = _numOfTags;

        emit NewSentence(_id, _content);

        return true;
    }

    
    // add tag
    function tag(bytes32 _id, uint _choice) public openforTag(_id) returns (bool){
        require(SentenceList[_id].workerList[msg.sender] == false);


        // add to worker list
        SentenceList[_id].workerList[msg.sender] = true;

        // add tag
        ResultList[_id][_choice]++;
        TagLogList[_id].choice[msg.sender] = _choice;
        SentenceList[_id].numOfAns += 1;
        // check if complete
        if (SentenceList[_id].numOfAns == SentenceList[_id].numRequired) {
           SentenceList[_id].completed = true;
        }
        // todo
        emit AddTag(msg.sender, _id, _choice);

        return true;
    }

    
    // Get the result
    function getResult(bytes32 _id) public returns (uint[] memory){
        require(msg.sender == SentenceList[_id].requester);
        return ResultList[_id];
    }
}
