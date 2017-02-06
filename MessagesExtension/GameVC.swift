//
//  GameVC.swift
//  Chicago
//
//  Created by Drew Lanning on 2/4/17.
//  Copyright © 2017 Drew Lanning. All rights reserved.
//

import UIKit
import Messages

class GameVC: UIViewController {
  
  @IBOutlet var dieBtn: [DieButton]!
  @IBOutlet var playerDisplay: [PlayerDisplay]!
  @IBOutlet weak var potDisplay: PotDisplay!
  @IBOutlet weak var rollBtn: RollButton!
  @IBOutlet weak var phaseDisplay: PhaseDisplay!
  
  var game: ChicagoModel?
  var currentPlayer: Player?
  var currentPlayerDisplay: PlayerDisplay?
  weak var message: MSMessage?
  weak var conversation: MSConversation!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    game = ChicagoModel(withMessage: message, fromConversation: conversation)
    currentPlayer = game!.currentPlayer
    initViewsForGame()
  }
  
  func initViewsForGame() {
    guard let game = self.game else {
      print("where the fuck is the game?")
      return
    }
    sortPlayerDisplays()
    potDisplay.setChips(to: game.potOfChips)
    phaseDisplay.setPhase(to: game.currentPhase)
  }
  
  private func sortPlayerDisplays() {
    for (index, player) in game!.players.enumerated() {
      playerDisplay[index].isHidden = false
      playerDisplay[index].setupDisplay(forPlayer: player, order: index, score: player.score)
      playerDisplay[index].setID(to: player.playerID)
    }
    currentPlayerDisplay = playerDisplay.first(where: { (display) -> Bool in
      display.playerID == currentPlayer?.playerID
    })
  }
  
  func scorePlayer() {
    var total = 0
    for die in dieBtn {
      total = total + die.die.score
    }
    currentPlayer?.setScore(to: total)
    currentPlayerDisplay?.setScore(to: total)
  }
  
  @IBAction func rollDice(sender: UIButton) {
    if currentPlayer?.isTurnOver() == false {
      do {
        try currentPlayer?.makeMove(.roll)
        for die in dieBtn where die.locked == false {
          die.setFace(toValue: die.die.roll(withModifier: 0))
        }
        scorePlayer()
        if currentPlayer!.isTurnOver() {
          rollBtn.set(state: .send)
          // TESTING END OF ROUND
          game!.distributeChips(forPhase: game!.currentPhase)
          potDisplay.setChips(to: game!.potOfChips)
//          if game!.isRoundOver {
//            game!.distributeChips(forPhase: game!.currentPhase)
//          }
        }
      } catch {
        print(error)
      }
    }
  }
  
  @IBAction func lockDie(sender: UIButton) {
    
  }
  
}
