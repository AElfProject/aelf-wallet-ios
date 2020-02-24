//
//  ChainTitleView.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/9/26.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit

private let normalSize = CGSize(width: 80, height: 20)
private let largeSize = CGSize(width: 100, height: 30)

class ChainTitleView: UIView {

    var tapClosure: (() -> ())?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {

        addSubview(titleButton)

        titleButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        self.snp.makeConstraints { (make) in
            make.size.equalTo(normalSize)
        }

        displayMode(App.assetMode)
    }

    private lazy var titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.tintColor = UIColor.white
        button.onTap {
            self.tapClosure?()
        }
        return button
    }()


}

extension ChainTitleView {

    func setTitle(_ title: String, showImage: Bool = true) {
        
        if showImage {
            titleButton.setImage(UIImage(named: "down-arrow"), for: .normal)
            titleButton.setTitle("Current Chain - %@".localizedFormat(title), for: .normal)
            titleButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            titleButton.setTitlePosition(position: .left, spacing: 5)
        } else {
            titleButton.setTitle(title, for: .normal)
            titleButton.setImage(nil, for: .normal)
            titleButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        }
    }

    func displayMode(_ mode: AssetDisplayMode) {

        var size = CGSize.zero

        if mode == .chain {
            setTitle(App.chainID)
            borderWidth = 1
            borderColor = UIColor(hexString: "F3F5F9")
            layer.masksToBounds = true
            
            titleButton.sizeToFit()
            titleButton.width += 30
            titleButton.height = 25
            size = titleButton.size
            layer.cornerRadius = titleButton.height/2
            titleButton.isUserInteractionEnabled = true
        } else {
            setTitle("Assets".localized(), showImage: false)
            borderColor = UIColor.clear
            size = largeSize
            titleButton.isUserInteractionEnabled = false
        }

        snp.updateConstraints { (make) in
            make.size.equalTo(size)
        }
    }
    
    func masterStyle() {
        backgroundColor = UIColor.master
        titleButton.borderWidth = 0
        
    }
}
