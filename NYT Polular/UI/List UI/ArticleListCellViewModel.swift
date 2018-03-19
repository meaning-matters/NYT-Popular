//
//  ArticleListCellViewModel.swift
//  NYT Polular
//
//  Created by Cornelis van der Bent on 17/03/2018.
//  Copyright © 2018 Cornelis. All rights reserved.
//

import Foundation
import UIKit

/// Model class for list cell.
@objcMembers class ArticleListCellViewModel: NSObject
{
    // MARK: - DI Object
    let imageCache:    ImageCacheProtocol

    // MARK: - Public Properties
    let section:       String
    let date:          String
    let title:         String
    let byline:        String
    let thumbnailUrl:  String?

    // MARK: - Bindable Public Property
    dynamic var thumbnail: UIImage?

    // MARK: - Lifecycle

    init(article: ArticleModel, imageCache: ImageCacheProtocol)
    {
        self.imageCache   = imageCache

        self.section      = article.section
        self.date         = article.date
        self.title        = article.title
        self.byline       = article.byline
        self.thumbnailUrl = article.thumbnailUrl

        super.init()

        if let url = self.thumbnailUrl
        {
            self.imageCache.getImage(at: url)
            { [weak self] (image) in
                self?.thumbnail = image
            }
        }
    }
}
