//
//  WebView.swift
//  SDImageSVGWKWebCoderExample
//
//  Created by Won on 2023/05/10.
//

import UIKit
import SwiftUI
import Combine
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        
    }
}

struct WebView_Previews: PreviewProvider{
    static var previews: some View{
        WebView(url: URL(string: "https://www.naver.com")!)
    }
}
