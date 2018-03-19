//
//  ArticleViewModel.swift
//  NYT Popular
//
//  Created by Cornelis van der Bent on 18/03/2018.
//  Copyright © 2018 meaning-matters. All rights reserved.
//

import Foundation
import UIKit

@objcMembers class ArticleViewModel: NSObject
{
    private var model:          ArticleModel
    private var listViewModel:  ArticleListViewModel
    private var imageCache:     WebImageCacheProtocol
    private var dataRepository: DataRepositoryProtocol

    var url:         String  { return self.model.url }
    var section:     String  { return self.model.section }
    var byline:      String  { return self.model.byline }
    var title:       String  { return self.model.title }
    var abstract:    String  { return self.model.abstract }
    var date:        String  { return self.model.date }
    var source:      String  { return self.model.date }
    var imageUrl:    String? { return self.model.imageUrl }

    lazy var article: Article =
    {
        return self.dataRepository.findArticleWithUrl(url: self.model.url)!
    }()

    dynamic var image:      UIImage
    dynamic var isFavorite: Bool
    {
        didSet
        {
            self.model.isFavorite = isFavorite
            if isFavorite
            {
                self.dataRepository.addFavorite(article: self.article)
                self.listViewModel.favorites.append(FavoriteModel(date: NSDate(),
                                                                  article: ArticleModel(article: self.article)))
            }
            else
            {
                self.dataRepository.removeFavorite(article: self.article)
                self.listViewModel.favorites = self.listViewModel.favorites.filter { $0.article.url != self.article.url }
            }
        }
    }

    let buttonTitle: String = "Go to Full Online Article"

    init(_ model: ArticleModel,
         listViewModel: ArticleListViewModel,
         imageCache: WebImageCacheProtocol,
         dataRepository: DataRepositoryProtocol)
    {
        self.model          = model
        self.listViewModel  = listViewModel
        self.imageCache     = imageCache
        self.dataRepository = dataRepository

        self.image      = UIImage(named: "DetailPlaceholder")!
        self.isFavorite = model.isFavorite

        super.init()

        if let url = self.imageUrl
        {
            self.imageCache.getImage(at: url)
            { [weak self] (image) in
                DispatchQueue.main.async // TODO: Sort out why this is needed in case the image is already loaded.
                {
                    self?.image = image ?? UIImage(named: "DetailPlaceholder")!
                }
            }
        }
    }
}
