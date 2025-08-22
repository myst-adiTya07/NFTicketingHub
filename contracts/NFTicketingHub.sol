// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract NFTicketingHub is ERC721, Ownable {
    uint256 public eventCount;


    uint256 public constant FIXED_TICKET_PRICE = 0.01 ether;

    struct EventDetails {
        string title;
        uint256 eventDate;
        uint256 maxTickets;
        uint256 ticketsIssued;
        bool available;
    }

    mapping(uint256 => EventDetails) public eventData;
    mapping(uint256 => mapping(address => bool)) public ticketHolders;

    constructor() ERC721("NFTicketingHub", "NFTICKET") Ownable(msg.sender) {}

    /// @notice Owner can add a new event with basic information
    function registerEvent(
        string calldata title_,
        uint256 eventDate_,
        uint256 maxTickets_
    ) external onlyOwner {
        eventData[eventCount] = EventDetails({
            title: title_,
            eventDate: eventDate_,
            maxTickets: maxTickets_,
            ticketsIssued: 0,
            available: true
        });
        eventCount++;
    }

    /// @notice Public function to buy a ticket for a selected event
    function buyTicket(uint256 eventId) external payable {
        EventDetails storage selectedEvent = eventData[eventId];

        require(selectedEvent.available, "Event is disabled or unavailable");
        require(msg.value >= FIXED_TICKET_PRICE, "Payment does not meet ticket cost");
        require(!ticketHolders[eventId][msg.sender], "Ticket already bought by user");
        require(selectedEvent.ticketsIssued < selectedEvent.maxTickets, "Tickets exhausted");

        selectedEvent.ticketsIssued++;

        ticketHolders[eventId][msg.sender] = true;

        uint256 tokenId = _composeTokenId(eventId, selectedEvent.ticketsIssued);
        _mint(msg.sender, tokenId);
    }

    /// @notice Enables or disables an existing event (by owner)
    function switchEventStatus(uint256 eventId) external onlyOwner {
        eventData[eventId].available = !eventData[eventId].available;
    }


    /// @notice Transfers all ETH balance from contract to the owner's address
    function releaseFunds() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    /// @dev Generates a token ID by combining event ID and its ticket number
    function _composeTokenId(uint256 eventId, uint256 ticketSeq) private pure returns (uint256) {
        return eventId * 1000 + ticketSeq;
    }
}
