//
//  DataRepository.swift
//  NYT Polular
//
//  Created by Cornelis van der Bent on 18/03/2018.
//  Copyright © 2018 Cornelis. All rights reserved.
//

import Foundation
import CoreData

protocol DataRepositoryProtocol
{
    @discardableResult func addUniqueArticle(url:          String,
                                             section:      String,
                                             byline:       String,
                                             title:        String,
                                             abstract:     String,
                                             date:         String,
                                             source:       String,
                                             thumbnailUrl: String?,
                                             imageUrl:     String?) -> Article?

    func findArticleWithUrl(url: String) -> Article?

    func delete(article: Article)

    func fetchArticles() -> [Article]

    func fetchFavoriteArticles() -> [Article]

    func save()
}

class DataRepository: DataRepositoryProtocol
{
    private var dataContext: NSManagedObjectContext

    init(dataContext: NSManagedObjectContext)
    {
        self.dataContext = dataContext
    }

    @discardableResult func addUniqueArticle(url:          String,
                                             section:      String,
                                             byline:       String,
                                             title:        String,
                                             abstract:     String,
                                             date:         String,
                                             source:       String,
                                             thumbnailUrl: String?,
                                             imageUrl:     String?) -> Article?
    {
        var article: Article? = nil

        if self.findArticleWithUrl(url: url) == nil
        {
            article = Article(entity: Article.entity(), insertInto: self.dataContext)
            article?.url          = url
            article?.section      = section
            article?.byline       = byline
            article?.title        = title
            article?.abstract     = abstract
            article?.date         = date
            article?.source       = source
            article?.thumbnailUrl = thumbnailUrl
            article?.imageUrl     = imageUrl
        }

        return article
    }

    func findArticleWithUrl(url: String) -> Article?
    {
        let request = Article.fetchRequest() as NSFetchRequest<Article>
        request.predicate = NSPredicate(format: "url == %@", url)
        do
        {
            return try self.dataContext.fetch(request).first
        }
        catch let error as NSError
        {
            print("Fetch failed: \(error), \(error.userInfo)")

            return nil
        }
    }

    func delete(article: Article)
    {
        self.dataContext.delete(article)
    }

    func fetchArticles() -> [Article]
    {
        do
        {
            return try self.dataContext.fetch(Article.fetchRequest())
        }
        catch let error as NSError
        {
            print("Fetch failed: \(error), \(error.userInfo)")

            return []
        }
    }

    func fetchFavoriteArticles() -> [Article]
    {
        return []
    }

    func save()
    {
        do
        {
            try self.dataContext.save()
        }
        catch let error as NSError
        {
            print("Save failed: \(error), \(error.userInfo)")
        }
    }
}
