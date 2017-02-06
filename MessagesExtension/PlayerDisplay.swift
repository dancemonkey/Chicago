//
//  PlayerDisplay.swift
//  Chicago
//
//  Created by Drew Lanning on 2/3/17.
//  Copyright © 2017 Drew Lanning. All rights reserved.
//

import UIKit

class PlayerDisplay: UIView {
  
  @IBOutlet weak var view: UIView!
  @IBOutlet weak var playerNumber: UILabel!
  @IBOutlet weak var chipCount: UILabel!
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    view = Bundle.main.loadNibNamed("PlayerDisplay", owner: self, options: nil)?[0] as! UIView
    self.addSubview(view)
    view.frame = self.bounds
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  private func setChips(to count: Int) {
    chipCount.text = "Chips - \(count)"
  }
  
  private func setPlayer(number: Int) {
    playerNumber.text = "Player \(number + 1)"
  }
  
  func setupDisplay(forPlayer player: Player, order: Int) {
    setChips(to: player.chips)
    setPlayer(number: order)
  }
  
}
