//
//  DieButton.swift
//  Chicago
//
//  Created by Drew Lanning on 2/3/17.
//  Copyright © 2017 Drew Lanning. All rights reserved.
//

import UIKit

class DieButton: UIButton {
    
  var die: D6 = D6()
  
  var locked: Bool = false {
    didSet {
      if locked {
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 1.0
      } else {
        layer.borderColor = UIColor.clear.cgColor
      }
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setFace(toValue: 1)
  }
  
  func setFace(toValue value: Int) {
    self.setTitle("\(value)", for: .normal)
  }
  
  func lock() {
    self.locked = true
  }
  
  func unLock() {
    self.locked = false
  }
  
}
