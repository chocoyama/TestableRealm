//
//  ItemRepository.swift
//  TestableRealmResults
//
//  Created by Takuya Yokoyama on 2020/02/04.
//  Copyright © 2020 Takuya Yokoyama. All rights reserved.
//

import Foundation
import RealmSwift

protocol ItemRepository {
    func getAll() -> Results<ItemEntity>
}

class ItemRepositoryImpl: ItemRepository {
    func getAll() -> Results<ItemEntity> {
        ItemEntity.all()
    }
}

class ItemRepositoryMock: ItemRepository {
    func getAll() -> Results<ItemEntity> {
        let stubItems: [ItemEntity] = (0..<10).map {
            let entity = ItemEntity()
            entity.id = "\($0)"
            entity.name = "\($0)"
            return entity
        }
        return Realm.createStubResults(for: stubItems)
    }
}

extension Realm {
    static func createStubResults<Entity: Object>(for stubEntities: [Entity]) -> Results<Entity> {
        let onMemoryRealm = try! Realm(configuration: .init(inMemoryIdentifier: "test"))
        try! onMemoryRealm.write {
            onMemoryRealm.deleteAll()
            onMemoryRealm.add(stubEntities, update: .all)
        }
        return onMemoryRealm.objects(Entity.self)
    }
}

