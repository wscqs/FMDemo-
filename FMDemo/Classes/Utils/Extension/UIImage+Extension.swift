//
//  UIImage+Extension.swift
//  QSBaoKan
//
//  Created by mba on 16/6/7.
//  Copyright © 2016年 cqs. All rights reserved.
//


import UIKit

extension UIImage {

    func qs_avatarImage(size: CGSize?, backColor: UIColor = UIColor.white,lineColor: UIColor = UIColor.lightGray) -> UIImage? {
        
        var size = size
        if size == nil || size?.width == 0 {
            size = CGSize(width: 34, height: 34)
        }
        let rect = CGRect(origin: CGPoint(), size: size!)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        
        backColor.setFill()
        UIRectFill(rect)
        
        let path = UIBezierPath(ovalIn: rect)
        path.addClip()
        
        draw(in: rect)
        
        let ovalPath = UIBezierPath(ovalIn: rect)
        ovalPath.lineWidth = 0.1
        lineColor.setStroke()
        ovalPath.stroke()
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return result
    }
    
    /// 由颜色生成的图片
    class func imageWithColor(_ color: UIColor, size: CGSize) -> UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: size.width == 0 ? 1.0 : size.width, height: size.height == 0 ? 1.0 : size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    /*
     将图片等比例缩放, 缩放到图片的宽度等屏幕的宽度
     */
    func displaySize() -> CGSize {
        // 新的高度 / 新的宽度 = 原来的高度 / 原来的宽度
        // 新的宽度
        let newWidth = SCREEN_WIDTH
        
        // 新的高度
        let newHeight = newWidth * size.height / size.width
        
        let newSize = CGSize(width: newWidth, height: newHeight)
        return newSize
    }
    
    /**
     缩放图片到指定的尺寸
     
     - parameter newSize: 需要缩放的尺寸
     
     - returns: 返回缩放后的图片
     */
    func resizeImageWithNewSize(_ newSize: CGSize) -> UIImage {
        
        var rect = CGRect.zero
        let oldSize = self.size
        
        if newSize.width / newSize.height > oldSize.width / oldSize.height {
            rect.size.width = newSize.height * oldSize.width / oldSize.height
            rect.size.height = newSize.height
            rect.origin.x = (newSize.width - rect.size.width) * 0.5
            rect.origin.y = 0
        } else {
            rect.size.width = newSize.width
            rect.size.height = newSize.width * oldSize.height / oldSize.width
            rect.origin.x = 0
            rect.origin.y = (newSize.height - rect.size.height) * 0.5
        }
        
        UIGraphicsBeginImageContext(newSize)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.clear.cgColor)
        UIRectFill(CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    /**
     调整图片为正方向
     - returns: 调整后的图片
     */
    func fixOrientation() -> UIImage {
        //        // No-op if the orientation is already correct
        //        if self.imageOrientation == .Up {
        //            return self
        //        }
        //        // We need to calculate the proper transformation to make the image upright.
        //        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        //        var transform: CGAffineTransform = CGAffineTransformIdentity
        //        switch self.imageOrientation {
        //        case .Down, .DownMirrored:
        //            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height)
        //            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
        //        case .Left, .LeftMirrored:
        //            transform = CGAffineTransformTranslate(transform, self.size.width, 0)
        //            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
        //        case .Right, .RightMirrored:
        //            transform = CGAffineTransformTranslate(transform, 0, self.size.height)
        //            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
        //        default:
        //            break
        //        }
        //
        //        switch self.imageOrientation {
        //        case .UpMirrored, .DownMirrored:
        //            transform = CGAffineTransformTranslate(transform, self.size.width, 0)
        //            transform = CGAffineTransformScale(transform, -1, 1)
        //        case .LeftMirrored, .RightMirrored:
        //            transform = CGAffineTransformTranslate(transform, self.size.height, 0)
        //            transform = CGAffineTransformScale(transform, -1, 1)
        //        default:
        //            break
        //        }
        //
        //        // Now we draw the underlying CGImage into a new context, applying the transform
        //        // calculated above.
        //
        //
        //        //这里需要注意下CGImageGetBitmapInfo，它的类型是Int32的，CGImageGetBitmapInfo(self.CGImage).rawValue，这样写才不会报错
        //        let ctx: CGContextRef = CGBitmapContextCreate(nil, Int(self.size.width), Int(self.size.height), CGImageGetBitsPerComponent(self.CGImage), 0, CGImageGetColorSpace(self.CGImage), CGImageGetBitmapInfo(self.CGImage).rawValue)!
        //        CGContextConcatCTM(ctx, transform)
        //        switch self.imageOrientation {
        //        case .Left, .LeftMirrored, .Right, .RightMirrored:
        //            // Grr...
        //            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.height, self.size.width), self.CGImage)
        //        default:
        //            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage)
        //        }
        //
        //        // And now we just create a new UIImage from the drawing context
        //        let cgimg: CGImageRef = CGBitmapContextCreateImage(ctx)!
        //        let img: UIImage = UIImage(CGImage: cgimg)
        //        return img
        
        
        if imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: CGPoint.zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage!;
    }
}
