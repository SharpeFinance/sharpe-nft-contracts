// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SharpeFinanceCattle is Context, AccessControl, ERC721 {

    //const
    string constant public TOKEN_NAME = "SharpeFinanceCattle";
    string constant public TOKEN_SYMBOL = "SFC";
    uint256 constant public TOKEN_PRICE = 0 ether;
    uint256 constant public MAX_SUPPLY = 100;
    uint256 constant public MINT_START = 1631163238;
    uint256 constant public WHITE_LIST_MINT_START = 1631159638;
    address public owner;

    //unminted token map
    mapping(uint256 => uint256) public unmintedTokenMap;

    //white list map
    mapping(address => uint8) public whiteList;

    /**
     * constructor
     */
    constructor(string memory baseURI) public ERC721(TOKEN_NAME, TOKEN_SYMBOL) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setBaseURI(baseURI);
        owner = _msgSender();
    }

    /**
     * add address to white list
     */
    function addToWhiteList(address[] memory addressArray) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Admin role requested.");
        require(addressArray.length > 0, "Empty address array.");
        for (uint i = 0; i < addressArray.length; i++) {
            address addr = addressArray[i];
            whiteList[addr] = 5;
        }
    }

    /**
     * withdraw
     */
    function withdraw() external {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Admin role requested.");
        require(address(this).balance > 0, "Insufficient fund.");
        _msgSender().transfer(address(this).balance);
    }

    /**
     * mint nft
     */
    function mintNft() external payable {

        //check value
        require(msg.value == TOKEN_PRICE, "Insufficient fund.");

        //require amount
        require(totalSupply() < MAX_SUPPLY, "All tokens has been minted.");

        //require owner token amount
        require(balanceOf(_msgSender()) < 10, "Account reaches max token amount.");

        //require mint start
        if (whiteList[_msgSender()] > 0 && whiteList[_msgSender() <= 5]) {
            require(block.timestamp >= WHITE_LIST_MINT_START, "Mint has not started.");
            whiteList[_msgSender()]--;
        } else {
            require(block.timestamp >= MINT_START, "Mint has not started.");
        }

        //remain
        uint256 remain = MAX_SUPPLY - totalSupply();

        //last token
        uint256 lastToken = unmintedTokenAmount - 1;

        //random index
        uint256 tokenId = _random(unmintedTokenAmount);

        //get unminted target token
        uint256 target = unmintedTokenMap[tokenId];
        uint256 lastTarget = unmintedTokenMap[lastToken];

        //point to target
        if (tokenId != lastToken) {
            if (lastTarget == 0) {
                unmintedTokenMap[tokenId] = lastToken;
            } else {
                unmintedTokenMap[tokenId] = lastTarget;
            }
        }

        //point to target
        if (target != 0) {
            tokenId = target;
        }

        //mint nft
        _mint(_msgSender(), tokenId);

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