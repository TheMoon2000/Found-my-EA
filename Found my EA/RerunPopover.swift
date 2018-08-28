//
//  RerunPopover.swift
//  Found my EA
//
//  Created by Jia Rui Shan on 1/29/17.
//  Copyright © 2017 Jerry Shan. All rights reserved.
//

import Cocoa

class RerunPopover: NSViewController {
    
    var EA_Name = ""

    @IBOutlet weak var startDate: NSDatePicker!
    @IBOutlet weak var endDate: NSDatePicker!
    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet weak var rerunButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startDate.dateValue = Date()
        endDate.dateValue = Date().addingTimeInterval(30 * 86400)
    }
    
    @IBAction func rerun(_ sender: NSButton) {
        spinner.startAnimation(nil)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM. d, y"
        let start = formatter.string(from: startDate.dateValue)
        let end = formatter.string(from: endDate.dateValue)
        
        let url = URL(string: serverAddress + "tenicCore/EAUpdate.php")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        var hasRun = false
        let postString = "EA=\(mainViewController!.EA_Name.stringValue)&key=Start Date||End Date||Status&value=\(start + "||" + end + "||Pending")"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            if hasRun {return}
            if error != nil {
                print(error!)
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                print(json)
                DispatchQueue.main.async {
                    self.spinner.stopAnimation(nil)
                    mainViewController!.finishPickingDate(start, endDate: end)
                    self.dismissViewController(self)
                }
            } catch {
                print(String(data: data!, encoding: String.Encoding.utf8)!)
            }
            hasRun = true
        }
        
        task.resume()
        
    }
    
}
