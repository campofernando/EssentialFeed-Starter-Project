//
//  UIImageView+Animations.swift
//  EssentialFeediOS
//
//  Created by Fernando Campo Garcia on 18/05/25.
//

import UIKit

extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?) {
        image = newImage
        
        guard newImage != nil else { return }
        
        alpha = 0
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.alpha = 1
        }
    }
}
