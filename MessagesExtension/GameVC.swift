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
  var currentUser: String?
  weak var message: MSMessage?
  weak var conversation: MSConversation!
  var composeDelegate: ComposeMessageDelegate?
  var endGameMessage: GameEndMessages?
  
  typealias GameResultAction = (UIAlertAction) -> ()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    game = ChicagoModel(withMessage: message, fromConversation: conversation)
    currentPlayer = game!.currentPlayer
    initViewsForGame()
    if game!.isCheating(player: currentUser!) {
      disableAllButtons()
      print("cheater")
    }
    if game!.isRoundOver && game!.isCheating(player: currentUser!) == false {
      showResultsPopup(forGameEnd: .currentPlayerLost(phase: game!.currentPhase))
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
      endGameMessage = GameEndMessages.currentPlayerWon(phase: game!.currentPhase)
      disableAllButtons()
      showResultsPopup(forGameEnd: endGameMessage!)
    } else {
      endGameMessage = GameEndMessages.currentPlayerLost(phase: game!.currentPhase)
      disableAllButtons()
      showResultsPopup(forGameEnd: endGameMessage!)
    }
  }
  
  func showResultsPopup(forGameEnd ending: GameEndMessages) {
    // TODO: need to show result to opponent when current player loses and starts new round
    let endMessage = ending.message()
    let actionTitle = ending.action()
    let lostActionClosure: GameResultAction = { [unowned self] action in
      self.startNewTurn()
    }
    let wonActionClosure: GameResultAction = { [unowned self] action in
      self.composeDelegate?.compose(fromGame: self.game!)
    }
    let actionClosure = ending.currentPlayerWonAction() ? wonActionClosure : lostActionClosure
    
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
      if game!.isPhaseOver(phase: game!.currentPhase) {
        game!.startNewPhase(phase: game!.currentPhase)
        initViewsForGame()
      }
    case .newRound:
      print("new round stuff")
    case .newPhase:
      print("new phase stuff")
    }
  }
  
  @IBAction func lockDie(sender: DieButton) {
    if currentPlayer!.didRoll {
      sender.locked = true
    }
  }
  
}
