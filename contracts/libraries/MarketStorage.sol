// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// library LibAuctionStorage {

struct marketDetails {
    bool isBougth;
    address seller;
    uint256 price;
    address buyer;
    uint256 amountBougth;
}

struct ItemDetails {
    address NftAddress;
    uint NftId;
}

struct MarketStorage {
    address Moderator;
    uint256[] ItemsId;
    mapping(uint256 => bool) isCorrectId;
    mapping(uint256 => marketDetails) MarketItem;
    mapping(uint256 => ItemDetails) mItemDetails;
}
// }
