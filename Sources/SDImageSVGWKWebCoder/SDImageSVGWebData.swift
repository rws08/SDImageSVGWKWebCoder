//
//  SDImageSVGWebData.swift
//  
//
//  Created by Won on 2023/05/09.
//

import SDWebImage
import SwiftUI
import WebKit

class SDImageSVGWebData: NSObject, WKNavigationDelegate {
    static let kSVGTagEnd = "</svg>"
    private let kTimeout = 15.0
        
    private var htmlSVG = ""
    public var width: CGFloat = 0
    public var height: CGFloat = 0
    private var image: UIImage?
    private var semaphore: DispatchSemaphore?
    private var svgWebView: WKWebView?
    
    var data: Data
    var backgroundColor: Color?
    
    init(_ data: Data, backgroundColor: Color? = nil) {
        self.data = data
        self.backgroundColor = backgroundColor
        super.init()
        makeHtmlSVG()
    }
    
    public func getImage() -> UIImage? {
        semaphore = DispatchSemaphore(value: 0)
        renderSVGToWebView()
        _ = semaphore?.wait(timeout: .now() + kTimeout)
        removeRender()
        
        return image
    }
    
    private func makeHtmlSVG() {
        if let strSvg = String(data: data, encoding: .utf8) {
            let svg = rewriteSVGSize(strSvg)
            htmlSVG = """
                 <html>
                     <head> </head>
                     <body style=\"width: 100vw; height: 100vh; margin: 0;\">
                         \(svg)
                     </body>
                 </html>
                 """
        } else {
            htmlSVG = ""
        }
    }
    
    private func removeRender() {
        DispatchQueue.main.async {
            if self.svgWebView != nil {
                self.svgWebView?.removeFromSuperview()
                self.svgWebView = nil
            }
            self.semaphore = nil
        }
    }
    
    private func renderSVGToWebView() {
        DispatchQueue.main.async {
            let preferences = WKPreferences()
            preferences.javaScriptCanOpenWindowsAutomatically = false
            
            let configuration = WKWebViewConfiguration()
            configuration.preferences = preferences
            configuration.allowsAirPlayForMediaPlayback = false
            
            let webView = WKWebView(frame: CGRect(x: UIScreen.main.bounds.size.width, y: 200, width: max(320, self.width), height: max(320, self.height)), configuration: configuration)
            webView.scrollView.isScrollEnabled = false
            webView.navigationDelegate = self
            webView.loadHTMLString(self.htmlSVG, baseURL: nil)
            
            self.svgWebView?.removeFromSuperview()
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let window = windowScene?.windows.first
            window?.rootViewController?.view.insertSubview(webView, at: -1)
                        
            self.svgWebView = webView
        }
    }
    
    // MARK: - WKNavigationDelegate
    func webView(_ webview: WKWebView, didFinish: WKNavigation!) {
        DispatchQueue.main.async { // rendering in main thread
            webview.takeSnapshot(with: nil) { image, _ in
                self.image = image
                self.semaphore?.signal()
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.image = nil
        self.semaphore?.signal()
    }
    
    private func cutOnlySVG(_ string: String) -> String {
        guard let startRange = string.range(of: "<svg") else { return string }
        guard let endRange = string.range(of: SDImageSVGWebData.kSVGTagEnd, options: .backwards) else {
            return string
        }
        
        let tagRange = startRange.lowerBound..<endRange.upperBound
        return String(string[tagRange])
    }
    
    private func rewriteSVGSize(_ str: String) -> String {
        let string = cutOnlySVG(str)
        guard let startRange = string.range(of: "<svg") else { return string }
        let remainder = startRange.upperBound..<string.endIndex
        guard let endRange = string.range(of: ">", range: remainder) else {
            return string
        }
        
        let tagRange = startRange.lowerBound..<endRange.upperBound
        let oldTag   = string[tagRange]
        
        var attrs: [String: String] = {
            final class Handler: NSObject, XMLParserDelegate {
                var attrs: [String: String]?
                
                func parser(_ parser: XMLParser, didStartElement: String, namespaceURI: String?, qualifiedName: String?, attributes: [String: String]) {
                    self.attrs = attributes
                }
            }
            let parser  = XMLParser(data: Data((string[tagRange] + SDImageSVGWebData.kSVGTagEnd).utf8))
            let handler = Handler()
            parser.delegate = handler
            
            guard parser.parse() else { return [:] }
            return handler.attrs ?? [:]
        }()
        
        self.width = CGFloat(Int(attrs["width"]?.filter { $0.isNumber } ?? "0") ?? 0)
        self.height = CGFloat(Int(attrs["height"]?.filter { $0.isNumber } ?? "0") ?? 0)
        if let viewBox = attrs["viewBox"],
           self.width == 0, self.height == 0 {
            let viewFrame = viewBox.split(separator: " ")
            if viewFrame.count == 4 {
                self.width = CGFloat(Int(viewFrame[2].filter { $0.isNumber }) ?? 0)
                self.height = CGFloat(Int(viewFrame[3].filter { $0.isNumber }) ?? 0)
            }
        }
        
        // set minimum size for display ( If the size is too small, the image won't render properly. )
        if self.width != 0, self.height != 0,
           self.width < 320 || self.height < 320 {
            let scale = min(320/self.width, 320/self.height)
            self.width *= scale
            self.height *= scale
        }
        
        // set size
        if attrs["viewBox"] == nil &&
            (attrs["width"] != nil || attrs["height"] != nil) {
            let w = attrs.removeValue(forKey: "width")  ?? "100%"
            let h = attrs.removeValue(forKey: "height") ?? "100%"
            let x = attrs.removeValue(forKey: "x")      ?? "0"
            let y = attrs.removeValue(forKey: "y")      ?? "0"
            attrs["viewBox"] = "\(x) \(y) \(w) \(h)"
        }
        attrs.removeValue(forKey: "x")
        attrs.removeValue(forKey: "y")
        attrs["width"]  = "100%"
        attrs["height"] = "100%"
        
        // set backgroundcolor
        if let backgroundColor = self.backgroundColor {
            print("backgroundcolor")
            if attrs["style"] == nil ||
                attrs["style"]?.contains("background") == false {
                if let style = attrs["style"] {
                    attrs["style"] = "\(style) background:\(backgroundColor.hexStringFromColor())"
                } else {
                    attrs["style"] = "background:\(backgroundColor.hexStringFromColor())"
                }
            }
        }
        
        func renderTag(_ tag: String, attributes: [String: String]) -> String {
            var ms = "<\(tag)"
            for (key, value) in attributes {
                ms += " \(key)=\""
                ms += value
                    .replacingOccurrences(of: "&", with: "&amp;")
                    .replacingOccurrences(of: "<", with: "&lt;")
                    .replacingOccurrences(of: ">", with: "&gt;")
                    .replacingOccurrences(of: "'", with: "&apos;")
                    .replacingOccurrences(of: "\"", with: "&quot;")
                ms += "\""
            }
            ms += ">"
            return ms
        }
        
        let newTag = renderTag("svg", attributes: attrs)
        print(newTag)
        return newTag == oldTag ? string : string.replacingCharacters(in: tagRange, with: newTag)
    }
}

extension Color {
    func hexStringFromColor() -> String {
        let components = self.components
        let r = components.red
        let g = components.green
        let b = components.blue
        
        let hexString = String(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        return hexString
    }
    
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        guard UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a) else {
            return (0, 0, 0, 0)
        }
        
        return (r, g, b, a)
    }
}
