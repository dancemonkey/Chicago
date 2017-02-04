//
//  DieButton.swift
//  Chicago
//
//  Created by Drew Lanning on 2/3/17.
//  Copyright © 2017 Drew Lanning. All rights reserved.
//

import UIKit

class DieButton: UIButton {
  
  func setFace(toValue value: Int) {
    self.setTitle("\(value)", for: .normal)
  }
  
}
