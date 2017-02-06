//
//  Die.swift
//  Chicago
//
//  Created by Drew Lanning on 2/3/17.
//  Copyright © 2017 Drew Lanning. All rights reserved.
//

import GameplayKit
import Foundation

class Die {
  
  internal var _numSides: Int
  var numSides: Int {
    return _numSides
  }
  
  internal var _value: Int
  var value: Int {
    return _value
  }
  
  private var _locked = false
  var locked: Bool {
    return _locked
  }
  
  init(sides: Int, faceColor: UIColor = .white, pipColor: UIColor = .black) {
    self._numSides = sides
    self._value = 1
  }
  
  func roll(withModifier modifier: Int = 0) -> Int {
    self._value = GKRandomDistribution.init(forDieWithSideCount: self._numSides).nextInt() + modifier
    return self._value
  }
  
  func lockDie() {
    self._locked = true
  }
  
}

class D6: Die {
  init() {
    super.init(sides: 6)
    self._value = 3
  }
}

extension D6 {
  var score: Int {
    switch value {
    case 1:
      return 100
    case 2, 3, 4, 5:
      return value
    case 6:
      return 60
    default:
      return 0
    }
  }
}
