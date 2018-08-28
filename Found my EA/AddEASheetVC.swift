//
//  AddEAViewController.swift
//  Found my EA
//
//  Created by Jia Rui Shan on 03/06/2017.
//  Copyright © 2017 Jerry Shan. All rights reserved.
//

import Cocoa

class AddEAViewController: NSViewController, NSTextFieldDelegate {

    @IBOutlet weak var addEASheet: NSView!
    @IBOutlet weak var addEASpinner: NSProgressIndicator!
    @IBOutlet weak var addEAName: NSTextField!
    @IBOutlet weak var addEAWarning: NSTextField!
    @IBOutlet weak var addEAButton: NSButton!
    @IBOutlet weak var addEACancelButton: NSButton!
    @IBOutlet weak var addEAStartDate: NSDatePicker!
    @IBOutlet weak var addEAEndDate: NSDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addEAStartDate.dateValue = Date()
        addEAEndDate.dateValue = Date()
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        addEAName.layer?.borderWidth = 0
        addEAWarning.stringValue = ""
    }
    
    @IBAction func addEA(_ sender: NSButton) {
        var pass = true
        if addEAName.stringValue == "" {
            addEAWarning.stringValue = "EA name cannot be blank"
            pass = false
        }
        
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789 _-")
        if addEAName.stringValue.rangeOfCharacter(from: characterset.inverted) != nil {
            pass = false
            addEAWarning.stringValue = "Invalid character(s)"
        }
        
        if ["EAs", "App", "Updates", "Users", "gpa"].contains(addEAName.stringValue) {
            pass = false
            addEAWarning.stringValue = "System reserved name"
        }
        
        if addEAStartDate.dateValue.timeIntervalSince(addEAEndDate.dateValue) > 0 {
            return
        }
        
        if !pass {
            addEAName.wantsLayer = true
            addEAName.layer?.borderWidth = 1
            addEAName.layer?.borderColor = NSColor.red.cgColor
            return
        }
        // Get the list of EAs from the server to ensure that the name is not occupied
        addEASpinner.startAnimation(nil)
        let url = URL(string: serverAddress + "tenicCore/service.php")
        sender.isEnabled = false
        let task = URLSession.shared.dataTask(with: url!) {
            data, response, error in
            if error != nil {
                print("error=\(error!)")
                sender.isEnabled = true
                self.addEAWarning.stringValue = "Connection error."
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSArray
                var EAs = [[String: String]]()
                
                for i in json {
                    EAs.append(i as! [String:String])
                }
                DispatchQueue.main.async {
                    for i in EAs {
                        if self.addEAName.stringValue == i["Name"]! {
                            self.addEAName.wantsLayer = true
                            self.addEAName.layer?.borderWidth = 1
                            self.addEAName.layer?.borderColor = NSColor.red.cgColor
                            self.addEAWarning.stringValue = "EA name exists."
                            pass = false
                            sender.isEnabled = true
                            break
                        }
                    }
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMM. d, y"
                    formatter.locale = Locale(identifier: "en_US")
                    if pass {
                        let sup = isTeacher ? appadvisory : ""
                        let newEA = EA(self.addEAName.stringValue, type: isTeacher, // Name of EA
                            description: "", // A short description (appears in Find my EA)
                            date: "Monday | 3:40 - 4:20", // Default time slot
                            leader: appfullname, // String of leader names
                            id: appstudentID, // ID of leaders
                            supervisor: sup, // Nameo of supervisor
                            location: "", // Location of EA
                            approval: "Incomplete", // Status of the EA. Not approved by default.
                            participants: "0", // Number of participants in total
                            approved: "0", // How many people were accepted
                            max: "", // A specification of the minimum and maximum grade levels
                            dates: "", // A list of dates (separated with " | ") on which the EA will run
                            startDate: formatter.string(from: self.addEAStartDate.dateValue), // When the EA starts
                            endDate: formatter.string(from: self.addEAEndDate.dateValue), // When the EA ends
                            proposal: "", // The student's 200-300 words EA proposal
                            prompt: "", // What users see when they are about to sign up
                            frequency: 4) // How many times does the EA run each week?
                        self.addEAToServer(newEA, spinner: self.addEASpinner)
                    } else {
                        self.addEASpinner.stopAnimation(nil)
                        sender.isEnabled = true
                    }
                }
                
            } catch let err as NSError {
                print(err)
            }
            return
        }
        task.resume()
    }
    
    func addEAToServer(_ theEA: EA, spinner: NSProgressIndicator) {
        let url = URL(string: serverAddress + "tenicCore/submitEA.php")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let type = isTeacher ? "Teacher" : "Student"
        let postString = "name=\(theEA.name)&leader=\(theEA.leader)&description=\(theEA.description)&id=\(theEA.id)&supervisor=\(theEA.supervisor)&date=\(theEA.time)&location=\(theEA.location)&status=Incomplete&type=\(type)&age= | &max=\(theEA.max)&dates=&start=\(theEA.startDate)&end=\(theEA.endDate)&proposal=\(theEA.proposal.encodedString())"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        addEACancelButton.isEnabled = false
        let uploadtask = URLSession.shared.dataTask(with: request) {
            data, response, error in
            spinner.stopAnimation(nil)
            DispatchQueue.main.async {
                self.dismiss(nil)
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                if json["status"] as? String == "success" {
                    print("success")
                    DispatchQueue.main.async {
                        mainViewController!.myEAs.append(theEA)
                        mainViewController!.zeroEA.isHidden = true
                    }
                }
            } catch {
                print("error=\(error)")
            }
            return
        }
        uploadtask.resume()
    }
    
}
