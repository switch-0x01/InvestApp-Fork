//
//  StockCell.swift
//  My Portfolio
//
//  Created by Mamkin itshnik on 08.03.2022.
//

import UIKit

class StockCell: UITableViewCell {
    
    lazy var testLabel: UILabel = {
        let label = UILabel()
        label.text = "Quik filter"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.contentView.addSubview(testLabel)
        NSLayoutConstraint.activate([
            testLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            testLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            testLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            testLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    //paste your needed parameters
    func setupCellModel() {
        
    }
}
