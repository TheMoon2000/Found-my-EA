//
//  AttributeView.swift
//  EA Manager
//
//  Created by Jia Rui Shan on 3/28/17.
//  Copyright © 2017 Jerry Shan. All rights reserved.
//

import Cocoa

class AttributeView: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func listPanel(_ sender: NSButton) {
        mainViewController?.message.orderFrontListPanel(sender)
    }
    
    @IBAction func linkPanel(_ sender: NSButton) {
        mainViewController?.message.orderFrontLinkPanel(sender)
    }
    
    @IBAction func tablePanel(_ sender: NSButton) {
        mainViewController?.message.orderFrontTablePanel(sender)
    }
    
    @IBAction func spacingPanel(_ sender: NSButton) {
        mainViewController?.message.orderFrontSpacingPanel(sender)
    }
    
}
