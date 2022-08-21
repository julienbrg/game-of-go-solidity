// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.8;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";

contract Go is ReentrancyGuard {

    uint public goban = 19 * 19;
    uint public width = 19;
    address public white;
    address public black;
    address public turn;
    uint public capturedWhiteStones;
    uint public capturedBlackStones;
    bool public blackPassedOnce;
    bool public whitePassedOnce;
    int public blackScore;
    int public whiteScore;

    struct Intersection {
        uint x;
        uint y;
        State state;
    }

    Intersection[361] public intersections;

    enum State {
        Black,
        White,
        Empty
    }
    State public state;

    event Start(string indexed statement);
    event Move(string indexed player, uint indexed x, uint indexed y);
    event End(string indexed statement, int indexed blackScore, int indexed whiteScore);

    constructor (
        address _white, 
        address _black
    )

    {
        white = _white;
        black = _black;

        // Black plays first
        turn = black;
        
        // Goban init
        uint i;
        intersections[0] = Intersection({x: 0, y: 0, state: State.Empty});
        for( uint j ; j < width ; j++ ) {
            for( uint k ; k < width ; k++ ) {
                intersections[i++] = Intersection({x: j, y: k, state: State.Empty});
            }
        }
        require(i==goban, "ERROR_DURING_GOBAN_INIT");
        emit Start("The game has started.");
    }

    function play(uint _x, uint _y) public nonReentrant() {
        require(msg.sender == white || msg.sender == black, "CALLER_IS_NOT_ALLOWED_TO_PLAY" ); // maybe better with a onlyPlayer modifier instead
        require(isOffBoard(_x, _y) == false, "OFF_BOARD");
        uint move = getIntersectionId(_x, _y);
        require(intersections[move].state == State.Empty, "CANNOT_PLAY_HERE");

        if (msg.sender == white) {
            require(turn == white, "NOT_YOUR_TURN");
            intersections[move].state = State.White;
            turn = black;
            emit Move("White", _x, _y);
        }

        if (msg.sender == black) {
            require(turn == black, "NOT_YOUR_TURN");
            intersections[move].state = State.Black;
            turn = white;
            emit Move("Black", _x, _y);
        }
    }

    function pass() public nonReentrant() {
        require(msg.sender == white || msg.sender == black, "CALLER_IS_NOT_ALLOWED_TO_PLAY" );
        if (msg.sender == white) {
            turn = black;
            emit Move("White", 42, 42); // off board
        }

        if (msg.sender == black) {
            if (blackPassedOnce == true) {
                end();
            }
            blackPassedOnce = true;
            turn = white;
            emit Move("Black", 42, 42); // off board
        }
    }

    function capture(uint _stone) private {}

    function end() private {
        require(blackPassedOnce == true || whitePassedOnce == true, "MISSING_TWO_CONSECUTIVE_PASS"); // not sure if relevant or enough safe
        blackScore = 1; // count the points instead
        whiteScore = 0;
        if (blackScore > whiteScore) {
            emit End("Black wins", blackScore, whiteScore);
        } else {
            emit End("White wins", blackScore, whiteScore);
        }
    }

    function isOffBoard(uint _a, uint _b) public view returns (bool offBoard) {
        if (getIntersectionId(_a, _b) >= goban - 1) {
            return true;
        }
    }

    function getIntersectionId(uint _a, uint _b) public view returns (uint target) {
        for (target; target < goban ; target++) {
            if (intersections[target].x == _a && intersections[target].y == _b) {
                return target;
            }
        }
    }

    function getIntersection(uint _target) public view returns (uint _x, uint _y) {
        return (intersections[_target].x, intersections[_target].y);
    }

    function getNeighbors(uint _target) public view returns (uint east, uint west, uint north, uint south) {
        east = _target - 1;
        west = _target + 1;
        north = _target + width;
        south = _target - width;   
        return (east, west, north, south);
    }

    // lists all connected stones
    function getGroup(uint _target) public view returns (uint[] memory) {

        uint[] memory group = new uint[](10); // will be longer than 10

        uint nextTarget;

        uint east; 
        uint west;
        uint north;
        uint south;

        uint id = 0 ;

        group[id] = _target;

        (east, west, north, south) = getNeighbors(_target);

        if (intersections[_target].state == intersections[east].state) {
            id = id + 1;
            console.log("      id  east =", id);
            group[id] = east;
            nextTarget = east;
        }
        if (intersections[_target].state == intersections[west].state) {
            id = id + 1;
            console.log("      id west =", id);
            group[id] = west;
            nextTarget = west;
        }
        if (intersections[_target].state == intersections[north].state) {
            id = id + 1;
            console.log("      id north =", id);
            group[id] = north;
            nextTarget = north;
        }
        if (intersections[_target].state == intersections[south].state) {
            id = id + 1;
            console.log("      id south =", id);
            group[id] = south;
            nextTarget = south;
        }

        return group;
    }
}