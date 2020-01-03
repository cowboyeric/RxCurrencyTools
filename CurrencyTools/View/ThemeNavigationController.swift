//
//  ThemeNavigationController.swift
//  CurrencyTools
//
//  Created by Eric on 27/12/2019.
//  Copyright © 2019 Eric. All rights reserved.
//

import UIKit

class ThemeNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.barTintColor = UIColor.themeColor
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        // Do any additional setup after loading the view.
    }
}

extension UIColor{
    static let themeColor = UIColor(hex: 0x443864)
    
    
    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
}
