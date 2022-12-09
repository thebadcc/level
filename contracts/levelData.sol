// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

/*

      ██╗ ███████╗██╗   ██╗███████╗██╗                                            
      ██║ ██╔════╝██║   ██║██╔════╝██║                                            
█████╗██║ █████╗  ██║   ██║█████╗  ██║█████╗                                      
╚════╝██║ ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚════╝                                      
      ██║ ███████╗ ╚████╔╝ ███████╗██║                                      
      ╚═╝ ╚══════╝  ╚═══╝  ╚══════╝╚═╝ Data v1                           
                                                                                      
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

contract level is Context, Ownable {
   
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
    constructor(string memory name_) {
        _name = name_;
    }

    function getCanvas(uint tokenId) public view returns (uint[] memory) {
        return (canvases[tokenId].canvas);
    }

     function getLbry(uint tokenId) public view returns (string memory) {
        return (lbrys[tokenId].lbry);
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
  function tokenURI(uint256 tokenId) public view virtual returns (string memory result) {

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
                        '","(animation_URL": "data:text/html;charset=utf-8,',
                        tokenHTML(tokenId),
                        '","image": "data:image/svg+xml;base64,',
                        Base64.encode(
                        abi.encodePacked(tokenSVG(tokenId))
                        ),
                        '"}'
                    )
                )
            )
        );
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
        string memory svgSeed;
        
        svgSeed = terraformsData.tokenSVG(
                    3, 
                    terraforms.tokenToPlacement(tokenMetas[tokenId].terraformId), 
                    10196, 
                    0, 
                    canvases[tokenMetas[tokenId].canvasLbry].canvas
                );
        bytes memory _bytes=bytes(svgSeed);
    
           bytes memory trimmed_bytes = new bytes(_bytes.length-6);
            for (uint i=0; i < _bytes.length-6; i++) {
                trimmed_bytes[i] = _bytes[i];
            }
           return string(
                abi.encodePacked (
               trimmed_bytes,
               _topComp(tokenMetas[tokenId].loop, tokenId),
               _botComp(tokenMetas[tokenId].loop, tokenId),
               "</svg>"
                )
               );
    }

    function dreamSVG(uint tokenId, uint _terraformId) 
        public 
        view 
        virtual
        returns (string memory) 
    {
        string memory svgSeed;
        
        svgSeed = terraformsData.tokenSVG(
                    3, 
                    terraforms.tokenToPlacement(_terraformId), 
                    10196, 
                    0, 
                    canvases[tokenMetas[tokenId].canvasLbry].canvas
                );
        bytes memory _bytes=bytes(svgSeed);
    
           bytes memory trimmed_bytes = new bytes(_bytes.length-6);
            for (uint i=0; i < _bytes.length-6; i++) {
                trimmed_bytes[i] = _bytes[i];
            }
           return string(
                abi.encodePacked (
               trimmed_bytes,
               _topComp(tokenMetas[tokenId].loop, tokenId),
               _botComp(tokenMetas[tokenId].loop, tokenId),
               "</svg>"
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
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return tokenMetas[tokenId].level != 0;
    }

    function create(uint256 tokenId, uint[] memory _topLbry, uint[] memory _botLbry, uint _canvasLbry, uint _loop, uint _terraformId, string memory _title, string memory _description, string memory _collection) public virtual onlyOwner {
        uint placement = terraforms.tokenToPlacement(_terraformId);
        (uint tokenLevel, ) = terraformsData.levelAndTile(placement, 10196);
        uint realLvl = tokenLevel + 1;
        tokenMetas[tokenId] = tokenMeta(_terraformId, realLvl, _topLbry, _botLbry, _canvasLbry, _loop, _title, _description, _collection);
    }

    function addLbry(string memory _script) public virtual onlyOwner{
         lbrys[lbrylength + 1] = lbry(_script); 
         lbrylength += 1;
    }
    
    function addCanvas(uint[] memory _canvas) public virtual onlyOwner{
        canvases[canvasLength + 1] = canvas(_canvas);
        canvasLength += 1;
    }

    function updateToken(uint256 tokenId, uint[] memory _topUp, uint[] memory _botUp, uint _canvasUp) public virtual onlyOwner {
        tokenMetas[tokenId].topLbry =  _topUp;
        tokenMetas[tokenId].botLbry =  _botUp;
        tokenMetas[tokenId].canvasLbry =  _canvasUp;
    }

}
