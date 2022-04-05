//
//  CustomNavBar.swift
//  My Portfolio
//
//  Created by Евгений on 16.02.2022.
//

import UIKit

class UINavigationControllerWithDependency: UINavigationController, DependencyHolder {
    weak var _repository: DependencyRepository?
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func dependencyInjected() {
        guard let rootViewController = viewControllers.first else {
            return 
        }
        injectDependency(to: rootViewController)
    }
}
