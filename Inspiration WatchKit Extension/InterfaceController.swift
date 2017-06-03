//
//  InterfaceController.swift
//  Inspiration WatchKit Extension
//
//  Created by Konstantin Khokhlov on 03.06.17.
//  Copyright © 2017 Konstantin Khokhlov. All rights reserved.
//

import WatchKit
import WatchConnectivity
import Foundation

class InterfaceController: WKInterfaceController, WCSessionDelegate {

    // MARK: - Outlets
    @IBOutlet private var quoteLabel: WKInterfaceLabel!

    // MARK: - WKInterfaceController
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        guard WCSession.isSupported() else { return }
        WCSession.default().delegate = self
        WCSession.default().activate()
    }

    // MARK: - WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            print("Communication is activated")
        }
    }

    // MARK: - iPhone Integration
    // MARK: Get data
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async { [weak self] in
            guard let text = userInfo["content"] as? String else { return }
            self?.quoteLabel.setText(text)
        }
    }
    // MARK: Send data
    @IBAction private func newQuoteButtonPressed() {
        guard WCSession.default().activationState == .activated else { return }
        guard WCSession.default().isReachable else { return }
        let message = ["message": "update"]
        WCSession.default().sendMessage(message, replyHandler: nil)
    }
}
