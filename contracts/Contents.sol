//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";

contract Contents {
    using SafeMath for uint256;

    Content[] public contents; // 메인페이지 전체 조회용
    uint256 private contentsNumber; // 전체 콘텐츠 수

    mapping(address => uint256[]) private contentsOfOwner; // 마이페이지 첫화면 전체 스크롤용
    mapping(uint256 => address) public contentsBelongsTo; // 글의 소유자 확인용

    mapping(address => mapping(string => uint256[])) private contentsOfUser; //카테고리에 해당 되는 게시글들 
    mapping(address => string[]) private tagsOfUser; // 사용자의 해시태그 종류

    mapping(address => User) public userInfo; // 사용자 프로필 정보
    mapping(string => bool) private tagExists;

    enum Page {
        Main,
        Mypage
    }

    struct Content {
        uint256 idx;
        string title;
        string content;
        address writer;
        string date;
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

    // function initialize() external {
    //     contentsNumber = 0;
    // }

    function getContentsOfOwner() public view returns (uint256[] memory) {
        return contentsOfOwner[msg.sender];
    }

    // 사용자 프로필 정보 세팅
    function setUserInfo(string memory _nickName, string memory _profileImgURL)
        public
    {
        userInfo[msg.sender] = User(msg.sender, _nickName, _profileImgURL);
    }

    modifier isContentOwner(uint256 _idx) {
        require(
            contentsBelongsTo[_idx] == msg.sender,
            "msg.sender doesn't have this"
        );
        _;
    }

    function getTagsOfWriter(address _writer)
        public
        view
        returns (Tag[] memory)
    {
        string[] memory tags = tagsOfUser[_writer];
        uint256 tagCounts = tags.length;
        Tag[] memory t = new Tag[](tagCounts);

        for (uint256 i = 0; i < tagCounts; i++) {
            uint256 count = contentsOfUser[_writer][tags[i]].length;
            t[i] = Tag(tags[i], count);
        }
        return t;
    }

    // 게시글 생성
    function create(
        string memory _title,
        string memory _content,
        string memory _date,
        string[] memory _tags
    ) external {
        contents.push(
            Content(contentsNumber, _title, _content, msg.sender, _date)
        );
        contentsOfOwner[msg.sender].push(contentsNumber);

        for (uint256 i = 0; i < _tags.length; i++) {
            contentsOfUser[msg.sender][_tags[i]].push(contentsNumber);
            if (!tagExists[_tags[i]]) {
                tagsOfUser[msg.sender].push(_tags[i]);
                tagExists[_tags[i]] = true;
            }
        }

        contentsBelongsTo[contentsNumber] = msg.sender;
        contentsNumber = contentsNumber.add(1);
    }

    // 게시글 수정(내용만 수정 가능)
    function edit(uint256 _idx, string memory _content)
        public
        isContentOwner(_idx)
    {
        contents[_idx].content = _content;
    }

    function getMycontentPageable(uint256 _current, uint256 _amount)
        public
        view
        returns (Content[] memory)
    {
        uint256 size = _safePagenation(_current, _amount, Page.Mypage);
        Content[] memory content = new Content[](size - _current);
        uint256[] memory myContents = contentsOfOwner[msg.sender];
        uint256 count = 0;
        for (
            uint256 i = _current;
            i < _safePagenation(_current, _amount, Page.Mypage);
            i++
        ) {
            uint256 contentNumber = myContents[i];
            Content memory item = contents[contentNumber];
            content[count] = item;
            count = count.add(1);
        }

        return content;
    }

    //페이지네이션
    function getContentPageable(uint256 _current, uint256 _amount)
        public
        view
        returns (Content[] memory)
    {
        uint256 size = _safePagenation(_current, _amount, Page.Main);
        Content[] memory content = new Content[](size - _current);
        uint256 count = 0;
        for (
            uint256 i = _current;
            i < size;
            i++
        ) {
            content[count] = contents[i];
            count = count.add(1);
        }
        return content;
    }

    // 마지막 페이지 핸들링
    function _safePagenation(
        uint256 _cursor,
        uint256 _val,
        Page loc
    ) private view returns (uint256) {
        uint256 size = (loc == Page.Main)
            ? contentsNumber
            : contentsOfOwner[msg.sender].length;

        if (_cursor + _val >= size) {
            return size;
        }

        return _cursor + _val;
    }
}
