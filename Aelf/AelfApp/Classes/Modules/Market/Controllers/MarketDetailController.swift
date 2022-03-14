//
//  MarketDetailController.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/5.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import AVFoundation

class MarketDetailController: BaseStaticTableController {

    @IBOutlet weak var contentChartView: Chart!
    @IBOutlet var detailArray: [UILabel]!
    @IBOutlet var titleArray: [UILabel]!
    @IBOutlet var segmentArray: [UIButton]!

    @IBOutlet weak var priceChangeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceMarketLabel: UILabel!
    
    let viewModel = MarketDetailViewModel()
    let kLineRefreshTrigger = PublishSubject<Void>()
    let timeTrigger = BehaviorSubject<Int>(value: 1) // 1：24小时  35：近一周 150：近一月

    var model:MarketCoinModel? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        addWhiteBackItem()
        setupUI()

        tableView.separatorStyle = .none
        setSegmentTag(tag: 0)
        loadChartView()
        addRightItem()
        bindViewModel()
    }

    func bindViewModel() {

        guard let model = model else { return }
        self.priceLabel.text = App.currencySymbol + (model.lastPrice ?? "")
//        self.priceLabel.hero.id = self.priceLabel.text
//        self.priceMarketLabel.text =

        title = (model.symbol?.uppercased() ?? "")
        
        SVProgressHUD.show(withStatus: nil)
        SVProgressHUD.setDefaultMaskType(.none)
        
        let refresh = Observable.of(Observable.just(()), kLineRefreshTrigger).merge()
        let input = MarketDetailViewModel.Input(currency: App.currency,
                                                name: model.identifier ?? "",
                                                type: 1,
                                                time: timeTrigger,
                                                loadKLine: refresh,
                                                loadData: Observable.just(()))
        let output = viewModel.transform(input: input)
        viewModel.output = output
//        viewModel.output?.dataSource.bind(onNext: { [weak self](detailModel) in
//            self?.updateUI(detailModel: detailModel)
//        }).disposed(by: rx.disposeBag)
        
        viewModel.output?.klineSource.bind(onNext: { [weak self](klineSource) in
            SVProgressHUD.dismiss()
            self?.updateView(klineSource: klineSource)
        }).disposed(by: rx.disposeBag)
    }

    func addRightItem() {

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: favouriteButton)
    }

    lazy var favouriteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "favour_outline"), for: .normal)
        button.setImage(UIImage(named: "favor_solid"), for: .selected)
        button.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)

        if let model = self.model {
           button.isSelected = model.exist()
        }
        return button
    }()

    @objc func favoriteButtonTapped() {

        guard let model = model else { return }
        
        // https://www.jianshu.com/p/d1f5b4ec3a1d
        AudioServicesPlaySystemSound(1519);
        if model.exist() {
            model.delete()
            favouriteButton.isSelected = false
        } else {
            model.save()
            favouriteButton.isSelected = true
        }
    }
    
    func setupUI() {
        
        guard let model = model else { return }
        
        priceMarketLabel.text = ""
        priceMarketLabel.isHidden = true
        
        let increase = model.increase?.double() ?? 0.0
        let format = (increase > 0 ? "+" : "-") + String(format: "%.2f",increase) + "%"
        
        self.priceChangeLabel.text = format.replacingOccurrences(of: "--", with: "-")
        if increase > 0 {//小于0
            self.priceChangeLabel.backgroundColor = .appGreen
        } else {
            self.priceChangeLabel.backgroundColor = .appRed
        }
        
        let titleList = ["marketValue","coin_intro_rank","coin_intro_vol24","coin_intro_total_supply"].map { $0.localized() }
        for i in 0..<4 {
            self.titleArray[i].text = titleList[i]
            if i == 0 {
                if App.currency.lowercased() == "usd" {
                    self.detailArray[i].text =  "$ " + (self.model?.marketValue)!
                } else {
                    self.detailArray[i].text =  "¥ " + (self.model?.marketValue)!
                }
            } else if i == 1 {
                self.detailArray[i].text = "#\(self.model?.marketValueTrans ?? "")"
            } else if i == 2 {
                if App.currency.lowercased() == "usd" {
                    self.detailArray[i].text = "$ " + (self.model?.totalVolume)!
                } else {
                    self.detailArray[i].text = "¥ " + (self.model?.totalVolume)!
                }
            } else if i == 3 {
                self.detailArray[i].text = self.model?.amountTrans ?? "--";
            }
        }

        for i in 4..<8 {
            self.titleArray[i].isHidden = true
            self.detailArray[i].isHidden = true
        }
        tableView.reloadData()
    }

//    func updateUI(detailModel: MarketDetailModel) {
//
//        let price = self.model?.lastPrice?.double() ?? 0
//        if App.currency.lowercased() == "usd" {
//            let p = price * (detailModel.usdToCNY.double() ?? 0)
//            self.priceMarketLabel.text = "¥" + p.format(maxDigits: 3)
//        } else {
//            let p = price / (detailModel.usdToCNY.double() ?? 1)
//            self.priceMarketLabel.text = "$" + p.format(maxDigits: 3)
//        }
//
//        let increase = model?.increase?.double() ?? 0.0
//        let format = (increase > 0 ? "+" : "-") + String(format: "%.2f",increase) + "%"
//        self.priceChangeLabel.text = format.replacingOccurrences(of: "--", with: "-")
//        if increase > 0 {//小于0
//            self.priceChangeLabel.backgroundColor = .appGreen
//        } else {
//            self.priceChangeLabel.backgroundColor = .appRed
//        }
//        let titleList = ["marketValue","coin_intro_rank","coin_intro_vol24","coin_intro_total_supply"].map { $0.localized() }
//        for i in 0..<4 {

