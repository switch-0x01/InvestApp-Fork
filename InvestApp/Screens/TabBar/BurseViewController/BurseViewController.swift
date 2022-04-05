//
//  BurseViewController.swift
//  My Portfolio
//
//  Created by Владислав Седенков on 15.02.2022.
//

import UIKit

final class BurseViewController: UIViewController, DependencyHolder {
    weak var _repository: DependencyRepository?
    
    var proxyDataSource = Array(repeating: 1, count: 30)
    
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        view.addSubview(tableView)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Биржа"

        setUpTableView()
        setupSearchController()
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Type something here to search"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.searchBar.searchTextField.insertToken(UISearchToken(icon: nil, text: "Фильтр"), at: 0)
        searchController.searchBar.searchTextField.insertToken(UISearchToken(icon: nil, text: "по"), at: 1)
        searchController.searchBar.searchTextField.insertToken(UISearchToken(icon: nil, text: "акциям"), at: 2)
    }
}
