//
//  PortfolioViewController+UITableViewDelegate.swift
//  My Portfolio
//
//  Created by Алексей Агеев on 26.03.2022.
//

import UIKit


extension PortfolioViewController: UITableViewDelegate {
    
    //MARK: Actions
    private func presentJournalViewController() {
        let vc = UINavigationControllerWithDependency(rootViewController: JournalViewController())
        vc.modalPresentationStyle = .fullScreen
        injectDependency(to: vc)
        present(vc, animated: true)
    }
    
    private func pushDetailViewController(for ticker: String) {
        guard let repository = repository else {
            fatalError("Please inject dependencies into PortfolioViewController")
        }
        
        let detailViewModel = DetailViewModel(ticker: ticker, dataSource: DataSource(repository: repository))
        
        let detailViewController = DetailViewController(viewModel: detailViewModel)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentSection = TableViewSection.allCases[indexPath.section]
        
        switch currentSection {
        case .journal:
            presentJournalViewController()
        case .stocks:
            let selectedTicker = viewModel.ticker(for: indexPath.row)
            pushDetailViewController(for: selectedTicker)
        default:
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
