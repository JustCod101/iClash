import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var proxyManager: ProxyManager
    @State private var showingConfigSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Status Card
                VStack {
                    HStack {
                        Circle()
                            .fill(proxyManager.isRunning ? Color.green : Color.red)
                            .frame(width: 12, height: 12)
                        Text(proxyManager.isRunning ? "Connected" : "Disconnected")
                            .font(.headline)
                    }
                    
                    if let config = proxyManager.currentConfig {
                        Text("Mode: \(config.mode)")
                            .font(.subheadline)
                        Text("Port: \(config.port)")
                            .font(.subheadline)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
                
                // Quick Actions
                HStack(spacing: 20) {
                    Button(action: {
                        if proxyManager.isRunning {
                            proxyManager.stopProxy()
                        } else {
                            proxyManager.startProxy()
                        }
                    }) {
                        VStack {
                            Image(systemName: proxyManager.isRunning ? "stop.fill" : "play.fill")
                                .font(.title)
                            Text(proxyManager.isRunning ? "Stop" : "Start")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                    
                    Button(action: { showingConfigSheet = true }) {
                        VStack {
                            Image(systemName: "gear")
                                .font(.title)
                            Text("Config")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                }
                
                // Stats
                VStack(alignment: .leading, spacing: 10) {
                    Text("Statistics")
                        .font(.headline)
                    
                    HStack {
                        StatView(title: "Upload", value: "0 MB/s")
                        StatView(title: "Download", value: "0 MB/s")
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
                
                Spacer()
            }
            .padding()
            .navigationTitle("iClash")
            .sheet(isPresented: $showingConfigSheet) {
                ConfigView()
            }
        }
    }
}

struct StatView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    HomeView()
        .environmentObject(ProxyManager())
} 