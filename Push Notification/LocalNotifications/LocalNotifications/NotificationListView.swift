//
// Created for LocalNotifications
// by Stewart Lynch on 2022-05-22
// Using Swift 5.0
//
// Follow me on Twitter: @StewartLynch
// Subscribe on YouTube: https://youTube.com/StewartLynch
//

import SwiftUI

struct NotificationListView: View {
    @EnvironmentObject var lnManager: LocalNotificationManager
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        NavigationView {
            VStack {
                if(lnManager.isGranted){
                    GroupBox("Schedule") {
                        Button("Interval Notification") {
                            Task {
                                let localNotification = LocalNotification(identifier: UUID().uuidString, title: "Some Title", body: "Some Body", timeInterval: 60, repeats: true)
                                await lnManager.schedule(localNotification: localNotification)
                            }
                        }
                        .buttonStyle(.bordered)
                        Button("Calendar Notification") {
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(width: 300)
                    // List View Here
                    
                    List {
                        ForEach(lnManager.pendingRequest, id: \.identifier) { request in
                            VStack(alignment: .leading){
                                Text(request.content.title)
                                HStack{
                                    Text(request.identifier)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .swipeActions {
                                Button("Delete", role: .destructive){
                                    lnManager.removeRequest(withIdentifier: request.identifier)
                                }
                                
                            }
                                   
                            
                        }
                    }
                    
                }
                else {
                    Button("Enable Notification"){
                        lnManager.openSettings()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Local Notifications")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        lnManager.clearAllRequests()
                    } label: {
                        Image(systemName: "clear.fill")
                            .imageScale(.large)
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .task {
            try? await lnManager.requestAuthorization()
        }
        .onChange(of: scenePhase) { newValue in
            if newValue == .active {
                Task {
                    try? await lnManager.requestAuthorization()
                    await lnManager.getPendingRequeest()
                }
            }
//            switch newValue {
//            case .active:
//                print("App is active")
//            case .inactive:
//                print("App is inactive")
//            case .background:
//                print("App is in background")
//            @unknown default:
//                print("Unexpected scene phase")
//            }
        }
    }
}

struct NotificationListView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationListView()
            .environmentObject(LocalNotificationManager())
    }
}
