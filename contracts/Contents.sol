//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "hardhat/console.sol";

contract Contents is OwnableUpgradeable {
    using SafeMath for uint256;

    Content[] public contents; // 메인페이지 전체 조회용
    uint256 public totalContentNumber; // 전체 콘텐츠 수

    mapping(address => uint256[]) private contentOwner; // 마이페이지 첫화면 전체 스크롤용
    mapping(uint256 => address) public contentWriter; // 글의 소유자 확인용

    mapping(address => mapping(string => uint256[])) private userSTagContent; //카테고리에 해당 되는 게시글들
    mapping(address => string[]) private userSTag; // 사용자의 카테고리 종류

    mapping(address => User) public userInformation; // 사용자 프로필 정보
    string[] private nickNames;
    mapping(string => bool) private tagExists;

    enum Page {
        Main,
        Mypage
    }

    struct Content {
        uint256 idx;
        string title;
        string thumbnail;
        string content;
        User writer;
        string[] tags;
        string date;
        bool blocked;
    }

    struct User {
        address adr;
        string nickName;
        string profileImgURL;
    }

    struct Tag {
        string tagName;
        uint256 count;
    }

    function initialize() public initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    modifier isContentOwner(uint256 _idx) {
        require(
            contentWriter[_idx] == msg.sender,
            "msg.sender doesn't have this"
        );
        _;
    }

    //nickName check
    function checkNicknameDuplicate(string memory _nickName)
        public
        view
        returns (bool)
    {
        uint256 len = nickNames.length;
        for (uint256 i = 0; i < len; i++) {
            if (
                keccak256(abi.encodePacked(nickNames[i])) ==
                keccak256(abi.encodePacked(_nickName))
            ) {
                return true;
            }
        }
        return false;
    }

    // 게시글 생성
    function create(
        string memory _title,
        string memory _thumbnail,
        string memory _content,
        string memory _date,
        string[] memory _tags
    ) external {
        User memory writer = userInformation[msg.sender];

        contents.push(
            Content(
                totalContentNumber,
                _title,
                _thumbnail,
                _content,
                writer,
                _tags,
                _date,
                false
            )
        );
        contentOwner[msg.sender].push(totalContentNumber);

        for (uint256 i = 0; i < _tags.length; i++) {
            userSTagContent[msg.sender][_tags[i]].push(totalContentNumber);
            if (!tagExists[_tags[i]]) {
                userSTag[msg.sender].push(_tags[i]);
                tagExists[_tags[i]] = true;
            }
        }

        contentWriter[totalContentNumber] = msg.sender;
        totalContentNumber = totalContentNumber.add(1);
    }

    // 게시글 수정(내용만 수정 가능)
    function edit(uint256 _idx, string memory _content)
        public
        isContentOwner(_idx)
    {
        contents[_idx].content = _content;
    }

    function setBlock(uint256 _postId) public onlyOwner {
        contents[_postId].blocked = true;
        contents[_postId].title = "";
        contents[_postId].content = "";
        contents[_postId].thumbnail = "";
    }

    function getContent(uint256 _postId) public view returns(Content memory) {
        return contents[_postId];
    }

    function getContentOwner(address _adr) public view returns(uint256[] memory) {
        return contentOwner[_adr];
    }
  
    function getUserSTag(address _writer)
        public
        view
        returns (Tag[] memory)
    {
        string[] memory tags = userSTag[_writer];
        uint256 tagCounts = tags.length;
        Tag[] memory t = new Tag[](tagCounts);

        for (uint256 i = 0; i < tagCounts; i++) {
            uint256 count = userSTagContent[_writer][tags[i]].length;
            t[i] = Tag(tags[i], count);
        }
        return t;
    }

    // 사용자 프로필 정보 세팅
    function setUserInformation(string memory _nickName, string memory _profileImgURL)
        public
    {
        userInformation[msg.sender] = User(msg.sender, _nickName, _profileImgURL);
        nickNames.push(_nickName);
    }

    //메인 페이지 페이지네이션
    function getContentPagination(uint256 _current, uint256 _amount)
        public
        view
        returns (Content[] memory)
    {
        uint256 end = _safePagination(_current, _amount);
        // console.log(_current, _amount, end);

        Content[] memory content = new Content[](_current - end);
        uint256 count = 0;
   
        for (uint256 i = _current - 1; i >= end; i--) {
            content[count] = contents[i];
            count = count.add(1);
            if(i == 0){
                break;
            }
        }

        return content;
    }

    function getUserContentPagination(
        uint256 _current,
        uint256 _amount,
        address _user
    ) public view returns (Content[] memory) {
        uint256 end = _safePagination(_current, _amount);
        
        Content[] memory content = new Content[](_current - end);
        uint256[] memory myContents = contentOwner[_user];
        uint256 count = 0;
        for (uint256 i = _current - 1; i >= end; i--) {
            uint256 contentNumber = myContents[i];
            Content memory item = contents[contentNumber];
            content[count] = item;
            count = count.add(1);
            if(i == 0) {
                break;
            }
        }

        return content;
    }

    function getTagContentPagination (address _user, string memory _tag, uint256 _current, uint256 _amount) public view returns (Content[] memory) {
        uint256 end = _safePagination(_current, _amount);
        Content[] memory content = new Content[](_current - end);
        uint256[] memory tagContentsNumber = userSTagContent[_user][_tag];
        uint256 count = 0;
        for(uint256 i = _current - 1; i >= end; i--) {
            uint256 tagContent = tagContentsNumber[i];
            Content memory c = contents[tagContent];
            content[count] = c;
            count = count.add(1);
            if (i == 0){
                break;
            }
        }
        
        return content;
    }

    // 마지막 페이지 핸들링
    function _safePagination(uint256 _cursor, uint256 _val)
        private
        pure
        returns (uint256)
    {
        if (_cursor < _val) {
            return 0;
        }

        return _cursor - _val;
    }
}
