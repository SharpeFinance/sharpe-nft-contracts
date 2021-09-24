// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SharpeFinanceCattle is Ownable, ERC721 {

    //const
    string constant public TOKEN_NAME = "SharpeFinanceCattle";
    string constant public TOKEN_SYMBOL = "SFC";
    uint256 constant public TOKEN_PRICE = 0.0618 ether;
    uint256 constant public MAX_SUPPLY = 5005;
    uint256 public MINT_START;
    uint256 public PRESALE_START;
    bool public mintStart;

    //unminted token map
    mapping(uint256 => uint256) public unmintedTokenMap;

    //white list map
    mapping(address => uint8) public whiteList;

    //reward list map
    mapping(address => bool) public rewardList;

    /**
     * constructor
     */
    constructor(string memory baseURI_, uint256 mintStart_, uint256 presaleStart_) public ERC721(TOKEN_NAME, TOKEN_SYMBOL) {
        setBaseUri(baseURI_);
        setStartTime(mintStart_, presaleStart_);
        _initMint(_msgSender());
    }

    /**
     * set base uri
     */
    function setBaseUri(string memory baseURI_) public onlyOwner {
        _setBaseURI(baseURI_);
    }

    /**
     * set start time
     */
    function setStartTime(uint256 mintStart_, uint256 presaleStart_) public onlyOwner {
        MINT_START = mintStart_;
        PRESALE_START = presaleStart_;
    }

    /**
     * init mint
     */
    function _initMint(address to_) private {
        _mintFixedNft(to_, 0);
        _mintFixedNft(to_, 1);
        _mintFixedNft(to_, 2);
        _mintFixedNft(to_, 3);
        _mintFixedNft(to_, 4);
    }

    /**
     * add address to white list
     */
    function addToWhiteList(address[] memory addrs_) external onlyOwner {
        require(addrs_.length > 0, "Empty address array.");
        for (uint i = 0; i < addrs_.length; i++) {
            address addr = addrs_[i];
            whiteList[addr] = 5;
        }
    }

    /**
     * add address to reward list
     */
    function addToRewardList(address[] memory addrs_) external onlyOwner {
        require(addrs_.length > 0, "Empty address array.");
        for (uint i = 0; i < addrs_.length; i++) {
            address addr = addrs_[i];
            rewardList[addr] = true;
        }
    }

    /**
     * withdraw
     */
    function withdraw() external onlyOwner {
        require(address(this).balance > 0, "Insufficient fund.");
        _msgSender().transfer(address(this).balance);
    }

    /**
     * mint start
     */
    function startMint() external onlyOwner {
        mintStart = true;
    }

    /**
     * mint nft
     */
    function mintNft() external payable {

        //check mint start
        require(mintStart, "Mint has not started.");

        //check value
        require(msg.value == TOKEN_PRICE, "Insufficient fund.");

        //require owner token amount
        require(balanceOf(_msgSender()) < 10, "Account reaches max token amount.");

        //require mint start
        if (whiteList[_msgSender()] > 0 && whiteList[_msgSender()] <= 5) {
            require(block.timestamp >= PRESALE_START, "Mint has not started.");
            whiteList[_msgSender()]--;
        } else {
            require(block.timestamp >= MINT_START, "Mint has not started.");
        }

        //mint nft
        _mintNft(_msgSender());
    }

    /**
     * claim reward
     */
    function claimReward() external {

        //require reward
        require(rewardList[_msgSender()], "Reward qualification requested.");

        //mint nft
        _mintNft(_msgSender());

        //finish reward
        rewardList[_msgSender()] = false;
    }

    /**
     * mint nft fixed NFT
     */
    function _mintFixedNft(address to_, uint256 tokenId_) private {

        //require supply
        require(totalSupply() < MAX_SUPPLY, "All tokens has been minted.");

        //remain
        uint256 remain = MAX_SUPPLY - totalSupply();

        //last token
        uint256 lastToken = remain - 1;

        //get unminted target token
        uint256 target = unmintedTokenMap[tokenId_];
        uint256 lastTarget = unmintedTokenMap[lastToken];

        //point to target
        if (tokenId_ != lastToken) {
            if (lastTarget == 0) {
                unmintedTokenMap[tokenId_] = lastToken;
            } else {
                unmintedTokenMap[tokenId_] = lastTarget;
            }
        }

        //point to target
        if (target != 0) {
            tokenId_ = target;
        }

        //mint nft
        _mint(to_, tokenId_);
    }

    /**
     * mint nft
     */
    function _mintNft(address to_) private {

        //require supply
        require(totalSupply() < MAX_SUPPLY, "All tokens has been minted.");

        //remain
        uint256 remain = MAX_SUPPLY - totalSupply();

        //last token
        uint256 lastToken = remain - 1;

        //random index
        uint256 tokenId = _random(remain);

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
        _mint(to_, tokenId);
    }

    /**
     * random integer
     */
    function _random(uint256 randomSize_) private view returns (uint256){
        uint256 nonce = totalSupply();
        uint256 difficulty = block.difficulty;
        uint256 gaslimit = block.gaslimit;
        uint256 number = block.number;
        uint256 timestamp = block.timestamp;
        uint256 gasprice = tx.gasprice;
        uint256 random = uint256(keccak256(abi.encodePacked(nonce, difficulty, gaslimit, number, timestamp, gasprice))) % randomSize_;
        return random;
    }
}
