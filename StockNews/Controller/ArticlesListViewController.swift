//
//  ArticlesListViewController.swift
//  StockNews
//
//  Created by Tracy Chen on 4/2/19.
//  Copyright © 2019 Tracy. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class ArticlesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var articlesListTableView: UITableView!
    
    var dateTimeList:[Double] = []
    var dateTimeFormattedList:[String] = []
    var headlineList:[String] = []
    var sourceList:[String] = []
    var urlList:[String] = []
    var ticker = ""
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        articlesListTableView.delegate = self
        articlesListTableView.dataSource = self
        
        let token = "pk_11a5de39ee5c479b9e66905fe0c92117"
        
        AF.request("https://cloud.iexapis.com/beta/stock/\(ticker)/news/last/25?token=\(token)")
            .responseJSON
            { response in
                print("Request: \(String(describing: response.request))")   // original url request
                print("Response: \(String(describing: response.response))") // http url response
                print("Result: \(response.result)")                         // response serialization result
                
                if let json = response.result.value {
                    print("JSON: \(json)") // serialized json response
                }
                
                guard let responseJSON = response.result.value as? [[String: AnyObject]] else {
                    print("Error reading response")
                    return
                }
                
                var list:[Articles] = []
                responseJSON.forEach({ (item) in
                    list.append(Mapper<Articles>().map(JSONObject: item)!)
                })
                
                
                for item in list {
                    self.dateTimeList.append(item.dateTime!)
                    self.headlineList.append(item.headline!)
                    self.sourceList.append(item.source!)
                    self.urlList.append(item.URL! + "?token=\(token)")
                }

                for i in self.dateTimeList {
                    let epocTime = i / 1000
                    //You need to convert it from milliseconds dividing it by 1000
                    let articleDateFormat = Date(timeIntervalSince1970: Double(epocTime))
                    let dateFormatter = DateFormatter.init(withFormat: "MM/dd/yy hh:mm a", locale: "")
                    var dateString = dateFormatter.string(from: articleDateFormat)
                    self.dateTimeFormattedList.append(dateString)
                }
                
                self.articlesListTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return headlineList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let urlString = self.urlList[indexPath.row]
        if let url = URL(string: urlString)
        {
            UIApplication.shared.openURL(url)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as! myTableViewCell
        
        if headlineList.count != 0 {
            tableViewCell.headlineTableView?.text = "\(headlineList[indexPath.row])"
            tableViewCell.dateTableView?.text = "\(dateTimeFormattedList[indexPath.row])"
            tableViewCell.sourceTableView?.text = "\(sourceList[indexPath.row])"
            tableViewCell.URLTableView?.text = "\(urlList[indexPath.row])"
        
        }
        return tableViewCell
    }
}
