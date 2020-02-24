//
//  YFTableViewCell.swift
//  YFTableViewCellForSwift
//
//  Created by Dandre on 2017/10/29.
//  Copyright © 2017年 Dandre. All rights reserved.
//

/**
 *  Author:Dandre
 *  YFTableViewCell下载：https://github.com/DandreYang/YFTableViewCell
 *  优点：
 *  1.支持代码和.xib等方式自定义tableViewCell
 *  2.使用简单，继承于YFTableViewCell即可
 *
 *  使用步骤：
 *  1.将你的tableViewCell继承于YFTableViewCell
 *  2.设置cell.delegate = self;
 *  3.设置cell.editButtonArray = array;(array为存有 UIButton 对象 的数组)
 *  3.1.开启【删除】按钮点击后提示【确认删除】按钮：cell.confirmButton = UIButton(title:"确认删除")
 *  3.2.设置点击哪个按钮才会提示【确认删除】按钮：cell.confirmButtonIndex = 0 (index为上面editButtonArray索引值)
 *  4.实现YFTableViewCellDelegate代理方法
 *      func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
 *      func tableView(_ tableView: UITableView, didClickedEditButtonAt buttonIndex: Int, At IndexPath:IndexPath)
 *
 */

import UIKit

protocol YFTableViewCellDelegate:NSObjectProtocol {
    
    
    /// 当点击cell时触发此方法，与UITableView的以下代理方法相同
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    
    /// 当点击cell上的自定义按钮时触发此协议方法
    ///
    /// - Parameters:
    ///   - tableView: 当前点击的cell所在的TableView
    ///   - buttonIndex: 当前点击的按钮索引
    ///   - indexPath: 当前点击的cell所在的IndexPath
    func tableView(_ tableView: UITableView, didClickedEditButtonAt buttonIndex: Int, At indexPath:IndexPath)
}

let kYFCellEditButtonDelele = UIColor.red
let kYFCellEditButtonMore   = UIColor.init(red: 180/255.0, green: 180/255.0, blue: 180/255.0, alpha: 1)
let kYFCellEditButtonOther  = UIColor.init(red: 180/255.0, green: 180/255.0, blue: 180/255.0, alpha: 1)
let kYFCellEditButtonIsRead = UIColor.init(red: 240/255.0, green: 164/255.0, blue: 24/255.0, alpha: 1)

let YFTableViewCellNSNotification = "YFTableViewCellNSNotification"

public enum YFTableViewCellState : Int {
    case center
    case left
    case right
}

class YFTableViewCell: UITableViewCell, UIScrollViewDelegate {
    
    var scrollView:UIScrollView?
    var editButtonArray:[UIButton]?
    var confirmButton:UIButton?
    var confirmButtonIndex:Int = 0
    weak var delegate:YFTableViewCellDelegate?
    
    private var     _cellState:YFTableViewCellState = .center
    private let     _rightButtonsView = UIView()
    private let     _backgroundView = UIView()
    private var     _lastOffset:CGFloat = 0.00
    private var     _confirmIsFocus:Bool = false
    
    var rightButtonsViewWidth:Double {
        return Double((editButtonArray?.count ?? 0)*80)
    }
    
    var tableView:UITableView? {
        return getSuperView(self, superClass: UITableView.self) as? UITableView
    }
    
    var indexPath:IndexPath? {
        return self.tableView?.indexPath(for: self)
    }
    
