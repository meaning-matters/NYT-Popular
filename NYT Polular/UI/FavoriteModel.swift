//
//  FavoriteModel.swift
//  NYT Polular
//
//  Created by Cornelis van der Bent on 19/03/2018.
//  Copyright © 2018 Cornelis. All rights reserved.
//

import Foundation
import CoreData

@objcMembers class FavoriteModel: NSObject
{
    var date:    NSDate
    var article: ArticleModel

    init(date:    NSDate,
         article: ArticleModel)
    {
        self.date    = date
        self.article = article
    }

    init(favorite: Favorite)
    {
        self.date    = favorite.date!
        self.article = ArticleModel(article: favorite.article!)
    }
}
