//
//  UIView + Ext.swift
//  My Portfolio
//
//  Created by Илья Андреев on 03.03.2022.
//

import UIKit

extension UIView {
    func addSubViews(_ views: UIView...) {
        views.forEach {
            addSubview($0)
        }
    }
}
