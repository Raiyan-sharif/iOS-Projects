//
//  LocalNotification.swift
//  LocalNotifications
//
//  Created by Raiyan Sharif on 13/5/25.
//
import Foundation

struct LocalNotification {
    init(identifier: String, title: String, body: String, timeInterval: Double, repeats: Bool) {
        self.identifier = identifier
        self.title = title
        self.body = body
        self.timeInterval = timeInterval
        self.dateComponents = nil
        self.repeats = repeats
        self.scheduleType = .time
    }
    init(identifier: String, title: String, body: String, dateComponents: DateComponents, repeats: Bool) {
        self.identifier = identifier
        self.title = title
        self.body = body
        self.timeInterval = nil
        self.dateComponents = dateComponents
        self.repeats = repeats
        self.scheduleType = .calander
    }
    
    enum ScheduleType {
        case time, calander
    }
    
    var identifier: String
    var title: String
    var body: String
    var timeInterval: Double?
    var dateComponents: DateComponents?
    var repeats: Bool
    var scheduleType: ScheduleType
}
