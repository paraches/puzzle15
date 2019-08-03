//
//  PuzzlePiece.swift
//  puzzle15
//
//  Created by paraches on 2019/08/02.
//  Copyright © 2019 paraches. All rights reserved.
//

import Foundation
import SpriteKit

class PuzzlePiece {
    var number: Int
    var sprite: SKSpriteNode?
    var frontTexture: SKTexture?
    var backTexture: SKTexture?
    
    init(number: Int) {
        self.number = number
    }
}
