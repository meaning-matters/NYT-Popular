//
//  Binder.swift
//  NYT Polular
//
//  Created by Cornelis van der Bent on 17/03/2018.
//  Copyright © 2018 Cornelis. All rights reserved.
//

import Foundation

/// Simple class that allows one-way binding on a property value.
class Binder<T>
{
    /// Closure that is called when the `value` is set.
    var binding: (T) -> () = { _ in }

    /// Value kept by an instance of this class.
    var value: T
    {
        didSet
        {
            binding(value)
        }
    }

    /// Creates an instance.
    ///
    /// - Parameter value: Initial value.
    init(_ value: T)
    {
        self.value = value
    }
}

