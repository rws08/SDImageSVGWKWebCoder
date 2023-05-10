# SDImageSVGWKWebCoder for iOS

SDImageSVGWKWebCoder is a Swift Package Manager compatible library that provides a custom Coder for the popular iOS image loading library, SDWebImage. It allows you to load and display SVG images using SDWebImage. This library uses WKWebView to render SVG images and capture them as images.

## Features
- Load SVG images using SDWebImage.
- Render SVG images in WKWebView.
- Capture rendered SVG images to create UIImage.

## Requirements
- iOS 14.0+
- Swift 5.0+

## Installation

SDImageSVGWKWebCoder can be installed through Swift Package Manager:

1. In Xcode, click File -> Swift Packages -> Add Package Dependency
2. Paste the following URL: https://github.com/rws08/SDImageSVGWKWebCoder.git
3. Follow the prompts to install the package.

## Usage

### SwiftUI

```swift
import SwiftUI
import SDWebImageSwiftUI
import SDImageSVGWKWebCoder

@main
struct ExampleApp: App {
    init() {
        SDImageCodersManager.shared.addCoder(SDImageSVGWKWebCoder.shared)
    }
    ...
}

import SDWebImage
import SDImageSVGWKWebCoder
import SwiftUI

struct ContentView: View {
    var body: some View {
        WebImage(url: URL(string: "https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/alphachannel.svg"))
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 200)
    }
}
```

## Acknowledgements

This library is inspired by the [SVGWebView](https://github.com/ZeeZide/SVGWebView) library.

## License

SDImageSVGWKWebCoder is released under the MIT license. See [LICENSE](https://github.com/rws08/SDImageSVGWKWebCoder/blob/main/LICENSE) for details.
