import Foundation
import NetworkExtension
import Combine

// MARK: - Models

struct ProxyNode: Identifiable {
    let id = UUID()
    var name: String
    var type: String // vmess, shadowsocks, socks5, http, trojan
    var server: String
    var port: Int
    var settings: [String: String]
}

struct ProxyRule: Identifiable {
    let id = UUID()
    var type: String // DOMAIN, DOMAIN-SUFFIX, DOMAIN-KEYWORD, IP-CIDR, GEOIP
    var value: String
    var proxy: String
}

// MARK: - Notifications

extension Notification.Name {
    static let startClashCore = Notification.Name("startClashCore")
    static let stopClashCore = Notification.Name("stopClashCore")
    static let clashConfigChanged = Notification.Name("clashConfigChanged")
}

// MARK: - ProxyManager

class ProxyManager: ObservableObject {
    @Published var isRunning: Bool = false
    @Published var nodes: [ProxyNode] = []
    @Published var rules: [ProxyRule] = []
    @Published var currentConfig: ClashConfig?
    @Published var configs: [ClashConfig] = []
    @Published var selectedConfig: ClashConfig?
    
    private var vpnManager: NETunnelProviderManager?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSampleData()
        setupVPNManager()
        observeNotifications()
    }
    
    // MARK: - VPN Management
    
    private func setupVPNManager() {
        NETunnelProviderManager.loadAllFromPreferences { [weak self] managers, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error loading VPN configurations: \(error.localizedDescription)")
                return
            }
            
            if let managers = managers, !managers.isEmpty {
                self.vpnManager = managers.first
            } else {
                self.createVPNManager()
            }
            
            self.updateStatus()
        }
    }
    
    private func createVPNManager() {
        let manager = NETunnelProviderManager()
        manager.localizedDescription = "iClash VPN"
        
        let proto = NETunnelProviderProtocol()
        proto.providerBundleIdentifier = "com.iclash.app.extension"
        proto.serverAddress = "localhost"
        manager.protocolConfiguration = proto
        
        manager.isEnabled = true
        
        manager.saveToPreferences { [weak self] error in
            if let error = error {
                print("Error saving VPN configuration: \(error.localizedDescription)")
                return
            }
            
            self?.vpnManager = manager
        }
    }
    
    private func updateStatus() {
        guard let vpnManager = vpnManager else { return }
        
        if let connection = vpnManager.connection as? NETunnelProviderSession {
            isRunning = connection.status == .connected || connection.status == .connecting
        } else {
            isRunning = false
        }
    }
    
    private func observeNotifications() {
        NotificationCenter.default.publisher(for: .NEVPNStatusDidChange)
            .sink { [weak self] _ in
                self?.updateStatus()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func startProxy() {
        guard let vpnManager = vpnManager,
              let connection = vpnManager.connection as? NETunnelProviderSession else {
            print("VPN manager not configured")
            return
        }
        
        do {
            try connection.startVPNTunnel()
            NotificationCenter.default.post(name: .startClashCore, object: nil)
        } catch {
            print("Error starting VPN: \(error.localizedDescription)")
        }
    }
    
    func stopProxy() {
        guard let vpnManager = vpnManager,
              let connection = vpnManager.connection as? NETunnelProviderSession else {
            return
        }
        
        connection.stopVPNTunnel()
        NotificationCenter.default.post(name: .stopClashCore, object: nil)
    }
    
    func addNode(_ node: ProxyNode) {
        nodes.append(node)
    }
    
    func deleteNode(_ node: ProxyNode) {
        if let index = nodes.firstIndex(where: { $0.id == node.id }) {
            nodes.remove(at: index)
        }
    }
    
    func addRule(_ rule: ProxyRule) {
        rules.append(rule)
    }
    
    func deleteRule(at index: Int) {
        rules.remove(at: index)
    }
    
    func moveRule(from source: IndexSet, to destination: Int) {
        rules.move(fromOffsets: source, toOffset: destination)
    }
    
    func testLatency(for node: ProxyNode, completion: @escaping (Double?) -> Void) {
        // Simulate latency test
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
            let latency = Double.random(in: 50...300)
            completion(latency)
        }
    }
    
    func addConfig(_ config: ClashConfig) {
        configs.append(config)
    }
    
    func applyConfig(_ config: ClashConfig) {
        self.currentConfig = config
        NotificationCenter.default.post(name: .clashConfigChanged, object: nil, userInfo: ["config": config])
    }
    
    // MARK: - Private Methods
    
    private func loadSampleData() {
        // Sample configurations
        let defaultConfig = ClashConfig(name: "Default Config", mode: "Rule", port: 7890, allowLan: false)
        configs = [defaultConfig]
        currentConfig = defaultConfig
        
        // Sample nodes
        nodes = [
            ProxyNode(name: "US Server", type: "vmess", server: "us.example.com", port: 443, settings: ["alterId": "64", "security": "auto"]),
            ProxyNode(name: "JP Server", type: "shadowsocks", server: "jp.example.com", port: 8388, settings: ["method": "aes-256-gcm", "password": "password"]),
            ProxyNode(name: "HK Server", type: "trojan", server: "hk.example.com", port: 443, settings: ["password": "password", "sni": "example.com"])
        ]
        
        // Sample rules
        rules = [
            ProxyRule(type: "DOMAIN-SUFFIX", value: "google.com", proxy: "US Server"),
            ProxyRule(type: "DOMAIN-KEYWORD", value: "facebook", proxy: "JP Server"),
            ProxyRule(type: "GEOIP", value: "CN", proxy: "DIRECT"),
            ProxyRule(type: "DOMAIN", value: "example.com", proxy: "DIRECT")
        ]
    }
}