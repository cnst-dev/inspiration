//
//  Extensions.swift
//  Inspiration
//
//  Created by Konstantin Khokhlov on 09.05.17.
//  Copyright © 2017 Konstantin Khokhlov. All rights reserved.
//

import UIKit

extension String {

    var cleared: String {
        guard let data = self.data(using: String.Encoding.unicode) else { return "" }
        guard let attributedText = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil) else { return ""}
        return attributedText.string
    }
}
