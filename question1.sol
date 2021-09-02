pragma solidity ^0.6.0;

contract HotelRoom{
    mapping (uint256=>Room) rooms;
    address payable public owner;
    constructor()public { 
        owner = msg.sender;
        
        
    }
   
    enum Statuses{vacant,occupied} 
    
    
    struct Room{
        uint256 id;
        string name;
        Statuses status;
        uint256 time;
    }
    
    
    modifier costs(uint _amount){
        
        require(msg.value >= _amount, "Not sufficient ether provided...");
        _;
          
    }
    event Occupy(address _occupant, uint _value, uint256 _id);
   
    function bookRoom(uint256 identity, string memory nameOfOccupant) external payable  costs(3 ether){
        require(rooms[identity].status!=Statuses.occupied);
        owner .transfer(msg.value);
       Room storage ROOM =rooms[identity];
       ROOM.id=identity;
       ROOM.status = Statuses.occupied;
       ROOM.name=nameOfOccupant;
       ROOM.time=block.timestamp;
        //currentStatus = Statuses.occupied;
        emit Occupy(msg.sender,msg.value,identity);
    }
    function VerifiyRoom(uint256 ID) public view returns(uint256,string memory ,Statuses){
        return( rooms[ID].id,rooms[ID].name,rooms[ID].status);
    }
    
}