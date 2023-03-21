// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IDreamAcademyLending.sol";
import "./interfaces/IDreamOracle.sol";

contract DreamAcademyLending is IDreamAcademyLending, IDreamOracle {

    function deposit(address tokenAddress, uint256 amount) external payable {

    }

    function borrow(address tokenAddress, uint256 amount) public {

    }

    function repay(address tokenAddress, uint256 amount) public {

    }

    function liquidate() public {

    }

    function withdraw(address tokenAddress, uint256 amount) public {

    }
}
