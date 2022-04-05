//
//  PortfolioTableViewCell.swift
//  My Portfolio
//
//  Created by Алексей Агеев on 11.03.2022.
//

import UIKit

class PortfolioTableViewCell: UITableViewCell {
    static let identifier = "PortfolioDynamicCell"
    
    private let logo = UIImageView()
    private let name = UILabel()
    private let numberOfStocks = UILabel()
    private let share = UILabel()
    private let stockPrice = UILabel()
    private let stockPriceChange = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLabelStyles()
        setupLogo()
        makeLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage(_ image: UIImage?) {
        logo.image = image
    }
    
    func setContent(company: PortfolioModel.PortfolioCompany) {
        name.text = company.name
        numberOfStocks.text = NumberFormatter.integerFormatter.string(for: company.numberOfStocks)
        share.text = NumberFormatter.percentFormatter.string(for: company.share)
        stockPrice.text = NumberFormatter.rubFormatter.string(for: company.stockPrice)
        
        guard let priceChangeFormatted = NumberFormatter.signedDecimalFormatter.string(for: company.change),
              !priceChangeFormatted.isEmpty,
              let priceChangePercentageFormatted = NumberFormatter.signedPercentFormatter.string(for: company.changePercent),
              !priceChangePercentageFormatted.isEmpty
        else {
            stockPriceChange.isHidden = true
            return
        }
        
        stockPriceChange.isHidden = false
        stockPriceChange.text = "\(priceChangeFormatted) (\(priceChangePercentageFormatted))"
        stockPriceChange.textColor = (company.changePercent ?? 0) < 0 ? .red : .green
    }
    
    // MARK: UI
    private func setupLabelStyles() {
        setupLabel(name, as: .name)
        setupLabel(numberOfStocks, as: .numberOfStocks)
        setupLabel(share, as: .share)
        setupLabel(stockPrice, as: .stockPrice)
        setupLabel(stockPriceChange, as: .stockPriceChange)
    }
    
    private func makeSFSymbolUIImageView(sfSymbolName: String) -> UIImageView {
        let sfSymbol = UIImage(systemName: sfSymbolName,
                               withConfiguration: UIImage.SymbolConfiguration(textStyle: .footnote))
        let imageView = UIImageView(image: sfSymbol)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .secondaryLabel
        imageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return imageView
    }
    
    private func setupLogo() {
        logo.widthAnchor.constraint(equalToConstant: 44).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        logo.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        logo.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        logo.contentMode = .scaleAspectFit
    }

    private func setupLabel(_ label: UILabel, as element: Label) {
        label.lineBreakMode = .byWordWrapping
        
        switch element {
        case .name:
            label.font = .preferredFont(forTextStyle: .headline)
            label.numberOfLines = 0
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        case .stockPrice:
            label.font = .preferredFont(forTextStyle: .body)
            label.setContentHuggingPriority(.defaultLow, for: .vertical)
        case .numberOfStocks, .share:
            label.font = .preferredFont(forTextStyle: .footnote)
            label.textColor = .secondaryLabel
        case .stockPriceChange:
            label.font = .preferredFont(forTextStyle: .footnote)
            label.setContentHuggingPriority(.defaultLow, for: .vertical)
        }
    }
    
    // MARK: Layout
    /*
     MainStack {
        logo
        NameStack { 
            name
            StockAndShareStack {
                StockStack {
                    stackImageView
                    numberOfStocks
                }
                ShareStack {
                    pieChartImageView
                    share (UILabel)
                }
            }
        }
        PriceStack {
            stockPrice (UILabel)
            stockPriceChange (UILabel)
        }
     }
     */
    
    private func makeLayout() {
        let mainStack = makeMainStack()
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }

    private func makeMainStack() -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [makeNameStack(), makePriceStack()])
        if needsLargeLayout {
            stack.axis = .vertical
            stack.alignment = .leading
        } else {
            stack.insertArrangedSubview(logo, at: 0)
            stack.spacing = 8
            stack.alignment = .center
        }
        stack.distribution = .fill
        stack.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return stack
    }
    
    private func makeNameStack() -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [name, makeStockAndShareStack()])
        stack.axis = .vertical
        stack.alignment = .leading
        return stack
    }
    
    private func makeStockAndShareStack() -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [makeStockStack(), makeShareStack()])
        if needsLargeLayout {
            stack.axis = .vertical
            stack.alignment = .leading
        } else {
            stack.spacing = 8
        }
        return stack
    }
    
    private func makeStockStack() -> UIStackView {
        let stackImageView = makeSFSymbolUIImageView(sfSymbolName: "square.stack.3d.up.fill")
        let stack = UIStackView(arrangedSubviews: [stackImageView, numberOfStocks])
        stack.spacing = 4
        return stack
    }
    
    private func makeShareStack() -> UIStackView {
        let pieChartImageView = makeSFSymbolUIImageView(sfSymbolName: "chart.pie.fill")
        let stack = UIStackView(arrangedSubviews: [pieChartImageView, share])
        stack.spacing = 4
        return stack
    }
    
    private func makePriceStack() -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [stockPrice, stockPriceChange])
        stack.axis = .vertical
        stack.alignment = needsLargeLayout ? .leading : .trailing
        stack.distribution = .fillEqually
        return stack
    }
}

//MARK: Extensions
extension PortfolioTableViewCell {
    private enum Label {
        case name
        case numberOfStocks
        case share
        case stockPrice
        case stockPriceChange
    }
}

extension PortfolioTableViewCell {
    private var needsLargeLayout: Bool {
        guard traitCollection.horizontalSizeClass == .compact else {
            return false
        }
        
        let interfaceOrientation = UIApplication
            .shared
            .windows
            .first(where: { $0.isKeyWindow })?
            .windowScene?
            .interfaceOrientation
        
        guard ![.landscapeLeft, .landscapeRight].contains(interfaceOrientation) else {
            return UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory
        }
        
        switch UIScreen.main.scale {
        case 2:
            return UIApplication.shared.preferredContentSizeCategory > .large
        case 3:
            return UIApplication.shared.preferredContentSizeCategory > .extraExtraLarge
        default:
            return UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory
        }
    }
}
