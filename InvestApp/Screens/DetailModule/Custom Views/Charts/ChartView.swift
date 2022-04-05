//
//  ChartView.swift
//  My Portfolio
//
//  Created by Eugene Dudkin on 19.02.2022.
//

import UIKit

class ChartView: UIView {
    
    //MARK: Interface
    public var dataSource: [ChartCandle]? {
        didSet {
            // Recalculate chart's data and scroll to right
            setupView()
            let rightOffset = CGPoint(x: chartScrollView.contentSize.width, y: 0)
            chartScrollView.setContentOffset(rightOffset, animated: false)
            setNeedsLayout()
        }
    }
    public var fullScreenButtonHandler: (() -> ())?
    public var chartStyleButtonHandler: (() -> ())?
    
    public func startAnimating(withMockData isMocked: Bool) {}
    public func stopAnimating() {}

    //MARK: Declarations
    private var drawableDataSourceRange: ClosedRange<Int>?
    private var drawableDataPoints: [CGPoint]?
    private let drawablePointCountExceedFrameWidth = 40
    
    // Chart View foundation
    private let topBorder: UIView = .init() // 1 part
    private let chartScrollView: UIScrollView = .init() // 2 part
    private let auxiliaryView: UIView = .init() // 3 part
    private let sectionBorder: UIView = .init() // 4 part
    private let chartStyleButton: UIButton = .init(type: .custom) // 5 part
    
    // ChartScrollView, 2 part
    private let chartView: UIView = .init() // 2.1 part
    private let chartBorder: UIView = .init() // 2.2 part
    private let chartLabelsView: UIView = .init() // 2.3 part
    
    // ChartView, 2.1 part
    private let chartGridLayer: CALayer = .init() // 2.1.1 part
    private let chartDataLayer: CALayer = .init() // 2.1.2 part
    private let chartGradientLayer: CAGradientLayer = .init() // 2.1.3 part
    private let chartGradientLayerMask: CAShapeLayer = .init() // 2.1.4 part
    
    // AuxiliaryView, 3 part
    private let auxiliaryPriceView: UIView = .init() // 3.1 part
    private let auxiliaryBorderView: UIView = .init() // 3.2 part
    private let auxiliaryButton: UIButton = .init(type: .custom) // 3.3 part
    
    // Long Press layers and Pointers
    private let longPressVerticalLine: CAShapeLayer = .init()
    private let longPressPointExternalCircle: CAShapeLayer = .init()
    private let longPressPointInternalCircle: CAShapeLayer = .init()
    private let longPressTextLabel: CATextLayer = .init()

    private let pointerHorisontalLine: CAShapeLayer = .init()
    private let pointerPriceLabel: CATextLayer = .init()
    
    //MARK: Constants
    // 1 part
    private let topBorderHeight: CGFloat = 1

    // 2 part
    private let xPointSpace: CGFloat = 5
    private let chartViewPadding: CGFloat = 20
    private let chartBorderHeight: CGFloat = 1
    private let chartLabelsViewHeight: CGFloat = 30
    
    // 3 part
    private let auxiliaryViewWidth: CGFloat = 30
    private let auxiliaryBorderHeight: CGFloat = 1
    private let auxiliaryButtonHeight: CGFloat = 30

    // 4 part
    private let sectionBorderWidth: CGFloat = 1
    
