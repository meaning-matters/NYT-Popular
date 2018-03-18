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

    dynamic var articles:    [ArticleModel] = []
    dynamic var errorString: String?        = nil
    dynamic var isLoading:   Bool           = false

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
        }
    }

    func cellViewModel(at indexPath: IndexPath) -> ArticleListCellViewModel
    {
        return cellViewModels[indexPath.row]
    }
}
