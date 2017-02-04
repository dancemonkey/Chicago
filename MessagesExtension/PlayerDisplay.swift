//
//  PlayerDisplay.swift
//  Chicago
//
//  Created by Drew Lanning on 2/3/17.
//  Copyright © 2017 Drew Lanning. All rights reserved.
//

import UIKit

class PlayerDisplay: UIView {
  
  @IBOutlet weak var playerNumber: UILabel!
  @IBOutlet weak var chipCount: UILabel!
  
  func setChips(to count: Int) {
    chipCount.text = "Chips - \(count)"
  }
  
  func setPlayer(number: Int) {
    playerNumber.text = "Player \(number)"
  }
  
}
