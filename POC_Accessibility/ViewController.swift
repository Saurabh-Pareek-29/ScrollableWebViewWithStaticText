//
//  ViewController.swift
//  POC_Accessibility
//
//  Created by saurabh.pareek on 23/05/23.
//

import UIKit
import Foundation
import WebKit

class ViewController: UIViewController {
	
	@IBOutlet weak var lblBottom: UILabel!
	@IBOutlet weak var lblTop: UILabel!
	@IBOutlet weak var webVW: WKWebView!
	@IBOutlet weak var contentView: UIView!
	@IBOutlet weak var constraint_WebViewHeight: NSLayoutConstraint!
	let appleUrl = URL(string: "https://www.apple.com/ipad/")
	private var useCustomFont = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
	}
	
	func loadURL() {
		webVW.load(URLRequest(url: appleUrl!))
		webVW.allowsBackForwardNavigationGestures = true
		webVW.scrollView.isScrollEnabled = false
		webVW.scrollView.bounces = false
		webVW.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
	}
	
	//MARK: - custom method to setupView
	fileprivate func setupView() {
		webVW.navigationDelegate = self
		
		lblTop.isAccessibilityElement = true
		lblTop.accessibilityTraits = .staticText
		lblTop.font = .preferredFont(forTextStyle: .body)
		lblTop.adjustsFontForContentSizeCategory = true
		
		lblBottom.isAccessibilityElement = true
		lblBottom.accessibilityTraits = .staticText
		lblBottom.font = .preferredFont(forTextStyle: .body)
		lblBottom.adjustsFontForContentSizeCategory = true
		
		NotificationCenter.default.addObserver(self,selector: #selector(preferredContentSizeChanged(_:)),name: UIContentSizeCategory.didChangeNotification,object: nil)
		
		loadURL()
	}
	
	
	//MARK: - The above code is printing in debugger but size is not changing of webView content
	private func notifyFontSize(newSize:CGFloat) {
		let javascriptFunction = "fontSizeChanged(\(newSize))"
		webVW.evaluateJavaScript(javascriptFunction) { (result, error) in
			print("font size changed in webview")
		}
	}
	
	@objc private func preferredContentSizeChanged(_ notification: Notification) {
		if let userInfo = notification.userInfo,
		   let contentSize = userInfo["UIContentSizeCategoryNewValueKey"] {
			print("new category \(contentSize) type = \(type(of: contentSize))")
		}
		let font = UIFont.preferredFont(forTextStyle: .body)
		if useCustomFont {
			notifyFontSize(newSize: font.pointSize)
		}
		else {
			webVW.reload()
		}
		
	}
	
}

//MARK: - Extension of WKNavigationDelegate
extension ViewController: WKNavigationDelegate {
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			self.constraint_WebViewHeight.constant = self.webVW.scrollView.contentSize.height
		}
	}
}

