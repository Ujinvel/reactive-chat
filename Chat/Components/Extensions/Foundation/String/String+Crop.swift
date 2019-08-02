//
//  String+Crop.swift
//  Chat
//
//  Created by Ujin on 8/2/19.
//  Copyright © 2019 Ujin. All rights reserved.
//

import Foundation

extension String {
    func cropText(replacementText text: String,
                  range: NSRange,
                  maxSymbolsCount: Int) -> String? {
        var resultText = self
        
        if let range = Range(range, in: resultText) {
            if !text.isEmpty {
                resultText.insert(contentsOf: text, at: range.lowerBound)
            } else {
                resultText.removeSubrange(range)
            }
            
            if resultText.count >= maxSymbolsCount {
                resultText = String(resultText[resultText.startIndex...resultText.index(resultText.startIndex, offsetBy: maxSymbolsCount - 1)])
                resultText = resultText.trimmingCharacters(in: .whitespacesAndNewlines)
                
                return resultText
            }
        }
        return nil
    }
}
