//
//  Stock.swift
//  StockNews
//
//  Created by Tracy Chen on 4/8/19.
//  Copyright © 2019 Tracy. All rights reserved.
//

import Foundation

class Stock {
    var stockTicker = ""
    var stockPercentChange = ""
    var stockLastPrice = 0.0
    
    func initializer (stockTicker:String, stockPercentChange:String, stockLastPrice: Double, stockIndexTickers:[String]) -> Stock {
        self.stockTicker = stockTicker
        self.stockPercentChange = stockPercentChange
        self.stockLastPrice = stockLastPrice
        return self
    }
}
