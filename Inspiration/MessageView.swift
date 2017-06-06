//
//  MessageView.swift
//  Inspiration
//
//  Created by Konstantin Khokhlov on 24.05.17.
//  Copyright © 2017 Konstantin Khokhlov. All rights reserved.
//

import UIKit

class MessageView: UIView, Animating {

    // MARK: - Nested
    private struct Strings {
        static let onStart = (message: "The internet connection appears to be offline...", button: "Try again!")
        static let inWork = (message: "The internet connection appears to be offline...", button: " ")
    }

    // MARK: - Properties
    enum State {
        case onStart, inWork
    }

    // MARK: - Outlets
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var tryButton: UIButton!

    // MARK: - Methods

    /// Sets the message label and the button title texts.
    ///
    /// - Parameter strings: - A tuple of texts for the message label and the button title.
    private func configure(for strings: (message: String, button: String)) {
        messageLabel.text = strings.message
        tryButton.setTitle(strings.button, for: .normal)
    }

    /// Сonfigures texts for the current state.
    ///
    /// - Parameter state: - The current state.
    func configure(for state: State) {
        switch state {
        case .onStart:
            configure(for: Strings.onStart)
        case .inWork:
            configure(for: Strings.inWork)
        }
    }
}
