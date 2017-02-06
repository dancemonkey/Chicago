//
//  ChicagoModel.swift
//  Chicago
//
//  Created by Drew Lanning on 2/3/17.
//  Copyright © 2017 Drew Lanning. All rights reserved.
//

import Foundation
import Messages

enum ValidMove: String {
  case roll, setAside
}

enum PlayerItemNames: String {
  case score, chips, rollLimit, playerID
}

enum GameItemNames: String {
  case phase, potSize
}

enum Phase: Int {
  case one = 1, two
}

class ChicagoModel {
  private var _players = [Player]()
  var players: [Player] {
    return _players
  }
  private var _currentPlayer: Player? = nil
  var currentPlayer: Player? {
    return _currentPlayer
  }
  private var _currentPhase: Phase = .one
  var currentPhase: Phase {
    return _currentPhase
  }
  private var dice: [D6] = [D6(), D6(), D6()]
  private var _potOfChips: Int = 0
  var potOfChips: Int {
    return _potOfChips
  }
  private let validMoves: [ValidMove] = [.roll, .roll, .roll, .setAside]
  private var turnOver: Bool {
    return currentPlayer?.availableMoves.count == 0
  }
  var isRoundOver: Bool {
    get {
      let playersWhoHaveNotGone: [Player] = players.filter { (player) -> Bool in
        return player.score == 0
      }
      return playersWhoHaveNotGone.count == 0
    }
  }
  
  init(withMessage message: MSMessage?, fromConversation convo: MSConversation) {
    if let msg = message, let url = msg.url {
      if let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false) {
        if let queryItems = components.queryItems {
          let tempPlayer = Player()
          for item in queryItems {
            if item.name.contains(PlayerItemNames.playerID.rawValue) {
              tempPlayer.setPlayer(id: item.value!)
            }
            if item.name == PlayerItemNames.score.rawValue {
              tempPlayer.setScore(to: Int(item.value!)!)
            }
            if item.name == PlayerItemNames.chips.rawValue {
              tempPlayer.setChips(to: Int(item.value!)!)
            }
            if item.name == PlayerItemNames.rollLimit.rawValue {
              tempPlayer.setRollLimit(to: Int(item.value!)!)
            }
            _players.append(tempPlayer)
            if item.name == GameItemNames.phase.rawValue {
              _currentPhase = Phase(rawValue: Int(item.value!)!)!
            }
            if item.name == GameItemNames.potSize.rawValue {
              _potOfChips = Int(item.value!)!
            }
          }
        }
      }
    } else {
      _currentPlayer = Player()
      _currentPlayer?.setPlayer(id: convo.localParticipantIdentifier.uuidString)
      _players.append(currentPlayer!)
      for (index, _) in convo.remoteParticipantIdentifiers.enumerated() {
        let player = Player()
        player.setPlayer(id: convo.remoteParticipantIdentifiers[index].uuidString)
        _players.append(player)
      }
      _potOfChips = players.count * 2
      _currentPhase = .one
    }
//    setCurrentPlayer(fromConversation: convo)
  }
  
//  func setCurrentPlayer(fromConversation convo: MSConversation) {
//    currentPlayer = players.first(where: { (player) -> Bool in
//      return player.playerID == convo.localParticipantIdentifier.uuidString
//    })!
//  }
  
  func isPhaseOver(phase: Phase) -> Bool {
    switch phase {
    case .one:
      return potOfChips == 0
    case .two:
      return currentPlayer?.chips == 0
    }
  }
  
  func isGameWon(byPlayer player: Player) -> Bool {
    return currentPhase == .two && player.chips == 0
  }
  
  func distributeChips(forPhase phase: Phase) {
    switch phase {
    case .one:
      addChipToLowestScore()
    case .two:
      subtractChipFromHighestScore()
    }
    
  }
  
  private func addChipToLowestScore() {
    var lowestScore = players.first?.score
    var lowestPlayer = players.first
    for player in players {
      if player.score < lowestScore! {
        lowestScore = player.score
        lowestPlayer = player
      }
    }
    lowestPlayer?.addChip()
    self.removeChipFromPot()
  }
  
  private func subtractChipFromHighestScore() {
    var highestScore = players.first?.score
    var highestPlayer = players.first
    for player in players {
      if player.score > highestScore! {
        highestScore = player.score
        highestPlayer = player
      }
    }
    highestPlayer?.removeChip()
    self.addChipToPot()
  }
  
  private func addChipToPot() {
    self._potOfChips = self._potOfChips + 1
  }
  
  private func removeChipFromPot() {
    self._potOfChips = self._potOfChips - 1
  }

}
