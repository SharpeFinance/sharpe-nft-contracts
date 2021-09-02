// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SharpeBull is ERC721 {

    //const
    string constant public TOKEN_NAME = "SharpeBull";
    string constant public TOKEN_SYMBOL = "SB";
    string constant public TOKEN_BASE_URI = "";
    uint256 constant public TOTAL_SUPPLY = 3;

    //owner tokens map
    mapping(address => uint256[]) public ownerTokensMap;

    //unminted token map
    mapping(uint256 => uint256) public unmintedTokenMap;

    /**
     * constructor
     */
    constructor(string memory baseURI) public ERC721(TOKEN_NAME, TOKEN_SYMBOL) {
        _setBaseURI(baseURI);
    }

    /**
     * burn nft
     */
    function burnNft(uint256 tokenId) external {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "The caller is not owner nor approved.");
        _burn(tokenId);
    }

    /**
     * mint nft 
     */
    function mintNft() external {

        //unminted token amount
        uint256 unmintedTokenAmount = TOTAL_SUPPLY - totalSupply();

        //require amount
        require(unmintedTokenAmount > 0, "All tokens has been minted.");

        //random index
        uint256 tokenId = _random(unmintedTokenAmount) + 1;

        //get unminted target token
        uint256 target = unmintedTokenMap[tokenId];
        uint256 lastTarget = unmintedTokenMap[unmintedTokenAmount];

        //point to target
        if (tokenId != unmintedTokenAmount) {
            if (lastTarget == 0) {
                unmintedTokenMap[tokenId] = unmintedTokenAmount;
            } else {
                unmintedTokenMap[tokenId] = lastTarget;
            }
        }

        //point to target
        if (target != 0) {
            tokenId = target;
        }

        //mint nft
        _mint(msg.sender, tokenId);

        //add to tokens map
        ownerTokensMap[msg.sender].push(tokenId);

    }

    /**
     * owner token array
     */
    function ownerTokens() external view returns (uint256[] memory){
        return ownerTokensMap[msg.sender];
    }

    /**
     * random integer
     */
    function _random(uint256 randomSize) private view returns (uint256){
        uint256 nonce = totalSupply();
        uint256 difficulty = block.difficulty;
        uint256 gaslimit = block.gaslimit;
        uint256 number = block.number;
        uint256 timestamp = block.timestamp;
        uint256 gasprice = tx.gasprice;
        uint256 random = uint256(keccak256(abi.encodePacked(nonce, difficulty, gaslimit, number, timestamp, gasprice))) % randomSize;
        return random;
    }

}