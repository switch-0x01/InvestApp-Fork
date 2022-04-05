//
//  AnalyticsViewController.swift
//  My Portfolio
//
//  Created by Владислав Седенков on 15.02.2022.
//

import UIKit
import Combine

final class AnalyticsViewController: UIViewController, DependencyHolder {
    weak var _repository: DependencyRepository?
    
    var viewModel: AnalyticsViewModelProtocol?
    var data: [(String, Double)] = [] {
        didSet {
            tableView.reloadData()
            header.setData(data: data, colors: dataColors)
            setNumber()
        }
    }
    var cash: Decimal = 0
    var dataColors: [UIColor] = []
    var allCancellables = Set<AnyCancellable>()
    var showMoreCellsDidTapped = false
    
    private var segmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl()
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.insertSegment(withTitle: "Компании", at: 0, animated: false)
        segmentControl.insertSegment(withTitle: "Отрасли", at: 1, animated: false)
        segmentControl.selectedSegmentIndex = 0
        return segmentControl
    }()
    
    private var contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(AnalyticsTableViewCell.self, forCellReuseIdentifier: AnalyticsTableViewCell.identifier)
        tableView.register(PieChartHeaderView.self, forHeaderFooterViewReuseIdentifier: "header")
        return tableView
    }()
    
    private var header: PieChartHeaderView = {
        let header = PieChartHeaderView(reuseIdentifier: nil)
        header.frame = CGRect(x: 0, y: 0, width: 250, height: 250)
        return header
    }()
    
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
  
    private var showMoreButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Показать больше", for: .normal)
        btn.setTitleColor(.link, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.addTarget(self, action: #selector(loadMoreTap), for: .touchUpInside)
        btn.clipsToBounds = true
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = AnalyticsViewModel(portfolioGateway: portfolioGateway, companyGateway: companyGateway)
        setSubscribers()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = UIColor.clear
        setupScrollView()
        setupConstraints()
        setupTableHeader()
        segmentControl.addTarget(self, action: #selector(switchSegment), for: .valueChanged)
    }
    
    private func setSubscribers() {
        viewModel?.dataColorsPublisher.sink { colors in
            self.dataColors = colors
        }.store(in: &allCancellables)
        
        viewModel?.dataPublisher.sink { companies in
            if self.segmentControl.selectedSegmentIndex == 0 {
                self.data = companies.reduce(into: [(String, Double)]()) { partialResult, company in
//                    print(company.name)
                    if let ticker = company.name,
                       let stockBatchesSumCost = company.stockBatches?
                        .compactMap({ $0 as? StockBatch })
                        .reduce(into: Double(0), { $0 += (company.currentStockPrice?.doubleValue ?? 0) * Double($1.numberOfStocks) }) {
                           partialResult.append((ticker, stockBatchesSumCost))
                    }
                }
            } else {
                self.data = companies.reduce(into: [String: Double]()) { industries, company in
                    if let industry = company.industry,
                       let stockBatchesSumCost = company.stockBatches?
                        .compactMap({ $0 as? StockBatch })
                        .reduce(into: Double(0), { $0 += (company.currentStockPrice?.doubleValue ?? 0) * Double($1.numberOfStocks) }) {
                        industries[industry, default: 0] += stockBatchesSumCost
                    }
                }.map { ($0.key, $0.value) }
            }
        }.store(in: &allCancellables)
        
        viewModel?.cashPublisher.sink { cash in
            self.cash = cash
        }.store(in: &allCancellables)
    }
    
    private func stocksNumberStringFormatter(data: [(String, Double)], number: Int) -> String {
        if (data.count % 10) == 1 && ((data.count > 20) || (data.count < 10)) {
            return "\(data.count) компания"
        }
        else if (1...4).contains(data.count % 10) && ((data.count > 20) || (data.count < 10)) {
            return "\(data.count) компании"
        }
        else {
            return "\(data.count) компаний"
        }
    }
    
    @objc private func switchSegment(sender: UISegmentedControl) {
        viewModel?.getData()
        viewModel?.getCashAmount()
        setNumber()
    }
    
    func setNumber() {
        if segmentControl.selectedSegmentIndex == 0 {
            if (data.count % 10) == 1 && ((data.count > 20) || (data.count < 10)) {
                header.stocksNumberLabel.text = "\(data.count) компания"
            }
            else if (1...4).contains(data.count % 10) && ((data.count > 20) || (data.count < 10)) {
                header.stocksNumberLabel.text = "\(data.count) компании"
            }
            else {
                header.stocksNumberLabel.text = "\(data.count) компаний"
            }
        } else {
            if (data.count % 10) == 1 && ((data.count > 20) || (data.count < 10)) {
                header.stocksNumberLabel.text = "\(data.count) отрасль"
            }
            else if (1...4).contains(data.count % 10) && ((data.count > 20) || (data.count < 10)) {
                header.stocksNumberLabel.text = "\(data.count) отрасли"
            }
            else {
                header.stocksNumberLabel.text = "\(data.count) отраслей"
            }
        }
    }
}

extension AnalyticsViewController {
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupConstraints() {
        contentView.addSubview(segmentControl)
        contentView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            segmentControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            segmentControl.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            segmentControl.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        NSLayoutConstraint.activate([
            tableView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            tableView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 20
                                          ),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    func setupTableHeader() {
        tableView.tableHeaderView = header
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.getData()
        viewModel?.getCashAmount()
    }
}

extension AnalyticsViewController: UITableViewDelegate {
    
}

extension AnalyticsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      if data.count <= 8 || showMoreCellsDidTapped {
        return data.count
      } else {
        return 8
      }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: AnalyticsTableViewCell.identifier, for: indexPath) as? AnalyticsTableViewCell else {
        return UITableViewCell()
      }
      cell.configure(with: data.sorted(by: { $0.1 > $1.1 }), colors: dataColors, for: indexPath)
        return cell
    }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    if showMoreCellsDidTapped || data.count <= 8 {
      return nil
    } else {
      let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
      footerView.backgroundColor = .clear
      footerView.addSubview(showMoreButton)
      showMoreButton.frame = CGRect(
        x: 0,
        y: 0,
        width: footerView.frame.size.width,
        height: footerView.frame.size.height)
      return footerView
    }
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return showMoreCellsDidTapped == false ? 30 : 0
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 44
  }
}

extension AnalyticsViewController {
  @objc private func loadMoreTap() {
    showMoreCellsDidTapped = true
    DispatchQueue.main.async {
      self.tableView.reloadData()
    }
  }
}

