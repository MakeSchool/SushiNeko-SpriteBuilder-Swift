//
//  Character.swift
//  Timberman
//
//  Created by Dion Larson on 2/3/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

class Character: CCSprite {
  var side: Side = .Left    // Character starts on left side
  
  func left() {             // triggered by touchBegan on left side
    side = .Left
    scaleX = 1              // default character sprite
  }
  
  func right() {            // triggered by touchBegan on right side
    side = .Right
    scaleX = -1             // flips sprite around anchor point
  }
  
  func tap() {              // runs the swipe animation for character
    animationManager.runAnimationsForSequenceNamed("Tap")
  }
}
