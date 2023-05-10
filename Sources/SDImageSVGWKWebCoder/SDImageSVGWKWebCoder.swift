import SDWebImage
import SwiftUI

public extension SDImageCoderOption {
    static let decodeBackgroundColor = SDImageCoderOption(rawValue: "decodeBackgroundColor")
}

public class SDImageSVGWKWebCoder: NSObject, SDImageCoder {
    public static let shared = SDImageSVGWKWebCoder()
    
    // MARK: - SDImageCoder
    public func canDecode(from data: Data?) -> Bool {
        return isSVGFormatForData(data)
    }
    
    public func decodedImage(with data: Data?, options: [SDImageCoderOption: Any]? = nil) -> UIImage? {
        if let data = data {
            let backgroundColor = options?[.decodeBackgroundColor] as? Color
            let svgData = SDImageSVGWebData(data, backgroundColor: backgroundColor)
            let image = svgData.getImage()
            return image
        }
        return nil
    }
    
    public func canEncode(to format: SDImageFormat) -> Bool {
        return false
    }
    
    public func encodedData(with image: UIImage?, format: SDImageFormat, options: [SDImageCoderOption: Any]? = nil) -> Data? {
        return nil
    }
    
    private func isSVGFormatForData(_ data: Data?) -> Bool {
        guard let data = data,
              let searchData = SDImageSVGWebData.kSVGTagEnd.data(using: .utf8)
        else { return false }
        
        let searchCount = min(100, data.count)
        let startIdx = data.count - searchCount
        
        return data.range(of: searchData, options: .backwards, in: startIdx..<data.count) != nil
    }
}

