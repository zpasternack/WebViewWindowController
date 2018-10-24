//
//  WebViewWindowController.swift
//  WebViewWindowController
//
//  Created by Zacharias Pasternack on 1/23/17.
//  Copyright © 2017-2018 FatApps, LLC. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
// * Redistributions of source code must retain the above copyright
// notice, this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright
// notice, this list of conditions and the following disclaimer in the
// documentation and/or other materials provided with the distribution.
// * Neither the name Fat Apps, LLC nor the
// names of its contributors may be used to endorse or promote products
// derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import Cocoa
import WebKit

open class WebViewWindowController: NSWindowController {

	#if OPT_USE_WKWEBVIEW
	@IBOutlet weak var webView: WKWebView!
	#else
	@IBOutlet weak var webView: WebView!
	#endif /* OPT_USE_WKWEBVIEW */
	
	@IBInspectable var htmlFile: String!
	@IBInspectable var adaptsForDarkMode: Bool = true
	
	private var appearanceObserver: NSKeyValueObservation? = nil
	
    open override func windowDidLoad() {
        super.windowDidLoad()
		
		assert(webView != nil, "Forgot to set webView IBOutlet!")
		assert(htmlFile != nil, "Forgot to specify HTML file for web view!")
		assert(window != nil, "Forgot to set window IBOutlet!")
		guard htmlFile != nil, webView != nil, window != nil else { return }
		
		// Watch for appearance changes.
		if #available(OSX 10.14, *) {
			appearanceObserver = window!.observe(\.effectiveAppearance) {
				[weak self] (window, change) in
				self?.updateAppearance()
			}
		}

		// Set delegate for WebView (so we can catch links and do stuff).
		#if OPT_USE_WKWEBVIEW
		webView.navigationDelegate = self
		#else
		webView.policyDelegate = self
		webView.frameLoadDelegate = self
		#endif /* OPT_USE_WKWEBVIEW */
		
		// Load our HTML page.
		loadHtml()
    }
	
	open func modify(forAppearance appearance: NSAppearance) {
		// Only do anything for dark theme.
		var isDarkTheme = false
		if #available(OSX 10.14, *) {
			isDarkTheme = appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
		}
		guard isDarkTheme else { return }
		
		// Modify CSS for dark mode.
		let darkModeCSS = [
			"body { color : #fff }",
			"a { color: #419CFF }"
		]
		
		for aCSS in darkModeCSS {
			let js = "var style = document.createElement('style'); style.innerHTML = '\(aCSS)'; document.head.appendChild(style);"
			#if OPT_USE_WKWEBVIEW
			webView.evaluateJavaScript(js, completionHandler: nil)
			#else
			_ = webView.stringByEvaluatingJavaScript(from: js)
			#endif /* OPT_USE_WKWEBVIEW */
		}
	}
	
	private func loadHtml() {
		let fileURL = NSURL(fileURLWithPath: htmlFile)
		let fileName = fileURL.deletingPathExtension?.lastPathComponent
		let fileExtension = fileURL.pathExtension
		
		if let htmlPath = Bundle.main.path(forResource: fileName, ofType: fileExtension),
			let html = try? String(contentsOfFile: htmlPath, encoding: String.Encoding.utf8)
		{
			#if OPT_USE_WKWEBVIEW
			webView.loadHTMLString(html, baseURL: Bundle.main.bundleURL)
			#else
			webView.mainFrame.loadHTMLString(html, baseURL: Bundle.main.bundleURL)
			#endif /* OPT_USE_WKWEBVIEW */
		}
	}
	
	@available(OSX 10.14, *)
	private func updateAppearance() {
		// Reload HTML.
		loadHtml()
	}
}

#if !OPT_USE_WKWEBVIEW
extension WebViewWindowController: WebPolicyDelegate {

	public func webView(_ webView: WebView!,
						decidePolicyForNavigationAction actionInformation: [AnyHashable : Any]!,
						request: URLRequest!,
						frame: WebFrame!,
						decisionListener listener: WebPolicyDecisionListener!)
	{
		if let fileURL = request.url, !fileURL.isFileURL {
			// If it's not a file URL, let an external app handle it.
			NSWorkspace.shared.open(fileURL)
			listener.ignore()
			return
		}
		
		// Allow it.
		listener.use()
	}
}

extension WebViewWindowController: WebFrameLoadDelegate {
	open func webView(_ sender: WebView!, didFinishLoadFor frame: WebFrame!) {
		guard window != nil else { return }
		modify(forAppearance: window!.effectiveAppearance)
	}
}
#endif /* !OPT_USE_WKWEBVIEW */

#if OPT_USE_WKWEBVIEW
extension WebViewWindowController: WKNavigationDelegate {
	
	open func webView(_ webView: WKWebView,
					  decidePolicyFor navigationAction: WKNavigationAction,
					  decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
	{
		if let fileURL = navigationAction.request.url, !fileURL.isFileURL {
			// If it's not a file URL, let an external app handle it.
			NSWorkspace.shared.open(fileURL)
			decisionHandler(.cancel)
			return
		}
		
		// Allow it.
		decisionHandler(.allow)
	}
	
	open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		guard window != nil else { return }
		modify(forAppearance: window!.effectiveAppearance)
		}
}
#endif
