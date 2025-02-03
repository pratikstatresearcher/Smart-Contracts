// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CrowdFunding {
    //Campaign Details
    string public campaignName;
    address public owner;
    uint256 public campaignStartDate;
    uint256 public campaignLastDate;
    uint256 public targetAmount;
    uint256 public collectedAmount;
    bool public isCamapignVerified;
    uint256 public amountSpent;
    uint256 public amountAvailable;

    // Details given by Campaign Owner
    constructor(string memory name, address admin, uint day, uint target) {
        campaignName = name;
        owner = admin;
        campaignStartDate = block.timestamp;
        campaignLastDate = block.timestamp + (day * 1 days);
        targetAmount = target * 1 ether;
        collectedAmount = 0 ether;
    }


    //Modifier to perform some activities only by owner
    modifier OnlyOwner() {
        require(msg.sender == owner, "The caller is not owner");
        _;
    }

    //Minimum Contribution limit
    uint256 public minimumContribution = 0.01 ether;

    //mapping and event to record who contributed and how much
    mapping(address => uint256) public donated;
    event donationDetails(address donar, uint256 amount, uint256 time);

    //Mapping to keep records regarding withdrawal;
    mapping(address => uint256) public withdrawalAccount;
    event withdrawalDetails(address to, uint256 amount, uint256 time);

    //Mapping to keep refund details
    mapping(address => uint256) public refund;
    event refundDetails(address recevier, uint256 amount, uint256 time);

    //Event to log data after successful cancellation of campaign
    event Cancellation_Successful(string);

    //List of Donars
    address[] private Donars;

    //Funtion for donation in Ether
    function donateETH() public payable {
        require(block.timestamp <= campaignLastDate, "Campaign is over");
        require(
            msg.value >= minimumContribution,
            "The minimun donation amount is 0.01 ether"
        );
        require(collectedAmount <= targetAmount, "Target has been met.");
        donated[msg.sender] = msg.value;
        collectedAmount += msg.value;
        amountAvailable += msg.value;
        Donars.push(msg.sender);
        emit donationDetails(msg.sender, msg.value, block.timestamp);
    }

    ////////////////Ask this:
    //Function to donated ERC20 token
    function donateERC20(address tokenAddress, uint256 amount) public payable {
        require(block.timestamp <= campaignLastDate, "Campaign is over");
        //require(amount >= minimumContribution, "The donation should not less than 0.01 ether");
        //The above condition is not applied here since ERC20 token may have different market values.
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        donated[msg.sender] += amount;
        collectedAmount += amount;
        amountAvailable += amount;
        Donars.push(msg.sender);
        emit donationDetails(msg.sender, amount, block.timestamp);
    }

    //Function to get donars list
    function listOfDonars() public view returns (address[] memory) {
        return Donars;
    }

    //Function to withdraw money
    function withdraw(address payable receiver, uint256 amount)
        public
        OnlyOwner
    {
        require(
            collectedAmount >= targetAmount,
            "Targeted amount is not reached"
        );
        require(amount < collectedAmount, "Requested amount is too high");
        receiver.transfer(amount);
        withdrawalAccount[receiver] = amount;
        amountSpent += amount;
        amountAvailable = collectedAmount - amount;
        emit withdrawalDetails(receiver, amount, block.timestamp);
    }

    //Event to log that is the campaign verified or not
    event campaignVerified(string);

    //Function to verify the campaign only by owner
    function verify() public OnlyOwner {
        isCamapignVerified = true;
        emit campaignVerified("This campaign is verified by Owner itself");
    }

    // Total time remained
    function timeRemained() public view returns (uint256) {
        require(block.timestamp < campaignLastDate, "Campaign is over");
        return (campaignLastDate - block.timestamp);
    }

    //Total funds need to be collected
    function fundNeeded() public view returns (string memory, uint256) {
        require(collectedAmount <= targetAmount, "Target is met");
        return ("Need : ", (targetAmount - collectedAmount));
    }

    //Function to cancel the campaign
    function cancelCampaign() public OnlyOwner {
        require(
            block.timestamp > campaignStartDate,
            "Camapaign is not started yet"
        );
        require(block.timestamp < campaignLastDate, "Campaing is over");
        for (uint256 i = 0; i < Donars.length; i++) {
            address Recevier = Donars[i];
            uint256 RecevierAmount = donated[Donars[i]];

            if (refund[Recevier] == 0 && donated[Recevier] > 0) {
                payable(Recevier).transfer(RecevierAmount);
                refund[Recevier] = RecevierAmount;
                collectedAmount -= RecevierAmount;
                donated[Donars[i]] = 0;
                emit refundDetails(Recevier, RecevierAmount, block.timestamp);
            }
        }

        emit Cancellation_Successful(
            "Campaing is cancelled successfully and respective amount is refunded to them."
        );
    }
}
