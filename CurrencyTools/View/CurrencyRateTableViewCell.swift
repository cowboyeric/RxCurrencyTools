//
//  CurrencyRateTableViewCell.swift
//  CurrencyTools
//
//  Created by Eric on 12/16/19.
//  Copyright © 2019 Eric. All rights reserved.
//

import UIKit

enum tradingAction {
    case buy
    case sell
}

final class CurrencyRateTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    @IBOutlet weak var sellLabel: UILabel!
    @IBOutlet weak var buyLabel: UILabel!
    
    
    var ratePair: RatePair? {
        didSet {
            guard let ratePair = ratePair else { return }
            if ratePair.pair.count == 6 {
                //MARK: Simply assume rate pair is always 6 digit
                
                titleLabel.text = "\(ratePair.pair.prefix(3))/\(ratePair.pair.suffix(3))"
            }else{
                titleLabel.text = ratePair.pair
            }
            subTitleLabel.text = "\(titleLabel.text ?? ratePair.pair) : Forex"
            
            let buyPrice = self.getPriceBy(rate: ratePair.rate, action: .buy)
            let sellPrice = self.getPriceBy(rate: ratePair.rate, action: .sell)
            //MARK: Calculate buy/sell price by add/remove 1-10 pip
            
            buyLabel.text = "\(String(format: "$%.4f", buyPrice))"
            sellLabel.text = "\(String(format: "$%.4f", sellPrice))"
            if ratePair.originalRate > 0 {
                let persentageChange = ((ratePair.rate - ratePair.originalRate)/ratePair.originalRate) * 100
                changeLabel.textColor = (persentageChange > 0) ? UIColor(hex:0x3cde5a) : UIColor(hex:0xff3768)
                //MARK: Using color reflect price up/down trend
                changeLabel.text = "\(String(format: "%.2f", fabs(persentageChange)))%"
            }else{
                changeLabel.text = " - "
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    internal func getPriceBy(rate: Double, action: tradingAction) -> Double{
        let decimalCount = rate.decimalCount()
        let pipUnit = 1/pow(10, (decimalCount > 4) ? 4 : decimalCount)
        let pipValue = (NSDecimalNumber(decimal: pipUnit).doubleValue / rate).rounded(toPlaces: 4)
        switch action {
        case .buy:
            return rate + (pipValue * Double(Int.random(in: 1...10)))
        case .sell:
            return rate - (pipValue * Double(Int.random(in: 1...10)))
        }
    }
}


extension Double {
    func decimalCount() -> Int {
        if self == Double(Int(self)) {
            return 0
        }
        
        let integerString = String(Int(self))
        let doubleString = String(Double(self))
        let decimalCount = doubleString.count - integerString.count - 1
        
        return decimalCount
    }
    
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
