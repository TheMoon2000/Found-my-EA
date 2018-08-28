//
//  ViewController.swift
//  Found my EA
//
//  Created by Jia Rui Shan on 12/5/16.
//  Copyright © 2016 Jerry Shan. All rights reserved.
//

import Cocoa
import CoreWLAN
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

// Where the messenger is.
var messengerPath: String {
    let rawPath: NSString = "~/Library/Containers/com.tenic.EA-Center/"
    let absolutePath = rawPath.expandingTildeInPath
    let appPath = absolutePath + "/EA Center Messenger.app"
    
    return appPath
}

// Advisory / supervisor = email

let loading_delay = 1.0

var mainViewController: ViewController?

let animationPack = NSKeyedUnarchiver.unarchiveObject(withFile: Bundle.main.path(forResource: "Assets", ofType: "tenic")!) as! [String: Data]

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, NSTextViewDelegate, NSURLDownloadDelegate, NSMenuDelegate, WindowResizeDelegate, GRRequestsManagerDelegate, NSSplitViewDelegate {
    
    @IBOutlet weak var EATableView: NSTableView!
    @IBOutlet weak var mainView: NSView!
    @IBOutlet weak var effectsView: NSVisualEffectView!
    @IBOutlet weak var effectsView2: NSVisualEffectView!
    @IBOutlet weak var splitView: NSSplitView!
    @IBOutlet weak var splitviewLeft: NSView!
    @IBOutlet weak var splitviewRight: NSView!
    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var EA_Name: NSTextField!
    @IBOutlet weak var noEA_label: NSTextField!
    @IBOutlet weak var zeroEA: NSTextField!
    @IBOutlet weak var version: NSTextField!
    
    @IBOutlet weak var activeSwitch: NSSegmentedControl!
    @IBOutlet weak var activeSpinner: NSProgressIndicator!
    @IBOutlet weak var approveButton: NSButton!
    @IBOutlet weak var approvalSpinner: NSProgressIndicator!
    
    @IBOutlet weak var monday: NSButton!
    @IBOutlet weak var tuesday: NSButton!
    @IBOutlet weak var wednesday: NSButton!
    @IBOutlet weak var thursday: NSButton!
    @IBOutlet weak var friday: NSButton!
    @IBOutlet weak var time: NSPopUpButton!
    @IBOutlet weak var time_detail: NSTextField!
    @IBOutlet weak var dateSpinner: NSProgressIndicator!
    @IBOutlet weak var frequency: NSPopUpButton!
    @IBOutlet weak var frequencySpinner: NSProgressIndicator!
    @IBOutlet weak var location: NSTextField!
    @IBOutlet weak var locationSpinner: NSProgressIndicator!
    
    @IBOutlet weak var EA_Description: NSTextField!
    @IBOutlet weak var descriptionCount: NSTextField!
    @IBOutlet weak var descriptionSpinner: NSProgressIndicator!
    @IBOutlet weak var uploadDescriptionButton: NSButton!
    @IBOutlet var proposal: ProposalField!
    @IBOutlet weak var proposalScrollView: NSScrollView!
    @IBOutlet weak var proposalSpinner: NSProgressIndicator!
    @IBOutlet weak var proposalWordCount: NSTextField!
    @IBOutlet weak var updateProposalButton: NSButton!
    
    @IBOutlet weak var maxStudents: NSComboBox!
    @IBOutlet weak var maxStudentsSpinner: NSProgressIndicator!
    @IBOutlet weak var enableMaxStudents: NSButton!
    @IBOutlet weak var leaderIDs: NSTokenField!
    @IBOutlet weak var leaderIDSpinner: NSProgressIndicator!
    @IBOutlet weak var supervisorLabel: NSTextField!
    @IBOutlet weak var supervisor: NSTokenField!
    @IBOutlet weak var supervisorSpinner: NSProgressIndicator!
    @IBOutlet weak var participantTable: NSTableView!
//    @IBOutlet weak var participantSpinner: NSProgressIndicator!
    @IBOutlet var participantLoader: LoadImage!
    @IBOutlet weak var leaders: NSTokenField!
    @IBOutlet weak var leadersSpinner: NSProgressIndicator!
    
    @IBOutlet weak var promptSpinner: NSProgressIndicator!
    @IBOutlet weak var prompt: NSTextField!

    var boldMenuItem: NSMenuItem!
    @IBOutlet var message: NSTextView!
    @IBOutlet weak var fontStyle: NSSegmentedControl!
    @IBOutlet weak var alignmentSegment: NSSegmentedControl!
    @IBOutlet weak var colorWell: NSColorWell!
    @IBOutlet weak var attributeView: NSView!
    @IBOutlet weak var descriptionUpdateSpinner: NSProgressIndicator!
    @IBOutlet weak var revertSpinner: NSProgressIndicator!
    
    @IBOutlet weak var minGradeCheckbox: NSButton!
    @IBOutlet weak var maxGradeCheckbox: NSButton!
    @IBOutlet weak var minGrade: NSPopUpButton!
    @IBOutlet weak var maxGrade: NSPopUpButton!
    @IBOutlet weak var gradeSpinner: NSProgressIndicator!
    
    @IBOutlet weak var nextSessionDateTextfield: NSTextField!
    @IBOutlet weak var markAbsent: NSButton!
    @IBOutlet weak var markPresent: NSButton!
    
    var syncTextfields = [NSView]()
    
    var nextSessionDate: String { // The date displayed for a certain EA
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM. d, y"
            formatter.locale = Locale(identifier:"en_US")
            
            if nextSessionDateTextfield.stringValue != "Today" && nextSessionDateTextfield.stringValue != "" {
                return nextSessionDateTextfield.stringValue
            } else {
                return formatter.string(from: Date()) // This runs when the displayed date is "Today"
            }
        }
        set (newValue) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM. d, y"
            formatter.locale = Locale(identifier:"en_US")
            let todayDate = formatter.date(from: formatter.string(from: Date()))!
            if newValue == "Unavailable" {
                nextSessionDateTextfield.stringValue = "Unavailable" // Don't set a date then
            } else {
                let today = formatter.string(from: Date())
                // Decide whether the app should display "today" based on whether the date is today
                if newValue == today {
                    nextSessionDateTextfield.stringValue = "Today"
                } else {
                    nextSessionDateTextfield.stringValue = newValue
                }
            }
            
            // Some buttons should be disabled for an unavailable date schedule
            if newValue == "Unavailable" {
                markPresent.isEnabled = false
                markAbsent.isEnabled = false
                nextSessionDateTextfield.alphaValue = 1
            } else if let markDate = formatter.date(from: newValue) {
                markPresent.isEnabled = todayDate.timeIntervalSince(markDate) >= 0
                markAbsent.isEnabled = markPresent.isEnabled
//                nextSessionDateTextfield.alphaValue = todayDate.timeIntervalSinceDate(markDate) >= 0 ? 1 : 0.1
            }
        }
    }
    @IBOutlet weak var sessionDateSpinner: NSProgressIndicator!
    @IBOutlet weak var previousDate: NSButton!
    @IBOutlet weak var nextDate: NSButton!
    @IBOutlet weak var confirmDateButton: NSButton!
    
    @IBOutlet weak var loadImage: LoadImage!
    
    @IBOutlet weak var messageTitle: NSTextField!
    @IBOutlet var broadcastTextView: NSTextView!
    @IBOutlet weak var broadcastSpinner: NSProgressIndicator!
    @IBOutlet weak var sendButton: NSButton!
    
    
    var tmpTextfield = NSTextField()
    var beginString = String()
    
    var atrview: NSView? = nil
    
    var downloadQueue = [String: NSURLDownload]()
    
    var sheetWindow = NSWindow()
    
    var constraint = [NSLayoutConstraint]()
    
    var length = 0
    
    let requestManager = GRRequestsManager(hostname: "47.52.6.204:23333", user: "eamanager", password: "Tenic@EA")
    
    var tmpSelectedRow = -1
    
    var shouldUpdate = true
    
    var myEAs = [EA]() {

        didSet (oldValue) {
            if myEAs.count != 0 || !loadImage.isAnimating {
                loadImage.stopAnimation() // After the list of EAs are finalized, stop loading
            }
            let row = EATableView.selectedRow
            if myEAs.count > oldValue.count {
                print(oldValue.count)
                // If more rows have been added
                if oldValue.count == 0 {
                    EATableView.insertRows(at: IndexSet(integersIn: NSMakeRange(0, myEAs.count).toRange()!), withAnimation: .effectFade)
                } else {
                    EATableView.insertRows(at: IndexSet(integersIn: NSMakeRange(oldValue.count, 1).toRange() ?? 0..<0), withAnimation: .effectFade)

                }
            } else if myEAs.count < oldValue.count {
                if myEAs.count == 0 {
                    EATableView.removeRows(at: IndexSet(integersIn: NSMakeRange(0, EATableView.numberOfRows).toRange()!), withAnimation: .effectFade)
                } else {
                    EATableView.removeRows(at: IndexSet(integersIn: NSMakeRange(row, 1).toRange() ?? 0..<0), withAnimation: .slideUp)
                }
            } else if shouldUpdate {
                EATableView.reloadData(forRowIndexes: IndexSet(integer: row), columnIndexes: IndexSet(integer: 0))
                EATableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection:false)
            }
        }
    }
    
    var participants = [Participant]() {
        didSet {
            if !refreshParticipants {return}
            participantTable.reloadData()
            if participants.count != 0 || !participantLoader.isAnimating {
                participantLoader.stopAnimation() // Stop loading if the list of participants is fetched
            }
            
        }
    }
    
    var EA_Namelist = [String]()
    
    let d = UserDefaults.standard
    
    func transparency() {
        effectsView.isHidden = !effectsView.isHidden
        effectsView2.isHidden = !effectsView2.isHidden
        splitviewRight.menu!.item(at: 0)!.state = effectsView.isHidden ? 0 : 1
        EA_Name.updateLayer()
        d.set(!effectsView.isHidden, forKey: "Transparency")
    }
    
    var currentItem: NSObject?

    override func viewDidLoad() {
        
        shell("/bin/sh", arguments: ["-c", "open '\(messengerPath)'"]) // Launch the background messenger app
        
        super.viewDidLoad()
        
        mainViewController = self
        
        let ad = NSApplication.shared().delegate as! AppDelegate
        
        boldMenuItem = ad.boldMenuItem
        
        nextSessionDateTextfield.stringValue = ""
        
        version.stringValue = "Found my EA (\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String))"
    
        syncTextfields = [leaders, leaderIDs, location, EA_Description, supervisor, maxStudents, time_detail, prompt, proposalScrollView]
//        syncTextfields = [proposalScrollView]
        
        EA_Name.stringValue = ""
        
        if !isTeacher {
            markAbsent.isHidden = true
            markPresent.isHidden = true
        }
        
        proposalScrollView.wantsLayer = true

        let em = NSMenu()
        let item = em.addItem(withTitle: "Use Transparency", action: #selector(ViewController.transparency), keyEquivalent: "")
        if d.bool(forKey: "Transparency") {
            item.state = 1
            effectsView.isHidden = false
            effectsView2.isHidden = false
        } else {
            effectsView.isHidden = true
            effectsView2.isHidden = true
        }
        splitView.subviews[1].menu = em
        
        // Hooking the nib files with the table views
        
        let eaNib = NSNib(nibNamed: "EAView", bundle: Bundle.main)
        EATableView.register(eaNib!, forIdentifier: "EA View")
        
        let participantNib = NSNib(nibNamed: "ParticipantView", bundle: Bundle.main)
        participantTable.register(participantNib!, forIdentifier: "Participant Table")
        
        // Initializing the right-click menu for the EA attendance
        
        let menu = NSMenu()
        menu.delegate = self
        menu.autoenablesItems = false
        menu.addItem(withTitle: "EA Hasn't Run, Cannot Mark Attendance", action: nil, keyEquivalent: "").isEnabled = false
        participantTable.menu = menu
        
        splitviewLeft.wantsLayer = true
        splitviewLeft.layer?.backgroundColor = NSColor(red: 228/255, green: 242/255, blue: 255/255, alpha: 1).cgColor
        splitviewRight.wantsLayer = true
        splitviewRight.layer?.backgroundColor = NSColor(red: 245/255, green: 250/255, blue: 255/255, alpha: 1).cgColor
        
//        d.removeObjectForKey("Has Launched Before")

        tabView.selectTabViewItem(at: 0)
        
        loadImage.startAnimation("Cloud Sync")
        loadFromServer()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            checkforUpdates(false)
        }

    }
    
    override func viewDidAppear() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            self.view.window?.makeKeyAndOrderFront(nil)
        }
    }
    
    override func viewDidDisappear() {
        for i in myEAs {
            Terminal().deleteFileWithPath(NSTemporaryDirectory() + i.name + ".rtfd") // Clear all caches
        }
    }
    
    // Datasource method
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == EATableView {
            return myEAs.count
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "MMM. d, y"
            if nextSessionDate == "Unavailable" {
                return 0
            } else {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US")
                formatter.dateFormat = "MMM. d, y"
                return participantsAtGivenDate(participants, date: formatter.date(from: nextSessionDate)!).count
            }
        }
    }
    
    // Sometimes, when each participant has their own attendance record, it becomes difficult to know who was present on which session of the EA. In this case, here is a function that filters out a given list of participants according to a specified date
    
    func participantsAtGivenDate(_ participants: [Participant], date: Date) -> [Participant] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM. d, y"
        let tmp = participants.filter {participant -> Bool in
            if participant.startDate == "" {return false} // If there is no start date, there cannot be any participant who signed up
            
            // The following few lines of code create two arrays of Dates
            let startDates = participant.startDate.components(separatedBy: "|").map {
                return formatter.date(from: $0) ?? formatter.date(from: formatter.string(from: Date()))!
            } // Participants may have multiple start dates, if they once quit and rejoined an EA
            var endDates = participant.endDate.components(separatedBy: "|").map {
                return formatter.date(from: $0) ?? Date(timeIntervalSinceReferenceDate: 0)
            }
            if (endDates.count < startDates.count || endDates.first!.timeIntervalSinceReferenceDate == 0) && date.timeIntervalSince(startDates.last!) >= 0 {return true} // If the number of start dates for the EA is greater than the number of times it ended, it should be running
            if participant.approval == "Pending" {return date.timeIntervalSince(startDates.last!) >= 0} // If the EA is pending, we look at the date of the last time it has started running
            
            // Iterate through all the pairs of start and end dates. If the given date is located between a start-end pair, then it must be an active date
            for i in 0..<startDates.count {
                if startDates[i].timeIntervalSince(date) <= 0 && endDates[i].timeIntervalSince(date) > 0 {
                    return true
                }
            }
            return false
        }
        return tmp
    }
    
    var shouldUpdateParticipantsTable = false // Switch of whether the participants table view should be reloaded upon an update in the variable
    
    
    // Datasource method: Returns cell for every row
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM. d, y"
        
        let EAcell = EATableView.make(withIdentifier: "EA View", owner: self) as! EAView
        if tableView == EATableView {
            EAcell.EAName.stringValue = myEAs[row].name
            if myEAs[row].teacher {
                EAcell.supervisorLabel.stringValue = "Contact Email(s):"
            } else {
                EAcell.supervisorLabel.stringValue = "Supervisor:"
            }
            EAcell.supervisor.stringValue = myEAs[row].supervisor
            EAcell.date.stringValue = myEAs[row].time
            EAcell.location.stringValue = myEAs[row].location
            
            if myEAs[row].dates != "" {
                EAcell.numberOfParticipants.stringValue = "..."
                EAcell.participantsApproved.stringValue = "..."
                shouldUpdate = false
                let next = updateDatesForEA(myEAs[row])
                shouldUpdate = true
                updateParticipantsForEA(EAcell.EAName.stringValue, date: next, updateTable: shouldUpdateParticipantsTable)
            } else {
                EAcell.numberOfParticipants.stringValue = "0"
                EAcell.participantsApproved.stringValue = "0"
            }
            shouldUpdateParticipantsTable = false
            if myEAs[row].approval == "Approved" {
                EAcell.status = .active
            } else if myEAs[row].approval == "Pending" {
                EAcell.status = .pending
            } else if myEAs[row].approval == "Inactive" {
                EAcell.status = .inactive
            } else if myEAs[row].approval == "Unapproved" {
                EAcell.status = .unapproved
            } else {
                EAcell.status = .none
            }
            
            if myEAs[row].dates != "" {
                let lastDate = myEAs[row].dates.components(separatedBy: " | ").last!
                if formatter.date(from: lastDate)!.timeIntervalSince(formatter.date(from: formatter.string(from: Date()))!) < 0 {
                    EAcell.status = .finished
                }
            }
            EAcell.toolTip = "Start Date: \(myEAs[row].startDate)\n" +
                             "End Date: \(myEAs[row].endDate)"
            
            return EAcell
        } else if tableView == participantTable {
            
            let currentDate = formatter.date(from: nextSessionDate)!
            
            let tmp = participantsAtGivenDate(participants, date: currentDate)
            
            let cell = participantTable.make(withIdentifier: "Participant Table", owner: self) as! ParticipantView
            if EATableView.selectedRow == -1 {return nil}
            cell.EA_Name = (EATableView.view(atColumn: 0, row: EATableView.selectedRow, makeIfNecessary: false) as! EAView).EAName.stringValue
            cell.name.stringValue = tmp[row].name
            cell.advisory.stringValue = tmp[row].advisory
            cell.toolTip = "Student ID: \(tmp[row].id)"
            let msg = tmp[row].message == "N/A" ? "" : tmp[row].message
            cell.message.stringValue = msg == "" ? "The student was lazy and did not provide any supplementary information regarding himself/herself." : msg
            cell.approvalButton.isHidden = true
            cell.approveLabel.isHidden = false
            cell.approvalSpinner.stopAnimation(nil)
            
            let isFuture = currentDate.timeIntervalSince(Date()) > 0
            formatter.dateFormat = "y/M/d"
            let date = formatter.string(from: currentDate)
            
            if tmp[row].attendance.contains(date) {
                cell.attendance = .present
            } else if !isFuture {
                cell.attendance = .absent
            } else {
                cell.attendance = .none
            }
            
            if tmp[row].approval == "Pending" {
                cell.approvalButton.title = "Approve"
                cell.approveLabel.isHidden = true
                cell.approvalButton.isHidden = false
                cell.attendance = .unapproved
            }
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return tableView == EATableView ? 147 : 45
    }
    
    @discardableResult
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if tableView != EATableView {return false}
        let cell = EATableView.view(atColumn: 0, row: row, makeIfNecessary: false) as! EAView

        let theEA = myEAs.filter({(ea) -> Bool in
            return ea.name == cell.EAName.stringValue
        })[0]
        for i in syncTextfields {
            if i.layer != nil && i.layer?.borderWidth != 0 && row != lastSelectedRow {
                let alert = NSAlert()
                customizeAlert(alert)
                alert.messageText = "Unsaved change!"
                alert.informativeText = "One or more changes you've made to your EA have not been synced to the server, and they have been outlined in orange color. These changes will be discarded as soon as you switch your selection."
                alert.alertStyle = .critical
                alert.window.title = "Warning"
                alert.addButton(withTitle: "Go Back and Check").keyEquivalent = "\r"
                alert.addButton(withTitle: "Discard Changes")
                if alert.runModal() == NSAlertFirstButtonReturn {
                    EATableView.selectRowIndexes(IndexSet(integer: lastSelectedRow), byExtendingSelection: false)
                    tabView.isHidden = false
                    noEA_label.isHidden = true
                    EA_Name.stringValue = myEAs[lastSelectedRow].name
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        self.updateDatesForEA(theEA)
                        self.updateParticipantsForEA(theEA.name, date: nil, updateTable: true)
                    }
                    return false
                } else {
                    break
                }
            }
        }
        if row == lastSelectedRow && myEAs[row].id == leaderIDs.stringValue {
//            EATableView.selectRowIndexes(NSIndexSet(index: lastSelectedRow), byExtendingSelection: false)
//            tabView.hidden = false
//            noEA_label.hidden = true
//            EA_Name.stringValue = myEAs[lastSelectedRow].name
//            dispatch_after(dispatch_time(0, Int64(NSEC_PER_SEC/100)), dispatch_get_main_queue(), {
//                self.updateDatesForEA(theEA)
//                self.updateParticipantsForEA(theEA.name, date: nil, updateTable: true)
//            })
//            return false
            lastSelectedRow = -1
            self.tableView(EATableView, shouldSelectRow: row)
        }
        tabView.isHidden = false
        noEA_label.isHidden = true
        
        EA_Name.stringValue = theEA.name
        
        activeSwitch.isEnabled = true
        activeSwitch.toolTip = "Use this switch to enable / disable your EA for signup."
        approveButton.isEnabled = false
        
        if theEA.approval == "Approved" {
            activeSwitch.selectedSegment = 0
        } else if theEA.approval == "Inactive" {
            activeSwitch.selectedSegment = 1
        } else if theEA.approval == "Pending" {
            activeSwitch.isEnabled = false
            activeSwitch.toolTip = "Your EA is currently pending."
        } else if theEA.approval == "Incomplete" {
            activeSwitch.isEnabled = false
            activeSwitch.toolTip = "You can only enable / disable your EA signup after it is approved."
            approveButton.isEnabled = true
        } else if theEA.approval == "Unapproved" {
            activeSwitch.isEnabled = false
            activeSwitch.selectedSegment = -1
            approveButton.isEnabled = false
            activeSwitch.toolTip = "Your EA is not approved, so it cannot be turned active."
        }
        
        // Fetching the description of the EA
        EA_Description.stringValue = theEA.description.decodedString()
        controlTextDidChange(Notification(name: Notification.Name(rawValue: ""), object: EA_Description))
        
        // Fetching the location
        location.stringValue = theEA.location
        
        // Fetch the supplementary info
        prompt.stringValue = theEA.prompt
        
        // Fetch the frequency
        frequency.selectItem(withTag: theEA.frequency)
        
        // Next session date
        confirmDateButton.isEnabled = theEA.dates != "" || !["Unapproved", "Incomplete", "Pending"].contains(theEA.approval)
        
        // Fetching the date
        let dateDescription = theEA.time.components(separatedBy: " | ")
        let defaultTimes = time.menu!.items.map {(item) -> String in
            return item.title
        }
        if dateDescription.count > 1 && defaultTimes.contains(dateDescription[1]) {
            time.title = dateDescription[1]
            time_detail.isHidden = true
        } else {
            time.title = "Other Time(s)"
            time_detail.isHidden = false
            time_detail.stringValue = dateDescription[1]
        }
        monday.integerValue = dateDescription[0].contains("Mon") ? 1 : 0
        tuesday.integerValue = dateDescription[0].contains("Tue") ? 1 : 0
        wednesday.integerValue = dateDescription[0].contains("Wed") ? 1 : 0
        thursday.integerValue = dateDescription[0].contains("Thu") ? 1 : 0
        friday.integerValue = dateDescription[0].contains("Fri") ? 1 : 0
        frequency.isEnabled = dateDescription[0].components(separatedBy: ",").count == 1
        
        // Fetch leaders and supervisor
        
        supervisor.stringValue = theEA.supervisor
        supervisor.isEnabled = theEA.supervisor.caseInsensitiveCompare(appfullname) != .orderedSame
        leaders.stringValue = theEA.leader
        leaderIDs.stringValue = theEA.id
        leaders.placeholderString = appfullname
        if FileManager().fileExists(atPath: NSTemporaryDirectory() + theEA.name + ".rtfd") {
            message.readRTFD(fromFile: NSTemporaryDirectory() + theEA.name + ".rtfd")
            adjustImages()
        } else {
            updateDescription()
        }
        if theEA.teacher {
            supervisorLabel.stringValue = "Contact Email(s):"
            supervisor.placeholderString = "Contact emails..."
            supervisor.isEnabled = isTeacher
            supervisor.tokenStyle = .default
        } else {
            supervisorLabel.stringValue = "Supervisor:"
            supervisor.placeholderString = "Name of the supervisor..."
            supervisor.tokenStyle = .default
            
        }
        
        proposal.string = theEA.proposal
        self.textDidChange(Notification(name: Notification.Name(rawValue: ""), object: proposal))
        
        // Maximum Students
        if theEA.max != "" && Int(theEA.max) > 0 {
            maxStudents.stringValue = theEA.max
            enableMaxStudents.integerValue = 1
            maxStudents.isEnabled = true
        } else {
            maxStudents.isEnabled = false
            maxStudents.stringValue = "10"
            enableMaxStudents.integerValue = 0
        }
        
        //Finish button
        if cell.status == .finished {
            approveButton.title = "Run Again"
            approveButton.isEnabled = true
            approveButton.toolTip = "Your EA has already finished. By pressing \"Run Again\", you will select a start date and enddate to re-apply your EA."
        } else {
            approveButton.title = "Request Approval"
            approveButton.toolTip = "Press this button to let the EA coordinator review and approve your EA. This usually requires a face-to-face meeting."
        }
        
        // Minimum and Maximum Grade Limits
        
        minGrade.isEnabled = false
        maxGrade.isEnabled = false
        minGradeCheckbox.integerValue = 0
        maxGradeCheckbox.integerValue = 0
        
        if theEA.age.contains(" | ") {
            let bounds = theEA.age.components(separatedBy: " | ")
            if bounds[0] != "" {
                minGradeCheckbox.integerValue = 1
                minGrade.isEnabled = true
                minGrade.title = bounds[0]
            } else {
                minGradeCheckbox.integerValue = 0
                minGrade.isEnabled = false
                minGrade.title = "6"
            }
            if bounds[1] != "" {
                maxGradeCheckbox.integerValue = 1
                maxGrade.isEnabled = true
                maxGrade.title = bounds[1]
            } else {
                maxGradeCheckbox.integerValue = 0
                maxGrade.isEnabled = false
                maxGrade.title = "12"
            }
        } else {
            print(theEA.age)
        }
            
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.nextSessionDate = self.updateDatesForEA(theEA)
            self.updateParticipantsForEA(theEA.name, date: nil, updateTable: true)
            self.changeStatusForKey("Next", value: self.nextSessionDate, spinner: self.sessionDateSpinner, updateRow: true)
        }
        
        
        return true
    }
    
    func mailAll() {
        let emails = participants.map {participant -> String in
            return participant.id + "@mybcis.cn"
        }
        let title = messageTitle.stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let body = broadcastTextView.string!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: "mailto:" + emails.joined(separator: ",") + "?subject=" + title! + "&body=" + body!)!
        
        if NSEvent.modifierFlags().contains(.command) {
            do {
                try NSWorkspace.shared().open([url], withApplicationAt: URL(string: "file:///Applications/Microsoft%20Outlook.app") ?? URL(string: "file:///Applications/Mail.app")!, options: .default, configuration: [String:AnyObject]())
            } catch {
                
            }
        } else {
            NSWorkspace.shared().open(url)
        }
    }
    
    override func flagsChanged(with theEvent: NSEvent) {
        if NSEvent.modifierFlags().contains(.option) {
            if NSEvent.modifierFlags().contains(.command) {
                sendButton.title = "Outlook"
            } else {
                sendButton.title = "Email"
            }
            sendButton.toolTip = "Send an email to all your EA members!"
        } else {
            sendButton.title = "Send"
            sendButton.toolTip = "Broadcast your message to all EA members!"
        }
    }

    @discardableResult
    func updateDatesForEA(_ theEA: EA) -> String {
        
        if theEA.dates == "" || ["Unapproved", "Pending", "Incomplete"].contains(theEA.approval) {return "Unavailable"}
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM. d, y"
        formatter.locale = Locale(identifier: "en_US")
        let today = formatter.string(from: Date())
        
        // Attempts to return the first date that is later than the current date
        for i in theEA.dates.components(separatedBy: " | ") {
            if formatter.date(from: i)!.timeIntervalSince(formatter.date(from: today)!) >= 0 {
                return i
            }
        }
        // If this doesn't work, then apparently the last date is still older than the current date
        return theEA.dates.components(separatedBy: " | ").last!
        
    }
    
    func windowWillResize(_ sender: AnyObject?) {
        constraint = NSLayoutConstraint.constraints(withVisualFormat: "[firstview(\(splitviewLeft.frame.width))]", options: NSLayoutFormatOptions.alignmentMask, metrics: nil, views: ["firstview": splitviewLeft])
        splitviewLeft.addConstraints(constraint)
        
    }
    
    func windowHasResized(_ sender: AnyObject?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.splitviewLeft.removeConstraints(self.constraint)
        }
    }
    
    //////////
    
    
    //Fetching EAs from the server
    
    func loadFromServer() {
        
        
//        spinner.startAnimation(nil)
        loadImage.startAnimation("Cloud Sync")
        loadImage.clickCount += 1
        Thread.sleep(forTimeInterval: 0)
        zeroEA.isHidden = true
        noEA_label.isHidden = false
        EA_Name.stringValue = ""
        let url = URL(string: serverAddress + "tenicCore/service.php")
        var hasRun = false
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        let alert = NSAlert()
        customizeAlert(alert)
        
        let postString = "id=\(appstudentID)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            self.loadImage.clickCount = 0
            if error != nil || data == nil {
                DispatchQueue.main.async {
                    self.loadImage.stopAnimation()
                    if self.myEAs.count != 0 {return}
                    alert.messageText = "Let me get online!"
                    alert.informativeText = "Internet connection to me is like oxygen to you."
                    alert.addButton(withTitle: "OK").keyEquivalent = "\r"
                    alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
                }
                print("error=\(error!)")
                return
            }
            if self.myEAs.count != 0 {return}
            if hasRun {return}; hasRun = true
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSArray
                var EAs = [[String: String]]()
                
                for i in json {
                    EAs.append(i as! [String:String])
                }
                var tmp = [EA]()
                for i in EAs {
                    if i["ID"]!.contains(appstudentID) || i["Supervisor"]!.contains(appfullname) || i["Supervisor"]!.contains(appstudentID) {
                        var ea = EA(i["Name"]!, type: i["Type"]! == "Teacher", description: i["Description"]!, date: i["Date"]!, leader: i["Leader"]!, id: i["ID"]!, supervisor: i["Supervisor"]!, location: i["Location"]!, approval: i["Status"]!, participants: i["Participants"]!, approved: i["Approved"]!, max: i["Max"]!, dates: i["Dates"]!, startDate: i["Start Date"]!, endDate: i["End Date"]!, proposal: i["Proposal"]!.decodedString(), prompt: i["Prompt"]!.decodedString(), frequency: Int(i["Frequency"]!) ?? 4)
                        if ea.participants == "-1" {
                            ea.participants = "0"
                        }
                        if ea.approved == "-1" {
                            ea.approved = "0"
                        }
                        ea.age = i["Age"]!
                        if ea.approval != "Hidden" {
                            tmp.append(ea)
                        }
                    }
                }
                tmp = tmp.sorted{$0.name < $1.name}
                Thread.sleep(forTimeInterval: loading_delay)
                DispatchQueue.main.async {
                    self.shouldUpdateParticipantsTable = true
                    self.loadImage.stopAnimation()
                    self.myEAs = tmp
                    self.EATableView.reloadData()
                    self.zeroEA.isHidden = self.myEAs.count > 0
                }

            } catch let err as NSError {
                print(err)
                DispatchQueue.main.async {
                    self.loadImage.stopAnimation()
                    if self.myEAs.count != 0 {return}
                    if error == nil {
                        alert.messageText = "Connection to server failed."
                        alert.informativeText = "Our server is down for maintenance. We will be back very soon~~"
                    } else {
                        alert.messageText = "Let me get online!"
                        alert.informativeText = "Internet connection to me is like oxygen to you."
                    }
                    alert.addButton(withTitle: "OK").keyEquivalent = "\r"
                    alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
                }
            }
            
        }
        task.resume()
        
        
    }
    
    // Updating the table view for the EA participants
    
    func updateParticipantsForEA(_ EA_Name: String, date: String?, updateTable: Bool) {
        
        if EA_Name == self.EA_Name.stringValue && updateTable {
            participants = []
            participantLoader.startAnimation("Ring")
        }
//        let theEA = myEAs.filter({$0.name == EA_Name})[0]
        
        // Get the participants info of an EA
        let url = URL(string: serverAddress + "tenicCore/EAInfo.php")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        var hasRun = false
        let postString = "EA=\(EA_Name)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            if hasRun {return}
            
            if data == nil || error != nil {
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSArray

                var tmpParticipants = [Participant]()
                
                for i in json {
                    let dict = i as! [String:String]
//                    print(dict)
                    let p = Participant(name: dict["Name"]!, id: dict["ID"]!, advisory: dict["Advisory"]!, message: dict["Message"]!, approval: dict["Approval"]!, attendance: dict["Attendance"]!, startDate: dict["Start Date"]!, endDate: dict["End Date"]!)
                    if p.approval != "Inactive" {
                        tmpParticipants.append(p)
                    }
                }
                
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US")
                formatter.dateFormat = "MMM. d, y"
                
                let sessionDate = date != nil && date! != "" ? formatter.date(from: date!) : (self.nextSessionDate == "Unavailable" ? formatter.date(from: formatter.string(from: Date()))! : formatter.date(from: self.nextSessionDate)!)
                
                DispatchQueue.main.async {
                    if EA_Name == self.EA_Name.stringValue && updateTable {
                        self.participants = tmpParticipants
                        self.participantLoader.stopAnimation()
                    }
                    if tmpParticipants.count > 0 && sessionDate != nil {
                        tmpParticipants = self.participantsAtGivenDate(tmpParticipants, date: sessionDate!)
                    }
                    let approvedParticipants = tmpParticipants.filter({$0.approval == "Approved"}).count
                    
                    for i in 0..<self.EATableView.numberOfRows {
                        if let cell = self.EATableView.view(atColumn: 0, row: i, makeIfNecessary: false) as? EAView {
                            if cell.EAName.stringValue == EA_Name {
                                cell.numberOfParticipants.integerValue = tmpParticipants.count
                                cell.participantsApproved.integerValue = approvedParticipants
                            }
                        }
                    }
                }
            } catch {
                print("connection error")
                DispatchQueue.main.async {
                    self.participantLoader.stopAnimation()
                }
            }
            hasRun = true
        }
        
        task.resume()
    }
    
    // When the user presses the reload button
    
    @IBAction func reloadTables(_ sender: NSButton) {
//        for i in syncTextfields {
//            controlTextDidEndEditing(Notification(name: Notification.Name(rawValue: ""), object: i))
//            if i.layer != nil && i.layer?.borderWidth != 0 {
//                let alert = NSAlert()
//                customizeAlert(alert)
//                alert.messageText = "Unsaved change!"
//                alert.informativeText = "One or more changes you've made to your EA have not been synced to the server, and they have been outlined in orange color. These changes will be discarded as soon as you refresh."
//                alert.alertStyle = .critical
//                alert.window.title = "Warning"
//                alert.addButton(withTitle: "Go Back and Check").keyEquivalent = "\r"
//                alert.addButton(withTitle: "Discard Changes")
//                if alert.runModal() == NSAlertFirstButtonReturn {return} else {
//                    break
//                }
//            }
//        }
        if let textfield = currentItem as? NSTextField {
            controlTextDidEndEditing(Notification(name: Notification.Name(rawValue: ""), object: textfield, userInfo: nil))
        } else if currentItem as? NSTextView == proposal {
            self.updateProposal(updateProposalButton)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.loadFromServer()
            self.tabView.isHidden = true
            self.EA_Name.stringValue = ""
            self.EATableView.deselectAll(nil)
            self.tableViewSelectionIsChanging(Notification(name: Notification.Name(rawValue: ""), object: self.EATableView))
            if self.loadImage.clickCount != 0 {
                self.myEAs.removeAll()
            } else {
                self.loadImage.stopAnimation()
            }
        }
    }
    
    func tableViewSelectionIsChanging(_ notification: Notification) {
        if EATableView.selectedRow == -1 {
            tabView.isHidden = true
            EA_Name.stringValue = ""
            noEA_label.isHidden = false
        } else if EATableView.selectedRow != lastSelectedRow {
            noEA_label.isHidden = true
            for i in syncTextfields {
                i.layer?.borderWidth = 0
            }
        }
        
    }
    
    var lastSelectedRow = -1
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if EATableView.selectedRow != -1 {
            lastSelectedRow = EATableView.selectedRow
        }
    }

    @IBAction func changeActiveStatus(_ sender: NSSegmentedControl) {
        shouldUpdate = false
        if sender.selectedSegment == 0 {
            changeStatusForKey("Status", value: "Approved", spinner: activeSpinner, updateRow: true)
            for i in 0..<myEAs.count {
                if myEAs[i].name == EA_Name.stringValue {
                    myEAs[i].approval = "Approved"
                    break
                }
            }
        } else {
            changeStatusForKey("Status", value: "Inactive", spinner: activeSpinner, updateRow: true)
            for i in 0..<myEAs.count {
                if myEAs[i].name == EA_Name.stringValue {
                    myEAs[i].approval = "Inactive"
                    break
                }
            }
        }
        shouldUpdate = true
    }
    
    @IBAction func updateProposal(_ sender: NSButton) {
        shouldUpdate = false
        changeStatusForKey("Proposal", value: proposal.string!.encodedString(), spinner: proposalSpinner, updateRow: false)
        for i in 0..<myEAs.count {
            if myEAs[i].name == EA_Name.stringValue {
                myEAs[i].proposal = proposal.string!
            }
        }
        proposalScrollView.layer?.borderWidth = 0
        shouldUpdate = true
    }
    
    @IBAction func updatePrompt(_ sender: NSTextField) {
        shouldUpdate = false
        for i in 0..<myEAs.count {
            if myEAs[i].name == EA_Name.stringValue {
                myEAs[i].prompt = sender.stringValue
            }
        }
        changeStatusForKey("Prompt", value: sender.stringValue.encodedString(), spinner: promptSpinner, updateRow: false)
        sender.layer?.borderWidth = 0
        shouldUpdate = true
    }
    
    @IBAction func sendDescription(_ sender: NSButton) {
        
        if EA_Description.stringValue.encodedString().characters.count > 250 {
            return
        }
        shouldUpdate = false
        changeStatusForKey("Description", value: EA_Description.stringValue.encodedString(), spinner: descriptionSpinner, updateRow: false)
        for i in 0..<myEAs.count {
            if myEAs[i].name == EA_Name.stringValue {
                myEAs[i].description = EA_Description.stringValue.encodedString()
                break
            }
        }
        shouldUpdate = true
    }
    
    @IBAction func changeEADate(_ sender: Any) {
        
        
        // Determine what time slot string to display
        
        var dates = [String]()
        if monday.integerValue == 1 {dates.append("Mon")}
        if tuesday.integerValue == 1 {dates.append("Tue")}
        if wednesday.integerValue == 1 {dates.append("Wed")}
        if thursday.integerValue == 1 {dates.append("Thu")}
        if friday.integerValue == 1 {dates.append("Fri")}
        let backupDates = dates
        if dates.count == 0 {
            time.isEnabled = false
            return
        } else {
            time.isEnabled = true
            if dates.count == 1 {
                if monday.integerValue == 1 {dates = ["Monday"]}
                if tuesday.integerValue == 1 {dates = ["Tuesday"]}
                if wednesday.integerValue == 1 {dates = ["Wednesday"]}
                if thursday.integerValue == 1 {dates = ["Thursday"]}
                if friday.integerValue == 1 {dates = ["Friday"]}
            } else {
                frequency.selectItem(withTag: 4)
            }
        }
        
        frequency.isEnabled = dates.count == 1
        
        time_detail.layer?.borderWidth = 0
        
        let date = time_detail.isHidden ? time.title : time_detail.stringValue
        
        let theDate = dates.joined(separator: ", ") + " | " + date
        changeStatusForKey("Date", value: theDate, spinner: dateSpinner, updateRow: true)
        
        let generalFormatter = DateFormatter()
        generalFormatter.dateFormat = "MMM. d, y"
        generalFormatter.locale = Locale(identifier: "en_US")
        
        let weekFormatter = DateFormatter()
        weekFormatter.dateFormat = "E"
        
        for i in 0..<myEAs.count {
            if myEAs[i].name == EA_Name.stringValue {
                myEAs[i].time = theDate
                
                if myEAs[i].dates != "" && frequency.selectedTag() == 4, let button = sender as? NSButton, (sender as! NSButton).integerValue == 1 {
                    shouldUpdate = false
                    if let dayOfTheWeekIndex = [monday, tuesday, wednesday, thursday, friday].index(where: {$0 == button}) {
                        let dayOfTheWeek = ["Mon", "Tue", "Wed", "Thu", "Fri"][dayOfTheWeekIndex]
                        let start = generalFormatter.date(from: myEAs[i].startDate)!
                        var current = generalFormatter.date(from: generalFormatter.string(from: Date()))!.addingTimeInterval(86400)
                        if current.timeIntervalSince(start) < 0 {current = start}
                        let end = generalFormatter.date(from: myEAs[i].endDate)!
                        var dateList = myEAs[i].dates.components(separatedBy: " | ").map {generalFormatter.date(from: $0)!}
                        
                        while end.timeIntervalSince(current) > 0 {
                            if weekFormatter.string(from: current) == dayOfTheWeek {
                                dateList.append(current)
                                current.addTimeInterval(7 * 86400)
                            } else {
                                current.addTimeInterval(86400)
                            }
                        }
                        shouldUpdate = true
                        dateList.sort()
                        myEAs[i].dates = dateList.map({generalFormatter.string(from: $0)}).joined(separator: " | ")
                    }
                } else if myEAs[i].dates != "" && frequency.selectedTag() == 4, (sender as? NSButton)?.integerValue == 0 {
                   //problem with unavailable detection

                    var dateList = myEAs[i].dates.components(separatedBy: " | ").map {generalFormatter.date(from: $0)!}
                    
                    dateList = dateList.filter {backupDates.contains(weekFormatter.string(from: $0))}
                    myEAs[i].dates = dateList.map({generalFormatter.string(from: $0)}).joined(separator: " | ")
                }
            }
        }
    }
    
    @IBAction func toggleOtherTime(_ sender: NSPopUpButton) {
        if time.title == "Other Time(s)" {
            time_detail.isHidden = false
            return
        } else {
            time_detail.isHidden = true
        }        
        changeEADate(sender)
    }
    
    @IBAction func changeLocation(_ sender: NSTextField) {
        shouldUpdateParticipantsTable = false
        for i in 0..<myEAs.count {
            if myEAs[i].name == EA_Name.stringValue {
                myEAs[i].location = location.stringValue
                break
            }
        }
        shouldUpdateParticipantsTable = true
        changeStatusForKey("Location", value: location.stringValue, spinner: locationSpinner, updateRow: true)
        sender.layer?.borderWidth = 0
    }
    
    @IBAction func changeSupervisor(_ sender: NSTextField) {
        
        shouldUpdateParticipantsTable = false
        for i in 0..<myEAs.count {
            if myEAs[i].name == EA_Name.stringValue {
                myEAs[i].supervisor = supervisor.stringValue
            }
        }
        shouldUpdateParticipantsTable = true
        changeStatusForKey("Supervisor", value: supervisor.stringValue, spinner: supervisorSpinner, updateRow: true)
        sender.layer?.borderWidth = 0
    }
    
    @IBAction func requestApproval(_ sender: NSButton) {
        if sender.title == "Request Approval" {
            let alert = NSAlert()
            customizeAlert(alert)
            alert.messageText = "Are you sure?"
            alert.informativeText = "If you continue, your EA will become available for review by the EA coordinator. There is no undo."
            alert.window.title = "Request EA Approval"
            alert.addButton(withTitle: "Proceed").keyEquivalent = "\r"
            alert.addButton(withTitle: "Cancel")
            if alert.runModal() == NSAlertSecondButtonReturn {return}
            shouldUpdateParticipantsTable = false
            changeStatusForKey("Status", value: "Pending", spinner: approvalSpinner, updateRow: true)
            for i in 0..<myEAs.count {
                if myEAs[i].name == EA_Name.stringValue {
                    myEAs[i].approval = "Pending"
                }
            }
            shouldUpdateParticipantsTable = true
        } else {
//            let vc = NSViewController(nibName: "RerunPopover", bundle: NSBundle.mainBundle())
            let storyboard = NSStoryboard(name: "Main", bundle: Bundle.main)
            let vc = storyboard.instantiateController(withIdentifier: "RerunPopover")
            self.presentViewController(vc as! RerunPopover, asPopoverRelativeTo: sender.bounds, of: sender, preferredEdge: .maxY, behavior: .semitransient)
        }
    }
    
    func finishPickingDate(_ startDate: String, endDate: String) {
        approveButton.title = "Request Approval"
        approveButton.isEnabled = false
        approveButton.toolTip = "Press this button to let the EA coordinator review and approve your EA. This may require a face-to-face meeting."
        
        for i in 0..<myEAs.count {
            if myEAs[i].name == EA_Name.stringValue {
                shouldUpdate = false
                myEAs[i].startDate = startDate
                myEAs[i].endDate = endDate
                myEAs[i].approval = "Pending"
                myEAs[i].dates = ""
                participants.removeAll()
//                updateDatesForEA(myEAs[i])
                nextSessionDate = "Unavailable"
                shouldUpdate = true
//                updateParticipantsForEA(EA_Name.stringValue, date: nextSessionDate, updateTable: true)
                confirmDateButton.isEnabled = false
                changeStatusForKey("Next", value: nextSessionDate, spinner: sessionDateSpinner, updateRow: true)
                changeStatusForKey("Dates", value: "", spinner: sessionDateSpinner, updateRow: false)
                break
            }
        }
        activeSwitch.isEnabled = false
    }
    
    @IBAction func changeLeader(_ sender: NSTokenField) {
        print("change leader")
        if sender.stringValue == "" {return}
        let string = (sender.objectValue as! [String]).joined(separator: ", ")
        shouldUpdateParticipantsTable = false
        for i in 0..<myEAs.count {
            if myEAs[i].name == EA_Name.stringValue {
                myEAs[i].leader = string
                break
            }
        }
        shouldUpdateParticipantsTable = true
        changeStatusForKey("Leader", value: string, spinner: leadersSpinner, updateRow: true)
        sender.layer?.borderWidth = 0
    }
    
    @IBAction func updateLeaderIDs(_ sender: NSTokenField) {
        let string = (sender.objectValue as! [String]).joined(separator: ", ")
        if !string.contains(appstudentID) && !supervisor.isEnabled {
            let alert = NSAlert()
            customizeAlert(alert)
            alert.messageText = "Change EA Ownership?!"
            alert.informativeText = "You are currently changing the owner(s) and you are not one of them. As soon as you make this change and log out, you will no longer be able to view and manage this EA in \"Found my EA\"."
            alert.alertStyle = .critical
            alert.window.title = "Ownership Removal Warning"
            alert.addButton(withTitle: "I Understand").keyEquivalent = "\r"
            alert.addButton(withTitle: "Cancel")
            let theEA = myEAs.filter({$0.name == EA_Name.stringValue})[0]
            if alert.runModal() == NSAlertSecondButtonReturn {
                sender.stringValue = theEA.id
                sender.layer?.borderWidth = 0
                return}
        }
        
        sender.objectValue = (sender.objectValue as! [String]).map({regularizeID($0) ?? $0})
        
        shouldUpdate = false
        changeStatusForKey("ID", value: string, spinner: leaderIDSpinner, updateRow: false)
        for i in 0..<myEAs.count {
            if myEAs[i].name == EA_Name.stringValue {
                myEAs[i].id = string
                break
            }
        }
        shouldUpdate = true
        sender.layer?.borderWidth = 0
    }
    
    func changeStatusForKey(_ key: String, value: String, spinner: NSProgressIndicator?, updateRow: Bool) {
        
        let row = EATableView.selectedRow
        if row == -1 && EA_Name.stringValue == "" {print("row is -1 error"); return}
        spinner?.startAnimation(nil)
        let url = URL(string: serverAddress + "tenicCore/EAUpdate.php")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        var hasRun = false
        let postString = "EA=\(EA_Name.stringValue)&key=\(key)&value=\(value)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let alert = NSAlert()
        customizeAlert(alert)
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            if hasRun {return}
            
            if (data == nil || error != nil) {
                if key != "Next" {
                    DispatchQueue.main.async {
                        spinner?.stopAnimation(nil)
                        alert.messageText = "Let me get online!"
                        alert.informativeText = "If you do not connect to the Internet, I cannot save your changes."
                        alert.addButton(withTitle: "OK").keyEquivalent = "\r"
                        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
                    }
                }
                return
            }
            do {
                _ = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                DispatchQueue.main.async {
                    spinner?.stopAnimation(nil)
                    if row != -1 && updateRow {
                        self.updateValuesForRow(row)
                    }
                    if spinner == self.approvalSpinner {
                        self.approveButton.isEnabled = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    spinner?.stopAnimation(nil)
                    alert.messageText = "Let me get online!"
                    alert.informativeText = "If you do not connect to the Internet, I cannot save your changes."
                    alert.addButton(withTitle: "OK").keyEquivalent = "\r"
                    alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
                }
            }
            hasRun = true
            return
        }
        
        task.resume()
        
    }
    
    func tableView(_ tableView: NSTableView, shouldTypeSelectFor event: NSEvent, withCurrentSearch searchString: String?) -> Bool {
        return false
    }
    
    func updateValuesForRow(_ row: Int) {
        
        let cell = EATableView.view(atColumn: 0, row: row, makeIfNecessary: false) as! EAView
        let theEA = myEAs.filter({(ea) -> Bool in
            return ea.name == cell.EAName.stringValue
        })[0]
        
        switch theEA.approval {
        case "Approved":
            cell.status = .active
        case "Pending":
            cell.status = .pending
        case "Inactive":
            cell.status = .inactive
        case "Unapproved":
            cell.status = .unapproved
        default:
            cell.status = .none
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM. d, y"
        if myEAs[row].dates != "" {
            let lastDate = myEAs[row].dates.components(separatedBy: " | ").last!
            if formatter.date(from: lastDate)!.timeIntervalSince(formatter.date(from: formatter.string(from: Date()))!) < 0 {
                cell.status = .finished
            }
        }
        
        cell.date.stringValue = theEA.time
        cell.location.stringValue = theEA.location
        cell.supervisor.stringValue = theEA.supervisor
    }
    
    
    //////////////
    
    func participantsUpdate(_ EA_Name: String, pID: String) {
        for i in 0..<myEAs.count {
            let cell = EATableView.view(atColumn: 0, row: i, makeIfNecessary: false) as! EAView
            if cell.EAName.stringValue == EA_Name && cell.numberOfParticipants.integerValue > cell.participantsApproved.integerValue {
//                myEAs[i].approved = String(Int(myEAs[i].approved)! + 1)
                cell.participantsApproved.integerValue += 1
            }
        }
        for i in 0..<participants.count {
            if participants[i].id == pID {
                participants[i].approval = "Approved"
            }
        }
    }

    func adjustImages() {
        if #available(OSX 10.11, *) {
            if message.attributedString().containsAttachments {
                var content = message.getParts()
                let images = message.getAlignImages()
                let attributedImages = message.getAttributedAlignImages()
                
                var indexOfAlignImages = [Int]()
                
                for i in 0..<content.count {
                    if content[i].containsAttachments {
                        indexOfAlignImages.append(i)
                    }
                }
                
                
                let newImages = images.map {image -> NSImage in
                    let scaleFactor = (message.frame.width - 10) / image.size.width
                    image.size.width *= scaleFactor
                    image.size.height *= scaleFactor
                    if image.size.width >= image.resolution.width ||
                        image.size.height >= image.resolution.height {
                        image.size = image.resolution
                    }
                    return image
                }
                
                
                let newAttrStr = NSMutableAttributedString()
                
                var newImageCount = 0
                
                for i in 0..<content.count {
                    if !indexOfAlignImages.contains(i) {
                        newAttrStr.append(content[i])
                    } else {
                        let tmp = NSMutableAttributedString(attributedString: attributedImages[newImageCount])
                        var oldattr = attributedImages[newImageCount].attributes(at: 0, effectiveRange: nil)
                        let attachment = oldattr["NSAttachment"] as! NSTextAttachment
                        attachment.attachmentCell = NSTextAttachmentCell(imageCell: newImages[newImageCount])
                        oldattr["NSAttachment"] = attachment
                        tmp.addAttributes(oldattr, range: NSMakeRange(0, tmp.length))
                        newAttrStr.append(tmp)
                        newImageCount += 1
                    }
                }
                message.textStorage?.setAttributedString(newAttrStr)
            }
        }
    }
    
    func splitViewDidResizeSubviews(_ notification: Notification) {
        adjustImages()
    }
    
    //////////////
    
    override func controlTextDidChange(_ obj: Notification) {
        let textfield = obj.object as! NSTextField
        textfield.wantsLayer = true
        if textfield == EA_Description {
            descriptionCount.stringValue = wordCountFormatter(EA_Description.stringValue.encodedString().characters.count, max: 250)
            uploadDescriptionButton.isEnabled = EA_Description.stringValue.encodedString().characters.count <= 250
        } else if textfield == messageTitle {
            textfield.layer?.borderWidth = 0
        }
        textfield.layer?.borderWidth = 0
        currentItem = textfield
    }
    
    func textDidChange(_ notification: Notification) {
        if notification.object as! NSTextView == proposal {
            proposal.superview!.layer?.borderWidth = 0
            let words = proposal.string!.components(separatedBy: CharacterSet.punctuationCharacters.union(CharacterSet.whitespacesAndNewlines)).filter({$0 != ""})
            if words.count > 0 {
                proposalWordCount.stringValue = "\(words.count) out of 300 words"
            } else {
                proposalWordCount.stringValue = "300 words maximum"
            }
            updateProposalButton.isEnabled = words.count <= 300
            proposalWordCount.textColor = words.count > 300 ? NSColor.red : NSColor.black
            if proposal.string! == myEAs.filter({$0.name == EA_Name.stringValue})[0].proposal {
                proposalScrollView.layer?.borderWidth = 0
            }
            currentItem = proposal
        } else if notification.object as! NSTextView == message {
//            adjustImages()
        }
    }
    
    func textDidEndEditing(_ notification: Notification) {
        if notification.object as! NSTextView == proposal {
            let theEA = myEAs[EATableView.selectedRow]
            if proposal.string! != theEA.proposal {
                proposalScrollView.wantsLayer = true
                proposalScrollView.layer?.borderColor = NSColor.orange.cgColor
                proposalScrollView.layer?.borderWidth = 1
            }
            currentItem = proposal
        }
    }
    
        
    override func controlTextDidEndEditing(_ obj: Notification) {
        if EA_Name.stringValue == "" {return}
        let textfield_ = obj.object as? NSTextField
        var textfield = NSTextField()
        if textfield_ == nil {return} else {
            textfield = textfield_!
        }
        let theEA = myEAs.filter({ea -> Bool in
            return ea.name == EA_Name.stringValue})[0]
        switch textfield {
        case EA_Description:
            if theEA.description.decodedString() != textfield.stringValue {sendDescription(uploadDescriptionButton)}
        case location:
            if theEA.location != textfield.stringValue {changeLocation(location)}
        case supervisor:
            if theEA.supervisor != textfield.stringValue {changeSupervisor(supervisor)}
        case leaderIDs:
            if theEA.id != textfield.stringValue {updateLeaderIDs(leaderIDs); print(textfield.stringValue)}
        case leaders:
            if theEA.leader != textfield.stringValue {changeLeader(leaders)}
        case maxStudents:
            if theEA.max != textfield.stringValue && textfield.isEnabled || Int(textfield.stringValue) == nil {changeMaxStudents(maxStudents)}
        case time_detail:
            if theEA.time.components(separatedBy: " | ")[1] != textfield.stringValue && !textfield.isHidden {changeEADate(time_detail)}
        case prompt:
            if theEA.prompt != textfield.stringValue {updatePrompt(prompt)}
        default:
            print(textfield.stringValue)
        }
//        if change {
//            textfield.layer?.borderColor = NSColor.orangeColor().CGColor
//            textfield.layer?.borderWidth = 1
//        } else {
//            textfield.layer?.borderWidth = 0
//        }
    }
    
    /////////////
    
    func wordCountFormatter(_ length: Int, max: Int) -> String {
        if length == 0 {
            return "\(max) characters max"
        } else {
            return "\(length)/\(max) characters"
        }
    }

    @IBAction func maxStudents(_ sender: NSButton) {
        maxStudents.isEnabled = sender.objectValue as! Bool
        maxStudents.layer?.borderWidth = 0
        if enableMaxStudents.integerValue == 1 {
            changeMaxStudents(maxStudents)
            controlTextDidEndEditing(Notification(name: Notification.Name(rawValue: ""), object: maxStudents))
        } else {
            shouldUpdate = false
            changeStatusForKey("Max", value: "", spinner: maxStudentsSpinner, updateRow: false)
            maxStudents.layer?.borderWidth = 0
            for i in 0..<myEAs.count {
                if myEAs[i].name == EA_Name.stringValue {
                    myEAs[i].max = ""
                    break
                }
            }
            shouldUpdate = true
        }
    }
    
    @IBAction func changeMaxStudents(_ sender: NSComboBox) {
        if Int(sender.stringValue) == nil || sender.integerValue <= 0 || sender.integerValue > 999 {return}
        sender.layer?.borderWidth = 0
        shouldUpdate = false
        for i in 0..<myEAs.count {
            if myEAs[i].name == EA_Name.stringValue {
                myEAs[i].max = sender.stringValue
            }
        }
        shouldUpdate = true
        changeStatusForKey("Max", value: sender.stringValue, spinner: maxStudentsSpinner, updateRow: false)
        sender.layer?.borderWidth = 0
    }
    
    @IBAction func changeAlignment(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            message.alignLeft(sender)
        case 1:
            message.alignCenter(sender)
        case 2:
            message.alignRight(sender)
        case 3:
            message.alignJustified(sender)
        default:
            break
        }
    }
    
    @IBAction func addEA(_ sender: NSButton) {
        self.performSegue(withIdentifier: "Add EA", sender: sender)
    }
    
    @IBAction func fontStyle(_ sender: NSSegmentedControl) {
        boldMenuItem.menu?.update()
        if sender.selectedSegment == 3 {
            NSFontManager.shared().orderFrontFontPanel(sender)
            sender.setSelected(false, forSegment: 3)
        } else if sender.selectedSegment == 0 {
            boldMenuItem.menu?.update()
            boldMenuItem.menu?.performActionForItem(at: 1)
        } else if sender.selectedSegment == 1 {
            boldMenuItem.menu?.performActionForItem(at: 2)
        } else {
            //            boldMenuItem.menu?.performActionForItemAtIndex(3)
            message.underline(sender)
        }
    }
    
    func textViewDidChangeSelection(_ notification: Notification) {
        let fm = NSFontManager.shared()
        if let s = fm.selectedFont {
            fontStyle.setSelected(fm.weight(of: s) >= 8, forSegment: 0)
        }
        if let i = fm.selectedFont?.italicAngle {
            fontStyle.setSelected(i != 0, forSegment: 1)
        }
        boldMenuItem.menu?.update()
        fontStyle.setSelected(boldMenuItem.menu?.item(at: 3)?.state == 1, forSegment: 2)
        
        var range = message.selectedRange()
        if range.length == 0 && message.textStorage!.length != 0 {
            if range.location != 0 {
                range.location -= 1
            }
            range.length += 1
        }
//        else if message.textStorage?.length == 0 {
//            colorWell.color = NSColor.black
//        }
        if message.textStorage?.length == 0 {return}
        
        let attrStr = message.attributedString().attributedSubstring(from: range)
        if let color = attrStr.attributes(at: 0, longestEffectiveRange: nil, in: NSMakeRange(0, attrStr.length))[NSForegroundColorAttributeName] as? NSColor {
            colorWell.color = color
        } else {
            colorWell.color = NSColor.black
        }
        
        if let alignment = message.attributedString().attributedSubstring(from: range).attributes(at: 0, longestEffectiveRange: nil, in: NSMakeRange(0, message.attributedString().length))[NSParagraphStyleAttributeName] as? NSParagraphStyle {
            switch (alignment.alignment) {
            case .left:
                alignmentSegment.selectedSegment = 0
            case .right:
                alignmentSegment.selectedSegment = 2
            case .center:
                alignmentSegment.selectedSegment = 1
            case .justified:
                alignmentSegment.selectedSegment = 3
            default:
                alignmentSegment.selectedSegment = 0
            }
        
        }
    }
    
    
    func textViewDidChangeTypingAttributes(_ notification: Notification) {
        textViewDidChangeSelection(notification)
    }
    
    @IBAction func moreAttributes(_ sender: NSButton) {
        let viewController = NSViewController()
        if atrview != nil {
            viewController.view = atrview!
        } else {
            viewController.view = self.attributeView
            atrview = attributeView
        }
        viewController.view.frame.size = CGSize(width: 186, height: 186)
        let popover = NSPopover()
        popover.behavior = .transient
        popover.contentViewController = viewController
        popover.show(relativeTo: viewController.view.bounds, of: sender, preferredEdge: .maxY)
    }
    
    @IBAction func uploadDescription(_ sender: NSButton) {
        /*
        if CWWiFiClient()?.interface()?.ssid() == "BCIS WIFI" || CWWiFiClient()?.interface()?.ssid() == "BCIS_AP_Visitor" {
            let alert = NSAlert()
            customizeAlert(alert)
            alert.messageText = "Oops! You're on school wifi."
            alert.informativeText = "Unfortunately, BCIS Wi-Fi blocked all outgoing network traffic on FTP servers. Therefore, you must switch to a different network in order to upload."
            alert.addButtonWithTitle("Fine").keyEquivalent = "\r"
            alert.window.title = "Unavailable Network"
            if alert.runModal() == NSAlertFirstButtonReturn {return}
        } */
        
        descriptionUpdateSpinner.startAnimation(nil)
        sender.isEnabled = false
        
        // Prepare description RTFD file to upload (as zip)
        message.writeRTFD(toFile: NSTemporaryDirectory() + "Description.rtfd", atomically: true)
        message.writeRTFD(toFile: NSTemporaryDirectory() + EA_Name.stringValue + ".rtfd", atomically: true)
        let command = Terminal(launchPath: "/usr/bin/zip", arguments: ["-r", EA_Name.stringValue + ".zip", "Description.rtfd"])
        command.currentPath = NSTemporaryDirectory()
        command.deleteFileWithPath("./\(EA_Name.stringValue).zip")
        command.execUntilExit()
        command.deleteFileWithPath("./Description.rtfd")
        
        var config = SessionConfiguration()
        
        /*
        config.host = "e45.ehosts.com"
        config.username = "ea@thefluxfilm.com"
        config.password = "tenic"
        config.passive = true
        */
        
        config.host = "47.52.6.204:23333"
        config.username = "root"
        config.password = "Tenic@2017"
        config.passive = true
        
        let session = Session(configuration: config)
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory() + EA_Name.stringValue + ".zip")
        session.upload(fileURL, path: "/var/www/html/EA/" + EA_Name.stringValue + ".zip") {(result, error) -> Void in
            DispatchQueue.main.async {
                self.descriptionUpdateSpinner.stopAnimation(nil)
                sender.isEnabled = true
            }
            if result {
                print("uploaded")
            } else {
                let alert = NSAlert()
                alert.messageText = "Let me get online!"
                if error?.code == 2 {
                    alert.informativeText = "If you do not connect to the Internet, I cannot save your changes."
                } else {
                    print(error!)
                }
                DispatchQueue.main.async {
                    alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
                }
            }
        }
    }
    
    @IBAction func revertDescription(_ sender: NSButton) {
        let alert = NSAlert()
        customizeAlert(alert)
        alert.messageText = "Are you sure?"
        alert.informativeText = "If you continue, your EA's description will be reverted to the last version you've uploaded to the server."
        alert.addButton(withTitle: "Proceed").keyEquivalent = "\r"
        alert.addButton(withTitle: "Cancel")
        if alert.runModal() == NSAlertSecondButtonReturn {return}
        updateDescription()
    }
    
    func updateDescription() {
        revertSpinner.startAnimation(nil)
        message.isEditable = false
        let acceptableChars = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789_-")
        
        let name = EA_Name.stringValue.addingPercentEncoding(withAllowedCharacters: acceptableChars)
        message.string = ""
        let request = URLRequest(url: URL(string: serverAddress + "EA/\(name!).zip")!)
        let download = NSURLDownload.init(request: request, delegate: self)
        download.setDestination(NSTemporaryDirectory() + EA_Name.stringValue + ".zip", allowOverwrite: true)
        download.deletesFileUponFailure = true
        downloadQueue[EA_Name.stringValue] = download
        Terminal().deleteFileWithPath(NSTemporaryDirectory() + EA_Name.stringValue + ".rtfd")
        Terminal().deleteFileWithPath(NSTemporaryDirectory() + "Description.rtfd")
    }

    
    func downloadDidFinish(_ download: NSURLDownload) {
        revertSpinner.stopAnimation(nil)

        if downloadQueue[EA_Name.stringValue] == download {
            let command = Terminal(launchPath: "/usr/bin/unzip", arguments: ["-o", EA_Name.stringValue + ".zip"])
            command.currentPath = NSTemporaryDirectory()
            command.execUntilExit()
            command.launchPath = "/bin/mv"
            command.deleteFileWithPath(NSTemporaryDirectory() + EA_Name.stringValue + ".rtfd")
            command.arguments = ["Description.rtfd", EA_Name.stringValue + ".rtfd"]
            command.execUntilExit()
            message.readRTFD(fromFile: NSTemporaryDirectory() + EA_Name.stringValue + ".rtfd")
            adjustImages()
            message.isEditable = true
            length = 0
        }
    }
    
    func download(_ download: NSURLDownload, didReceiveDataOfLength length: Int) {
        self.length += length
    }
    
    func download(_ download: NSURLDownload, didFailWithError error: Error) {
        print(error)
        revertSpinner.stopAnimation(nil)
        print(error.localizedDescription)
//        if error.code == -1100 {
            message.string = "Give a brief introduction to your EA. Similar to how you would advertise your EA on the Student Bulletin, use graphics and texts to attract students and convince them to join! Some things you may want to include:\n\n • A QR code of your Wechat group\n • What students will be doing in this EA\n • The final outcome of this EA\n • Images of the EA\n • Requirements / Prerequisites\n • Start Date & End Date\n • Updates on current progress\n\nNote: If you want to import a photo from an apple device, plug it in, right click and select \"Import Image\"!"
            message.font = NSFont(name: "Helvetica", size: 13)
            message.alignment = .left
            message.isEditable = true
            message.textColor = NSColor.black
            let pstyle = NSMutableParagraphStyle.default().mutableCopy() as! NSMutableParagraphStyle
            pstyle.paragraphSpacing = 7
            pstyle.lineHeightMultiple = 1.1
            message.textStorage?.addAttribute(NSParagraphStyleAttributeName, value: pstyle, range: NSMakeRange(0, message.textStorage!.length))

//        }
    }
    
    @IBAction func removeEA(_ sender: NSButton) {
        
        let row = EATableView.selectedRow
        if row == -1 {return}
        
        let alert = NSAlert()
        customizeAlert(alert)
        alert.messageText = "Remove this EA?"
        alert.informativeText = "All your records on this EA will be permanently erased from the server."
        alert.window.title = "Remove EA"
        alert.addButton(withTitle: "I have made up my mind")
        alert.addButton(withTitle: "Cancel")
        if alert.runModal() == NSAlertSecondButtonReturn {return}

        let cell = EATableView.view(atColumn: 0, row: row, makeIfNecessary: false) as! EAView
        let url = URL(string: serverAddress + "tenicCore/RemoveEA.php")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        var hasRun = false
        let postString = "EA=\(cell.EAName.stringValue)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            if hasRun {return}
            hasRun = true
            DispatchQueue.main.async {
                self.myEAs.remove(at: row)
                self.tableViewSelectionIsChanging(Notification(name: Notification.Name(rawValue: ""), object: nil))
                self.zeroEA.isHidden = self.myEAs.count > 0
            }
            
        }
        task.resume()
    }
    
    @IBAction func enableMinGrade(_ sender: NSButton) {
        minGrade.isEnabled = sender.integerValue == 1
        changeGradeBoundary(sender)
    }
    
    @IBAction func enableMaxGrade(_ sender: NSButton) {
        maxGrade.isEnabled = sender.integerValue == 1
        changeGradeBoundary(sender)
    }
    
    @IBAction func changeGradeBoundary(_ sender: NSObject) {
        if Int(minGrade.title) > Int(maxGrade.title) && minGrade.isEnabled && maxGrade.isEnabled {
            let alert = NSAlert()
            alert.messageText = "Your minimum grade is GREATER than your maximum grade"
            alert.alertStyle = .critical
            alert.informativeText = "Technically, this means no one can join your EA. Are you sure about that?"
            alert.addButton(withTitle: "Yes").keyEquivalent = "\r"
            alert.addButton(withTitle: "No")
            customizeAlert(alert)
            if alert.runModal() != NSAlertFirstButtonReturn {
                switch sender {
                case maxGrade:
                    maxGrade.title = minGrade.title
                case maxGradeCheckbox:
                    maxGradeCheckbox.integerValue = 0
                    maxGrade.isEnabled = false
                case minGrade:
                    minGrade.title = maxGrade.title
                case minGradeCheckbox:
                    minGradeCheckbox.integerValue = 0
                    minGrade.isEnabled = false
                default:
                    break
                }
                return
            }
            
        }
        
        var minAge = ""
        if minGrade.isEnabled {minAge = minGrade.title}
        var maxAge = ""
        if maxGrade.isEnabled {maxAge = maxGrade.title}
        shouldUpdate = false
        for i in 0..<myEAs.count {
            if myEAs[i].name == EA_Name.stringValue {
                myEAs[i].age = minAge + " | " + maxAge
            }
        }
        shouldUpdate = true
        changeStatusForKey("Age", value: minAge + " | " + maxAge, spinner: gradeSpinner, updateRow: false)
        (sender as? NSComboBox)?.layer?.borderWidth = 0
    }
    
    @IBAction func changeFrequency(_ sender: NSPopUpButton) {
        for i in 0..<myEAs.count {
            if myEAs[i].name == EA_Name.stringValue {
                myEAs[i].frequency = sender.selectedTag()
                changeStatusForKey("Frequency", value: String(sender.selectedTag()), spinner: nil, updateRow: false)
                
                if myEAs[i].dates == "" {return}
                myEAs[i].dates = generateAvailableDates(myEAs[i])
                changeStatusForKey("Dates", value: myEAs[i].dates, spinner: nil, updateRow: false)
            }
        }
    }
    
    func generateAvailableDates(_ theEA: EA) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM. d, y"
        formatter.locale = Locale(identifier: "en_US")
        //        let today = formatter.date(from: formatter.string(from: Date()))!
        let dates = theEA.time.components(separatedBy: " | ")[0].components(separatedBy: ", ")
        
        
        let start = formatter.date(from: theEA.startDate)!
        var current = formatter.date(from: formatter.string(from: Date()))!.addingTimeInterval(86400)
        if current.timeIntervalSince(start) < 0 {current = start}
        let endDate = formatter.date(from: theEA.endDate)!
        
        var availableDates = [String]()
        if theEA.dates != "" {
            availableDates = theEA.dates.components(separatedBy: " | ").map {formatter.date(from: $0)!} . filter {$0.timeIntervalSince(current) < 0} . map {formatter.string(from: $0)}
        }
        
        for i in 0...Int(endDate.timeIntervalSince(current) / 86400) {
            formatter.dateFormat = "E"
            let tmpdate = current.addingTimeInterval(Double(i * 86400))
            let weekday = formatter.string(from: tmpdate)
            if dates.contains(weekday) || dates[0].hasPrefix(weekday) {
                formatter.dateFormat = "MMM. d, y"
                availableDates.append(formatter.string(from: tmpdate))
            }
        }
        
        switch theEA.frequency {
        case 4:
            return availableDates.joined(separator: " | ")
        case 2:
            return availableDates.filter({availableDates.index(of: $0)! % 2 == 0}).joined(separator: " | ")
        case 1:
            return availableDates.filter({availableDates.index(of: $0)! % 4 == 0}).joined(separator: " | ")
        default:
            return availableDates.joined(separator: " | ")
        }
    }
    
    @IBAction func nextDate(_ sender: NSButton) {
        
        if EATableView.selectedRow == -1 || nextSessionDate == "Unavailable" {return}
        let theEA = myEAs[EATableView.selectedRow]
        if theEA.dates == "" {return}
        
        let allDates = theEA.dates.components(separatedBy: " | ")
        if let currentIndex = allDates.index(of: nextSessionDate) {
            if currentIndex < allDates.count - 1 {nextSessionDate = allDates[currentIndex+1]} else {
                nextSessionDate = allDates.last!
            }
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "MMM. d, y"
            
            let oldDate = formatter.date(from: nextSessionDate)!
            
            var targetDate = Date()
            
            for i in allDates.map({formatter.date(from: $0)!}) {
                let distance = i.timeIntervalSince(oldDate) / 86400
                if distance > 0 {
                    targetDate = i
                }
            }
            nextSessionDate = formatter.string(from: targetDate)
        }
        
        /*
        if EATableView.selectedRow == -1 {return}
        
        let theEA = myEAs[EATableView.selectedRow]
        let availableDays = theEA.time.componentsSeparatedByString(" | ")[0].componentsSeparatedByString(", ")
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM. d, y"
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        
        let today = formatter.dateFromString(formatter.stringFromDate(NSDate()))!
        
        let currentDate = formatter.dateFromString(nextSessionDate)!
        
        var distance = 0.0
        if availableDays.count == 1 {
            distance = 7
        } else {
            let week = NSDateFormatter()
            week.dateFormat = "E"
            week.locale = NSLocale(localeIdentifier: "en_US")
            let currentDayOfWeek = week.stringFromDate(currentDate)
            if !availableDays.contains(currentDayOfWeek) {
                let alert = NSAlert()
                alert.messageText = "An error has occurred."
                alert.informativeText = "Please reload the page."
                alert.addButtonWithTitle("OK").keyEquivalent = "\r"
                alert.beginSheetModalForWindow(view.window!, completionHandler: nil)
                return
            }
            let index = Double(availableDays.indexOf(currentDayOfWeek)!)
            let old = week.dateFromString(currentDayOfWeek)!
            if Int(index) == availableDays.count - 1 {
                let new = week.dateFromString(availableDays.first!)!
                var interval = new.timeIntervalSinceDate(old) / 86400
                if interval < 0 {interval+=7}
                distance = interval
            } else {
                let new = week.dateFromString(availableDays[Int(index+1)])!
                var interval = new.timeIntervalSinceDate(old) / 86400
                if interval < 0 {interval+=7}
                distance = interval
            }
        }
        let newDate = currentDate.dateByAddingTimeInterval(distance * 86400)
        
        let EAEndDate = formatter.dateFromString(theEA.endDate)!
        if newDate.timeIntervalSinceDate(EAEndDate) > 0 {return}

        confirmDateButton.enabled = newDate.timeIntervalSinceDate(today) >= 0
        
        nextSessionDate = formatter.stringFromDate(newDate)

        print(formatter.stringFromDate(newDate))
        
        if confirmDateButton.enabled {
            confirmDateButton.enabled = formatter.stringFromDate(newDate) != theEA.next && theEA.approval != "Inactive" && theEA.approval != "Pending" && theEA.approval != "Unapproved"
//            markPresent.enabled = false
//            markAbsent.enabled = false
        }
        */
        participantTable.reloadData()
    }
    
    @IBAction func previousDate(_ sender: NSButton) {
        
        if EATableView.selectedRow == -1 || nextSessionDate == "Unavailable" {return}
        
        let theEA = myEAs[EATableView.selectedRow]
        
        let allDates = theEA.dates.components(separatedBy: " | ")
        if let currentIndex = allDates.index(of: nextSessionDate) {
            if currentIndex > 0 {nextSessionDate = allDates[currentIndex-1]}
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "MMM. d, y"
            
            let oldDate = formatter.date(from: nextSessionDate)!
            
            var targetDate = Date()
            
            for i in allDates.map({formatter.date(from: $0)!}).reversed() {
                let distance = i.timeIntervalSince(oldDate) / 86400
                if distance < 0 {
                    targetDate = i
                }
            }
            nextSessionDate = formatter.string(from: targetDate)
        }
        

        participantTable.reloadData()

    }
    
    @IBAction func activateScheduler(_ sender: NSButton) {
        self.performSegue(withIdentifier: "Session Scheduler", sender: self)
    }
    
    
    // Managing the attendence system
    
    // Right Click
    var rightclickRowIndex = -1
    
    func menuWillOpen(_ menu: NSMenu) {
        
//        let theEA = myEAs.filter({$0.name == EA_Name.stringValue})[0]
        if !isTeacher {
            participantTable.menu?.removeAllItems()
            participantTable.menu?.addItem(withTitle: "Only EA Supervisor Can Mark Attendance", action: nil, keyEquivalent: "").isEnabled = false
            return
        }
        
        let cursor = NSEvent.mouseLocation()
        let cursorInWindow = NSPoint(x: cursor.x - (view.window?.frame.origin.x)!, y: cursor.y - (view.window?.frame.origin.y)!)
        rightclickRowIndex = participantTable.row(at: participantTable.convert(cursorInWindow, from: view))
        if rightclickRowIndex == -1 {menu.removeAllItems(); return}
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM. d, y"
        if nextSessionDateTextfield.stringValue != "Today" {
            let tmp = formatter.date(from: nextSessionDate)!
            if tmp.timeIntervalSince(Date()) > 0 {
                menu.removeAllItems()
                menu.addItem(withTitle: "EA Hasn't Run, Cannot Mark Attendance", action: nil, keyEquivalent: "").isEnabled = false
                if isTeacher {
                    menu.addItem(NSMenuItem.separator())
                    menu.addItem(withTitle: "Force Remove Student From EA", action: #selector(ViewController.removeParticipant), keyEquivalent: "").toolTip = "Don't want to see this student here?"
                }
                return
            }
        }
        
        let cell = participantTable.view(atColumn: 0, row: rightclickRowIndex, makeIfNecessary: false) as! ParticipantView
        
        participantTable.menu?.removeAllItems()
        if cell.attendance == .unapproved {return}
        participantTable.menu?.addItem(withTitle: "Mark as Present for this Session", action: #selector(ViewController.markAsPresent), keyEquivalent: "")
        participantTable.menu?.addItem(withTitle: "Mark as Absent for this Session", action: #selector(ViewController.markAsAbsent), keyEquivalent: "")
        
        if cell.attendance == .present {
            participantTable.menu?.item(at: 0)?.isEnabled = false
        } else if cell.attendance == .absent {
            participantTable.menu?.item(at: 1)?.isEnabled = false
        }
        
        if isTeacher {
            menu.addItem(NSMenuItem.separator())
            menu.addItem(withTitle: "Force Remove Student From EA", action: #selector(ViewController.removeParticipant), keyEquivalent: "").toolTip = "Don't want to see this student here?"
        }
    }
    
    // When the user clicks the remove menu item after the right-click a participant:
    
    func removeParticipant() {
        
        let alert = NSAlert()
        alert.messageText = "You are about to remove a student from \(EA_Name.stringValue)."
        alert.informativeText = "This process cannot be undone. However, the student may choose to rejoin the EA (which would require the EA approval again)."
        alert.addButton(withTitle: "Proceed").keyEquivalent = "\r"
        alert.addButton(withTitle: "Cancel")
        alert.icon = NSApplication.shared().applicationIconImage
        alert.beginSheetModal(for: view.window!) { response in
            if response != NSAlertFirstButtonReturn {return}
            let cell = self.participantTable.view(atColumn: 0, row: self.rightclickRowIndex, makeIfNecessary: false) as! ParticipantView
            for i in 0..<self.participants.count {
                if self.participants[i].id == cell.toolTip!.components(separatedBy: "\r")[0].components(separatedBy: ": ")[1] {
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "en_US")
                    formatter.dateFormat = "MMM. d, y"
                    
                    let url = URL(string: serverAddress + "tenicCore/signup.php")
                    var request = URLRequest(url: url!)
                    request.httpMethod = "POST"
                    
                    let postString = "id=\(self.participants[i].id)&ea=\(self.EA_Name.stringValue)&action=Leave&date=\(formatter.string(from: Date()))"
                    
                    request.httpBody = postString.data(using: String.Encoding.utf8)
                    
                    // Specify the session task
                    let uploadtask = URLSession.shared.dataTask(with: request) {
                        data, response, error in
                        do {
                            let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary as! [String:String]
                            if json["status"] == "success" {
                                DispatchQueue.main.async {
                                    self.updateParticipantsForEA(self.EA_Name.stringValue, date: self.nextSessionDate, updateTable: true)
                                }
                                broadcastMessage("Find my EA", message: "You have been removed from \(self.EA_Name.stringValue) by the EA supervisor.", filter: "I: \(self.participants[i].id)")
                                return
                            }
                            
                        } catch {
                            print(String(data: data!, encoding: String.Encoding.utf8)!)
                        } // End of do-catch structure
                    } // End of URLSession Data Transfer
                    uploadtask.resume()
                } // End of user ID match confirmation
            } // End of for-loop
        } // End of alert sheet response closure
    } // End of the function

    
    
    var refreshParticipants = true
    
    @IBAction func markAllAsPresent(_ sender: NSButton) {
        for i in 0..<participantTable.numberOfRows {
            let cell = participantTable.view(atColumn: 0, row: i, makeIfNecessary: false) as! ParticipantView
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "MMM. d, y"
            
            let tmp = formatter.date(from: nextSessionDate)!
            formatter.dateFormat = "y/M/d"
            let date = formatter.string(from: tmp)
            
            let currentID = cell.userID ?? "_"
            
            let pid = participants.map {$0.id}
            
            if let index = pid.index(of: currentID), !participants[index].attendance.contains(date) {
                refreshParticipants = false
                let add = participants[index].attendance == "" ? date : date + ", "
                participants[index].attendance = add + participants[index].attendance // Don't do the refresh yet
                refreshParticipants = true
                cell.changeStatusForKey("Attendance", value: participants[index].attendance, spinner: cell.attendanceSpinner, id: participants[index].id, present: true)
            }
        }
    }
    
    @IBAction func markAllAsAbsent(_ sender: NSButton) {
        let formatter = DateFormatter()
        for i in 0..<participantTable.numberOfRows {
            let cell = participantTable.view(atColumn: 0, row: i, makeIfNecessary: false) as! ParticipantView
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "MMM. d, y"
            
            let tmp = formatter.date(from: nextSessionDate)!
            formatter.dateFormat = "y/M/d"
            let date = formatter.string(from: tmp)
            
            let currentID = cell.userID ?? "_"
            
            let pid = participants.map {$0.id}
            
            if let index = pid.index(of: currentID), participants[index].attendance.contains(date) {
                var attendenceDates = participants[index].attendance.components(separatedBy: ", ")
                if attendenceDates.contains(date) {
                    attendenceDates.remove(at: attendenceDates.index(of: date)!)
                }
                refreshParticipants = false
                participants[index].attendance = attendenceDates.joined(separator: ", ")
                refreshParticipants = true
                cell.changeStatusForKey("Attendance", value: participants[index].attendance, spinner: cell.attendanceSpinner, id: participants[index].id, present: false)
            }
        }
    }
    
    
    func markAsPresent() {
        let cell = participantTable.view(atColumn: 0, row: rightclickRowIndex, makeIfNecessary: false) as! ParticipantView
        if cell.attendance == .present {return}
        for i in 0..<participants.count {
            if participants[i].id == cell.toolTip!.components(separatedBy: "\r")[0].components(separatedBy: ": ")[1] {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US")
                formatter.dateFormat = "MMM. d, y"
                
                let tmp = formatter.date(from: nextSessionDate)!
                formatter.dateFormat = "y/M/d"
                let date = formatter.string(from: tmp)
                
                let add = participants[i].attendance == "" ? date : date + ", "
                refreshParticipants = false
                participants[i].attendance = add + participants[i].attendance // Don't do the refresh yet
                refreshParticipants = true
                cell.changeStatusForKey("Attendance", value: participants[i].attendance, spinner: cell.attendanceSpinner, id: participants[i].id, present: true)
            }
        }
    }
    
    func markAsAbsent() {
        let cell = participantTable.view(atColumn: 0, row: rightclickRowIndex, makeIfNecessary: false) as! ParticipantView
        if cell.attendance == .absent {return}
        for i in 0..<participants.count {
            if participants[i].id == cell.toolTip!.components(separatedBy: "\r")[0].components(separatedBy: ": ")[1] {
                
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US")
                formatter.dateFormat = "MMM. d, y"
                
                let tmp = formatter.date(from: nextSessionDate)!
                formatter.dateFormat = "y/M/d"
                let date = formatter.string(from: tmp)
                
                var attendenceDates = participants[i].attendance.components(separatedBy: ", ")
                if attendenceDates.contains(date) {
                    attendenceDates.remove(at: attendenceDates.index(of: date)!)
                }
                refreshParticipants = false
                participants[i].attendance = attendenceDates.joined(separator: ", ")
                refreshParticipants = true
                cell.changeStatusForKey("Attendance", value: participants[i].attendance, spinner: cell.attendanceSpinner, id: participants[i].id, present: false)
            }
        }
    }
    
    
    @IBAction func sendMessage(_ sender: NSButton) {
        
        if sender.title == "Email" {
            sender.title = "Send"
            mailAll()
            return
        }
        
        var pass = true
        if messageTitle.stringValue == "" {
            pass = false
            messageTitle.wantsLayer = true
            messageTitle.layer?.borderColor = NSColor.red.cgColor
            messageTitle.layer?.borderWidth = 1
        }
        
        if !pass {return}
        
        sender.isHidden = true
        broadcastSpinner.startAnimation(nil)
        
        let filter = "E:\(EA_Name.stringValue)"
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "y/MM/dd HH:mm:ss:SSS"
        let date = formatter.string(from: Date())
        var sent = false
        let url = URL(string: serverAddress + "tenicCore/SendMessage.php")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let postString = "date=\(date)&message=\([filter, messageTitle.stringValue.encodedString(), broadcastTextView.string!.encodedString()].joined(separator: "\u{2028}"))"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            if sent {return}
            if error != nil {
                print("error=\(error!)")
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    customizeAlert(alert)
                    alert.messageText = "Let me get online!"
                    alert.informativeText = "I cannot send your message if you are offline."
                    alert.addButton(withTitle: "OK").keyEquivalent = "\r"
                    alert.runModal()
                }
                return
            }
            
            DispatchQueue.main.async {
                self.broadcastSpinner.stopAnimation(nil)
                self.broadcastTextView.string = ""
                self.messageTitle.stringValue = ""
                sender.isHidden = false
            }
            
            sent = true
        }
        task.resume()
    }
    
    func logout(_ sender: NSButton) {
        self.performSegue(withIdentifier: "Log out", sender: self)
        for i in NSApplication.shared().windows {
            if !["Login", "Bug Reporter"].contains(i.title) {
                i.orderOut(self)
            }
        }
        logged_in = false
    }
    
    // FTP server communication
    
    @IBOutlet weak var updateProgressText: NSTextField!
    @IBOutlet weak var updateDownloadProgress: NSProgressIndicator!
    
    func startUpdate() {
        updateProgressText.stringValue = "Preparing update..."
        requestManager?.delegate = self
        updateDownloadProgress.isHidden = false
        updateDownloadProgress.isIndeterminate = true
        updateDownloadProgress.startAnimation(nil)
        let menu = NSMenu(title: "Update")
        menu.addItem(withTitle: "Cancel Download", action: #selector(ViewController.cancelUpdate), keyEquivalent: "")
        updateDownloadProgress.menu = menu
        requestManager?.addRequestForDownloadFile(atRemotePath: "../downloads/Found my EA.pkg", toLocalPath: NSTemporaryDirectory() + "Found my EA.pkg")
        requestManager?.startProcessingRequests()
    }
    
    func cancelUpdate() {
        requestManager?.stopAndCancelAllRequests()
        updateDownloadProgress.isHidden = true
        updateDownloadProgress.doubleValue = 0
        updateProgressText.stringValue = ""
    }
    
    func requestsManager(_ requestsManager: GRRequestsManagerProtocol!, didCompletePercent percent: Float, forRequest request: GRRequestProtocol!) {
        updateProgress = Double(percent * 100)
    }
    
    var updateProgress = 0.0 {
        didSet {
            updateDownloadProgress.isIndeterminate = false
            updateProgressText.stringValue = "Downloading...\(Int(updateProgress))%"
            updateDownloadProgress.doubleValue = updateProgress
        }
    }
    
    func requestsManager(_ requestsManager: GRRequestsManagerProtocol!, didCompleteDownloadRequest request: GRDataExchangeRequestProtocol!) {
        updateFinished()
    }
    
    func updateFinished() {
        updateDownloadProgress.isHidden = true
        updateProgressText.stringValue = "Update downloaded."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.updateProgressText.stringValue = ""
        }
        
        let alert = NSAlert()
        alert.window.title = "Found my EA Update"
        alert.messageText = "I'm ready."
        alert.informativeText = "Would you like to update right now?"
        alert.addButton(withTitle: "Install Now").keyEquivalent = "\r"
        alert.addButton(withTitle: "Later")
        customizeAlert(alert)
        if alert.runModal() == NSAlertFirstButtonReturn {
            let command = Terminal(launchPath: "/usr/bin/open", arguments: [NSTemporaryDirectory() + "Found my EA.pkg"])
            command.execUntilExit()
            NSApplication.shared().terminate(0)
        } else {
            (NSApplication.shared().delegate as! AppDelegate).installUpdate.isHidden = false
            (NSApplication.shared().delegate as! AppDelegate).updateItem.isEnabled = false
        }
    }
}

