//
//  DetailViewController.swift
//  My Portfolio
//
//  Created by Владислав Седенков on 16.02.2022.
//

import UIKit
import Combine

final class DetailViewController: LoadingViewController {
    
    private let headerView: UIView = .init()
    private let footerView: UIView = .init()
    private let currentPriceLabel: UILabel = .init()
    private let changePriceLabel: UILabel = .init()
    private let chartView: ChartView = .init()
    private let chartTimeframeSegmentedControl: UISegmentedControl = .init()
    private let infoTableView: UITableView = .init(frame: .zero, style: .insetGrouped)
    private let buyButton: UIButton = .init()
    private let sellButton: UIButton = .init()
    
    private var bindings: Set<AnyCancellable> = .init()
    
    private(set) var viewModel: DetailViewModel!
    
    private var isLoading: Bool = false {
        didSet { isLoading ? showLoadingView() : dismissLoadingView() }
    }
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureInfoTableView()
        
        configureHeaderView()
        configureCurrentPriceLabel()
        configureChangePriceLabel()
        configureChartView()
        configureChartTimeframeSegmentedControl()
        configureTableHeaderView()
        
        configureFooterView()
        configureSellButton()
        configureBuyButton()
        configureTableFooterView()
        
        bindViewModelToView()
        
        //refreshAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.prefersLargeTitles = true
        //navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = .systemGreen
    }
}

extension DetailViewController {
    
    private func configureViewController() {
        view.backgroundColor = .systemGroupedBackground
        view.addSubViews(infoTableView)
    }
    
    private func configureInfoTableView() {
        infoTableView.translatesAutoresizingMaskIntoConstraints = false
        infoTableView.register(InfoTableViewCell.self, forCellReuseIdentifier: InfoTableViewCell.description())
        infoTableView.delegate = self
        infoTableView.dataSource = self
        NSLayoutConstraint.activate([
            infoTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            infoTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            infoTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            infoTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        infoTableView.refreshControl = UIRefreshControl()
        infoTableView.refreshControl?.tintColor = .systemGreen
        infoTableView.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh ...")
        infoTableView.refreshControl?.addTarget(
            self,
            action: #selector(refresh),
            for: .valueChanged
        )
    }
}

extension DetailViewController {
    
    private func configureHeaderView() {
        headerView.addSubViews(currentPriceLabel, changePriceLabel, chartView, chartTimeframeSegmentedControl)
        headerView.frame.size.width = view.frame.width
    }
    
    private func configureCurrentPriceLabel() {
        currentPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        currentPriceLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        currentPriceLabel.text = " "
        
        NSLayoutConstraint.activate([
            currentPriceLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: Mock.padding),
            currentPriceLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: Mock.padding)
        ])
    }
    
    private func configureChangePriceLabel() {
        changePriceLabel.translatesAutoresizingMaskIntoConstraints = false
        changePriceLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        changePriceLabel.text = " "
        
        NSLayoutConstraint.activate([
            changePriceLabel.leadingAnchor.constraint(equalTo: currentPriceLabel.leadingAnchor),
            changePriceLabel.topAnchor.constraint(equalTo: currentPriceLabel.bottomAnchor, constant: Mock.miniPadding)
        ])
    }
    
    private func configureChartView() {
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.tintColor = .white
        chartView.contentMode = .scaleAspectFill
        NSLayoutConstraint.activate([
            chartView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            chartView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            chartView.topAnchor.constraint(equalTo: changePriceLabel.bottomAnchor, constant: Mock.padding),
            chartView.heightAnchor.constraint(equalToConstant: Mock.chartImageHeight)
        ])
    }
    
