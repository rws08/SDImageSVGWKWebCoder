//
//  SDImageSVGWKWebCoderExampleApp.swift
//  SDImageSVGWKWebCoderExample
//
//  Created by Won on 2023/05/09.
//

import SwiftUI
import SDWebImageSwiftUI
import SDImageSVGWKWebCoder

@main
struct SDImageSVGWKWebCoderExampleApp: App {
    init() {
        SDImageCodersManager.shared.addCoder(SDImageSVGWKWebCoder.shared)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