func customizeAlert(_ alert: NSAlert) {
    alert.window.styleMask.insert(.texturedBackground)
    for i in alert.window.titlebarAccessoryViewControllers {
        print(i)
    }
    alert.window.isMovableByWindowBackground = true
    alert.window.backgroundColor = NSColor(red: 0.95, green: 0.98, blue: 1, alpha: 1)
    alert.window.setFrame(NSRect(origin: alert.window.contentView!.frame.origin, size: NSMakeSize(alert.window.frame.width, alert.window.frame.height - 1)), display: true)
    alert.window.contentView!.frame = NSRect(origin: alert.window.contentView!.frame.origin, size: NSMakeSize(alert.window.contentView!.frame.width, alert.window.contentView!.frame.height + 4))
    if alert.window.title == "" {alert.window.title = "Found my EA"}
}


let database = ["Cloud Sync": (108, 19), "Globe": (506, 57), "Ring": (14, 0)]

class LoadImage: NSImageView {
    
    var isAnimating = false
    var imageName = ""
    var max = 0
    var breakpoint = 0
    
    var clickCount = 0 {
        didSet {
            if clickCount >= 4 {
                let alert = NSAlert()
                alert.messageText = "Please be Patient!"
                alert.informativeText = "You seem to be experiencing a poor internet connection, but clicking the reload button as often as you can DOES NOT help."
                customizeAlert(alert)
                alert.addButton(withTitle: "OK").keyEquivalent = "\r"
                alert.runModal()
            }
        }
    }
    
