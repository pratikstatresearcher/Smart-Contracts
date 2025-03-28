// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract VoterRegistry {
    address public Owner;

    //Struct To store the details of candidates
    struct Candidates {
        string Name;
        uint256 Age;
        string Symbol;
        uint256 Votes;
    }

    //List of candidates standed for election
    address[] private candidatesList;

    //Mapping
    mapping(address => Candidates) private addCandidate;
    mapping(address => bool) public isVoted; //Mapping to check that a person votted;
    mapping(string => bool) private isSymbolAvailable;

    //Events to emit the details
    event candidateAdded(string _name, string _symbol);
    event voteCastedto(string _symbol);
    event ElectionResult(address _Winner, string _Name, uint256 _votes);

    //constructor
    constructor() {
        Owner = msg.sender;
    }

    //modifier
    modifier onlyOwner() {
        require(Owner == msg.sender, "Caller is not a Owner");
        _;
    }

    //function to add candidates
    //Note that once candidate registered for votting it can't be withdraw their nomination.
    function addCandidates(
        address _candidate,
        string memory _name,
        uint256 _age,
        string memory _symbol
    ) public onlyOwner {
        require(bytes(_name).length > 0, "Name canot be empty");
        require(bytes(_symbol).length > 0, "Symbol cant be empty");
        require(
            _age >= 25 && _age <= 75,
            "Candidate is constitutionaly not eligible."
        );
        require(isSymbolAvailable[_symbol] == false, "Symbol already exists.");
        require(
            bytes(addCandidate[_candidate].Name).length == 0,
            "Candidate already registered"
        );

        addCandidate[_candidate] = Candidates({
            Name: _name,
            Age: _age,
            Symbol: _symbol,
            Votes: 0
        });
        isSymbolAvailable[_symbol] = true;
        candidatesList.push(_candidate);

        emit candidateAdded(_name, _symbol);
    }

    //function to get the Candidate details to help voters
    function getCandidate(uint256 i)
        external
        view
        returns (address, string memory)
    {
        require(i < candidatesList.length, "Invalid value of index");
        return (candidatesList[i], addCandidate[candidatesList[i]].Symbol);
    }

    //function to vote the candidate
    function castVote(address _candidate) external {
        require(
            isVoted[msg.sender] == false,
            "Voter already casted their vote"
        );
        require(
            bytes(addCandidate[_candidate].Name).length > 0,
            "Candidate is not registered"
        );
        isVoted[msg.sender] = true;
        addCandidate[_candidate].Votes += 1;
    }

    //function to get Winner
    function getResult()
        public
        returns (
            address,
            string memory,
            uint256
        )
    {
        require(candidatesList.length > 0, "Candidates are not listed yet");
        address winner;
        uint256 maxVotes = 0;

        for (uint256 i = 0; i < candidatesList.length; i++) {
            address candidateAddress = candidatesList[i];
            if (addCandidate[candidateAddress].Votes > maxVotes) {
                maxVotes = addCandidate[candidateAddress].Votes;
                winner = candidateAddress;
            }
        }
        emit ElectionResult(winner, addCandidate[winner].Name, maxVotes);
        return (winner, addCandidate[winner].Name, maxVotes);
    }
}
