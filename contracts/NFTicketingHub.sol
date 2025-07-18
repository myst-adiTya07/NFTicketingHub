// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTicketingHub is ERC721, Ownable {
    uint256 public totalEvents;
    uint256 public ticketPrice = 0.01 ether;
    
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

    function createEvent(
        string memory _name,
        uint256 _date,
        uint256 _totalTickets
    ) external onlyOwner {
        events[totalEvents] = Event({
            name: _name,
            date: _date,
            totalTickets: _totalTickets,
            ticketsSold: 0,
            isActive: true
        });
        totalEvents++;
    }

    function purchaseTicket(uint256 eventId) external payable {
        require(events[eventId].isActive, "Event not active");
        require(msg.value >= ticketPrice, "Insufficient payment");
        require(!hasPurchased[eventId][msg.sender], "Already purchased");
        require(events[eventId].ticketsSold < events[eventId].totalTickets, "Sold out");

        events[eventId].ticketsSold++;
        hasPurchased[eventId][msg.sender] = true;
        _mint(msg.sender, eventId * 1000 + events[eventId].ticketsSold);
    }

    function toggleEventStatus(uint256 eventId) external onlyOwner {
        events[eventId].isActive = !events[eventId].isActive;
    }

    function withdrawFunds() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
