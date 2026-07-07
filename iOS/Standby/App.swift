import SwiftUI

@main
struct StandbyApp: App {
    @StateObject private var store = Store()
    @StateObject private var purchases = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(purchases)
                .task {
                    await purchases.refreshStatus()
                    store.isPro = purchases.isPurchased
                }
                .onChange(of: purchases.isPurchased) { _, newValue in
                    store.isPro = newValue
                }
                .tint(Theme.accent)
        }
    }
}
