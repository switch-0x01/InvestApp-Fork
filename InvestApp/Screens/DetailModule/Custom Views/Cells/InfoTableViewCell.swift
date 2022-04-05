//
//  InfoTableViewCell.swift
//  My Portfolio
//
//  Created by Илья Андреев on 03.03.2022.
//

import UIKit

class InfoTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
