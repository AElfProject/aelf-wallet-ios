//
//  BouncesContentView.swift
//  AelfApp
//
//  Created by 晋先森 on 17/3/3.
//  Copyright © 2017年 晋先森. All rights reserved.
//


import UIKit
import ESTabBarController_swift

class BasicContentView: ESTabBarItemContentView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        textColor = UIColor(white: 175.0 / 255.0, alpha: 1.0)
        highlightTextColor = UIColor.master

        iconColor = UIColor(white: 175.0 / 255.0, alpha: 1.0)
        highlightIconColor = UIColor.master

    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


class BouncesContentView: BasicContentView {

    public var duration = 0.25

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func selectAnimation(animated: Bool, completion: (() -> ())?) {
        self.bounceAnimation()
        completion?()
    }

    override func reselectAnimation(animated: Bool, completion: (() -> ())?) {
        self.bounceAnimation()
        completion?()
    }
    
    func bounceAnimation() {
        let scale = CAKeyframeAnimation(keyPath: "transform.scale")
        scale.values = [1.0 ,1.25, 0.9, 1.15, 1.0]
        scale.duration = duration * 2
        scale.calculationMode = CAAnimationCalculationMode.cubic
        imageView.layer.add(scale, forKey: nil)
    }
}
