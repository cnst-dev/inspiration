//
//  MainViewController.swift
//  Inspiration
//
//  Created by Konstantin Khokhlov on 08.05.17.
//  Copyright © 2017 Konstantin Khokhlov. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var contentTextView: UITextView!

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        getQuote()
    }

    // MARK: - Actions
    @IBAction private func buttonPressed(_ sender: UIButton) {
        getQuote()
    }

    // MARK: Quotes
    private func getQuote() {
        guard let url = Constants.quotesURL else { return }
        Quote.getQuote(from: url) { [weak self] (quote) in
            DispatchQueue.main.async {
                self?.contentTextView.setHTMLText(quote.content)
            }
        }
    }

}
