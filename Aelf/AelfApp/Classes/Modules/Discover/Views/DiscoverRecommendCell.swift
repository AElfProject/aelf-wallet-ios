//
//  DiscoverRecommendCell.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/6.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

/// 推荐的游戏，内置 Collection，最多2行展示。
class DiscoverRecommendCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var didSelectClosure: ((DiscoverDapp) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        setupCollectionView()
    }

    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(nibWithCellClass: DiscoverGameCell.self)
        collectionView.isScrollEnabled = false
    }

    var dataSource = [DiscoverDapp]() {
        didSet {
            collectionView.reloadData()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension DiscoverRecommendCell:
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (screenBounds.width - 20*2)/4
        return CGSize(width: w, height: w + 25)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: DiscoverGameCell.self, for: indexPath)
        cell.item = dataSource[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let item = dataSource[indexPath.row]
        didSelectClosure?(item)
    }

}
