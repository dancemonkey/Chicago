//
//  ChicagoModel.swift
//  Chicago
//
//  Created by Drew Lanning on 2/3/17.
//  Copyright © 2017 Drew Lanning. All rights reserved.
//

import Foundation
import Messages

enum ValidMoves: String {
  case roll, setAside
}

enum Phase: Int {
  case one = 1, two
}

class ChicagoModel {
  private var players: [Player]
  private var currentPlayer: Player
  private var currentPhase: Phase
  private var dice: [D6] = [D6(), D6(), D6()]
  private var potOfChips: Int
  private let validMoves: [ValidMoves] = [.roll, .roll, .roll, .setAside]
  private var turnOver: Bool {
    return currentPlayer.availableMoves.count == 0
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
    if let msg = message {
      // set up game from parse Message
    } else {
      players = [Player]()
      for (index, player) in convo.remoteParticipantIdentifiers.enumerated() {
        let player = Player()
        player.setPlayer(id: convo.remoteParticipantIdentifiers[index].uuidString)
        players.append(player)
      }
      currentPlayer = players.first(where: { (player) -> Bool in
        return player.playerID == convo.localParticipantIdentifier.uuidString
      })!
      potOfChips = players.count * 2
      currentPhase = .one
    }
    // parse message here and populate game values
  }
  
  func isPhaseOver(phase: Phase) -> Bool {
    switch phase {
    case .one:
      return potOfChips == 0
    case .two:
      return currentPlayer.chips == 0
    }
  }
  
  func isGameWon(byPlayer player: Player) -> Bool {
    return currentPhase == .two && player.chips == 0
  }
}
