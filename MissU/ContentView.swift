//
//  ContentView.swift
//  MissU
//
//  Created by Robert Zhao on 2025-12-22.
//

import SwiftUI
import CoreLocation
import MapKit
import UserNotifications

// sender of the app (me, her)
enum Sender: String, Codable{
    case me
    case her
}


/////////////////////////////////////////////////////////////////////////////////////////////////////
// current app user (me or her)
// modify here to change the app version (boy or girl)
let currentUser: Sender = .her
/////////////////////////////////////////////////////////////////////////////////////////////////////

// record structure that will be saved on phone locally and on firebase
struct LoveRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    let latitude: Double
    let longitude: Double
    let placeName: String
    let sender: Sender
}

struct ContentView: View{
    
    // start date of the relationship
    let startDate = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 25))!
    
    let firestoreService = FirestoreService()
    
    // user id on fire store
    // place holder for fire store
    let currentUserId = "couple_001"
    
    // indicate whether showing history page
    @State private var showHistory = false
    
    // heat beat
    @State private var isBeating = false
    
    // add location manager
    @StateObject private var locationManager = LocationManager()
    @State private var records: [LoveRecord] = []
    
    @State private var lastHandleDate = loadLastHandledDate()
    
    var body: some View{
        
        NavigationStack{
            ZStack{
                // background
                Color(red: 1.0, green: 0.92, blue: 0.95).ignoresSafeArea()
                
                VStack(spacing: 30){
                    
                    VStack{
                        // day count display
                        Text("在一起第").font(.system(size: 35, weight: .bold))
                        
                        Text("\(daysTogether)").font(.system(size: 100, weight: .bold))
                        
                        Text("天").font(.system(size: 35, weight: .bold))
                    }.foregroundColor(.pink)
                        .padding(.top, 40)
                    
                    Spacer()
                    
                    /* heart button */
                    Button{
                        heartBeat()
                        locationManager.requestLocation()
                        recordMoment(sender: currentUser) // log current time, location
                        
                        print("miss you")
                    }
                    label:{
                        ZStack{
                            Image(systemName: "heart.fill")
                                .font(.system(size: 250))
                            
                            Text("想你了")
                                .foregroundColor(.white)
                                .font(.system(size:45, weight: .bold))
                        }
                        .foregroundColor(.pink)
                        .scaleEffect(isBeating ? 1.15 : 1.0)
                    }
                    
                    Spacer()
                    
                    // history button
                    NavigationLink{
                        HistoryView(records: records)
                    } label: {
                        Text("历史记录 >")
                            .foregroundColor(.pink)
                            .padding(.bottom, 20)
                            .font(.system(size: 25, weight: .bold))
                    }
                }
            }.onAppear{
                // request notification on the first use
                requestNotificationPermission()
                records = loadRecords()
                
                /* syns with cloud and notify locally whenever there is new record */
                firestoreService.listen(ownerId: currentUserId){ cloudRecords in
                    // find new records
                    let newRecords = cloudRecords.filter{
                        $0.date > lastHandleDate && $0.sender != currentUser
                    }
                    
                    // send notification for these new records
                    for record in newRecords{
                        // display location as content of the notification
                        sendLocalNotification(title: "❤️ ta 想你了", body: "在 \(record.placeName) 想起了你")
                    }
                    
                    // update last handle date
                    if let newestDate = cloudRecords.map(\.date).max(){
                        lastHandleDate = newestDate
                        saveLastHandledDate(newestDate)
                    }
                    
                    // update local storage with cloud storage
                    records = cloudRecords
                    saveRecords(records)
                    
                }
            }
        }
    }
    
    // calculate days together
    var daysTogether: Int{
        let days = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        return days
    }
    
    // heart beat effect function
    func heartBeat(){
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        
        withAnimation(.easeIn(duration: 0.15)){
            isBeating = true
        }
        generator.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15){
            withAnimation(.easeOut(duration: 0.15)){
                isBeating = false
            }
        }
    }
    
    // record function
    func recordMoment(sender: Sender){
        let now = Date() // fetch current date
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            // fetch location
            if let location = locationManager.location{
                // record the current latitude and longitude
                let lat = location.coordinate.latitude
                let lon = location.coordinate.longitude
                
                // using built in function to find the place name
                reverseGeocode(latitude: lat, longitude: lon){ place in
                    let record = LoveRecord(id: UUID(), date: now, latitude: lat, longitude: lon, placeName: place, sender: sender)
                    
                    records.append(record)
                    saveRecords(records)
                    
                    firestoreService.upload(record: record, ownerId: currentUserId)
                    
                    // print on console, not on UI
                    print("time: ", now)
                    print("location: ", place)
                }
            }
            else{
                print("failed to retrieve location")
            }
        }
    }
    
    // request notification
    func requestNotificationPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    print("通知权限已授权")
                } else {
                    print("通知权限被拒绝")
                }
            }
    }

}

func reverseGeocode(latitude: Double, longitude: Double,
                    completion: @escaping (String) -> Void) {
    // Use Core Location's CLGeocoder on all iOS versions
    let geocoder = CLGeocoder()
    let location = CLLocation(latitude: latitude, longitude: longitude)
    geocoder.reverseGeocodeLocation(location) { placemarks, _ in
        if let placemark = placemarks?.first {
            let placeName =
                placemark.name ??
                placemark.locality ??
                "未知地点"
            completion(placeName)
        } else {
            completion("未知地点")
        }
    }
}

/* send local notification */
func sendLocalNotification(title: String, body: String) {

    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = .default   // sound and vibration

    // send 1 second after
    let trigger = UNTimeIntervalNotificationTrigger(
        timeInterval: 1,
        repeats: false
    )

    let identifier = UUID().uuidString
    let request = UNNotificationRequest(
        identifier: identifier,
        content: content,
        trigger: trigger
    )

    UNUserNotificationCenter.current().add(request)
}



#Preview {
    ContentView()
}
