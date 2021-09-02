pragma solidity 0.8.0;

contract userAuthenticity{
 
   mapping(address=> user) Users;
   
   
    uint256 count;
    
    constructor(){
         count=0;
    }
    enum LogIn{yes,no}
    struct user{
      string userName;
      string password;
      LogIn _login;
      
    }
    modifier costs(uint _amount){
        
        require(msg.value >= _amount, "Not sufficient ether provided...");
        _;
          
    }
    
   function signUp( string  memory Username, string  memory passWord) external payable costs(3 ether) {
    user storage _user= Users[msg.sender];
    _user.userName=Username;
    _user.password=passWord;
    _user._login=LogIn.no;
    
   }
  
   function Login(string memory _username, string memory _passWord)external {
        require(keccak256(abi.encodePacked(Users[msg.sender].userName))==keccak256(abi.encodePacked(_username )) && keccak256(abi.encodePacked(Users[msg.sender].password))==keccak256(abi.encodePacked(_passWord)), "Please Check Your Credentials Again");
        user storage _user= Users[msg.sender];
        _user._login=LogIn.yes;
    }
}