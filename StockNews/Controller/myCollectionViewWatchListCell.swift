//
//  myCollectionViewWatchListCell.swift
//  StockNews
//
//  Created by Tracy Chen on 4/1/19.
//  Copyright © 2019 Tracy. All rights reserved.
//

import UIKit

protocol watchListCellDelegate: class {
    func delete(cell: myCollectionViewWatchListCell)
}

class myCollectionViewWatchListCell: UICollectionViewCell {

    @IBOutlet weak var tickerWLLabel: UILabel!
    @IBOutlet weak var priceWLLabel: UILabel!
    @IBOutlet weak var percentChangeWLLabel: UILabel!
    @IBOutlet weak var deleteButton: UIVisualEffectView!
    
    weak var delegate: watchListCellDelegate?
    
    @IBAction func deleteButtonDidTap(_ sender: Any) {
        delegate?.delete(cell: self)
    }
}
