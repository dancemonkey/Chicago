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
  case phase, potSize, numberOfPlayers
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
      print("found message and url")
      if let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false) {
        print("found components")
        if let queryItems = components.queryItems {
          print("found queryItems")
          
          let numberOfPlayers = Int((queryItems.first(where: { (item) -> Bool in
            return item.name == GameItemNames.numberOfPlayers.rawValue
          })?.value)!)
          
          for index in 0 ..< (numberOfPlayers!) {
            let tempPlayer = Player()
            for item in queryItems {
              if item.name == PlayerItemNames.playerID.rawValue + "\(index)" {
                tempPlayer.setPlayer(id: item.value!)
                print(convo.localParticipantIdentifier.uuidString)
                print(item.value!)
                if convo.localParticipantIdentifier.uuidString == item.value! {
                  _currentPlayer = tempPlayer
                }
              }
              if item.name == PlayerItemNames.score.rawValue + "\(index)" {
                tempPlayer.setScore(to: Int(item.value!)!)
              }
              if item.name == PlayerItemNames.chips.rawValue + "\(index)" {
                tempPlayer.setChips(to: Int(item.value!)!)
              }
              if item.name == PlayerItemNames.rollLimit.rawValue + "\(index)" {
                tempPlayer.setRollLimit(to: Int(item.value!)!)
              }
            }
            _players.append(tempPlayer)
          }
          
          for item in queryItems {
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
      // USING THESE IDs WILL NOT WORK, THEY AREN'T CONSISTENT BETWEEN LOCAL/REMOTE ACROSS DEVICES
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
  }
  
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
