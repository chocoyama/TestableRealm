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
    @ObservedObject private var viewModel = ViewModel(
        itemResults: .init(ItemResults(ItemEntity.all()))
//        itemResults: .init(StubItemResults())
    )
    
    var body: some View {
        List {
            ForEach(0..<viewModel.itemResults.count) { index in
                if self.viewModel.itemResults.get(index).isInvalidated {
                    EmptyView()
                } else {
                    Text(self.viewModel.itemResults.get(index).name)
                }
            }
        }.onAppear {
            ItemEntity.setUp()
        }
    }
}

class ViewModel1: ObservableObject {
    var objectWillChange: ObservableObjectPublisher = .init()
    let itemResults: Results<ItemEntity>
    private var notificationTokens: [NotificationToken] = []
    
    init(itemResults: Results<ItemEntity>) {
        self.itemResults = itemResults
        notificationTokens.append(itemResults.observe { _ in
            self.objectWillChange.send()
        })
    }
    
    deinit {
        notificationTokens.forEach {
            NotificationCenter.default.removeObserver($0)
        }
    }
}

import Combine
class ViewModel: ObservableObject {
    var objectWillChange: ObservableObjectPublisher = .init()
    let itemResults: AnyResults<ItemEntity>
    private var notificationTokens: [NotificationToken] = []
    
    init(itemResults: AnyResults<ItemEntity>) {
        self.itemResults = itemResults
        notificationTokens.append(itemResults.observe {
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
            .map { _ in (0..<10000).randomElement()! }
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
