// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/access/Ownable.sol";
import "./interfaces/IDreamAcademyLending.sol";
import "./interfaces/IPriceOracle.sol";

contract DreamAcademyLending is IDreamAcademyLending, Ownable{
    IPriceOracle dreamoracle;
    IERC20 public usdc;

    uint public constant INTEREST_RATE = 1000000000315522921573372069;
    uint256 public constant LTV = 50;
    uint256 public constant LIQUIDATION_THRESHOLD = 75;
    uint public constant DECIMAL = 10**18;
    uint256 public constant BLOCK_PER_DAY = 7200;

    constructor (IPriceOracle _dreamoracle, address _usdc) {
        dreamoracle = _dreamoracle;
        usdc = IERC20(_usdc);
    }
    
    struct User {
        uint usdcBalance; //balance of USDC
        uint usdcDebt; // debt of USDC LP tokens
        uint ethCollateral; //balance of ETH Collateral
        uint lastBorrowBlock; // last block the user borrowed
    }

    mapping(address => User) public users;

    event Deposit(address indexed user, address indexed tokenAddress, uint amount);
    event Borrow(address indexed user, address indexed tokenAddress, uint amount);
    event Repay(address indexed user, address indexed tokenAddress, uint amount);
    event Liquidate(address indexed user, address indexed tokenAddress, uint amount);
    event Withdraw(address indexed user, address indexed tokenAddress, uint amount);

    function initializeLendingProtocol(address _usdc) external payable onlyOwner {
        usdc.transferFrom(msg.sender, address(this), msg.value);
    }

    function deposit(address tokenAddress, uint256 amount) external payable {
        //address(0) = ETH
        if (tokenAddress == address(0)) {
            require(msg.value > 0, "ETH deposit must not zero.");
            require(msg.value >= amount, "ETH deposit must be equal or more than msg.value");
            users[msg.sender].ethCollateral += msg.value;
            emit Deposit(msg.sender, tokenAddress, msg.value);
        } else {
            require(amount > 0, "USDC deposit must not zero.");
            User storage user = users[msg.sender];
            user.usdcBalance += amount;
            usdc.transferFrom(msg.sender, address(this), amount);
            emit Deposit(msg.sender, tokenAddress, amount);
        }
    }

    function borrow(address tokenAddress, uint256 amount) external {
        require(amount > 0, "amount cannot be zero");
        require(tokenAddress == address(usdc), "only USDC can be borrowed");
        uint256 userMaxBorrow = getUserLTV(msg.sender);
        uint256 maxBorrowAmount = getBorrowLTV(amount);
        require(amount <= userMaxBorrow, "User Impossible to Borrow.");
        require(amount <= maxBorrowAmount, "Not enough Amount.");
        users[msg.sender].usdcDebt += amount;
        users[msg.sender].lastBorrowBlock = block.number;
        usdc.transfer(msg.sender, amount);
        emit Borrow(msg.sender, tokenAddress, amount);
    }

    function repay(address tokenAddress, uint256 amount) external {
        require(amount > 0, "amount cannot be zero");
        require(tokenAddress == address(usdc), "only USDC can be repay");
        User storage user = users[msg.sender];
        uint256 interest = getInterest(user.usdcDebt, user.lastBorrowBlock, block.number);
        require(user.usdcDebt >= amount, "amount cannot exceed debt");
        user.usdcDebt += interest;
        user.lastBorrowBlock = block.number;
        user.usdcDebt -= amount;
        usdc.transferFrom(msg.sender, address(this), amount);
        emit Repay(msg.sender, tokenAddress, amount);
    }

    function liquidate(address user, address tokenAddress, uint256 amount) external {
        require(amount > 0, "amount cannot be zero");
        require(tokenAddress == address(usdc), "only USDC can be liquidated");
        User storage user_s = users[user];
        require(healthCheck(user), "Didn't liquidator");
        user_s.usdcDebt -= amount;
        usdc.transferFrom(user, address(this), amount);
        emit Liquidate(user, tokenAddress, amount);
    }

    function withdraw(address tokenAddress, uint256 amount) external {
        require(amount > 0, "amount cannot be zero");
        if (tokenAddress == address(0)) {
            require(users[msg.sender].ethCollateral >= amount,"Insufficient balance");
            users[msg.sender].ethCollateral -= amount;
            payable(msg.sender).transfer(amount);
        } else {
            require(users[msg.sender].usdcBalance >= amount,"Insufficient balance");
            users[msg.sender].usdcBalance -= amount;
            IERC20(tokenAddress).transfer(msg.sender,amount);
        }
    }

    function getAccruedSupplyAmount(address tokenAddress) public payable returns (uint256) {
    }

    function getCurrentPrice() internal view returns (uint256 ethPrice, uint256 usdcPrice) {
        ethPrice = dreamoracle.getPrice(address(0));
        usdcPrice = dreamoracle.getPrice(address(usdc));
    }

    function getBorrowLTV(uint256 amount) internal view returns (uint256) {
        uint256 ethValue = (amount * dreamoracle.getPrice(address(0))) / DECIMAL;
        return ethValue * LTV / 100;
    }

    function getUserLTV(address user) internal view returns (uint256) {
        uint256 ethCollateral = users[user].ethCollateral;
        uint256 CollateralusdcValue = (ethCollateral * dreamoracle.getPrice(address(0))) / DECIMAL;
        uint256 maxBorrowAmount = (CollateralusdcValue * LTV) / 100;
        uint256 Debt = users[user].usdcDebt;

        return maxBorrowAmount > Debt ? maxBorrowAmount - Debt : 0;
    }

    function healthCheck(address user) internal view returns (bool) {
        uint256 curDebt = users[user].usdcDebt;
        uint256 ethColl = users[user].ethCollateral;
        uint256 maxBorrowAmount = getBorrowLTV(ethColl);

        return curDebt <= maxBorrowAmount;
    }

    function getInterest(uint256 usdcDebt, uint256 lastBlock, uint256 BlockNum) internal view returns (uint256) {
        uint256 blocksElapsed = BlockNum - lastBlock;
        uint256 interest = (usdcDebt * ((INTEREST_RATE  ** blocksElapsed) -1)) / DECIMAL;
        return interest;
    }

}
