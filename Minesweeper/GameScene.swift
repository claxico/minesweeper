//
//  GameScene.swift
//  Minesweeper
//
//  Created by Huit Blackmon on 2/12/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var tiles: [TileObject] = []
    private var labels: [SKLabelNode] = []
    private var cameraNode = SKCameraNode()

    private let cols = 20
    private let rows = 20
    private var numberOfBombs: Int {cols * rows / 10}
    private var flagsLeft = 0
    private var startTime = Date()
    private var tilesLeftToReveal = 0
    private var stage: GameStage = .setup
    
    private var initialScale: CGFloat = 1
    private var margin = 10
    
    var addFlag = true
    
    let numberColors: [Int: UIColor] = [1: .systemBlue, 2: .systemGreen, 3: .red, 4: .purple]
    
    var grassLayer = SKTileMapNode()
    var dirtLayer = SKTileMapNode()
    var flagLayer = SKTileMapNode()
    var bottomLayer = SKTileMapNode()
    
    var parentViewController: GameViewController?
    
    let dateFormatter = DateComponentsFormatter()
    
    override func didMove(to view: SKView) {
        scene?.backgroundColor = UIColor(named: "Water")!
        scene?.addChild(cameraNode)
        scene?.camera = cameraNode
        
//        cameraNode.setScale(2)
        
        setUpBoard()
        setUpTileMap()
        
        let tapRec = UILongPressGestureRecognizer()
        tapRec.minimumPressDuration = 0.5
        tapRec.allowableMovement = 0
        tapRec.addTarget(self, action: #selector(longPressed(_:)))
        self.view!.addGestureRecognizer(tapRec)
        
        let panRec = UIPanGestureRecognizer()
        panRec.minimumNumberOfTouches = 1
        panRec.addTarget(self, action: #selector(self.panned(_:)))
        self.view?.addGestureRecognizer(panRec)
        
//        let pinchRec = UIPinchGestureRecognizer()
//        pinchRec.addTarget(self, action: #selector(self.pinched(_:)))
//        self.view?.addGestureRecognizer(pinchRec)
        
        dateFormatter.allowedUnits = [.minute, .second]
        dateFormatter.zeroFormattingBehavior = .pad
        dateFormatter.unitsStyle = .abbreviated
        
        updateTimeLabel()
        updateFlagLabel()

    }
    
    @objc func panned(_ sender: UIPanGestureRecognizer) {
        
        var xTranslation = -sender.translation(in: view).x //* cameraNode.xScale
        var yTranslation = sender.translation(in: view).y //* cameraNode.yScale

        if cameraNode.position.x + self.frame.width/2 + xTranslation > grassLayer.frame.maxX {
            cameraNode.run(SKAction.moveTo(x: grassLayer.frame.maxX - self.frame.width/2, duration: 0))
            xTranslation = 0
        } else if cameraNode.position.x - self.frame.width/2 + xTranslation < grassLayer.frame.minX {
            cameraNode.run(SKAction.moveTo(x: grassLayer.frame.minX + self.frame.width/2, duration: 0))
            xTranslation = 0
        }
        
        if cameraNode.position.y + self.frame.height/2 + yTranslation > grassLayer.frame.maxY {
            cameraNode.run(SKAction.moveTo(y: grassLayer.frame.maxY - self.frame.height/2, duration: 0))
            yTranslation = 0
        } else if cameraNode.position.y - self.frame.height/2 + yTranslation < grassLayer.frame.minY {
            cameraNode.run(SKAction.moveTo(y: grassLayer.frame.minY + self.frame.height/2, duration: 0))
            yTranslation = 0
        }
        
        cameraNode.position.x += xTranslation
        cameraNode.position.y += yTranslation
        
        sender.setTranslation(CGPoint(x:0, y:0), in: view)
        
    }
    
    @objc func longPressed(_ sender: UILongPressGestureRecognizer) {
    
        if sender.state != .began {
            return
        }
        
        var pos = sender.location(in: view)
        pos = (scene?.convertPoint(fromView: pos))!
        let r = grassLayer.tileRowIndex(fromPosition: pos)
        let c = grassLayer.tileColumnIndex(fromPosition: pos)
        
        guard (0 <= r && r < rows) && (0 <= r && c < cols) else {
            return
        }
        
        let tile = tiles[getIndex(row: r, col: c, rows: rows, cols: cols)]
        
        
        if tile.isRevealed || (!tile.isFlagged && flagsLeft == 0){
            return
        }
        
        tile.isFlagged = !tile.isFlagged
        
        let tileSet = SKTileSet(named: "Minesweeper Tile Set")!
        let flagTiles = tileSet.tileGroups.first { $0.name == "Flag"}
        
        if tile.isFlagged {
            flagsLeft -= 1
            flagLayer.setTileGroup(flagTiles, forColumn: c, row: r)
        } else {
            flagsLeft += 1
            flagLayer.setTileGroup(nil, forColumn: c, row: r)
        }
        updateFlagLabel()
        
        return
    }
    
    @objc func pinched(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .began {
            initialScale = cameraNode.xScale
        }
    
        let nextScale = initialScale / sender.scale

        if nextScale > 2 {
            cameraNode.setScale(2)
            return
        } else if nextScale < 0.5 {
            cameraNode.setScale(0.5)
            return
        }

        cameraNode.setScale(initialScale / sender.scale)
        
//        if let view = sender.view {
//
//               switch sender.state {
//               case .changed:
//                   let pinchCenter = CGPoint(x: sender.location(in: view).x - view.bounds.midX,
//                                             y: sender.location(in: view).y - view.bounds.midY)
//
//                   cameraNode.run(SKAction.moveBy(x: pinchCenter.x, y: pinchCenter.y, duration: 0))
//                   cameraNode.run(SKAction.scale(by: 1/sender.scale, duration: 0))
//                   cameraNode.run(SKAction.moveBy(x: -pinchCenter.x, y: -pinchCenter.y, duration: 0))
//
//                   sender.scale = 1
//
//               default:
//                   return
//               }
//
//
//           }

    }
    
    
    func setUpTileMap() {
        
        let tileSet = SKTileSet(named: "Minesweeper Tile Set")!
        let tileSize = CGSize(width: 64, height: 64)
        
        let lightGrassTiles = tileSet.tileGroups.first { $0.name == "Light Grass"}
        let darkGrassTiles = tileSet.tileGroups.first {$0.name == "Dark Grass"}
        let lightDirtTiles = tileSet.tileGroups.first { $0.name == "Light Dirt"}
        let darkDirtTiles = tileSet.tileGroups.first {$0.name == "Dark Dirt"}

        
        grassLayer = SKTileMapNode(tileSet: tileSet, columns: cols, rows: rows, tileSize: tileSize)
        
        for r in 0..<rows {
            for c in 0..<cols {
                if r % 2 == c % 2 {
                    grassLayer.setTileGroup(lightGrassTiles, forColumn: c, row: r)
                } else {
                    grassLayer.setTileGroup(darkGrassTiles, forColumn: c, row: r)
                }
            }
        }
        
        
        let marginCols = Int(view!.frame.width / tileSize.width * 4)
        let marginRows = Int(view!.frame.height / tileSize.height * 4)
        
        bottomLayer = SKTileMapNode(tileSet: tileSet, columns: marginCols, rows: marginRows, tileSize: tileSize)
        dirtLayer = SKTileMapNode(tileSet: tileSet, columns: cols, rows: rows, tileSize: tileSize)
        flagLayer = SKTileMapNode(tileSet: tileSet, columns: cols, rows: rows, tileSize: tileSize)
        
        for r in 0..<rows {
            for c in 0..<cols {
                if r % 2 == c % 2 {
                    dirtLayer.setTileGroup(lightDirtTiles, forColumn: c, row: r)
                } else {
                    dirtLayer.setTileGroup(darkDirtTiles, forColumn: c, row: r)
                }
            }
        }
        
        for r in 0..<bottomLayer.numberOfRows {
            for c in 0..<bottomLayer.numberOfColumns {
                if r % 2 == c % 2 {
                    bottomLayer.setTileGroup(lightDirtTiles, forColumn: c, row: r)
                } else {
                    bottomLayer.setTileGroup(darkDirtTiles, forColumn: c, row: r)
                }
            }
        }
        
        addChild(bottomLayer)
        addChild(dirtLayer)
        
        for r in 0..<rows {
           for c in 0..<cols {
               
               let center = dirtLayer.centerOfTile(atColumn: c, row: r)
               
               let label = SKLabelNode(text: "")
               label.position = center
               label.fontSize = tileSize.width/2
               label.fontName = "Menlo"
               label.fontColor = .white
               label.verticalAlignmentMode = .center
               
               labels.append(label)
               addChild(label)
                   
           }
       }

        addChild(grassLayer)
        addChild(flagLayer)
        
    }

    func resetGrass() {
        let tileSet = SKTileSet(named: "Minesweeper Tile Set")!
        let lightGrassTiles = tileSet.tileGroups.first { $0.name == "Light Grass"}
        let darkGrassTiles = tileSet.tileGroups.first {$0.name == "Dark Grass"}
        
        for r in 0..<rows {
            for c in 0..<cols {
                if r % 2 == c % 2 {
                    grassLayer.setTileGroup(lightGrassTiles, forColumn: c, row: r)
                } else {
                    grassLayer.setTileGroup(darkGrassTiles, forColumn: c, row: r)
                }
                flagLayer.setTileGroup(nil, forColumn: c, row: r)
            }
        }
        
    }
    
    func setUpBoard() {
        
        resetGrass()
        
        tiles = []
        tilesLeftToReveal = rows*cols - numberOfBombs
        
        for i in 0..<rows*cols {
            tiles.append(TileObject(index: i))
        }
        
        flagsLeft = numberOfBombs
        updateFlagLabel()
        updateTimeLabel()
    }
    
    func setUpMines(startIndex: Int) {
        
        let grid = getNewGrid(rows: rows, cols: cols, bombs: numberOfBombs, startIndex: startIndex)
        
        for i in 0..<grid.count {
            let number = grid[i]
            
            
            if number == 9 {
                tiles[i].isMine = true
                labels[i].text = ""
            } else if number == 0 {
                tiles[i].adjacentMines = 0
                labels[i].text = ""
            } else {
                tiles[i].adjacentMines = number
                labels[i].text = String(number)
                labels[i].fontColor = numberColors[number] ?? .white
            }
        }
        
        startTime = Date()
        
    }
    
    func updateFlagLabel() {
        var message = ""
        switch stage {
        case .setup:
            message = "Tap anywhere to start!"
        case .started:
            message = "Flags left: \(flagsLeft)"
        case .won:
            message = "You win!"
        case .lost:
            message = "You lost :("
        }
        
        parentViewController?.flagsLabel.text = message
    }
    
    func updateTimeLabel() {
        if stage == .setup {
            startTime = Date()
        }
        
        let currentTime = Date()
        let elapsedTime = DateInterval(start: startTime, end: currentTime)
        
        parentViewController?.timeLabel.text = dateFormatter.string(from: elapsedTime.duration)
    }
    
    func revealBombs() {
        for tile in tiles {
            if tile.isMine {
                tile.isRevealed = true
                let tileSet = SKTileSet(named: "Minesweeper Tile Set")!
                let bombTiles = tileSet.tileGroups.first {$0.name == "Bomb"}
                
                let (r, c) = getRowAndCol(index: tile.index, rows: rows, cols: cols)
                grassLayer.setTileGroup(nil, forColumn: c, row: r)
                flagLayer.setTileGroup(bombTiles, forColumn: c, row: r)
            }
        }
    }

    func revealTile(row: Int, col: Int) {
        let tile = tiles[getIndex(row: row, col: col, rows: rows, cols: cols)]
        
        guard !tile.isRevealed else {
            return
        }

        if tile.isMine {
            revealBombs()
            stage = .lost
            updateFlagLabel()
            return
        } else {
        
            tile.isRevealed = true
            grassLayer.setTileGroup(nil, forColumn: col, row: row)
            
            if tile.isFlagged {
                tile.isFlagged = false
                flagsLeft += 1
                flagLayer.setTileGroup(nil, forColumn: col, row: row)
                updateFlagLabel()
            }
           
            tilesLeftToReveal -= 1
            if tilesLeftToReveal == 0 {
                stage = .won
                updateFlagLabel()
            }
            
            if tile.adjacentMines == 0 {
                for dir in dirs {
                    let newRow = row + dir.0
                    let newCol = col + dir.1
                    
                    guard (0 <= newRow && newRow < rows) && (0 <= newCol && newCol < cols) else {
                       continue
                    }
                    revealTile(row: newRow, col: newCol)
                }
                
            }
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
        if stage == .won || stage == .lost {
            setUpBoard()
            stage = .setup
            updateFlagLabel()
            updateTimeLabel()
            return
        }
        
        
        let r = grassLayer.tileRowIndex(fromPosition: pos)
        let c = grassLayer.tileColumnIndex(fromPosition: pos)
        
        guard grassLayer.frame.contains(pos) else {
            return
        }
    
        let tile = tiles[getIndex(row: r, col: c, rows: rows, cols: cols)]
        
        if tile.isFlagged || tile.isRevealed {
            return
        } else if stage == .setup {
            let startIndex = getIndex(row: r, col: c, rows: rows, cols: cols)
            setUpMines(startIndex: startIndex)
            stage = .started
            updateFlagLabel()
        }
        
        revealTile(row: r, col: c)

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.longPress(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        if stage == .started {
            updateTimeLabel()
        }
    }
}

