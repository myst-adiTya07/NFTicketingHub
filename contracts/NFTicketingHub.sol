// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTicketingHub is ERC721, Ownable {
    uint256 public totalEvents;
    uint256 public constant TICKET_PRICE = 0.01 ether;

    struct Event {
        string name;
        uint256 date;
        uint256 totalTickets;
        uint256 ticketsSold;
        bool isActive;
    }

    mapping(uint256 => Event) public events;
    mapping(uint256 => mapping(address => bool)) public hasPurchased;

    constructor() ERC721("NFTicketingHub", "NFTICKET") Ownable(msg.sender) {}

    /// @notice Admin can initialize a new event
    function createEvent(
        string calldata name_,
        uint256 date_,
        uint256 totalTickets_
    ) external onlyOwner {
        events[totalEvents] = Event({
            name: name_,
            date: date_,
            totalTickets: totalTickets_,
            ticketsSold: 0,
            isActive: true
        });
        totalEvents++;
    }

    /// @notice User can buy a ticket for a given event
    function purchaseTicket(uint256 eventId) external payable {
        Event storage evt = events[eventId];

        require(evt.isActive, "This event is currently inactive");
        require(msg.value >= TICKET_PRICE, "Insufficient payment for ticket");
        require(!hasPurchased[eventId][msg.sender], "User already owns a ticket");
        require(evt.ticketsSold < evt.totalTickets, "All tickets have been sold");

        evt.ticketsSold++;
        hasPurchased[eventId][msg.sender] = true;

        uint256 tokenId = _generateTokenId(eventId, evt.ticketsSold);
        _mint(msg.sender, tokenId);
    }

    /// @notice Admin can enable or disable an event
    function toggleEventStatus(uint256 eventId) external onlyOwner {
        events[eventId].isActive = !events[eventId].isActive;
    }

    /// @notice Transfers all collected funds to the contract owner
    function withdrawFunds() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    /// @dev Produces a unique token ID using the event ID and ticket serial
    function _generateTokenId(uint256 eventId, uint256 ticketNumber) private pure returns (uint256) {
        return eventId * 1000 + ticketNumber;
    }
}
