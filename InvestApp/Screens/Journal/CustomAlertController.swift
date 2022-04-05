//
//  CustomAlertController.swift
//  My Portfolio
//
//  Created by Никита on 01.04.2022.
//

import UIKit

enum ResultAlert {
    case error
    case success
}

class CustomAlertController: UIAlertController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.view.layer.cornerRadius = 15
        self.view.layer.borderWidth = 3
    }
}
