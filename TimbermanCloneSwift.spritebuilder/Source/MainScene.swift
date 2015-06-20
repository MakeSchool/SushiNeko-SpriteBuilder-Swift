//
//  MainScene.swift
//  Timberman
//
//  Created by Dion Larson on 2/3/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation

enum Side {                         // enum for keeping track branch and character sides
  case Left, Right, None
}

enum GameState {                    // enum for keeping track of GameState
  case Title, Ready, Playing, GameOver
}

class MainScene: CCNode {
  var timeLeft: Float = 0 {         // time left for game over life bar
    didSet {                        // updates lifeBar scale timeLeft whenever changes
      timeLeft = max(min(timeLeft, 10), 0)
      lifeBar.scaleX = timeLeft / Float(10)
    }
  }
  var lifeBar: CCSprite!            // loaded in from SpriteBuilder
  
 
  var score: Int = 0 {              // keeps track of score
    didSet {                        // updates label whenever changed
      scoreLabel.string = "\(score)"
    }
  }
  var scoreLabel: CCLabelTTF!       // loaded in from SpriteBuilder
  
  var pieces: [Piece] = []          // array to keep track of pieces buffer
  var piecesNode: CCNode!           // CCNode to hold pieces, loaded in from SpriteBuilder
  var pieceIndex: Int = 0           // index of current pieces
  var pieceLastSide: Side = .Left   // keeps track of last-set pieces side
                                    // allows for fair randomization of obstacles (chopsticks)
  
  var addPiecePosition: CGPoint?    // placeholder point for dropping in animated sushi

  var character: Character!         // loaded in from SpriteBuilder

  var tapButtons: CCNode!           // loaded in from SpriteBuilder
  var gameState = GameState.Title   // tracks game state
  
  
  // gets called after CCB is finished being loaded in, all Doc root vars populated
  func didLoadFromCCB() {
    // loops from 0 to 10 non-inclusive
    for i in 0..<10 {
      // loads a new pieces from CCB into piece var
      var piece: Piece = CCBReader.load("Piece") as! Piece
      
      // sets up obstacle (chopstick) side
      pieceLastSide = piece.setObstacle(pieceLastSide)
      
      // sets initial position, dependent on i so that it builds up tower
      piece.position = CGPoint(x: 0, y: piece.contentSizeInPoints.height * CGFloat(i))
      
      // add piece to piecesNode so it will be drawn to scene
      piecesNode.addChild(piece)
      
      // add piece to pieces array
      pieces.append(piece)
    }
    // initializes timeLeft at 5 so bar is 50% full
    timeLeft = 5
    
    // enables touches so touchBegan can be triggered
    self.userInteractionEnabled = true
    
  }
  
  override func onEnter() {         // gets called after added to screen
    super.onEnter()                 // init -> didLoadFromCCB -> onEnter
    addPiecePosition = piecesNode.positionInPoints
  }
  
  // triggered whenever a touch is detected in the scene
  override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
    if gameState == .GameOver || gameState == .Title { return }  // Ignore if game state is game over
    if gameState == .Ready { start() }    // Trigger start animation
    
    if touch.locationInWorld().x < CCDirector.sharedDirector().viewSize().width / 2 {
      character.left()              // touch is on left side of screen
    } else {
      character.right()             // touch is on right side of screen
    }
    if isGameOver() { return }      // check for obstacle collision after character moves
    
    character.tap()                 // animate the character's swipe
    
    stepTower()                     // steps tower
  }
  
  func addHitPiece(obstacleSide: Side) {
    // load in piece
    var flyingPiece: Piece = CCBReader.load("Piece") as! Piece
    
    // place at bottom of tower
    flyingPiece.position = addPiecePosition!
    
    // queue up correct animation based on which side character is on
    var animationName = character.side == .Left ? "FromLeft" : "FromRight"
    flyingPiece.animationManager.runAnimationsForSequenceNamed(animationName)
    flyingPiece.side = obstacleSide
    
    // add to scene and animation starts
    addChild(flyingPiece)
  }
  
  func stepTower() {
    // grab current piece
    var piece = pieces[pieceIndex]
    
    // add in animated piece to fly away
    addHitPiece(piece.side)
    
    // move piece to top of tower
    piece.position = ccpAdd(piece.position, CGPoint(x: 0, y: piece.contentSize.height * 10))
    
    // increase zOrder of piece, needed because of isometric piece view
    piece.zOrder = piece.zOrder + 1
    
    // randomizes obstacle side on piece
    pieceLastSide = piece.setObstacle(pieceLastSide)
    
    var movePiecesDown = CCActionMoveBy(duration: 0.15, position: CGPoint(x: 0, y: -piece.contentSize.height))
    piecesNode.runAction(movePiecesDown)
    
    // increment pieceIndex so next piece will be checked on next stepTower
    pieceIndex = (pieceIndex + 1) % 10
    
    if isGameOver() { return }      // checks for obstacle collision after tower stepped
    timeLeft = timeLeft + 0.25      // increments time
    score++                         // increments score
  }
  
  func isGameOver() -> Bool {       // checks if current piece is on same side as character
    // grab current piece
    var newPiece = pieces[pieceIndex]
    
    // checks if on same side as character, triggers game over
    if newPiece.side == character.side { triggerGameOver() }
    
    // returns game over bool for using method call in if statement
    return gameState == .GameOver
  }
  
  func triggerGameOver() {          // sets game state to GameOver and shows recap screen
    gameState = .GameOver
    
    var gameOverScreen: GameOver = CCBReader.load("GameOver", owner: self) as! GameOver
    gameOverScreen.score = score    // set score for game over screen
    addChild(gameOverScreen)   // drop down animation plays automatically
  }
  
  func ready() {
    gameState = .Ready              // game state updated
    
    // show score/timer
    animationManager.runAnimationsForSequenceNamed("Ready")
    
    // fade in tap buttons
    tapButtons.cascadeOpacityEnabled = true
    tapButtons.opacity = 0.0
    tapButtons.runAction(CCActionFadeIn(duration: 0.2))
  }
  
  func start() {
    gameState = .Playing            // game state updated
    
    // fade out tap buttons
    tapButtons.runAction(CCActionFadeOut(duration: 0.2))
  }
  
  func restart() {                  // triggered by restartButton set up in SpriteBuilder
    // load in new MainScene from CCB
    var mainScene: MainScene = CCBReader.load("MainScene") as! MainScene
    mainScene.ready()
    
    var scene = CCScene()
    scene.addChild(mainScene)
    
    var transition = CCTransition(fadeWithDuration: 0.3)
    
    // replace current scene with new scene to start game from beginning
    CCDirector.sharedDirector().presentScene(scene, withTransition: transition)
  }
  
  override func update(delta: CCTime) {   // called before every frame before draw
    if gameState != .Playing { return }   // ignore if not in Playing state
    timeLeft -= Float(delta)              // decrement time left by time since last update
    if timeLeft == 0 {                    // trigger game over if time left is zero
      triggerGameOver()
    }
  }
}
