// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTicketingHub is ERC721, Ownable {
    uint256 public totalEvents;
    string private baseTokenURI;

    struct Event {
        string name;
        uint256 date;
        uint256 totalTickets;
        uint256 ticketsSold;
        uint256 ticketPrice;
        bool isActive;
    }

    mapping(uint256 => Event) public events;
    mapping(uint256 => mapping(address => bool)) public hasPurchased;

    event EventCreated(uint256 indexed eventId, string name, uint256 date, uint256 ticketPrice);
    event TicketPurchased(uint256 indexed eventId, address buyer, uint256 tokenId);
    event EventStatusToggled(uint256 indexed eventId, bool isActive);

    constructor(string memory baseURI_) ERC721("NFTicketingHub", "NFTICKET") Ownable(msg.sender) {
        baseTokenURI = baseURI_;
    }

    function createEvent(
        string calldata name_,
        uint256 date_,
        uint256 totalTickets_,
        uint256 ticketPrice_
    ) external onlyOwner {
        require(date_ > block.timestamp, "Event date must be in the future");
        events[totalEvents] = Event({
            name: name_,
            date: date_,
            totalTickets: totalTickets_,
            ticketsSold: 0,
            ticketPrice: ticketPrice_,
            isActive: true
        });

        emit EventCreated(totalEvents, name_, date_, ticketPrice_);
        totalEvents++;
    }

    function purchaseTicket(uint256 eventId) external payable {
        Event storage evt = events[eventId];

        require(evt.isActive, "Event is not active");
        require(block.timestamp < evt.date, "Event already occurred");
        require(msg.value >= evt.ticketPrice, "Insufficient ETH for ticket");
        require(!hasPurchased[eventId][msg.sender], "Already purchased");
        require(evt.ticketsSold < evt.totalTickets, "Sold out");

        evt.ticketsSold++;
        hasPurchased[eventId][msg.sender] = true;

        uint256 tokenId = _generateTokenId(eventId, evt.ticketsSold);
        _mint(msg.sender, tokenId);

        emit TicketPurchased(eventId, msg.sender, tokenId);
    }

    function toggleEventStatus(uint256 eventId) external onlyOwner {
        events[eventId].isActive = !events[eventId].isActive;
        emit EventStatusToggled(eventId, events[eventId].isActive);
    }

    function withdrawFunds() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function getEvent(uint256 eventId) external view returns (Event memory) {
        return events[eventId];
    }

    function _generateTokenId(uint256 eventId, uint256 ticketNumber) private pure returns (uint256) {
        return eventId * 10000 + ticketNumber;
    }

    // Restrict transfers after the event date
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override {
        if (from != address(0)) { // Not minting
            uint256 eventId = tokenId / 10000;
            require(block.timestamp < events[eventId].date, "Ticket transfer not allowed after event");
        }
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // Optional: baseURI override
    function _baseURI() internal view override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string calldata newBaseURI) external onlyOwner {
        baseTokenURI = newBaseURI;
    }
}
