//
//  AppDelegate.swift
//  Found my EA
//
//  Created by Jia Rui Shan on 12/5/16.
//  Copyright © 2016 Jerry Shan. All rights reserved.
//

import Cocoa

let serverAddress = "http://47.52.6.204/"
let schoolWifi = ["BCIS WIFI", "BCIS INF"]

var appadvisory = ""
var appfullname = ""
var appstudentID = ""
var isTeacher: Bool {
    if ["SSEA", "99999999"].contains(appstudentID) {return true}
    if appstudentID.characters.count < 8 {return false}
    
    if appstudentID.characters.count == 10 {return false}
    
    let year = String(Array(appstudentID.characters)[0...1])
    
    return year == "20"
}

var loginPass = ""
var logged_in = false {
    didSet {
        // These menu options are only available once the user logs in
        let menu = NSApplication.shared().mainMenu!.item(withTitle: "Found my EA")!
        menu.submenu?.item(withTitle: "Change Password")?.isEnabled = logged_in
        menu.submenu?.item(withTitle: "Open Messenger...")?.isEnabled = logged_in
        menu.submenu?.item(withTitle: "Log in...")?.isHidden = logged_in
        menu.submenu?.item(withTitle: "Log out...")?.isHidden = !logged_in
        menu.submenu?.item(withTitle: "Update Identity...")?.isEnabled = logged_in
    }
}

func regularizeID(_ id: String) -> String? {
    if ["99999999", "SSEA"].contains(id) {
        return id
    } else if ![10,8].contains(id.characters.count) || Int(id) == nil || !["0", "1"].contains(String(id.characters.last!)) && id.characters.count != 8 {
        return nil
    } else if id.characters.count == 8 && !id.hasPrefix("20") {
        return "20" + id
    } else {
        return id
    }
}

let AESKey = "Tenic" // The security key for the encrypted .tenic file

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    
    @IBOutlet weak var boldMenuItem: NSMenuItem!
    @IBOutlet weak var installUpdate: NSMenuItem!
    @IBOutlet weak var updateItem: NSMenuItem!
    @IBOutlet weak var muteItem: NSMenuItem!
    
    // This function is responsible for opening the menu.
    
    @IBAction func openHistory(_ sender: NSMenuItem) {
        let string:NSString = "~/Library/Application Support/Find my EA/.history"
        let command = Terminal(launchPath: "/bin/mkdir", arguments: ["-p", string.expandingTildeInPath])
        command.execUntilExit()
        command.launchPath = "/usr/bin/open"
        command.arguments = [messengerPath]
        command.exec()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    @IBAction func checkForUpdates(_ sender: NSMenuItem) {
        checkforUpdates(true)
    }
    
    @IBAction func logout(_ sender: NSMenuItem) {
        mainViewController?.logout(NSButton())
    }
    
    @IBAction func openGuide(_ sender: NSMenuItem) {
        NSWorkspace.shared().open(URL(string: "http://tenic.xyz/downloads/Found%20my%20EA%20User%20Manual.pdf")!)
    }
    
    @IBAction func visitFacebook(_ sender: NSMenuItem) {
        NSWorkspace.shared().open(URL(string: "https://www.facebook.com/teamtenic/")!)
    }
    
    @IBAction func visitWebsite(_ sender: NSMenuItem) {
        NSWorkspace.shared().open(URL(string: "http://tenic.xyz/")!)
    }
    
    @IBAction func installUpdate(_ sender: NSMenuItem) {
        let command = Terminal(launchPath: "/usr/bin/open", arguments: [NSTemporaryDirectory() + "Found my EA.pkg"])
        command.execUntilExit()
        NSApplication.shared().terminate(0)
        sender.isEnabled = false
    }
    
    @IBAction func toggleMuted(_ sender: NSMenuItem) {
        if sender.state == 0 {
            muted = true
            sender.state = 1
        } else {
            muted = false
            sender.state = 0
        }
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        muteItem.state = muted ? 1 : 0
    }
    
    var muted: Bool {
        get {
            let path: NSString = "~/Library/Application Support/Find my EA/.mute"
            let fm = FileManager()
            return fm.fileExists(atPath: path.expandingTildeInPath)
        }
        set (newValue) {
            let path: NSString = "~/Library/Application Support/Find my EA/.mute"
            if !newValue {
                Terminal().deleteFileWithPath(path.expandingTildeInPath)
            } else {
                Terminal(launchPath: "/bin/mkdir", arguments: ["-p", path.expandingTildeInPath]).exec()
            }
        }
    }
    
    func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
        if item?.title == "Install Update" {
            let attributes = [NSFontAttributeName: NSFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: NSColor(red: 1, green: 0.99, blue: 0.7, alpha: 1)]
            installUpdate.attributedTitle = NSAttributedString(string: installUpdate.title, attributes: attributes)
        } else {
            let attributes = [NSFontAttributeName: NSFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: NSColor(red: 1/255, green: 141/255, blue: 140/255, alpha:1)]
            installUpdate.attributedTitle = NSAttributedString(string: installUpdate.title, attributes: attributes)
        }
    }
}


// Universal global function used to broadcast message
func broadcastMessage(_ title: String, message: String, filter: String) {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.dateFormat = "y/MM/dd HH:mm:ss:SSS"
    let date = formatter.string(from: Date())
    var sent = false
    let url = URL(string: serverAddress + "tenicCore/SendMessage.php")
    var request = URLRequest(url: url!)
    request.httpMethod = "POST"
    let postString = "date=\(date)&message=\([filter, title.encodedString(), message.encodedString()].joined(separator: "\u{2028}"))"
    request.httpBody = postString.data(using: String.Encoding.utf8)
    let task = URLSession.shared.dataTask(with: request) {
        data, response, error in
        if sent {return}
        if error != nil {
            print("error=\(error!)")
        }
        sent = true
    }
    task.resume()
}

class DraggableImage: NSImageView {
    override var mouseDownCanMoveWindow: Bool {
        return true
    }
}
