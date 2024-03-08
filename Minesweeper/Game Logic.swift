//
//  Game Logic.swift
//  Minesweeper
//
//  Created by Huit Blackmon on 2/12/23.
//

import Foundation

func getRowAndCol(index: Int, rows: Int, cols: Int) -> (Int, Int) {
    return (index / cols, index % cols)
}

func getIndex(row: Int, col: Int, rows: Int, cols: Int) -> Int {
    
    return row * cols + col
}

let dirs = [(-1, -1), (-1, 0), (-1, +1),
            (0, -1),           (0, +1),
            (+1, -1), (+1, 0), (1, +1),
]


func getNewGrid(rows: Int, cols: Int, bombs: Int, startIndex: Int) -> [Int] {
    
    var grid = Array(repeating: 0, count: rows*cols)
    
    var b: [Int] = Array(0..<rows*cols)
    b.remove(at: startIndex)
    b = b.shuffled()
    let bombIndices = b.prefix(bombs)
    
    // Set up bombs
    for i in bombIndices {
        grid[i] = 9
    }
    
    // Set up numbers
    for i in bombIndices {
        
        let (bombRow, bombCol) = getRowAndCol(index: i, rows: rows, cols: cols)
        
        for dir in dirs {
            
            let newRow = bombRow + dir.0
            let newCol = bombCol + dir.1
            
            guard (0 <= newRow && newRow < rows) && (0 <= newCol && newCol < cols) else {
               continue
            }
            
            let index = getIndex(row: newRow, col: newCol, rows: rows, cols: cols)

            if grid[index] != 9 {
                grid[index] += 1
            }
        }
    }
    
    return grid
}



enum GameStage {
    case setup, started, won, lost
}
