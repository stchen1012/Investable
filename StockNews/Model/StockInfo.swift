//
//  StockInfo.swift
//  StockNews
//
//  Created by Tracy Chen on 4/8/19.
//  Copyright © 2019 Tracy. All rights reserved.
//

import Foundation
import ObjectMapper

class StockInfo: Mappable {
    
    var symbol: String?
    var latestPrice: Double?
    var changePercent: Double?
    var latestUpdate: Double?
    var latestIEXUpdateTime: Double?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        symbol         <- map["symbol"]
        latestPrice    <- map["latestPrice"]
        changePercent  <- map["changePercent"]
        latestUpdate   <- map["latestUpdate"]
        latestIEXUpdateTime <- map["iexLastUpdated"]
    }
    
    func initialize (symbol: String, latestPrice: Double, changePercent: Double, latestUpdate: Double, latestIEXUpdateTime: Double) -> StockInfo {
        self.symbol = symbol
        self.latestPrice = latestPrice
        self.changePercent = changePercent
        self.latestUpdate = latestUpdate
        self.latestIEXUpdateTime = latestIEXUpdateTime
        return self
    }
}

