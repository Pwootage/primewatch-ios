//
//  InterfaceController.swift
//  primewatch-watch Extension
//
//  Created by Christopher Freestone on 12/18/16.
//  Copyright © 2016 Christopher Freestone. All rights reserved.
//

import WatchKit
import WatchConnectivity
import Foundation

class InterfaceController: WKInterfaceController, WCSessionDelegate {
  @IBOutlet var timeLabel: WKInterfaceLabel!
  var wcSession: WCSession? = nil

  override func awake(withContext context: Any?) {
    super.awake(withContext: context)

  }

  override func willActivate() {
    super.willActivate()

    if WCSession.isSupported() && wcSession == nil {
      wcSession = WCSession.default()
      wcSession!.delegate = self
    }
    if wcSession != nil && wcSession!.activationState != .activated {
      wcSession!.activate()
    }
  }

  override func didDeactivate() {
    super.didDeactivate()
  }

  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    print("Session is active")
  }

  func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
    print(message)
    let time = message["time"] ?? "???"
    timeLabel.setText("\(time)")
  }


}
