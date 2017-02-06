//
//  CompactVC.swift
//  Chicago
//
//  Created by Drew Lanning on 2/4/17.
//  Copyright © 2017 Drew Lanning. All rights reserved.
//

import UIKit

class CompactVC: UIViewController {
  
  var delegate: ExpandViewDelegate? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func loadGame() {
    delegate?.expand(toPresentationStyle: .expanded)
  }
}
