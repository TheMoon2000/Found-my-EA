//
//  SignupButton.swift
//  Find my EA
//
//  Created by Jia Rui Shan on 1/23/17.
//  Copyright © 2017 Jerry Shan. All rights reserved.
//

import Cocoa

class SignupButton: NSButton {
    
    var mouseIsDown = false
    var mouseIsIn = false
    
    var clickable = true

    override func awakeFromNib() {
        self.alphaValue = 0.75
        self.addTrackingArea(NSTrackingArea(rect: self.bounds, options: NSTrackingAreaOptions(rawValue: 129), owner: self, userInfo: nil))
        if !UserDefaults.standard.bool(forKey: "Blue Theme") && title == "Sign up now!" {
            let redInput = CIVector(cgRect: NSMakeRect(1,1,0,0))
            let greenInput = CIVector(cgRect: NSMakeRect(0,1,0,0))
            let blueInput = CIVector(cgRect: NSMakeRect(0,1,0,0))
            let alphaInput = CIVector(cgRect: NSMakeRect(0,1,0,0))
            let filter = CIFilter(name: "CIColorPolynomial", withInputParameters: ["inputRedCoefficients": redInput, "inputGreenCoefficients": greenInput, "inputBlueCoefficients": blueInput, "inputAlphaCoefficients": alphaInput])
            self.wantsLayer = true
            self.layer?.filters?.removeAll()
            self.layer?.filters?.append(filter!)
        }
    }
    
    override func mouseEntered(with theEvent: NSEvent) {
        mouseIsIn = true
        if self.title == "Sign up now!" {
            self.alphaValue = 0.85
        }
    }
    
    override func mouseExited(with theEvent: NSEvent) {
        mouseIsIn = false
        if self.title == "Sign up now!" {
            self.alphaValue = 0.75
        }
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        if !clickable {return}
        self.alphaValue = 0.99
        mouseIsDown = true
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        if !clickable {return}
        self.alphaValue = 0.75
        mouseIsDown = false
        if !mouseIsIn {return}
        if self.title == "Sign up now!" {
            loginview.signup(self)
        } else if self.title == "Back to Login" {
            loginview.returnLogin(self)
        } else if self.title == "Previous" {
            loginview.returnSignup(self)
        } else if self.toolTip! == "Log out" {
            mainViewController?.logout(self)
        }
    }
}
