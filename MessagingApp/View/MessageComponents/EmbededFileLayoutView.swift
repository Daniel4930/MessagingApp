//
//  FileEmbededView.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/13/25.
//

import SwiftUI

enum DataSize {
    case byte(unit: String = "byte")
    case KB(unit: String = "KB")
    case MB(unit: String = "MB")
}

struct EmbededFileLayoutView: View {
    let name: String
    let data: Data
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "document.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundStyle(.gray)
            VStack(alignment: .leading) {
                Text(name)
                    .font(.callout)
                    .foregroundStyle(.blue)
                Text("\(fileSizeTextFormat())")
                    .font(.caption)
            }
        }
        .padding()
        .background(Color("SecondaryBackgroundColor"))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        
    }
}
extension EmbededFileLayoutView {
    func fileSizeTextFormat() -> String {
        let size = data.count
        var sizeUnit = DataSize.byte()
        var result = ""
        var quotient: Float = Float(size)
        var iteration = 0
        
        while quotient > 1000 {
            quotient = quotient / 1000
            iteration += 1
        }
        
        let convertedSize = quotient
        if iteration == 0 {
            sizeUnit = DataSize.byte()
        }
        else if iteration == 1 {
            sizeUnit = DataSize.KB()
        } else {
            sizeUnit = DataSize.MB()
        }
        
        let trailingDecimal = convertedSize - convertedSize.rounded(.down)
        
        switch sizeUnit {
        case .byte(let unit):
            result = String(Int(convertedSize)) + " " + unit + (ceilf(convertedSize) > 1 ? "s" : "")
        case .KB(let unit):
            result = (trailingDecimal.rounded(toPlaces: 2) > 0 ? String(format: "%.2f", convertedSize) : String(Int(convertedSize))) + " " + unit
        case .MB(let unit):
            result = (trailingDecimal.rounded(toPlaces: 2) > 0 ? String(format: "%.2f", convertedSize) : String(Int(convertedSize))) + " " + unit
        }
        
        return result
    }
}
extension Float {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
}
