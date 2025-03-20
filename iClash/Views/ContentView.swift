import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var proxyManager: ProxyManager
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            NodesView()
                .tabItem {
                    Label("Nodes", systemImage: "network")
                }
            
            RulesView()
                .tabItem {
                    Label("Rules", systemImage: "list.bullet")
                }
            
            LogsView()
                .tabItem {
                    Label("Logs", systemImage: "doc.text.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ProxyManager())
} 