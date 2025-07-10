//
//  Message.swift
//  MessagingApp
//
//  Created by Daniel Le on 7/9/25.
//
import Foundation

struct Message: Hashable, Identifiable {
    let id = UUID()
    let userId: UUID
    let date: Date
    let data: Data
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
            data: Data("Morning! Did you finish the report?".utf8),
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),
        Message(
            userId: User.mockUser[1].id,
            date: createDate(day: 2, month: 5, year: 2024, hour: 9, minute: 15),
            data: Data("Hey! Almost done, should have it ready by lunch.".utf8),
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),

        // Same user sends multiple messages at the same time
        Message(
            userId: User.mockUser[0].id,
            date: createDate(day: 2, month: 5, year: 2024, hour: 9, minute: 16),
            data: Data("Also, I updated the budget sheet.".utf8),
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),
        Message(
            userId: User.mockUser[0].id,
            date: createDate(day: 2, month: 5, year: 2024, hour: 9, minute: 16),
            data: Data("Check if you agree with the new numbers.".utf8),
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),

        // Day 2 - 14:08 multiple users
        Message(
            userId: User.mockUser[0].id,
            date: createDate(day: 3, month: 5, year: 2024, hour: 14, minute: 8),
            data: Data("Hey, free for a quick call later?".utf8),
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),
        Message(
            userId: User.mockUser[1].id,
            date: createDate(day: 3, month: 5, year: 2024, hour: 14, minute: 8),
            data: Data("Sure, what time were you thinking?".utf8),
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),

        // Same user sends multiple messages at the same time again
        Message(
            userId: User.mockUser[1].id,
            date: createDate(day: 3, month: 5, year: 2024, hour: 14, minute: 9),
            data: Data("Also, I reviewed your notes.".utf8),
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),
        Message(
            userId: User.mockUser[1].id,
            date: createDate(day: 3, month: 5, year: 2024, hour: 14, minute: 9),
            data: Data("Looks good, no major changes needed.".utf8),
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),

        // Day 3 - 9:10 multiple users
        Message(
            userId: User.mockUser[1].id,
            date: createDate(day: 4, month: 5, year: 2024, hour: 9, minute: 10),
            data: Data("Morning! It went really well. Thanks for setting it up.".utf8),
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),
        Message(
            userId: User.mockUser[0].id,
            date: createDate(day: 4, month: 5, year: 2024, hour: 9, minute: 10),
            data: Data("Of course. Glad to hear it.".utf8),
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),

        // Same user multiple messages at same minute
        Message(
            userId: User.mockUser[0].id,
            date: createDate(day: 4, month: 5, year: 2024, hour: 9, minute: 11),
            data: Data("Are you coming to the team lunch?".utf8),
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),
        Message(
            userId: User.mockUser[0].id,
            date: createDate(day: 4, month: 5, year: 2024, hour: 9, minute: 11),
            data: Data("It's at noon.".utf8),
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),

        // Day 4 - 16:45 multiple users
        Message(
            userId: User.mockUser[0].id,
            date: createDate(day: 5, month: 5, year: 2024, hour: 16, minute: 45),
            data: Data("Did you see the email about the new project?".utf8),
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),
        Message(
            userId: User.mockUser[1].id,
            date: createDate(day: 5, month: 5, year: 2024, hour: 16, minute: 45),
            data: Data("Yeah, looks interesting! We should discuss tomorrow.".utf8),
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),

        // Day 5 - some consecutive messages
        Message(
            userId: User.mockUser[0].id,
            date: createDate(day: 6, month: 5, year: 2024, hour: 11, minute: 30),
            data: Data("Can you review my draft?".utf8),
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),
        Message(
            userId: User.mockUser[1].id,
            date: createDate(day: 6, month: 5, year: 2024, hour: 11, minute: 32),
            data: Data("Sure thing, sending feedback soon.".utf8),
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),
        Message(
            userId: User.mockUser[0].id,
            date: createDate(day: 6, month: 5, year: 2024, hour: 11, minute: 35),
            data: Data("Thanks! Appreciate it.".utf8),
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),

        // Day 6 - 20:00 multiple users
        Message(
            userId: User.mockUser[1].id,
            date: createDate(day: 7, month: 5, year: 2024, hour: 20, minute: 0),
            data: Data("Are you coming to the meeting tomorrow?".utf8),
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),
        Message(
            userId: User.mockUser[0].id,
            date: createDate(day: 7, month: 5, year: 2024, hour: 20, minute: 0),
            data: Data("Yes, I’ll be there.".utf8),
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),
        Message(
            userId: User.mockUser[1].id,
            date: createDate(day: 7, month: 5, year: 2024, hour: 20, minute: 1),
            data: Data("Great! Looking forward to it.".utf8),
            location: MessageLocation.dm,
            react: nil, replyMessageId: nil, fowardMessageId: nil, edited: false
        ),
        Message(
            userId: User.mockUser[1].id,
            date: createDate(day: 7, month: 5, year: 2024, hour: 20, minute: 1),
            data: Data("Great! Looking forward to it.".utf8),
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

enum MessageLocation {
    case channel
    case dm
}
