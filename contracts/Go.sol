// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Go is ReentrancyGuard {

    uint256 public goban = 19 * 19;
    uint256 public width = 19;
    address public white;
    address public black;
    address public turn;
    uint256 public capturedWhiteStones;
    uint256 public capturedBlackStones;
    bool public blackPassedOnce;
    bool public whitePassedOnce;
    int256 public blackScore;
    int256 public whiteScore;

    struct Intersection {
        uint256 x;
        uint256 y;
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
    event Move(string indexed player, uint256 indexed x, uint256 indexed y);
    event End(string indexed statement, int256 indexed blackScore, int256 indexed whiteScore);

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
        uint256 i;
        intersections[0] = Intersection({x: 0, y: 0, state: State.Empty});
        for( uint256 j ; j < width ; j++ ) {
            for( uint256 k ; k < width ; k++ ) {
                intersections[i++] = Intersection({x: j, y: k, state: State.Empty});
            }
        }
        require(i==goban, "ERROR_DURING_GOBAN_INIT");
        emit Start("The game has started.");
    }

    function play(uint256 _x, uint256 _y) public nonReentrant() {
        require(msg.sender == white || msg.sender == black, "CALLER_IS_NOT_ALLOWED_TO_PLAY" ); // maybe better with a onlyPlayer modifier instead
        require(isOffBoard(_x, _y) == false, "OFF_BOARD");
        uint256 move = getIntersectionId(_x, _y);
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
        }

        if (msg.sender == black) {

            if (blackPassedOnce == true) {
                end();
            }
            
            blackPassedOnce = true;
            turn = white;
        }
    }

    function capture(uint256 _stone) private {

    }

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

    function isOffBoard(uint256 _a, uint256 _b) public view returns (bool offBoard) {
        if (getIntersectionId(_a, _b) >= goban - 1) {
            return true;
        }
    }

    function getIntersectionId(uint256 _a, uint256 _b) public view returns (uint256 target) {
        for (target; target < goban ; target++) {
            if (intersections[target].x == _a && intersections[target].y == _b) {
                return target;
            }
        }
    }

    function getIntersection(uint256 _target) public view returns (uint256 _x, uint256 _y) {
        return (intersections[_target].x, intersections[_target].y);
    }

    function getNeighbors(uint256 _target) public view returns (uint256 east, uint256 west, uint256 north, uint256 south) {
        east = _target - 1;
        west = _target + 1;
        north = _target + width;
        south = _target - width;   
        return (east, west, north, south);
    }
}