//
//  LoadingViewController.swift
//  My Portfolio
//
//  Created by Илья Андреев on 09.03.2022.
//

import UIKit

class LoadingViewController: UIViewController {
    
    private let containerView: UIView = .init()
    private let activityIndicator: UIActivityIndicatorView = .init(style: .large)
    
    func showLoadingView() {
        DispatchQueue.main.async {
            self.containerView.backgroundColor = .systemBackground
            self.containerView.alpha = 0
            self.view.addSubViews(self.containerView)
            self.containerView.frame = self.view.bounds
            
            
            UIView.animate(withDuration: 0.75) {
                self.containerView.alpha = 0.8
            }
            
            self.activityIndicator.color = .systemGreen
            self.containerView.addSubViews(self.activityIndicator)
            self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                self.activityIndicator.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),
                self.activityIndicator.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor)
            ])
            self.view.bringSubviewToFront(self.containerView)
            self.activityIndicator.startAnimating()
        }
    }
    
    func dismissLoadingView() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
            self.containerView.removeFromSuperview()
        }
    }
}
