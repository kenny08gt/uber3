pragma solidity >=0.4.0 <0.9.0;

contract SimpleStorage {
    uint storedData;

    mapping (address => uint) travels;
    mapping (address => uint) poolOfDrivers;

    function set(uint x) public {
        storedData = x;
    }

    function get() public view returns (uint) {
        return storedData;
    }

    function travel() public {

    }

    function beginTravel() public {

    }

    function endTravel() public {
        
    }


}