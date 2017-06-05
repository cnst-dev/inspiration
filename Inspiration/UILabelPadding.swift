//
//  UILabelPadding.swift
//  Inspiration
//
//  Created by Konstantin Khokhlov on 05.06.17.
//  Copyright © 2017 Konstantin Khokhlov. All rights reserved.
//

import UIKit

class UILabelPadding: UILabel {

    // MARK: - Properties
    @IBInspectable var top: CGFloat = 0.0
    @IBInspectable var left: CGFloat = 0.0
    @IBInspectable var bottom: CGFloat = 0.0
    @IBInspectable var right: CGFloat = 0.0

    override var intrinsicContentSize: CGSize {
        let padding = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        let superContentSize = super.intrinsicContentSize
        let width = superContentSize.width + padding.left + padding.right
        let heigth = superContentSize.height + padding.top + padding.bottom
        return CGSize(width: width, height: heigth)
    }

    // MARK: - UILabel
    override func drawText(in rect: CGRect) {
        let padding = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, padding))
    }
}
