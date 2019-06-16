//
//  Articles.swift
//  StockNews
//
//  Created by Tracy Chen on 4/2/19.
//  Copyright © 2019 Tracy. All rights reserved.
//

import Foundation
import ObjectMapper

class Articles: Mappable {
    
    var dateTime: Double?
    var headline: String?
    var image: String?
    var source: String?
    var URL: String?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        dateTime    <- map["datetime"]
        headline    <- map["headline"]
        image       <- map["image"]
        source      <- map["source"]
        URL         <- map["url"]
    }
    
    func initialize (dateTime: Double, headline: String, image: String, source: String, URL: String) -> Articles {
        self.dateTime = dateTime
        self.headline = headline
        self.image = image
        self.source = source
        self.URL = URL
        return self
    }
}
