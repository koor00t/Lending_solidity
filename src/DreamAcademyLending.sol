// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/access/Ownable.sol";
import "./interfaces/IDreamAcademyLending.sol";
import "./interfaces/IPriceOracle.sol";

contract DreamAcademyLending is IDreamAcademyLending, Ownable{
    IPriceOracle dreamoracle;
    IERC20 public immutable usdc;
    IERC20 public immutable eth;

    uint public constant interestRate = 10**16;
    uint256 public constant LTV = 50;
    uint256 public constant LIQUIDATION_THRESHOLD = 75;
    uint public constant DECIMAL = 10**18;

    constructor (IPriceOracle _dreamoracle, address _usdc) {
        dreamoracle = _dreamoracle;
        usdc = IERC20(_usdc);
        eth = IERC20(address(this));
    }
    
    struct User {
        uint ethBalance; //balance of ETH LP tokens
        uint usdcBalance; //balance of USDC LP tokens
        uint usdcDebt; // debt of USDC LP tokens
        uint lastBorrowTime; // last time the user borrowed
    }

    mapping(address => User) public users;

    event Deposit(address indexed user, address indexed tokenAddress, uint amount);
    event Borrow(address indexed user, address indexed tokenAddress, uint amount);
    event Repay(address indexed user, address indexed tokenAddress, uint amount);
    event Liquidate(address indexed user, address indexed liquidator, address indexed tokenAddress, uint amount);
    event Withdraw(address indexed user, address indexed tokenAddress, uint amount);

    function initializeLendingProtocol(address _usdc) external payable onlyOwner {
        usdc.transferFrom(msg.sender, address(this), msg.value);
    }

    function deposit(address tokenAddress, uint256 amount) external payable {
        require(tokenAddress == address(usdc) || tokenAddress == address(eth), "Invalid token address");
        require(amount > 0, "Amount must be positive.");
        if (tokenAddress == address(0)) {
            require(users[msg.sender].usdcBalance >= amount, "Insufficient balance.");
            users[msg.sender].usdcBalance -= amount;
            usdc.transfer(msg.sender, amount);
        } else {
            require(users[msg.sender].ethBalance >= amount && getLTV(msg.sender) <= LTV * DECIMAL/100, "Insufficient collateral or LTV exceeded");
            users[msg.sender].ethBalance -= amount;
            eth.transfer(msg.sender, amount);
        }
        emit Deposit(msg.sender, tokenAddress, amount);
    }

    function borrow(address tokenAddress, uint256 amount) public {

    }

    function repay(address tokenAddress, uint256 amount) public {

    }

    function liquidate(address user, address tokenAddress, uint256 amount) public {

    }

    function withdraw(address tokenAddress, uint256 amount) public {

    }

    function getAccruedSupplyAmount(address tokenAddress) external payable returns (uint256) {

    }

    
    // Function for getting LTV of a user (in wei)
    function getLTV(address user) public view returns (uint) {
        if (users[user].ethBalance == 0) return 0;
        uint256 ethValue = users[user].ethBalance * dreamoracle.getPrice(address(eth)) / DECIMAL;
        return users[user].usdcDebt * DECIMAL / ethValue;
    }
}
