// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

/*

      ██╗ ███████╗██╗   ██╗███████╗██╗                                            
      ██║ ██╔════╝██║   ██║██╔════╝██║                                            
█████╗██║ █████╗  ██║   ██║█████╗  ██║█████╗                                      
╚════╝██║ ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚════╝                                      
      ██║ ███████╗ ╚████╔╝ ███████╗██║                                      
      ╚═╝ ╚══════╝  ╚═══╝  ╚══════╝╚═╝ v1                           
                                                                                      
██████╗ ██╗   ██╗    ████████╗██╗  ██╗███████╗██████╗  █████╗ ██████╗  ██████╗ ██████╗
██╔══██╗╚██╗ ██╔╝    ╚══██╔══╝██║  ██║██╔════╝██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔════╝
██████╔╝ ╚████╔╝        ██║   ███████║█████╗  ██████╔╝███████║██║  ██║██║     ██║     
██╔══██╗  ╚██╔╝         ██║   ██╔══██║██╔══╝  ██╔══██╗██╔══██║██║  ██║██║     ██║     
██████╔╝   ██║          ██║   ██║  ██║███████╗██████╔╝██║  ██║██████╔╝╚██████╗╚██████╗
╚═════╝    ╚═╝          ╚═╝   ╚═╝  ╚═╝╚══════╝╚═════╝ ╚═╝  ╚═╝╚═════╝  ╚═════╝ ╚═════╝

An interactive art collection built on-chain with Terraforms by @mathcastles

--DISCLAIMER--
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT
OF COPYRIGHT, PATENT, TRADEMARK, OR OTHER RIGHT. IN NO EVENT SHALL THE
AUTHOR(S) BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
INCLUDING ANY GENERAL, SPECIAL, INDIRECT, INCIDENTAL, OR CONSEQUENTIAL
DAMAGES, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF THE USE OR INABILITY TO USE THE SOFTWARE OR FROM
OTHER DEALINGS IN THE SOFTWARE.

Copyright 2022. All rights reserved.

*/

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721Receiver.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/introspection/ERC165.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Base64.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";


/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
interface Iterraforms {
  
    function tokenToPlacement(uint) 
        external 
        view 
        returns (uint);

    function ownerOf(uint) 
        external 
        view 
        returns (address);  
}

interface IterraformsData {

    function tokenSVG(uint, uint, uint, uint, uint[] memory) 
        external 
        view 
        returns (string memory);

    function levelAndTile(uint, uint) 
        external
        view
        returns (uint, uint);
}

