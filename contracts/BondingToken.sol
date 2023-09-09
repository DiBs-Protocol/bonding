// SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IBancorFormula {
    function calculatePurchaseReturn(
        uint256 _supply,
        uint256 _connectorBalance,
        uint32 _connectorWeight,
        uint256 _depositAmount
    ) external view returns (uint256);

    function calculateSaleReturn(
        uint256 _supply,
        uint256 _connectorBalance,
        uint32 _connectorWeight,
        uint256 _sellAmount
    ) external view returns (uint256);
}

contract BondingToken is ERC20, ReentrancyGuard {
    using SafeERC20 for IERC20;

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

        initialize(_initialSupply, _initialPrice);
    }

    function getPurchaseReturn(uint256 amount) public view returns (uint256) {
        return
            IBancorFormula(curve).calculatePurchaseReturn(
                totalSupply(),
                connectorBalance,
                connectorWeight,
                amount
            );
    }

    function getSaleReturn(uint256 amount) public view returns (uint256) {
        return
            IBancorFormula(curve).calculateSaleReturn(
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

    function initialize(
        uint256 _initialSupply,
        uint256 _initialPrice
    ) internal {
        require(_initialSupply > 0, "BondingToken: ZERO_SUPPLY");
        require(_initialPrice > 0, "BondingToken: ZERO_INITIAL_PRICE");

        uint256 _initialConnectorBalance = (_initialSupply *
            _initialPrice *
            1000000) / (connectorWeight * 1e18);

        _mint(address(this), _initialSupply);
        connectorBalance = _initialConnectorBalance;

        emit Initialized(
            _initialPrice,
            _initialSupply,
            _initialConnectorBalance
        );
    }
}
