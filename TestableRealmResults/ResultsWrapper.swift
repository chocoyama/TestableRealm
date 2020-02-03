//
//  ResultsWrapper.swift
//  TestableRealmResults
//
//  Created by Takuya Yokoyama on 2020/02/03.
//  Copyright © 2020 Takuya Yokoyama. All rights reserved.
//

import RealmSwift

protocol ResultsWrapper {
    associatedtype Entity: RealmCollectionValue
    var count: Int { get }
    func observe(_ handler: @escaping () -> Void) -> NotificationToken
    func get(_ index: Int) -> Entity
}

class AnyResults<Entity: RealmCollectionValue>: ResultsWrapper {
    private let _observe: (@escaping () -> Void) -> NotificationToken
    private let _get: (Int) -> Entity
    
    required init<E: ResultsWrapper>(_ wrapper: E) where E.Entity == Entity {
        count = wrapper.count
        _observe = wrapper.observe
        _get = wrapper.get
    }
    
    var count: Int
    
    func observe(_ handler: @escaping () -> Void) -> NotificationToken {
        _observe(handler)
    }
    
    func get(_ index: Int) -> Entity {
        _get(index)
    }
}

protocol RealmResultsWrapper: ResultsWrapper {
    var results: Results<Entity> { get }
}

extension RealmResultsWrapper {
    var count: Int {
        results.count
    }
    
    func observe(_ handler: @escaping () -> Void) -> NotificationToken {
        results.observe { _ in
            handler()
        }
    }
    
    func get(_ index: Int) -> Entity {
        results[index]
    }
}

protocol StubEntityWrapper: ResultsWrapper {
    var entities: [Entity] { get }
}

extension StubEntityWrapper {
    var count: Int {
        entities.count
    }
    
    func observe(_ handler: @escaping () -> Void) -> NotificationToken {
        .init()
    }
    
    func get(_ index: Int) -> Entity {
        entities[index]
    }
}
