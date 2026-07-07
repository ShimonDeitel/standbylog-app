import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    @Published var isPurchased: Bool = false
    static let productID = "com.shimondeitel.standbylog.pro.monthly"

    private var updateListenerTask: Task<Void, Never>?

    init() {
        updateListenerTask = listenForTransactions()
        Task { await refreshStatus() }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    func purchase() async {
        do {
            let products = try await Product.products(for: [Self.productID])
            guard let product = products.first else { return }
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    isPurchased = true
                }
            default:
                break
            }
        } catch {
            print("Purchase failed: \(error)")
        }
    }

    func restore() async {
        try? await AppStore.sync()
        await refreshStatus()
    }

    func refreshStatus() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == Self.productID {
                isPurchased = true
                return
            }
        }
        isPurchased = false
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self?.refreshStatus()
                }
            }
        }
    }
}
