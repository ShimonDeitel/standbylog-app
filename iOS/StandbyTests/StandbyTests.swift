import XCTest
@testable import Standby

@MainActor
final class StandbyTests: XCTestCase {
    var store: Store!

    override func setUp() {
        super.setUp()
        store = Store()
        store.items = []
        store.save()
    }

    func testAddIncreasesCount() {
        let before = store.items.count
        _ = store.add(Item(field1: "Test", field2: "Value", status: Status.all[0]))
        XCTAssertEqual(store.items.count, before + 1)
    }

    func testAddRespectsFreeLimit() {
        for i in 0..<store.freeLimit {
            _ = store.add(Item(field1: "Item \(i)", field2: "x", status: Status.all[0]))
        }
        let result = store.add(Item(field1: "Overflow", field2: "x", status: Status.all[0]))
        XCTAssertFalse(result)
        XCTAssertEqual(store.items.count, store.freeLimit)
    }

    func testIsAtFreeLimitTrueWhenFull() {
        for i in 0..<store.freeLimit {
            _ = store.add(Item(field1: "Item \(i)", field2: "x", status: Status.all[0]))
        }
        XCTAssertTrue(store.isAtFreeLimit)
    }

    func testProBypassesFreeLimit() {
        store.isPro = true
        for i in 0..<(store.freeLimit + 5) {
            _ = store.add(Item(field1: "Item \(i)", field2: "x", status: Status.all[0]))
        }
        XCTAssertEqual(store.items.count, store.freeLimit + 5)
    }

    func testDeleteRemovesItem() {
        _ = store.add(Item(field1: "ToDelete", field2: "x", status: Status.all[0]))
        let item = store.items.first!
        store.delete(item)
        XCTAssertFalse(store.items.contains(where: { $0.id == item.id }))
    }

    func testUpdateModifiesItem() {
        _ = store.add(Item(field1: "Orig", field2: "x", status: Status.all[0]))
        var item = store.items.first!
        item.field1 = "Updated"
        store.update(item)
        XCTAssertEqual(store.items.first?.field1, "Updated")
    }

    func testSeedDataBelowFreeLimit() {
        XCTAssertLessThan(store.items.count, store.freeLimit)
    }
}
