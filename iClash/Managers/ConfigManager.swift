import Foundation

class ConfigManager {
    static let shared = ConfigManager()
    
    private let fileManager = FileManager.default
    private let configDirectory: URL
    
    init() {
        // Get the app group container directory
        if let groupContainerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.iclash.app") {
            configDirectory = groupContainerURL.appendingPathComponent("configs", isDirectory: true)
        } else {
            // Fallback to documents directory
            configDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("configs", isDirectory: true)
        }
        
        // Create directory if it doesn't exist
        try? fileManager.createDirectory(at: configDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Public Methods
    
    func saveConfig(_ config: ClashConfig) throws -> URL {
        // Create filename
        let filename = "\(config.name.lowercased().replacingOccurrences(of: " ", with: "_")).yaml"
        let fileURL = configDirectory.appendingPathComponent(filename)
        
        // Generate YAML content
        let yamlContent = config.toYAML()
        
        // Write to file
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        return fileURL
    }
    
    func loadConfig(from url: URL) throws -> ClashConfig {
        // Read YAML content
        let yamlContent = try String(contentsOf: url, encoding: .utf8)
        
        // Parse YAML content
        return try ClashConfig.fromYAML(yamlContent)
    }
    
    func allConfigs() -> [URL] {
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: configDirectory, includingPropertiesForKeys: nil)
            return fileURLs.filter { $0.pathExtension == "yaml" }
        } catch {
            print("Error listing config files: \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteConfig(at url: URL) throws {
        try fileManager.removeItem(at: url)
    }
    
    func importConfig(from url: URL, completion: @escaping (Result<ClashConfig, Error>) -> Void) {
        // Download and parse remote config
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let yamlContent = String(data: data, encoding: .utf8) else {
                completion(.failure(NSError(domain: "ConfigManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid data"])))
                return
            }
            
            do {
                let config = try ClashConfig.fromYAML(yamlContent)
                completion(.success(config))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

// MARK: - YAML Encoding/Decoding
struct YAMLEncoder {
    func encode(_ config: ClashConfig) throws -> String {
        var yaml = """
        port: \(config.port)
        allow-lan: \(config.allowLan)
        mode: \(config.mode)
        
        proxies:
        """
        
        for proxy in config.proxies {
            yaml += "\n  - name: \(proxy.name)"
            yaml += "\n    type: \(proxy.type)"
            yaml += "\n    server: \(proxy.server)"
            yaml += "\n    port: \(proxy.port)"
            
            for (key, value) in proxy.settings {
                yaml += "\n    \(key): \(value)"
            }
        }
        
        yaml += "\n\nrules:"
        for rule in config.rules {
            yaml += "\n  - \(rule.type),\(rule.value),\(rule.proxy)"
        }
        
        return yaml
    }
}

struct YAMLDecoder {
    func decode(_ type: ClashConfig.Type, from yaml: String) throws -> ClashConfig {
        // TODO: Implement YAML parsing
        // For now, return a default configuration
        return ClashConfig(
            port: 7890,
            allowLan: true,
            mode: "rule",
            proxies: [],
            rules: []
        )
    }
}

public struct ClashConfig: Codable {
    public let proxies: [String: ProxyNode]
    public let rules: [String]
    public let proxyGroups: [ProxyGroup]
    
    public enum CodingKeys: String, CodingKey {
        case proxies
        case rules
        case proxyGroups = "proxy-groups"
    }
}

struct ProxyGroup: Codable {
    let name: String
    let type: String
    let proxies: [String]
}