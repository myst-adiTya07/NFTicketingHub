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

    /// @notice Creates a new event
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

    /// @notice Allows user to purchase a ticket for a specific event
    function purchaseTicket(uint256 eventId) external payable {
        Event storage evt = events[eventId];

        require(evt.isActive, "Event is not active");
        require(msg.value >= TICKET_PRICE, "Ticket price not met");
        require(!hasPurchased[eventId][msg.sender], "Ticket already purchased");
        require(evt.ticketsSold < evt.totalTickets, "Tickets sold out");

        evt.ticketsSold++;
        hasPurchased[eventId][msg.sender] = true;

        uint256 tokenId = _generateTokenId(eventId, evt.ticketsSold);
        _mint(msg.sender, tokenId);
    }

    /// @notice Toggles the active status of an event
    function toggleEventStatus(uint256 eventId) external onlyOwner {
        events[eventId].isActive = !events[eventId].isActive;
    }

    /// @notice Withdraws all funds to the owner
    function withdrawFunds() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    /// @dev Generates a unique tokenId based on eventId and ticket number
    function _generateTokenId(uint256 eventId, uint256 ticketNumber) private pure returns (uint256) {
        return eventId * 1000 + ticketNumber;
    }
}
