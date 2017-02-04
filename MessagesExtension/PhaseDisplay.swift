//
//  PhaseDisplay.swift
//  Chicago
//
//  Created by Drew Lanning on 2/3/17.
//  Copyright © 2017 Drew Lanning. All rights reserved.
//

import UIKit

class PhaseDisplay: UIView {
  
  @IBOutlet weak var phaseNumber: UILabel!

  func setPhase(to phase: Phase) {
    phaseNumber.text = "Phase \(phase)"
  }

}
