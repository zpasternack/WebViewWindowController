//
//  AboutBoxController.swift
//  WebViewWindowController
//
//  Created by Zacharias Pasternack on 9/02/18.
//  Copyright © 2019 Fat Apps, LLC. All rights reserved.
//

import Carbon
import Cocoa
import WebKit


class AboutBoxController: WebViewWindowController {

	@IBOutlet weak var versionField: NSTextField!
	
	convenience init() {
		self.init(windowNibName: "AboutBox")
	}
	
    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Movable by window background.
		window?.isMovableByWindowBackground = true
		
		// Setup version field.
		if let infoDictionary = Bundle.main.infoDictionary,
		   let buildString = infoDictionary["CFBundleVersion"],
		   let versionString = infoDictionary["CFBundleShortVersionString"]
		{
			versionField.stringValue = "v\(versionString) (\(buildString))"
		}
    }

	override func keyDown(with theEvent: NSEvent) {
		// Close via Escape key.
		let commandKeyDown = theEvent.modifierFlags.contains(NSEvent.ModifierFlags.command)
		if !commandKeyDown && theEvent.keyCode == UInt16(kVK_Escape) {
			window?.orderOut(self)
			return
		}

		interpretKeyEvents([theEvent])
	}
}
