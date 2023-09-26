// SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/ICurve.sol";

contract BondingToken is ERC20, ReentrancyGuard {
    using SafeERC20 for IERC20;

    address public immutable factory;

    address public immutable author;
    address public immutable connectorToken;
    uint32 public immutable connectorWeight; // represented in ppm, 1-1000000
    address public immutable curve;

    uint256 public connectorBalance;

    event Initialized(
        uint256 initialPrice,
        uint256 initialSupply,
        uint256 initialConnectorBalance
    );

    event Minted(
        address indexed recipient,
        uint256 purchaseReturn,
        uint256 amountDeposited
    );

    event Burned(
        address indexed from,
        uint256 saleReturn,
        uint256 amountBurned
    );

    constructor(
        string memory name,
        string memory symbol,
        address _connectorToken,
        uint32 _connectorWeight,
        address _curve,
        address _author,
        uint256 _initialSupply,
        uint256 _initialPrice
    ) ERC20(name, symbol) {
        require(
            _connectorWeight > 0 && _connectorWeight <= 1000000,
            "BondingToken: INVALID_WEIGHT"
        );

        connectorToken = _connectorToken;
        connectorWeight = _connectorWeight;
        curve = _curve;
        author = _author;

        factory = msg.sender;

        initialize(_initialSupply, _initialPrice);
    }

    /// @notice Get the current market cap of the bonding token in terms of the connector token
    /// @return market cap of the bonding token
    function getMarketCap() external view returns (uint256) {
        return spotPrice() * totalSupply();
    }

    /// @notice Get the current spot price of the bonding token
    /// @return spot price of the bonding token
    function spotPrice() public view returns (uint256) {
        return (connectorBalance * 1e24) / (totalSupply() * connectorWeight);
    }

    /// @notice Get the amount of bonding tokens that would be minted for depositing connector tokens
    /// @param amount amount of connector tokens to deposit
    /// @return amount of bonding tokens minted
    function getPurchaseReturn(uint256 amount) public view returns (uint256) {
        return
            ICurve(curve).calculatePurchaseReturn(
                totalSupply(),
                connectorBalance,
                connectorWeight,
                amount
            );
    }

    /// @notice Get the amount of connector tokens that would be returned for selling bonding tokens
    /// @param amount amount of bonding tokens to sell
    /// @return amount of connector tokens returned
    function getSaleReturn(uint256 amount) public view returns (uint256) {
        return
            ICurve(curve).calculateSaleReturn(
                totalSupply(),
                connectorBalance,
                connectorWeight,
                amount
            );
    }

    /// @notice Buy bonding tokens using connector tokens
    /// @param to recipient of the minted tokens
    /// @param amount amount of connector tokens to deposit
    function mint(address to, uint256 amount) external nonReentrant {
        uint256 purchaseReturn = getPurchaseReturn(amount);
        connectorBalance += amount; // Update state first
        _mint(to, purchaseReturn);
        IERC20(connectorToken).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );

        emit Minted(to, purchaseReturn, amount);
    }

    /// @notice Sell bonding tokens for connector tokens
    /// @param amount amount of bonding tokens to burn
    /// @param to owner of the tokens
    function burn(uint256 amount, address to) external nonReentrant {
        uint256 saleReturn = getSaleReturn(amount);

        connectorBalance -= saleReturn; // Update state first
        _burn(msg.sender, amount);
        IERC20(connectorToken).safeTransfer(to, saleReturn);

        emit Burned(msg.sender, saleReturn, amount);
    }

    /// @notice Initialize the bonding curve
    /// @param _initialSupply initial supply of bonding tokens
    /// @param _initialPrice initial price of bonding tokens
    function initialize(
        uint256 _initialSupply,
        uint256 _initialPrice
    ) internal {
        require(_initialSupply > 0, "BondingToken: ZERO_SUPPLY");
        require(_initialPrice > 0, "BondingToken: ZERO_INITIAL_PRICE");

        uint256 _initialConnectorBalance = (_initialSupply *
            _initialPrice *
            1000000) / (uint256(connectorWeight) * 1e18);

        _mint(address(this), _initialSupply);
        connectorBalance = _initialConnectorBalance;

        require(connectorBalance > 0, "BondingToken: ZERO_CONNECTOR_BALANCE");

        emit Initialized(
            _initialPrice,
            _initialSupply,
            _initialConnectorBalance
        );
    }
}
