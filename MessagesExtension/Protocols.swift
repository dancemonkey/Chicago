//
//  Protocols.swift
//  Chicago
//
//  Created by Drew Lanning on 2/5/17.
//  Copyright © 2017 Drew Lanning. All rights reserved.
//

import Foundation
import Messages

protocol ExpandViewDelegate {
  func expand(toPresentationStyle presentationStyle: MSMessagesAppPresentationStyle)
  func getPresentationStyle() -> MSMessagesAppPresentationStyle
}
