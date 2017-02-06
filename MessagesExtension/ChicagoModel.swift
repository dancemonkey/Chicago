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
  private var currentPlayer: Player? = nil
  private var currentPhase: Phase = .one
  private var dice: [D6] = [D6(), D6(), D6()]
  private var potOfChips: Int = 0
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
              currentPhase = Phase(rawValue: Int(item.value!)!)!
            }
            if item.name == GameItemNames.potSize.rawValue {
              potOfChips = Int(item.value!)!
            }
          }
        }
      }
    } else {
      for (index, _) in convo.remoteParticipantIdentifiers.enumerated() {
        let player = Player()
        player.setPlayer(id: convo.remoteParticipantIdentifiers[index].uuidString)
        _players.append(player)
      }
      currentPlayer = Player()
      currentPlayer?.setPlayer(id: convo.localParticipantIdentifier.uuidString)
      _players.append(currentPlayer!)
      potOfChips = players.count * 2
      currentPhase = .one
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
}
