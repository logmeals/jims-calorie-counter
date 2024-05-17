//
//  Logic.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/17/24.
//

import Foundation

func formatDate(_ date: Date) -> String {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let yesterday = calendar.date(byAdding: .day, value: -1, to: today)
    
    if calendar.isDate(date, inSameDayAs: today) {
        return "Today"
    } else if let yesterday = yesterday, calendar.isDate(date, inSameDayAs: yesterday) {
        return "Yesterday"
    } else {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
        
        var formattedDate = dateFormatter.string(from: date)
        let currentYear = calendar.component(.year, from: today)
        let dateYear = calendar.component(.year, from: date)
        
        if dateYear != currentYear {
            formattedDate += ", \(dateYear)"
        }
        
        return formattedDate
    }
}

func formatNumberWithCommas(_ number: Int) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    return numberFormatter.string(from: NSNumber(value: number)) ?? ""
}

func formatTimestamp(date: Date) -> String {
    let formatter = DateFormatter()
    let use24HourTimestamps = UserDefaults.standard.bool(forKey: "use24HourTimestamps")
    
    if use24HourTimestamps {
        formatter.dateFormat = "HH:mm"
    } else {
        formatter.dateFormat = "h:mm a"
    }
    
    return formatter.string(from: date)
}
