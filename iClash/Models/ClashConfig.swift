import Foundation

// MARK: - ClashConfig Model

struct ClashConfig: Codable, Identifiable, Equatable {
    let id = UUID()
    var name: String
    var mode: String // Global, Rule, Direct
    var port: Int
    var allowLan: Bool
    var externalController: String?
    var secret: String?
    
    // Proxy collections
    var proxies: [ProxyNode] = []
    var rules: [ProxyRule] = []
    var proxyGroups: [ProxyGroup] = []
    
    init(name: String = "Default", mode: String = "Rule", port: Int = 7890, allowLan: Bool = false) {
        self.name = name
        self.mode = mode
        self.port = port
        self.allowLan = allowLan
    }
    
    // Adding a custom coding keys enum to support YAML format
    enum CodingKeys: String, CodingKey {
        case name
        case mode
        case port
        case allowLan = "allow-lan"
        case externalController = "external-controller"
        case secret
        case proxies
        case rules
        case proxyGroups = "proxy-groups"
    }
    
    // Implementing Equatable to compare configs
    static func == (lhs: ClashConfig, rhs: ClashConfig) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - ProxyGroup
struct ProxyGroup: Codable, Identifiable, Equatable {
    let id = UUID()
    var name: String
    var type: String
    var proxies: [String]
    
    enum CodingKeys: String, CodingKey {
        case name, type, proxies
    }
    
    static func == (lhs: ProxyGroup, rhs: ProxyGroup) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - YAML Helpers

// These helper functions can be used for YAML serialization/deserialization
extension ClashConfig {
    func toYAML() -> String {
        var yaml = "# iClash Configuration\n\n"
        
        yaml += "name: \(name)\n"
        yaml += "port: \(port)\n"
        yaml += "mode: \(mode.lowercased())\n"
        yaml += "allow-lan: \(allowLan)\n"
        
        if let externalController = externalController {
            yaml += "external-controller: \(externalController)\n"
            
            if let secret = secret {
                yaml += "secret: \(secret)\n"
            }
        }
        
        // Add proxies section if needed
        if !proxies.isEmpty {
            yaml += "\nproxies:\n"
            for proxy in proxies {
                yaml += "  - name: \(proxy.name)\n"
                yaml += "    type: \(proxy.type)\n"
                yaml += "    server: \(proxy.server)\n"
                yaml += "    port: \(proxy.port)\n"
                
                for (key, value) in proxy.settings {
                    yaml += "    \(key): \(value)\n"
                }
            }
        }
        
        // Add proxy groups if needed
        if !proxyGroups.isEmpty {
            yaml += "\nproxy-groups:\n"
            for group in proxyGroups {
                yaml += "  - name: \(group.name)\n"
                yaml += "    type: \(group.type)\n"
                yaml += "    proxies:\n"
                for proxy in group.proxies {
                    yaml += "      - \(proxy)\n"
                }
            }
        }
        
        // Add rules section if needed
        if !rules.isEmpty {
            yaml += "\nrules:\n"
            for rule in rules {
                yaml += "  - \(rule.type),\(rule.value),\(rule.proxy)\n"
            }
        }
        
        return yaml
    }
    
    static func fromYAML(_ yaml: String) throws -> ClashConfig {
        // A simple YAML parser implementation
        var configName = "Imported Config"
        var mode = "Rule"
        var port = 7890
        var allowLan = false
        var externalController: String?
        var secret: String?
        
        // Extract values using simple parsing
        let lines = yaml.components(separatedBy: .newlines)
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.hasPrefix("name: ") {
                configName = String(trimmedLine.dropFirst(6).trimmingCharacters(in: .whitespaces))
            } else if trimmedLine.hasPrefix("port: ") {
                let portStr = trimmedLine.dropFirst(6).trimmingCharacters(in: .whitespaces)
                port = Int(portStr) ?? 7890
            } else if trimmedLine.hasPrefix("mode: ") {
                let modeStr = trimmedLine.dropFirst(6).trimmingCharacters(in: .whitespaces)
                mode = modeStr.capitalized
            } else if trimmedLine.hasPrefix("allow-lan: ") {
                let allowLanStr = trimmedLine.dropFirst(11).trimmingCharacters(in: .whitespaces)
                allowLan = allowLanStr == "true"
            } else if trimmedLine.hasPrefix("external-controller: ") {
                externalController = String(trimmedLine.dropFirst(20).trimmingCharacters(in: .whitespaces))
            } else if trimmedLine.hasPrefix("secret: ") {
                secret = String(trimmedLine.dropFirst(8).trimmingCharacters(in: .whitespaces))
            }
        }
        
        var config = ClashConfig(name: configName, mode: mode, port: port, allowLan: allowLan)
        config.externalController = externalController
        config.secret = secret
        
        // Parsing proxies, proxy groups and rules would require more sophisticated parsing
        // which is beyond the scope of this simple implementation
        
        return config
    }
} 