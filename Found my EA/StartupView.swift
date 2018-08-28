//
//  StartupView.swift
//  EA Registration
//
//  Created by Jia Rui Shan on 12/4/16.
//  Copyright © 2016 Jerry Shan. All rights reserved.
//

import Cocoa

let blueColor = NSColor(red: 38/255, green: 130/255, blue: 250/255, alpha: 0.1)
//let highlightColor = NSColor(red: 30/255, green: 120/255, blue: 248/255, alpha: 1)
//let mouseDownColor = NSColor(red: 25/255, green: 115/255, blue: 245/255, alpha: 1)
let highlightColor = NSColor(red: 38/255, green: 130/255, blue: 250/255, alpha: 0.18)
let mouseDownColor = NSColor(red: 38/255, green: 130/255, blue: 250/255, alpha: 0.14)


var isOutside = true

var startupView = StartupView()

class StartupView: NSView, NSTextFieldDelegate {

    @IBOutlet weak var beginButtonText: NSTextField!
    @IBOutlet weak var beginButton: NSButton!
    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var advisory: NSTextField!
    @IBOutlet weak var id: NSTextField!
    @IBOutlet weak var wechat: NSTextField!
    @IBOutlet weak var pickerView: IdentityPickerView!
    @IBOutlet weak var teacherInfoView: NSView!
    @IBOutlet weak var studentInfoView: NSView!
    @IBOutlet weak var teacherID: NSTextField!
    @IBOutlet weak var teacherEmail: NSTextField!
    @IBOutlet weak var teacherName: NSTextField!
    
