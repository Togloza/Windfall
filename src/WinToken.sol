// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "./Access.sol";

interface Turnstile {
    function register(address) external returns (uint256);
    function withdraw(uint256 _tokenId, address _recipient, uint256 _amount) external returns (uint256);
    function balances(uint256 _tokenId) external view returns (uint256);
    function assign(uint256 _tokenId) external returns (uint256);
} 

contract WinToken is ERC721, ERC721Burnable {
    using Counters for Counters.Counter;
    Access public access;

    Counters.Counter private _tokenIdCounter;

    string baseURI;

    Turnstile immutable turnstile;

    constructor(address _accessAddress, uint _turnstileTokenId ) ERC721("winCanto", "winCANTO") {

        turnstile = Turnstile(0xEcf044C5B4b867CFda001101c617eCd347095B44);
        turnstile.assign(_turnstileTokenId);
        access = Access(_accessAddress);
        baseURI = "INSERT_BASE_URI_HERE";
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string calldata newBaseURI) public {
        require(access.hasAdminRole(msg.sender));
        baseURI = newBaseURI;
    }

    function safeMint(address to) public {
        require(access.hasMinterRole(msg.sender));
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    function getNextTokenId() external view returns (uint256) {
        return _tokenIdCounter.current();
    }

    function exists(uint256 tokenId) external view returns (bool) {
        return super._exists(tokenId);
    }

    function isApproved(
        address spender,
        uint256 tokenId
    ) public view returns (bool) {
        return super._isApprovedOrOwner(spender, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
