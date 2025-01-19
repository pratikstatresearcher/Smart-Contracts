// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract StudentManagement {
    // Making Struct
    struct Student {
        string Name;
        uint256 Age;
        uint256 Score;
    }

    //Make Make Array to store IDs
    uint256[] public StudentIds;

    //mapping an Id to student
    mapping(uint256 => Student) public Students;

    //Making an Event
    event StudentAdded(uint256 Id, string name, uint256 age, uint256 score);
    event StudentUpdated(uint256 Id, uint256 updatedScore);

    //Making Modifier
    modifier StudentExist(uint256 Id) {
        require(bytes(Students[Id].Name).length != 0, "Student Id exits");
        _;
    }

    //Add students in struct
    function AddStudent(
        uint256 i,
        string memory name,
        uint256 age,
        uint256 score
    ) public {
        require(bytes(Students[i].Name).length == 0, "Student id exists");
        StudentIds.push(i);
        Students[i] = Student({Name: name, Age: age, Score: score});

        emit StudentAdded(i, name, age, score);
    }

    //Update Students score
    function UpdateScore(uint256 i, uint256 NewScore) public {
        Students[i].Score = NewScore;
        emit StudentUpdated(i, NewScore);
    }

    //Featching all Students from Ids through emit function to get all student details.
    event StudentDetails(uint256, string, uint256, uint256);

    function GetAllStudents() public {
        for (uint256 i = 0; i < StudentIds.length; i++) {
            Student memory student = Students[StudentIds[i]];
            emit StudentDetails(
                StudentIds[i],
                student.Name,
                student.Age,
                student.Score
            );
        }
    }

    //Function to get All ids
    function AllStudentIds() public view returns (uint256[] memory) {
        return StudentIds;
    }
}
