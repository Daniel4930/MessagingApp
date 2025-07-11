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
    let id = UUID()
    let userId: UUID
    let date: Date
    let text: String?
    let imageData: Data?
    let location: MessageLocation
    let react: String?
    let replyMessageId: UUID?
    let fowardMessageId: UUID?
    let edited: Bool
    
    static let mockMessage = [
        // Day 1 - 9:15 multiple users
        Message(
            userId: User.mockUser[0].id,
            date: createDate(day: 2, month: 5, year: 2024, hour: 9, minute: 15),
            text: "Morning! Did you finish the report?",
            imageData: nil,
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),
        Message(
            userId: User.mockUser[1].id,
            date: createDate(day: 2, month: 5, year: 2024, hour: 9, minute: 15),
            text: "Hey! Almost done, should have it ready by lunch.",
            imageData: nil,
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),

        // Same user sends multiple messages at the same time
        Message(
            userId: User.mockUser[0].id,
            date: createDate(day: 2, month: 5, year: 2024, hour: 9, minute: 16),
            text: "Also, I updated the budget sheet.",
            imageData: nil,
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),
        Message(
            userId: User.mockUser[0].id,
            date: createDate(day: 2, month: 5, year: 2024, hour: 9, minute: 16),
            text: "Check if you agree with the new numbers.",
            imageData: nil,
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),

        // Day 2 - 14:08 multiple users
        Message(
            userId: User.mockUser[0].id,
            date: createDate(day: 3, month: 5, year: 2024, hour: 14, minute: 8),
            text: "Hey, free for a quick call later?",
            imageData: nil,
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),
        Message(
            userId: User.mockUser[1].id,
            date: createDate(day: 3, month: 5, year: 2024, hour: 14, minute: 8),
            text: "Sure, what time were you thinking?",
            imageData: nil,
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),

        // Same user sends multiple messages at the same time again
        Message(
            userId: User.mockUser[1].id,
            date: createDate(day: 3, month: 5, year: 2024, hour: 14, minute: 9),
            text: "Also, I reviewed your notes.",
            imageData: nil,
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),
        Message(
            userId: User.mockUser[1].id,
            date: createDate(day: 3, month: 5, year: 2024, hour: 14, minute: 9),
            text: "Looks good, no major changes needed.",
            imageData: nil,
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),

        // Day 3 - 9:10 multiple users
        Message(
            userId: User.mockUser[1].id,
            date: createDate(day: 4, month: 5, year: 2024, hour: 9, minute: 10),
            text: "Morning! It went really well. Thanks for setting it up.",
            imageData: nil,
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),
        Message(
            userId: User.mockUser[0].id,
            date: createDate(day: 4, month: 5, year: 2024, hour: 9, minute: 10),
            text: "Of course. Glad to hear it.",
            imageData: nil,
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),

        // Same user multiple messages at same minute
        Message(
            userId: User.mockUser[0].id,
            date: createDate(day: 4, month: 5, year: 2024, hour: 9, minute: 11),
            text: "Are you coming to the team lunch?",
            imageData: nil,
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),
        Message(
            userId: User.mockUser[0].id,
            date: createDate(day: 4, month: 5, year: 2024, hour: 9, minute: 11),
            text: "It's at noon.",
            imageData: nil,
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),

        // Day 4 - 16:45 multiple users
        Message(
            userId: User.mockUser[0].id,
            date: createDate(day: 5, month: 5, year: 2024, hour: 16, minute: 45),
            text: "Did you see the email about the new project?",
            imageData: nil,
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),
        Message(
            userId: User.mockUser[1].id,
            date: createDate(day: 5, month: 5, year: 2024, hour: 16, minute: 45),
            text: "Yeah, looks interesting! We should discuss tomorrow.",
            imageData: nil,
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),

        // Day 5 - some consecutive messages
        Message(
            userId: User.mockUser[0].id,
            date: createDate(day: 6, month: 5, year: 2024, hour: 11, minute: 30),
            text: "Can you review my draft?",
            imageData: nil,
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),
        Message(
            userId: User.mockUser[1].id,
            date: createDate(day: 6, month: 5, year: 2024, hour: 11, minute: 32),
            text: "Sure thing, sending feedback soon.",
            imageData: nil,
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),
        Message(
            userId: User.mockUser[0].id,
            date: createDate(day: 6, month: 5, year: 2024, hour: 11, minute: 35),
            text: "Thanks! Appreciate it.",
            imageData: nil,
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),

        // Day 6 - 20:00 multiple users
        Message(
            userId: User.mockUser[1].id,
            date: createDate(day: 7, month: 5, year: 2024, hour: 20, minute: 0),
            text: "Are you coming to the meeting tomorrow?",
            imageData: nil,
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),
        Message(
            userId: User.mockUser[0].id,
            date: createDate(day: 7, month: 5, year: 2024, hour: 20, minute: 0),
            text: "Yes, I’ll be there.",
            imageData: nil,
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),
        Message(
            userId: User.mockUser[1].id,
            date: createDate(day: 7, month: 5, year: 2024, hour: 20, minute: 1),
            text: "Great! Looking forward to it.",
            imageData: nil,
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),
        Message(
            userId: User.mockUser[1].id,
            date: createDate(day: 7, month: 5, year: 2024, hour: 20, minute: 1),
            text: "Great! Looking forward to",
            imageData: nil,
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),
        Message(
            userId: User.mockUser[1].id,
            date: createDate(day: 7, month: 5, year: 2024, hour: 20, minute: 1),
            text: "This is my icon",
            imageData: UIImage(named: "userIcon")!.pngData()!,
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
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
