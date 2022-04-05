//
//  PieChartHeaderView.swift
//  My Portfolio
//
//  Created by Сергей Петров on 12.03.2022.
//

import Foundation
import UIKit

class PieChartHeaderView: UITableViewHeaderFooterView {
    static let identifier = "TableHeader"
    
    private var stocksSumValueLabel: UILabel = {
        let stockSumValueLabel = UILabel()
        stockSumValueLabel.text = "0 ₽"
        stockSumValueLabel.sizeToFit()
        return stockSumValueLabel
    }()

    var stocksNumberLabel: UILabel = {
        let stocksNumberLabel = UILabel()
        stocksNumberLabel.text = "0 компаний"
        stocksNumberLabel.sizeToFit()
        return stocksNumberLabel
    }()
    
    private var pieChartView: PieChartView = {
        let pieChartView = PieChartView(frame: CGRect(x: 0,
                                                      y: 0,
                                                      width: 100,
                                                      height: 100),
                                        strokeWidth: 2,
                                        strokeColor: .black,
                                        secondRadiusMultiplier: 0.9)
        return pieChartView
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(pieChartView)
        contentView.addSubview(stocksSumValueLabel)
        contentView.addSubview(stocksNumberLabel)
    }
    
    init(reuseIdentifier: String?, data: [(String, Double)] = [], colors: [UIColor] = []) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(pieChartView)
        contentView.addSubview(stocksSumValueLabel)
        contentView.addSubview(stocksNumberLabel)
        setData(data: data, colors: colors)
    }
    
    func setData(data: [(String, Double)], colors: [UIColor]) {
        let sumValue = (100 * round(data.reduce(into: 0) { $0 += $1.1 })) / 100
        stocksSumValueLabel.text = "\(sumValue) ₽"
//        stocksNumberLabel.text = stocksNumberStringFormatter(data: data, number: data.count)
        stocksSumValueLabel.sizeToFit()
        stocksNumberLabel.sizeToFit()
        pieChartView.setData(data: data, colors: colors)
        pieChartView.setNeedsDisplay()
        self.setNeedsLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        pieChartView.frame = CGRect(x: 0,
                                    y: 0,
                                    width: contentView.bounds.width,
                                    height: contentView.bounds.height)
        stocksNumberLabel.sizeToFit()
        stocksSumValueLabel.sizeToFit()
        stocksSumValueLabel.center = CGPoint(x: pieChartView.center.x, y: pieChartView.center.y)
        stocksNumberLabel.center = CGPoint(x: pieChartView.center.x, y: pieChartView.center.y + stocksSumValueLabel.frame.height)
        
    }
}
