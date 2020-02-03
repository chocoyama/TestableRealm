//
//  ContentView.swift
//  SwiftUI+Realm
//
//  Created by Takuya Yokoyama on 2020/02/03.
//  Copyright © 2020 Takuya Yokoyama. All rights reserved.
//

import SwiftUI
import RealmSwift

struct ContentView: View {
    @EnvironmentObject private var store: Store
    
    var body: some View {
        List {
            ForEach(0..<store.itemEntities.count) { index in
                if self.store.itemEntities[index].isInvalidated {
                    EmptyView()
                } else {
                    Text(self.store.itemEntities[index].name)
                }
            }
        }.onAppear {
            ItemEntity.setUp()
        }
    }
}

protocol ResultsWrapper {
    var count: Int { get }
    func observe(_ handler: @escaping () -> Void) -> NotificationToken
    subscript(index: Int) -> ItemEntity { get }
}

class ResultsWrapperImpl: ResultsWrapper {
    private let itemEntities: Results<ItemEntity>
    
    init(itemEntities: Results<ItemEntity>) {
        self.itemEntities = itemEntities
    }
    
    var count: Int { itemEntities.count }
    
    func observe(_ handler: @escaping () -> Void) -> NotificationToken {
        itemEntities.observe { _ in
            handler()
        }
    }
    
    subscript(index: Int) -> ItemEntity {
        get {
            itemEntities[index]
        }
    }
}

import Combine
class Store: ObservableObject {
    var objectWillChange: ObservableObjectPublisher = .init()
    private(set) var itemEntities: ResultsWrapper = ResultsWrapperImpl(itemEntities: ItemEntity.all())
    private var notificationTokens: [NotificationToken] = []
    
    init() {
        notificationTokens.append(itemEntities.observe {
            self.objectWillChange.send()
        })
    }
    
    deinit {
        notificationTokens.forEach {
            NotificationCenter.default.removeObserver($0)
        }
    }
}

class ItemEntity: Object, Identifiable {
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    
    override class func primaryKey() -> String? { "id" }
    override class func indexedProperties() -> [String] { ["id"] }
    
    private static var realm = try! Realm()
    
    static func setUp() {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (timer) in
            try! realm.write {
                print("### update \(Date())")
                realm.deleteAll()
                realm.add(createFixture(), update: .modified)
            }
        }
    }
    
    static func all() -> Results<ItemEntity> {
        realm.objects(ItemEntity.self)
    }
    
    private static func createFixture() -> [ItemEntity] {
        (0..<10)
            .map { _ in (0..<1000).randomElement()! }
            .map { number -> ItemEntity in
                let item = ItemEntity()
                item.id = "\(number)"
                item.name = "item\(number)"
                return item
            }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
