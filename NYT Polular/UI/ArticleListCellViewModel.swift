//
//  ArticleListCellViewModel.swift
//  NYT Polular
//
//  Created by Cornelis van der Bent on 17/03/2018.
//  Copyright © 2018 Cornelis. All rights reserved.
//

import Foundation
import UIKit

class ArticleListCellViewModel
{
    let imageCache:    WebImageCacheProtocol
    let section:       String
    let date:          String
    let title:         String
    let byline:        String
    let thumbnailUrl:  String?
    var thumbnail:     Binder<UIImage?> = Binder(nil)

    init(article: ArticleModel, imageCache: WebImageCacheProtocol)
    {
        self.imageCache   = imageCache

        self.section      = article.section
        self.date         = article.date
        self.title        = article.title
        self.byline       = article.byline
        self.thumbnailUrl = article.thumbnailUrl

        if let url = self.thumbnailUrl
        {
            self.imageCache.getImage(at: url)
            { [weak self] (image) in
                self?.thumbnail.value = image
            }
        }
    }
}
