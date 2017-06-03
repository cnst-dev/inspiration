//
//  MainViewController.swift
//  Inspiration
//
//  Created by Konstantin Khokhlov on 08.05.17.
//  Copyright © 2017 Konstantin Khokhlov. All rights reserved.
//

import UIKit
import WatchConnectivity

class MainViewController: UIViewController, WCSessionDelegate {

    // MARK: - Nested
    private struct Strings {
        static let info = (title: "Instruction",
                           message: "\n Swipe up for sharing.\n \n Tap the image to update.\n \n Tap the quote to update.",
                           button: "OK"
        )
    }

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
    @IBOutlet private weak var messageView: MessageView!
    @IBOutlet private weak var buttonsStack: UIStackView!
    @IBOutlet private weak var quotesStack: UIStackView!

    @IBOutlet private weak var spinner: UIActivityIndicatorView!

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(share))
        swipeRecognizer.direction = .up
        view.addGestureRecognizer(swipeRecognizer)

        guard Reachability.isConnectedToNetwork() else { return }

        getBackground()
        getQuote()
        messageView.configure(for: .onStart)
        messageView.animateAlpha(duration: 2.0)

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

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Communication is inactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default().activate()
    }

    // MARK: - Actions
    @IBAction private func infoButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(
            title: Strings.info.title,
            message: Strings.info.message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Strings.info.button, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @IBAction private func tryButtonPressed(_ sender: UIButton) {
        guard Reachability.isConnectedToNetwork() else { return }

        getBackground()
        getQuote()
        messageView.animateAlpha(duration: 2.0)
    }

    // MARK: API integration
    func getQuote() {
        guard Reachability.isConnectedToNetwork() else {
            messageView.configure(for: .inWork)
            messageView.animateAlpha(duration: 2.0)
            return
        }
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
            self?.sendToWatch(quote: quote)
        }
    }

    func getBackground() {
        guard Reachability.isConnectedToNetwork() else {
            messageView.configure(for: .inWork)
            messageView.animateAlpha(duration: 2.0)
            return
        }
        guard let url = Constants.imagesURL else { return }
        spinner.startAnimating()
        view.isUserInteractionEnabled = false
        Background.getImage(from: url) { [weak self] (backround) in
            DispatchQueue.main.async {
                self?.imageView.image = backround.image
                self?.spinner.stopAnimating()
                self?.view.isUserInteractionEnabled = true
                self?.quotesStack.isHidden = false
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

    // MARK: - Watch Integration
    // MARK: Get data
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async { [weak self] in
            self?.getQuote()
        }
    }

    // MARK: - Send data
    private func sendToWatch(quote: Quote) {
        guard WCSession.default().activationState == .activated else { return }
        let content = ["content": quote.content]
        WCSession.default().transferUserInfo(content)
    }
}