    private func configureChartTimeframeSegmentedControl() {
        chartTimeframeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        Mock.chartTimeframeSegmentedControlItems.enumerated().forEach {
            chartTimeframeSegmentedControl.insertSegment(withTitle: $0.element, at: $0.offset, animated: true)
        }
        
        let widthAnchor = chartTimeframeSegmentedControl.widthAnchor.constraint(equalTo: headerView.widthAnchor, constant: -2 * Mock.padding)
        widthAnchor.priority = UILayoutPriority(999)
        
        NSLayoutConstraint.activate([
            chartTimeframeSegmentedControl.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            widthAnchor,
            chartTimeframeSegmentedControl.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: Mock.padding),
            chartTimeframeSegmentedControl.heightAnchor.constraint(equalToConstant: Mock.periodsSegmentedControlHeight),
            chartTimeframeSegmentedControl.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -Mock.padding)
        ])
        chartTimeframeSegmentedControl.selectedSegmentIndex = 0
    }
    
    private func configureTableHeaderView() {
        infoTableView.tableHeaderView = headerView
        headerView.frame.size.height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    }
}

extension DetailViewController {
    
    private func configureFooterView() {
        footerView.addSubViews(buyButton, sellButton)
    }
    
    private func configureSellButton() {
        sellButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            sellButton.heightAnchor.constraint(equalToConstant: Mock.buttonMinimumHeight),
            sellButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: Mock.padding),
            sellButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: Mock.padding),
            sellButton.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -Mock.padding),
            sellButton.widthAnchor.constraint(
                equalTo: footerView.widthAnchor, multiplier: Mock.actionButtonToWidthMultiplier
            )
        ])
        
        sellButton.backgroundColor = .systemRed
        sellButton.layer.cornerRadius = Mock.cornerRadius
        sellButton.setTitle(Mock.sellButtonTitle, for: .normal)
        sellButton.titleLabel?.font = UIFont.systemFont(ofSize: Mock.buttonTitleTextFontSize, weight: .bold)
    }
    
    private func configureBuyButton() {
        buyButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buyButton.heightAnchor.constraint(equalToConstant: Mock.buttonMinimumHeight),
            buyButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -Mock.padding),
            buyButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: Mock.padding),
            buyButton.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -Mock.padding),
            buyButton.widthAnchor.constraint(equalTo: sellButton.widthAnchor)
        ])
        
        buyButton.backgroundColor = .systemGreen
        buyButton.layer.cornerRadius = Mock.cornerRadius
        buyButton.setTitle(Mock.buyButtonTitle, for: .normal)
        buyButton.titleLabel?.font = UIFont.systemFont(ofSize: Mock.buttonTitleTextFontSize, weight: .bold)
    }
    
    private func configureTableFooterView() {
        infoTableView.tableFooterView = footerView
        footerView.frame.size.height = footerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    }
}

extension DetailViewController {
    @objc private func refresh() {
        infoTableView.refreshControl?.endRefreshing()
    }
}

extension DetailViewController {
    private func handle(_ error: Error) {
        if let error = error as? StockError {
            showAlert(title: "Something went wrong!", message: error.rawValue)
        } else {
            showAlert(title: "Something went wrong!", message: error.localizedDescription)
        }
    }
}

extension DetailViewController {
    func bindViewModelToView() {
        
        viewModel.$isLoading
            .sink(receiveValue: { [unowned self] isLoading in
                self.isLoading = isLoading
            })
            .store(in: &bindings)
        
        viewModel.$title
            .sink(receiveValue: { [unowned self] title in
                self.title = title
            })
            .store(in: &bindings)
        
        viewModel.$currentPrice
            .assign(to: \.text, on: currentPriceLabel)
            .store(in: &bindings)
        
        viewModel.$changePrice
            .assign(to: \.text, on: changePriceLabel)
            .store(in: &bindings)
        
        viewModel.$priceSectionRightLabels
            .sink { [unowned self] _ in
                self.infoTableView.reloadData()
            }
            .store(in: &bindings)
        
        viewModel.$chartDataSource
            .assign(to: \.dataSource, on: chartView)
            .store(in: &bindings)
        
        viewModel.error
            .sink { [unowned self] error in
                self.handle(error)
            }
            .store(in: &bindings)
        
        chartTimeframeSegmentedControl.publisher(for: \.selectedSegmentIndex)
            .map{ ChartTimeframe.allCases[$0] }
            .assign(to: \.chartTimeFrame, on: viewModel)
            .store(in: &bindings)
    }
}
