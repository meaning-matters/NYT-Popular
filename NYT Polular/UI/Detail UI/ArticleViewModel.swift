//
//  ArticleViewModel.swift
//  NYT Popular
//
//  Created by Cornelis van der Bent on 18/03/2018.
//  Copyright © 2018 Cornelis. All rights reserved.
//

import Foundation
import UIKit

/// Model class belonging to the view that shows an article in detail.
@objcMembers class ArticleViewModel: NSObject
{
    // MARK: - View Models
    private var model:          ArticleModel
    private var listViewModel:  ArticleListViewModel

    // MARK: - DI Objects
    private var imageCache:     ImageCacheProtocol
    private var dataRepository: DataRepositoryProtocol

    // MARK: - Public Properties
    var url:          String  { return self.model.url }
    var section:      String  { return self.model.section }
    var byline:       String  { return self.model.byline }
    var title:        String  { return self.model.title }
    var abstract:     String  { return self.model.abstract }
    var date:         String  { return self.model.date }
    var source:       String  { return self.model.date }
    var imageUrl:     String? { return self.model.imageUrl }
    let buttonTitle:  String = "Go to Full Online Article"
    lazy var article: Article =
    {
        return self.dataRepository.findArticleWithUrl(url: self.model.url)!
    }()

    // MARK: - Bindable Public Properties
    dynamic var image:      UIImage
    dynamic var isFavorite: Bool
    {
        didSet
        {
            self.model.isFavorite = isFavorite
            if isFavorite
            {
                let favorite = self.dataRepository.addFavorite(article: self.article)
                self.listViewModel.favorites.append(FavoriteModel(favorite: favorite))

                self.listViewModel.favoriteWasAdded()
            }
            else
            {
                self.dataRepository.removeFavorite(article: self.article)
                self.listViewModel.favorites = self.listViewModel.favorites.filter { $0.article.url != self.article.url }
            }
        }
    }

    // MARK: - Lifecycle

    init(_ model: ArticleModel,
         listViewModel: ArticleListViewModel,
         imageCache: ImageCacheProtocol,
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
