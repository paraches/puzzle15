//
//  GameScene.swift
//  puzzle15
//
//  Created by paraches on 2019/08/02.
//  Copyright © 2019 paraches. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol GameSceneTouchDelegate {
    func touchesBeganInGameScene(x: Int, y: Int)
    func touchesEndedInGameScene(x: Int, y: Int)
    func touchesMovedInGameScene(x: Int, y: Int)
}

fileprivate let PieceSize: CGFloat = 80
fileprivate let PieceHalfSize: CGFloat = PieceSize / 2
fileprivate let BoardSize: CGFloat = PieceSize * 4

class GameScene: SKScene {
    var gameSceneTouchDelegate: GameSceneTouchDelegate?

    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: ((size.width-BoardSize)/2)/size.width,
                              y: ((size.height-BoardSize)/2)/size.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func didMove(to view: SKView) {
    }
    
    func touchUp(atPoint pos : CGPoint?) {
        guard let pos = pos else { return }
        if let (x, y) = calcColRowFrom(point: pos) {
            gameSceneTouchDelegate?.touchesEndedInGameScene(x: x, y: y)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchUp(atPoint: touches.first?.location(in: self))
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    
    //
    //  Place PuzzlePiece's spriteNode on GameScene
    //
    func placePuzzlePieces(_ board: Array2D<PuzzlePiece>, picture: CGImage, back: CGImage) {
        for (index, piece) in board.enumerated() {
            if let piece = piece, piece.sprite == nil {
                let cropRect = calcRectFor(number: index)
                if let image = picture.cropping(to: cropRect), let back = back.cropping(to: cropRect) {
                    let texture = SKTexture(cgImage: image)
                    piece.frontTexture = texture
                    piece.backTexture = SKTexture(cgImage: back)
                    let sprite = SKSpriteNode(texture: texture)
                    sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                    sprite.position = CGPoint(x: cropRect.origin.x + PieceHalfSize,
                                              y: 240 - cropRect.origin.y + PieceHalfSize)
                    addChild(sprite)
                    piece.sprite = sprite
                }
            }
        }
    }

    func setPuzzlePiecesPosition(_ board: Array2D<PuzzlePiece>) {
        for y in 0..<board.rows {
            for x in 0..<board.columns {
                if let piece = board[x, y], let sprite = piece.sprite {
                    setSpritePosition(sprite, x: x, y: y)
                }
            }
        }
    }

    func movePieces(_ pieces: [PuzzlePiece?], orientation: Int) {
        for (index, piece) in pieces.enumerated() {
            if let piece = piece, let sprite = piece.sprite {
                var moveAction: SKAction? = nil
                switch orientation {
                case 0:
                    moveAction = createMoveAction(x: sprite.position.x, y: sprite.position.y + PieceSize)
                case 1:
                    moveAction = createMoveAction(x: sprite.position.x + PieceSize, y: sprite.position.y)
                case 2:
                    moveAction = createMoveAction(x: sprite.position.x, y: sprite.position.y - PieceSize)
                case 3:
                    moveAction = createMoveAction(x: sprite.position.x - PieceSize, y: sprite.position.y)
                default:
                    break
                }
                if let moveAction = moveAction {
                    sprite.run(SKAction.sequence([
                        SKAction.wait(forDuration: TimeInterval(CGFloat(index) * 0.05)),
                        moveAction
                        ]
                    ))
                }
            }
        }
    }

    func fadeoutPieces(_ board: Array2D<PuzzlePiece>, duration: Double, completion: @escaping () -> Void) {
        for piece in board {
            if let sprite = piece?.sprite {
                sprite.run(SKAction.fadeOut(withDuration: duration))
            }
        }
        run(SKAction.wait(forDuration: duration), completion: completion)
    }
    
    func fadeinPieces(_ board: Array2D<PuzzlePiece>, duration: Double, completion: @escaping () -> Void) {
        for piece in board {
            if let sprite = piece?.sprite {
                sprite.run(SKAction.fadeIn(withDuration: duration))
            }
        }
        run(SKAction.wait(forDuration: duration), completion: completion)
    }
    
    func fadeinPieceWithWait(_ piece: PuzzlePiece?, duration: Double, wait: Double, completion: @escaping () -> Void) {
        if let sprite = piece?.sprite {
            sprite.run(SKAction.sequence([
                SKAction.wait(forDuration: wait),
                SKAction.fadeIn(withDuration: duration)
                ]),completion: completion)
        }
    }

    func flipAll(_ board: Array2D<PuzzlePiece>) {
        var wait: Double = 0.0
        for piece in board {
            if let piece = piece {
                flip(piece: piece, duration: 0.2, wait: wait)
            }
            wait += 0.05
        }
    }

    func resetTexture(_ board: Array2D<PuzzlePiece>) {
        for piece in board {
            if let piece = piece, let texture = piece.frontTexture {
                piece.sprite?.texture = texture
            }
        }
    }

    private func flip(piece: PuzzlePiece, duration: Double, wait: Double = 0.0) {
        let faceHalfFlip = SKAction.scaleX(to: 0.0, duration: duration)
        let backHalfFlip = SKAction.scaleX(to: 1.0, duration: duration)
        
        var actions = [SKAction]()
        if wait != 0.0 {
            actions.append(SKAction.wait(forDuration: wait))
        }
        actions.append(faceHalfFlip)
        
        if let backTexture = piece.backTexture {
            piece.sprite?.run(SKAction.sequence(actions), completion: {
                piece.sprite?.texture = backTexture
                piece.sprite?.run(backHalfFlip, completion: {})
            })
        }
    }

    private func createMoveAction(x: CGFloat, y: CGFloat) -> SKAction {
        let newPosition = CGPoint(x: x, y: y)
        let duration = 0.2
        let moveAction = SKAction.move(to: newPosition, duration: duration)
        moveAction.timingMode = .easeOut
        return moveAction
    }

    private func setSpritePosition(_ sprite: SKSpriteNode, x: Int, y: Int) {
        sprite.position = CGPoint(x: CGFloat(x) * PieceSize + PieceHalfSize,
                                  y: (PieceSize * (4 - 1)) - CGFloat(y) * PieceSize + PieceHalfSize)
    }

    private func calcColRowFrom(point: CGPoint) -> (colmn: Int, row: Int)? {
        guard 0 <= point.x && point.x < BoardSize && 0 <= point.y && point.y < BoardSize else {
            return nil
        }
        
        let x = Int(point.x / PieceSize)
        let y = 3 - Int(point.y / PieceSize)
        
        return (x, y)
    }

    private func calcRectFor(number: Int) -> CGRect {
        let x = Int(PieceSize) * (number % 4)
        let y =  Int(PieceSize) * (number / 4)
        return CGRect(x: x, y: y, width: Int(PieceSize), height: Int(PieceSize))
    }

}