    let d = NSUserDefaults.standardUserDefaults()
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
    }
    
    
    override func awakeFromNib() {
        startupView = self
        name.delegate = self
        advisory.delegate = self
        id.delegate = self
        
        beginButton.wantsLayer = true
        beginButton.layer?.backgroundColor = blueColor.CGColor
        
        beginButton.layer?.cornerRadius = 22
        beginButton.layer?.borderColor = NSColor.whiteColor().CGColor
        beginButton.layer?.borderWidth = 1
        
        let pstyle = NSMutableParagraphStyle()
        pstyle.alignment = .Center
        
//        let buttonFont = NSFont(name: "Helvetica Neue", size: 18)
        
//        beginButton.attributedTitle = NSAttributedString(string: "Let's Begin", attributes: [NSForegroundColorAttributeName: NSColor.whiteColor(), NSParagraphStyleAttributeName: pstyle, NSFontAttributeName: buttonFont!])
        let path: NSString = "~/Library/Application Support/Find my EA/.identity.tenic"
        let identity = NSKeyedUnarchiver.unarchiveObjectWithFile(path.stringByExpandingTildeInPath) as? [String:String] ?? [String:String]()
        
//        d.removeObjectForKey("Wechat")
        
        if let a = d.stringForKey("Advisory") {
            advisory.stringValue = a
        } else {
            advisory.stringValue = identity["Advisory"] ?? ""
        }
        
        if let n = d.stringForKey("Name") {
            name.stringValue = n
        } else {
            name.stringValue = identity["Name"] ?? ""
        }
        
        if let i = d.stringForKey("ID") {
            id.stringValue = i
        } else {
            id.stringValue = identity["ID"] ?? ""
        }
        
        if let w = d.stringForKey("Wechat") {
            wechat.stringValue = w
            if wechat.stringValue == "*_teacher_*" {
                teacherEmail.stringValue = advisory.stringValue
                teacherID.stringValue = id.stringValue
                teacherName.stringValue = name.stringValue
                pickerView.hidden = true
                teacherInfoView.hidden = false
            } else if identity["Wechat"] != nil {
                pickerView.hidden = true
                studentInfoView.hidden = false
            } else {
                beginButton.hidden = true
                beginButtonText.hidden = true
            }
        } else {
            wechat.stringValue = identity["Wechat"] ?? ""
            if wechat.stringValue == "*_teacher_*" {
                teacherEmail.stringValue = advisory.stringValue
                teacherID.stringValue = id.stringValue
                teacherName.stringValue = name.stringValue
                pickerView.hidden = true
                teacherInfoView.hidden = false
            } else if identity["Wechat"] != nil {
                pickerView.hidden = true
                studentInfoView.hidden = false
            } else {
                beginButton.hidden = true
                beginButtonText.hidden = true
            }
        }
        
        beginButton.addTrackingArea(NSTrackingArea(rect: beginButton.bounds, options: NSTrackingAreaOptions(rawValue: 129), owner: self, userInfo: nil))
        
        
        window?.standardWindowButton(.ZoomButton)?.hidden = true
        window?.standardWindowButton(.MiniaturizeButton)?.hidden = true
//        window?.standardWindowButton(.CloseButton)!.wantsLayer = true
        
//        let filter = CIFilter(name: "CIColorPolynomial", withInputParameters: [
//            "inputRedCoefficients": CIVector(CGRect: CGRectMake(0, 1, 0, 0)),
//            "inputGreenCoefficients": CIVector(CGRect: CGRectMake(0.4,1,0,0)),
//            "inputBlueCoefficients": CIVector(CGRect: CGRectMake(0.5,1,0,0)),
//            "inputAlphaCoefficients": CIVector(CGRect: CGRectMake(0.1,1,0,0))
//            ])
//        let filter = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius": 2])
//        window?.standardWindowButton(.CloseButton)?.layer?.filters?.append(filter!)
        
        
        let font = NSFont(name: "Helvetica Neue Light", size: 25)!
        let placeholderColor = NSColor(white: 0.9, alpha: 0.2)
        

        for i in [name, advisory, id, wechat, teacherName, teacherID, teacherEmail] {
            let attrStr = NSMutableAttributedString(string: i.placeholderString!)
            attrStr.addAttribute(NSForegroundColorAttributeName, value: placeholderColor, range: NSMakeRange(0, attrStr.length))
            attrStr.addAttribute(NSFontAttributeName, value: font, range: NSMakeRange(0, attrStr.length))
            
            i.placeholderAttributedString = attrStr
        }

    }
    
    override func controlTextDidChange(obj: NSNotification) {
        
//        a.setAttributedString(a as! NSAttributedString)
        
        switch obj.object! as! NSTextField {
        
        case name:
            name.wantsLayer = true
            name.layer?.borderWidth = 0
        case advisory:
            advisory.wantsLayer = true
            advisory.layer?.borderWidth = 0
        case id:
            id.wantsLayer = true
            id.layer?.borderWidth = 0
        case wechat:
            wechat.wantsLayer = true
            wechat.layer!.borderWidth = 0
        case teacherName:
            teacherName.wantsLayer = true
            teacherName.layer?.borderWidth = 0
        case teacherID:
            teacherID.wantsLayer = false
            teacherID.layer?.borderWidth = 0
        case teacherEmail:
            teacherEmail.wantsLayer = true
            teacherEmail.layer?.borderWidth = 0
        default:
            break
        }
    }
    
    override func mouseEntered(theEvent: NSEvent) {
        isOutside = false
        beginButton.layer?.backgroundColor = highlightColor.CGColor
    }
    
    override func mouseExited(theEvent: NSEvent) {
        isOutside = true
        beginButton.layer?.backgroundColor = blueColor.CGColor
    }
    
    @IBAction func begin(sender: NSButton) {
        var pass = true
        if name.stringValue == "" {
            name.wantsLayer = true
            name.layer?.borderWidth = 1
            name.layer?.borderColor = NSColor.redColor().CGColor
            pass = false
        }
        
        if advisory.stringValue == "" {
            advisory.wantsLayer = true
            advisory.layer?.borderWidth = 1
            advisory.layer?.borderColor = NSColor.redColor().CGColor
            pass = false
        }
        
        if id.stringValue.characters.count != 8 {
            id.wantsLayer = true
            id.layer?.borderWidth = 1
            id.layer?.borderColor = NSColor.redColor().CGColor
            pass = false
        }
        
        if wechat.stringValue == "*_teacher_*" {
            wechat.wantsLayer = true
            wechat.layer!.borderWidth = 1
            wechat.layer!.borderColor = NSColor.redColor().CGColor
        }
        
        if !teacherInfoView.hidden {
            pass = true
            if teacherName.stringValue == "" {
                teacherName.wantsLayer = true
                teacherName.layer?.borderWidth = 1
                teacherName.layer?.borderColor = NSColor.redColor().CGColor
                pass = false
            }
            if teacherID.stringValue.characters.count != 8 {
                teacherID.wantsLayer = true
                teacherID.layer?.borderWidth = 1
                teacherID.layer?.borderColor = NSColor.redColor().CGColor
                pass = false
            }
            if !teacherEmail.stringValue.containsString("@") {
                teacherEmail.wantsLayer = true
                teacherName.layer?.borderWidth = 1
                teacherName.layer?.borderColor = NSColor.redColor().CGColor
                pass = false
            }
        }
        
        if !pass {return}
        
        
        if !teacherInfoView.hidden {
            d.setValue(teacherName.stringValue, forKey: "Name")
            d.setValue(teacherEmail.stringValue, forKey: "Advisory")
            d.setValue(teacherID.stringValue, forKey: "ID")
            d.setValue("*_teacher_*", forKey: "Wechat")
            newUserRegistration(name.stringValue, advisory: advisory.stringValue, id: id.stringValue, wechat: wechat.stringValue)
        } else {
            d.setValue(name.stringValue, forKey: "Name")
            d.setValue(advisory.stringValue, forKey: "Advisory")
            d.setValue(id.stringValue, forKey: "ID")
            d.setValue(wechat.stringValue, forKey: "Wechat")
            newUserRegistration(teacherName.stringValue, advisory: teacherEmail.stringValue, id: teacherID.stringValue, wechat: "*_teacher_*")
        }
        mainViewController?.letsBegin(beginButton)
//
    }
    
}

