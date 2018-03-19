//
//  ArticleListCell.swift
//  NYT Polular
//
//  Created by Cornelis van der Bent on 17/03/2018.
//  Copyright © 2018 Cornelis. All rights reserved.
//

import UIKit

class ArticleListCell: UITableViewCell
{
    @IBOutlet private weak var sectionLabel:  UILabel!
    @IBOutlet private weak var dateLabel:     UILabel!
    @IBOutlet private weak var thumbnailView: UIImageView!
    @IBOutlet private weak var titleLabel:    UILabel!
    @IBOutlet private weak var bylineLabel:   UILabel!

    private var thumbnailObserver: NSKeyValueObservation?

    var viewModel: ArticleListCellViewModel!
    {
        didSet
        {
            self.sectionLabel.text   = self.viewModel.section
            self.dateLabel.text      = self.viewModel.date
            self.thumbnailView.image = self.viewModel.thumbnail ?? UIImage(named: "ListPlaceholder")
            self.titleLabel.text     = self.viewModel.title
            self.bylineLabel.text    = self.viewModel.byline

            self.bindViewModel()
        }
    }

    private func bindViewModel()
    {
        self.thumbnailObserver = self.viewModel.observe(\.thumbnail)
        { [weak self] (viewModel, changes) in
            self?.thumbnailView.image = viewModel.thumbnail ?? UIImage(named: "ListPlaceholder")
        }
    }
}
