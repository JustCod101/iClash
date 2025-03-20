import Foundation

// MARK: - ProxyNode

struct ProxyNode: Identifiable, Codable, Equatable {
    let id = UUID()
    var name: String
    var type: String // vmess, shadowsocks, socks5, http, trojan
    var server: String
    var port: Int
    var settings: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case id, name, type, server, port, settings
    }
    
    static func == (lhs: ProxyNode, rhs: ProxyNode) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - ProxyRule

struct ProxyRule: Identifiable, Codable, Equatable {
    let id = UUID()
    var type: String // DOMAIN, DOMAIN-SUFFIX, DOMAIN-KEYWORD, IP-CIDR, GEOIP
    var value: String
    var proxy: String
    
    enum CodingKeys: String, CodingKey {
        case id, type, value, proxy
    }
    
    static func == (lhs: ProxyRule, rhs: ProxyRule) -> Bool {
        return lhs.id == rhs.id
    }
} 