func newUserRegistration(name: String, advisory: String, id: String, wechat: String) {
    let url = NSURL(string: serverAddress + "PHP/NewUser.php")!
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "POST"
    var hasRun = false
    let postString = "name=\(name)&advisory=\(advisory)&id=\(id)&wechat=\(wechat)"
    request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
        data, response, error in
        if hasRun {return}
        if error != nil {
            print("error=\(error)")
        }
        print(String(data: data!, encoding: NSUTF8StringEncoding)!)
        hasRun = true
    }
    task.resume()
}

class beginButton: NSButton {
    override func mouseDown(theEvent: NSEvent) {
        self.layer?.backgroundColor = mouseDownColor.CGColor
    }
    
    override func mouseUp(theEvent: NSEvent) {
        if !isOutside {
            self.layer?.backgroundColor = highlightColor.CGColor
            super.mouseDown(theEvent)
        }
    }
}

var identityView = IdentityPickerView()

class IdentityPickerView: NSView {
    @IBOutlet weak var studentButton: NSButton!
    @IBOutlet weak var teacherButton: NSButton!
    @IBOutlet weak var studentButtonLabel: NSTextField!
    @IBOutlet weak var teacherButtonLabel: NSTextField!
    
    override func awakeFromNib() {
        identityView = self
    }
    
}

class StudentIdentityButton: NSButton {
    
    var mouseIsDown = false
    var mouseIsIn = false
    
    override func awakeFromNib() {
        self.wantsLayer = true
        self.layer!.backgroundColor = neutral
        self.layer!.cornerRadius = 6
        self.addTrackingArea(NSTrackingArea(rect: self.bounds, options: NSTrackingAreaOptions(rawValue: 129), owner: self, userInfo: nil))

    }
    override func mouseEntered(theEvent: NSEvent) {
        mouseIsIn = true
        self.layer?.backgroundColor = highlightcolor
    }
    
    override func mouseExited(theEvent: NSEvent) {
        mouseIsIn = false
        if mouseIsDown {
            self.layer?.backgroundColor = highlightcolor
        } else {
            self.layer?.backgroundColor = neutral
        }
    }
    
    override func mouseDown(theEvent: NSEvent) {
        mouseIsDown = true
//        self.layer?.backgroundColor = clickedcolor
        self.alphaValue = 0.7
    }
    
    override func mouseUp(theEvent: NSEvent) {
        mouseIsDown = false
        self.alphaValue = 0.8
        if mouseIsIn {
            startupView.studentInfoView.hidden = false
            startupView.pickerView.hidden = true
            startupView.beginButton.hidden = false
            startupView.beginButtonText.hidden = false
        } else {
            self.layer?.backgroundColor = neutral
        }
    }

}

let neutral = NSColor(red: 0.98, green: 0.99, blue: 1, alpha: 0.00).CGColor
let highlightcolor = NSColor(red: 0.98, green: 0.99, blue: 1, alpha: 0.2).CGColor
let clickedcolor = NSColor(red: 0.98, green: 0.99, blue: 1, alpha: 0.15).CGColor

class TeacherIdentityButton: NSButton {
    

    var mouseIsDown = false
    var mouseIsIn = false
    
    override func awakeFromNib() {
        self.wantsLayer = true
        self.layer!.backgroundColor = neutral
        self.layer!.cornerRadius = 6
        self.addTrackingArea(NSTrackingArea(rect: self.bounds, options: NSTrackingAreaOptions(rawValue: 129), owner: self, userInfo: nil))
    }
    
    override func mouseEntered(theEvent: NSEvent) {
        mouseIsIn = true
        self.layer?.backgroundColor = highlightcolor
    }
    
    override func mouseExited(theEvent: NSEvent) {
        mouseIsIn = false
        if mouseIsDown {
            self.layer?.backgroundColor = highlightcolor
        } else {
            self.layer?.backgroundColor = neutral
        }
    }
    
    override func mouseDown(theEvent: NSEvent) {
        mouseIsDown = true
//        self.layer?.backgroundColor = clickedcolor
        self.alphaValue = 0.7
    }
    
    override func mouseUp(theEvent: NSEvent) {
        mouseIsDown = false
//        self.layer?.backgroundColor = highlightcolor
        self.alphaValue = 0.8
        if mouseIsIn {
            startupView.teacherInfoView.hidden = false
            startupView.pickerView.hidden = true
            startupView.beginButton.hidden = false
            startupView.beginButtonText.hidden = false
        } else {
            self.layer?.backgroundColor = neutral
        }
    }
}

