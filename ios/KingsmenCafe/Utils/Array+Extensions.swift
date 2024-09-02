//
//  Array+Extensions.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 3/13/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import Foundation

extension Array where Element == CoordinatorType {
    mutating func delete(element: CoordinatorType) {
        self = filter { $0.identifier != element.identifier }
    }

    subscript<T: CoordinatorType>(id: String) -> T? {
        let filtered = filter { $0.identifier == id }
        if filtered.count == 0 {
            return nil
        }
        return (filtered[0] as! T)
    }
}

extension Collection {
    func itemIfExists(at index: Index) -> Element? {
        if !(index <= startIndex) || !(index >= endIndex) {
            return self[index]
        }
        return nil
    }
}
