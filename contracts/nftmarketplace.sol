// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
// import "hardhat/console.sol";
//INTERNAL IMPORT FOR OPEN ZEPPELINE
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "hardhat/console.sol";


contract nftmarketplace is ERC721URIStorage{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenids;  //every nft would have a unique id 
    Counters.Counter private _itemssold;  //will keep the track of how many token has been sold
    uint256 listingprice=0.0015 ether;


    address payable owner ;  //using payable function just to recieve funds from the marketplace
    mapping (uint256 => marketitem) private idmarketitem;  //every nft will have a unique id and will pass id into the struct marketitem which will have all the details of the nft like the owner of the contract and seeler of the contract etc.


    struct marketitem{
        uint256 tokenid;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }  

    event marketitemcreated(    //trigger the event if anything buing or selling is happening
        uint256 indexed tokenid,
        address seller,
        address owner,
        uint256 price,
        bool sold

    );

    modifier onlyowner{
        require(msg.sender==owner, "only owner of the marketplace can change the listing price" );
        _;
    }

    constructor() ERC721(" NFT METAVERSE TOKEN" , "MYNFT"){
        owner==payable(msg.sender);  //whoever will deploy the smart contract will becoem the owner of the nft

    }

    function updatelistingprice(uint256 _listingprice) public payable onlyowner{  //here listing price is the price which nft makers will give it toi the owner of this marketplace 

    }

    function getlistingprice() public view returns(uint256){
        return listingprice;
    }

    //LETS CREATE NFT TOKEN FUNCTION

    function createtoken(string memory tokenURI, uint256 price) public payable returns(uint256){ 
         //here we will create a token and assigned to a particular nft ,and here we will return the id of the token
         _tokenids.increment();  //increment the id of the token
         uint256 newtokenid=_tokenids.current();
         _mint(msg.sender, newtokenid);
         _setTokenURI(newtokenid,tokenURI);

         createmarketitem(newtokenid, price);
    
         return newtokenid;
         
    }   

    //creating market item
    function createmarketitem(uint256 tokenid, uint256 price) private{
        
        idmarketitem[tokenid] =marketitem(
            tokenid,
            payable(msg.sender),
            payable(address(this)),
            price,
            false
        );

        _transfer(msg.sender,address(this),tokenid);

        emit marketitemcreated(tokenid,msg.sender,address(this),price,false);
    }

    //function for resale of a token

    function resale(uint256 tokenid, uint256 price) public payable{
        require(idmarketitem[tokenid].owner==msg.sender,"only item owner can resale");
        require(msg.value==listingprice,"price must be equal to the listing price");
        
        idmarketitem[tokenid].sold=false;
        idmarketitem[tokenid].owner=payable(address(this));
        idmarketitem[tokenid].price=price;
        idmarketitem[tokenid].seller=payable(msg.sender);
        _itemssold.decrement();

        _transfer(msg.sender,address(this),tokenid);
    }

    //function to create market item sale;

    function createmarketsale(uint256 tokenid) public payable{
        uint256 price=idmarketitem[tokenid].price;
        require(msg.value==price," please submit the asking price in order to complete the purchase");
        idmarketitem[tokenid].sold=true;
        idmarketitem[tokenid].owner=payable(address(this));
        idmarketitem[tokenid].owner=payable(msg.sender);

        _itemssold.increment();

        _transfer(address(this),msg.sender,tokenid);

        payable(owner).transfer (listingprice);
        payable(idmarketitem[tokenid].seller).transfer(msg.value);
    }

    //getting unsold nft data;

    function fetchmarketitem() public view returns(marketitem[] memory){
        uint256 itemcount=_tokenids.current();
        uint256 unsolditemcount=_tokenids.current()-_itemssold.current();
        uint256 currentindex=0;

        marketitem[] memory item =new marketitem[](unsolditemcount);
        for(uint256 i=0;i<itemcount ;i++){
            if(idmarketitem[i+1].owner==address(this)){
                uint256 currentid=i+1;
                marketitem storage currentitem=idmarketitem[currentid];
                item[currentindex]=currentitem;
                currentindex+=1;
            }
        }
        return item;
    }

    //PURCHASE ITEM
    func



}