    func getSuperView(_ view:UIView, superClass: AnyClass) -> UIView {
        let cls = view.superview
        if (cls?.isKind(of: superClass))!{
            return cls!;
        }else{
            return getSuperView(cls!, superClass:superClass)
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        if scrollView == nil {
            scrollView = UIScrollView()
            contentView.addSubview(scrollView!)
            scrollView?.isPagingEnabled = true
            scrollView?.showsHorizontalScrollIndicator = false
            scrollView?.showsVerticalScrollIndicator = false
            scrollView?.bounces = false
            scrollView?.delegate = self
            scrollView?.tag = 0x80000
            scrollView?.backgroundColor = UIColor.white
            
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapClicked(_:)))
            self.scrollView?.addGestureRecognizer(tap)
            
            _rightButtonsView.frame = CGRect(x:self.bounds.width,
                                             y:0,
                                             width:CGFloat(self.rightButtonsViewWidth),
                                             height:self.bounds.height)
            scrollView?.addSubview(_rightButtonsView)
            
            _backgroundView.frame = self.bounds
            _backgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.15)
            scrollView?.addSubview(_backgroundView)
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(dealNotification),
                                                   name: NSNotification.Name(rawValue: YFTableViewCellNSNotification),
                                                   object: nil)
        }
        _backgroundView.backgroundColor = UIColor.white
        scrollView?.contentOffset = CGPoint.zero;
        _rightButtonsView.frame = CGRect(x:self.bounds.width,
                                         y:0,
                                         width:CGFloat(self.rightButtonsViewWidth),
                                         height:self.bounds.height)
        
        guard let editButtonArray = editButtonArray else {
            logDebug("editButtonArray数组为空")
            return
        }
        
        for i in 0..<editButtonArray.count {
            let btn = editButtonArray[i]
            btn.frame = CGRect(x: Double(i*80), y: 0.0, width: 80.0, height: Double(self.frame.height))
            _rightButtonsView.addSubview(btn)
            btn.tag = 10000 + i
            btn.addTarget(self, action: #selector(btnClicked(_:)), for: .touchUpInside)
        }
        
        if let confirm = confirmButton {
            confirm.frame = CGRect(x: 0.0, y: 0.0, width: rightButtonsViewWidth, height: Double(self.frame.height))
            confirm.isHidden = true
            _rightButtonsView.addSubview(confirm)
            confirm.addTarget(self, action: #selector(btnConfirmClicked(_:)), for: .touchUpInside)
        }
        
        
        scrollView?.contentSize = CGSize(width: Double(self.bounds.width) + self.rightButtonsViewWidth,
                                         height: 0.0)
        
        scrollView?.frame = CGRect(x:0.0,
                                   y:0.0,
                                   width:self.contentView.frame.width,
                                   height:self.contentView.frame.height)
        
        for view in self.contentView.subviews {
            guard view.isKind(of: UIScrollView.self) && view.tag == 0x80000 else{
                scrollView?.addSubview(view)
                return
            }
        }
        
    }
    
    @objc func dealNotification(_ info: Notification) {
        guard  info.object as?YFTableViewCell == self else {
            UIView.animate(withDuration: 0.3, animations: {
                self.scrollView?.contentOffset = CGPoint.zero
            })
            return
        }
    }
    
    @objc func tapClicked(_ tap:UITapGestureRecognizer) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: YFTableViewCellNSNotification), object: self)
        if scrollView?.contentOffset.x != 0 {
            UIView.animate(withDuration:0, animations: {
                self.scrollView?.contentOffset = CGPoint.zero
            })
            return
        }
        
        if self.delegate != nil {
            delegate?.tableView(tableView!, didSelectRowAt: indexPath!)
        }else{
            logDebug("未设置代理！")
        }
    }
    
    @objc func btnClicked(_ sender: UIButton) {
        let index = sender.tag - 10000
        if (index == confirmButtonIndex && confirmButton != nil) {
            _confirmIsFocus = true
            UIView.animate(withDuration:0, animations: {
                self.scrollView?.contentOffset = CGPoint.zero
            })
        }else{
            doBtnClicked(index: index)
        }
    }
    
    @objc func btnConfirmClicked(_ sender: UIButton) {
        doBtnClicked(index: confirmButtonIndex)
    }
    
    private func doBtnClicked(index:Int){
        UIView.animate(withDuration:0, animations: {
            self.scrollView?.contentOffset = CGPoint.zero;
        })
        
        if delegate != nil {
            delegate?.tableView(tableView!, didClickedEditButtonAt: index, At: indexPath!)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        NotificationCenter.default.post(name: Notification.Name(rawValue:YFTableViewCellNSNotification), object: self)
        
        if (scrollView.contentOffset.x <= _rightButtonsView.frame.size.width) {
            var rect = _rightButtonsView.frame
            rect.origin.x = self.bounds.width - rect.size.width + scrollView.contentOffset.x
            _rightButtonsView.frame = rect
        }
        scrollView.sendSubviewToBack(_rightButtonsView)
        
        _cellState = .left
        if (_lastOffset > scrollView.contentOffset.x) {
            _cellState = .center
        }
        
        _lastOffset = scrollView.contentOffset.x
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.x == 0) {
            if let _confirmButton = confirmButton{
                if (_confirmIsFocus) {
                    _confirmIsFocus = false
                    _confirmButton.isHidden = false
                    UIView.animate(withDuration:0, animations: {
                        scrollView.contentOffset = CGPoint(x: self.rightButtonsViewWidth, y: 0)
                    })
                }else if(_confirmButton.isHidden == false){
                    _confirmButton.alpha = 1
                    UIView.animate(withDuration: 0, animations: {
                        _confirmButton.alpha = 0
                    }, completion: { (_) in
                        _confirmButton.alpha = 1
                        _confirmButton.isHidden = true
                    })
                }
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        var rect = _rightButtonsView.frame
        if (_rightButtonsView.frame.origin.x >= self.bounds.width) {
            rect.origin.x = self.bounds.width
        }else{
            rect.origin.x = self.bounds.width - rect.size.width
        }
        _rightButtonsView.frame = rect
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        switch (_cellState) {
        case .center:
            targetContentOffset.pointee.x = 0
        case .left:
            if Double(scrollView.contentOffset.x) >= self.rightButtonsViewWidth/2 {
                targetContentOffset.pointee.x = CGFloat(self.rightButtonsViewWidth)
            }else{
                targetContentOffset.pointee.x = 0
            }
            
        default:
            break
        }
    }
}


// MARK:拓展UIButton类
extension UIButton {
    
    convenience init(type:UIButton.ButtonType = .custom,
                     title:String? = nil,
                     titleColor:UIColor = UIColor.white,
                     backgroundColor:UIColor = UIColor.red,
                     image:UIImage? = nil,
                     fontSize:CGFloat = 15)
    {
        self.init(type: type)
        self.setTitle(title, for: UIControlState.init(rawValue: 0))
        self.setTitleColor(titleColor, for: UIControlState.init(rawValue: 0))
        self.backgroundColor = backgroundColor;
        self.titleLabel?.font = UIFont.systemFont(ofSize: fontSize);
        self.setImage(image, for: UIControlState.init(rawValue: 0))
    }
}
