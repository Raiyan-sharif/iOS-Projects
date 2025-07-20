//
//  Meeting.swift
//  CustomUIPushNotificationGroupCall
//
//  Created by Raiyan Sharif on 14/7/25.
//
struct Meeting: Codable {
    let id: String
    let meetingUrl: String?
    let roomId: String
    let matrixServerName: String
    let meetingStartTime: String?
    let meetingEndTime: String?
    let participants: [String]?
    let createdAt: String
    let updatedAt: String
    let oneToOneCall: Bool
}
