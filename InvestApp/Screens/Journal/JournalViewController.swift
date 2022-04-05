//
//  JournalViewController.swift
//  My Portfolio
//
//  Created by Владислав Седенков on 15.02.2022.
//
import UIKit
import Combine

protocol IStarStopKeyboardObsrever {
    func startKeyboardObsrever()
    func stopKeyboardObsrever()
}

final class JournalViewController: UIViewController, DependencyHolder {
    weak var _repository: DependencyRepository?
    
    private var segmentArray = ["Купить", "Продать", "Дивиденды"]
    private var segmentedControl =  UISegmentedControl()
    var contentView = UIView()
    var scrollView = UIScrollView()
    let buyStockView = BuyStockView()
    let saleStockView = SaleStockView()
    let dividendsStockView = DividendsStockView()
    let view2 = UIView()
    
    var viewModel: JournalViewModelProtocol?
    var allCancellables = Set<AnyCancellable>()
    
    var currentCurrencyMultiplier: Decimal = 1
    
    var cashAmount: Decimal = 0 {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.buyStockView.availableMoneyLabel.text = "\(self?.cashAmount ?? 0)"
                self?.saleStockView.availableMoneyLabel.text = "\(self?.cashAmount ?? 0)"
                self?.dividendsStockView.availableMoneyLabel.text = "\(self?.cashAmount ?? 0)"
            }
            setButtonsEnabled()
        }
    }
    var targetCompanyName: String? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.buyStockView.tickerStockTextField.text = self?.targetCompanyName
                self?.saleStockView.tickerStockTextField.text = self?.targetCompanyName
                self?.dividendsStockView.tickerStockTextField.text = self?.targetCompanyName
            }
            viewModel?.targetCompanyName = targetCompanyName ?? ""
            setButtonsEnabled()
        }
    }
    var numberOfStocks: Int? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.buyStockView.amountStocksTextField.text = "\(self?.numberOfStocks ?? 0)"
                self?.saleStockView.amountStocksTextField.text = "\(self?.numberOfStocks ?? 0)"
                self?.viewModel?.numberOfStocks = self?.numberOfStocks ?? 0
                self?.setButtonsEnabled()
            }
        }
    }
    
    // FIXME: Update after add DatePicker
    var operationDate: Date? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.buyStockView.labelDate.text = Date().description
                self?.saleStockView.labelDate.text = Date().description
                self?.dividendsStockView.labelDate.text = Date().description
                self?.viewModel?.operationDate = self?.operationDate ?? Date()
                self?.setButtonsEnabled()
            }
        }
    }
    
    var currentStockPrice: Decimal? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.buyStockView.priceStockTextField.text = self?.currentStockPrice?.description ?? ""
                self?.saleStockView.priceStockTextField.text = self?.currentStockPrice?.description ?? ""
                self?.dividendsStockView.priceStockTextField.text = self?.currentStockPrice?.description ?? ""
                self?.viewModel?.currentStockPrice = self?.currentStockPrice ?? 0
                self?.setButtonsEnabled()
            }
        }
    }
    var noteText: String? {
        didSet {
            viewModel?.notes = noteText ?? ""
            setButtonsEnabled()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        viewModel = JournalViewModel(stockBatchGateway: stockBatchGateway)
        buyStockView.viewController = self
        saleStockView.viewController = self
        dividendsStockView.viewController = self
        setupNavBar()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(cancelScreen))
        setupSegmentedControl()
        setupScrollView()
        setSubscribers()
        hideKeyboard()
    }
    
    private func setSubscribers() {
        viewModel?.cashAmountPublisher.sink(receiveValue: { [weak self] cash in
            self?.cashAmount = cash
        }).store(in: &allCancellables)
        self.buyStockView.addButton.addTarget(self, action: #selector(buyStocksSubmit(_:)), for: .touchUpInside)
        self.saleStockView.addButton.addTarget(self, action: #selector(sellStocksSubmit(_:)), for: .touchUpInside)
        self.dividendsStockView.addButton.addTarget(self, action: #selector(enrollDividendSubmit(_:)), for: .touchUpInside)
    }
    
    func setCurrency() {
        guard let targetCompanyName = targetCompanyName else {
            return
        }
        NetworkingManager().fetchStock(symbol: targetCompanyName) { [weak self] result in
            switch result {
                case .success(let stock):
                    if let currency = stock.currency {
                        switch currency {
                            case "USD":
                                self?.currentCurrencyMultiplier = Decimal(CurrencyConverter.USD.rawValue)
                            case "EUR":
                                self?.currentCurrencyMultiplier = Decimal(CurrencyConverter.EUR.rawValue)
                            default:
                                self?.currentCurrencyMultiplier = 1
                        }
                    }
                case .failure(let error):
                    self?.currentCurrencyMultiplier = 1
                    print("No stock with symbol \(targetCompanyName)")
            }
            self?.setButtonsEnabled()
        }
    }
    
    @objc func buyStocksSubmit(_ sender: UIButton) {
        guard let viewModel = viewModel else {
            return
        }
        let tmp = viewModel.currentStockPrice
        viewModel.currentStockPrice *= currentCurrencyMultiplier
        viewModel.buyStock { error in
            if let error = error {
                print("fail to buy stocks!!! \(error.localizedDescription)")
                self.showAlert(title: .error, message: ("Неверно введены данные"))
            } else {
                self.showAlert(title: .success, message: "Покупка совершена успешно!")
            }
        }
        viewModel.currentStockPrice = tmp
    }
    
    @objc func sellStocksSubmit(_ sender: UIButton) {
        guard let viewModel = viewModel else {
            return
        }
        let tmp = viewModel.currentStockPrice
        viewModel.currentStockPrice *= currentCurrencyMultiplier
        viewModel.sellStock { error in
            if let error = error {
                print("fail to sell stocks!!! \(error.localizedDescription)")
                self.showAlert(title: .error, message: ("Неверно введены данные"))
            } else {
                self.showAlert(title: .success, message: "Продажа совершена успешно!")
            }
        }
        viewModel.currentStockPrice = tmp
    }
    
    @objc func enrollDividendSubmit(_ sender: UIButton) {
        self.viewModel?.enrollDividend { error in
            if error != nil {
                self.showAlert(title: .error, message: ("Неверно введены данные"))
            } else {
                self.showAlert(title: .success, message: "Дивиденды зачислены на счет!")
            }
        }
    }
    
    func setButtonsEnabled() {
        DispatchQueue.main.async { [weak self] in
            self?.buyStockView.addButton.isEnabled = false
            self?.saleStockView.addButton.isEnabled = false
            self?.dividendsStockView.addButton.isEnabled = false
            if let companyName = self?.targetCompanyName,
               let priceStock = self?.currentStockPrice,
               companyName.count > 0,
               priceStock > 0 {
                self?.dividendsStockView.addButton.isEnabled = true
                if let numberOfStocks = self?.numberOfStocks, numberOfStocks > 0 {
                    self?.saleStockView.addButton.isEnabled = true
                    if Decimal(numberOfStocks) * priceStock * (self?.currentCurrencyMultiplier ?? 1) <= self?.cashAmount ?? 0 {
                        self?.buyStockView.addButton.isEnabled = true
                    } else {
                        self?.buyStockView.addButton.isEnabled = false
                    }
                } else {
                    self?.buyStockView.addButton.isEnabled = false
                    self?.saleStockView.addButton.isEnabled = false
                }
            }
        }
    }
}

//MARK: UI
extension JournalViewController {
    private func setupScrollView() {
        scrollView.showsHorizontalScrollIndicator = false
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view2.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.heightAnchor.constraint(equalTo: view.heightAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            
            contentView.heightAnchor.constraint(equalTo: view.heightAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }
    
    private func setupSegmentedControl() {
        self.segmentedControl = UISegmentedControl(items: segmentArray)
        self.segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(segmentedControl)
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 0),
            segmentedControl.leftAnchor.constraint(
                equalTo: contentView.leftAnchor,
                constant: 20),
            segmentedControl.rightAnchor.constraint(
                equalTo: contentView.rightAnchor,
                constant: -20),
        ])
        self.showBuyStockView()
        self.segmentedControl.addTarget(self, action: #selector(selectedValue), for: .valueChanged)
    }
    
    private func showBuyStockView() {
        self.saleStockView.removeFromSuperview()
        self.dividendsStockView.removeFromSuperview()
        self.contentView.addSubview(self.buyStockView)
        self.buyStockView.setupKeyboardObsrever(self)
        self.buyStockView.translatesAutoresizingMaskIntoConstraints = false
        makeConstarint(view: self.buyStockView)
    }
    
    private func showSaleStockView() {
        self.buyStockView.removeFromSuperview()
        self.dividendsStockView.removeFromSuperview()
        self.contentView.addSubview(self.saleStockView)
        self.saleStockView.setupKeyboardObsrever(self)
        self.saleStockView.translatesAutoresizingMaskIntoConstraints = false
        makeConstarint(view: self.saleStockView)
    }
    
    private func showDividendsStockView() {
        self.saleStockView.removeFromSuperview()
        self.buyStockView.removeFromSuperview()
        self.contentView.addSubview(self.dividendsStockView)
        self.dividendsStockView.setupKeyboardObsrever(self)
        self.dividendsStockView.translatesAutoresizingMaskIntoConstraints = false
        makeConstarint(view: self.dividendsStockView)
    }
    
    private func makeConstarint(view: UIView){
        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(
                equalTo: contentView.leftAnchor,
                constant: 0),
            view.rightAnchor.constraint(
                equalTo: contentView.rightAnchor,
                constant: 0),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            view.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20)
        ])
        
    }
    
    @objc
    private func selectedValue(sender: UISegmentedControl) {
        if sender == self.segmentedControl {
            let index = self.segmentedControl.selectedSegmentIndex
            switch index {
            case 0:
                self.showBuyStockView()
                setButtonsEnabled()
            case 1:
                self.showSaleStockView()
                setButtonsEnabled()
            default:
                self.showDividendsStockView()
                setButtonsEnabled()
            }
        }
    }
}


extension JournalViewController {
    private func setupNavBar() {
        title = "Дневник сделок"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = .systemGreen
    }
    @objc private func cancelScreen() {
        dismiss(animated: true)
    }
}

extension JournalViewController {
    private func showAlert(title: ResultAlert, message: String) {
        DispatchQueue.main.async {
            var titleString = String()
            switch title {
            case .success:
                titleString = "Успех"
            case .error:
                titleString = "Ошибка"
            }
            let alert = CustomAlertController(title: titleString,
                                              message: message,
                                              preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
        }
    }
}

extension JournalViewController {
    private func hideKeyboard(){
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
    }
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            guard  let navigationSize = self.navigationController?.navigationBar.frame.size.height else { return }
            if self.view.frame.origin.y == 0 {
                if self.view.frame.size.height > 600 {
                    self.view.frame.origin.y -= keyboardSize.height - navigationSize - 40
                } else {
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}

extension JournalViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

extension JournalViewController: IStarStopKeyboardObsrever {
    func startKeyboardObsrever() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func stopKeyboardObsrever() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}


