//
//  GameVC.swift
//  Chicago
//
//  Created by Drew Lanning on 2/4/17.
//  Copyright © 2017 Drew Lanning. All rights reserved.
//

import UIKit
import Messages

enum GameEndMessage: String {
  case currentPlayerWon, currentPlayerLost
}

class GameVC: UIViewController {
  
  @IBOutlet var dieBtn: [DieButton]!
  @IBOutlet var playerDisplay: [PlayerDisplay]!
  @IBOutlet weak var potDisplay: PotDisplay!
  @IBOutlet weak var rollBtn: RollButton!
  @IBOutlet weak var phaseDisplay: PhaseDisplay!
  
  var game: ChicagoModel?
  var currentPlayer: Player?
  var currentPlayerDisplay: PlayerDisplay?
  var currentUser: String?
  weak var message: MSMessage?
  weak var conversation: MSConversation!
  var composeDelegate: ComposeMessageDelegate?
  var endGameMessage: GameEndMessage?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    game = ChicagoModel(withMessage: message, fromConversation: conversation)
    currentPlayer = game!.currentPlayer
    initViewsForGame()
    if game!.isCheating(player: currentUser!) {
      // TODO: INITIALIZE THE GAME BUT DISABLE ALL INTERACTION
      print("cheater")
    }
  }
  
  func initViewsForGame() {
    guard let game = self.game else {
      print("where the fuck is the game?")
      return
    }
    setupPlayerDisplays()
    setCurrentPlayer()
    potDisplay.setChips(to: game.potOfChips)
    phaseDisplay.setPhase(to: game.currentPhase)
  }
  
  private func setupPlayerDisplays() {
    for (index, player) in game!.players.enumerated() {
      playerDisplay[index].isHidden = false
      playerDisplay[index].setupDisplay(forPlayer: player, order: index, score: player.score)
      playerDisplay[index].setID(to: player.playerID)
    }
  }
  
  func setCurrentPlayer() {
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
  
  func distributeChips() {
    game!.distributeChips(forPhase: game!.currentPhase)
    potDisplay.setChips(to: game!.potOfChips)
    setupPlayerDisplays()
  }
  
  func resetForNextRound() {
    defer {
      game!.resetPlayerScores()
    }
    let winningPlayer = game!.getPlayerWhoWonRound()
    if winningPlayer === currentPlayer! {
      endGameMessage = .currentPlayerWon
      showResults(forGameEnd: endGameMessage!)
      // show results popup, with button to start new turn
      // disable main button
      startNewTurn()
    } else {
      endGameMessage = .currentPlayerLost
      showResults(forGameEnd: endGameMessage!)
      // show results pop-up with button to send message
      // disable main button
      // composeDelegate?.compose(fromGame: self.game!)
    }
  }
  
  func startNewTurn() {
    print("starting new turn, not sending")
  }
  
  func showResults(forGameEnd ending: GameEndMessage) {
    var endMessage: String = ""
    var actionTitle: String = ""
    var actionClosure: (UIAlertAction) -> ()
    switch ending {
    case .currentPlayerLost:
      endMessage = "you lost the round, you have to take a planet"
      actionTitle = "START NEW ROUND"
      actionClosure = { action in
        print("current player lost")
      }
    case .currentPlayerWon:
      endMessage = "you won the round, your opponent will get a planet"
      actionTitle = "SEND TO OPPONENT"
      actionClosure = { action in
        print("current player won")
      }
    }
    let resultPopup = UIAlertController(title: "Turn Over", message: endMessage, preferredStyle: .actionSheet)
    let action = UIAlertAction(title: actionTitle, style: .default, handler: actionClosure)
    resultPopup.addAction(action)
    present(resultPopup, animated: true, completion: nil)
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
        }
      } catch {
        print(error)
      }
    } else {
      if game!.isRoundOver {
        distributeChips()
        resetForNextRound()
      } else {
        composeDelegate?.compose(fromGame: self.game!)
      }
    }
  }
  
  @IBAction func lockDie(sender: DieButton) {
    if currentPlayer!.didRoll {
      sender.locked = true
    }
  }
  
}
