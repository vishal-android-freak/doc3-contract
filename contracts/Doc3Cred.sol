// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;
import '@openzeppelin/contracts/access/AccessControl.sol';
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Doc3Cred is ERC721, ERC721URIStorage, AccessControl {
    using Counters for Counters.Counter;

    bytes32 private constant INSTITUTE_ROLE = keccak256("INSTITUTE_ROLE");
    bytes32 private constant USER_ROLE = keccak256("USER_ROLE");
    address private _owner = 0x1Bca22be9853c4599bb63b1B1fF7a2711fF9fbbc;

    struct User {
        string name;
        string email;
    }

    struct Institute {
        string name;
        string email;
        bool isVerified;
    }

    mapping (address => Institute) private _institutes;
    mapping (address => User) private _users;

    Counters.Counter private _tokenIdCounter;

    event InstituteSignUp(address indexed institute, string name, string email);
    event InstituteApproved(address indexed institute);
    event UserSignUp(address indexed user, string name, string email);
    event IssueCredential(address indexed user, address indexed institute, uint256 indexed tokenId);
    event RevokeCredential(address indexed user, address indexed institute, uint256 indexed tokenId);

    constructor() ERC721("Doc3", "DOC3") {
        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
    }

    function signupInstitue(address instituteAddress, string calldata name, string calldata email) external {
        _institutes[instituteAddress] = Institute(name, email, false);
        emit InstituteSignUp(instituteAddress, name, email);
    }

    function approveInstitute(address instituteAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        Institute storage instituteData = _institutes[instituteAddress];
        instituteData.isVerified = true;
        _setupRole(INSTITUTE_ROLE, instituteAddress);
        emit InstituteApproved(instituteAddress);
    }

    function signupUser(address user, string calldata name, string calldata email) external {
        _users[user] = User(name, email);
        _setupRole(USER_ROLE, user);
        emit UserSignUp(user, name, email);
    }

    function burn(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Only owner of the token can burn it");
        _burn(tokenId);
    }

    function revoke(uint256 tokenId) external onlyRole(INSTITUTE_ROLE) {
        _burn(tokenId);
    }

    function safeMint(address to, string memory uri) external onlyRole(INSTITUTE_ROLE) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function _beforeTokenTransfer(address from, address to, uint256) view override internal {
        require(hasRole(INSTITUTE_ROLE, from) || to == address(0), "Not allowed to transfer token");
    }

    function _afterTokenTransfer(address from, address to, uint256 tokenId) override internal {

        if (from == address(0)) {
            emit IssueCredential(to, from, tokenId);
        } else if (to == address(0)) {
            emit RevokeCredential(to, from, tokenId);
        }
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

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControl, ERC721)
        returns (bool)
    {}
}