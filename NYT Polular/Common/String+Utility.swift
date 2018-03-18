//
//  String+Utility.swift
//  NYT Polular
//
//  Created by Cornelis van der Bent on 17/03/2018.
//  Copyright © 2018 Cornelis. All rights reserved.
//

import Foundation

extension String
{
    /// Replaces matches of a regular expression with the a given string.
    ///
    /// - Parameters:
    ///   - pattern:     Regular expression.
    ///   - replacement: String to replace regular expression matches with.
    mutating func replaceMatches(of pattern: String, with replacement: String)
    {
        do
        {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSMakeRange(0, self.count)
            self = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replacement)
        }
        catch
        {
            return
        }
    }
}
