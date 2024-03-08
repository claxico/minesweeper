//
//  TileObject.swift
//  Minesweeper
//
//  Created by Huit Blackmon on 2/18/23.
//

import Foundation
import UIKit


class TileObject {
    
    init(index: Int) {
        self.index = index
    }
    
    var isMine = false
    var adjacentMines = 0
    var isRevealed = false
    var isFlagged = false
    var index = 0
   

    let numberColors: [Int: UIColor] = [1: .systemBlue, 2: .systemGreen, 3: .red, 4: .purple]

    
    
}



