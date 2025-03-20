#!/bin/bash

# Create Xcode project
xcodegen generate

# Create necessary directories
mkdir -p iClash/App
mkdir -p iClash/Views
mkdir -p iClash/Managers
mkdir -p iClash/NetworkExtension

# Move files to their respective directories
mv iClashApp.swift iClash/App/
mv ContentView.swift iClash/Views/
mv HomeView.swift iClash/Views/
mv NodesView.swift iClash/Views/
mv RulesView.swift iClash/Views/
mv LogsView.swift iClash/Views/
mv ProxyManager.swift iClash/Managers/
mv ConfigManager.swift iClash/Managers/
mv PacketTunnelProvider.swift iClash/NetworkExtension/

# Create project.yml
cat > project.yml << EOL
name: iClash
options:
  bundleIdPrefix: com.iclash
  deploymentTarget:
    iOS: 15.0
    macOS: 12.0

targets:
  iClash:
    type: application
    platform: iOS
    sources:
      - path: iClash
    settings:
      base:
        INFOPLIST_FILE: iClash/Info.plist
        PRODUCT_BUNDLE_IDENTIFIER: com.iclash.app
    info:
      path: iClash/Info.plist
      properties:
        LSRequiresIPhoneOS: true
        UILaunchStoryboardName: LaunchScreen
        UIApplicationSceneManifest:
          UIApplicationSupportsMultipleScenes: false
          UISceneConfigurations:
            UIWindowSceneSessionRoleApplication:
              - UISceneConfigurationName: Default Configuration
                UISceneDelegateClassName: \$(PRODUCT_MODULE_NAME).SceneDelegate
        NSVPNUsageDescription: "iClash needs to create a VPN connection to manage your proxy settings."
        NSAppTransportSecurity:
          NSAllowsArbitraryLoads: true
    entitlements:
      path: iClash/iClash.entitlements
      properties:
        com.apple.security.application-groups:
          - group.com.iclash.app
        com.apple.developer.networking.vpn.api:
          - allow-vpn
          - allow-app-vpn
        com.apple.developer.networking.networkextension:
          - packet-tunnel-provider

  iClashExtension:
    type: app-extension
    platform: iOS
    sources:
      - path: iClash/NetworkExtension
    settings:
      base:
        INFOPLIST_FILE: iClash/NetworkExtension/Info.plist
        PRODUCT_BUNDLE_IDENTIFIER: com.iclash.app.extension
    info:
      path: iClash/NetworkExtension/Info.plist
      properties:
        NSExtension:
          NSExtensionPointIdentifier: com.apple.networkextension.packet-tunnel
          NSExtensionPrincipalClass: PacketTunnelProvider
    entitlements:
      path: iClash/NetworkExtension/iClashExtension.entitlements
      properties:
        com.apple.security.application-groups:
          - group.com.iclash.app
        com.apple.developer.networking.vpn.api:
          - allow-vpn
          - allow-app-vpn
        com.apple.developer.networking.networkextension:
          - packet-tunnel-provider
EOL

# Create Info.plist files
cat > iClash/Info.plist << EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>\$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleExecutable</key>
    <string>\$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>\$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>\$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>\$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UIApplicationSceneManifest</key>
    <dict>
        <key>UIApplicationSupportsMultipleScenes</key>
        <false/>
        <key>UISceneConfigurations</key>
        <dict>
            <key>UIWindowSceneSessionRoleApplication</key>
            <array>
                <dict>
                    <key>UISceneConfigurationName</key>
                    <string>Default Configuration</string>
                    <key>UISceneDelegateClassName</key>
                    <string>\$(PRODUCT_MODULE_NAME).SceneDelegate</string>
                </dict>
            </array>
        </dict>
    </dict>
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>armv7</string>
    </array>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>NSVPNUsageDescription</key>
    <string>iClash needs to create a VPN connection to manage your proxy settings.</string>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
</dict>
</plist>
EOL

cat > iClash/NetworkExtension/Info.plist << EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>\$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleExecutable</key>
    <string>\$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>\$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>\$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>\$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>NSExtension</key>
    <dict>
        <key>NSExtensionPointIdentifier</key>
        <string>com.apple.networkextension.packet-tunnel</string>
        <key>NSExtensionPrincipalClass</key>
        <string>PacketTunnelProvider</string>
    </dict>
</dict>
</plist>
EOL

# Create entitlements files
cat > iClash/iClash.entitlements << EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.iclash.app</string>
    </array>
    <key>com.apple.developer.networking.vpn.api</key>
    <array>
        <string>allow-vpn</string>
        <string>allow-app-vpn</string>
    </array>
    <key>com.apple.developer.networking.networkextension</key>
    <array>
        <string>packet-tunnel-provider</string>
    </array>
</dict>
</plist>
EOL

cat > iClash/NetworkExtension/iClashExtension.entitlements << EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.iclash.app</string>
    </array>
    <key>com.apple.developer.networking.vpn.api</key>
    <array>
        <string>allow-vpn</string>
        <string>allow-app-vpn</string>
    </array>
    <key>com.apple.developer.networking.networkextension</key>
    <array>
        <string>packet-tunnel-provider</string>
    </array>
</dict>
</plist>
EOL

# Make the script executable
chmod +x setup.sh

echo "Project setup complete! You can now open iClash.xcodeproj in Xcode." 