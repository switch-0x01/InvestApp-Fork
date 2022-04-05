//
//  CandleView.swift
//  My Portfolio
//
//  Created by Eugene Dudkin on 26.02.2022.


import UIKit

class CandleView: UIView {
    
    private var candle: ChartCandle?
    private var xScaleFactor: Double?
    private var yScaleFactor: Double?
    
    init(candle: ChartCandle, xScaleFactor: Double, yScaleFactor: Double) {
        super.init(frame: .zero)
        self.candle = candle
        self.xScaleFactor = xScaleFactor
        self.yScaleFactor = yScaleFactor
        drawCandle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func drawCandle() {
        guard let candle = candle, let xScaleFactor = xScaleFactor, let yScaleFactor = yScaleFactor else { return }
        self.frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: 3.0 * Double(xScaleFactor),
            height: Double(candle.high - candle.low) * Double(yScaleFactor)
        )
        var upperShadow: CGFloat
        var body: CGFloat
        var lowerShadow: CGFloat
        
        if candle.close > candle.open {
            // green candle
            upperShadow = CGFloat(candle.high - candle.close)
            body = CGFloat(candle.close - candle.open)
            lowerShadow = CGFloat(candle.open - candle.low)
        } else {
            // red candle
            upperShadow = CGFloat(candle.high - candle.open)
            body = CGFloat(candle.open - candle.close)
            lowerShadow = CGFloat(candle.close - candle.low)
        }
        
        var color: CGColor  {
            if candle.close > candle.open {
                return UIColor.systemGreen.cgColor
            } else if candle.close < candle.open {
                return UIColor.red.cgColor
            } else {
                return UIColor.black.cgColor
            }
        }
        
        // first part, upper shadow
        let candleLayer1 = CAShapeLayer()
        layer.addSublayer(candleLayer1)
        let path1 = UIBezierPath()
        path1.move(to: CGPoint(x: frame.width / 2, y: 0))
        path1.addLine(to: CGPoint(x: frame.width / 2, y: frame.height - (upperShadow * CGFloat(yScaleFactor))))
        candleLayer1.path = path1.cgPath
        candleLayer1.lineWidth = 1
        candleLayer1.strokeColor = color
        
        // second part, body
        let candleLayer2 = CAShapeLayer()
        layer.addSublayer(candleLayer2)
        let path2 = UIBezierPath()
        path2.move(to: CGPoint(x: frame.width / 2, y: frame.height - lowerShadow * CGFloat(yScaleFactor)))
        path2.addLine(to: CGPoint(x: frame.width / 2, y: frame.height - ((lowerShadow + body) * CGFloat(yScaleFactor))))
        candleLayer2.path = path2.cgPath
        candleLayer2.lineWidth = 3.0 * CGFloat(xScaleFactor)
        candleLayer2.strokeColor = color
        
        // third part, lower shadow
        let candleLayer3 = CAShapeLayer()
        layer.addSublayer(candleLayer3)
        let path3 = UIBezierPath()
        path3.move(to: CGPoint(x: frame.width / 2, y: frame.height))
        path3.addLine(to: CGPoint(x: frame.width / 2, y: frame.height - lowerShadow * CGFloat(yScaleFactor)))
        candleLayer3.path = path3.cgPath
        candleLayer3.lineWidth = 1
        candleLayer3.strokeColor = color
    }
}
