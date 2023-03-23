// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../libraries/MarketStorage.sol";
import "../../lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import "../../lib/openzeppelin-contracts/contracts/interfaces/IERC721.sol";
import "lib/openzeppelin-contracts/contracts/utils/Counters.sol";

// import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract MarketPlace {
    MarketStorage internal ds;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    event ItemListed(
        uint ItemId,
        address seller,
        address ItemAddress,
        uint price
    );
    event ItemOffMarket(
        uint ItemId,
        address seller,
        address ItemAddress,
        uint price,
        address from
    );

    function ListItem(
        address _NftAddress,
        uint _NftId,
        uint _price
    ) public returns (uint) {
        uint256 ItemId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        prepareItem(ItemId, _NftAddress, _NftId, _price);
        ds.ItemsId.push(ItemId);
        ds.isCorrectId[ItemId] = true;
        emit ItemListed(ItemId, msg.sender, _NftAddress, _price);
        return ItemId;
    }

    function prepareItem(
        uint _ItemId,
        address _NftAddress,
        uint _NftId,
        uint _price
    ) internal {
        IERC721(_NftAddress).transferFrom(msg.sender, address(this), _NftId);

        ds.MarketItem[_ItemId] = marketDetails({
            isBougth: false,
            seller: msg.sender,
            price: _price,
            buyer: address(0),
            amountBougth: 0
        });
        ds.mItemDetails[_ItemId] = ItemDetails({
            NftAddress: _NftAddress,
            NftId: _NftId
        });
    }

    function TakeOffMarket(uint _ItemId) public {
        if (ds.isCorrectId[_ItemId] == false) revert("INVALID ITEM ID");
        (
            bool isBougth,
            address seller,
            uint256 price,
            address buyer,
            uint256 amountBougth,
            address NftAddress,
            uint256 NftId
        ) = fetchItemDetails(_ItemId);
        if (seller != msg.sender) revert("NOT THE ORIGINAL SELLER");
        if (isBougth == true) revert("ITEM ALREADY SOLD");
        ds.MarketItem[_ItemId].isBougth = true;
        handleItemTransfer(
            _ItemId,
            NftAddress,
            NftId,
            seller,
            address(this),
            msg.sender,
            price,
            amountBougth
        );
        emit ItemOffMarket(_ItemId, msg.sender, NftAddress, price, buyer);
    }

    function handleItemTransfer(
        uint256 _ItemId,
        address _NftAddress,
        uint256 _NftId,
        address _currentOwner,
        address _from,
        address _to,
        uint256 _price,
        uint256 _amountBougth
    ) internal {
        IERC721(_NftAddress).transferFrom(_from, msg.sender, _NftId);
        ds.MarketItem[_ItemId] = marketDetails({
            isBougth: true,
            seller: _currentOwner,
            price: _price,
            buyer: _to,
            amountBougth: _amountBougth
        });
    }

    function fetchItemDetails(
        uint256 _ItemId
    )
        internal
        view
        returns (
            bool isBougth,
            address seller,
            uint256 price,
            address buyer,
            uint256 amountBougth,
            address NftAddress,
            uint256 NftId
        )
    {
        isBougth = ds.MarketItem[_ItemId].isBougth;
        seller = ds.MarketItem[_ItemId].seller;
        price = ds.MarketItem[_ItemId].price;
        buyer = ds.MarketItem[_ItemId].buyer;
        amountBougth = ds.MarketItem[_ItemId].amountBougth;
        NftAddress = ds.mItemDetails[_ItemId].NftAddress;
        NftId = ds.mItemDetails[_ItemId].NftId;
    }
}
