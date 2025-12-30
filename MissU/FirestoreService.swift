//
//  FirestoreService.swift
//  MissU
//
//  Created by Robert Zhao on 2025-12-29.
//

import Foundation
import FirebaseFirestore

class FirestoreService {

    private let db = Firestore.firestore()

    // Write a record
    // ownderId is required by firestore
    func upload(record: LoveRecord, ownerId: String) {
        let data: [String: Any] = [
            "id": record.id.uuidString,
            "date": Timestamp(date: record.date),
            "latitude": record.latitude,
            "longitude": record.longitude,
            "placeName": record.placeName,
            "sender": record.sender.rawValue,
            "ownerId": ownerId
        ]

        db.collection("loveRecords").addDocument(data: data)
    }

    // Listen to record change on firebase
    func listen(ownerId: String,
                onUpdate: @escaping ([LoveRecord]) -> Void) {

        db.collection("loveRecords")
            .whereField("ownerId", isEqualTo: ownerId)
            .order(by: "date")
            .addSnapshotListener { snapshot, error in

                guard let documents = snapshot?.documents else { return }

                let records: [LoveRecord] = documents.compactMap { doc in
                    let data = doc.data()

                    guard
                        let date = (data["date"] as? Timestamp)?.dateValue(),
                        let latitude = data["latitude"] as? Double,
                        let longitude = data["longitude"] as? Double,
                        let place = data["placeName"] as? String,
                        let senderRaw = data["sender"] as? String,
                        let sender = Sender(rawValue: senderRaw)
                    else { return nil }

                    // Try to read UUID from Firestore; fall back to a new one if missing or invalid
                    let id: UUID
                    if let idString = data["id"] as? String, let parsed = UUID(uuidString: idString) {
                        id = parsed
                    } else {
                        id = UUID()
                    }

                    return LoveRecord(
                        id: id,
                        date: date,
                        latitude: latitude,
                        longitude: longitude,
                        placeName: place,
                        sender: sender
                    )
                }

                onUpdate(records)
            }
    }
}
