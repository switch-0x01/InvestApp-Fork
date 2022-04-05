//
//  BurseViewController+UISearch.swift
//  My Portfolio
//
//  Created by Алексей Агеев on 12.03.2022.
//

import UIKit

extension BurseViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        repository?.logger.log("Try search '\(text)' in \(self.description)")
    }
}
