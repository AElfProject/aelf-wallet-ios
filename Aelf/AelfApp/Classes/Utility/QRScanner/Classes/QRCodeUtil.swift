//
//  QRCodeUtil.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/5.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit

class QRCodeUtil {
    static func setQRCodeToImageView(_ imageView: UIImageView?, _ url: String) {
        if imageView == nil {
            return
        }

        // 显示图片
        imageView?.image = createQRCode(origin: url)
    }

    static func getQRCode(origin: String) -> UIImage {
        return createQRCode(origin: origin)
    }

    private static func createQRCode(origin: String) -> UIImage {

        // 创建二维码滤镜
        let filter = CIFilter(name: "CIQRCodeGenerator")

        // 恢复滤镜默认设置
        filter?.setDefaults()

        // 设置滤镜输入数据
        let data = origin.data(using: String.Encoding.utf8)
        filter?.setValue(data, forKey: "inputMessage")

        // 设置二维码的纠错率 通常有L、M、Q、H这四种可能的纠正模式，分别代表了7%、15%、25%、30%的错误恢复能力
        filter?.setValue("L", forKey: "inputCorrectionLevel")
        
        // 从二维码滤镜里面, 获取结果图片
        var image = filter?.outputImage

        // 生成一个高清图片
        let transform = CGAffineTransform.init(scaleX: 20, y: 20)
        image = image?.transformed(by: transform)

        // 图片处理
        var resultImage = UIImage(ciImage: image!)

        // 设置二维码中心显示的小图标
        //        let center = UIImage(named: "AppIcon.png")
        //        resultImage = getClearImage(sourceImage: resultImage, center: center!)
        resultImage = getClearImage(sourceImage: resultImage)

        return resultImage
    }

    static func getClearImage(sourceImage: UIImage) -> UIImage {

//    static func getClearImage(sourceImage: UIImage, center: UIImage) -> UIImage {
        
        let size = sourceImage.size
        // 开启图形上下文
        UIGraphicsBeginImageContext(size)
        
        // 绘制大图片
        sourceImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
//        // 绘制二维码中心小图片
//        let width: CGFloat = 80
//        let height: CGFloat = 80
//        let x: CGFloat = (size.width - width) * 0.5
//        let y: CGFloat = (size.height - height) * 0.5
//        center.draw(in: CGRect(x: x, y: y, width: width, height: height))
        
        // 取出结果图片
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // 关闭上下文
        UIGraphicsEndImageContext()
        
        return resultImage!
    }
}
