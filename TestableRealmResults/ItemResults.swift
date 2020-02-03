//
//  ItemResults.swift
//  TestableRealmResults
//
//  Created by Takuya Yokoyama on 2020/02/03.
//  Copyright © 2020 Takuya Yokoyama. All rights reserved.
//

import RealmSwift

class ItemResults: RealmResultsWrapper {
    typealias Entity = ItemEntity
    
    let results: Results<ItemEntity>
    
    init(_ itemResults: Results<ItemEntity>) {
        self.results = itemResults
    }
}

class StubItemResults: StubEntityWrapper {
    typealias Entity = ItemEntity
    
    let entities: [ItemEntity]  = {
        (0..<10).map {
            let entity = ItemEntity()
            entity.name = "\($0)"
            return entity
        }
    }()
}
