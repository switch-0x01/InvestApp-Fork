//
//  PortfolioViewController+UITableViewDataSource.swift
//  My Portfolio
//
//  Created by Алексей Агеев on 26.03.2022.
//

import UIKit


extension PortfolioViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        TableViewSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentSection = TableViewSection.allCases[section]
        
        switch currentSection {
        case .stats:
            return TableViewSection.StatsCell.allCases.count
        case .journal:
            return TableViewSection.JournalCell.allCases.count
        case .cash:
            return TableViewSection.CashCell.allCases.count
        case .stocks:
            return viewModel.companies.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let currentSection = TableViewSection.allCases[section]
        
        switch currentSection {
        case .stats:
            return nil
        case .cash:
            return "Денежные средства"
        case .journal:
            return nil
        case .stocks:
            return "Открытые позиции"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentSection = TableViewSection.allCases[indexPath.section]
        
        var cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        
        var text: String?
        var secondaryText: String?
        
        switch currentSection {
        case .stats:
            cell.selectionStyle = .none
            
            let currentCell = TableViewSection.StatsCell.allCases[indexPath.row]
            switch currentCell {
            case .balance:
                text = "Баланс счёта"
                secondaryText = NumberFormatter.rubFormatter.string(for: viewModel.portfolioWorth)
            case .sharpe:
                text = "Коэффициент Шарпа"
                secondaryText = NumberFormatter.decimalFormatter.string(for: viewModel.sharpe)
            case .beta:
                text = "Бета относительно индекса"
                secondaryText = NumberFormatter.decimalFormatter.string(for: viewModel.beta)
            }
            cell.setupContent(text: text, secondaryText: secondaryText)
            
        case .cash:
            cell.selectionStyle = .none
            
            let currentCell = TableViewSection.CashCell.allCases[indexPath.row]
            switch currentCell {
            case .rub:
                text = "RUB"
                secondaryText = NumberFormatter.rubFormatter.string(for: viewModel.cash) ?? ""
            }
            cell.setupContent(text: text, secondaryText: secondaryText)
            
        case .journal:
            let currentCell = TableViewSection.JournalCell.allCases[indexPath.row]
            
            switch currentCell {
            case .goToJournal:
                text = "Дневник сделок"
                cell.accessoryType = .disclosureIndicator
            }
            cell.setupContent(text: text, secondaryText: secondaryText)

            
        case .stocks:
            guard let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: PortfolioTableViewCell.identifier) else {
                fatalError("No cell with such identifier")
            }
            cell = setupCompanyCell(cell: dequeuedCell, company: viewModel.companies[indexPath.row])
        }
        
        return cell
    }
}
