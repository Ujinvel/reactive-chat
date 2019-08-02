//
//  Data+DownsampleImage.swift
//  Chat
//
//  Created by Ujin on 8/2/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import UIKit

extension Data {
    // https://developer.apple.com/videos/play/wwdc2018/219
    // making large images for displaying at smaller size
    public func downsampleImage(to pointSize: CGSize = CGSize(width: 150, height: 150),
                                scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        return autoreleasepool {
            guard let imageSource = CGImageSourceCreateWithData(self as CFData,
                                                                [kCGImageSourceShouldCache: false] as CFDictionary) else {// create an object without decoding
                                                                    return nil
            }
            let maxDimensionInPixels = Swift.max(pointSize.width, pointSize.height) * scale
            let sampleOptions = [kCGImageSourceCreateThumbnailFromImageAlways: true,
                                 kCGImageSourceShouldCacheImmediately: true, // сreate an object from a compressed image
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
            if let sampleImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, sampleOptions) {
                return UIImage(cgImage: sampleImage)
            }
            return nil
        }
    }
}
