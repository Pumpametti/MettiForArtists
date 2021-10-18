
// 88b           d88  88888888888  888888888888  888888888888  88     88888888888  ,ad8888ba,    88888888ba             db         88888888ba  888888888888  88   ad88888ba  888888888888  ad88888ba   
// 888b         d888  88                88            88       88     88          d8"'    `"8b   88      "8b           d88b        88      "8b      88       88  d8"     "8b      88      d8"     "8b  
// 88`8b       d8'88  88                88            88       88     88         d8'        `8b  88      ,8P          d8'`8b       88      ,8P      88       88  Y8,              88      Y8,          
// 88 `8b     d8' 88  88aaaaa           88            88       88     88aaaaa    88          88  88aaaaaa8P'         d8'  `8b      88aaaaaa8P'      88       88  `Y8aaaaa,        88      `Y8aaaaa,    
// 88  `8b   d8'  88  88"""""           88            88       88     88"""""    88          88  88""""88'          d8YaaaaY8b     88""""88'        88       88    `"""""8b,      88        `"""""8b,  
// 88   `8b d8'   88  88                88            88       88     88         Y8,        ,8P  88    `8b         d8""""""""8b    88    `8b        88       88          `8b      88              `8b  
// 88    `888'    88  88                88            88       88     88          Y8a.    .a8P   88     `8b       d8'        `8b   88     `8b       88       88  Y8a     a8P      88      Y8a     a8P  
// 88     `8'     88  88888888888       88            88       88     88           `"Y8888Y"'    88      `8b     d8'          `8b  88      `8b      88       88   "Y88888P"       88       "Y88888P"   
                                                                                                                                                                                                    
//MettiForArtists is an open-source smart contract started by Pumpametti that allows artists with limited or no technical background to mint NFT artworks on their own custom contracts instead of using OpenSea Storefront Contract.
//With MettiForArtists you can mint unique artworks under your artist name, set irrevocable artwork links for your unique artworks, also set artwork royalties.
//More detailed tutorial and peer help will be availalble in Pumpametti Discord dev-Chat. 
//No artist should starve due to technical barrier.
//https://linktr.ee/Pumpametti

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Royalties.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MettiForArtists is ERC721, ERC721URIStorage, ERC721Burnable, ERC721Enumerable, Ownable, Royalties {  
     using SafeMath for uint256;
     using Strings for uint256;
   
    // Freeze OS Metadata to make artwork irrevocable
    event PermanentURI(string _value, uint256 indexed _id);

    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    string private _baseURIextended;
    uint256 private _MAX_UniqueWork = 2000000;
    
    //Here you can set smart contract name and token symbol

    constructor() ERC721("MettiForArtists", "MFA") {}

    function mintUniqueWork(
        address to,
        string memory _tokenURI,
        address payable receiver,
        uint256 basisPoints
    ) public onlyOwner {
        require(basisPoints < 10000, "Total royalties should not exceed 100%");
        uint256 tokenId = getNextTokenId();
        require(
            tokenId < _MAX_UniqueWork,
            "Maximum number of unique artworks exceeded"
        );

        _mintUniqueWork(to, tokenId, _tokenURI, receiver, basisPoints);
        _tokenIdCounter.increment();
    }

    function getNextTokenId() public view returns (uint256) {
        return _tokenIdCounter.current() + 1;
    }

    function _mintUniqueWork(
        address to,
        uint256 tokenId,
        string memory _tokenURI,
        address payable receiver,
        uint256 basisPoints
    ) internal {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        if (basisPoints > 0) {
            _setRoyalties(tokenId, receiver, basisPoints);
        }
        emit PermanentURI(tokenURI(tokenId), tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function _existsRoyalties(uint256 tokenId)
        internal
        view
        virtual
        override(Royalties)
        returns (bool)
    {
        return super._exists(tokenId);
    }

    function _getRoyaltyFallback()
        internal
        view
        override
        returns (address payable)
    {
        return payable(owner());
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return
            super.supportsInterface(interfaceId) ||
            _supportsRoyaltyInterfaces(interfaceId);
    }
}
