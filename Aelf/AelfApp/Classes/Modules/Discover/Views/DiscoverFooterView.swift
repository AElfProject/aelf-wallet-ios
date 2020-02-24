//
//  DiscoverFooterView.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/12/20.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit

class DiscoverFooterView: UIView {

    @IBOutlet var applyButton: UIButton!
    
    var tapDapply:(() -> ())?
    
    @IBAction func applyButtonTapped(_ sender: UIButton) {
        tapDapply?()
    }
    
    
}
