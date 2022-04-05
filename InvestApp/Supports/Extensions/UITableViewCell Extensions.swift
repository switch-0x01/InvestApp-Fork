//
//  UITableViewCell Extensions.swift
//  My Portfolio
//
//  Created by Алексей Агеев on 26.03.2022.
//

import UIKit


extension UITableViewCell {
    func setupContent(image: UIImage? = nil, text: String? = nil, secondaryText: String? = nil) {
        if #available(iOS 14, *) {
            var content = self.defaultContentConfiguration()
            
            content.image = image
            content.text = text
            content.secondaryText = secondaryText
            
            self.contentConfiguration = content
            
        } else { // fallback for iOS 13
            self.imageView?.image = image
            self.textLabel?.text = text
            self.detailTextLabel?.text = secondaryText
        }
    }
}
