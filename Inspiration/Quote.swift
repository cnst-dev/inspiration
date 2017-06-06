//
//  Quote.swift
//  Inspiration
//
//  Created by Konstantin Khokhlov on 09.05.17.
//  Copyright © 2017 Konstantin Khokhlov. All rights reserved.
//

import Foundation

struct Quote {

    // MARK: - Properties
    var title = ""
    var content = ""

    // MARK: - Methods
    /// Requests a quote.
    ///
    /// - Parameters:
    ///   - url: - The URL to be retrieved.
    ///   - completion: - Completion handler.
    static func getQuote(from url: URL, completion: @escaping ((Quote) -> Void)) {
        URLSession(configuration: .ephemeral).dataTask(with: url) { (data, _, error) in
            guard error == nil else { return }
            guard let data = data else { return }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] else { return }
            guard let rawTitle = json?[0]["title"] as? String, let rawContent = json?[0]["content"] as? String else { return }
            let quote = Quote(title: rawTitle.cleared.uppercased(), content: rawContent.cleared)
            completion(quote)
        }.resume()
    }
}
