import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showAddSheet = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var editingItem: Item?

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.items) { item in
                    Button {
                        editingItem = item
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(item.field1)
                                    .font(Theme.bodyFont.weight(.semibold))
                                    .foregroundStyle(Theme.textPrimary)
                                Spacer()
                                Text(item.status)
                                    .font(Theme.captionFont)
                                    .padding(.horizontal, 8).padding(.vertical, 3)
                                    .background(Theme.statusColor(item.status).opacity(0.2))
                                    .foregroundStyle(Theme.statusColor(item.status))
                                    .clipShape(Capsule())
                            }
                            Text(item.field2)
                                .font(Theme.captionFont)
                                .foregroundStyle(Theme.textPrimary.opacity(0.7))
                        }
                        .padding(.vertical, 4)
                    }
                    .accessibilityIdentifier("itemRow_\(item.field1)")
                }
                .onDelete { store.delete(at: $0) }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Standby")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.isAtFreeLimit {
                            showPaywall = true
                        } else {
                            showAddSheet = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showAddSheet) {
                ItemEditView(item: nil)
            }
            .sheet(item: $editingItem) { item in
                ItemEditView(item: item)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView().environmentObject(purchases)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView().environmentObject(purchases)
            }
        }
    }
}

struct ItemEditView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    let item: Item?

    @State private var field1: String = ""
    @State private var field2: String = ""
    @State private var status: String = Status.all.first ?? ""
    @State private var notes: String = ""
    @FocusState private var focusedField: Field?

    enum Field { case f1, f2, notes }

    var body: some View {
        NavigationStack {
            Form {
                Section("Date/Window") {
                    TextField("Date/Window", text: $field1)
                        .focused($focusedField, equals: .f1)
                        .accessibilityIdentifier("field1TextField")
                }
                Section("Callout count") {
                    TextField("Callout count", text: $field2)
                        .focused($focusedField, equals: .f2)
                        .accessibilityIdentifier("field2TextField")
                }
                Section("Status") {
                    Picker("Status", selection: $status) {
                        ForEach(Status.all, id: \.self) { Text($0).tag($0) }
                    }
                    .accessibilityIdentifier("statusPicker")
                }
                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .focused($focusedField, equals: .notes)
                        .accessibilityIdentifier("notesTextField")
                }
                if item != nil {
                    Section {
                        Button("Delete", role: .destructive) {
                            store.delete(item!)
                            dismiss()
                        }
                        .accessibilityIdentifier("deleteItemButton")
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
            .navigationTitle(item == nil ? "Add" : "Edit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelEditButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var newItem = item ?? Item(field1: "", field2: "", status: status)
                        newItem.field1 = field1
                        newItem.field2 = field2
                        newItem.status = status
                        newItem.notes = notes
                        if item == nil {
                            _ = store.add(newItem)
                        } else {
                            store.update(newItem)
                        }
                        dismiss()
                    }
                    .accessibilityIdentifier("saveItemButton")
                    .disabled(field1.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let item {
                    field1 = item.field1
                    field2 = item.field2
                    status = item.status
                    notes = item.notes
                }
            }
        }
    }
}
