// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/*
function deposit(address tokenAddress, uint256 amount) external;
function borrow(address tokenAddress, uint256 amount) external;
function repay(address tokenAddress, uint256 amount) external;
function liquidate(address user, address tokenAddress, uint256 amount) external;
function withdraw(address tokenAddress, uint256 amount) external;
*/

interface IDreamAcademyLending {
    function deposit(address tokenAddress, uint256 amount) external;
    function borrow(address tokenAddress, uint256 amount) external;
    function repay(address tokenAddress, uint256 amount) external;
    function liquidate(address user, address tokenAddress, uint256 amount) external;
    function withdraw(address tokenAddress, uint256 amount) external;
}