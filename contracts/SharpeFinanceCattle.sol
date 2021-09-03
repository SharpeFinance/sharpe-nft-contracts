// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SharpeFinanceCattle is Context, AccessControl, ERC721 {

    //const
    string constant public TOKEN_NAME = "SharpeFinanceCattle";
    string constant public TOKEN_SYMBOL = "SFC";
    uint256 constant public TOKEN_PRICE = 0.0618 ether;
    uint256 constant public MAX_SUPPLY = 5000;

    //unminted token map
    mapping(uint256 => uint256) public unmintedTokenMap;

    /**
     * constructor
     */
    constructor(string memory baseURI) public ERC721(TOKEN_NAME, TOKEN_SYMBOL) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setBaseURI(baseURI);
    }

    /**
     * get balance
     */
    function getBalance() public view returns (uint256) {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Admin role requested.");
        return address(this).balance;
    }

    /**
     * withdraw
     */
    function withdraw(uint256 amount) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Admin role requested.");
        require(amount <= getBalance(), "Insufficient fund.");
        _msgSender().transfer(amount);
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
    function mintNft() external payable {

        //check value
        require(msg.value == TOKEN_PRICE, "Insufficient fund.");

        //unminted token amount
        uint256 unmintedTokenAmount = MAX_SUPPLY - totalSupply();

        //require amount
        require(unmintedTokenAmount > 0, "All tokens has been minted.");

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