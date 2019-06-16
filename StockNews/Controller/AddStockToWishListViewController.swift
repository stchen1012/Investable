//
//  AddStockToWishListViewController.swift
//  StockNews
//
//  Created by Benny on 4/6/19.
//  Copyright © 2019 Tracy. All rights reserved.
//

import UIKit

class AddStockToWishListViewController: UIViewController {

    @IBOutlet weak var guidanceLabel: UILabel!
    @IBOutlet weak var addStockTextfield: UITextField!
    weak var addStockToWishListDelegate:AddStockToWishListDelegate?
    @IBAction func onBackTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // this func and shouldAutorotate below prevents autorotate of VC
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    @IBAction func savePressed(_ sender: Any) {
        addStockToWishListDelegate?.updateTickerList(sender: addStockTextfield.text!)
        dismiss(animated: true, completion: nil)
    }
    
}

protocol AddStockToWishListDelegate: AnyObject {
    func updateTickerList(sender: String)
}
