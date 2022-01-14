pragma solidity 0.8.4;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 *@dev DNU NFT
 */
contract Dnu is ERC721, Ownable, AccessControl {
    // Member role
    bytes32 public constant MEMBER_ROLE = keccak256("MEMBER_ROLE");

    // Counter of NFT
    uint256 public tokenCounter;

    // URI of Zero NFT
    string public zeroTokenURI;

    // URI of Basis NFT
    string public baseTokenURI;

    // Mapping of (tokenId,tokenURI)
    mapping(uint256 => string) private _tokenURIs;

    // Have minted a NFT
    mapping(address => bool) private _minted;

    /**
     *@dev Initializes the contract by setting a `name` and a `symbol` to the token collection
     *@param name NFT's name
     *@param symbol NFT's symbol
     */
    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        tokenCounter = 0;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     *@dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /**
     *@dev Set the URI of Zero NFT
     *@param tokenURI the URI of Zero's metadata
     */
    function setZeroTokenURI(string memory tokenURI) public onlyOwner {
        require(bytes(tokenURI).length > 0 ,"Zero NFT's URI should not be null");
        zeroTokenURI = tokenURI;
    }

    /**
     *@dev Set the URI of basis NFT
     *@param tokenURI the URI of basis's metadata
     */
    function setBaseTokenURI(string memory tokenURI) public onlyOwner {
        require(bytes(tokenURI).length > 0 ,"Basis NFT's URI should not be null");
        baseTokenURI = tokenURI;
    }

    /**
     *@dev Grant the Role to members
     *@param members the array of members' address
     */
    function addMembers(address[] memory members) public onlyOwner {
        for (uint256 i = 0; i < members.length; ++i) {
            _setupRole(MEMBER_ROLE, members[i]);
        }
    }

    /**
     *@dev Check the Role
     *@param member the address of members
     *@return have the member role
     */
    function checkMembers(address member) public view returns (bool) {
        return hasRole(MEMBER_ROLE, member);
    }

    /**
     *@dev mint an Zero NFT
     */
    function mintZero() public onlyOwner {
        _safeMint(msg.sender, tokenCounter);
        _setTokenURI(tokenCounter, zeroTokenURI);

        tokenCounter++;
    }

    /**
     *@dev mint an basis NFT
     */
    function mint() public onlyRole(MEMBER_ROLE) {
        require(!_minted[msg.sender], "You have minted a NFT");
        _safeMint(msg.sender, tokenCounter);
        _setTokenURI(tokenCounter, baseTokenURI);

        tokenCounter++;
        _minted[msg.sender] = true;
    }

    /**
     *@dev mint more basis NFT by Owner
     */
    function mintMore() public onlyOwner {
        _safeMint(msg.sender, tokenCounter);
        _setTokenURI(tokenCounter, baseTokenURI);

        tokenCounter++;
    }
    /**
     *@dev set the tokenURI
     *@param _tokenId Id of NFT
     *@param _tokenURI URI of NFt
     */
    function _setTokenURI(uint256 _tokenId, string memory _tokenURI)
        internal
        virtual
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI set of nonexistent token"
        ); // Checks if the tokenId exists
        _tokenURIs[_tokenId] = _tokenURI;
    }

    /**
     *@dev check the tokenURI by tokenId
     *@param tokenId Id of NFT
     *@return the tokenURI by tokenId
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI set of nonexistent token"
        );
        return _tokenURIs[tokenId];
    }
}
