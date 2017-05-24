//
//  Animated.swift
//  Inspiration
//
//  Created by Konstantin Khokhlov on 24.05.17.
//  Copyright © 2017 Konstantin Khokhlov. All rights reserved.
//

import UIKit

protocol Animated {}

extension Animated where Self: UIView {
    func animateAlpha(duration: CGFloat) {
        self.isHidden = false
        let startAlpha = self.alpha
        UIView.animate(withDuration: TimeInterval(duration),
                       animations: { [weak self] in
                        self?.alpha -= startAlpha / duration
            },
                       completion: { [weak self] isEnded in
                        if isEnded {
                            self?.isHidden = true
                            self?.alpha = startAlpha
                        }
        })
    }
}
