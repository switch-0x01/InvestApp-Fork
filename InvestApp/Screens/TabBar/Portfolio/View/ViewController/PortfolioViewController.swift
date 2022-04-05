//
//  PortfolioViewController.swift
//  My Portfolio
//
//  Created by Владислав Седенков on 15.02.2022.
//

import UIKit
import Combine


//MARK: UIViewController
final class PortfolioViewController: UIViewController, DependencyHolder {
    weak var _repository: DependencyRepository?
    
    let viewModel = PortfolioViewModel()
    private var viewModelSubscription: AnyCancellable?
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        
        viewModelSubscription = viewModel.objectWillChange.sink { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        setupNavigationBar()
        setupTableView()
    }
    
    func dependencyInjected() {
        injectDependency(to: viewModel)
    }

    //MARK: UI initial setup
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Портфель"
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(PortfolioTableViewCell.self, forCellReuseIdentifier: PortfolioTableViewCell.identifier)
    }
    
    //MARK: UI
    func setupCompanyCell(cell: UITableViewCell, company: PortfolioModel.PortfolioCompany) -> UITableViewCell {
        guard let cell = cell as? PortfolioTableViewCell else {
            fatalError("unknown cell type")
        }
        
        Task {
            async let imageData = viewModel.companyImageData(ticker: company.ticker)
            cell.setImage(UIImage(data: await imageData))
        }
        
        cell.setContent(company: company)
        cell.accessoryType = .disclosureIndicator

        return cell
    }
}

//MARK: extensions
extension PortfolioViewController {
    /// This enum's structure represents PortfolioViewController's UITableView hierarchy.
    enum TableViewSection: CaseIterable {
        case stats
        case cash
        case journal
        case stocks
        
        enum StatsCell: CaseIterable {
            case balance
            case sharpe
            case beta
        }
        
        enum CashCell: CaseIterable {
            case rub
        }
        
        enum JournalCell: CaseIterable {
            case goToJournal
        }
    }
}
