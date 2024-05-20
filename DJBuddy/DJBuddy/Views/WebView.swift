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

    var webView = WKWebView()

    func makeCoordinator() -> Coordinator {
        Coordinator(self, didFinishLoading: didFinishLoading)
    }

    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1"
        webView.allowsLinkPreview = true

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            print("somethings up with server trust")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        let exceptions = SecTrustCopyExceptions(serverTrust)
        SecTrustSetExceptions(serverTrust, exceptions)
        print("challenge handled")
        completionHandler(.useCredential, URLCredential(trust: serverTrust));
    }

    func reload(){
        webView.reload()
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        let didFinishLoading: ((token: String?, email: String?)) -> Void

        init(_ parent: WebView, didFinishLoading: @escaping ((token: String?, email: String?)) -> Void) {
            self.parent = parent
            self.didFinishLoading = didFinishLoading
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("reload")
            self.parent.reload()
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Inject JavaScript to check for specific response in the content
            let script = """
                            (function() {
                                var content = document.body.innerText || document.body.textContent;
                                var resultType = "error";
                                var userToken = null;
                                var email = null;
                                try {
                                    var json = JSON.parse(content);
                                    if (json.result === "success") {
                                        resultType = "success";
                                        userToken = json.user_token;
                                        email = json.email;
                                    } else if (json.result === "failure") {
                                        resultType = "failure";
                                    }
                                } catch (error) {
                                    console.error("Error parsing JSON: " + error);
                                }
                                return [resultType, userToken, email];
                            })()
                            """

            webView.evaluateJavaScript(script) { [weak self] (result, error) in
                if let data = result as? [String] {
                    let resultType = data[0]
                    switch resultType {
                    case "success":
                        let userToken = data[1]
                        let email = data[2]
                        self?.didFinishLoading((userToken, email))
                    case "failure":
                        self?.didFinishLoading((nil, nil))
                    default:
                        break
                    }
                }
            }
        }
    }
}
