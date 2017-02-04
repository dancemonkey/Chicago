//
//  PotDisplay.swift
//  Chicago
//
//  Created by Drew Lanning on 2/3/17.
//  Copyright © 2017 Drew Lanning. All rights reserved.
//

import UIKit

class PotDisplay: UIView {
  
  @IBOutlet weak var chipsInPot: UILabel!
  
  func setChips(to count: Int) {
    chipsInPot.text = "Chips Left - \(count)"
  }
  
}
