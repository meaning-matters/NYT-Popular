//
//  ArticleListViewModel.swift
//  NYT Polular
//
//  Created by Cornelis van der Bent on 17/03/2018.
//  Copyright © 2018 Cornelis. All rights reserved.
//

import Foundation
import CoreData

@objcMembers class ArticleListViewModel: NSObject
{
    var articlesSource: ArticlesSourceProtocol
    var imageCache:     WebImageCacheProtocol
    var dataRepository: DataRepositoryProtocol

    var title: String = "New York Times Most Viewed"

    dynamic var articles:    [ArticleModel]  = []
    dynamic var favorites:   [FavoriteModel] = []
    dynamic var errorString: String?         = nil
    dynamic var isLoading:   Bool            = false

    private var cellViewModels = [ArticleListCellViewModel]()

    init(articlesSource: ArticlesSourceProtocol, imageCache: WebImageCacheProtocol, dataRepository: DataRepositoryProtocol)
    {
        self.articlesSource = articlesSource
        self.imageCache     = imageCache
        self.dataRepository = dataRepository

        super.init()

        self.loadArticles()
    }

    func loadArticles()
    {
        guard !self.isLoading else { return }

        self.isLoading = true

        self.articlesSource.loadArticles
        { [unowned self] (articles, errorString) in
            self.isLoading   = false
            self.errorString = errorString

            if let articles = articles
            {
                for article in articles
                {
                    self.dataRepository.addUniqueArticle(url:          article.url,
                                                         section:      article.section,
                                                         byline:       article.byline,
                                                         title:        article.title,
                                                         abstract:     article.abstract,
                                                         date:         article.date,
                                                         source:       article.source,
                                                         thumbnailUrl: article.thumbnailUrl,
                                                         imageUrl:     article.imageUrl)
                }
            }

            self.dataRepository.save()

            self.articles       = self.dataRepository.fetchArticles().map { ArticleModel(article: $0) }
            self.cellViewModels = self.articles.map { ArticleListCellViewModel(article: $0, imageCache: self.imageCache) }
            self.favorites      = self.dataRepository.fetchFavorites().map { FavoriteModel(favorite: $0) }
        }
    }

    func articleIndex(for indexPath: IndexPath) -> Int
    {
        if self.favorites.count > 0 && indexPath.section == 0
        {
            let article = self.articles.filter { $0.url == self.favorites[indexPath.row].article.url }.first!

            return self.articles.index(of: article)!
        }
        else
        {
            return indexPath.row
        }
    }

    func cellViewModel(at indexPath: IndexPath) -> ArticleListCellViewModel
    {
        return self.cellViewModels[self.articleIndex(for: indexPath)]
    }

    func deleteArticle(at indexPath: IndexPath)
    {
        let index = self.articleIndex(for: indexPath)
        if let article = self.dataRepository.findArticleWithUrl(url: self.articles[index].url)
        {
            self.dataRepository.delete(article: article)
            self.dataRepository.save()
            
            self.articles       = self.dataRepository.fetchArticles().map { ArticleModel(article: $0) }
            self.cellViewModels = self.articles.map { ArticleListCellViewModel(article: $0, imageCache: self.imageCache) }
        }
    }
}
