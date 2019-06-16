//
//  ViewController.swift
//  StockNews
//
//  Created by Tracy Chen on 3/31/19.
//  Copyright © 2019 Tracy. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, AddStockToWishListDelegate {

    @IBOutlet weak var USMarketLabel: UILabel!
    @IBOutlet weak var refreshLabel: UILabel!
    @IBOutlet weak var watchListLabel: UILabel!
    @IBOutlet weak var USMarketCollectionView: UICollectionView!
    @IBOutlet weak var watchListCollectionView: UICollectionView!
    @IBOutlet weak var editButtonLabel: UIButton!
    @IBAction func editButton(_ sender: Any) {
        if (isEditingCollectionView) { // isEditingCollectionView == true
            editButtonLabel.setTitle("EDIT", for: .normal)
            isEditingCollectionView = false
        }
        else{
            editButtonLabel.setTitle("CANCEL", for: .normal)
            isEditingCollectionView = true
        }
     watchListCollectionView.reloadData()
    }

    let collectionViewFooterReuseIdentifier = "watchListFooterView"
    let addStockToWishlistSegue = "addStockToWishlistSegue"
    let seguefromCollectionView = "seguefromCollectionView"
    var selectedTicker = ""
    var tickerList:[String] = []
    var indices:[String] = ["DIA", "ONEQ", "SPY"]
    var stockArrayforIndex: [Stock] = []
    var indexLastPriceArray:[Double] = []
    var indexPriceChangeArray:[String] = []
    var stockTickerList:[String] = []
    var stockArray: [Stock] = []
    var indexLastPriceWLArray:[Double] = []
    var indexPriceChangeWLArray:[String] = []
    var isEditingCollectionView = false
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .gray
        refreshControl.addTarget(self, action: #selector(requestData), for: .valueChanged)
        return refreshControl
    }()
    

    
   override func viewDidLoad() {
        super.viewDidLoad()

        //UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    
        USMarketCollectionView.delegate = self
        watchListCollectionView.delegate = self
        
        USMarketCollectionView.dataSource = self
        watchListCollectionView.dataSource = self
        
        watchListCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: collectionViewFooterReuseIdentifier)
    
        let token = "pk_11a5de39ee5c479b9e66905fe0c92117"
    
        for i in indices{
            AF.request("https://cloud.iexapis.com/beta/stock/\(i)/quote/latestPrice;changePercent?token=\(token)")
                .responseJSON
                { response in
                    print("Request: \(String(describing: response.request))")   // original url request
                    print("Response: \(String(describing: response.response))") // http url response
                    print("Result: \(response.result)")                         // response serialization result
                    
                    if let json = response.result.value {
                        print("JSON: \(json)") // serialized json response
                    }
                    
                    guard let responseJSON = response.result.value as? [String: AnyObject] else {
                        print("Error reading response")
                        return
                    }
                    
                    let indexObjectInfo = Mapper<StockInfo>().map(JSONObject: responseJSON)
                    let indexStocks = Stock.init()
                    indexStocks.stockTicker = indexObjectInfo?.symbol! ?? ""
                    indexStocks.stockLastPrice = indexObjectInfo?.latestPrice! ?? 0
                    let percentChangeCalc = ((indexObjectInfo?.changePercent ?? 0) * 100)
                    let roundedPercentChangeCalc = String(format: "%.2f", percentChangeCalc)
                    indexStocks.stockPercentChange = String(format: "%.2f", percentChangeCalc)
                    self.stockArrayforIndex.append(indexStocks)
                    let lastUpdatedIEXTime = indexObjectInfo?.latestIEXUpdateTime
                    let epocTime = (lastUpdatedIEXTime ?? 0) / 1000
                    //You need to convert it from milliseconds dividing it by 1000
                    let articleDateFormat = Date(timeIntervalSince1970: Double(epocTime))
                    let dateFormatter = DateFormatter.init(withFormat: "hh:mm a MM/dd/yy", locale: "")
                    var dateString = dateFormatter.string(from: articleDateFormat)
                    self.refreshLabel.text = "DIA tracks the Dow, ONEQ tracks the NASDAQ and SPY tracks the S&P 500"
                    self.USMarketCollectionView.reloadData()
            }
            //this will refresh data
            watchListCollectionView.refreshControl = refresher
        }
    
        let storage = UserDefaults.standard.array(forKey: "tickerDefaultList") ?? []
        stockTickerList = storage as! [String]
