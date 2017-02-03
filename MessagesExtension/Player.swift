//
//  Player.swift
//  Chicago
//
//  Created by Drew Lanning on 2/3/17.
//  Copyright © 2017 Drew Lanning. All rights reserved.
//

import Foundation

class Player {
  var score: Int
  var chips: Int
  var availableMoves: [ValidMoves]
  private var _playerID: String!
  var playerID: String {
    return _playerID
  }
  
  init(score: Int = 0, chips: Int = 0, availableMoves: [ValidMoves] = [.roll, .roll, .roll, .setAside]) {
    self.score = score
    self.chips = chips
    self.availableMoves = availableMoves
  }
  
  func setPlayer(id: String) {
    self._playerID = id
  }
}
