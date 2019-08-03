//
//  GameViewController.swift
//  puzzle15
//
//  Created by paraches on 2019/08/02.
//  Copyright © 2019 paraches. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, PuzzleGameDelegate, GameSceneTouchDelegate {
    @IBOutlet var skView: SKView!
    @IBOutlet weak var startButton: UIButton!

    var gameScene: GameScene?
    var puzzleGame: PuzzleGame?
    
    var reset = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {

            let scene = GameScene(size: view.bounds.size)
            scene.gameSceneTouchDelegate = self
            self.gameScene = scene

            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true

            let puzzleGame = PuzzleGame(delegate: self)
            self.puzzleGame = puzzleGame
            
            if let image = UIImage(named: "face")?.cgImage, let backImage = UIImage(named: "back")?.cgImage {
                scene.placePuzzlePieces(puzzleGame.board, picture: image, back: backImage)
            }
        }
        

    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func touchStartButton(_ sender: Any) {
        if reset {
            startButton.setTitle("Start", for: .normal)
            resetBoard()
        }
        else {
            startGame()
        }
    }
    
    private func resetBoard() {
        guard let puzzleGame = puzzleGame, let gameScene = gameScene else { return }
        reset = false
        gameScene.fadeoutPieces(puzzleGame.board, duration: 0.5, completion:{
            gameScene.resetTexture(puzzleGame.board)
            gameScene.fadeinPieces(puzzleGame.board, duration: 0.5, completion: {})
        })
    }
    
    private func startGame() {
        guard let puzzleGame = puzzleGame, let gameScene = gameScene else { return }
        gameScene.fadeoutPieces(puzzleGame.board, duration: 0.5, completion: {
            puzzleGame.gameStart()
            gameScene.fadeinPieces(puzzleGame.board, duration: 0.5, completion: {})
        })
    }

    //
    //  GameSceneTouchDelegate
    //
    func touchesBeganInGameScene(x: Int, y: Int) {
    }
    
    func touchesEndedInGameScene(x: Int, y: Int) {
        guard let puzzleGame = puzzleGame else { return }
        puzzleGame.clickAt(colmn: x, row: y)
    }
    
    func touchesMovedInGameScene(x: Int, y: Int) {
    }
    
    //
    //  PuzzleGameDelegate
    func gameDidStart(game: PuzzleGame) {
        guard let gameScene = gameScene, let puzzleGame = puzzleGame else { return }
        
        gameScene.setPuzzlePiecesPosition(puzzleGame.board)
    }
    
    func PuzzlePieceMove(pieces: [PuzzlePiece?], orientation: Int) {
        guard let gameScene = gameScene else { return }
        
        gameScene.movePieces(pieces, orientation: orientation)
    }
    
    func gameDidFinished(game: PuzzleGame) {
        guard let gameScene = gameScene, let puzzleGame = puzzleGame else { return }
        
        gameScene.fadeinPieceWithWait(puzzleGame.board[15], duration: 0.5, wait: 0.4, completion: {
            gameScene.run(SKAction.wait(forDuration: 1.0), completion: {
                gameScene.flipAll(puzzleGame.board)
                self.reset = true
                self.startButton.setTitle("Reset", for: .normal)
            })
        })

    }

}
