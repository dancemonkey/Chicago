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
  var endRoundMessage: RoundEndMessages?
  
  typealias GameResultAction = (UIAlertAction) -> ()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    game = ChicagoModel(withMessage: message, fromConversation: conversation)
    currentPlayer = game!.currentPlayer
    initViewsForGame()
    if game!.isCheating(player: currentUser!) {
      disableAllButtons()
      print("cheater")
    } else if game!.isRoundOver {
      showResultsPopup(forGameEnd: .currentPlayerLost(phase: game!.currentPhase))
    } else if game!.priorPlayerLost {
      showResultsPopup(forGameEnd: .priorPlayerLost())
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
      endRoundMessage = RoundEndMessages.currentPlayerWon(phase: game!.currentPhase)
      disableAllButtons()
      showResultsPopup(forGameEnd: endRoundMessage!)
    } else {
      endRoundMessage = RoundEndMessages.currentPlayerLost(phase: game!.currentPhase)
      disableAllButtons()
      showResultsPopup(forGameEnd: endRoundMessage!)
    }
  }
  
  func showResultsPopup(forGameEnd ending: RoundEndMessages) {
    let endMessage = ending.message()
    let actionTitle = ending.action()
    let lostActionClosure: GameResultAction = { [unowned self] action in
      self.startNewTurn()
      self.game!.priorPlayerLost = true
    }
    let wonActionClosure: GameResultAction = { [unowned self] action in
      self.composeDelegate?.compose(fromGame: self.game!)
    }
    let actionClosure: ((UIAlertAction) -> ())?
    if let action = ending.currentPlayerWonAction() {
      actionClosure = action ? wonActionClosure : lostActionClosure
    } else {
      actionClosure = { [unowned self] action in
        self.game!.priorPlayerLost = false
      }
    }
    
    let resultPopup = UIAlertController(title: "Turn Over", message: endMessage, preferredStyle: .actionSheet)
    let action = UIAlertAction(title: actionTitle, style: .default, handler: actionClosure)
    resultPopup.addAction(action)
    present(resultPopup, animated: true, completion: nil)
  }
  
  func startNewTurn() {
    game!.startNewRound()
    if game!.isPhaseOver(phase: game!.currentPhase) {
      game!.startNewPhase(phase: game!.currentPhase)
      // TODO: popup when starting new phase explaining the change in rules
      // TODO: remove pot from view in phase two
      initViewsForGame()
    }
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
      // QUESTION: Are these cases even needed?
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
