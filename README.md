# Automated Chess Board System

## Introduction

The Automated Chess Board System merges the ancient strategy game of chess with cutting-edge automation technology. This innovative platform allows players to compete against artificial intelligence (AI), practicing their strategies and seeing them executed on an electronic chessboard. It translates players' commands into actual movements, enhancing the traditional chess experience with modern technology.

## Theory

The system employs a sophisticated algorithm that assigns values to chess pieces and positions to calculate the best move. It uses a valuation system (pawns = 1, knights and bishops = 3, rooks = 5, queens = 9, king = 0) and a streamlined Minimax algorithm to evaluate the board's state and make decisions. This process aims to maximize the player's score while minimizing the opponent's, taking into account both material and positional advantages. The level of the chess engine can be adjusted by changing the evaluation depth.

## Design

The design of the Automated Chess Board System began with a detailed schematic of electronic components and their connections, followed by individual testing of components like NEMA17 stepper motors and DRV8825 drivers. The chessboard combines 3D-printed parts, aluminum profiles, and GT belts for precise movement control. Key features include limit switches for position calibration and an electromagnet for piece manipulation, powered by 12V and controlled via an NMOS transistor. The system's software interprets chess moves from a Python script, executing them through the physical movement of pieces on the board.

## Results and Discussions

The system demonstrated an 80% accuracy in piece movement. Challenges included magnet-to-board alignment and the variable weight of chess pieces. Initially, the design faced limitations due to the large code size, leading to a refined approach that emphasizes serial communication. Suggestions for improvement include using servo motors for precise magnet positioning and stronger magnets to enhance operational efficiency.

## Conclusions

The Automated Chess Board System showcases the successful integration of AI with mechanical chess, achieving substantial accuracy in piece movement. Future enhancements can further improve magnet alignment and the system's overall functionality, promising an even more engaging and efficient automated chess experience.
