//
//  BurseTableDelegate.swift
//  My Portfolio
//
//  Created by Mamkin itshnik on 08.03.2022.
//

import UIKit

extension BurseViewController: UITableViewDelegate {
    func setUpTableView() {
        tableView.register(StockCell.self, forCellReuseIdentifier: String(describing: StockCell.self))
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        repository?.logger.log("Did select \(indexPath.row) in \(self.description)")
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
