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
  case phase, potSize, numberOfPlayers, currentPlayer, nextPlayer, lastUserToOpen, showRoundResults
}

enum Phase: Int {
  case one = 1, two, end
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
  private var _nextPlayer: Player? = nil
  var nextPlayer: Player? {
    return _nextPlayer
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
  private var _lastUserToOpen: String? = nil
  var lastUserToOpen: String? {
    return _lastUserToOpen
  }
  var isRoundOver: Bool {
    get {
      let playersWhoHaveNotGone: [Player] = players.filter { (player) -> Bool in
        return player.score == 0
      }
      return playersWhoHaveNotGone.count == 0
    }
  }
  var priorPlayerLost: Bool = false
  
  init(withMessage message: MSMessage?, fromConversation convo: MSConversation) {
    if let msg = message, let url = msg.url {
      print("found message and url")
      if let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false) {
        print("found components")
        if let queryItems = components.queryItems {
          print("found queryItems")
          
          for item in queryItems {
            if item.name == GameItemNames.phase.rawValue {
              _currentPhase = Phase(rawValue: Int(item.value!)!)!
            }
            if item.name == GameItemNames.potSize.rawValue {
              _potOfChips = Int(item.value!)!
            }
            if item.name == GameItemNames.currentPlayer.rawValue {
              _currentPlayer = parsePlayer(fromItem: item.value!)
            }
            if item.name == GameItemNames.nextPlayer.rawValue {
              _nextPlayer = parsePlayer(fromItem: item.value!)
            }
            if item.name == GameItemNames.lastUserToOpen.rawValue {
              _lastUserToOpen = item.value!
              print("last user to open as parsed from game model \(lastUserToOpen)")
            }
          }
          
          _players.append(currentPlayer!)
          _players.append(nextPlayer!)

        }
      }
    } else {
      _currentPlayer = Player()
      _currentPlayer?.setPlayer(id: convo.localParticipantIdentifier.uuidString)
      _players.append(currentPlayer!)
      _nextPlayer = Player()
      _nextPlayer?.setPlayer(id: "NIL")
      _players.append(_nextPlayer!)
      _potOfChips = players.count * 2
      _currentPhase = .one
    }
  }
  
  private func parsePlayer(fromItem item: String) -> Player {
    let player = Player()
    let delineator = "*-*-*"
    let playerDetails = item.components(separatedBy: delineator)
    player.setPlayer(id: playerDetails[0])
    player.setScore(to: Int(playerDetails[1])!)
    player.setChips(to: Int(playerDetails[2])!)
    player.setRollLimit(to: Int(playerDetails[3])!)
    return player
  }
  
  func assignIdIfNeeded(forPlayer player: Player, fromConversation convo: MSConversation) {
    if player.playerID == "NIL" {
      player.setPlayer(id: convo.localParticipantIdentifier.uuidString)
    }
  }
  
  func isPhaseOver(phase: Phase) -> Bool {
    switch phase {
    case .one:
      return potOfChips == 0
    case .two:
      return currentPlayer?.chips == 0
    case .end:
      return true
    }
  }
  
  func startNewPhase(phase: Phase) {
    switch phase {
    case .one:
      self._currentPhase = .two
    case .two:
      self._currentPhase = .end
    case .end:
      self._currentPhase = .one
    }
  }
  
  func isGameWon(byPlayer player: Player) -> Bool {
    return currentPhase == .two && player.chips == 0
  }
  
  func getPlayerWhoWonRound() -> Player {
    var baseScore = players[0].score
    var winningPlayer = players[0]
    for player in players {
      if player.score >= baseScore {
        baseScore = player.score
        winningPlayer = player
      }
    }
    return winningPlayer
  }
  
  func distributeChips(forPhase phase: Phase) {
    switch phase {
    case .one:
      addChipToLowestScore()
    case .two:
      subtractChipFromHighestScore()
    case .end:
      break
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
  
  func isCheating(player: String) -> Bool {
    if let last = lastUserToOpen {
      return last == player
    } else {
      return false
    }
  }
  
  func startNewRound() {
    resetPlayerScores()
    for player in players {
      player.setRollLimit(to: 3)
    }
  }
  
  private func resetPlayerScores() {
    for player in players {
      player.setScore(to: 0)
    }
  }

}
