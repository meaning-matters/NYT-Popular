//
//  ArticleModel.swift
//  NYT Polular
//
//  Created by Cornelis van der Bent on 17/03/2018.
//  Copyright © 2018 Cornelis. All rights reserved.
//

import Foundation

class ArticleModel
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

    init(url:          String,
         section:      String,
         byline:       String,
         title:        String,
         abstract:     String,
         date:         String,
         source:       String,
         thumbnailUrl: String?,
         imageUrl:     String?)
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
    }
}
