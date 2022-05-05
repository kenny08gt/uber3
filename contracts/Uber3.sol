// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

contract Uber3 {
    uint public travelsCount = 0;
    uint public travelRequestCount = 0;
    uint public driversCount = 0;
    uint public passengersCount = 0;
    mapping (address => uint) drivers;
    mapping (address => bool) driversStatus;
    mapping (address => uint) passengers;
    mapping (uint => Travel) travels;
    mapping (uint => TravelRequest) travelsRequested;

    struct Travel {
        uint id;
        uint start;
        uint finish;
        uint amount;
        address passenger;
        address driver;
        bool active;
        bool finished_by_driver;
        bool finished_by_passenger;
    }

    struct TravelRequest {
        uint id;
        uint start;
        uint finish;
        uint amount;
        address passenger;
        bool accepted;
    }


    event Received(address sender, uint value);
    event TravelRequested(address passenger,uint start, uint finish);
    event TravelAccepted(Travel travel);
    event TravelFinished(Travel travel);
    event PaymentSentToDriver(address driver, uint amount);

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function driverConnects() public {
        driversCount = driversCount + 1;
        drivers[msg.sender] = driversCount;
        driversStatus[msg.sender] = false;
    }

    function passengerConnects() public {
        passengersCount = passengersCount + 1;
        passengers[msg.sender] = passengersCount;
    }

    function passengerRequestDrive(uint start, uint finish) public payable {
        require(passengers[msg.sender] != 0, "Passenger not connected previously");
        TravelRequest memory request = TravelRequest(travelRequestCount, start, finish, msg.value, msg.sender, false);
        travelsRequested[request.id] = request;
        travelRequestCount = travelRequestCount + 1;
        //Emit an event
        emit TravelRequested(msg.sender, start, finish);
    }

    function driverAcceptDrive(uint travelRequestId) public {
        require(drivers[msg.sender] != 0, "Driver not connected previously");
        require(driversStatus[msg.sender] != false, "Driver its occupied already. Finish the drive first");

        travelsRequested[travelRequestId].accepted = true;
        travels[travelsCount] = Travel(travelsCount, travelsRequested[travelRequestId].start, 
            travelsRequested[travelRequestId].finish, 
            travelsRequested[travelRequestId].amount, 
            travelsRequested[travelRequestId].passenger, 
            msg.sender, 
            true, 
            false, 
            false
        );
        
        travelsCount = travelsCount + 1;

        driversStatus[msg.sender] = true;

        emit TravelAccepted(travels[travelsCount - 1]);
    }

    function passengerFinishDrive(uint travelId) public {
        require(travels[travelId].amount > 0, "Travel not found in passenger finish");
        require(travels[travelId].passenger == msg.sender, "Only the passenger that request the travel can finish it");
        travels[travelId].finished_by_passenger = true;
        if(travels[travelId].finished_by_driver) {
             finishDrive(travelId);
        }
    }

    function driverFinishDrive(uint travelId) public {
        require(travels[travelId].amount > 0, "Travel not found in driver finish");
        require(travels[travelId].driver == msg.sender, "Only the driver that accept the travel can finish it");
        travels[travelId].finished_by_driver = true;
        if(travels[travelId].finished_by_passenger) {
           finishDrive(travelId);
        }
    }

    function finishDrive(uint travelId) private {
        payable(travels[travelId].driver).transfer(travels[travelId].amount);
        emit PaymentSentToDriver(travels[travelId].driver, travels[travelId].amount);
        travels[travelId].active = false;
        travels[travelId].amount = 0;

        driversStatus[msg.sender] = false;
        emit TravelFinished(travels[travelId]);
    }

}