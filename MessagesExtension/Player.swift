//
//  Player.swift
//  Chicago
//
//  Created by Drew Lanning on 2/3/17.
//  Copyright © 2017 Drew Lanning. All rights reserved.
//

import Foundation

enum MoveError: Error {
  case invalidMove
}

class Player {
  private var _score: Int
  var score: Int {
    return _score
  }
  private var _rollLimit: Int = 3
  var rollLimit: Int {
    return _rollLimit
  }
  private var _chips: Int
  var chips: Int {
    return _chips
  }
  private var _availableMoves: [ValidMove]
  var availableMoves: [ValidMove] {
    return _availableMoves
  }
  private var _playerID: String!
  var playerID: String {
    return _playerID
  }
    
  init(score: Int = 0, chips: Int = 0, availableMoves: [ValidMove] = [.roll, .roll, .roll, .setAside]) {
    self._score = score
    self._chips = chips
    self._availableMoves = availableMoves
  }
  
  func setPlayer(id: String) {
    self._playerID = id
  }
  
  func setRollLimit(to rolls: Int) {
    _rollLimit = rolls
    _availableMoves.removeAll()
    for _ in 0 ..< _rollLimit {
      _availableMoves.append(.roll)
    }
    _availableMoves.append(.setAside)
  }
  
  func makeMove(_ move: ValidMove) throws {
    switch move {
    case .roll:
      if _availableMoves.contains(.roll) {
        _availableMoves.remove(at: _availableMoves.index(of: .roll)!)
      } else {
        throw MoveError.invalidMove
      }
    case .setAside:
      break
    }
  }
  
  func setScore(to score: Int) {
    self._score = score
  }
  
  func setChips(to chips: Int) {
    self._chips = chips
  }
  
  func isTurnOver() -> Bool {
    return availableMoves.contains(.roll) == false
  }
  
}
