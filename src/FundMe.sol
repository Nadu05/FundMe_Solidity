// SPDX-License-Identifier: MIT
// 1. Pragma
pragma solidity 0.8.30;

// 2. Imports
import {AggregatorV3Interface} from "@chainlink/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConveter.sol";

// 3. Interfaces, Libraries, Contracts
error FundMe__NotOwner();

/**
 * @title A sample Funding Contract
 * @author Patrick Collins
 * @notice This contract is for creating a sample funding contract
 * @dev This implements price feeds as our library
 */
contract FundMe {
    // Type Declarations
    using PriceConverter for uint256;

    // State variables
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;
    address private immutable I_OWNER;
    address[] private sFunders;
    mapping(address => uint256) private sAddressToAmountFunded;
    AggregatorV3Interface private sPriceFeed;

    // Events (we have none!)

    // Modifiers
    modifier onlyOwner() {
        // require(msg.sender == i_owner);
        _onlyOwner();
        _;
    }

    // Functions Order:
    //// constructor
    //// receive
    //// fallback
    //// external
    //// public
    //// internal
    //// private
    //// view / pure

    constructor(address priceFeed) { //address priceFeed
        sPriceFeed = AggregatorV3Interface(priceFeed);
        I_OWNER = msg.sender;
    }

    function _onlyOwner() internal view {
        if (msg.sender != I_OWNER) revert FundMe__NotOwner();
    }

    /// @notice Funds our contract based on the ETH/USD price
    function fund() public payable {
        require(msg.value.getConversionRate(sPriceFeed) >= MINIMUM_USD, "You need to spend more ETH!");
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        sAddressToAmountFunded[msg.sender] += msg.value;
        sFunders.push(msg.sender);
    }

    // aderyn-ignore-next-line(centralization-risk,unused-public-function,state-change-without-event))
    function withdraw() public onlyOwner {
        // aderyn-ignore-next-line(storage-array-length-not-cached,costly-loop)
        for (uint256 funderIndex = 0; funderIndex < sFunders.length; funderIndex++) {
            address funder = sFunders[funderIndex];
            sAddressToAmountFunded[funder] = 0;
        }
        sFunders = new address[](0);
        // Transfer vs call vs Send
        // payable(msg.sender).transfer(address(this).balance);
        (bool success,) = I_OWNER.call{value: address(this).balance}("");
        require(success);
    }

    function cheaperWithdraw() public onlyOwner {
        address[] memory funders = sFunders;
        // mappings can't be in memory, sorry!
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            sAddressToAmountFunded[funder] = 0;
        }
        sFunders = new address[](0);
        // payable(msg.sender).transfer(address(this).balance);
        (bool success,) = I_OWNER.call{value: address(this).balance}("");
        require(success);
    }

    /**
     * Getter Functions
     */

    /**
     * @notice Gets the amount that an address has funded
     *  @param fundingAddress the address of the funder
     *  @return the amount funded
     */
    function getAddressToAmountFunded(address fundingAddress) public view returns (uint256) {
        return sAddressToAmountFunded[fundingAddress];
    }

    function getVersion() public view returns (uint256) {
        return sPriceFeed.version();
    }

    function getFunder(uint256 index) public view returns (address) {
        return sFunders[index];
    }

    function getOwner() public view returns (address) {
        return I_OWNER;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return sPriceFeed;
    }
}
