//
//  UIButton+Ext.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/5/31.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation

extension UIButton {

    func setTitlePosition(position: UIView.ContentMode,spacing: CGFloat = 0) {
        set(image: currentImage, title: currentTitle ?? "", titlePosition: position, additionalSpacing: spacing, state: .normal)
    }

    private func set(image anImage: UIImage?, title: String,
                   titlePosition: UIView.ContentMode, additionalSpacing: CGFloat, state: UIControlState) {
        self.imageView?.contentMode = .center
        self.setImage(anImage, for: state)

        positionLabelRespectToImage(title: title, position: titlePosition, spacing: additionalSpacing)

        self.titleLabel?.contentMode = .center
        self.setTitle(title, for: state)
    }

    private func positionLabelRespectToImage(title: String, position: UIView.ContentMode,
                                             spacing: CGFloat) {
        let imageSize = self.imageRect(forContentRect: self.frame)
        let titleFont = self.titleLabel?.font!
        let titleSize = title.size(withAttributes: [NSAttributedString.Key.font: titleFont!])

        var titleInsets: UIEdgeInsets
        var imageInsets: UIEdgeInsets

        switch (position) {
        case .top:
            titleInsets = UIEdgeInsets(top: -(imageSize.height + titleSize.height + spacing),
                                       left: -(imageSize.width), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width)
        case .bottom:
            titleInsets = UIEdgeInsets(top: (imageSize.height + titleSize.height + spacing),
                                       left: -(imageSize.width), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width)
        case .left:
            titleInsets = UIEdgeInsets(top: 0, left: -(imageSize.width * 2), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0,
                                       right: -(titleSize.width * 2 + spacing))
        case .right:
            titleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -spacing)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        default:
            titleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }

        self.titleEdgeInsets = titleInsets
        self.imageEdgeInsets = imageInsets
    }
}
