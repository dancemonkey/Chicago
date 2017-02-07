//
//  PhaseDisplay.swift
//  Chicago
//
//  Created by Drew Lanning on 2/3/17.
//  Copyright © 2017 Drew Lanning. All rights reserved.
//

import UIKit

class PhaseDisplay: UIView {
  
  @IBOutlet weak var view: UIView!
  @IBOutlet weak var phaseNumber: UILabel!
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    view = Bundle.main.loadNibNamed("PhaseDisplay", owner: self, options: nil)?[0] as! UIView
    self.addSubview(view)
    view.frame = self.bounds
  }

  func setPhase(to phase: Phase) {
    phaseNumber.text = "Phase \(phase)"
  }

}
