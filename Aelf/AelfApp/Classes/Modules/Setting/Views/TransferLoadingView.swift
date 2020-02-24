//
//  TransferLoadingView.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/10/14.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation

class TransferLoadingView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white
        addSubview(indicatorView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        view.hidesWhenStopped = true
        view.startAnimating()
        view.center = self.center
        view.centerY -= 100
        return view
    }()


    func startLoading() {
        indicatorView.startAnimating()
    }

    func stopLoading() {
        indicatorView.stopAnimating()
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 1
        }) { _ in
            self.removeFromSuperview()
        }
    }
}
