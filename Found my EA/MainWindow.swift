//
//  MainWindow.swift
//  Find my EA
//
//  Created by Jia Rui Shan on 12/5/16.
//  Copyright © 2016 Jerry Shan. All rights reserved.
//

import Cocoa

class MainWindow: NSWindowController, NSWindowDelegate {
    
    @IBOutlet weak var mainwindow: NSWindow!
    
    var resizeDelegate: WindowResizeDelegate?
    
    override func windowWillLoad() {
        mainwindow.delegate = self // The window is responsive to the delegate methods
        mainwindow.titlebarAppearsTransparent = true // The grey title bar is invisible
        mainwindow.styleMask.insert(.fullSizeContentView) // The view may occupy the title area
        mainwindow.backgroundColor = NSColor.white // The background color is set to white by default
        mainwindow.isMovableByWindowBackground = true // The user can drag the window from any point
        
        mainwindow.titleVisibility = .hidden // Used to activate the wide title bar

//        mainwindow.backgroundColor = NSColor(white:1, alpha:1)

    }
    
    override func windowDidLoad() {
        let vc = self.contentViewController! as! ViewController
        self.resizeDelegate = vc
    }
    
    func windowWillStartLiveResize(_ notification: Notification) {
        resizeDelegate?.windowWillResize(nil)
    }
    
    func windowDidEndLiveResize(_ notification: Notification) {
        resizeDelegate?.windowHasResized(nil)
    }
    
    func windowWillEnterFullScreen(_ notification: Notification) {
        //mainwindow.title = "Found my EA"
        mainwindow.titleVisibility = .visible
        mainwindow.toolbar?.isVisible = false
        resizeDelegate?.windowWillResize(nil)
    }
    
    func windowDidEnterFullScreen(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.resizeDelegate?.windowHasResized(nil)
        }
    }
    
    func windowWillExitFullScreen(_ notification: Notification) {
        resizeDelegate?.windowWillResize(nil)
    }

    func windowDidExitFullScreen(_ notification: Notification) {
        mainwindow.titleVisibility = .hidden
        mainwindow.toolbar?.isVisible = true
        resizeDelegate?.windowHasResized(nil)
    }
    
    func windowDidResize(_ notification: Notification) {
        mainViewController?.adjustImages()
    }

}

class SplitView: NSSplitView {
    override var mouseDownCanMoveWindow: Bool {
        return true
    }
}
