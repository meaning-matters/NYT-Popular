//
//  ArticleListViewModel.swift
//  NYT Polular
//
//  Created by Cornelis van der Bent on 17/03/2018.
//  Copyright © 2018 Cornelis. All rights reserved.
//

import Foundation

class ArticleListViewModel
{
    var articlesSource: ArticlesSourceProtocol
    var imageCache:     WebImageCacheProtocol

    var title:      String                 = "New York Times Most Viewed"

    var articles:   Binder<[ArticleModel]> = Binder([ArticleModel]())
    var error:      Binder<String?>        = Binder(nil)
    var isLoading:  Binder<Bool>           = Binder(false)

    private var cellViewModels = [ArticleListCellViewModel]()

    init(articlesSource: ArticlesSourceProtocol, imageCache: WebImageCacheProtocol)
    {
        self.articlesSource = articlesSource
        self.imageCache     = imageCache

        self.loadArticles()
    }

    func loadArticles()
    {
        guard !self.isLoading.value else { return }

        self.isLoading.value = true

        self.articlesSource.getArticles
        { [unowned self] (articles, error) in
            self.isLoading.value = false
            self.error.value     = error
            
            if let articles = articles
            {
                self.cellViewModels = articles.map { ArticleListCellViewModel(article: $0, imageCache: self.imageCache) }
                self.articles.value = articles
            }
            else
            {
                self.cellViewModels = []
                self.articles.value = []
            }
            
            self.articles.value = articles ?? []
        }
    }

    func cellViewModel(at indexPath: IndexPath) -> ArticleListCellViewModel
    {
        return cellViewModels[indexPath.row]
    }
}
