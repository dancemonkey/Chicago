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
  
  typealias GameResultAction = (UIAlertAction) -> ()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    startGame()
    print("starting game state = \(game!.state)")
    
    guard game!.isCheating(player: currentUser!) == false else {
      disableAllButtons()
      return
    }
  }
  
  func startGame() {
    game = ChicagoModel(withMessage: message, fromConversation: conversation)
    currentPlayer = game!.currentPlayer
    initViewsForGame()
    
    if game!.state != .firstStart {
      if game!.state == .gameOver {
        showWinningResults()
      }
      if game!.state == .roundOver || game!.isPhaseOver(phase: game!.currentPhase) {
        if game!.isPhaseOver(phase: game!.currentPhase) {
          showPhaseEndPopup(forPhase: game!.currentPhase)
        }
        showResultsPopup(forRoundEnd: .currentPlayerLost(phase: game!.currentPhase), atStartup: true)
      }
      if game!.state == .loserStartedNewRound {
        showResultsPopup(forRoundEnd: .priorPlayerLost(), atStartup: true)
      }
    } else {
      game!.setState(state: .playing)
    }
    
  }
  
  func initViewsForGame() {
    guard let game = self.game else {
      print("where the fuck is the game?")
      return
    }
    setupPlayerDisplays()
    setCurrentPlayer()
    if game.currentPhase == .one {
      potDisplay.isHidden = false
      potDisplay.setChips(to: game.potOfChips)
    } else {
      potDisplay.isHidden = true
    }
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
  
  func showPhaseEndPopup(forPhase phase: Phase) {
    let message = Phase.message(phase)
    let title = Phase.title(phase)
    let phasePopup = UIAlertController(title: title(), message: message(), preferredStyle: .alert)
    let confirm = UIAlertAction(title: "Ok", style: .default, handler: nil)
    phasePopup.addAction(confirm)
    present(phasePopup, animated: true, completion: nil)
  }
  
  func startNewRound() {
    game!.startNewRound()
    if game!.isPhaseOver(phase: game!.currentPhase) {
      showPhaseEndPopup(forPhase: game!.currentPhase)
      game!.startNewPhase()
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
      } catch {
        print(error)
      }
      scorePlayer()
      if currentPlayer!.isTurnOver() {
        game!.setRollLimitForNextPlayer()
        game!.changeState()
        print(game!.state)
        rollBtn.set(state: .send)
        if game!.state == .roundOver {
          distributeChips()
          game!.changeState()
          if game!.isPhaseOver(phase: game!.currentPhase) {
            game!.startNewPhase()
            game!.changeState()
          }
          if game!.state == .gameOver {
            showWinningResults()
          } else {
            showRoundEndResults()
          }
        }
      }
    case .send:
      composeDelegate?.compose(fromGame: self.game!)
    // QUESTION: Are these cases even needed?
    case .newRound:
      print("new round stuff")
    case .newPhase:
      print("new phase stuff")
    }
  }
  
  func showRoundEndResults() {
    let winningPlayer = game!.getPlayerWhoWonRound()
    let endRoundMessage: RoundEndMessages
    disableAllButtons()
    if winningPlayer === currentPlayer! {
      endRoundMessage = RoundEndMessages.currentPlayerWon(phase: game!.currentPhase)
      game!.setState(state: .roundOver)
    } else {
      endRoundMessage = RoundEndMessages.currentPlayerLost(phase: game!.currentPhase)
      game!.setState(state: .loserStartedNewRound)
    }
    showResultsPopup(forRoundEnd: endRoundMessage, atStartup: false)
  }
  
  func showWinningResults() {
    let winningPlayer = game!.getPlayerWhoWonRound()
    disableAllButtons()
    showGameEndPopup(forWinner: winningPlayer)
  }
  
  func showGameEndPopup(forWinner winner: Player) {
    var message = ""
    var action: ((UIAlertAction) -> ())
    if winner === currentPlayer! {
      message = "You won!"
    } else {
      message = "You lost!"
    }
    if game!.otherPlayerSawGameEndResults {
      action = { action in
        self.message = nil
        self.startGame()
        self.enableAllButtons()
      }
    } else {
      action = { [unowned self] action in
        self.game!.otherPlayerSawGameEndResults = true
        self.composeDelegate?.compose(fromGame: self.game!)
      }
    }
    buildPopup(withMessage: message, title: "Game Over", action: action, actionTitle: "OK")
  }
  
  func showResultsPopup(forRoundEnd ending: RoundEndMessages, atStartup: Bool) {
    let endMessage = ending.message()
    let actionTitle = ending.action()
    let lostActionClosure: GameResultAction = { [unowned self] action in
      if atStartup {
        self.game!.setState(state: .playing)
      } else {
        self.game!.setState(state: .loserStartedNewRound)
      }
      self.startNewRound()
    }
    let wonActionClosure: GameResultAction = { [unowned self] action in
      self.game!.setState(state: .roundOver)
      self.composeDelegate?.compose(fromGame: self.game!)
    }
    let actionClosure: ((UIAlertAction) -> ())?
    if let action = ending.currentPlayerWonAction() {
      actionClosure = action ? wonActionClosure : lostActionClosure
    } else {
      actionClosure = { [unowned self] action in
//        self.game!.priorPlayerLost = false
      }
    }
    buildPopup(withMessage: endMessage!, title: "Round Over", action: actionClosure, actionTitle: actionTitle!)
  }
  
  func buildPopup(withMessage message: String, title: String, action: ((UIAlertAction) -> ())?, actionTitle: String) {
    let popup = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    let action = UIAlertAction(title: actionTitle, style: .default, handler: action)
    popup.addAction(action)
    present(popup, animated: true, completion: nil)
  }
  
  @IBAction func lockDie(sender: DieButton) {
    if currentPlayer!.didRoll {
      sender.locked = true
    }
  }
  
  @IBAction func tempDoneBtn(sender: UIButton) {
    game!.setRollLimitForNextPlayer()
    composeDelegate?.compose(fromGame: self.game!)
  }
  
}
