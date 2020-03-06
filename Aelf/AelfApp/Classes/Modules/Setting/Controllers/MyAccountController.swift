//
//  MyAccountController.swift
//  AelfApp
//
//  Created by MacKun on 2019/5/31.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import CropViewController
import AVFoundation

struct AccountItem {
    var title: String
    var img: String
    var type: ExportWalletType
}

class MyAccountController: BaseController {

    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!

    let viewModel = MyAccountViewModel()

    var selectImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
        bindAccountViewModel()

        updateUI(info: App.userInfo)
    }

    func makeUI() {

        self.title = "Identity Management".localized()

        tableView.register(nibWithCellClass: AccountItemCell.self)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 45
        tableView.delegate = self
        tableView.dataSource = self

        tableView.reloadData()

        avatarImageView.hero.id = "AvatarID"
        nameButton.hero.id = "UserNameID"

        avatarImageView.cornerRadius = avatarImageView.height/2
        avatarImageView.borderWidth = 0.5
        avatarImageView.borderColor = UIColor.white
        avatarImageView.isUserInteractionEnabled = true

        copyButton.isHidden = true

        logoutButton.alpha = 0
        UIView.animate(withDuration: 1) {
            self.logoutButton.alpha = 1
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(openUserPhotos))
        avatarImageView.addGestureRecognizer(tap)
    }

    func updateUI(info: IdentityInfo?) {
        guard let info = info else { return }

        if let name = info.name,name.length > 0 {
            self.nameButton.setTitle(name, for: .normal)
//            copyButton.isHidden = false
        }else {
            self.nameButton.setTitle(AElfWallet.walletName ?? "AELF", for: .normal)
//            copyButton.isHidden = true
        }

        if let url = URL(string: info.img ?? "") {
            self.avatarImageView.setImage(with: url, placeholder: UIImage(named: "logo-mark"))
        }else {
            self.avatarImageView.image = UIImage(named: "logo-mark")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    @objc func openUserPhotos() {

        Configuration.doneButtonTitle = "Done".localized()
        Configuration.cancelButtonTitle = "Cancel".localized()
        Configuration.OKButtonTitle = "OK".localized()
        Configuration.noImagesTitle = "Sorry! There are no images here!".localized()
        Configuration.requestPermissionTitle = "Permission denied".localized()
        Configuration.settingsTitle = "Settings".localized()
        Configuration.noCameraTitle = "No images available".localized()
        Configuration.requestPermissionMessage = "Please, allow the application to access to your photo library".localized()

        let imagePicker = ImagePickerController()
        imagePicker.imageLimit = 1
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .overFullScreen
        present(imagePicker, animated: true, completion: nil)
    }

    func bindAccountViewModel() {

        let input = MyAccountViewModel.Input(address: App.address,headerRefresh: headerRefresh())
        let output = viewModel.transform(input: input)

        output.userInfo.subscribe(onNext: { [weak self] info in
            App.userInfo = info
            self?.updateUI(info: info)
        }).disposed(by: rx.disposeBag)

        viewModel.parseError.subscribe(onNext: { e in
            SVProgressHUD.showInfo(withStatus: e.msg ?? "")
        }).disposed(by: rx.disposeBag)
    }

    @IBAction func logoutAction(_ sender: Any) {
        
        AudioServicesPlaySystemSound(1519) //1520
        AElfAlertView.show(title: "Log Out".localized(),
                           subTitle: "All wallet data will be deleted after you log out".localized())
        {
            asyncMainDelay(duration: 0.2, block: {
                self.confirmLogout()
            })
        }
    }

    func confirmLogout() {
        
        SecurityVerifyManager.verifyPaymentPassword(completion: { (pwd) in
            if let pwd = pwd {
                App.deleteAllData(pwd: pwd)
                self.logoutSuccessful()
            }
        })
    }

    func logoutSuccessful() {
        asyncMainDelay(duration: 0.1, block: {
            BaseTableBarController.resetImportRootController()
        })
    }

    @IBAction func nameButtonTapped(_ sender: UIButton) {

        let disposeBage = DisposeBag()
        InputAlertView.show(inputType: .editUserName) { v in
            let img = self.avatarImageView.image ?? UIImage(named: "logo-mark")
            self.viewModel.updateUserName(address: App.address, name: v.pwdField.text ?? "", img: img)
                .subscribe(onNext: { result in
                    logDebug(result)
                    self.headerRefreshTrigger.onNext(())
                    v.hide()
                }, onError: { e in
                    logDebug(e)
                    v.hide()
                }).disposed(by: disposeBage)
        }
    }

    @IBAction func copyButtonTapped(_ sender: Any) {
        if let title = nameButton.currentTitle {
            UIPasteboard.general.string = title
            SVProgressHUD.showSuccess(withStatus: "Copied".localized())
        }
    }

    func uploadUserInfo() {

        SVProgressHUD.show()
        self.viewModel.updateUserName(address: App.address, name: nil, img: self.selectImage)
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                logDebug(result)
                if result.isOk {
                    self.avatarImageView.image = self.selectImage
                    self.headerRefreshTrigger.onNext(())
                    SVProgressHUD.dismiss()
                }else {
                    SVProgressHUD.showError(withStatus: result.msg ?? "")
                }

            }).disposed(by: rx.disposeBag)
    }


    lazy var dataArray: [AccountItem] = {
        var items = [AccountItem]()
        items.append(AccountItem(title: "Password Hint".localized(), img: "p-word-hint",type: .hint))
        
        items.append(AccountItem(title: "Export QR Code".localized(), img: "export-qr",type: .qrCode))
        items.append(AccountItem(title: "Export Keystore".localized(), img: "export-keyword",type: .keyStore))
        
        // 通过助记词导入，才有导出助记词选项
        if App.isMnemonicImport {
            items.append(AccountItem(title: "Export Mnemonic Phrase".localized(), img:"export-mnemonic",type: .mnemonic))
        }
        
        items.append(AccountItem(title: "Export Private Key".localized(), img: "export-private-key",type: .privateKey))
        

        return items
    }()

    func showCropVC(image: UIImage) {

        let cropVC = CropViewController(croppingStyle: .circular, image: image)
        cropVC.onDidCropToCircleImage = { (cropImg,rect,idx) in
            self.selectImage = cropImg
            self.uploadUserInfo()

            cropVC.dismiss(animated: true, completion: nil)
        }
        self.present(cropVC, animated: true, completion: nil)
    }
}

