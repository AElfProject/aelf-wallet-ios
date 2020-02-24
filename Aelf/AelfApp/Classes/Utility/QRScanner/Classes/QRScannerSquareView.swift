//
//  QRScannerSquareView.swift
//  QRScanner
//
//  Created by 周斌 on 2018/11/30.
//

import UIKit

public class QRScannerSquareView: UIView {

    let scanLine = UIImageView()
    lazy var resourcesBundle:Bundle? = {
        if let path = Bundle.main.path(forResource: "QRScanner", ofType: "framework", inDirectory: "Frameworks"),
            let framework = Bundle(path: path),
            let bundlePath = framework.path(forResource: "QRScanner", ofType: "bundle"),
            let bundle = Bundle(path: bundlePath) {
            return bundle
        }
        return nil
    }()
    
    public var sizeMultiplier : CGFloat = 0.1 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var lineWidth : CGFloat = 2 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var lineColor : UIColor = UIColor.green {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    func setUp() {
        self.backgroundColor = UIColor.clear
        addSubview(scanLine)
        
        scanLine.translatesAutoresizingMaskIntoConstraints = false
        scanLine.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scanLine.heightAnchor.constraint(equalToConstant: 2).isActive = true
        scanLine.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scanLine.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    func startAnimation() {
        let startPoint = CGPoint(x: scanLine .center.x  , y: 1)
        let endPoint = CGPoint(x: scanLine.center.x, y: bounds.size.height - 1)
        
        let translation = CABasicAnimation(keyPath: "position")
        translation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        translation.fromValue = NSValue(cgPoint: startPoint)
        translation.toValue = NSValue(cgPoint: endPoint)
        translation.duration = 1
        translation.repeatCount = MAXFLOAT
        translation.autoreverses = true
        scanLine.layer.add(translation, forKey: "scan")
    }
    
    func stopAnimation() {
        scanLine.layer.removeAllAnimations()
    }
    
    func drawCorners() {
        let rectCornerContext = UIGraphicsGetCurrentContext()
        
        rectCornerContext?.setLineWidth(lineWidth)
        rectCornerContext?.setStrokeColor(lineColor.cgColor)
        
        //top left corner
        rectCornerContext?.beginPath()
        rectCornerContext?.move(to: CGPoint(x: 0, y: 0))
        rectCornerContext?.addLine(to: CGPoint(x: self.bounds.size.width*sizeMultiplier, y: 0))
        rectCornerContext?.strokePath()
        
        //top rigth corner
        rectCornerContext?.beginPath()
        rectCornerContext?.move(to: CGPoint(x: self.bounds.size.width - self.bounds.size.width*sizeMultiplier, y: 0))
        rectCornerContext?.addLine(to: CGPoint(x: self.bounds.size.width, y: 0))
        rectCornerContext?.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height*sizeMultiplier))
        rectCornerContext?.strokePath()
        
        //bottom rigth corner
        rectCornerContext?.beginPath()
        rectCornerContext?.move(to: CGPoint(x: self.bounds.size.width,
                                            y: self.bounds.size.height -
                                                self.bounds.size.height*sizeMultiplier))
        rectCornerContext?.addLine(to: CGPoint(x: self.bounds.size.width,
                                               y: self.bounds.size.height))
        rectCornerContext?.addLine(to: CGPoint(x: self.bounds.size.width - self.bounds.size.width*sizeMultiplier,
                                               y: self.bounds.size.height))
        rectCornerContext?.strokePath()
        
        //bottom left corner
        rectCornerContext?.beginPath()
        rectCornerContext?.move(to: CGPoint(x: self.bounds.size.width*sizeMultiplier, y: self.bounds.size.height))
        rectCornerContext?.addLine(to: CGPoint(x: 0, y: self.bounds.size.height))
        rectCornerContext?.addLine(to: CGPoint(x: 0, y: self.bounds.size.height - self.bounds.size.height*sizeMultiplier))
        rectCornerContext?.strokePath()
        
        //second part of top left corner
        rectCornerContext?.beginPath()
        rectCornerContext?.move(to: CGPoint(x: 0, y: self.bounds.size.height*sizeMultiplier))
        rectCornerContext?.addLine(to: CGPoint(x: 0, y: 0))
        rectCornerContext?.strokePath()
    }
    func drawLine() {
        guard let image = UIImage(named: "QRCode-line", in: resourcesBundle, compatibleWith: nil)else {
            return
        }
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        lineColor.setFill()
        guard let context = UIGraphicsGetCurrentContext() else {
            scanLine.image = image
            return
        }
        
        context.translateBy(x: 0, y: image.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(CGBlendMode.normal)
        
        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        guard let mask = image.cgImage else {
            scanLine.image = image
            return
        }
        context.clip(to: rect, mask: mask)
        context.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        scanLine.image = newImage
    }
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        self.drawCorners()
        drawLine()
    }
}
