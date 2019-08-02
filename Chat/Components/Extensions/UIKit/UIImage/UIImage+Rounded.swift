//
//  UIImage+Rounded.swift
//  Chat
//
//  Created by Ujin on 8/2/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import UIKit

extension UIImage {
    public func rounded(withCornerRadius radius: CGFloat, divideRadiusByImageScale: Bool = false) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            let scaledRadius = divideRadiusByImageScale ? radius / scale : radius
            let clippingPath = UIBezierPath(roundedRect: CGRect(origin: CGPoint.zero, size: size), cornerRadius: scaledRadius)
        
            clippingPath.addClip()
            draw(in: CGRect(origin: CGPoint.zero, size: size))
        
            let roundedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return roundedImage
    }
}
