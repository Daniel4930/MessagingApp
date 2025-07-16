//
//  Message.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/9/25.
//
import Foundation
import UIKit

enum MessageLocation {
    case channel
    case dm
}

struct Message: Hashable, Identifiable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
    var identifier: String {
        return UUID().uuidString
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    let id = UUID()
    let userId: UUID
    let date: Date
    let text: String?
    let imageData: [Data]
    let fileData: [(name: String, data: Data)]
    let location: MessageLocation
    let react: String?
    let replyMessageId: UUID?
    let forwardMessageId: UUID?
    let edited: Bool
    
    static let mockMessage: [Message] = [
        Message(
            userId: User.mockUser[1].id,
            date: createDate(day: 12, month: 3, year: 1990, hour: 8, minute: 30),
            text: "Back to the 1980s",
            imageData: [],
            fileData: [],
            location: .dm,
            react: nil,
            replyMessageId: nil,
            forwardMessageId: nil,
            edited: false
        ),
        Message(
            userId: User.mockUser[0].id,
            date: createDate(day: 10, month: 6, year: 2022, hour: 14, minute: 15),
            text: "Hey, are we still on for the meeting?",
            imageData: [],
            fileData: [],
            location: .channel,
            react: "👍",
            replyMessageId: nil,
            forwardMessageId: nil,
            edited: false
        ),
        Message(
            userId: User.mockUser[0].id,
            date: createDate(day: 11, month: 6, year: 2022, hour: 9, minute: 45),
            text: nil,
            imageData: [Data("sampleImage".utf8)],
            fileData: [],
            location: .dm,
            react: nil,
            replyMessageId: nil,
            forwardMessageId: nil,
            edited: false
        ),
        Message(
            userId: User.mockUser[1].id,
            date: createDate(day: 11, month: 6, year: 2022, hour: 10, minute: 0),
            text: "Check out this document",
            imageData: [],
            fileData: [(name: "Proposal.pdf", data: Data("PDF data".utf8))],
            location: .channel,
            react: nil,
            replyMessageId: nil,
            forwardMessageId: nil,
            edited: false
        ),
        Message(
            userId: User.mockUser[1].id,
            date: createDate(day: 12, month: 6, year: 2022, hour: 16, minute: 20),
            text: "Sure! I'll send it over.",
            imageData: [],
            fileData: [],
            location: .dm,
            react: "❤️",
            replyMessageId: nil,
            forwardMessageId: nil,
            edited: true
        ),
        Message(
            userId: User.mockUser[0].id,
            date: createDate(day: 13, month: 6, year: 2022, hour: 11, minute: 5),
            text: "Forwarded message",
            imageData: [],
            fileData: [],
            location: .channel,
            react: nil,
            replyMessageId: nil,
            forwardMessageId: UUID(), // Replace with actual forwarded message ID
            edited: false
        ),
        Message(
            userId: User.mockUser[0].id,
            date: createDate(day: 13, month: 6, year: 2022, hour: 21, minute: 5),
            text: "Forwarded message",
            imageData: [],
            fileData: [],
            location: .channel,
            react: nil,
            replyMessageId: nil,
            forwardMessageId: UUID(), // Replace with actual forwarded message ID
            edited: false
        ),
        Message(
            userId: User.mockUser[0].id,
            date: createDate(day: 13, month: 6, year: 2022, hour: 1, minute: 5),
            text: "Forwarded message",
            imageData: [],
            fileData: [],
            location: .channel,
            react: nil,
            replyMessageId: nil,
            forwardMessageId: UUID(), // Replace with actual forwarded message ID
            edited: false
        ),
        Message(
            userId: User.mockUser[1].id,
            date: createDate(day: 12, month: 6, year: 2022, hour: 16, minute: 20),
            text: "Sure! I'll send it over.",
            imageData: [],
            fileData: [],
            location: .dm,
            react: "❤️",
            replyMessageId: nil,
            forwardMessageId: nil,
            edited: true
        ),
        Message(
            userId: User.mockUser[1].id,
            date: createDate(day: 12, month: 6, year: 2025, hour: 3, minute: 20),
            text: "https://youtube.com",
            imageData: [],
            fileData: [],
            location: .dm,
            react: "❤️",
            replyMessageId: nil,
            forwardMessageId: nil,
            edited: true
        ),
        Message(
            userId: User.mockUser[1].id,
            date: createDate(day: 12, month: 6, year: 2025, hour: 1, minute: 20),
            text: "https://youtube.com",
            imageData: [],
            fileData: [],
            location: .dm,
            react: "❤️",
            replyMessageId: nil,
            forwardMessageId: nil,
            edited: true
        ),
        Message(
            userId: User.mockUser[1].id,
            date: createDate(day: 12, month: 6, year: 2023, hour: 3, minute: 19),
            text: "",
            imageData: [UIImage(named: "icon")!.pngData()!, UIImage(named: "icon")!.pngData()!],
            fileData: [],
            location: .dm,
            react: "❤️",
            replyMessageId: nil,
            forwardMessageId: nil,
            edited: true
        )
    ]

    
    static func createDate(day: Int, month: Int, year: Int, hour: Int, minute: Int) -> Date {
        var date = DateComponents()
        date.day = day
        date.month = month
        date.year = year
        date.hour = hour
        date.minute = minute
        
        let calendar = Calendar.current
        if let result = calendar.date(from: date) {
            return result
        }
        
        return Date()
    }
}