//        watchListCollectionView.reloadData()
        updateLatestPriceAndPercentageChange(stockTickerList: stockTickerList)
    }

    @objc
    func requestData() {
        updateLatestPriceAndPercentageChange(stockTickerList: stockTickerList)
        
        let deadline = DispatchTime.now() + .milliseconds(700)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
        self.refresher.endRefreshing()
        }
    }

    // this func and shouldAutorotate below prevents autorotate of VC
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    func updateTickerList(sender: String) {
        if !stockTickerList.contains(sender){
            let stock = Stock.init()
            stock.stockTicker = sender
            stockArray.append(stock)
            stockTickerList.append(stock.stockTicker)
            UserDefaults.standard.set(stockTickerList, forKey: "tickerDefaultList")
            updateLatestPriceAndPercentageChange(stockTickerList: stockTickerList)
            }
        }
    
    func updateLatestPriceAndPercentageChange(stockTickerList: [String]){
        for ticker in stockTickerList {
            
            AF.request("https://cloud.iexapis.com/beta/stock/\(ticker)/quote/latestPrice;changePercent?token=pk_11a5de39ee5c479b9e66905fe0c92117")
                .responseJSON
                { response in
                    print("Request: \(String(describing: response.request))")   // original url request
                    print("Response: \(String(describing: response.response))") // http url response
                    print("Result: \(response.result)")                         // response serialization result
                    
                    if let json = response.result.value {
                        print("JSON: \(json)") // serialized json response
                    }
                    
                    guard let responseJSON = response.result.value as? [String: AnyObject] else {
                        print("Error reading response")
                        return
                    }
                    
                    //Check if ticker is in stockArray
                    if (self.stockArray.contains(where: { (stock) -> Bool in
                        return stock.stockTicker == ticker
                    })){
                        // Update percent change and latest price
                        let indexWLObjectInfo = Mapper<StockInfo>().map(JSONObject: responseJSON)
                        let indexOfStock = self.stockArray.firstIndex(where: { (stock) -> Bool in
                            return stock.stockTicker == ticker
                        })
                        self.stockArray[indexOfStock!].stockLastPrice = indexWLObjectInfo?.latestPrice! ?? 0
                        self.stockArray[indexOfStock!].stockPercentChange = String(format: "%.2f", (indexWLObjectInfo?.changePercent ?? 0) * 100)
                    }
                    else{
                        //3b - Create a new stock object and populate. Then add it to stockArray
                        let stock = Stock.init()
                        let indexWLObjectInfo = Mapper<StockInfo>().map(JSONObject: responseJSON)
                        stock.stockTicker = ticker
                        stock.stockLastPrice = indexWLObjectInfo?.latestPrice! ?? 0
                        let percentChangeCalc = ((indexWLObjectInfo?.changePercent ?? 0) * 100)
                        stock.stockPercentChange = String(format: "%.2f", percentChangeCalc)
                        self.stockArray.append(stock)
                    }
                    // Reload CV
                    self.watchListCollectionView.reloadData()
        }
    }
    }
    
    @objc func addStockButtonPressed(sender: UIButton){
        performSegue(withIdentifier: addStockToWishlistSegue, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == addStockToWishlistSegue {
            let vc = segue.destination as! AddStockToWishListViewController
            vc.addStockToWishListDelegate = self
        }
        if segue.identifier == seguefromCollectionView {
            let vc = segue.destination as! ArticlesListViewController
            vc.ticker = selectedTicker
        }
    }
    
    //this handle the tapping of watchlistCell to segue to Articles VC
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.USMarketCollectionView {
            //nothing
        }
        else{
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ArticlesListViewController") as! ArticlesListViewController
            vc.ticker = stockArray[indexPath.item].stockTicker
            present(vc, animated: true, completion: nil)
        }
        
    }
    
    func collectionView(_ collectionView:UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.USMarketCollectionView {
            //return indices.count // replace w count for data in A
            return stockArrayforIndex.count
        }
        return stockArray.count // replace w count for data in B - watchlistCell
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.USMarketCollectionView {
            let cellA = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! myCollectionViewCell
            cellA.indexLabel.text = stockArrayforIndex[indexPath.item].stockTicker
               if stockArrayforIndex.count == indices.count {
                cellA.layer.cornerRadius = 10
                cellA.layer.masksToBounds = true
                cellA.lastTradePriceLabel.text = "$\(stockArrayforIndex[indexPath.item].stockLastPrice)"
                let percentChangeIntMarket = Double(stockArrayforIndex[indexPath.item].stockPercentChange)
                if (percentChangeIntMarket ?? 0.0  > 0.0){
                    cellA.percentChangeLabel.text = "\(stockArrayforIndex[indexPath.item].stockPercentChange)%"
                    cellA.percentChangeLabel.textColor = UIColor.init(red:0.36, green:0.72, blue:0.36, alpha:1.0)
                }
                else{
                    cellA.percentChangeLabel.text = "\(stockArrayforIndex[indexPath.item].stockPercentChange)%"
                    cellA.percentChangeLabel.textColor = UIColor.init(red:0.95, green:0.05, blue:0.28, alpha:1.0)
                }
            }
            return cellA
            }
        else {
            let cellB = collectionView.dequeueReusableCell(withReuseIdentifier: "watchListCell", for: indexPath) as! myCollectionViewWatchListCell
            cellB.layer.cornerRadius = 10
            cellB.layer.masksToBounds = true
            cellB.tickerWLLabel.text = stockArray[indexPath.item].stockTicker
            cellB.priceWLLabel.text = "$\(stockArray[indexPath.item].stockLastPrice)"
    
            let percentChange = stockArray[indexPath.item].stockPercentChange
            cellB.percentChangeWLLabel.text = "\(percentChange)%"
            let percentChangeInt = Double(stockArray[indexPath.item].stockPercentChange)
            if (percentChangeInt ?? 0.0  > 0.0){
                // Generated from site - https://www.uicolor.xyz/#/hex-to-ui
                cellB.backgroundColor = UIColor(red:0.36, green:0.72, blue:0.36, alpha:1.0)
            }
            else{
                cellB.backgroundColor = UIColor(red:0.95, green:0.05, blue:0.28, alpha:1.0)
            }
            cellB.delegate = self
            if (isEditingCollectionView) {
                cellB.deleteButton.isHidden = false
            }
            else{
                cellB.deleteButton.isHidden = true
            }
//               }
            return cellB
            }
        }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: collectionViewFooterReuseIdentifier, for: indexPath as IndexPath)
        let addButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: collectionView.frame.width, height: 50))
        addButton.setTitle("+", for: .normal)
        //addButton.setTitleColor(UIColor.black, for: .normal)
        addButton.setTitleColor(UIColor.init(red: (19/255), green: (122/255), blue: (254/255), alpha: 1), for: .normal)
        addButton.addTarget(self, action: #selector(ViewController.addStockButtonPressed(sender:)), for: .touchUpInside)
        footerView.backgroundColor = UIColor.white
        //footerView.backgroundColor = UIColor.init(red: (154/255), green: (154/255), blue: (154/255), alpha: 1)
        footerView.layer.borderWidth = 2.0
        //footerView.layer.borderColor = UIColor.init(red: 19, green: 122, blue: 254, alpha: 1.0).cgColor
        footerView.layer.borderColor = UIColor.init(red: (19/255), green: (122/255), blue: (254/255), alpha: 1).cgColor
        footerView.addSubview(addButton)
        return footerView

    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        print(indexPath.item)
        return true
    }
}

extension ViewController : watchListCellDelegate {
    func delete(cell: myCollectionViewWatchListCell) {
        if let indexPath = watchListCollectionView?.indexPath(for: cell) {
            // 1. delete the item from the data source
            stockArray.remove(at: indexPath.item)
            stockTickerList.remove(at: indexPath.item)
            UserDefaults.standard.set(stockTickerList, forKey: "tickerDefaultList")
            // 2. delete cell at that index path from the collection view
            watchListCollectionView?.deleteItems(at: [indexPath])
            watchListCollectionView.reloadData()
        }
    }
}

