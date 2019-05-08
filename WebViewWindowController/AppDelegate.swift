//
//  AppDelegate.swift
//  WebViewWindowController
//
//  Created by Zacharias Pasternack on 9/2/18.
//  Copyright © 2019 Fat Apps, LLC. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var window: NSWindow!
	
	private lazy var aboutBox: NSWindowController? = {
		return AboutBoxController()
	}()

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		showAboutBox(nil)
	}

	@IBAction func showAboutBox(_ sender: Any?) {
		aboutBox?.window?.makeKeyAndOrderFront(nil)
	}
	
}

