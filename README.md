# iClash

iClash is an open-source Clash proxy manager for iOS and macOS, built with SwiftUI. It provides a modern and user-friendly interface for managing Clash proxy configurations.

## Features

- Support for multiple proxy protocols:
  - VMess
  - Shadowsocks
  - SOCKS5
  - HTTP
  - Trojan

- Rule-based traffic routing:
  - GEOIP rules
  - Domain filters
  - Manual rules

- Subscription-based configuration updates
- Background VPN management
- Real-time proxy statistics
- Detailed traffic logs

## Requirements

- iOS 15.0+ / macOS 12.0+
- Xcode 13.0+
- Swift 5.5+

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/iClash.git
```

2. Open the project in Xcode:
```bash
cd iClash
open iClash.xcodeproj
```

3. Build and run the project.

## Project Structure

```
iClash/
├── App/
│   └── iClashApp.swift
├── Views/
│   ├── ContentView.swift
│   ├── HomeView.swift
│   ├── NodesView.swift
│   ├── RulesView.swift
│   └── LogsView.swift
├── Managers/
│   ├── ProxyManager.swift
│   └── ConfigManager.swift
└── NetworkExtension/
    └── PacketTunnelProvider.swift
```

## Development

### Building

1. Open the project in Xcode
2. Select your target device/simulator
3. Click the Run button or press Cmd+R

### Testing

The project includes unit tests and UI tests. To run the tests:

1. Open the Test navigator (Cmd+6)
2. Click the Run button next to the test suite

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [Clash](https://github.com/Dreamacro/clash) - A rule-based tunnel in Go
- [SwiftUI](https://developer.apple.com/xcode/swiftui/) - Apple's modern UI framework 