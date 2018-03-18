//
//  ArticleListViewModel.swift
//  NYT Polular
//
//  Created by Cornelis van der Bent on 17/03/2018.
//  Copyright © 2018 Cornelis. All rights reserved.
//

import Foundation

@objcMembers class ArticleListViewModel: NSObject
{
    var articlesSource: ArticlesSourceProtocol
    var imageCache:     WebImageCacheProtocol

    var title: String = "New York Times Most Viewed"

    dynamic var articles:    [ArticleModel] = []
    dynamic var errorString: String?        = nil
    dynamic var isLoading:   Bool           = false

    private var cellViewModels = [ArticleListCellViewModel]()

    init(articlesSource: ArticlesSourceProtocol, imageCache: WebImageCacheProtocol)
    {
        self.articlesSource = articlesSource
        self.imageCache     = imageCache

        super.init()

        self.loadArticles()
    }

    func loadArticles()
    {
        guard !self.isLoading else { return }

        self.isLoading = true

        self.articlesSource.getArticles
        { [unowned self] (articles, errorString) in
            self.isLoading   = false
            self.errorString = errorString
            
            if let articles = articles
            {
                self.cellViewModels = articles.map { ArticleListCellViewModel(article: $0, imageCache: self.imageCache) }
                self.articles = articles
            }
            else
            {
                self.cellViewModels = []
                self.articles = []
            }
            
            self.articles = articles ?? []
        }
    }

    func cellViewModel(at indexPath: IndexPath) -> ArticleListCellViewModel
    {
        return cellViewModels[indexPath.row]
    }
}
