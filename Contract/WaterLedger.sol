// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title WaterLedger
 * @dev A decentralized water usage tracking and credit trading system.
 * Users can log their water usage, earn/save water credits, and transfer credits.
 */
contract WaterLedger {
    struct User {
        uint256 totalUsage;    // Total water used (in liters)
        uint256 waterCredits;  // Credits earned (1 credit = 1 liter saved)
        bool registered;
    }

    mapping(address => User) private users;
    address public admin;

    event UserRegistered(address indexed user);
    event WaterLogged(address indexed user, uint256 amountUsed);
    event CreditsTransferred(address indexed from, address indexed to, uint256 amount);

    modifier onlyRegistered() {
        require(users[msg.sender].registered, "User not registered");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /**
     * @notice Register a new user in the WaterLedger system
     */
    function registerUser() external {
        require(!users[msg.sender].registered, "Already registered");
        users[msg.sender] = User(0, 0, true);
        emit UserRegistered(msg.sender);
    }

    /**
     * @notice Log water usage; users may lose or earn credits
     * @param amountUsed The amount of water used in liters
     */
    function logWaterUsage(uint256 amountUsed) external onlyRegistered {
        require(amountUsed > 0, "Amount must be greater than 0");
        users[msg.sender].totalUsage += amountUsed;

        // Reward credits for low usage (<100 liters)
        if (amountUsed < 100) {
            users[msg.sender].waterCredits += 10; // Reward bonus credits
        }

        emit WaterLogged(msg.sender, amountUsed);
    }

    /**
     * @notice Transfer credits between users
     * @param recipient The address receiving credits
     * @param amount The number of credits to transfer
     */
    function transferCredits(address recipient, uint256 amount) external onlyRegistered {
        require(users[recipient].registered, "Recipient not registered");
        require(users[msg.sender].waterCredits >= amount, "Insufficient credits");

        users[msg.sender].waterCredits -= amount;
        users[recipient].waterCredits += amount;

        emit CreditsTransferred(msg.sender, recipient, amount);
    }

    /**
     * @notice Get user information
     */
    function getUserData(address user) external view returns (uint256, uint256, bool) {
        User memory u = users[user];
        return (u.totalUsage, u.waterCredits, u.registered);
    }
}

