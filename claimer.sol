// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;


import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/release-v3.4/contracts/access/Ownable.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/release-v3.4/contracts/token/ERC20/SafeERC20.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/release-v3.4/contracts/math/SafeMath.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/release-v3.4/contracts/utils/ReentrancyGuard.sol";
import "./interface/ITierIDOPool.sol";

contract Claimer is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct Claim {
        uint unlockTime; // unix time
        uint percent; // three decimals: 1.783% = 1783
    }

    Claim[] public claims;

    uint256 public id;

    bool public isPaused = false;
    uint public totalTokens;
    uint public claimedTokens;
    mapping(address => uint) public total;
    mapping(address => uint) public claimed;
    mapping(address => mapping(uint => uint)) public isClaimed;

    IERC20 public token;
    ITierIDOPool public idoPool;
    event Claimed(address indexed account, uint amount, uint percent, uint claimIdx);
    event ClaimReleased(uint percent, uint newTime, uint claimIdx);
    event ClaimDelayed(uint percent, uint newTime, uint claimIdx);
    event ClaimingPaused(bool status);

    constructor(uint256 _id, address _idoPool,address _token,uint[] memory times, uint[] memory percents) public {
        require(_token != address(0), "Token address cannot be address zero");
        require(_idoPool != address(0), "IDO address cannot be address zero");

        token = IERC20(_token);
        id = _id;
        idoPool=ITierIDOPool(_idoPool);
        totalTokens= idoPool.getTotalAmount();

        uint totalPercent;
        for (uint i = 0; i < times.length; i++) {
            require(percents[i] > 0, 'Claimer: 0% is not allowed');
            require(times[i] > 0, 'Claimer: time must specified');

            claims.push(Claim(times[i], percents[i]));
            totalPercent += percents[i];
        }
        require(totalPercent == 100000, 'Claimer: Sum of all claimed must be 100%');
   }

    function getAccountAmount(address account) external view returns (uint256) {
        uint256 amount=idoPool.getSale(account);
        return amount;
    }

    function getClaimableAccountAmount(address account) external view returns (uint256) {
        uint256 totalClaimable;
        for (uint i = 0; i < claims.length; i++) {
            if (isClaimable(i)) {
                totalClaimable += getClaimAmount(i, account);
            }
        }

        return totalClaimable - claimed[account];
    }

    function getRemainingAccountAmount(address account) external view returns (uint) {
        return idoPool.getSale(account) - claimed[account];
    }

    function getTotalRemainingAmount() external view returns (uint) {
        return totalTokens - claimedTokens;
    }

    function getClaims(address account) external view returns (uint[] memory, uint[] memory, uint[] memory, bool[] memory, uint[] memory) {
        uint len = claims.length;
        uint[] memory times = new uint[](len);
        uint[] memory percents = new uint[](len);
        uint[] memory amount = new uint[](len);
        bool[] memory _isClaimable = new bool[](len);
        uint[] memory claimedAmount = new uint[](len);

        for (uint i = 0; i < len; i++) {
            times[i] = claims[i].unlockTime;
            percents[i] = claims[i].percent;
            amount[i] = getClaimAmount(i, account);
            _isClaimable[i] = block.timestamp > claims[i].unlockTime;
            claimedAmount[i] = isClaimed[account][i];
        }

        return (times, percents, amount, _isClaimable, claimedAmount);
    }

    function claim(address account, uint idx) external nonReentrant {
        require(idx < claims.length, "Claimer: Out of bounds index");
        require(isClaimed[account][idx] == 0, "Claimer: Already claimed");
        require(isClaimable(idx), "Claimer: Not claimable");
       
        uint256 claimAllocation=idoPool.getSale(account);
      
        require(claimAllocation > 0, "Claimer: Account doesn't have allocation");
        require(!isPaused, "Claimer: Claiming paused");

        uint claimAmount = getClaimAmount(idx, account);
        require(claimAmount > 0, "Claimer: Amount is zero");

        claimedTokens += claimAmount;
        claimed[account] += claimAmount;
        isClaimed[account][idx] = claimAmount;

        token.safeTransfer(account, claimAmount);

        emit Claimed(account, claimAmount, claims[idx].percent, idx);
    }

    function releaseClaim(uint claimIdx) external onlyOwner {
        require(claimIdx < claims.length, "Claimer: Out of bounds index");
        Claim storage _claim = claims[claimIdx];

        require(_claim.unlockTime > block.timestamp, 'Claimer: Claim already released');
        _claim.unlockTime = block.timestamp;
        emit ClaimReleased(_claim.percent, _claim.unlockTime, claimIdx);
    }

    function delayClaim(uint claimIdx, uint newUnlockTime) external onlyOwner {
        require(claimIdx < claims.length, "Claimer: Out of bounds index");
        Claim storage _claim = claims[claimIdx];

        require(newUnlockTime > block.timestamp, 'Claimer: Time must be in future');
        require(newUnlockTime > _claim.unlockTime, 'Claimer: Time must be after the current claim time');
        _claim.unlockTime = newUnlockTime;
        emit ClaimDelayed(_claim.percent, _claim.unlockTime, claimIdx);
    }

    function isClaimable(uint claimIdx) internal view returns (bool) {
        return claims[claimIdx].unlockTime < block.timestamp;
    }

    function getClaimAmount(uint claimIdx, address account) internal view returns (uint) {
        uint256 claimAmount = idoPool.getSale(account);
        if (claimAmount == 0) {
            return 0;
        }
        return claimAmount * claims[claimIdx].percent / 100000;
    }

    function pauseClaiming(bool status) external onlyOwner {
        isPaused = status;
        emit ClaimingPaused(status);
    }
 

    function userclaim(address account) external nonReentrant{

         uint256 len =0;
         len = claims.length;
         uint i = 0;
            while( i < len)
            {      
                if(isClaimable(i)== true){
                    require(len< claims.length, "Claimer: Out of bounds index");
                    require(isClaimed[account][i] == 0, "Claimer: Already claimed");
                    require(isClaimable(i), "Claimer: Not claimable");
                    uint256 claimAllocation=idoPool.getSale(account);
                    require(claimAllocation > 0, "Claimer: Account doesn't have allocation");
                    require(!isPaused, "Claimer: Claiming paused");
                    uint claimAmount = getClaimAmount(i, account);
                    require(claimAmount > 0, "Claimer: Amount is zero");
                    claimedTokens += claimAmount;
                    claimed[account] += claimAmount;
                    isClaimed[account][i] = claimAmount;
                    token.safeTransfer(account,claimAmount);
                    emit Claimed(account, claimAmount, claims[i].percent, i);
                    i++;
                }
                else{
                    i++;
                }
            }
        }
   

    function withdrawAll() external onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        if (balance > 0) {
            payable(owner()).transfer(balance);
        }

        token.transfer(owner(), token.balanceOf(address(this)));
    }

    function withdrawToken(address _token, uint256 amount) external onlyOwner nonReentrant{
        IERC20(_token).transfer(owner(), amount);
    }

    function setToken(address _token) external onlyOwner {
        require(claims[0].unlockTime > block.timestamp, 'Cannot change token after first claim unlocked');
        token = IERC20(_token);
    }
}