    // 5 part
    private let chartStyleButtonPadding: CGFloat = 16
    private let chartStyleButtonHeight: CGFloat = 32

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        configureDelegates()
        drawTopBorder() // 1 part
        drawChartScrollView() // 2 part
        drawAuxiliaryView() // 3 part
        drawSectionBorder() // 4 part
        drawChartStyleButton() // 5 part
    }
    
    override func layoutSubviews() {
        clean()
        setupView()
    }
    
    private func configureDelegates() {
        chartScrollView.delegate = self
    }
    
    //MARK: 1 Part
    private func drawTopBorder() { // 1 part
        addSubview(topBorder)
        topBorder.backgroundColor = .secondaryLabel
        topBorder.frame = CGRect(
            x: 0,
            y: 0,
            width: frame.size.width,
            height: topBorderHeight
        )
    }
    
    //MARK: 2 Part
    private func drawChartScrollView() { // 2 part
        addSubview(chartScrollView)
        chartScrollView.showsHorizontalScrollIndicator = false
        chartScrollView.frame = CGRect(
            x: 0,
            y: topBorderHeight,
            width: frame.size.width - auxiliaryViewWidth - sectionBorderWidth,
            height: frame.size.height - topBorderHeight
        )
        
        if let dataSource = dataSource {
            chartScrollView.contentSize = CGSize(
                width: CGFloat(dataSource.count) * xPointSpace,
                height: chartScrollView.frame.size.height
            )
        }
        
        drawChartView() // 2.1 part
        drawChartBorder() // 2.2 part
        drawLabelsView() // 2.3 part
    }
    
    private func drawChartView() { // 2.1 part
        chartScrollView.addSubview(chartView)
        chartView.frame = CGRect(
            x: 0,
            y: chartViewPadding,
            width: chartScrollView.contentSize.width,
            height: chartScrollView.contentSize.height - (2 * chartViewPadding) - chartLabelsViewHeight
        )
        
        drawGridLayer() // 2.1.1 part
        drawLineChartLayer() // 2.1.2 part
        drawGradientLayer() // 2.1.3 part
        drawMaskGradientLayer() // 2.1.4 part
        
        configureLongTouchRecognizer()
    }
    
    private func drawGridLayer() { // 2.1.1 part
        chartGridLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: chartScrollView.contentSize.width,
            height: chartScrollView.contentSize.height - chartLabelsViewHeight - chartBorderHeight
        )
        chartScrollView.layer.addSublayer(chartGridLayer)
        
        guard let dataSource = dataSource else {
            return
        }

        let textFont = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
        for valueIndex in 0..<dataSource.count where valueIndex % 16 == 0 {
            let textLabelLayer = CATextLayer()
            let textLabelLayerHeight: CGFloat = 9
            let label = dataSource[valueIndex].date
            let textLabelLayerWidth: CGFloat = 150
            
            textLabelLayer.frame = CGRect(
                x: CGFloat(valueIndex) * xPointSpace - textLabelLayerWidth / 2,
                y: 26,
                width: textLabelLayerWidth,
                height: textLabelLayerHeight
            )
            
            let degrees = 270.0
            let radians = CGFloat(degrees * Double.pi / 180)
            textLabelLayer.transform = CATransform3DMakeRotation(
                radians,
                0.0,
                0.0,
                1.0
            )
            
            textLabelLayer.foregroundColor = UIColor.secondaryLabel.cgColor
            textLabelLayer.contentsScale = UIScreen.main.scale
            textLabelLayer.font = textFont
            textLabelLayer.fontSize = textLabelLayerHeight
            textLabelLayer.string = label
            textLabelLayer.alignmentMode = .center
            chartGridLayer.addSublayer(textLabelLayer)
        }
    }
    
    private func drawLineChartLayer() { // 2.1.2 part
        guard
            let dataSource = dataSource,
            let drawableDataSourceRange = getDrawableRange(with: drawablePointCountExceedFrameWidth)
        else {
            return
        }
        self.drawableDataSourceRange = drawableDataSourceRange
        drawableDataPoints = getDrawableDataPoints(with: dataSource, and: drawableDataSourceRange)
        drawLineChart()
        chartView.layer.addSublayer(chartDataLayer)
    }
    
    private func drawGradientLayer() { // 2.1.3 part
        chartGradientLayer.frame = chartView.bounds
        chartGradientLayer.colors = [UIColor.systemGreen.cgColor, UIColor.clear.cgColor]
        chartView.layer.addSublayer(chartGradientLayer)
    }
    
    private func drawMaskGradientLayer() { // 2.1.4 part
        if let visibleDataPoints = drawableDataPoints, !visibleDataPoints.isEmpty {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: visibleDataPoints[0].x, y: chartView.frame.height))
            path.addLine(to: visibleDataPoints[0])
            if let chartPath = createChartLinePath() {
                path.append(chartPath)
            }
            path.addLine(to: CGPoint(
                x: visibleDataPoints[visibleDataPoints.count - 1].x,
                y: chartView.frame.height
            ))
            path.addLine(to: CGPoint(
                x: visibleDataPoints[0].x,
                y: chartView.frame.height
            ))
            chartGradientLayerMask.path = path.cgPath
            chartGradientLayer.mask = chartGradientLayerMask
        }
    }
    
    private func drawChartBorder() { // 2.2 part
        addSubview(chartBorder)
        chartBorder.frame = CGRect(
            x: 0,
            y: frame.size.height - chartLabelsViewHeight - chartBorderHeight,
            width: frame.size.width - sectionBorderWidth - auxiliaryViewWidth,
            height: chartBorderHeight
        )
        chartBorder.backgroundColor = .secondaryLabel
    }
    
    private func drawLabelsView() { // 2.3 part
        chartScrollView.addSubview(chartLabelsView)
        chartLabelsView.frame = CGRect(
            x: 0,
            y: chartScrollView.contentSize.height - chartLabelsViewHeight,
            width: chartScrollView.contentSize.width,
            height: chartLabelsViewHeight
        )

        guard let dataSource = dataSource else {
            return
        }

        let textFont = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
        for valueIndex in 0..<dataSource.count where valueIndex % 16 == 0 {

            let textLabelLayer = CATextLayer()
            let label = dataSource[valueIndex].label
            let textLabelLayerWidth: CGFloat = 60
            
            textLabelLayer.frame = CGRect(
                x: CGFloat(valueIndex) * xPointSpace - textLabelLayerWidth / 2,
                y: 5,
                width: textLabelLayerWidth,
                height: 15
            )
            textLabelLayer.foregroundColor = UIColor.secondaryLabel.cgColor
            textLabelLayer.contentsScale = UIScreen.main.scale
            textLabelLayer.font = textFont
            textLabelLayer.fontSize = 12
            textLabelLayer.string = label
            textLabelLayer.alignmentMode = .center
            chartLabelsView.layer.addSublayer(textLabelLayer)
        }
    }
    
    //MARK: 3 Part
    private func drawAuxiliaryView() { // 3 part
        addSubview(auxiliaryView)
        auxiliaryView.frame = CGRect(
            x: frame.size.width - auxiliaryViewWidth,
            y: topBorderHeight,
            width: auxiliaryViewWidth,
            height: frame.size.height - topBorderHeight
        )
        auxiliaryView.clipsToBounds = true
        
        drawPriceView() // 3.1 part
        drawAuxiliaryBorder() // 3.2 part
        drawAuxiliaryButton() // 3.3 part
    }
    
    private func drawPriceView() { // 3.1 part
        auxiliaryView.addSubview(auxiliaryPriceView)
        auxiliaryPriceView.clipsToBounds = true
        auxiliaryPriceView.frame = CGRect(
            x: 0,
            y: 0,
            width: auxiliaryViewWidth,
            height: auxiliaryView.frame.size.height - auxiliaryButtonHeight - auxiliaryBorderHeight
        )
        
        drawGridTextLayer()
        
        guard let dataSource = dataSource else {
            return
        }

        if let visibleViewRange = getDrawableRange(with: 0) {
            let visibleViewDataSource = Array(dataSource[visibleViewRange.lowerBound..<visibleViewRange.upperBound])
            let candle = visibleViewDataSource.last
            drawPointerPriceLabel(candle: candle)
            drawPointerHorisontalLine(candle: candle)
        }
    }
    
    private func drawAuxiliaryBorder() { // 3.2 part
        auxiliaryView.addSubview(auxiliaryBorderView)
        auxiliaryBorderView.frame = CGRect(
            x: 0,
            y: frame.size.height - auxiliaryButtonHeight - topBorderHeight - auxiliaryBorderHeight,
            width: frame.size.width,
            height: auxiliaryBorderHeight
        )
        auxiliaryBorderView.backgroundColor = .secondaryLabel
    }
    
    private func drawAuxiliaryButton() { // 3.3 part
        auxiliaryView.addSubview(auxiliaryButton)
        
        auxiliaryButton.frame = CGRect(
            x: 0,
            y: frame.size.height - auxiliaryButtonHeight,
            width: auxiliaryButtonHeight,
            height: auxiliaryButtonHeight
        )
        let image = UIImage(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left")
        auxiliaryButton.setImage(image, for: .normal)
        auxiliaryButton.tintColor = .secondaryLabel
        auxiliaryButton.addTarget(self, action: #selector(self.fullScreenButtonTapped), for: .touchUpInside)
    }
    
    @objc func fullScreenButtonTapped(sender: UIButton) {
        guard let fullScreenButtonHandler = fullScreenButtonHandler else { return }
        fullScreenButtonHandler()
    }
    
    //MARK: 4 Part
    private func drawSectionBorder() { // 4 part
        addSubview(sectionBorder)
        sectionBorder.frame = CGRect(
            x: frame.size.width - auxiliaryViewWidth - sectionBorderWidth,
            y: topBorderHeight,
            width: sectionBorderWidth,
            height: frame.size.height - topBorderHeight
        )
        sectionBorder.backgroundColor = .secondaryLabel
    }
    
    //MARK: 5 Part
    private func drawChartStyleButton() { // 5 part
        addSubview(chartStyleButton)
        
        chartStyleButton.frame = CGRect(
            x: chartStyleButtonPadding,
            y: chartStyleButtonPadding + topBorderHeight,
            width: chartStyleButtonHeight,
            height: chartStyleButtonHeight
        )

        let iconImage = UIImage(systemName: "line.diagonal")
        chartStyleButton.setImage(iconImage, for: .normal)
        chartStyleButton.backgroundColor = UIColor(white: 0.2, alpha: 0.5)
        chartStyleButton.tintColor = .systemGreen
        chartStyleButton.layer.borderWidth = 1.0
        chartStyleButton.layer.borderColor = UIColor.systemGreen.cgColor
        chartStyleButton.layer.cornerRadius = 8
        chartStyleButton.addTarget(self, action: #selector(self.chartStyleButtonTapped), for: .touchUpInside)
    }
    
    @objc func chartStyleButtonTapped(sender: UIButton) {
        guard let chartStyleButtonHandler = chartStyleButtonHandler else {
            return
        }
        chartStyleButtonHandler()
    }
    
    //MARK: Helpers
    private func drawLineChart() {
        if let path = createChartLinePath() {
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.strokeColor = UIColor.systemGreen.cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            lineLayer.lineWidth = 2
            chartDataLayer.addSublayer(lineLayer)
        }
    }
    
    private func createChartLinePath() -> UIBezierPath? {
        guard let drawableDataPoints = drawableDataPoints, !drawableDataPoints.isEmpty else {
            return nil
        }
        let path = UIBezierPath()
        path.move(to: drawableDataPoints[0])
        
        for i in 1..<drawableDataPoints.count {
            path.addLine(to: drawableDataPoints[i])
        }
        return path
    }
    
    func getDrawableRange(with visibility: Int) -> ClosedRange<Int>? {
        let offsetX = chartScrollView.contentOffset.x
        let chartVisibleWidth = chartScrollView.frame.size.width + xPointSpace
        
        var minVisibleIndex = Int(offsetX) / Int(xPointSpace) - visibility
        var maxVisibleIndex = (Int(offsetX) + Int(chartVisibleWidth)) / Int(xPointSpace) + visibility
        
        if minVisibleIndex < 0 {
            minVisibleIndex = 0
        }
        
        if let dataSource = dataSource, maxVisibleIndex > dataSource.count {
            maxVisibleIndex = dataSource.count
        }
        
        return minVisibleIndex...maxVisibleIndex
    }
    
    private func getDrawableDataPoints(
        with dataSource: [ChartCandle],
        and range: ClosedRange<Int>
    ) -> [CGPoint] {
        
        let visibleDataSource = Array(dataSource[range.lowerBound..<range.upperBound])
        
        if let max = visibleDataSource.max()?.close,
           let min = visibleDataSource.min()?.close {
            
            var result: [CGPoint] = []
            let minMaxRange = CGFloat(max - min)
            
            for i in range.lowerBound..<range.upperBound {
                let value = CGFloat(dataSource[i].close)
                let height = chartView.frame.height / minMaxRange * (CGFloat(max) - value)
                let point = CGPoint(x: CGFloat(i) * xPointSpace, y: height)
                result.append(point)
            }
            return result
        }
        return []
    }
    
    private func drawGridTextLayer() {
        guard let dataSource = dataSource, let visibleRange = drawableDataSourceRange else {
            return
        }
        
        let visibleDataSource = Array(dataSource[visibleRange.lowerBound..<visibleRange.upperBound])

        if let max = visibleDataSource.max()?.close,
           let min = visibleDataSource.min()?.close {
            
            let minCGFloat = CGFloat(min)
            let maxCGFloat = CGFloat(max)
            
            let gridValue: [CGFloat] = [0, 0.25, 0.5, 0.75, 1]
            let textFont = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
            for value in gridValue {
                let textLayerY: CGFloat = chartView.frame.size.height * CGFloat(value) + chartViewPadding
                let textLayer = CATextLayer()
                let textLayerHeight: CGFloat = 12
                var textValue = maxCGFloat - (maxCGFloat - minCGFloat) * value
                if textValue == 0 {
                    textValue = minCGFloat
                }
                textLayer.frame = CGRect(
                    x: 0,
                    y: textLayerY - textLayerHeight / 2,
                    width: auxiliaryPriceView.frame.size.width,
                    height: textLayerHeight
                )

                textLayer.foregroundColor = UIColor.secondaryLabel.cgColor
                textLayer.contentsScale = UIScreen.main.scale
                textLayer.font = textFont
                textLayer.fontSize = textLayerHeight
                textLayer.string = "\(round(textValue * 10) / 10 )"
                textLayer.alignmentMode = .center
                
                auxiliaryPriceView.layer.addSublayer(textLayer)
            }
        }
    }
    
    private func drawPointerPriceLabel(candle: ChartCandle?) {
        guard
            let dataSource = dataSource,
            let visibleFullRange = drawableDataSourceRange
        else {
            return
        }
        
        let visibleFullDataSource = Array(dataSource[visibleFullRange.lowerBound..<visibleFullRange.upperBound])
        
        if let candlePrice = candle?.close,
           let max = visibleFullDataSource.max()?.close,
           let min = visibleFullDataSource.min()?.close {
            
            let textFont = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
            let textLayerHeight: CGFloat = 12
            
            let screenHeight = chartView.frame.size.height
            let valueRange = CGFloat(max - min)
            let valueHeight = CGFloat(max - candlePrice)
            let textLayerY = screenHeight * valueHeight / valueRange + chartViewPadding - textLayerHeight / 2
            
            pointerPriceLabel.frame = CGRect(
                x: 0,
                y: textLayerY,
                width: auxiliaryPriceView.frame.size.width,
                height: textLayerHeight + textLayerHeight * 0.25
            )
            
            pointerPriceLabel.removeAllAnimations()
            pointerPriceLabel.foregroundColor = UIColor.white.cgColor
            pointerPriceLabel.backgroundColor = UIColor.systemGreen.cgColor
            pointerPriceLabel.contentsScale = UIScreen.main.scale
            pointerPriceLabel.font = textFont
            pointerPriceLabel.fontSize = textLayerHeight
            pointerPriceLabel.string = "\(round(candlePrice * 10) / 10)"
            pointerPriceLabel.alignmentMode = .center
            auxiliaryPriceView.layer.addSublayer(pointerPriceLabel)
        }
    }
            
        
    private func drawPointerHorisontalLine(candle: ChartCandle?) {
        guard let dataSource = dataSource, let visibleFullRange = drawableDataSourceRange else {
            return
        }
        let visibleFullDataSource = Array(dataSource[visibleFullRange.lowerBound..<visibleFullRange.upperBound])
        
        if let candlePrice = candle?.close,
           let max = visibleFullDataSource.max()?.close,
           let min = visibleFullDataSource.min()?.close {
            
            let textLayerHeight: CGFloat = 12
            
            let screenHeight = chartView.frame.size.height
            let valueRange = CGFloat(max - min)
            let valueHeight = CGFloat(max - candlePrice)
            let textLayerY = screenHeight * valueHeight / valueRange + chartViewPadding - textLayerHeight / 2
            
            
            // draw horisontal line on chartScrollView
            let pathLine = UIBezierPath()
            pathLine.move(to: CGPoint(x: 0, y: textLayerY - textLayerHeight - 2))
            pathLine.addLine(to: CGPoint(x: chartView.frame.size.width, y: textLayerY - textLayerHeight - 2))
            pointerHorisontalLine.path = pathLine.cgPath
            pointerHorisontalLine.lineDashPattern = [6, 6]
            pointerHorisontalLine.strokeColor = UIColor.systemGreen.cgColor
            pointerHorisontalLine.lineWidth = 1
            chartView.layer.addSublayer(pointerHorisontalLine)
        }
    }
    
    private func clean() {
        auxiliaryPriceView.layer.sublayers?.forEach {
            $0.removeFromSuperlayer()
        }
        
        chartDataLayer.sublayers?.forEach {
            $0.removeFromSuperlayer()
        }
        
        chartGridLayer.sublayers?.forEach {
            $0.removeFromSuperlayer()
        }
        
        chartLabelsView.layer.sublayers?.forEach {
            $0.removeFromSuperlayer()
        }
        
        chartView.layer.sublayers?.forEach {
            $0.removeFromSuperlayer()
        }
    }
    
    // MARK: Long Press Gesture
    private func configureLongTouchRecognizer() {
        let longTouchRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longTouched))
        chartScrollView.addGestureRecognizer(longTouchRecognizer)
    }

    @objc func longTouched(sender: UILongPressGestureRecognizer) {
        let longPressPoint = sender.location(in: chartView)
        let longPressSelfPoint = sender.location(in: self)

        guard let longPressData = getLongPressData(from: longPressPoint) else {
            return
        }
        
        let longPressCandle = longPressData.chartCandle

        if sender.state == UIGestureRecognizer.State.began {
            drawLongPressVerticalLine(longPressData.point.x)
            drawPointerPriceLabel(candle: longPressCandle)
            drawPointerHorisontalLine(candle: longPressCandle)
            drawLongPressPoint(longPressData.point)
            drawLongPressTextLabel(point: longPressData.point, candle: longPressData.chartCandle, selfPoint: longPressSelfPoint)
            layoutIfNeeded()
        } else if sender.state == UIGestureRecognizer.State.changed {
            drawLongPressVerticalLine(longPressData.point.x)
            drawPointerPriceLabel(candle: longPressCandle)
            drawPointerHorisontalLine(candle: longPressCandle)
            drawLongPressPoint(longPressData.point)
            drawLongPressTextLabel(point: longPressData.point, candle: longPressData.chartCandle, selfPoint: longPressSelfPoint)
            layoutIfNeeded()
        } else if sender.state == UIGestureRecognizer.State.ended {
            setNeedsLayout()
        }
    }

    private func drawLongPressVerticalLine(_ x: CGFloat) {
        let pathLine = UIBezierPath()
        pathLine.move(to: CGPoint(x: x, y: 0 - chartViewPadding))
        pathLine.addLine(to: CGPoint(x: x, y: chartView.frame.size.height + chartViewPadding + 5))
        longPressVerticalLine.path = pathLine.cgPath
        longPressVerticalLine.strokeColor = UIColor.systemGreen.cgColor
        longPressVerticalLine.lineWidth = 1
        chartView.layer.addSublayer(longPressVerticalLine)
    }
    
    private func drawLongPressPoint(_ point: CGPoint) {
        // External Point on ChartView
        let externalCirclePath = UIBezierPath(
            arcCenter: point,
            radius: 4,
            startAngle: 0,
            endAngle: CGFloat.pi * 2,
            clockwise: true
        )
        
        longPressPointExternalCircle.path = externalCirclePath.cgPath
        longPressPointExternalCircle.fillColor = UIColor.systemBackground.cgColor
        longPressPointExternalCircle.strokeColor = UIColor.systemBackground.cgColor
        longPressPointExternalCircle.lineWidth = 1
        chartView.layer.addSublayer(longPressPointExternalCircle)
        
        // Internal Point on ChartView
        let internalCirclePath = UIBezierPath(
            arcCenter: point,
            radius: 2,
            startAngle: 0,
            endAngle: CGFloat.pi * 2,
            clockwise: true
        )
        
        longPressPointInternalCircle.path = internalCirclePath.cgPath
        longPressPointInternalCircle.fillColor = UIColor.systemGreen.cgColor
        longPressPointInternalCircle.strokeColor = UIColor.systemGreen.cgColor
        longPressPointInternalCircle.lineWidth = 1
        chartView.layer.addSublayer(longPressPointInternalCircle)
    }
    
    private func drawLongPressTextLabel(point: CGPoint, candle: ChartCandle, selfPoint: CGPoint) {
        let textLayerHeight: CGFloat = 12
        
        var offsetX: CGFloat
        
        if selfPoint.x < 30 {
            offsetX = 30
        } else if selfPoint.x > (frame.size.width - auxiliaryViewWidth - sectionBorderWidth - 30) {
            offsetX = -30
        } else {
            offsetX = 0
        }
        longPressTextLabel.removeAllAnimations()
        longPressTextLabel.frame = CGRect(
            x: point.x - 30 + offsetX,
            y: 5,
            width: 60,
            height: 15
        )
        longPressTextLabel.removeAllAnimations()
        longPressTextLabel.foregroundColor = UIColor.white.cgColor
        longPressTextLabel.backgroundColor = UIColor.systemGreen.cgColor
        longPressTextLabel.contentsScale = UIScreen.main.scale
        longPressTextLabel.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
        longPressTextLabel.fontSize = textLayerHeight
        longPressTextLabel.string = candle.label
        longPressTextLabel.alignmentMode = .center
        chartLabelsView.layer.addSublayer(longPressTextLabel)
    }
    
    private func getLongPressData(from pressPoint: CGPoint) -> (point: CGPoint, chartCandle: ChartCandle)? {
        guard
            let dataSource = dataSource,
                !dataSource.isEmpty,
                let visibleRange = getDrawableRange(with: drawablePointCountExceedFrameWidth)
        else {
            return nil
        }

        let visiblePoints = getDrawableDataPoints(with: dataSource, and: visibleRange)
        
        var nearestPoint = visiblePoints[0]
        var nearestIndex = 0
        var minGap: CGFloat = CGFloat.infinity
        
        for (index, point) in visiblePoints.enumerated() {
            if abs(point.x - pressPoint.x) < minGap {
                minGap = abs(point.x - pressPoint.x)
                nearestPoint = point
                nearestIndex = visibleRange.lowerBound + index
            }
        }
        return (point: nearestPoint, chartCandle: dataSource[nearestIndex])
    }
}

extension ChartView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setNeedsLayout()
    }
}
