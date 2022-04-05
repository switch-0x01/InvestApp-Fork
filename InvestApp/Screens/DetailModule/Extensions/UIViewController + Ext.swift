//
//  UIViewController + Ext.swift
//  My Portfolio
//
//  Created by Илья Андреев on 15.03.2022.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alertController: UIAlertController = .init(
            title: title,
            message: message,
            preferredStyle: UIAlertController.Style.alert
        )
        
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default))
        present(alertController, animated: true, completion: completion)
    }
}