//            self.titleArray[i].text = titleList[i]
//            if i == 0 {
//                self.detailArray[i].text = detailModel.marketValue
//            } else if i == 1 {
//                self.detailArray[i].text = "#\(detailModel.marketValueOrder)"
//
//            } else if i == 2 {
//                self.detailArray[i].text = detailModel.volTrans
//
//            } else if i == 3 {
//                self.detailArray[i].text = detailModel.supply
//
//            }
//        }
//
//        for i in 4..<8 {
//            self.titleArray[i].isHidden = true
//            self.detailArray[i].isHidden = true
//        }
//
//        self.tableView.reloadData()

//        if ((self.viewModel.output?.numberSectionOfRow.value)! > 0) {
//        }
//    }

    func configBaseInfo() {

        
    }
    
    func loadChartView()  {
        contentChartView.lineWidth = 0.5
        contentChartView.hideHighlightLineOnTouchEnd = true
        contentChartView.xLabelsTextAlignment = .center
        contentChartView.yLabelsOnRightSide = true
    }

    func updateView(klineSource: MarketTradeModel) {
        
        let array = klineSource.list
        if array!.isEmpty {
            return
        }
        var serieData: [Double] = []
        var labels: [Double] = []
        var labelsAsString: Array<String> = []
        var minValue = Double(999999999)
        var maxValue = Double(0)
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "MM-dd"
        let time = try? timeTrigger.value()
        if (time == 1) {
            dateFormatter.dateFormat = "HH:mm"
        }
        //  1：24小时  30：近一周 150：近一月
        let hCount = (try? timeTrigger.value()) == 1 ? 8:5
        let indexCount = array!.count/hCount
        for (index,value) in array!.enumerated() {
            
//            guard let modelArray = value else { return }
            
            let last: Double = value[1] as! Double
            serieData.append(last)
            minValue = min(minValue, last)
            maxValue = max(maxValue, last)

            let timeStamp = value[0] as! Int
            if timeStamp > 0 {
                let timeInterval:TimeInterval = TimeInterval(timeStamp/1000)
                let time = NSDate(timeIntervalSince1970:timeInterval)

                let monthAsString:String = dateFormatter.string(from: time as Date)
                if (labels.isEmpty  || index%indexCount == 0) {
                    labels.append(Double(index))
                    labelsAsString.append(monthAsString)
                }
            }
        }

        let series = ChartSeries(serieData)
        series.area = true
        self.contentChartView.xLabels = labels
        self.contentChartView.xLabelsFormatter = { (labelIndex: Int, labelValue: Double) -> String in
            return labelsAsString[labelIndex]
        }
        self.contentChartView.yLabelsFormatter = {
            (labelIndex: Int, labelValue: Double) -> String in
            
            if labelValue >= 1 {
                return String(format: "%.2f", labelValue)
            } else {
                return String(format: "%.3f", labelValue)
            }
        }
        self.contentChartView.minY = minValue - (maxValue - minValue)/2.0
        self.contentChartView.maxY = maxValue + (maxValue - minValue)/2.0
        self.contentChartView.removeAllSeries()
        self.contentChartView.add(series)

        tableView.reloadData()
        
    }
   
    @IBAction func segmentAction(_ sender: UIButton) {
        // type 24h week month year all
        let tag = sender.tag - 1001
        setSegmentTag(tag: tag)

        var timeSpace = 0
        if tag == 0 {
            timeSpace = 1
        } else if tag == 1 {
            timeSpace = 7
        } else {
            timeSpace = 30
        }
        
        timeTrigger.onNext(timeSpace)
        
//        SVProgressHUD.show(withStatus: nil)
//        SVProgressHUD.setDefaultMaskType(.none)

//        kLineRefreshTrigger.onNext(()) //触发 Kline 网络请求
    }
    func setSegmentTag(tag:NSInteger) {
        for i in 0..<segmentArray.count {
           let segmentButton = segmentArray[i]
            if i == tag {
                segmentButton.backgroundColor = .master
                segmentButton.setTitleColor(.white, for: .normal)
            } else {
                segmentButton.backgroundColor = .white
                segmentButton.setTitleColor(.black, for: .normal)
            }
        }
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        // Redraw chart on rotation
        contentChartView.setNeedsDisplay()
        
    }
}

// MARK: View Appear
extension MarketDetailController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.configBackgroundImage(image: UIImage(color: UIColor.master,
                                                                                      size: CGSize(width: 10, height: 10)), titleColor: UIColor.white)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        self.navigationController?.navigationBar.configBackgroundImage(image: UIImage(), titleColor: UIColor.black)
        self.navigationController?.navigationBar.shadowImage = nil
    }
}

// MARK: StatusBar
extension MarketDetailController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: Table Delegate
extension MarketDetailController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let value = viewModel.output?.numberOfSection.value {
            return value
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let value = viewModel.output?.numberSectionOfRow.value {
            return value
        }
        return 0
    }
}
