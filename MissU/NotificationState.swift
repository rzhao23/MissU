//
//  NotificationState.swift
//  MissU
//
//  Created by Robert Zhao on 2025-12-29.
//

import Foundation

/* Retrieve the date of the latest notified message */
private let lastHandledDateKey = "lastHandledLoveRecordDate"

func loadLastHandledDate() -> Date {
    UserDefaults.standard.object(forKey: lastHandledDateKey) as? Date
        ?? Date.distantPast
}

func saveLastHandledDate(_ date: Date) {
    UserDefaults.standard.set(date, forKey: lastHandledDateKey)
}
