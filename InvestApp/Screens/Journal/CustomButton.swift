//
//  CustomButton.swift
//  My Portfolio
//
//  Created by Сергей Петров on 26.03.2022.
//

import Foundation
import UIKit

class CustomButton: UIButton {
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                backgroundColor = .systemGreen
            } else {
                backgroundColor = .secondarySystemBackground
            }
        }
    }
}
