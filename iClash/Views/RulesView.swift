import SwiftUI

struct RulesView: View {
    @EnvironmentObject private var proxyManager: ProxyManager
    @State private var showingAddRule = false
    @State private var selectedRule: ProxyRule?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(proxyManager.rules) { rule in
                    RuleRow(rule: rule)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedRule = rule
                        }
                }
                .onDelete(perform: deleteRules)
                .onMove(perform: moveRules)
            }
            .navigationTitle("Rules")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddRule = true }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingAddRule) {
                AddRuleView()
            }
            .sheet(item: $selectedRule) { rule in
                RuleDetailView(rule: rule)
            }
        }
    }
    
    private func deleteRules(at offsets: IndexSet) {
        // TODO: Implement rule deletion
    }
    
    private func moveRules(from source: IndexSet, to destination: Int) {
        // TODO: Implement rule reordering
    }
}

struct RuleRow: View {
    let rule: ProxyRule
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(rule.type)
                    .font(.headline)
                Spacer()
                Text(rule.proxy)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(rule.value)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct AddRuleView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var proxyManager: ProxyManager
    
    @State private var type = "DOMAIN"
    @State private var value = ""
    @State private var proxy = "DIRECT"
    
    let ruleTypes = ["DOMAIN", "DOMAIN-SUFFIX", "DOMAIN-KEYWORD", "IP-CIDR", "GEOIP"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Rule Info")) {
                    Picker("Type", selection: $type) {
                        ForEach(ruleTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    
                    TextField("Value", text: $value)
                    
                    Picker("Proxy", selection: $proxy) {
                        Text("DIRECT").tag("DIRECT")
                        Text("REJECT").tag("REJECT")
                        ForEach(proxyManager.nodes) { node in
                            Text(node.name).tag(node.name)
                        }
                    }
                }
            }
            .navigationTitle("Add Rule")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    saveRule()
                    dismiss()
                }
                .disabled(value.isEmpty)
            )
        }
    }
    
    private func saveRule() {
        let rule = ProxyRule(
            type: type,
            value: value,
            proxy: proxy
        )
        
        // TODO: Add rule to proxyManager
    }
}

struct RuleDetailView: View {
    let rule: ProxyRule
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Rule Info")) {
                    LabeledContent("Type", value: rule.type)
                    LabeledContent("Value", value: rule.value)
                    LabeledContent("Proxy", value: rule.proxy)
                }
            }
            .navigationTitle("Rule Details")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

#Preview {
    RulesView()
        .environmentObject(ProxyManager())
} 