//
//  CollectionExtension.swift
//  MKRandomKeyboard
//
//  Created by Minya Knoka on 15/10/12.
//  Copyright © 2015年 Minya Knoka. All rights reserved.
//
//  Source Code Link: https://github.com/aaroncrespo/Swift-Playgrounds/blob/b1bdf718c25433381dde2aa6a7c73bec50e22e1d/Algorithms/Algorithms.playground/Sources/Shuffle.swift
//

import Foundation

extension CollectionType where Index == Int {
    
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollectionType where Index == Int {
    
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}