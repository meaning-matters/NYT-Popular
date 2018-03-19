//
//  ArticleModel.swift
//  NYT Polular
//
//  Created by Cornelis van der Bent on 17/03/2018.
//  Copyright © 2018 Cornelis. All rights reserved.
//

import Foundation
import CoreData

/// Model class article data.
@objcMembers class ArticleModel: NSObject
{
    var url:          String
    var section:      String
    var byline:       String
    var title:        String
    var abstract:     String
    var date:         String
    var source:       String
    var thumbnailUrl: String?
    var imageUrl:     String?
    var isFavorite:   Bool

    init(url:          String,
         section:      String,
         byline:       String,
         title:        String,
         abstract:     String,
         date:         String,
         source:       String,
         thumbnailUrl: String?,
         imageUrl:     String?,
         isFavorite:   Bool = false)
    {
        self.url          = url
        self.section      = section
        self.byline       = byline
        self.title        = title
        self.abstract     = abstract
        self.date         = date
        self.source       = source
        self.thumbnailUrl = thumbnailUrl
        self.imageUrl     = imageUrl
        self.isFavorite   = isFavorite
    }

    init(article: Article)
    {
        // `NSManagedObject` properties are optional. In the database model however, only `thumbnailUrl` and `imageUrl`
        // are optional. Therefore the force unwrappings below won't cause trouble.
        self.url          = article.url!
        self.section      = article.section!
        self.byline       = article.byline!
        self.title        = article.title!
        self.abstract     = article.abstract!
        self.date         = article.date!
        self.source       = article.source!
        self.thumbnailUrl = article.thumbnailUrl
        self.imageUrl     = article.imageUrl
        self.isFavorite   = (article.favorite != nil)
    }
}
