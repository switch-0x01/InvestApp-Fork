//
//  CustomTextField.swift
//  My Portfolio
//
//  Created by Никита on 17.03.2022.
//
import UIKit

class CustomTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.frame = CGRect(x: 0, y: 0, width: 100.00, height: 40.00)
        self.textColor = .white
        self.backgroundColor = .secondarySystemGroupedBackground
        self.layer.cornerRadius = 15
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
