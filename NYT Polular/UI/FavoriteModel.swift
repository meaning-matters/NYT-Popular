//
//  FavoriteModel.swift
//  NYT Polular
//
//  Created by Cornelis van der Bent on 19/03/2018.
//  Copyright © 2018 Cornelis. All rights reserved.
//

import Foundation
import CoreData

/// Model class for favorite info.
@objcMembers class FavoriteModel: NSObject
{
    var date:    NSDate         // Favorite creation date.
    var article: ArticleModel

    init(favorite: Favorite)
    {
        self.date    = favorite.date!
        self.article = ArticleModel(article: favorite.article!)
    }
}
