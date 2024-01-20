import serial


# this to check the ports name !
import serial.tools.list_ports
myports = [tuple(p) for p in list(serial.tools.list_ports.comports())]
print(myports)

import pygame as p
import ChessEngineAd as ChessEngine
import ChessBot
import config

p.init()

BOARD_WIDTH = BOARD_HEIGHT = config.BOARD_WIDTH
DIMENTION = config.DIMENTION  # 8*8 CHESS BOARD
SQ_SIZE = BOARD_HEIGHT // DIMENTION
MAX_FPS = config.MAX_FPS
IMAGES = {}


def main():
    valid = True
    s = serial.Serial('COM5', 9600)
    gs = ChessEngine.GameState()
    validMoves = gs.getValidMoves()
    # loadImages()
    running = True

    playerOne = config.PLAYER_ONE_HUMAN
    playerTwo = config.PLAYER_TWO_HUMAN
    gameOver = False

    print('Enter (S) to start the game: ')
    num_bytes = 1
    data = s.read(num_bytes)
    start = data.decode('utf-8')
    while start != 'S':
        print('Enter (S) to start the game: ')
        num_bytes = 1
        data = s.read(num_bytes)
        start = data.decode('utf-8')

    print("Enter the difficulty level (1-3, with 1 being easiest and 3 hardest): ")
    data = s.read(1)
    depth = data.decode('utf-8')
    while depth < str(0) or depth > str(3):
        print("Enter the difficulty level (1-3, with 1 being easiest and 3 hardest): ")
        data = s.read(1)
        depth = data.decode('utf-8')
    print(depth)
    ChessBot.DEPTH = int(depth)
    counter = 0
    while running:
        humanTurn = (gs.whiteToMove and playerOne) or (not gs.whiteToMove and playerTwo)
        if not gameOver and humanTurn:
            if counter != 0 and valid is True:
                print(data)
                print("Waiting to complete the move: ")
                data = s.read(1)
                done = data.decode('utf-8')
                print(done)
                while done != 'D':
                    print("Waiting to complete the move: ")
                    data = s.read(1)
                    done = data.decode('utf-8')
                    print(done)
            counter = 1
            move_input = input("Enter move (e.g., e2e4): ")
            start_square = move_input[:2]
            end_square = move_input[2:4]

            try:
                start_row, start_col = 8 - int(start_square[1]), ord(start_square[0]) - ord('a')
                end_row, end_col = 8 - int(end_square[1]), ord(end_square[0]) - ord('a')
                if gs.enPassantPossible == (end_row, end_col):
                    en_passant_move = True
                else:
                    en_passant_move = False

                    # Create a Move object with enPassant attribute set accordingly
                if en_passant_move:
                    move = ChessEngine.Move((start_row, start_col), (end_row, end_col), gs.board,
                                            enPassant=en_passant_move)
                else:
                    move = ChessEngine.Move((start_row, start_col), (end_row, end_col), gs.board)

                if move_input in ["e1g1", "e1c1", "e8g8", "e8c8"]:  # Recognize castling notation
                    move.isCastleMove = True
                    # Check if the move is en passant

                num_pieces_before = gs.getNumPieces()

                if move in validMoves:
                    gs.makeMove(move)
                    validMoves = gs.getValidMoves()
                    num_pieces_after = gs.getNumPieces()
                    valid = True
                    if num_pieces_after < num_pieces_before:
                        killed = ('L' + str(ord(start_square[0]) - 96) + str(start_square[1]) + 'x' + str(ord(end_square[0]) - 96) +str(end_square[1]))
                        print('move = ', killed)
                        s.write(killed.encode('utf-8'))
                    else:
                        not_killed = ('L' + str(ord(start_square[0]) - 96) + str(start_square[1]) + 't' + str(ord(end_square[0]) - 96) +str(end_square[1]))
                        print('move = ', not_killed)
                        s.write(not_killed.encode('utf-8'))
                else:
                    valid = False
                    print("Invalid move! Try again.")
            except (ValueError, IndexError):
                print("Invalid input! Try again.")
                valid = False

        elif not gameOver:
            print("Waiting to complete the move: ")
            data = s.read(1)
            print(data)
            done = data.decode('utf-8')
            print(done)
            while done != 'D':
                print("Waiting to complete the move: ")
                data = s.read(1)
                done = data.decode('utf-8')
                print(done)
            num_pieces_before = gs.getNumPieces()
            AIMove = ChessBot.findBestMoveMinMax(gs, validMoves)
            if AIMove is None:
                AIMove = ChessBot.findRandomMove(validMoves)
            gs.makeMove(AIMove)
            validMoves = gs.getValidMoves()
            num_pieces_after = gs.getNumPieces()
            # print(f"Bot moved: {AIMove.getChessNotation()}")
            chessMove = AIMove.getChessNotation()
            if num_pieces_after < num_pieces_before:
                killed = ('E' + str(ord(chessMove[0]) - 96) + str(chessMove[1]) + 'x' + str(ord(chessMove[2]) - 96) + str(chessMove[3]))
                print('bot move = ', killed)
                s.write(killed.encode('utf-8'))
            else:
                not_killed = ('E' + str(ord(chessMove[0]) - 96) + str(chessMove[1]) + 't' + str(ord(chessMove[2]) - 96) + str(chessMove[3]))
                print('bot move = ', not_killed)
                s.write(not_killed.encode('utf-8'))

        drawGameState(gs)

        # Print Checkmate
        if gs.checkMate:
            gameOver = True
            if gs.whiteToMove:
                print("Black Won by Checkmate!")
                s.write('M'.encode('utf-8'))
            else:
                print("White Won by Checkmate!")
                s.write('M'.encode('utf-8'))

        # Print Stalemate
        if gs.staleMate:
            gameOver = True
            print("Draw due to Stalemate!")

    print("Game Over")


def getSquareInput(prompt):
    while True:
        try:
            move_input = input(prompt)
            if (
                len(move_input) == 2
                and 'a' <= move_input[0].lower() <= 'h'
                and '1' <= move_input[1] <= '8'
            ):
                return (int(move_input[1]) - 1, ord(move_input[0].lower()) - ord('a'))
            else:
                print("Invalid input! Please enter a valid square (e.g., e2).")
        except ValueError:
            print("Invalid input! Please enter a valid square (e.g., e2).")

def drawGameState(gs):
    board = gs.board
    print("    a  b  c  d  e  f  g  h")
    print("  +-------------------------")
    for i in range(8):
        print(f"{8 - i}|", end=" ")
        for j in range(8):
            piece = board[i][j]
            print(piece if piece != '--' else ' .', end=" ")
        print("|")
    print("  +-------------------------")

if __name__ == '__main__':
    main()