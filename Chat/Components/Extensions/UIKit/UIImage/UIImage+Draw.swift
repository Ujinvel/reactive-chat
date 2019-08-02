//
//  UIImage+Draw.swift
//  Chat
//
//  Created by Ujin on 8/2/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import UIKit

extension UIImage {
    static func draw(cornerRadius: CGFloat,
                     fillColor: UIColor,
                     borderColor: UIColor = .clear,
                     borderWidth: CGFloat = 1.0,
                     opaque: Bool? = nil) -> UIImage {
        let cornerSize = max(borderWidth, cornerRadius)
        let side = 2 * cornerSize + 1
        let imageRect = CGRect(x: 0, y: 0, width: side, height: side)
        
        let isOpaque = opaque ?? (cornerRadius == 0 && fillColor != .clear)
        UIGraphicsBeginImageContextWithOptions(imageRect.size, isOpaque, 0)
            let context = UIGraphicsGetCurrentContext()
            let path = UIBezierPath(roundedRect: imageRect, cornerRadius: cornerRadius)
        
            context?.setFillColor(fillColor.cgColor)
            path.fill()
        
            if borderWidth > 0 && borderColor != .clear {
                let borderPath = UIBezierPath(roundedRect: imageRect.insetBy(dx: borderWidth / 2, dy: borderWidth / 2),
                                              cornerRadius: cornerRadius - borderWidth / 2)
                borderPath.lineWidth = borderWidth
            
                context?.setStrokeColor(borderColor.cgColor)
                borderPath.stroke()
            }
        
            let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!.resizableImage(withCapInsets: UIEdgeInsets(top: cornerSize,
                                                                 left: cornerSize,
                                                                 bottom: cornerSize,
                                                                 right: cornerSize),
                                     resizingMode: .stretch)
    }
}
