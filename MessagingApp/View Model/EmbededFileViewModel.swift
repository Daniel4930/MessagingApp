//
//  EmbededFileViewModel.swift
//  MessagingApp
//
//  Created by Daniel Le on 9/20/25.
//

import Foundation

enum DataSize {
    case byte(unit: String = "byte")
    case KB(unit: String = "KB")
    case MB(unit: String = "MB")
}

class EmbededFileViewModel: ObservableObject {
    @Published var file: MessageFile
    @Published var fileUrl: URL?
    
    init(file: MessageFile) {
        self.file = file
    }
    
    func fileSizeTextFormat() -> String {
        let size = file.size
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
    
    func prepareFileUrl() async -> URL? {
        var tempUrl: URL?

        // If file retrieved from locally (from file -> contains data only)
        if let data = file.data {
            tempUrl = writeDataToTempDirectory(data: data, fileName: file.name)
        }

        // If file retrieved from firebase (only contains url (https)), save it to a temp directory
        else if let fileURLString = file.url {
            // Use storageUniqueName if available, otherwise fall back to regular name
            let fileName = file.storageUniqueName ?? file.name

            // Check if file already exists in temp directory
            let tempDir = FileManager.default.temporaryDirectory
            let cachedFileURL = tempDir.appendingPathComponent(fileName)

            if FileManager.default.fileExists(atPath: cachedFileURL.path) {
                return cachedFileURL
            }

            guard let data = await saveDataFromRemoteURL(from: fileURLString) else { return nil }

            tempUrl = writeDataToTempDirectory(data: data, fileName: fileName)
        }
        return tempUrl
    }
    
    private func writeDataToTempDirectory(data: Data, fileName: String) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
        } catch {
            print("Failed to write data to temporary directory: \(error)")
            return nil
        }
        return fileURL
    }
    
    /// If file retrieved from firebase (only contains url (https)), get data
    private func saveDataFromRemoteURL(from urlString: String) async -> Data? {
        guard let fileUrl = URL(string: urlString) else { return nil }

        do {
            let urlRequest = URLRequest(url: fileUrl)
            let (tempURL, _) = try await URLSession.shared.download(for: urlRequest)

            let data = try Data(contentsOf: tempURL)

            return data
        } catch is CancellationError {
            // Task was cancelled (view disappeared during scroll) - this is expected
            return nil
        } catch {
            print("Failed to retrieve tempURL downloaded from remote URL: \(error)")
        }

        return nil
    }
}
