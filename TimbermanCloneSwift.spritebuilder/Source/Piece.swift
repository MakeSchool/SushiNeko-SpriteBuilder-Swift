//
//  Piece.swift
//  Timberman
//
//  Created by Dion Larson on 2/3/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

class Piece: CCNode {
  var left: CCSprite!             // loaded in from SpriteBuilder
  var right: CCSprite!            // loaded in from SpriteBuilder
  
  var side: Side = .None {        // intializes obstacle side to none
    didSet {                      // sets visibility according to side set
      left.visible = false
      right.visible = false
      if side == .Right {
        right.visible = true
      } else if side == .Left {
        left.visible = true
      }
    }
  }
  
  // handles randomization of obstacle side
  func setObstacle(lastSide: Side) -> Side {
    if lastSide != .None {        // if last side was not none, set to None
      side = .None                // keeps unpassable state from occurring
    } else {
      var rand = CCRANDOM_0_1()   // random value between 0 and 1
      if rand < 0.45 {
        side = .Left              // 45% of obstacle sides will be left
      } else if rand < 0.9 {
        side = .Right             // 45% of obstacle sides will be right
      } else {
        side = .None              // 10% of obstacle sides will be repeated none
      }
    }
    return side                   // returns side so pieceLastSide can be set
  }
}
