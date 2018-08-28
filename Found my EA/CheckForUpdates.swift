//
//  CheckForUpdates.swift
//  Found my EA
//
//  Created by Jia Rui Shan on 12/30/16.
//  Copyright © 2016 Jerry Shan. All rights reserved.
//

import Foundation
import Cocoa
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


var ischecking = false

func checkforUpdates(_ active: Bool) {
    if !logged_in {return}
    if ischecking {return}
    ischecking = true
    let url = URL(string: serverAddress + "tenicCore/CheckUpdate.php")!
    
    if active {
        mainViewController?.updateDownloadProgress.isHidden = false
        mainViewController?.updateDownloadProgress.isIndeterminate = true
        mainViewController?.updateDownloadProgress.startAnimation(nil)
        mainViewController?.updateProgressText.stringValue = "Checking..."
    }
    
    let alert = NSAlert()
    customizeAlert(alert)

    let task = URLSession.shared.dataTask(with: url) {
        data, response, error in
        if error != nil {
            print("error=\(error!)")
            if !active {return}
            DispatchQueue.main.async {
                alert.messageText = "Connection Error!"
                alert.informativeText = "We did not establish a connection to our server. Please try again later."
                alert.addButton(withTitle: "OK").keyEquivalent = "\r"
                alert.runModal()
                mainViewController?.updateDownloadProgress.isHidden = true
                mainViewController?.updateProgressText.stringValue = ""
            }
            return
        }
        ischecking = false
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSArray
            let currentVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
            var updateInfo = json[1] as! [String:String]
            
            DispatchQueue.main.async {
                mainViewController?.updateDownloadProgress.isHidden = true
                mainViewController?.updateProgressText.stringValue = ""
            }
            if Int(updateInfo["Version"]!) > Int(currentVersion) {
                DispatchQueue.main.async {
                    alert.messageText = "An Update is Available!"
                    alert.informativeText = updateInfo["Description"]!
                    alert.addButton(withTitle: "Update").keyEquivalent = "\r"
                    if updateInfo["Importance"]! == "0"{
                        alert.addButton(withTitle: "Not Now")
                    }
                    if alert.runModal() != NSAlertFirstButtonReturn {return}
                    mainViewController?.startUpdate()
                }
            } else if active {
                DispatchQueue.main.async {
                    alert.messageText = "No Updates Available"
                    alert.informativeText = "You are currently using the newest version of Found my EA."
                    alert.addButton(withTitle: "OK").keyEquivalent = "\r"
                    alert.runModal()
                }
            }
            
        } catch let err as NSError {
            DispatchQueue.main.async {
                alert.messageText = "Connection Error!"
                alert.informativeText = "We did not establish a connection to our server. Please try again later."
                alert.addButton(withTitle: "OK").keyEquivalent = "\r"
                alert.runModal()
                mainViewController?.updateDownloadProgress.isHidden = true
                mainViewController?.updateProgressText.stringValue = ""
            }
            print(err)
        }
        return
    }
    task.resume()
    
}
