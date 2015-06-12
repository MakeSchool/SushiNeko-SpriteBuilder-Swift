//
//  GameOver.swift
//  Timberman
//
//  Created by Dion Larson on 2/23/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

class GameOver: CCNode {
  var scoreLabel: CCLabelTTF!           // loaded in from SpriteBuilder
  var score: Int = 0 {                  // keeps track of score
    didSet {                            // updates label whenever changed
      scoreLabel.string = "\(score)"
    }
  }
  
  var restartButton: CCButton!          // loaded in from SpriteBuilder
  
  // gets called after CCB is finished being loaded in, all Doc root vars populated
  func didLoadFromCCB() {
    // fade in restart button
    restartButton.cascadeOpacityEnabled = true
    restartButton.runAction(CCActionFadeIn(duration: 0.3))
  }
}
