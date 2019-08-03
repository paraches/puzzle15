//
//  Array2D.swift
//  puzzle15
//
//  Created by paraches on 2019/08/02.
//  Copyright © 2019 paraches. All rights reserved.
//

import Foundation

class Array2D<T>: Sequence {
    let columns: Int
    let rows: Int
    private var array: [T?]
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        self.array = .init(repeating: nil, count: columns * rows)
    }
    
    subscript(column: Int, row: Int) -> T? {
        get {
            return array[(row * columns) + column]
        }
        set {
            array[(row * columns) + column] = newValue
        }
    }
    
    subscript(index: Int) -> T? {
        get {
            return array[index]
        }
        set {
            array[index] = newValue
        }
    }

    func makeIterator() -> AnyIterator<T?> {
        var index = 0
        return AnyIterator {
            defer { index += 1}
            guard index < self.array.count else { return nil }
            return self.array[index]
        }
    }
}
