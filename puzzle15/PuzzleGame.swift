//
//  PuzzleGame.swift
//  puzzle15
//
//  Created by paraches on 2019/08/02.
//  Copyright © 2019 paraches. All rights reserved.
//

import Foundation

protocol PuzzleGameDelegate {
    func gameDidStart(game: PuzzleGame)
    func PuzzlePieceMove(pieces: [PuzzlePiece?], orientation: Int)
    func gameDidFinished(game: PuzzleGame)
}

class PuzzleGame {
    var delegate: PuzzleGameDelegate
    var board: Array2D<PuzzlePiece>
    var removedPiece: PuzzlePiece?
    
    init(delegate: PuzzleGameDelegate) {
        self.delegate = delegate
        self.board = Array2D<PuzzlePiece>(columns: 4, rows: 4)
        setupPuzzlePieces()
    }
    
    private func setupPuzzlePieces() {
        for row in 0..<4 {
            for colmn in 0..<4 {
                board[colmn, row] = PuzzlePiece(number: row * 4 + colmn)
            }
        }
    }

    func gameStart() {
        removedPiece = board[15]
        board[15] = nil
        
        repeat {
            shuffleByInsert()
        } while (!canSolve(board))

        delegate.gameDidStart(game: self)
    }
    
    func clickAt(colmn: Int, row: Int) {
        if canMoveFrom(colmn: colmn, row: row) {
            if let (movedPieces, orientation) = moveFrom(colmn: colmn, row: row) {
                delegate.PuzzlePieceMove(pieces: movedPieces, orientation: orientation)
            }
            if doesGameFinished() {
                gameFinished()
            }
        }
    }
    
    private func doesGameFinished() -> Bool {
        for i in 0..<15 {
            if board[i]?.number != i {
                return false
            }
        }
        return true
    }
    
    private func gameFinished() {
        board[15] = removedPiece
        delegate.gameDidFinished(game: self)
    }
    
    private func canMoveFrom(colmn: Int, row: Int) -> Bool {
        if board[colmn, row] == nil { return false }
        
        for i in 0..<4 {
            if board[colmn, i] == nil || board[i, row] == nil {
                return true
            }
        }
        return false
    }
    
    private func spacePosition() -> (colmn: Int, row: Int)? {
        for i in 0..<16 {
            if board[i] == nil {
                return (i % 4, i  / 4)
            }
        }
        return nil
    }
    
    private func moveFrom(colmn: Int, row: Int) -> (movedPieces: [PuzzlePiece?], orientation: Int)? {
        guard let (x, y) = spacePosition() else { return nil }
        
        var pieces = [PuzzlePiece?]()
        var orientation = -1
        
        if x == colmn {
            if y < row {
                for i in (y+1)...row {
                    board[colmn, i - 1] = board[colmn, i]
                    pieces.append(board[colmn, i])
                }
                orientation = 0
            }
            else {
                for i in (row..<y).reversed() {
                    board[colmn, i + 1] = board[colmn, i]
                    pieces.append(board[colmn, i])
                }
                orientation = 2
            }
        }
        else if y == row {
            if x < colmn {
                for i in (x+1)...colmn {
                    board[i - 1, row] = board[i, row]
                    pieces.append(board[i, row])
                }
                orientation = 3
            }
            else {
                for i in (colmn..<x).reversed() {
                    board[i + 1, row] = board[i, row]
                    pieces.append(board[i, row])
                }
                orientation = 1
            }
        }
        board[colmn, row] = nil
        return (pieces, orientation)
    }
    
    private func shuffleByMove() {
        for _ in 0..<5000 {
            let x = Int(arc4random_uniform(4))
            let y = Int(arc4random_uniform(4))
            if canMoveFrom(colmn: x, row: y) {
                let _ = moveFrom(colmn: x, row: y)
            }
        }
    }
    
    private func shuffleByInsert() {
        let newBoard = Array2D<PuzzlePiece>(columns: 4, rows: 4)
        var indexes = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
        
        for piece in board {
            if let piece = piece {
                let i = arc4random_uniform(UInt32(indexes.count))
                let position = indexes.remove(at: Int(i))
                newBoard[position] = piece
            }
        }
        
        board = newBoard
    }
    
    private func canSolve(_ gameBoard: Array2D<PuzzlePiece>) -> Bool {
        var count = 0
        var table = gameBoard.map {$0?.number}
        
        for (i, number) in table.enumerated() {
            if i == 15 { break }
            if i == number { continue }
            for j in i+1...15 {
                if table[j] == i {
                    table[j] = table[i]
                    table[i] = i
                    count += 1
                    break
                }
            }
        }
        
        return count % 2 == 0 ? true : false
    }
}
