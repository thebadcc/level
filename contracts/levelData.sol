// SPDX-License-Identifier: MIT

/*

      ██╗ ███████╗██╗   ██╗███████╗██╗                                            
      ██║ ██╔════╝██║   ██║██╔════╝██║                                            
█████╗██║ █████╗  ██║   ██║█████╗  ██║█████╗                                      
╚════╝██║ ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚════╝                                      
      ██║ ███████╗ ╚████╔╝ ███████╗██║                                      
      ╚═╝ ╚══════╝  ╚═══╝  ╚══════╝╚═╝ DATA v:alpha                         

by: thebadcc                                      

A permissioned Terraforms derivative framework.

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


interface Iterraforms {
  
    function tokenToPlacement(uint) 
        external 
        view 
        returns (uint);

    function tokenToStatus(uint) 
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

    struct tokenParam{
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
    mapping(uint => tokenParam) public tokenParams;

    uint public lbrylength = 0;
    uint public canvasLength = 0;

    // Animation url for internal and external asset
    string public animationURL;

    // Trigger for onchain HTML or offchain asset storage
    bool public externalAnimation = false;

    // Token name
    string private _name;

    //Terraforms.sol interface
    Iterraforms terraforms = Iterraforms(0x4E1f41613c9084FdB9E34E11fAE9412427480e56);

    //TerraformsData.sol interface
    IterraformsData terraformsData = IterraformsData(0xA5aFC9fE76a28fB12C60954Ed6e2e5f8ceF64Ff2);

    constructor(string memory name_) {
        _name = name_;
    }

    function getCanvas(uint tokenId) public view returns (uint[] memory) {
        return (canvases[tokenId].canvas);
    }

     function getLbry(uint tokenId) public view returns (string memory) {
        return (lbrys[tokenId].lbry);
    }

    
    function tokenURI(uint256 tokenId) public view virtual returns (string memory result) {
    string memory animation;
    if (externalAnimation == true) {
        animation = string(abi.encodePacked(
            animationURL,
            Strings.toString(tokenId)
        ));
    } else {
        animation = string(abi.encodePacked(
            animationURL,
            tokenHTML(tokenId)
        ));
    }
    result = string(  
            abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(
                    abi.encodePacked(
                        '{"name":"',
                        tokenParams[tokenId].title,
                        '","description":"',
                        tokenParams[tokenId].description,
                        '","artist":"',
                        tokenParams[tokenId].artist,
                        '","terraform":"',
                        Strings.toString(tokenParams[tokenId].terraformId),
                        '","animation_URL":"',
                        animation,
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

    function tokenSVG(uint tokenId) 
        public 
        view 
        virtual
        returns (string memory) 
    {
        string memory svgSeed;
        
        svgSeed = terraformsData.tokenSVG(
                    terraforms.tokenToStatus(tokenParams[tokenId].terraformId), 
                    terraforms.tokenToPlacement(tokenParams[tokenId].terraformId), 
                    10196, 
                    0, 
                    canvases[tokenParams[tokenId].canvasLbry].canvas
                );
        bytes memory _bytes=bytes(svgSeed);
    
           bytes memory trimmed_bytes = new bytes(_bytes.length-6);
            for (uint i=0; i < _bytes.length-6; i++) {
                trimmed_bytes[i] = _bytes[i];
            }
           return string(
                abi.encodePacked (
               trimmed_bytes,
               _topComp(tokenParams[tokenId].loop, tokenId),
               _botComp(tokenParams[tokenId].loop, tokenId),
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
                    terraforms.tokenToStatus(tokenParams[tokenId].terraformId),  
                    terraforms.tokenToPlacement(_terraformId), 
                    10196, 
                    0, 
                    canvases[tokenParams[tokenId].canvasLbry].canvas
                );
        bytes memory _bytes=bytes(svgSeed);
    
           bytes memory trimmed_bytes = new bytes(_bytes.length-6);
            for (uint i=0; i < _bytes.length-6; i++) {
                trimmed_bytes[i] = _bytes[i];
            }
           return string(
                abi.encodePacked (
               trimmed_bytes,
               _topComp(tokenParams[tokenId].loop, tokenId),
               _botComp(tokenParams[tokenId].loop, tokenId),
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
        tokenParams[tokenId].level == tokenLevel + 1, 
        "ERC721: invalid token level"
        );
        require(
            _exists(tokenId), "ERC721: invalid token ID"
        );
        tokenParams[tokenId].terraformId = _terraformId;
    }

    function create(uint256 tokenId, uint[] memory _topLbry, uint[] memory _botLbry, uint _canvasLbry, uint _loop, uint _terraformId, string memory _title, string memory _description, string memory _artist) public virtual onlyOwner {
        uint placement = terraforms.tokenToPlacement(_terraformId);
        (uint tokenLevel, ) = terraformsData.levelAndTile(placement, 10196);
        uint realLvl = tokenLevel + 1;
        tokenParams[tokenId] = tokenParam(_terraformId, realLvl, _topLbry, _botLbry, _canvasLbry, _loop, _title, _description, _artist);
    }

    function addLbry(string memory _script) public virtual onlyOwner{
         lbrys[lbrylength + 1] = lbry(_script); 
         lbrylength += 1;
    }
    
    function addCanvas(uint[] memory _canvas) public virtual onlyOwner{
        canvases[canvasLength + 1] = canvas(_canvas);
        canvasLength += 1;
    }

    function updateToken(uint256 tokenId, uint[] memory _topUp, uint[] memory _botUp, uint _canvasUp, uint _loop) public virtual onlyOwner {
        tokenParams[tokenId].topLbry =  _topUp;
        tokenParams[tokenId].botLbry =  _botUp;
        tokenParams[tokenId].canvasLbry =  _canvasUp;
        tokenParams[tokenId].loop =  _loop;
    }

    function updateExternal(string memory _animationURL, bool _externalAnimation) public virtual onlyOwner {
        animationURL = _animationURL;
        externalAnimation == _externalAnimation;
        }

    function _topComp(uint loop, uint tokenId)
        private 
        view 
        returns (string memory)  {
        string memory result;    
        for (uint i = 0; i < loop; i++) {
            result = string(abi.encodePacked(result, lbrys[tokenParams[tokenId].topLbry[i]].lbry));
        }
        return string ( 
                result
        );
    }

    function _botComp(uint loop, uint tokenId)
        private 
        view 
        returns (string memory)  {
        string memory result;    
        for (uint i = 0; i < loop; i++) {
            result = string(abi.encodePacked(result, lbrys[tokenParams[tokenId].botLbry[i]].lbry));
        }
        return string ( 
                result
        );
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return tokenParams[tokenId].level != 0;
    }
}
