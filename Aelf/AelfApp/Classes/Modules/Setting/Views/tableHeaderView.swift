//
//  tableHeaderView.swift
//  AelfApp

//
//  Created by MacKun on 2019/6/25.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

protocol tableHeaderViewDelegate {
    
    func tableHeaderViewDelegateClick(_ head:tableHeaderView,num:Int)
    
}

class tableHeaderView: UITableViewHeaderFooterView {
    
    var delegate : tableHeaderViewDelegate?
    var section : Int = 0
    
    init(reuseIdentifier:String) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        setupRight()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    static func headViewWithTableView(_ tableView:UITableView)->tableHeaderView{
        
        let headID = "tableHeaderViewID"
        
        var headView  = tableView.dequeueReusableHeaderFooterView(withIdentifier: headID)
        
        if headView == nil
        {
            headView = tableHeaderView(reuseIdentifier:headID)
        }
//        headView?.textLabel?.numberOfLines = 0;
//        headView?.textLabel?.frame = CGRect(x:20,y:0,width:screenWidth - 60 - 30,height:48)
        return headView as! tableHeaderView
        
    }
 
    override func layoutSubviews() {
        super.layoutSubviews()
//        self.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
//        self.textLabel?.textColor = .appBlack
        
        rightButton.frame = CGRect(x:(contentView.bounds.width)-60,y:0,width:48,height:48)
       
    }
    
    
    
    func setupRight(){
       
        contentView.addSubview(contentLabel)
        contentView.addSubview(rightButton)
    }
    lazy var rightButton : UIButton = {
        
        let btn = UIButton()
        btn.setImage(UIImage.init(named: "down-arrow"), for: .normal)
        btn.addTarget(self, action: #selector(tapHeadView), for: .touchUpInside)
        
        return btn
    }()
    lazy var contentLabel : UILabel = {
       let label = UILabel.init(frame: CGRect(x:20,y:0,width:screenWidth - 60 - 30,height:48))
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .appBlack
        return label
    }()
    func setLeftBottom(_ show:Bool){

        let animate = CABasicAnimation(keyPath: "transform.rotation.z")
        
        animate.toValue = !show ? Double.pi*1 : 0
        animate.duration = 0.2
        animate.isRemovedOnCompletion = false
        animate.fillMode = CAMediaTimingFillMode.forwards
        rightButton.layer.add(animate, forKey: nil)
    
    }
    @objc fileprivate func tapHeadView(){
       
        if (delegate != nil)
        {
           
            delegate?.tableHeaderViewDelegateClick(self,num:section)
        }
        
    }
    
}

