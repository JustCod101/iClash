import SwiftUI

struct LogsView: View {
    @EnvironmentObject private var proxyManager: ProxyManager
    @State private var logs: [LogEntry] = []
    @State private var filterText = ""
    @State private var logLevel: LogLevel = .all
    
    var body: some View {
        NavigationView {
            VStack {
                // Filter bar
                HStack {
                    TextField("Filter logs", text: $filterText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Picker("Level", selection: $logLevel) {
                        ForEach(LogLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 100)
                }
                .padding(.horizontal)
                
                // Log list
                List {
                    ForEach(filteredLogs) { entry in
                        LogEntryRow(entry: entry)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Logs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: clearLogs) {
                        Image(systemName: "trash")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: shareLogs) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .onAppear {
                // Simulate some logs for preview
                if logs.isEmpty {
                    loadSampleLogs()
                }
            }
        }
    }
    
    private var filteredLogs: [LogEntry] {
        logs.filter { log in
            let matchesFilter = filterText.isEmpty || 
                log.message.localizedCaseInsensitiveContains(filterText)
            
            let matchesLevel = logLevel == .all || log.level == logLevel
            
            return matchesFilter && matchesLevel
        }
    }
    
    private func clearLogs() {
        logs.removeAll()
    }
    
    private func shareLogs() {
        // TODO: Implement log sharing functionality
    }
    
    private func loadSampleLogs() {
        logs = [
            LogEntry(timestamp: Date(), level: .info, message: "Proxy service started"),
            LogEntry(timestamp: Date().addingTimeInterval(-60), level: .debug, message: "Loaded configuration from user defaults"),
            LogEntry(timestamp: Date().addingTimeInterval(-120), level: .warning, message: "Connection attempt timed out"),
            LogEntry(timestamp: Date().addingTimeInterval(-180), level: .error, message: "Failed to establish connection to us.example.com"),
            LogEntry(timestamp: Date().addingTimeInterval(-240), level: .info, message: "Rule matched: google.com -> US Server"),
            LogEntry(timestamp: Date().addingTimeInterval(-300), level: .debug, message: "DNS cache hit for facebook.com"),
            LogEntry(timestamp: Date().addingTimeInterval(-360), level: .info, message: "New connection: 192.168.1.5:54321 -> twitter.com:443"),
        ]
    }
}

struct LogEntryRow: View {
    let entry: LogEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(entry.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(entry.level.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(entry.level.color.opacity(0.2))
                    .foregroundColor(entry.level.color)
                    .cornerRadius(4)
            }
            
            Text(entry.message)
                .font(.body)
                .lineLimit(3)
        }
        .padding(.vertical, 4)
    }
}

struct LogEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let level: LogLevel
    let message: String
}

enum LogLevel: String, CaseIterable {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARN"
    case error = "ERROR"
    case all = "ALL"
    
    var color: Color {
        switch self {
        case .debug:
            return .gray
        case .info:
            return .blue
        case .warning:
            return .orange
        case .error:
            return .red
        case .all:
            return .primary
        }
    }
}

#Preview {
    LogsView()
        .environmentObject(ProxyManager())
} 