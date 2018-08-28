//
//  PlaceholderTextView.swift
//  Find my EA Messenger
//
//  Created by Jia Rui Shan on 12/21/16.
//  Copyright © 2016 Jerry Shan. All rights reserved.
//

import Cocoa

class PlaceholderTextView: NSTextView {

    
    override func becomeFirstResponder() -> Bool {
        self.needsDisplay = true
        return super.becomeFirstResponder()
    }
    
    override func drawRect(rect: NSRect) {
        super.drawRect(rect)
        
        if (self.string! == "") {
            let placeHolderString: NSAttributedString = NSAttributedString(string: "Type your message here...", attributes: [NSForegroundColorAttributeName : NSColor(white: 0.8, alpha: 1), NSFontAttributeName: NSFont(name: "Source Sans Pro", size: 13.5)!])
            placeHolderString.drawAtPoint(NSPoint(x: 5, y: -4))
        }
    }
    
}
