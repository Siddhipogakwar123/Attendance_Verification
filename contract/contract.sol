// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StudentRegistry {

    // Struct to hold student details
    struct Student {
        string name;
        string email;
        string mobile;
        string rollNo;
        uint256 attendanceCount; // Number of days attended
    }

    // Mapping of wallet addresses to students
    mapping(address => Student) public students;

    // Constant reward amount (adjust as necessary)
    uint256 public constant REWARD_AMOUNT = 0.1 ether;

    // Address of the contract owner
    address public owner;

    // Event for logging reward issuance
    event RewardIssued(address indexed studentAddress, uint256 rewardAmount);

    // Constructor to set the contract owner
    constructor() {
        owner = msg.sender;
    }

    // Modifier to check if the caller is the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Function to register a student
    function registerStudent(
        string memory _name,
        string memory _email,
        string memory _mobile,
        string memory _rollNo
    ) public {
        students[msg.sender] = Student(_name, _email, _mobile, _rollNo, 0);
    }

    // Function to mark attendance
    function markAttendance() public {
        Student storage student = students[msg.sender];
        require(bytes(student.name).length > 0, "Student not registered");
        student.attendanceCount += 1;

        // Check and reward attendance
        if (student.attendanceCount > 5) {
            require(address(this).balance >= REWARD_AMOUNT, "Insufficient funds in contract");
            payable(msg.sender).transfer(REWARD_AMOUNT);
            emit RewardIssued(msg.sender, REWARD_AMOUNT);
        }
    }

    // Function to get a student's attendance count
    function getAttendanceCount(address _studentAddress) public view returns (uint256) {
        return students[_studentAddress].attendanceCount;
    }

    // Function to get a student's details and their attendance count
    function getStudentDetails(address _studentAddress) public view returns (
        string memory name,
        string memory email,
        string memory mobile,
        string memory rollNo,
        uint256 attendanceCount
    ) {
        Student memory student = students[_studentAddress];
        return (
            student.name,
            student.email,
            student.mobile,
            student.rollNo,
            student.attendanceCount
        );
    }

    // Function to fund the contract (allows sending Ether to the contract)
    function fundContract() public payable {}

    // Function to withdraw funds, restricted to the owner
    function withdrawFunds(uint256 amount) public onlyOwner {
        require(amount <= address(this).balance, "Insufficient funds in the contract");
        payable(owner).transfer(amount);
    }
}
