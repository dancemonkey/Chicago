//
//  PotDisplay.swift
//  Chicago
//
//  Created by Drew Lanning on 2/3/17.
//  Copyright © 2017 Drew Lanning. All rights reserved.
//

import UIKit

class PotDisplay: UIView {
    
  @IBOutlet weak var view: UIView!
  @IBOutlet weak var chipsInPot: UILabel!
  var totalChips: Int = 0 {
    didSet {
      chipsInPot.text = "Chips Left - \(totalChips)"
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    view = Bundle.main.loadNibNamed("PotDisplay", owner: self, options: nil)?[0] as! UIView
    self.addSubview(view)
    view.frame = self.bounds
  }
  
  func setChips(to count: Int) {
    totalChips = count
  }
  
  func removeChip() {
    totalChips = totalChips - 1
  }
  
  func addChip() {
    totalChips = totalChips + 1
  }
  
}
