//
//  Background.swift
//  Inspiration
//
//  Created by Konstantin Khokhlov on 10.05.17.
//  Copyright © 2017 Konstantin Khokhlov. All rights reserved.
//

import UIKit

struct Background {
    // MARK: - Properties
    var image: UIImage

    // MARK: - Methods
    static func getImage(from url: URL, completion: @escaping ((Background) -> Void)) {
        URLSession(configuration: .ephemeral).dataTask(with: url) { (data, _, error) in
            guard error == nil else { return }
            guard let data = data, let image = UIImage(data: data) else { return }
            completion(Background(image: image))
        }.resume()
    }
}
