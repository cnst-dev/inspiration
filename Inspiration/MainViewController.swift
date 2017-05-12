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
            contentTextView.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(getQuote))
            )
        }
    }
    @IBOutlet private weak var imageView: UIImageView! {
        didSet {
            imageView.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(getBackground))
            )
        }
    }
    @IBOutlet private weak var buttonsStack: UIStackView!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        getQuote()
        getBackground()
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(share))
        swipeRecognizer.direction = .up
        view.addGestureRecognizer(swipeRecognizer)
    }

    // MARK: - Actions
    @IBAction func infoButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Instruction",
            message: "\n Swipe up for sharing.\n \n Tap the image to update.\n \n Tap the quote to update.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: API integration
    func getQuote() {
        print("q")
        view.isUserInteractionEnabled = false
        spinner.startAnimating()
        guard let url = Constants.quotesURL else { return }
        Quote.getQuote(from: url) { [weak self] (quote) in
            DispatchQueue.main.async {
                self?.contentTextView.text = quote.content
                self?.titleLabel.text = "- \(quote.title)"
                self?.contentTextView.sizeToFit()
                self?.spinner.stopAnimating()
                self?.view.isUserInteractionEnabled = true
            }
        }
    }

    func getBackground() {
        guard let url = Constants.imagesURL else { return }
        spinner.startAnimating()
        view.isUserInteractionEnabled = false
        Background.getImage(from: url) { [weak self] (backround) in
            DispatchQueue.main.async {
                self?.imageView.image = backround.image
                self?.spinner.stopAnimating()
                self?.view.isUserInteractionEnabled = true
            }
        }
    }

    // MARK: - Methods
    private func makeScreenShot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        view.layer.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return image
    }

    func share() {
        buttonsStack.isHidden = true
        guard let image = makeScreenShot() else { return }
        buttonsStack.isHidden = false
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view
        present(activityViewController, animated: true, completion: nil)
    }
}
