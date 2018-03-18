//
//  ArticleViewController.swift
//  NYT Popular
//
//  Created by Cornelis van der Bent on 18/03/2018.
//  Copyright © 2018 Cornelis. All rights reserved.
//

import UIKit

class ArticleViewController : UIViewController
{
    private var viewModel:  ArticleViewModel
    private var imageCache: WebImageCacheProtocol

    @IBOutlet private weak var titleLabel:          UILabel!
    @IBOutlet private weak var bylineLabel:         UILabel!
    @IBOutlet private weak var imageView:           UIImageView!
    @IBOutlet private weak var imageRatioContraint: NSLayoutConstraint!
    @IBOutlet private weak var abstractLabel:       UILabel!
    @IBOutlet private weak var goButton:            UIButton!

    private var imageObserver: NSKeyValueObservation?

    init(viewModel: ArticleViewModel, imageCache: WebImageCacheProtocol)
    {
        self.viewModel  = viewModel
        self.imageCache = imageCache

        super.init(nibName: "ArticleViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.imageView.layer.borderWidth = 1
        self.imageView.layer.borderColor = UIColor(white: 0.95, alpha:1.0).cgColor

        self.title = self.viewModel.section + " - " + self.viewModel.date

        self.titleLabel.text    = self.viewModel.title
        self.bylineLabel.text   = self.viewModel.byline
        self.imageView.image    = self.viewModel.image
        self.abstractLabel.text = self.viewModel.abstract
        self.goButton.setTitle(self.viewModel.buttonTitle, for: .normal)
        
        self.bindViewModel()
    }

    @IBAction private func goAction(_ sender: Any)
    {
        if let url = URL(string: self.viewModel.url)
        {
            UIApplication.shared.open(url)
        }
    }

    private func bindViewModel()
    {
        self.imageObserver = self.viewModel.observe(\.image)
        { [weak self] (viewModel, changes) in
            guard let `self` = self else { return }

            self.imageView.image = self.viewModel.image

            // Make sure that `UIImageView` encloses the image without empty borders.
            self.imageRatioContraint.isActive = false
            let multiplier = self.viewModel.image.size.width / self.viewModel.image.size.height
            self.imageRatioContraint = self.imageView.widthAnchor.constraint(equalTo: self.imageView.heightAnchor,
                                                                             multiplier: multiplier)
            self.imageRatioContraint.isActive = true
        }
    }
}

