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
    private var model:      ArticleModel
    private var imageCache: WebImageCacheProtocol

    var url:         String  { return model.url }
    var section:     String  { return model.section }
    var byline:      String  { return model.byline }
    var title:       String  { return model.title }
    var abstract:    String  { return model.abstract }
    var date:        String  { return model.date }
    var source:      String  { return model.date }
    var imageUrl:    String? { return model.imageUrl }

    dynamic var image:       UIImage
    let buttonTitle: String = "Go to Full Online Article"

    init(_ model: ArticleModel, imageCache: WebImageCacheProtocol)
    {
        self.model      = model
        self.imageCache = imageCache
        self.image      = UIImage(named: "DetailPlaceholder")!

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
