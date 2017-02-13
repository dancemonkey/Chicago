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
  case phase, potSize, numberOfPlayers, currentPlayer, nextPlayer, lastUserToOpen, otherPlayerSawGameEndResults, state
}

enum GameState: String {
  case roundOver, gameOver, playing, firstStart, loserStartedNewRound
}

enum Phase: Int {
  case one = 1, two, end
  
  func message() -> String? {
    switch self {
    case .one:
      return "The winner of each round now gets to destroy one of their planets."
    case .two:
      return nil
    case .end:
      return nil
    }
  }
  
  func title() -> String? {
    switch self {
    case .one:
      return "Phase 1 is over!"
    case .two:
      return "Game over!"
    case.end:
      return nil
    }
  }
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
  private var _state: GameState = .firstStart
  var state: GameState {
    return _state
  }
  private var isRoundOver: Bool {
    get {
      let playersWhoHaveNotGone: [Player] = players.filter { (player) -> Bool in
        return player.score == 0
      }
      return playersWhoHaveNotGone.count == 0
    }
  }
  var priorPlayerLost: Bool = false
  var otherPlayerSawGameEndResults: Bool = false
  var firstStart: Bool = false
  
  init(withMessage message: MSMessage?, fromConversation convo: MSConversation) {
    if let msg = message, let url = msg.url {
      if let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false) {
        if let queryItems = components.queryItems {
          
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
            }
            if item.name == GameItemNames.state.rawValue {
              _state = GameState(rawValue: item.value!)!
            }
            if item.name == GameItemNames.otherPlayerSawGameEndResults.rawValue {
              otherPlayerSawGameEndResults = Bool(item.value!)!
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
      _state = .firstStart
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
      return false
    }
  }
  
  func startNewPhase() {
    switch currentPhase {
    case .one:
      self._currentPhase = .two
    case .two:
      self._currentPhase = .end
    case .end:
      self._currentPhase = .one
    }
    changeState()
  }
  
  func isGameWon(byPlayer player: Player) -> Bool {
    return currentPhase == .two && player.chips == 0
  }
  
  private func isGameOver() -> Bool {
    guard currentPhase == .two || currentPhase == .end else {
      return false
    }
    for player in players {
      return player.chips == 0
    }
    return false
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
  
  func setState(state: GameState) {
    self._state = state
  }
  
  func setRollLimitForNextPlayer() {
    let rollLimit = isRoundOver ? 3 : currentPlayer!.totalRolls
    _nextPlayer?.setRollLimit(to: rollLimit)
  }
  
  func changeState() {
    if isGameOver() {
      _state = .gameOver
    } else if isRoundOver {
      _state = .roundOver
    }
    print("\(#function) changed state to \(_state)")
  }
  
}