    var currentThread: Thread?
    
    let resourcePath = Bundle.main.resourcePath!
    
    func startAnimation(_ image: String) {
        if currentThread != nil && !currentThread!.isCancelled || isAnimating {return}
        stopAnimation()
        self.image = nil
        self.imageName = image
        max = database[imageName]!.0
        breakpoint = database[imageName]!.1
        self.isHidden = false
        isAnimating = true
        currentThread = Thread(target: self, selector: #selector(LoadImage.loop), object: nil)
        currentThread!.start()
    }
    
    func stopAnimation() {
        isAnimating = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.currentThread?.cancel()
        }
    }
    
    func loop() {
        isAnimating = true
        var currentFrame = 0
        let imageData = NSData.data(withCompressedData: (animationPack[NSString(string: imageName).aes256Encrypt(withKey: AESKey)]! as NSData).aes256Decrypt(withKey: AESKey)) as! Data
        let sequence = NSKeyedUnarchiver.unarchiveObject(with: imageData) as! [Data]
        while isAnimating {
            //let name = imageName + "_" + String(format: "%03d", currentFrame) + ".png"
            //let tmp = NSImage(contentsOfFile: resourcePath + "/" + imageName + "/" + name)
            DispatchQueue.main.async {self.image = NSImage(data: sequence[currentFrame])}
            currentFrame = currentFrame < max ? currentFrame + 1 : breakpoint
            Thread.sleep(forTimeInterval: 0.03)
        }
        self.isHidden = true
        return
    }
}

extension NSTokenField {
    override open var stringValue: String {
        get {
            let raw = self.objectValue as! [String]
            return raw.joined(separator: ", ")
        } set (newValue) {
            let content = newValue.components(separatedBy: ", ")
            self.objectValue = newValue == "" ? [String]() : content
        }
    }
}
