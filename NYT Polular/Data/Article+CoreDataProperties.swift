//
//  Article+CoreDataProperties.swift
//  NYT Polular
//
//  Created by Cornelis van der Bent on 19/03/2018.
//  Copyright © 2018 Cornelis. All rights reserved.
//
//

import Foundation
import CoreData

extension Article
{
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Article>
    {
        return NSFetchRequest<Article>(entityName: "Article")
    }

    @NSManaged public var abstract:     String?
    @NSManaged public var byline:       String?
    @NSManaged public var date:         String?
    @NSManaged public var imageUrl:     String?
    @NSManaged public var section:      String?
    @NSManaged public var source:       String?
    @NSManaged public var thumbnailUrl: String?
    @NSManaged public var title:        String?
    @NSManaged public var url:          String?
    @NSManaged public var favorite:     Favorite?
}
