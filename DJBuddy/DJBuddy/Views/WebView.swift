//
//  WebView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 19/05/2024.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    let didFinishLoading: ((token: String?, email: String?)) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(didFinishLoading: didFinishLoading)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1"

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let didFinishLoading: ((token: String?, email: String?)) -> Void

        init(didFinishLoading: @escaping ((token: String?, email: String?)) -> Void) {
            self.didFinishLoading = didFinishLoading
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Inject JavaScript to check for specific response in the content
            let script = """
                            (function() {
                                var content = document.body.innerText || document.body.textContent;
                                var userToken = null;
                                var email = null;
                                try {
                                    var json = JSON.parse(content);
                                    if (json.result === "success") {
                                        userToken = json.user_token;
                                        email = json.email;
                                    }
                                } catch (error) {
                                    console.error("Error parsing JSON: " + error);
                                }
                                return [userToken, email];
                            })()
                            """

            webView.evaluateJavaScript(script) { [weak self] (result, error) in
                if let data = result as? [String] {
                    let userToken = data[0]
                    let email = data[1]
                    self?.didFinishLoading((userToken, email))
                } else {
//                    self?.didFinishLoading((nil, nil))
                }
            }
        }
    }
}
