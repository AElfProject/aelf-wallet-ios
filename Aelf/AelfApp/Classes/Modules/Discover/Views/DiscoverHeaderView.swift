//
//  DiscoverHeaderView.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/6.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import FSPagerView

/// Discover 首页头部 header： 搜索+扫描+轮播图
class DiscoverHeaderView: UIView {

    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var pageView: FSPagerView! {
        didSet {
            self.pageView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: FSPagerViewCell.className)
            self.pageView.cornerRadius = 10
            self.pageView.decelerationDistance = FSPagerView.automaticDistance
        }
    }

    @IBOutlet weak var pageControl: FSPageControl! {
        didSet {
            self.pageControl.contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self.pageControl.setStrokeColor(UIColor(hexString: "B3B8BC"), for: .normal)
            self.pageControl.setStrokeColor(.master, for: .selected)
            self.pageControl.setFillColor(.master, for: .selected)
        }
    }

    override func awakeFromNib() {
        
    }
    
    static func loadView(tapBanner: ((DiscoverBanner) -> Void)?) -> DiscoverHeaderView {
        guard let v = DiscoverHeaderView.loadFromNib(named: DiscoverHeaderView.className) as? DiscoverHeaderView else {
            fatalError("加载 Xib:\(self.className) 失败！")
        }
        v.tapBanner = tapBanner
        
        return v
    }

    var bannerSource = [DiscoverBanner]() {
        didSet {
            self.pageControl.numberOfPages = bannerSource.count
            self.pageControl.isHidden = bannerSource.count <= 1
            pageView.reloadData()
        }
    }

    var tapBanner:((DiscoverBanner) -> Void)?
    
    static func headerHeight() -> CGFloat {
        let pageHeight = (screenWidth - 20*2) * 0.3 // 宽高比固定 0.3
        let height = (40 + 5) + pageHeight + 25
        
        return height
    }
}

extension DiscoverHeaderView: FSPagerViewDelegate,FSPagerViewDataSource {

    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return bannerSource.count
    }

    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: FSPagerViewCell.className, at: index)

        let banner = bannerSource[index]
        cell.textLabel?.superview?.isHidden = true
        cell.imageView?.setImage(with: URL(string: banner.img))

        return cell
    }

    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)

        let banner = bannerSource[index]
        tapBanner?(banner)
    }

    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        self.pageControl.currentPage = targetIndex
    }

    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        self.pageControl.currentPage = pagerView.currentIndex
    }

}
