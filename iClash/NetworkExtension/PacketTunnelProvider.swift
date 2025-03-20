import NetworkExtension
import Foundation

// Define notification names for the network extension
extension Notification.Name {
    static let startClashCore = Notification.Name("startClashCore")
    static let stopClashCore = Notification.Name("stopClashCore")
    static let clashConfigChanged = Notification.Name("clashConfigChanged")
}

class PacketTunnelProvider: NEPacketTunnelProvider {
    private var clashProcess: Any? // Using Any instead of Process since it's not directly available
    
    override func startTunnel(options: [String: NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        // Set up tunnel settings
        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "127.0.0.1")
        
        // Configure DNS settings
        let dnsSettings = NEDNSSettings(servers: ["8.8.8.8", "8.8.4.4"])
        dnsSettings.matchDomains = [""]
        networkSettings.dnsSettings = dnsSettings
        
        // Configure IPv4 settings
        let ipv4Settings = NEIPv4Settings(addresses: ["192.168.255.1"], subnetMasks: ["255.255.255.0"])
        ipv4Settings.includedRoutes = [NEIPv4Route.default()]
        networkSettings.ipv4Settings = ipv4Settings
        
        // Set the network settings
        setTunnelNetworkSettings(networkSettings) { error in
            if let error = error {
                NSLog("Failed to set tunnel network settings: \(error.localizedDescription)")
                completionHandler(error)
                return
            }
            
            // Start the Clash core
            self.startClashCore()
            
            // Setup observation for notifications
            self.observeNotifications()
            
            completionHandler(nil)
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Stop the Clash core
        stopClashCore()
        
        // Call completion handler
        completionHandler()
    }
    
    // MARK: - Clash Core Management
    
    private func startClashCore() {
        NSLog("Starting Clash core")
        
        guard clashProcess == nil else {
            NSLog("Clash core is already running")
            return
        }
        
        // Create a custom class to handle process management
        // since Process is not available in Network Extensions
        let processManager = ClashProcessManager()
        
        // In a real app, you would set the path to your embedded Clash binary
        // For this example, we'll just log the attempt
        NSLog("Would start Clash core with current configuration")
        
        // Store reference to the process
        clashProcess = processManager
    }
    
    private func stopClashCore() {
        NSLog("Stopping Clash core")
        
        guard clashProcess != nil else {
            NSLog("Clash core is not running")
            return
        }
        
        // Since we're not using actual Process, just log action
        NSLog("Terminating Clash core")
        
        // Clear reference
        clashProcess = nil
    }
    
    private func observeNotifications() {
        NotificationCenter.default.addObserver(
            forName: .stopClashCore,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            self?.stopClashCore()
        }
        
        NotificationCenter.default.addObserver(
            forName: .clashConfigChanged,
            object: nil,
            queue: nil
        ) { [weak self] notification in
            // Restart Clash with new configuration
            self?.stopClashCore()
            self?.startClashCore()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// A simple class to manage Clash process since Process is not available
class ClashProcessManager {
    private var isRunning = false
    
    func start() {
        isRunning = true
    }
    
    func terminate() {
        isRunning = false
    }
    
    var running: Bool {
        return isRunning
    }
}

// Simple version of ProxyServer for the PacketTunnelProvider
class ProxyServer {
    // We don't need the full ClashConfig here, just use Any to avoid importing the model
    private let config: Any
    
    init(config: Any) {
        self.config = config
    }
    
    func start() {
        // Start Clash core with configuration
    }
    
    func stop() {
        // Stop Clash core process
        NotificationCenter.default.post(name: .stopClashCore, object: nil)
        // Release network resources
        URLSession.shared.invalidateAndCancel()
    }
}
