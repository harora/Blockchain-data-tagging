pragma solidity 0.4.20;

contract Sentence {
    // Sentence for tagging
    struct Sentence {
        uint id;
        string content;
        uint numOfTags;
        uint numRequired;
        mapping(address => bool) workerList;
        address requester;
        bool completed;
    }

    struct VoteLog {
        mapping(address => uint) choice;
    }

    address public owner;

    mapping(uint => Sentence) public SentenceList;
    mapping(uint => uint[]) private ResultList;
    mapping(uint => TagLog) private TagLogList;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier checkVoteNum(uint _id) {
        require(isExist(_id) == true);
        // todo
        require(SentenceList[_id].workerList.length < SentenceList[_id].numRequired);
        _;
    }

    // add sentence event
    event NewSentence(uint _id, string _content);
    // tag event
    event AddTag(address indexed _from, uint _id, uint _choice, uint _numRequired);

    constructor() public {
        // The owner address is maintained.
        owner = msg.sender;
    }

    // check existence
    function isExist(uint _id) public {
        if (SentenceList[_id].isExist == true) {
            return true;
        } else {
            return false;
        }
    }


    // Create a new request sentence
    function create(string memory _content, uint _numOfTags, uint _numRequired) public {

        uint _id = keccak256(abi.encodePacked(_content));
        // check existence
        require(isExist(_id) == false);

        SentenceList[_id].isExist = true;
        SentenceList[_id].id = _id;
        SentenceList[_id].content = _content;
        SentenceList[_id].numOfTags = _numOfTags;
        SentenceList[_id].numRequired = _numRequired;

        ResultList[_id].length = _numberOfChoices;

        emit NewSentence(_id, _content);

        return true;
    }

    
    // add tag
    function tag(uint _id, uint _choice) public {
        require(SentenceList[_id].workerList[msg.sender] == false);


        // add to worker list
        SentenceList[_id].workerList[msg.sender] = true;

        // add tag
        ResultList[_id][_choice]++;
        TagLogList[_id].choice[msg.sender] = _choice;
        // todo
        emit AddTag(msg.sender, _id, _choice);

        return true;
    }

    
    // Get the result
    function getResult(uint _id) public {
        require(msg.sender == SentenceList[_id].requester);
        return ResultList[_id];
    }
}
