//
//  ArticleListViewController.swift
//  NYT Polular
//
//  Created by Cornelis van der Bent on 16/03/2018.
//  Copyright © 2018 Cornelis. All rights reserved.
//

import UIKit

class ArticleListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet private var tableView: UITableView!

    private var webInterface:  WebInterfaceProtocol
    private var webImageCache: WebImageCacheProtocol
    private var statusLabel:   UILabel!
    private let loadingText:   String = "Loading..."

    init(webInterface: WebInterfaceProtocol, webImageCache: WebImageCacheProtocol)
    {
        self.webInterface  = webInterface
        self.webImageCache = webImageCache

        super.init(nibName: "ArticleListViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.tableView.register(UINib(nibName: "ArticleListCell", bundle: nil), forCellReuseIdentifier: "ArticleListCell")

        self.addTableBackground()
        self.tableView.tableFooterView = UIView()
        self.title = self.viewModel.title

        self.bindViewModel()

        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self,
                                                 action: #selector(ArticleListViewController.handleRefresh(_:)),
                                                 for: UIControlEvents.valueChanged)

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "List", style: .plain, target: nil, action: nil)
    }

    private lazy var viewModel: ArticleListViewModel =
    {
        return ArticleListViewModel(articlesSource: WebArticlesSource(webInterface: self.webInterface),
                                    imageCache: self.webImageCache)
    }()

    @objc private func handleRefresh(_ refreshControl: UIRefreshControl)
    {
        self.viewModel.loadArticles()
    }

    /// Add square label at center for display of a loading or error text.
    private func addTableBackground()
    {
        self.tableView.backgroundView = UIView()
        self.tableView.backgroundView?.backgroundColor = UIColor(white: 0.95, alpha: 1.0)

        self.statusLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 280, height: 280))
        self.tableView.backgroundView!.addSubview(self.statusLabel)
        self.statusLabel.numberOfLines    = 0
        self.statusLabel.textAlignment    = .center
        self.statusLabel.lineBreakMode    = .byWordWrapping
        self.statusLabel.center           = self.tableView.backgroundView!.center;
        self.statusLabel.text             = self.loadingText
        self.statusLabel.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin,
                                             .flexibleTopMargin, .flexibleBottomMargin]
    }

    private func bindViewModel()
    {
        self.viewModel.error.binding =
        { [weak self] in
            self?.statusLabel.text = $0
        }

        self.viewModel.isLoading.binding =
        { [weak self] in
            if $0
            {
                self?.statusLabel.text = self?.loadingText
            }
            else
            {
                self?.tableView.refreshControl?.endRefreshing()

                self?.statusLabel.text = self?.viewModel.error.value
            }
        }

        self.viewModel.articles.binding =
        { [weak self] (_) in
            self?.tableView.reloadData()
        }
    }

    // MARK: - Table View

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.viewModel.articles.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ArticleListCell", for: indexPath) as! ArticleListCell

        cell.viewModel = self.viewModel.cellViewModel(at: indexPath)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
    }
}
