//
//  DataRepository.swift
//  NYT Polular
//
//  Created by Cornelis van der Bent on 18/03/2018.
//  Copyright © 2018 Cornelis. All rights reserved.
//

import Foundation
import CoreData

/// Protocol for storing and retrieving `Article` and `Favorite` objects.
protocol DataRepositoryProtocol
{
    /// Stores an `Article` object if it's not present yet.
    ///
    /// The `url` is used as the unique value to compare articles.
    ///
    /// - Parameters:
    ///   - url:          The online full article URL string.
    ///   - section:      News section.
    ///   - byline:       Article authors.
    ///   - title:        Main title.
    ///   - abstract:     Abstract.
    ///   - date:         Textual article release date.
    ///   - source:       News source.
    ///   - thumbnailUrl: URL string of thumbnail image.
    ///   - imageUrl:     URL string of large image.
    /// - Returns:        The newly created `Article` object, or `nil` if already present.
    @discardableResult func addUniqueArticle(url:          String,
                                             section:      String,
                                             byline:       String,
                                             title:        String,
                                             abstract:     String,
                                             date:         String,
                                             source:       String,
                                             thumbnailUrl: String?,
                                             imageUrl:     String?) -> Article?


    /// Finds the article that has the given `url`.
    ///
    /// - Parameter url: URL string to search with.
    /// - Returns:       The found `Article` object, or `nil`.
    func findArticleWithUrl(url: String) -> Article?


    /// Deletes the specified article.
    ///
    /// - Parameter article: `Article` object to delete.
    func delete(article: Article)


    /// Retrieves all `Article` objects sorted on `date` and then on `title`.
    ///
    /// - Returns: Array of sorted `Article` objects.
    func fetchArticles() -> [Article]

    /// Retrieves all `Favorite` objects sorted on `date` and then on the associated `Article`'s `title`.
    ///
    /// - Returns: Array of sorted `Favorite` objects.
    func fetchFavorites() -> [Favorite]


    /// Stores a `Favorite` object.
    ///
    /// - Parameter article: The associated article.
    /// - Returns:           The newly create `Favorite` object.
    func addFavorite(article: Article) -> Favorite


    /// Deletes the `Favorite` object that is associated with the specified `Article`.
    ///
    /// - Parameter article: Associated `Article`.
    func removeFavorite(article: Article)

    /// Saves data changes to disk, if any.
    func save()
}

class DataRepository: DataRepositoryProtocol
{
    private var dataContext: NSManagedObjectContext

    init(dataContext: NSManagedObjectContext)
    {
        self.dataContext = dataContext
    }

    // MARK: - DataRepositoryProtocol
    
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
            let fetchRequest: NSFetchRequest = Article.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false),
                                            NSSortDescriptor(key: "title", ascending: true)]

            return try self.dataContext.fetch(fetchRequest)
        }
        catch let error as NSError
        {
            print("Fetch failed: \(error), \(error.userInfo)")

            return []
        }
    }

    func fetchFavorites() -> [Favorite]
    {
        do
        {
            let fetchRequest: NSFetchRequest = Favorite.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false),
                                            NSSortDescriptor(key: "article.title", ascending: true)]

            return try self.dataContext.fetch(fetchRequest)
        }
        catch let error as NSError
        {
            print("Fetch failed: \(error), \(error.userInfo)")

            return []
        }
    }

    func addFavorite(article: Article) -> Favorite
    {
        let favorite = Favorite(entity: Favorite.entity(), insertInto: self.dataContext)
        favorite.article = article
        favorite.date    = NSDate()

        return favorite
    }

    func removeFavorite(article: Article)
    {
        if let favorite = article.favorite
        {
            self.dataContext.delete(favorite)
        }
    }

    func save()
    {
        if self.dataContext.hasChanges
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
}
