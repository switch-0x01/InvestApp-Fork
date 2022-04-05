//
//  MainViewController.swift
//  My Portfolio
//
//  Created by Владислав Седенков on 15.02.2022.
//

import UIKit

fileprivate enum TabBarCategory {
    case onboard
    case portfolio
    case analytics
    case burse
}

final class MainViewController: UITabBarController, DependencyHolder {
    weak var _repository: DependencyRepository?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let networkManager = NetworkingManager()
        companyGateway.fetchAllCompanies { result in
            switch result {
                case .success(let companies):
                    for company in companies {
                        networkManager.fetchStock(symbol: company.ticker ?? "") { result in
                            switch result {
                                case .success(let stock):
                                    if let newCurrentPrice = stock.latestPrice {
                                        companyGateway.updateCompany(company: company,
                                                                     newCompanyName: nil,
                                                                     newIndustry: nil,
                                                                     newCompanyTicker: nil,
                                                                     currentStockPrice: NSDecimalNumber(value: newCurrentPrice).decimalValue) { result in
                                            switch result {
                                                case .success(let company):
                                                    print("success update")
                                                case .failure(let error):
                                                    print("fail to update company")
                                            }
                                        
                                        }
                                    }
                                case .failure(_):
                                    print("fail to fetch stock!")
                            }
                        }
                    }
                case .failure(_):
                    print("fail to fet companies from storage")
            }
        }
        createTabBar()
        self.delegate = self
    }
}


//MARK: UI
extension MainViewController {
    
    private func createTabBar() {
        
        //controllers
        let onboardVC = OnboardViewController()
        let analyticsVC = AnalyticsViewController()
        let portfolioVC = PortfolioViewController()
        let navPortfolioVC = UINavigationControllerWithDependency(rootViewController: portfolioVC)
        let burseVC = BurseViewController()
        let navBurseVC = UINavigationControllerWithDependency(rootViewController: burseVC)
        //image
        let bold = UIImage.SymbolConfiguration(weight: .medium)
        let onboardImage = UIImage(systemName: createTabBarImage(category: .onboard), withConfiguration: bold)
        let analyticsImage = UIImage(systemName: createTabBarImage(category: .analytics), withConfiguration: bold)
        let portfolioImage = UIImage(systemName: createTabBarImage(category: .portfolio), withConfiguration: bold)
        let burseImage = UIImage(systemName: createTabBarImage(category: .burse), withConfiguration: bold)
        onboardVC.tabBarItem.image = onboardImage
        analyticsVC.tabBarItem.image = analyticsImage
        portfolioVC.tabBarItem.image = portfolioImage
        burseVC.tabBarItem.image = burseImage
        //title
        onboardVC.tabBarItem.title = createTabBarTitle(category: .onboard)
        analyticsVC.tabBarItem.title = createTabBarTitle(category: .analytics)
        portfolioVC.tabBarItem.title = createTabBarTitle(category: .portfolio)
        burseVC.tabBarItem.title = createTabBarTitle(category: .burse)
        //setup
        viewControllers = [onboardVC, navPortfolioVC, analyticsVC, navBurseVC]
    }
    private func createTabBarImage(category: TabBarCategory) -> String {
        switch category {
        case .onboard:
            return "newspaper.fill"
        case .portfolio:
            return "bag.fill"
        case .analytics:
            return "chart.bar.fill"
        case .burse:
            return "cart.fill"
        }
    }
    
    private func createTabBarTitle(category: TabBarCategory) -> String {
        switch category {
        case .onboard:
            return "Onboard"
        case .portfolio:
            return "Портфель"
        case .analytics:
            return "Аналитика"
        case .burse:
            return "Акции"
        }
    }
}

extension MainViewController: UITabBarControllerDelegate{
    func tabBarController(_ controller: UITabBarController, didSelect: UIViewController) {
        injectDependency(to: didSelect)
    }
}
