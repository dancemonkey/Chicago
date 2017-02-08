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
//  var showResultsAtStartup: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    game = ChicagoModel(withMessage: message, fromConversation: conversation)
    if game!.isCheating(player: currentUser!) {
      // TODO: INITIALIZE THE GAME BUT DISABLE ALL INTERACTION
      print("cheater")
    }
    currentPlayer = game!.currentPlayer
    initViewsForGame()
    if game!.isRoundOver {
      showResultsPopup(forGameEnd: .currentPlayerLost)
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
  
  func showRoundResults() {
    let winningPlayer = game!.getPlayerWhoWonRound()
    if winningPlayer === currentPlayer! {
      endGameMessage = .currentPlayerWon
      disableAllButtons()
      showResultsPopup(forGameEnd: endGameMessage!)
    } else {
      endGameMessage = .currentPlayerLost
      disableAllButtons()
      showResultsPopup(forGameEnd: endGameMessage!)
    }
  }
  
  func showResultsPopup(forGameEnd ending: GameEndMessage) {
    var endMessage: String = ""
    var actionTitle: String = ""
    var actionClosure: (UIAlertAction) -> ()
    switch ending {
    case .currentPlayerLost:
      endMessage = "you lost the round, you have to take a planet, you start the new round"
      actionTitle = "START NEW ROUND"
      actionClosure = { action in
        // need to somehow inform other player of results of round before they start their turn
        self.startNewTurn()
      }
    case .currentPlayerWon:
      endMessage = "you won the round, your opponent will get a planet and start the next round"
      actionTitle = "SEND TO OPPONENT"
      actionClosure = { action in
        self.composeDelegate?.compose(fromGame: self.game!)
        // need to create flag in VC to call startNewTurn when this package arrives
      }
    }
    let resultPopup = UIAlertController(title: "Turn Over", message: endMessage, preferredStyle: .actionSheet)
    let action = UIAlertAction(title: actionTitle, style: .default, handler: actionClosure)
    resultPopup.addAction(action)
    present(resultPopup, animated: true, completion: nil)
  }
  
  func startNewTurn() {
    game!.startNewRound()
    setupPlayerDisplays()
    rollBtn.set(state: .roll)
    for die in dieBtn {
      die.locked = false
    }
    enableAllButtons()
  }
  
  func disableAllButtons() {
    for view in view.subviews where view is UIButton {
      view.isUserInteractionEnabled = false
    }
  }
  
  func enableAllButtons() {
    for view in view.subviews where view is UIButton {
      view.isUserInteractionEnabled = true
    }
  }
  
  @IBAction func rollDice(sender: RollButton) {
    switch sender.actionState {
    case .roll:
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
    case .send:
      if game!.isRoundOver {
        distributeChips()
        showRoundResults()
      } else {
        composeDelegate?.compose(fromGame: self.game!)
      }
    case .newRound:
      print("new round stuff")
    }
  }
  
  @IBAction func lockDie(sender: DieButton) {
    if currentPlayer!.didRoll {
      sender.locked = true
    }
  }
  
}
