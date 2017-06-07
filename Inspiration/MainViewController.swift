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
                           message: "\n Swipe up or tap the button for sharing.\n \n Tap the image to update.\n \n Tap the quote to update.",
                           button: "OK"
        )
    }

    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabelPadding! {
        didSet {
            contentLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(getQuote)))
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
        messageView.hideAnimation(duration: 2.0)

        guard WCSession.isSupported() else { return }
        WCSession.default().delegate = self
        WCSession.default().activate()
    }

    // MARK: - Actions
    /// Presents the alert view.
    ///
    /// - Parameter sender: - The button from the Main.storyboard.
    @IBAction private func helpButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(
            title: Strings.info.title,
            message: Strings.info.message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Strings.info.button, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    /// Presents the share view.
    ///
    /// - Parameter sender: The bar button item from the Main.storyboard.
    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
        share()
    }

    /// Requests a quote and an image on the message view if the app is connected to the Internet.
    ///
    /// - Parameter sender: - The button from the Main.storyboard.
    @IBAction private func tryButtonPressed(_ sender: UIButton) {
        guard Reachability.isConnectedToNetwork() else { return }

        getBackground()
        getQuote()
        messageView.hideAnimation(duration: 2.0)
    }

    // MARK: API integration
    /// Requests a quoute if the app is connected to the Internet. Sends quote to the Watch app.
    func getQuote() {
        guard Reachability.isConnectedToNetwork() else {
            messageView.configure(for: .inWork)
            messageView.hideAnimation(duration: 2.0)
            return
        }
        view.isUserInteractionEnabled = false
        spinner.startAnimating()
        guard let url = Constants.quotesURL else { return }
        Quote.getQuote(from: url) { [weak self] (quote) in
            DispatchQueue.main.async {
                self?.contentLabel.text = quote.content
                self?.titleLabel.text = "- \(quote.title)"
                self?.contentLabel.sizeToFit()
                self?.spinner.stopAnimating()
                self?.view.isUserInteractionEnabled = true
            }
            self?.sendToWatch(quote: quote)
        }
    }

    /// Requests an image if the app is connected to the Internet.
    func getBackground() {
        guard Reachability.isConnectedToNetwork() else {
            messageView.configure(for: .inWork)
            messageView.hideAnimation(duration: 2.0)
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
    /// Makes a screenshot from the current context.
    ///
    /// - Returns: A screenshot.
    private func makeScreenShot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        view.layer.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return image
    }

    /// Presents an ActivityViewController to share a screenshot.
    func share() {
        guard let image = makeScreenShot() else { return }
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view
        present(activityViewController, animated: true, completion: nil)
    }

    // MARK: WCSessionDelegate
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

    // MARK: - Watch Integration
    /// Receives a message dictionary from the Watch app and sets the text property.
    ///
    /// - Parameters:
    ///   - session: The session object of the current process.
    ///   - message: A dictionary of property list values representing the contents of the message.
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async { [weak self] in
            self?.getQuote()
        }
    }

    /// Sends a message dictionary immediately to the Watch app.
    ///
    /// - Parameter quote: A quote to send.
    private func sendToWatch(quote: Quote) {
        guard WCSession.default().activationState == .activated && WCSession.default().isPaired else { return }
        let content = ["content": quote.content]
        WCSession.default().sendMessage(content, replyHandler: nil)
    }
}
