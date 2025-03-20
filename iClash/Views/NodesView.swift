import SwiftUI

struct NodesView: View {
    @EnvironmentObject private var proxyManager: ProxyManager
    @State private var showingAddNode = false
    @State private var selectedNode: ProxyNode?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(proxyManager.nodes) { node in
                    NodeRow(node: node)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                proxyManager.deleteNode(node)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedNode = node
                        }
                }
                .onDelete(perform: deleteNodes)
            }
            .navigationTitle("Nodes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddNode = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddNode) {
                AddNodeView()
            }
            .sheet(item: $selectedNode) { node in
                NodeDetailView(node: node)
            }
        }
    }
    
    private func deleteNodes(at offsets: IndexSet) {
        // TODO: Implement node deletion
    }
}

struct NodeRow: View {
    let node: ProxyNode
    @State private var latency: Double?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(node.name)
                    .font(.headline)
                Spacer()
                if let latency = latency {
                    Text("\(Int(latency))ms")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text("\(node.type) - \(node.server):\(node.port)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct AddNodeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var proxyManager: ProxyManager
    
    @State private var name = ""
    @State private var type = "vmess"
    @State private var server = ""
    @State private var port = ""
    @State private var settings: [String: String] = [:]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Info")) {
                    TextField("Name", text: $name)
                    Picker("Type", selection: $type) {
                        Text("VMess").tag("vmess")
                        Text("Shadowsocks").tag("shadowsocks")
                        Text("SOCKS5").tag("socks5")
                        Text("HTTP").tag("http")
                        Text("Trojan").tag("trojan")
                    }
                    TextField("Server", text: $server)
                    TextField("Port", text: $port)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Settings")) {
                    ForEach(Array(settings.keys.sorted()), id: \.self) { key in
                        HStack {
                            Text(key)
                            Spacer()
                            Text(settings[key] ?? "")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Add Node")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    saveNode()
                    dismiss()
                }
                .disabled(name.isEmpty || server.isEmpty || port.isEmpty)
            )
        }
    }
    
    private func saveNode() {
        guard let portInt = Int(port) else { return }
        
        let node = ProxyNode(
            name: name,
            type: type,
            server: server,
            port: portInt,
            settings: settings
        )
        
        // TODO: Add node to proxyManager
    }
}

struct NodeDetailView: View {
    let node: ProxyNode
    @Environment(\.dismiss) private var dismiss
    @State private var isTestingLatency = false
    @State private var latency: Double?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Info")) {
                    LabeledContent("Name", value: node.name)
                    LabeledContent("Type", value: node.type)
                    LabeledContent("Server", value: node.server)
                    LabeledContent("Port", value: String(node.port))
                }
                
                Section(header: Text("Settings")) {
                    ForEach(Array(node.settings.keys.sorted()), id: \.self) { key in
                        LabeledContent(key, value: node.settings[key] ?? "")
                    }
                }
                
                Section {
                    Button(action: testLatency) {
                        HStack {
                            Text("Test Latency")
                            Spacer()
                            if isTestingLatency {
                                ProgressView()
                            } else if let latency = latency {
                                Text("\(Int(latency))ms")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .disabled(isTestingLatency)
                }
            }
            .navigationTitle("Node Details")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
    
    private func testLatency() {
        isTestingLatency = true
        proxyManager.testLatency(for: node) { [weak self] result in
            DispatchQueue.main.async {
                self?.latency = result
                self?.isTestingLatency = false
            }
        }
    }
}

#Preview {
    NodesView()
        .environmentObject(ProxyManager())
}