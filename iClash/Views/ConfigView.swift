import SwiftUI

struct ConfigView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var proxyManager: ProxyManager
    
    @State private var selectedConfig: ClashConfig?
    @State private var showingAddConfig = false
    @State private var showingImportSheet = false
    @State private var importURL = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Current Configuration")) {
                    if let config = proxyManager.currentConfig {
                        ConfigRow(config: config, isActive: true)
                    } else {
                        Text("No active configuration")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Available Configurations")) {
                    ForEach(proxyManager.configs) { config in
                        ConfigRow(config: config, isActive: config.id == proxyManager.currentConfig?.id)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedConfig = config
                            }
                    }
                    .onDelete(perform: deleteConfigs)
                }
                
                Section {
                    Button(action: { showingAddConfig = true }) {
                        Label("Add Configuration", systemImage: "plus")
                    }
                    
                    Button(action: { showingImportSheet = true }) {
                        Label("Import from URL", systemImage: "square.and.arrow.down")
                    }
                }
            }
            .navigationTitle("Configurations")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddConfig) {
                AddConfigView()
            }
            .sheet(isPresented: $showingImportSheet) {
                ImportConfigView()
            }
            .sheet(item: $selectedConfig) { config in
                ConfigDetailView(config: config)
            }
        }
    }
    
    private func deleteConfigs(at offsets: IndexSet) {
        proxyManager.configs.remove(atOffsets: offsets)
    }
}

struct ConfigRow: View {
    let config: ClashConfig
    let isActive: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(config.name)
                    .font(.headline)
                HStack {
                    Text("Mode: \(config.mode)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Port: \(config.port)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if isActive {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddConfigView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var proxyManager: ProxyManager
    
    @State private var name = ""
    @State private var mode = "Rule"
    @State private var port = "7890"
    @State private var allowLan = false
    
    let modes = ["Global", "Rule", "Direct"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Settings")) {
                    TextField("Name", text: $name)
                    
                    Picker("Mode", selection: $mode) {
                        ForEach(modes, id: \.self) { mode in
                            Text(mode).tag(mode)
                        }
                    }
                    
                    TextField("Port", text: $port)
                        .keyboardType(.numberPad)
                    
                    Toggle("Allow LAN", isOn: $allowLan)
                }
            }
            .navigationTitle("Add Configuration")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    saveConfig()
                    dismiss()
                }
                .disabled(name.isEmpty || port.isEmpty)
            )
        }
    }
    
    private func saveConfig() {
        guard let portInt = Int(port) else { return }
        
        let config = ClashConfig(
            name: name,
            mode: mode,
            port: portInt,
            allowLan: allowLan
        )
        
        proxyManager.addConfig(config)
    }
}

struct ImportConfigView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var proxyManager: ProxyManager
    
    @State private var url = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Configuration URL")) {
                    TextField("https://example.com/config.yaml", text: $url)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button(action: importConfig) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Import")
                                .bold()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(url.isEmpty || isLoading)
                }
            }
            .navigationTitle("Import Configuration")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() }
            )
        }
    }
    
    private func importConfig() {
        guard !url.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        guard let urlObj = URL(string: url) else {
            errorMessage = "Invalid URL. Please check and try again."
            isLoading = false
            return
        }
        
        ConfigManager.shared.importConfig(from: urlObj) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let config):
                    self.proxyManager.addConfig(config)
                    self.dismiss()
                case .failure(let error):
                    self.errorMessage = "Error importing config: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct ConfigDetailView: View {
    let config: ClashConfig
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var proxyManager: ProxyManager
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Settings")) {
                    LabeledContent("Name", value: config.name)
                    LabeledContent("Mode", value: config.mode)
                    LabeledContent("Port", value: "\(config.port)")
                    LabeledContent("Allow LAN", value: config.allowLan ? "Yes" : "No")
                }
                
                if let externalController = config.externalController {
                    Section(header: Text("External Controller")) {
                        LabeledContent("URL", value: externalController)
                        if let secret = config.secret {
                            LabeledContent("Secret", value: secret)
                        }
                    }
                }
                
                Section {
                    Button(action: applyConfig) {
                        Text("Apply Configuration")
                            .bold()
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(config.id == proxyManager.currentConfig?.id)
                }
            }
            .navigationTitle("Configuration Details")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
    
    private func applyConfig() {
        proxyManager.applyConfig(config)
        dismiss()
    }
}

#Preview {
    ConfigView()
        .environmentObject(ProxyManager())
} 