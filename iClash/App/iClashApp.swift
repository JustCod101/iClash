import SwiftUI

@main
struct iClashApp: App {
    @StateObject private var proxyManager = ProxyManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(proxyManager)
        }
    }
} 