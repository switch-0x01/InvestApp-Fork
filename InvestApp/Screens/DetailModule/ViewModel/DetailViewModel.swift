//
//  DetailViewModel.swift
//  My Portfolio
//
//  Created by Илья Андреев on 15.03.2022.
//

import Foundation
import Combine

class DetailViewModel {
    
    @Published private(set) var title: String?
    @Published private(set) var currentPrice: String?
    @Published private(set) var changePrice: String?
    
    let priceTitle: String = "Стоимость"
    let priceSectionLeftLabels: [String] = ["Открытие", "Минимум", "Тикер"]
    @Published private(set) var priceSectionRightLabels: [String] = ["", "", ""]
    
    let accountTitle: String = "Портфель"
    let accountSectionLeftLabels: [String] = ["Количество", "Общая стоимость", "Дельта"]
    @Published private(set) var accountSectionRightLabels: [String] = ["100", "2", "3"]
    
    @Published private(set) var chartDataSource: [ChartCandle]?
    
    let error: PassthroughSubject<Error, Never> = .init()
    
    private var dataSource: DataSourcer!
    private let ticker: String!
    
    @Published var chartTimeFrame: ChartTimeframe?
    
    @Published private(set) var isLoading = false
    
    private var bindings: Set<AnyCancellable> = .init()
    
    init(ticker: String,
         dataSource: DataSourcer
    ) {
        self.ticker = ticker
        self.dataSource = dataSource
        bind()
    }
}

extension DetailViewModel {
    func bind() {
        Timer.publish(every: 600, on: .main, in: .common)
            .autoconnect()
            .prepend(Date())
            .sink { [unowned self] _ in
                self.updateModels()
            }
            .store(in: &bindings)
        
        $chartTimeFrame
            .compactMap{ $0 }
            .sink { [unowned self] timeframe in
                self.applyChartDataSource(range: timeframe)
            }
            .store(in: &bindings)
    }
    
    private func updateModels() {
        fetchModel()
        applyChartDataSource(range: .oneDay)
    }
    
    func fetchModel() {
        isLoading = true
        dataSource.fetchModelFor(ticker: ticker) { [weak self] result in
            guard let self = self else {
                return
            }
            self.isLoading = false
            switch result {
            case .success(let stock):
                DispatchQueue.main.async {
                    self.title = stock.companyName
                    self.currentPrice = String(stock.latestPrice) + " " + stock.currency
                    self.changePrice = String(stock.change)
                    
                    self.priceSectionRightLabels = [
                        String(stock.open),
                        String(stock.low),
                        String(stock.symbol)
                    ]
                }
            case .failure(let err):
                self.error.send(err)
            }
        }
    }
    
    func applyChartDataSource(range: ChartTimeframe) {
        var apiTimeframe: APITimeframe
        var scaleFactor: Int
        
        switch range {
        case .tenMinutes:
            apiTimeframe = .tenMinutes
            scaleFactor = 1
        case .thirtyMinutes:
            apiTimeframe = .thirtyMinutes
            scaleFactor = 1
        case .oneHour:
            apiTimeframe = .thirtyMinutes
            scaleFactor = 2
        case .oneDay:
            apiTimeframe = .oneDay
            scaleFactor = 1
        case .oneWeek:
            apiTimeframe = .oneDay
            scaleFactor = 5
        case .oneMonth:
            apiTimeframe = .oneDay
            scaleFactor = 21
        }
        
        isLoading = true
        dataSource.fetchCandlesFor(ticker: ticker, timeframe: apiTimeframe) { [weak self] result in
            guard let self = self else {
                return
            }
            self.isLoading = false
            switch result {
            case .success(let datasource):
                // please forget about D letter
                let chartConverter = ChartDataSourceConverter()
                DispatchQueue.main.async {
                    let scaledDataSource = chartConverter.scaleDataSource(
                        dataSource: datasource,
                        scaleFactor: scaleFactor
                    )
                    self.chartDataSource = scaledDataSource
                }
            case .failure(let err):
                self.error.send(err)
            }
        }
    }
}
