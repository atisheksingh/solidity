      // SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./AsvaInvestmentsInfo.sol";

interface ITierIDOPool {
     function getSale(address account) external view returns (uint256 amount);
     function getTotalAmountSold() external view returns (uint256 amount);
     function getTotalAmount() external view returns (uint256 amount);
     function getPoolWhiteLists() external view  returns (address[] memory);
     function getAddressTier(address _user) external view returns (uint8);
     function getInvestors(uint offset, uint limit) external view returns (address[] memory) ;
     function buy(uint256 amount) external;
     function withdraw() external;
     function emergencyWithdraw() external;
     function poolWhiteList(address _user) external view returns(bool);
}

interface IClaimer {
    function withdraw() external;
    function getAccountAmount(address account) external view returns (uint256);
    function getClaims(address account) external view 
    returns (uint[] memory, uint[] memory, uint[] memory, bool[] memory, uint[] memory) ;
    
    function claim(address account, uint idx) external;
    function getClaimableAccountAmount(address account) external view returns (uint256) ;
}


contract Aggeration {
  ITierIDOPool  idoPool;
  IClaimer     iclaimpool;
  AsvaInvestmentsInfo public immutable AsvaInfo;
  constructor( address _asvaInfoAddress) public 
  {
    AsvaInfo = AsvaInvestmentsInfo(_asvaInfoAddress);
   
  }


struct project {
uint256 id;
ITierIDOPool pool;
IClaimer claim;
}


project[] public projectlist;

function set(uint256 id ,address a, address c)public{
project memory temp = project(id,ITierIDOPool(a),IClaimer(c));
projectlist.push(temp);
}
//[["1","0x7a8659B8443DC10CA0c5C51809981F88cbdB591a","0x87387955aCb7b5B00726004Ef9fe498EB5a3F097"]]

function multipool(project[] memory t)public{
for(uint256 i=0; i<t.length; i++){
  project memory temp = project(t[i].id,t[i].pool,t[i].claim);
  projectlist.push(temp); 
}

}



function get (address user)public view returns(uint256[]memory,address[] memory ,uint256[] memory ,address[] memory,uint256[] memory){
  uint256 len = projectlist.length;
  uint256[] memory ids = new uint256[](len);
  uint256[] memory sale = new uint256[](len);
  uint256[] memory claim = new uint256[](len);
  address[] memory pools = new address[](len);
  address[] memory claimpools = new address[](len);
 
  for (uint256 i=0 ; i<len;i++){
  if(projectlist[i].pool.poolWhiteList(user)==true){
  ids[i] = projectlist[i].id;
  pools[i]= address(projectlist[i].pool);
  sale[i] = projectlist[i].pool.getSale(user);
  claimpools[i] = address(projectlist[i].claim);
  claim[i] = projectlist[i].claim.getClaimableAccountAmount(user);
  }
 

  }
  return (ids,pools,sale ,claimpools,claim);
}





// useraddress projcetid  get 
// array projcet id 





}
