//
//  GameEndMessages.swift
//  Chicago
//
//  Created by Drew Lanning on 2/8/17.
//  Copyright © 2017 Drew Lanning. All rights reserved.
//

import UIKit

enum RoundEndMessages {
  
  case currentPlayerWon(phase: Phase), currentPlayerLost(phase: Phase), priorPlayerLost()
  
  func message() -> String? {
    switch self {
    case .currentPlayerWon(phase: .one):
      return "you won the round, your opponent will get a planet and start the next round"
    case .currentPlayerWon(phase: .two):
      return "you won the round, you get to destroy a planet and your opponent starts the next round"
    case .currentPlayerWon(phase: .end):
      return nil
    case .currentPlayerLost(phase: .one):
      return "you lost the round, you have to take a planet, you start the new round"
    case .currentPlayerLost(phase: .two):
      return "you lost the round, your opponent gets to destroy a planet, you start the new round"
    case .currentPlayerLost(phase: .end):
      return nil
    case .priorPlayerLost():
      return "they lost the round, and started a new round"
    }
  }
  
  func action() -> String? {
    switch self {
    case .currentPlayerWon(phase: .one):
      return "SEND TO OPPONENT"
    case .currentPlayerWon(phase: .two):
      return "SEND TO OPPONENT"
    case .currentPlayerWon(phase: .end):
      return nil
    case .currentPlayerLost(phase: .one):
      return "START NEW ROUND"
    case .currentPlayerLost(phase: .two):
      return "START NEW ROUND"
    case .currentPlayerLost(phase: .end):
      return nil
    case .priorPlayerLost():
      return "OKAY"
    }
  }
  
  func currentPlayerWonAction() -> Bool? {
    switch self {
    case .currentPlayerWon(phase: .one):
      return true
    case .currentPlayerWon(phase: .two):
      return true
    case .currentPlayerWon(phase: .end):
      return true
    case .currentPlayerLost(phase: .one):
      return false
    case .currentPlayerLost(phase: .two):
      return false
    case .currentPlayerLost(phase: .end):
      return false
    case .priorPlayerLost():
      return nil
    }
  }
  
}
