pragma solidity 0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
contract A is ERC20 {

  constructor() ERC20("Token1", "A") public {}// calling constructor
//for minting token 
 function minttokenA(uint256 amount) public returns (bool) {
    _mint(msg.sender, amount);
    return true;
  }

}


contract B {
    using SafeMath for uint;
    IERC20 A;
   address _owner;
  constructor( IERC20 _token) public{
   A =_token;
_owner = msg.sender;
    }
 
 
 
 
 
 uint256 public pt;
 uint public ct;
 uint public amount;
 
 
 
  /*
    function stake() public payable 
            {  uint256 amount =msg.value;
                require(amount > 0, "Cannot stake 0");
                User[msg.sender].useramount =amount;
                                                          // _totalSupply = _totalSupply.add(amount);
                                                        //payable(address(msg.sender)).transfer(_amount); // taking in the ether //13-08-21
                emit staked(amount);
                User[msg.sender].pastblock = block.number;// staking block number 
            }
            */
 
 
 function stake() public payable {
     pt= block.number;
     amount = msg.value;
 }
 
 
 
 
 
 function unstake() public{
     ct =block.number;
    payable(address(msg.sender)).transfer(amount); // sending back ether
 }
 
 
function getR() internal returns(uint) {
    uint duration = ct.sub(pt);
    uint fix =25;
    
    uint total= fix+duration;
    return total;
    
}
 
 
//giving allowance to this contract 
//checking token balance in this contract 
event checkbal(uint);

function cB() public returns(uint )
{

    uint balance = A.balanceOf(address(this));

    emit checkbal(balance);
    return(balance);    
}

event RewardPaid(address indexed , uint);
function giveR()public returns(uint){
    
    uint reward = getR();
          if (reward > 0) {
            A.transferFrom(_owner, msg.sender, reward);// error
            emit RewardPaid(msg.sender, reward);}
    uint b =cB();
    return(b);
    
    
    //mint that much token here
    //allowance to this token 
    //transfer token to user 
    
    
    
}
    
    
    
    
    
    
    
}