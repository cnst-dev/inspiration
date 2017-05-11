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
    @IBOutlet private weak var contentTextView: UITextView! {
        didSet {
            contentTextView.translatesAutoresizingMaskIntoConstraints = true
            contentTextView.isScrollEnabled = false
        }
    }
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var buttonsStack: UIStackView!

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        getQuote()
        getBackground()
    }

    // MARK: - Actions
    @IBAction private func newQuotebuttonPressed(_ sender: UIButton) {
        getQuote()
        getBackground()
    }

    @IBAction private func shareButtonPressed(_ sender: UIButton) {
        buttonsStack.isHidden = true
        guard let image = makeScreenShot() else { return }
        buttonsStack.isHidden = false
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view
        present(activityViewController, animated: true, completion: nil)
    }

    // MARK: API integration
    private func getQuote() {
        guard let url = Constants.quotesURL else { return }
        Quote.getQuote(from: url) { [weak self] (quote) in
            DispatchQueue.main.async {
                self?.contentTextView.text = quote.content
                self?.titleLabel.text = "- \(quote.title)"
                self?.contentTextView.sizeToFit()
            }
        }
    }

    private func getBackground() {
        guard let url = Constants.imagesURL else { return }
        Background.getImage(from: url) { [weak self] (backround) in
            DispatchQueue.main.async {
                self?.imageView.image = backround.image
            }
        }
    }

    // MARK: - Methods
    func makeScreenShot() -> UIImage? {
        UIGraphicsBeginImageContext(view.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        view.layer.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return image
    }
}
