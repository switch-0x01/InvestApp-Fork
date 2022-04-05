//
//  BurseViewDataSource.swift
//  My Portfolio
//
//  Created by Mamkin itshnik on 08.03.2022.
//

import UIKit

extension BurseViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return proxyDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: StockCell.self), for: indexPath)
        (cell as? StockCell)?.testLabel.text = "\(indexPath.row)"
        return cell
    }
}
