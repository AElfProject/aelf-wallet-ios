//
//  CustomNetworkCell.swift
//  AelfApp
//
//  Created by yuguo on 2020/6/29.
//  Copyright © 2020 legenddigital. All rights reserved.
//

import UIKit

class CustomNetworkCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet var customTF: UITextField!
    
    @IBOutlet var chooseButton: UIButton!
    
    var confirmAction: ((String) -> Void)?
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        customTF.delegate = self
        customTF.addTarget(self, action:#selector(textfieldChangeAction(textfield:)), for:.editingChanged)

    }
    
    var isChoose: Bool? {
        didSet {
            guard let isChoose = isChoose else { return }
            chooseButton.isSelected = isChoose
            customTF.text = ""
            customTF.shouldBeginEditing { () -> Bool in
                return isChoose ? true : false
            }
        }
    }
    
    //点击按钮执行的方法
    @objc func textfieldChangeAction(textfield: UITextField) {
        if confirmAction != nil {
            confirmAction?(textfield.text ?? "")
        }
    }
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        print(456)
//    }
//
//    func textFieldDidChangeSelection(_ textField: UITextField) {
//        print(123)
//    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
