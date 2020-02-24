//
//  AccountExportController.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/13.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

class AccountExportController: BaseStaticTableController {

    @IBOutlet weak var backupTitleLabel: UILabel!
    @IBOutlet weak var backupDesLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var detailDesLabel: UILabel!
    @IBOutlet weak var toolTitleLabel: UILabel!
    @IBOutlet weak var toolDesLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var textViewHeightCons: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    var backType:ExportWalletType = .keyStore

    var privateKey: String? = nil
    var keyStore: String? = nil


    override func viewDidLoad() {
        super.viewDidLoad()

        addBackItem()
        makeUI()
    }

    func makeUI() {

        switch backType {
        case .keyStore:
            title = "Export Keystore".localized()
            backupTitleLabel.text = "Off-line Saving".localized()
            backupDesLabel.text = "Please do not save".localized()
//            detailLabel.text = "Do not use network transmission".localized()
            //detailDesLabel.text = "Do not transfer through network tools".localized()
            detailLabel.text = nil
            detailDesLabel.text = nil
            toolDesLabel.text = "Password management tools are recommended".localized()
            toolTitleLabel.text = "Password Management Tool".localized()
            nextButton.setTitle("Copy Keystore".localized(), for: .normal)
            self.textView.text = self.prettyKeyStore(jsonString: self.keyStore ?? "")
        case .privateKey:
            title = "Export Private Key".localized()
            backupTitleLabel.text = "Off-line Saving".localized()
            backupDesLabel.text = "Please do not save".localized()
            detailLabel.text = nil
            detailDesLabel.text = nil
            toolDesLabel.text = "Password management tools are recommended".localized()
            toolTitleLabel.text = "Password Management Tool".localized()
            textViewHeightCons.constant = textView.sizeThatFits(CGSize(width: textView.height, height: CGFloat.greatestFiniteMagnitude)).height + 20
            nextButton.setTitle("Copy PrivateKey".localized(), for: .normal)

            textView.text =  self.privateKey
        default:
            break
        }

        nextButton.cornerRadius = nextButton.height/2
        textView.isEditable = false
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.reloadData()

    }

    func prettyKeyStore(jsonString:String)->String? {
        guard let jsonData = jsonString.data(using: .utf8) else { return jsonString }
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)
            let prettyJsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            let prettyJson = String(data: prettyJsonData, encoding: .utf8)
            return prettyJson
        } catch  {
            logInfo("k error:\(error)")
        }
        return jsonString
    }

    // MARK: - Table view data source
    @IBAction func nextAction(_ sender: Any) {

        UIPasteboard.general.string = textView.text
        SVProgressHUD.showSuccess(withStatus: "Copied".localized())
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 1 {
            return 0
        } else {
            return UITableView.automaticDimension
        }
    }
}
