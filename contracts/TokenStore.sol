pragma solidity 0.8.13;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
  Demo contract that stores tokens on behalf of a user,
  and allows them to be withdrawn
 */
contract TokenStore is Ownable {

    struct Deposit {
        address erc20Token;
        uint256 balance;
    }


    mapping(address => Deposit[]) depositsByOwner;

    function withdrawApprove(address erc20Token, uint256 amount) public {
        IERC20 token = IERC20(erc20Token);
        token.approve(msg.sender, amount);  
    }

    function deposit(address erc20Token, uint256 amount) public {
        uint balanceIdx = getBalanceIdx(msg.sender, erc20Token);
        depositsByOwner[msg.sender][balanceIdx].balance += amount;

        IERC20 token = IERC20(erc20Token);
        token.transferFrom(msg.sender, address(this), amount);  
    }

    function withdraw(address erc20Token, uint256 amount) public {

        uint balanceIdx = getBalanceIdx(msg.sender, erc20Token);
        uint256 existingBalance = depositsByOwner[msg.sender][balanceIdx].balance;
        require(existingBalance >= amount, "Insufficient balance");
        depositsByOwner[msg.sender][balanceIdx].balance -= amount;

        IERC20 token = IERC20(erc20Token);
        token.transfer(msg.sender, amount);        
    }

    function getBalances() public view returns (Deposit[] memory) {
        return depositsByOwner[msg.sender];
    }

    function getBalanceIdx(address owner, address erc20Token) private returns (uint) {
        Deposit[] memory deposits = depositsByOwner[owner];
        for(uint i = 0; i < deposits.length; i++ ) {
            if (deposits[i].erc20Token == erc20Token) {
                return i;
            }
        }
        Deposit memory newdeposit;
        newdeposit.erc20Token = erc20Token;
        newdeposit.balance = 0;
        depositsByOwner[owner].push(newdeposit);
        return depositsByOwner[owner].length - 1;
    }
}