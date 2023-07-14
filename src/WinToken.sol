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

    using Counters for Counters.Counter; // Enumeration of tokens.
    Counters.Counter private _tokenIdCounter;

    Access public access; // Instantiate access contract for perms to be global across contracts.

    string baseURI;

    Turnstile immutable turnstile; // Needed for CANTO CSR.

    mapping (uint => address) tokenOwner; // Track token ownership for front end.

    constructor(address _accessAddress, uint _turnstileTokenId ) ERC721("winCanto", "WIN") {
        turnstile = Turnstile(0xEcf044C5B4b867CFda001101c617eCd347095B44); // Initialize CSR contract.
        turnstile.assign(_turnstileTokenId); // Assign CSR rewards to the same token as factory contract.
        access = Access(_accessAddress);
        baseURI = "https://storage.cloud.google.com/windfall-wintoken/windfall-metadata/";
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }
    // Allow admin to set the baseURI in case of a need for breaking metadata changes.
    function setBaseURI(string calldata newBaseURI) public {
        require(access.hasAdminRole(msg.sender));
        baseURI = newBaseURI;
    }
    // Mint tokens to "to" address, _safeMint calls _mint which calls _beforeTokenTransfer which updates tokenOwner.
    // Minter role required. 
    function safeMint(address to) public {
        require(access.hasMinterRole(msg.sender));
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }


    function getNextTokenId() public view returns (uint256) {
        return _tokenIdCounter.current();
    }
    // Function to find which tokens an address owns. Only to be used by front end since gas intensive.
    // Only needed for deployment on chains that don't support retrieving token ownership easily. 
    function getTokensOfOwner(address owner) external view returns (uint[] memory) {
    uint tokenCount = getNextTokenId();
    uint[] memory tokenIds = new uint[](tokenCount);
    uint counter = 0;
    for (uint i = 0; i < tokenCount; i++) {
        if (tokenOwner[i] == owner) {
            tokenIds[counter] = i;
            counter++;
        }
    }
    return tokenIds;
}

    function exists(uint256 tokenId) external view returns (bool) {
        return super._exists(tokenId);
    }

    function isApproved(address spender, uint256 tokenId) public view returns (bool) {
        return super._isApprovedOrOwner(spender, tokenId);
    }

    // Called before transfer events on the token. Batching doesn't make much sense so restricted.
    // Used to track token ownership. 
    function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal override {
        require(batchSize == 1, "Batch transfer not supported"); 
        tokenOwner[firstTokenId] = to; 
        super._beforeTokenTransfer(from, to, firstTokenId, 1);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
