//
//  RollButton.swift
//  Chicago
//
//  Created by Drew Lanning on 2/3/17.
//  Copyright © 2017 Drew Lanning. All rights reserved.
//

import UIKit

class RollButton: UIButton {
  
  func setRollCount(to count: Int, ofMax max: Int) {
    self.setTitle("Roll \(count) of \(max)", for: .normal)
  }

}