extension MyAccountController: ImagePickerDelegate {

    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {

    }

    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {

        imagePicker.dismiss(animated: true, completion: nil)
    }

    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        if let image = images.first {
            imagePicker.dismiss(animated: false) {
                self.showCropVC(image: image)
            }
        }
    }
}


extension MyAccountController:UITableViewDataSource,UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = dataArray[indexPath.row]
        let cell  = tableView.dequeueReusableCell(withClass: AccountItemCell.self)
        cell.settingLabel.text = item.title
        cell.imgView.image = UIImage.init(named: item.img)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = dataArray[indexPath.row]

        switch item.type {
        case .hint:
            let vc = UIStoryboard.loadController(PasswordHintController.self, storyType: .setting)
            push(controller: vc)
        case .mnemonic,.keyStore,.privateKey:
            let vc = UIStoryboard.loadController(BackupController.self, storyType: .setting)
            vc.backType = item.type
            push(controller: vc)
        case .qrCode:
            
            SecurityVerifyManager.verifyPaymentPassword(completion: { (pwd) in
                if let pwd = pwd {
                    let vc = UIStoryboard.loadController(ExportQRCodeController.self, storyType: .setting)
                    vc.pwd = pwd
                    self.push(controller: vc)
                }
            })
            break
        default:
            break
        }

    }
}
