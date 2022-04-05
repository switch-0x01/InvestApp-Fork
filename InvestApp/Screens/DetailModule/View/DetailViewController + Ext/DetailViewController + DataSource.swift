//
//  DetailViewController + DataSource.swift
//  My Portfolio
//
//  Created by Илья Андреев on 15.03.2022.
//

import UIKit

extension DetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        Sections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Sections.rowsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: InfoTableViewCell.description(), for: indexPath)
        
        switch Sections.allCases[indexPath.section] {
            
        case .price:
            cell.textLabel?.text = viewModel.priceSectionLeftLabels[indexPath.row]
            cell.detailTextLabel?.text = viewModel.priceSectionRightLabels[indexPath.row]
        case .account:
            cell.textLabel?.text = viewModel.accountSectionLeftLabels[indexPath.row]
            cell.detailTextLabel?.text = viewModel.accountSectionRightLabels[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Sections.allCases[section] {
        case .price: return viewModel.priceTitle
        case .account: return viewModel.accountTitle
        }
    }
}
