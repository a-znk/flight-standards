// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControl.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/common/ERC2981.sol";

abstract contract FlightStandards is AccessControl, Ownable, ERC2981  {

  address payable public payments;

  bytes32 public constant LICENSEE = keccak256("LICENSEE");
  bytes32 public constant CREATOR = keccak256("CREATOR");
  bytes32 public constant WITHDRAW_ROLE = keccak256("WITHDRAW_ROLE");

  uint96 public royaltyFeesInBips;

  uint256 public start;
  uint256 public period;

  constructor() Ownable() {
    _setRoleAdmin(LICENSEE, LICENSEE);
    _setRoleAdmin(CREATOR, CREATOR);
    _setRoleAdmin(WITHDRAW_ROLE, LICENSEE);
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC2981, AccessControl) returns (bool) {
    return super.supportsInterface(interfaceId);
  }

  function setRoyaltyInfo(address _receiver, uint96 _royaltyFeesInBips) internal {
    _setDefaultRoyalty(_receiver, _royaltyFeesInBips);
  }

  function updateRoyaltyInfo(address _receiver, uint96 _royaltyFeesInBips) public {
    require(block.timestamp > start + period * 1 hours, "Period has not ended!");
    require(hasRole(CREATOR, msg.sender),"Caller is not the creator!");
    _setDefaultRoyalty(_receiver, _royaltyFeesInBips);
  }

  function setPayments(address payable _payments) public {
    require(block.timestamp > start + period * 1 minutes, "Period has not ended!");
    require(hasRole(CREATOR, msg.sender),"Caller is not the creator!");
    payments = _payments;
  }

  function setPeriod(uint256 _period) public {
    require(block.timestamp > start + period * 1 minutes, "Period has not ended!");
    require(hasRole(CREATOR, msg.sender),"Caller is not the creator!");
    period = _period;
  }

  function transferOwnership(address newOwner) public override {
    if (block.timestamp > start + period * 1 minutes) {
      require(hasRole(CREATOR, msg.sender), "Caller is not the creator!");
      require(newOwner != address(0),"Ownable: new owner is the zero address");
      _transferOwnership(newOwner);
    } else {
      require(hasRole(LICENSEE, msg.sender),"Caller is not the licensee!");
      require(newOwner != address(0),"Ownable: new owner is the zero address");
      _transferOwnership(newOwner);
    }
  }
}