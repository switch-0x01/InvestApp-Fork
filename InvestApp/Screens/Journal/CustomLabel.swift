//
//  CustomLabel.swift
//  My Portfolio
//
//  Created by Никита on 17.03.2022.
//

import UIKit

class CustomLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.textColor = .white
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