contract level is Context, ERC165, IERC721, IERC721Metadata, Ownable {
   
    using Address for address;
    using Strings for uint256;

    // Token Libraries
    struct lbry {
        string lbry;
    }

    struct canvas {
        uint256[] canvas;
    }

    struct tokenMeta{
        uint terraformId;
        uint level;
        uint[] topLbry;
        uint[] botLbry;
        uint coverLbry;
        uint canvasLbry;
        uint loop;
        string title;
        string description;
        string artist;
    }

    mapping(uint => lbry) private lbrys;
    mapping(uint => canvas) canvases;
    mapping(uint => tokenMeta) public tokenMetas;

    uint public lbrylength = 0;
    uint public canvasLength = 0;

    // Animation url for internal and external asset
    string public animationURL;

    // Trigger for onchain HTML or offchain asset storage
    bool public externalAnimation;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    //Terraforms.sol interface
    Iterraforms terraforms = Iterraforms(0x4E1f41613c9084FdB9E34E11fAE9412427480e56);

    //TerraformsData.sol interface
    IterraformsData terraformsData = IterraformsData(0xA5aFC9fE76a28fB12C60954Ed6e2e5f8ceF64Ff2);

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function getCanvas(uint tokenId) public view returns (uint[] memory) {
        return (canvases[tokenId].canvas);
    }

     function getLbry(uint tokenId) public view returns (string memory) {
        return (lbrys[tokenId].lbry);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
  function tokenURI(uint256 tokenId) public view virtual override returns (string memory result) {
    string memory animationURI;
    if (externalAnimation == true){
            animationURI = string(
                abi.encodePacked(
                    animationURL,
                    tokenId,
                    ".html"
                )
            );
        } else { 
            animationURI = string(
                abi.encodePacked(
                    animationURL,
                    tokenHTML(tokenId)
                )
            );
        }

    result = string(  
            abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(
                    abi.encodePacked(
                        '{"name":"',
                        tokenMetas[tokenId].title,
                        '","description":"',
                        tokenMetas[tokenId].description,
                        '","artist":"',
                        tokenMetas[tokenId].artist,
                        '","terraform":"',
                        Strings.toString(tokenMetas[tokenId].terraformId),
                        abi.encodePacked(
                        '","animation_URL":"',
                        animationURI
                        ),
                        '","image": "data:image/svg+xml;base64,',
                        Base64.encode(
                        abi.encodePacked(coverSVG(tokenId))
                    ),
                        '"}'
                    )
                )
            )
        );
    }

    function updatetokenURI (string memory call, bool direction) public virtual  {
        animationURL = call;
        externalAnimation == direction;
    }

    function tokenHTML(uint256 tokenId) public view virtual returns (string memory) {
        return string(
            abi.encodePacked(
                "<html><head><meta charset='UTF-8'><style>html,body,svg{margin:0;padding:0; height:100%;text-align:center;}</style></head><body>", 
                tokenSVG(tokenId), 
                "</body></html>"
            )
        );
    }

    function _topComp(uint loop, uint tokenId)
        public 
        view 
        virtual
        returns (string memory)  {
        string memory result;    
        for (uint i = 0; i < loop; i++) {
            result = string(abi.encodePacked(result, lbrys[tokenMetas[tokenId].topLbry[i]].lbry));
        }
        return string ( 
                result
        );
    }

    function _botComp(uint loop, uint tokenId)
        public 
        view 
        virtual
        returns (string memory)  {
        string memory result;    
        for (uint i = 0; i < loop; i++) {
            result = string(abi.encodePacked(result, lbrys[tokenMetas[tokenId].botLbry[i]].lbry));
        }
        return string ( 
                result
        );
    }

    function tokenSVG(uint tokenId) 
        public 
        view 
        virtual
        returns (string memory) 
    {
       return string (
                abi.encodePacked (
                    _topComp(tokenMetas[tokenId].loop, tokenId),
                    terraformsData.tokenSVG(
                    3, 
                    terraforms.tokenToPlacement(tokenMetas[tokenId].terraformId), 
                    10196, 
                    0, 
                    canvases[tokenMetas[tokenId].canvasLbry].canvas
                    ),
                    _botComp(tokenMetas[tokenId].loop, tokenId)
                )
            );
    }

    function coverSVG(uint tokenId) 
        public 
        view 
        virtual
        returns (string memory) 
    {
       return string (
                abi.encodePacked (
                    terraformsData.tokenSVG(
                    3, 
                    terraforms.tokenToPlacement(tokenMetas[tokenId].terraformId), 
                    10196, 
                    0, 
                    canvases[tokenMetas[tokenId].coverLbry].canvas
                    )
                )
            );
    }

        function dreamSVG(uint _terraformId, uint tokenId) 
        public 
        view 
        virtual
        returns (string memory) 
    {
       return string (
                abi.encodePacked (
                    _topComp(tokenMetas[tokenId].loop, tokenId),
                    terraformsData.tokenSVG(
                    3, 
                    terraforms.tokenToPlacement( _terraformId), 
                    10196, 
                    0, 
                    canvases[tokenMetas[tokenId].canvasLbry].canvas
                    ),
                    _botComp(tokenMetas[tokenId].loop, tokenId)
                )
            );
    }
  
    function editToken(uint tokenId, uint _terraformId) public virtual {
        uint placement = terraforms.tokenToPlacement(_terraformId);
        (uint tokenLevel, ) = terraformsData.levelAndTile(placement, 10196);
        /*
        require (
            msg.sender == terraforms.ownerOf(_terraformId),
            "ERC721: caller is not terraform owner"
        );
        */
        require (
        tokenMetas[tokenId].level == tokenLevel + 1, 
        "ERC721: invalid token level"
        );
        require(
            _exists(tokenId), "ERC721: invalid token ID"
        );
        tokenMetas[tokenId].terraformId = _terraformId;
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = level.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner or approved for all"
        );
        _approve(to, tokenId);
    }

    function mint(address to, uint256 tokenId, uint[] memory _topLbry, uint[] memory _botLbry, uint _canvasLbry, uint _coverLbry, uint _loop, uint _terraformId, string memory _title, string memory _description, string memory _collection) public virtual onlyOwner {
        uint placement = terraforms.tokenToPlacement(_terraformId);
        (uint tokenLevel, ) = terraformsData.levelAndTile(placement, 10196);
        uint realLvl = tokenLevel + 1;
        tokenMetas[tokenId] = tokenMeta(_terraformId, realLvl, _topLbry, _botLbry, _coverLbry, _canvasLbry, _loop, _title, _description, _collection);
        _mint(to, tokenId);
    }

    function addLbry(string memory _script) public virtual onlyOwner{
         lbrys[lbrylength + 1] = lbry(_script); 
         lbrylength += 1;
    }
    
    function addCanvas(uint[] memory _canvas) public virtual onlyOwner{
        canvases[canvasLength + 1] = canvas(_canvas);
        canvasLength += 1;
    }

    function updateToken(uint256 tokenId, uint[] memory _topUp, uint[] memory _botUp, uint _canvasUp, uint _coverUp) public virtual onlyOwner {
        tokenMetas[tokenId].topLbry =  _topUp;
        tokenMetas[tokenId].botLbry =  _botUp;
        tokenMetas[tokenId].canvasLbry =  _canvasUp;
        tokenMetas[tokenId].coverLbry =  _coverUp;
    }


    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     */
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = level.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        // Check that tokenId was not minted by `_beforeTokenTransfer` hook
        require(!_exists(tokenId), "ERC721: token already minted");

        unchecked {
            // Will not overflow unless all 2**256 token ids are minted to the same owner.
            // Given that tokens are minted one by one, it is impossible in practice that
            // this ever happens. Might change if we allow batch minting.
            // The ERC fails to describe this case.
            _balances[to] += 1;
        }

        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = level.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Update ownership in case tokenId was transferred by `_beforeTokenTransfer` hook
        owner = level.ownerOf(tokenId);

        // Clear approvals
        delete _tokenApprovals[tokenId];

        unchecked {
            // Cannot overflow, as that would require more tokens to be burned/transferred
            // out than the owner initially received through minting and transferring in.
            _balances[owner] -= 1;
        }
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(level.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Check that tokenId was not transferred by `_beforeTokenTransfer` hook
        require(level.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");

        // Clear approvals from the previous owner
        delete _tokenApprovals[tokenId];

        unchecked {
            // `_balances[from]` cannot overflow for the same reason as described in `_burn`:
            // `from`'s balance is the number of token held, which is at least one before the current
            // transfer.
            // `_balances[to]` could overflow in the conditions described in `_mint`. That would require
            // all 2**256 token ids to be minted, which in practice is impossible.
            _balances[from] -= 1;
            _balances[to] += 1;
        }
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(level.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any (single) token transfer. This includes minting and burning.
     * See {_beforeConsecutiveTokenTransfer}.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any (single) transfer of tokens. This includes minting and burning.
     * See {_afterConsecutiveTokenTransfer}.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called before "consecutive token transfers" as defined in ERC2309 and implemented in
     * {ERC721Consecutive}.
     * Calling conditions are similar to {_beforeTokenTransfer}.
     */
    function _beforeConsecutiveTokenTransfer(
        address from,
        address to,
        uint256, /*first*/
        uint96 size
    ) internal virtual {
        if (from != address(0)) {
            _balances[from] -= size;
        }
        if (to != address(0)) {
            _balances[to] += size;
        }
    }

    /**
     * @dev Hook that is called after "consecutive token transfers" as defined in ERC2309 and implemented in
     * {ERC721Consecutive}.
     * Calling conditions are similar to {_afterTokenTransfer}.
     */
    function _afterConsecutiveTokenTransfer(
        address, /*from*/
        address, /*to*/
        uint256, /*first*/
        uint96 /*size*/
    ) internal virtual {}
}