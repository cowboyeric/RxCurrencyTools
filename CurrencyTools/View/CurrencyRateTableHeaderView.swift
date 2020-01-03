//
//  CurrencyRateTableHeaderView.swift
//  CurrencyTools
//
//  Created by Eric on 12/28/19.
//  Copyright © 2019 Eric. All rights reserved.
//

import UIKit

class CurrencyRateTableHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var equityLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var marginLabel: UILabel!
    @IBOutlet weak var usedLabel: UILabel!
    
    var balanceData: BalanceData? {
        didSet {
            guard let balanceData = balanceData else { return }
            self.equityLabel.text = String(format: "$%.2f", balanceData.equity)
            self.balanceLabel.text = String(format: "$%.2f", balanceData.balance)
            self.marginLabel.text = String(format: "$%.2f", balanceData.margin)
            self.usedLabel.text = String(format: "$%.2f", balanceData.used)
        }
    }
}
