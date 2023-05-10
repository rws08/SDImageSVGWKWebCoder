//
//  ContentView.swift
//  SDImageSVGWKWebCoderExample
//
//  Created by Won on 2023/05/09.
//

import SwiftUI
import SDWebImageSwiftUI
import WebKit

struct ContentView: View {
    let imageUrl = "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/alphachannel.svg"
    
    var body: some View {
        VStack {
            Text("Using WKWebView")
                .foregroundColor(.white)
            WebView(url: URL(string:  imageUrl)!)
            
            Text("Using SDImageSVGWKWebCoder")
                .foregroundColor(.white)
            WebImage(url: URL(string:  imageUrl)!)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
            
            Text("Using SDImageSVGWKWebCoder with BG")
                .foregroundColor(.white)
            WebImage(url: URL(string:  imageUrl)!, context: [.imageDecodeOptions: [SDImageCoderOption.decodeBackgroundColor: Color.gray], .storeCacheType: SDImageCacheType.none.rawValue])
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
        }
        .padding()
        .background(Color.black)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
