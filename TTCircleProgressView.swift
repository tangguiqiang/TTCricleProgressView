//
//  TTCircleProgressView.swift
//  圆形进度条
//
//  Created by tang on 2017/2/28.
//  Copyright © 2017年 tang. All rights reserved.
//

import UIKit

class TTCircleProgressView: UIView {

    /// 动画模式
    enum AnimationModel {
        case sameTime    // 同等时间
        case byProgress  // 根据进度决定动画时间
    }
    
    /// 动画模式 默认同等时间
    var animModel: AnimationModel = .sameTime {
        didSet {
            setNeedsDisplay()
        }
    }
    /// 线条背景色 默认灰色
    var pathBackColor: UIColor = UIColor.gray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// 线条填充色 默认红色
    var pathFillColor: UIColor = UIColor.red {
        didSet {
            setNeedsDisplay()
        }
    }
    /// 起点角度。角度从水平右侧开始为0，顺时针为增加角度。直接传度数 如-90
    fileprivate var tStartAngle: CGFloat? = 0
    var startAngle: CGFloat = 0 {
        willSet {
            if tStartAngle != newValue {
                tStartAngle = cricleDegreeToRadian(degree: newValue)
                setNeedsDisplay()
            }
        }
    }
    
    /// 减少的角度 直接传度数 如30
    fileprivate var tReduceAngle: CGFloat? = 0
    var reduceAngle: CGFloat = 0 {
        willSet {
            if newValue >= 360 { return }
            tReduceAngle = cricleDegreeToRadian(degree: newValue)
            setNeedsDisplay()
        }
    }
    
    /// 线宽 默认5
    var strokeWidth: CGFloat = 5 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// 是否显示小圆点
    var showPoint: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// 是否显示文字
    var showText: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// 文字的大小
    var textFont: UIFont = UIFont.boldSystemFont(ofSize: 22) {
        didSet {
            setNeedsDisplay()
        }
    }
    /// 文字的颜色
    var textColor: UIColor = UIColor.black {
        didSet {
            setNeedsDisplay()
        }
    }
    /// 文字格式是否保留两位小数
    var showDoublePoint: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// 进度 0-1
    var progress: CGFloat? {
        willSet {
            self.fakeProgress = 0.0
            if timer != nil {
                timer!.invalidate()
                timer = nil
            }
            //如果为0则直接刷新
            if newValue == 0 {
                setNeedsDisplay()
                return
            }
            
            timer = Timer(timeInterval: 0.005, repeats: true, block: { (timer) in
                
                guard newValue != nil else { return }
                
                if self.fakeProgress >= newValue! || self.fakeProgress >= 1.0 {
                    //最后一次赋准确值
                    self.fakeProgress = newValue!
                    self.setNeedsDisplay()
                    if self.timer != nil {
                        self.timer!.invalidate()
                        self.timer = nil
                    }
                    return
                } else {
                    //进度条动画
                    self.setNeedsDisplay()
                }
                
                // 增加数值
                if self.animModel == .sameTime {
                    //不同进度动画时间基本相同
                    self.fakeProgress += 0.01 * newValue!
                } else {
                    //进度越大动画时间越长。
                    self.fakeProgress += 0.01
                }
            })
            RunLoop.current.add(timer!, forMode: .commonModes)
            
        }
    }
    
    /// 用来逐渐增加直到等于progress的值
    fileprivate var fakeProgress: CGFloat = 0.0
    fileprivate var timer: Timer?
    //初始化 坐标 线条背景色 填充色 起始角度 线宽
    init(frame: CGRect, pathBackColor: UIColor?, pathFillColor: UIColor?, startAngle: CGFloat, strokeWidth: CGFloat) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        if pathBackColor != nil {
            self.pathBackColor = pathBackColor!
        }
        if pathFillColor != nil {
            self.pathFillColor = pathFillColor!
        }
        self.startAngle = cricleDegreeToRadian(degree: startAngle)
        self.strokeWidth = strokeWidth
        
    }
    
    /// 角度转弧度函数
    private func cricleDegreeToRadian(degree: CGFloat) -> CGFloat {
        return degree * CGFloat(M_PI) / 180
    }
    
    
    //画背景线、填充线、小圆点、文字
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let ctx = UIGraphicsGetCurrentContext()
        
        // 设置中心点 半径 起点和终点
        let maxWidth = frame.width < frame.height ? frame.width : frame.height
        let center = CGPoint(x: maxWidth * 0.5, y: maxWidth * 0.5)
        // 留出一像素，防止与边界相切的地方被切平
        let radius = maxWidth * 0.5 - strokeWidth * 0.5 - 1
        // 圆终点位置
        let endA = startAngle + (cricleDegreeToRadian(degree: 360) - reduceAngle)
        // 数值终点位置
        let valueEndA = startAngle + (cricleDegreeToRadian(degree: 360) - reduceAngle) * fakeProgress
        
        // 背景线
        let basePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endA, clockwise: true)
        // 设置线条宽度
        ctx?.setLineWidth(strokeWidth)
        // 设置线条顶端
        ctx?.setLineCap(.round)
        // 设置线条颜色
        pathBackColor.setStroke()
        // 把路径添加到上下文
        ctx?.addPath(basePath.cgPath)
        // 渲染背景线
        ctx?.strokePath()
        
        
        // 数值路径线
        let valuePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: valueEndA, clockwise: true)
        // 设置线条顶端
        ctx?.setLineCap(.round)
        // 设置线条颜色
        pathFillColor.setStroke()
        // 把路径添加到上下文
        ctx?.addPath(valuePath.cgPath)
        // 渲染数值线
        ctx?.strokePath()
        if showPoint == true {
            let x = frame.width * 0.5 + ((bounds.width - strokeWidth) * 0.5 - 1) * CGFloat(cosf(Float(valueEndA))) - strokeWidth * 0.5
            let y = frame.width * 0.5 + ((bounds.width - strokeWidth) * 0.5 - 1) * CGFloat(sinf(Float(valueEndA))) - strokeWidth * 0.5
            
            ctx?.draw((UIImage(named: "circle_point")?.cgImage)!, in: CGRect(x: x, y: y, width: strokeWidth, height: strokeWidth))
        }
        
        if showText == true {
            //画文字
            let format = showDoublePoint == true ? "%.2f%%": "%.f%%"
            let currentText = String(format: format, fakeProgress * 100) as NSString
            //段落格式
            let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            textStyle.lineBreakMode = .byWordWrapping
            textStyle.alignment = .center
            //构建属性集合
            let attributes = [NSFontAttributeName: textFont,
                              NSForegroundColorAttributeName: textColor,
                              NSParagraphStyleAttributeName: textStyle] as [String : Any]
            //获得size
            let stringSize = currentText.size(attributes: attributes)
            
            let x = (frame.width - stringSize.width) * 0.5
            let y = (frame.height - stringSize.height) * 0.5
            //垂直居中
            let r = CGRect(x: x, y: y, width: stringSize.width, height: stringSize.height)
            // 开始画
            currentText.draw(in: r, withAttributes: attributes)
        }
        
        
        
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
