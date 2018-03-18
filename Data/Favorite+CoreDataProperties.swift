//
//  Favorite+CoreDataProperties.swift
//  NYT Polular
//
//  Created by Cornelis van der Bent on 18/03/2018.
//  Copyright © 2018 Cornelis. All rights reserved.
//

import Foundation
import CoreData

extension Favorite
{
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favorite>
    {
        return NSFetchRequest<Favorite>(entityName: "Favorite")
    }

    @NSManaged public var article: Article?
}
