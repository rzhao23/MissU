//
//  Storage.swift
//  MissU
//
//  Created by Robert Zhao on 2025-12-29.
//

import Foundation

/* save records locally using json files */
func saveRecords(_ records: [LoveRecord]) {
    let encoder = JSONEncoder()
    if let data = try? encoder.encode(records) {
        UserDefaults.standard.set(data, forKey: "loveRecords")
    }
}

/* load records locally using json files */
func loadRecords() -> [LoveRecord] {
    let decoder = JSONDecoder()

    if let data = UserDefaults.standard.data(forKey: "loveRecords"),
       let records = try? decoder.decode([LoveRecord].self, from: data) {
        return records
    }

    return []
}
