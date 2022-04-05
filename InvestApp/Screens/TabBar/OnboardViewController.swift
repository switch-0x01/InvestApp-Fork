//
//  OnboardViewController.swift
//  My Portfolio
//
//  Created by Владислав Седенков on 15.02.2022.
//

import UIKit

final class OnboardViewController: UIPageViewController, DependencyHolder {
    weak var _repository: DependencyRepository?
    
    private var portfolioButton: UIButton = {
        let button = UIButton()
        button.setTitle("Перейти к вкладке Портфель", for: .normal)
        button.setTitleColor(.systemGreen, for: .normal)
        button.addTarget(self, action: #selector(goPortfoliolVC), for: .touchUpInside)
        return button
    }()
    private var burseButton: UIButton = {
        let button = UIButton()
        button.setTitle("Перейти к вкладке Акции", for: .normal)
        button.setTitleColor(.systemGreen, for: .normal)
        button.addTarget(self, action: #selector(goBurseVC), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureUI()
    }
}

//MARK: Action
extension OnboardViewController {
    @objc private func goPortfoliolVC() {
        tabBarController?.selectedIndex = 1
    }
    
    @objc private func goBurseVC() {
        tabBarController?.selectedIndex = 3
    }
}

//MARK: UI
extension OnboardViewController {
    private func configureUI() {
        view.addSubview(portfolioButton)
        view.addSubview(burseButton)
        portfolioButton.translatesAutoresizingMaskIntoConstraints = false
        burseButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            portfolioButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            portfolioButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        NSLayoutConstraint.activate([
            burseButton.topAnchor.constraint(equalTo: portfolioButton.bottomAnchor, constant: 20),
            burseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
