// SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.0;

import "./BancorFormula.sol";
import "./BondingToken.sol";

contract DiBsShares {
    address public immutable curve;

    address[] public allBondingTokens;

    event BondingTokenDeployed(
        address indexed bondingToken,
        address indexed author
    );

    constructor() {
        curve = address(new BancorFormula());
    }

    /// @dev Returns the length of allBondingTokens array
    function allBondingTokensLength() external view returns (uint256) {
        return allBondingTokens.length;
    }

    /// @dev Deploys a new bonding curve token
    /// @param name Name of the token
    /// @param symbol Symbol of the token
    /// @param _connectorToken Address of the connector token
    /// @param _connectorWeight Weight of the connector token
    /// @param _initialSupply Initial supply of the token
    /// @param _initialPrice Initial price of the token
    /// @return Address of the newly deployed bonding curve token
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

        emit BondingTokenDeployed(address(bondingToken), msg.sender);

        return address(bondingToken);
    }
}
