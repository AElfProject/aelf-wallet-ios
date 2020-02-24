//
//  VersionLogCell.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/19.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit

class VersionLogCell: BaseTableCell {

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bgView.backgroundColor = .white
        
       // self.bgView.removeSubviews()
        // Initialization code
    }
    
    func tranTime(timeStamp:Int) -> String {
        
        let timeInterval:TimeInterval = TimeInterval(timeStamp)
        let time = NSDate.init(timeIntervalSince1970:timeInterval)
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "YYYY.MM.dd"
        return  dateformatter.string(from: time as Date)
        //  logDebug("当前日期时间：\(dateformatter.string(from: time as Date))")
    }

    var item: AppVersionLog? {
        didSet {
            self.bgView.removeSubviews()
            guard let item = item else { return }
            let timeStamp = Int(item.upgradeTime ?? "0")!
            let time = self.tranTime(timeStamp: timeStamp)
            let title = (item.verNo ?? "") + "(" + time + ")"
            self.timeLabel.text = title
            let array = item.intro ?? []
            let count = array.count
            var lastLabel = UILabel.init(frame: .zero)
            for (index,content) in array.enumerated(){
                let desLabel = UILabel.init(text: content)
                desLabel.textColor = .c78
                desLabel.font = .systemFont(ofSize: 13)
                desLabel.numberOfLines = 0
                self.bgView.addSubview(desLabel)
                if index == 0 {
                    desLabel.snp.makeConstraints { (make) -> Void in
                        make.left.equalTo(45)
                        make.top.equalTo(8)
                        make.right.equalTo(self.bgView).offset(-30)
                    }
                } else {
                    
                    desLabel.snp.makeConstraints { (make) -> Void in
                        make.left.equalTo(45)
                        make.top.equalTo(lastLabel.snp.bottom).offset(8)
                        make.right.equalTo(self.bgView).offset(-30)
                        if index == count - 1 {
                             make.bottom.equalTo(self.bgView).offset(-8)
                        }
                    }
                }
                let pointView = UIView.init()
                pointView.backgroundColor = .appBlack
                pointView.layer.cornerRadius = 3
                pointView.layer.masksToBounds = true
                self.bgView.addSubview(pointView)
                pointView.snp.makeConstraints { (make) -> Void in
                    make.width.equalTo(6)
                    make.height.equalTo(6)
                    make.left.equalTo(28)
                    make.top.equalTo(desLabel.snp.top).offset(2)
                }
                lastLabel = desLabel
            }

        }
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
