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
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentTextView: UITextView!
    @IBOutlet private weak var imageView: UIImageView!

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        getQuote()
        getBackground()
    }

    // MARK: - Actions
    @IBAction private func buttonPressed(_ sender: UIButton) {
        getQuote()
        getBackground()
    }

    // MARK: API integration
    private func getQuote() {
        guard let url = Constants.quotesURL else { return }
        Quote.getQuote(from: url) { [weak self] (quote) in
            DispatchQueue.main.async {
                self?.contentTextView.text = quote.content
                self?.titleLabel.text = "- \(quote.title)"
            }
        }
    }

    func getBackground() {
        guard let url = Constants.imagesURL else { return }
        Background.getImage(from: url) { [weak self] (backround) in
            DispatchQueue.main.async {
                self?.imageView.image = backround.image
            }
        }
    }
}
