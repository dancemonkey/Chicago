//
//  RollButton.swift
//  Chicago
//
//  Created by Drew Lanning on 2/3/17.
//  Copyright © 2017 Drew Lanning. All rights reserved.
//

import UIKit

enum RollButtonState {
  case roll, send, newRound
}

class RollButton: UIButton {
  
  var actionState: RollButtonState = .roll {
    didSet {
      switch actionState {
      case .roll:
        setTitle("ROLL", for: .normal)
      case .send:
        setTitle("SEND", for: .normal)
      case .newRound:
        setTitle("START NEXT ROUND", for: .normal)
      }
    }
  }
  
  func setRollCount(to count: Int, ofMax max: Int) {
    self.setTitle("Roll \(count) of \(max)", for: .normal)
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setTitle("ROLL", for: .normal)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
  }
  
  func set(state: RollButtonState) {
    self.actionState = state
  }

}
