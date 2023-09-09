// SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.0;

import "./BancorFormula.sol";
import "./BondingToken.sol";

contract DiBsShares {
    address public immutable curve;

    address[] public allBondingTokens;

    constructor() {
        curve = address(new BancorFormula());
    }

    function allBondingTokensLength() external view returns (uint256) {
        return allBondingTokens.length;
    }

    function deployBondingToken(
        string memory name,
        string memory symbol,
        address _connectorToken,
        uint32 _connectorWeight,
        uint256 _initialSupply,
        uint256 _initialPrice
    ) external returns (address) {
        BondingToken bondingToken = new BondingToken(
            name,
            symbol,
            _connectorToken,
            _connectorWeight,
            curve,
            msg.sender,
            _initialSupply,
            _initialPrice
        );

        allBondingTokens.push(address(bondingToken));

        return address(bondingToken);
    }
}
