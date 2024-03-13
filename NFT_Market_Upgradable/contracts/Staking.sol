// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./SafeMath.sol";
contract Staking is Ownable(msg.sender){
    address public tokenReward;
    mapping(address=>UserRewards) userInfos;   //质押eth赚KSN
    uint public totalStake;
    uint public rewardPerTokenAcculate;
    uint public rewardRate;    // Reward to be paid out per second
    uint public updateAt;   //last timestamp updated
    uint public finishAt;

    using SafeMath for uint;
    
    event Staked(address user, uint256 amount);
    event Unstaked(address user, uint256 amount);
    event Claimed(address user, uint256 amount);
    event RewardsPerTokenUpdated(uint256 accumulated);
    event UserRewardsUpdated(address user, uint256 rewards, uint256 updateAt);

    error NO_NEED_UPDATE();

    struct UserRewards{
        uint eth_amount;  //eth deposit
        uint accumulated_rewards;  //rewards
        uint userRewardPerTokenPaid;   //当前用户的质押利率，每个质押token可获取多少reward
    }
    

    constructor(address _tokenReward){
        tokenReward = _tokenReward;
        rewardRate = 2;     // 2/1000 
    }

    modifier updateRewards(address user){
        rewardPerTokenAcculate = updateRewardPerToken();   //实时rewards
        uint user_deposit = userInfos[user].eth_amount;
        userInfos[user].accumulated_rewards += user_deposit.mul(rewardPerTokenAcculate - userInfos[user].userRewardPerTokenPaid).div(1e18);
        userInfos[user].userRewardPerTokenPaid = rewardPerTokenAcculate;
        updateAt = getLastTime();
        emit UserRewardsUpdated(user,userInfos[user].accumulated_rewards,updateAt);
        _;
    }


    function stake() public payable updateRewards(msg.sender){
        userInfos[msg.sender].eth_amount+= msg.value;
        totalStake+=msg.value;
        emit Staked(msg.sender,msg.value);
    }

    function unStake(uint amount) public updateRewards(msg.sender){
        require(userInfos[msg.sender].eth_amount >=amount,"amount too much!");
        payable(msg.sender).transfer(amount);
        userInfos[msg.sender].eth_amount -= amount;
        totalStake-=amount;
        emit Unstaked(msg.sender,amount);
    }

    function claim() public updateRewards(msg.sender){
       uint rewards = userInfos[msg.sender].accumulated_rewards;
       require(rewards >0 && rewards <= IERC20(tokenReward).balanceOf(msg.sender));
       IERC20(tokenReward).transfer(msg.sender, rewards);
       userInfos[msg.sender].accumulated_rewards = 0;
    }

    function extendRewardPeriod(uint duration,uint amount)external onlyOwner updateRewards(address(0)){
        require(duration>0 && amount>0);
        if(block.timestamp >= finishAt){
            rewardRate = amount.div(duration);
        }else{
            require(block.timestamp.add(duration) >= finishAt,"duration not availble!");
            uint remainingRewards = rewardRate.mul(finishAt-block.timestamp);
            rewardRate = (remainingRewards.add(amount)).div(duration);
        }
        require(rewardRate>0);
        finishAt = block.timestamp + duration;
        updateAt = block.timestamp;
        
    }   

    
    function getReamingRewards() public view returns (uint){
        return IERC20(tokenReward).balanceOf(address(this));
    }

    function updateRewardPerToken() internal view returns (uint){
        if(totalStake == 0){
            return rewardPerTokenAcculate;
        }
        return rewardPerTokenAcculate + (rewardRate.mul(getLastTime()-updateAt).mul(1e18)).div(totalStake);
    }


    
    function getLastTime() public view returns(uint){
        uint current_time = block.timestamp;
        return finishAt >current_time ? current_time:finishAt;
    }
}