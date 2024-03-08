//
//  Tile.swift
//  Minesweeper
//
//  Created by Huit Blackmon on 2/12/23.
//

import Foundation
import GameKit
import SpriteKit

class Tile: SKShapeNode {
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isMine = false
    var adjacentMines = 0
    var isRevealed = false
    var isFlagged = false
    
    var label: SKLabelNode?
    var flag: SKShapeNode?
    
    var row = 0
    var col = 0
    
    var index = 0
    
    func update() {
        if isRevealed {
            self.flag?.isHidden = true
            if isMine {
                self.fillColor = .red
            } else {
                self.fillColor = brownColor
                if adjacentMines > 0 {
                    self.label?.text = String(adjacentMines)
                    self.label?.fontColor = numberColors[adjacentMines] ?? .white
                    self.fillColor = brownColor
                }
            }
        } else {
            if isFlagged {
                self.flag?.isHidden = false
            } else {
                self.flag?.isHidden = true
            }
    
            self.fillColor = greenColor
        }
    }
    
    var greenColor: UIColor {
        if (row % 2) == (col % 2) {
            return UIColor(named: "Light Grass")!
        } else {
            return UIColor(named: "Dark Grass")!
        }
    }
    
    var brownColor: UIColor {
        if (row % 2) == (col % 2) {
            return UIColor(named: "Light Dirt")!
        } else {
            return UIColor(named: "Dark Dirt")!
        }
    }
    
    
    let numberColors: [Int: UIColor] = [1: .systemBlue, 2: .systemGreen, 3: .red, 4: .purple]

    
    
}
