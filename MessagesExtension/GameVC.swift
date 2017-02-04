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
  @IBOutlet weak var rollbtn: RollButton!
  @IBOutlet weak var phaseDisplay: PhaseDisplay!
  
  weak var game: ChicagoModel?
  weak var message: MSMessage?
  weak var conversation: MSConversation!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    game = ChicagoModel(withMessage: message, fromConversation: conversation)
  }
  
  func initViewsForGame() {
    guard let game = game else {
      fatalError()
    }
    for (index, player) in game.players.enumerated() {
      
    }
  }
  
  private func sortPlayerDisplays() {
    for player in playerDisplay {
      // sort playerDisplays before trying to activate them based on number of players
    }
  }
  
}