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
    @IBOutlet private weak var quoteTextView: UITextView!

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Actions
    @IBAction private func buttonPressed(_ sender: UIButton) {
        getQuote()
    }

    // MARK: Quotes
    private func getQuote() {
        let urlString = "http://quotesondesign.com/wp-json/posts?filter[orderby]=rand&filter[posts_per_page]=1"
        guard let url = URL(string: urlString) else { return }

        DispatchQueue.global().async { [weak self] in
            guard let data = try? Data(contentsOf: url) else { return }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] else { return }
            guard let quote = json?[0]["content"] as? String else { return }
            DispatchQueue.main.async {
                self?.quoteTextView.text = quote
            }
        }
    }

}
