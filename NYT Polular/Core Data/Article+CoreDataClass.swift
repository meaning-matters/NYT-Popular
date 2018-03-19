//
//  Article+CoreDataClass.swift
//  NYT Polular
//
//  Created by Cornelis van der Bent on 18/03/2018.
//  Copyright © 2018 Cornelis. All rights reserved.
//

import Foundation
import CoreData

public class Article: NSManagedObject
{
    func add(model: ArticleModel, to context: NSManagedObjectContext) -> Article
    {
        let article = Article(entity: Article.entity(), insertInto: context)
        article.url          = model.url
        article.section      = model.section
        article.byline       = model.byline
        article.title        = model.title
        article.abstract     = model.abstract
        article.date         = model.date
        article.source       = model.source
        article.thumbnailUrl = model.thumbnailUrl
        article.imageUrl     = model.imageUrl

        return article
    }
}
