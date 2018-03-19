//
//  ArticleListViewController.swift
//  NYT Polular
//
//  Created by Cornelis van der Bent on 16/03/2018.
//  Copyright © 2018 Cornelis. All rights reserved.
//

import Foundation
import UIKit
import CoreData

/// Shows a list of articles.
class ArticleListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    // MARK: - User Interface
    @IBOutlet private var tableView:      UITableView!
    private var           statusLabel:    UILabel!
    private let           loadingText:    String = "Loading..."
    private let           cellIdentifier: String = "ArticleListCell"

    // MARK: - DI Objects
    private var webInterface:   WebInterfaceProtocol
    private var imageCache:     ImageCacheProtocol
    private var dataRepository: DataRepositoryProtocol

    // MARK: - View Model Bindings
    private var errorObserver:     NSKeyValueObservation?
    private var isLoadingObserver: NSKeyValueObservation?
    private var articlesObserver:  NSKeyValueObservation?
    private var favoritesObserver: NSKeyValueObservation?

    // MARK: - Lifecycle & View Controller

    init(webInterface: WebInterfaceProtocol, imageCache: ImageCacheProtocol, dataRepository: DataRepositoryProtocol)
    {
        self.webInterface   = webInterface
        self.imageCache     = imageCache
        self.dataRepository = dataRepository

        super.init(nibName: "ArticleListViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.tableView.register(UINib(nibName: "ArticleListCell", bundle: nil), forCellReuseIdentifier: self.cellIdentifier)

        self.addTableBackground()
        self.tableView.tableFooterView = UIView()
        self.title = self.viewModel.title

        self.bindViewModel()

        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self,
                                                 action: #selector(ArticleListViewController.handleRefresh(_:)),
                                                 for: UIControlEvents.valueChanged)

        if UIDevice.current.userInterfaceIdiom == .phone
        {
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "List", style: .plain, target: nil, action: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

        if let indexPath = tableView.indexPathForSelectedRow
        {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    private lazy var viewModel: ArticleListViewModel =
    {
        return ArticleListViewModel(articlesSource: ArticlesSource(webInterface: self.webInterface),
                                    imageCache: self.imageCache,
                                    dataRepository: self.dataRepository)
    }()

    // MARK: - Local

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
        self.errorObserver = self.viewModel.observe(\.errorString)
        { [weak self] (viewModel, change) in
            self?.statusLabel.text = viewModel.errorString
        }

        self.isLoadingObserver = self.viewModel.observe(\.isLoading)
        { [weak self] (viewModel, change) in
            if viewModel.isLoading
            {
                self?.statusLabel.text = self?.loadingText
            }
            else
            {
                self?.tableView.refreshControl?.endRefreshing()

                self?.statusLabel.text = self?.viewModel.errorString
            }
        }

        self.articlesObserver = self.viewModel.observe(\.articles)
        { [unowned self] (viewModel, change) in
            self.tableView.reloadData()
        }

        self.favoritesObserver = self.viewModel.observe(\.favorites)
        { [unowned self] (viewModel, change) in
            self.tableView.reloadData()
        }
    }

    // MARK: - Table View

    func numberOfSections(in tableView: UITableView) -> Int
    {
        return (self.viewModel.articles.count > 0) ? ((self.viewModel.favorites.count > 0) ? 2 : 1) : 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if tableView.numberOfSections == 2 && section == 0
        {
            return "Favorite Articles"
        }
        else
        {
            return "All Articles"
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView.numberOfSections == 2 && section == 0
        {
            return self.viewModel.favorites.count
        }
        else
        {
            return self.viewModel.articles.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as! ArticleListCell

        cell.viewModel = self.viewModel.cellViewModel(at: indexPath)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let index                 = self.viewModel.articleIndex(for: indexPath)
        let articleViewModel      = ArticleViewModel(self.viewModel.articles[index],
                                                     listViewModel: self.viewModel,
                                                     imageCache: self.imageCache,
                                                     dataRepository: self.dataRepository)
        let articleViewController = ArticleViewController(viewModel: articleViewModel)

        if UIDevice.current.userInterfaceIdiom == .phone
        {
            self.navigationController?.pushViewController(articleViewController, animated: true)
        }

        if UIDevice.current.userInterfaceIdiom == .pad
        {
            let navigationController = UINavigationController(rootViewController: articleViewController)
            self.splitViewController?.showDetailViewController(navigationController, sender: nil)
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            self.viewModel.deleteArticle(at: indexPath)
        }
    }
}
