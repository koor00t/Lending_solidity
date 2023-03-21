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

    constructor (IPriceOracle _dreamoracle, address _usdc) {
        dreamoracle = _dreamoracle;
        usdc = IERC20(_usdc);
    }

    function initializeLendingProtocol(address _usdc) external payable onlyOwner {

    }

    function deposit(address tokenAddress, uint256 amount) external payable {

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
}
