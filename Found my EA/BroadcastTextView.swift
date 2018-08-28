//
//  BroadcastTextView.swift
//  Found my EA
//
//  Created by Jia Rui Shan on 12/27/16.
//  Copyright © 2016 Jerry Shan. All rights reserved.
//

import Cocoa

class BroadcastTextView: NSTextView {

    override func draw(_ rect: NSRect) {
        super.draw(rect)
        
        if (self.string! == "") {
            let placeHolderString: NSAttributedString = NSAttributedString(string: "Type your message here...", attributes: [NSForegroundColorAttributeName : NSColor(white: 0.7, alpha: 1), NSFontAttributeName: NSFont(name: "Source Sans Pro", size: 13.5)!])
            placeHolderString.draw(at: NSPoint(x: 5, y: -4))
        }
        let font = NSFont(name: "Source Sans Pro", size: 13.5)
        if self.font != font {
            self.font = font
        }
        let pstyle = NSMutableParagraphStyle.default().mutableCopy() as! NSMutableParagraphStyle
        pstyle.paragraphSpacing = 7
        pstyle.lineSpacing = 5
        self.textStorage?.addAttribute(NSParagraphStyleAttributeName, value: pstyle, range: NSMakeRange(0, self.textStorage!.length))
    }
    
    override func awakeFromNib() {
        self.insertionPointColor = NSColor(red: 0.1, green: 0.3, blue: 0.5, alpha: 1)
    }
    
    override func becomeFirstResponder() -> Bool {
        self.needsDisplay = true
        return super.becomeFirstResponder()
    }

}

class ProposalField: NSTextView {
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let font = NSFont(name: "Source Sans Pro", size: 13)
        self.font = font
        let pstyle = NSMutableParagraphStyle.default().mutableCopy() as! NSMutableParagraphStyle
        pstyle.paragraphSpacing = 7
        pstyle.lineSpacing = 5
        self.textStorage?.addAttribute(NSParagraphStyleAttributeName, value: pstyle, range: NSMakeRange(0, self.textStorage!.length))
        
        if (self.string! == "") {
            let placeHolderString: NSAttributedString = NSAttributedString(string: "Please write the proposal for your EA here. It should include:\n •  A detailed description of why you are running this EA\n •  Your main objective / What you aim to achieve.", attributes: [NSForegroundColorAttributeName : NSColor(white: 0.7, alpha: 1), NSFontAttributeName: NSFont(name: "Source Sans Pro", size: 13)!])
            placeHolderString.draw(at: NSPoint(x: 5, y: -4))
        } else {
            self.superview?.layer?.borderWidth = 0
        }
    }
    
    
    override func becomeFirstResponder() -> Bool {
        self.needsDisplay = true
        return super.becomeFirstResponder()
    }
    
}
