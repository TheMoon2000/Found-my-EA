//
//  EA Info.swift
//  EA Registration
//
//  Created by Jia Rui Shan on 12/3/16.
//  Copyright © 2016 Jerry Shan. All rights reserved.
//

import Cocoa

struct EA {
    var name = ""
    var teacher = false
    var description = ""
    var leader = ""
    var supervisor = ""
    var id = ""
    var location = ""
    var time = ""
    var approval = ""
    var participants = ""
    var approved = ""
    var age = " | "
    var max = ""
    var dates = ""
    var startDate = ""
    var endDate = ""
    var proposal = ""
    var prompt = ""
    var frequency = 4
    
    
    init(_ EA_Name: String, type: Bool, description: String, date: String, leader: String, id: String, supervisor: String, location: String, approval: String, participants: String, approved: String, max: String, dates: String, startDate: String, endDate: String, proposal: String, prompt: String, frequency: Int) {
        self.name = EA_Name
        self.description = description
        self.teacher = type
        self.time = date
        self.leader = leader
        self.supervisor = supervisor
        self.id = id
        self.location = location
        self.approval = approval
        self.participants = participants
        self.approved = approved
        self.max = max
        self.dates = dates
        self.startDate = startDate
        self.endDate = endDate
        self.proposal = proposal
        self.prompt = prompt
        self.frequency = frequency
    }
}

struct Participant {
    var name = ""
    var id = ""
    var advisory = ""
    var message = ""
    var approval = ""
    var attendance = ""
    var startDate = ""
    var endDate = ""
    
    init(name: String, id: String, advisory: String, message: String, approval: String, attendance: String, startDate: String, endDate: String) {
        self.name = name
        self.id = id
        self.advisory = advisory
        self.message = message
        self.approval = approval
        self.attendance = attendance
        self.startDate = startDate
        self.endDate = endDate
    }
}

extension Participant: Equatable {}
extension EA: Equatable {}
func ==(lhs: Participant, rhs: Participant) -> Bool {
    return lhs.name == rhs.name && lhs.id == rhs.id
}
func ==(lhs: EA, rhs: EA) -> Bool {
    return lhs.name == rhs.name && lhs.id == rhs.id
}
