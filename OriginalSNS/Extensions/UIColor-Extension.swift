//
//  UIColor-Extension.swift
//  OriginalSNS
//
//  Created by 村形皇映 on 2021/09/05.
//

import UIKit

extension UIColor{
    static func rgb(red:CGFloat ,green:CGFloat ,blue:CGFloat ) -> UIColor{
        return self.init(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}
