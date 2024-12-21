// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SkillSwap {
    string public name = "SkillSwap Token";
    string public symbol = "SST";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowances;
    mapping(address => string[]) public userSkills;
    mapping(address => uint256) public userTokensEarned;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event SkillAdded(address indexed user, string skill);
    event SkillSwapped(address indexed user1, address indexed user2, string skillOffered, string skillReceived);

    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(balanceOf[sender] >= amount, "Insufficient balance");
        require(allowances[sender][msg.sender] >= amount, "Allowance exceeded");
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        allowances[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function addSkill(string memory skill) public {
        userSkills[msg.sender].push(skill);
        emit SkillAdded(msg.sender, skill);
    }

    function swapSkills(address userToSwap, string memory mySkill, string memory theirSkill, uint256 tokensRequired) public {
        require(balanceOf[msg.sender] >= tokensRequired, "Insufficient tokens");
        require(containsSkill(userToSwap, theirSkill), "User does not have the required skill");
        
        // Transfer tokens as payment for the skill swap
        balanceOf[msg.sender] -= tokensRequired;
        balanceOf[userToSwap] += tokensRequired;
        userTokensEarned[userToSwap] += tokensRequired;
        
        emit SkillSwapped(msg.sender, userToSwap, mySkill, theirSkill);
    }

    function containsSkill(address user, string memory skill) internal view returns (bool) {
        for (uint256 i = 0; i < userSkills[user].length; i++) {
            if (keccak256(abi.encodePacked(userSkills[user][i])) == keccak256(abi.encodePacked(skill))) {
                return true;
            }
        }
        return false;
    }
}
