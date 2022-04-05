//
//  DividendsStockView.swift
//  My Portfolio
//
//  Created by Никита on 17.03.2022.
//
import UIKit
import Combine

class DividendsStockView: UIView {
    
    private var keyBoardObserver: IStarStopKeyboardObsrever?
    
    private var tickerStockLabel = UILabel()
    var tickerStockTextField = UITextField()
    
    private var priceStockLabel = UILabel()
    var priceStockTextField = UITextField()
    
    var labelDate = UILabel()
    
    private var writeOffMoneyLabel = UILabel()
    var availableMoneyLabel = UILabel()
    
    var addButton = CustomButton()
    
    var allCancellables = Set<AnyCancellable>()
    weak var viewController: JournalViewController? {
        didSet {
            
            NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: tickerStockTextField)
                .map { $0.object as? UITextField }
                .compactMap { $0?.text }
                .sink { [weak self] companyName in
                    self?.viewController?.targetCompanyName = companyName
                }.store(in: &allCancellables)
            
            NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification, object: tickerStockTextField)
                .map { $0.object as? UITextField }
                .compactMap { $0?.text }
                .sink { [weak self] companyName in
                    self?.viewController?.setCurrency()
                }.store(in: &allCancellables)
            
            NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: labelDate)
                .map { $0.object as? UITextField }
                .compactMap { $0?.text }
                .sink { [weak self] _ in
                    self?.viewController?.operationDate = Date()
                }.store(in: &allCancellables)
            
            NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: priceStockTextField)
                .map { $0.object as? UITextField }
                .compactMap { $0?.text }
                .sink { [weak self] price in
                    if price.last != "." {
                        self?.viewController?.currentStockPrice = Decimal(string: price)
                    }
                }.store(in: &allCancellables)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.loadUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension DividendsStockView {
    
    func loadUI() {
        setupTickerStockSection()
        setuplabelDate()
        setupPriceStockSection()
        setupWriteOffMoneyLabel()
        setupAvailableMoneyLabel()
        setupAddButtom()
    }
    //MARK: setupTickerStockSection
    func setupTickerStockSection() {
        self.tickerStockLabel = CustomLabel()
        self.tickerStockLabel.text = "Тикер компании"
        self.tickerStockLabel.textColor = .secondaryLabel
        self.addSubview(self.tickerStockLabel)
        
        NSLayoutConstraint.activate([
            self.tickerStockLabel.leftAnchor.constraint(
                equalTo: self.leftAnchor,
                constant: 20),
            self.tickerStockLabel.rightAnchor.constraint(
                equalTo: self.rightAnchor,
                constant: -20),
            self.tickerStockLabel.topAnchor.constraint(equalTo: self.firstBaselineAnchor , constant: 8)
        ])
        
        self.tickerStockTextField = CustomTextField()
        self.tickerStockTextField.delegate = self
        self.addSubview(self.tickerStockTextField)
        NSLayoutConstraint.activate([
            tickerStockTextField.leftAnchor.constraint(
                equalTo: self.leftAnchor,
                constant: 20),
            tickerStockTextField.rightAnchor.constraint(
                equalTo: self.rightAnchor,
                constant: -20),
            tickerStockTextField.heightAnchor.constraint(
                equalToConstant: 45),
            tickerStockTextField.topAnchor.constraint(
                equalTo: tickerStockLabel.bottomAnchor ,constant: 8)
        ])
    }
    
    //MARK: setuplabelDate
    private func setuplabelDate() {
        self.labelDate = CustomLabel()
        self.addSubview(self.labelDate)
        let time = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.YYYY HH:mm:ss"
        let formatteddate = formatter.string(from: time as Date)
        self.labelDate.text = "\(formatteddate)"
        self.labelDate.textColor = .secondaryLabel
        
        NSLayoutConstraint.activate([
            labelDate.leftAnchor.constraint(
                equalTo: self.leftAnchor,
                constant: 20),
            labelDate.rightAnchor.constraint(
                equalTo: self.rightAnchor,
                constant: -20),
            labelDate.topAnchor.constraint(
                equalTo: tickerStockTextField.bottomAnchor ,constant: 8)
        ])
    }
    
    //MARK: setupPriceStockSection
    private func setupPriceStockSection() {
        self.priceStockLabel = CustomLabel()
        self.priceStockLabel.text = "Цена"
        self.priceStockLabel.textColor = .secondaryLabel
        self.addSubview(self.priceStockLabel)
        
        NSLayoutConstraint.activate([
            self.priceStockLabel.leftAnchor.constraint(
                equalTo: self.leftAnchor,
                constant: 20),
            self.priceStockLabel.rightAnchor.constraint(
                equalTo: self.rightAnchor,
                constant: -20),
            self.priceStockLabel.topAnchor.constraint(equalTo: labelDate.bottomAnchor , constant: 8)
        ])
        self.priceStockTextField = CustomTextField()
        self.priceStockTextField.delegate = self
        self.addSubview(self.priceStockTextField)
        NSLayoutConstraint.activate([
            priceStockTextField.leftAnchor.constraint(
                equalTo: self.leftAnchor,
                constant: 20),
            priceStockTextField.rightAnchor.constraint(
                equalTo: self.rightAnchor,
                constant: -20),
            priceStockTextField.heightAnchor.constraint(
                equalToConstant: 45),
            priceStockTextField.topAnchor.constraint(
                equalTo: priceStockLabel.bottomAnchor ,constant: 8)
        ])
    }
    
    //MARK: setupWriteOffMoneyLabel
    private func setupWriteOffMoneyLabel() {
        self.writeOffMoneyLabel = CustomLabel()
        self.writeOffMoneyLabel.text = "Начислить деньги"
        self.writeOffMoneyLabel.textColor = .secondaryLabel
        self.addSubview(self.writeOffMoneyLabel)
        
        NSLayoutConstraint.activate([
            self.writeOffMoneyLabel.leftAnchor.constraint(
                equalTo: self.leftAnchor,
                constant: 20),
            self.writeOffMoneyLabel.topAnchor.constraint(
                equalTo: priceStockTextField.bottomAnchor ,constant: 8)
        ])
    }
    
    //MARK: setupAvailableMoneyLabel
    private func setupAvailableMoneyLabel() {
        self.availableMoneyLabel = CustomLabel()
        self.availableMoneyLabel.text = "Доступно: 300"
        self.availableMoneyLabel.textColor = .secondaryLabel
        self.addSubview(self.availableMoneyLabel)
        
        NSLayoutConstraint.activate([
            self.availableMoneyLabel.leftAnchor.constraint(
                equalTo: self.leftAnchor,
                constant: 20),
            self.availableMoneyLabel.topAnchor.constraint(
                equalTo: writeOffMoneyLabel.bottomAnchor ,constant: 8)
        ])
    }
    
    //MARK: setupAddButtom
    private func setupAddButtom() {
        self.addButton.isEnabled = false
        self.addButton.layer.cornerRadius = 15
        self.addButton.setTitle("Добавить", for: .normal)
        self.addButton.titleLabel?.textColor = .white
        self.addButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.addButton)
        self.addButton.sizeToFit()
        
        NSLayoutConstraint.activate([
            self.addButton.centerXAnchor.constraint(
                equalTo: self.centerXAnchor),
            self.addButton.widthAnchor.constraint(
                equalToConstant: self.addButton.frame.width + 20),
            self.addButton.heightAnchor.constraint(
                equalToConstant: 65),
            self.addButton.topAnchor.constraint(
                equalTo: availableMoneyLabel.bottomAnchor, constant: 20)
        ])
    }
}

extension DividendsStockView: UITextFieldDelegate, UITextViewDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
            keyBoardObserver?.stopKeyboardObsrever()
     }
}
extension DividendsStockView {
    func setupKeyboardObsrever(_  name: IStarStopKeyboardObsrever) {
        keyBoardObserver = name
        
    }
}
