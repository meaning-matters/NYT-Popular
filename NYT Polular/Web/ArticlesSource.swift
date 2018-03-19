//
//  ArticlesSource.swift
//  NYT Polular
//
//  Created by Cornelis van der Bent on 17/03/2018.
//  Copyright © 2018 Cornelis. All rights reserved.
//

import Foundation

/// Supplies a list articles.
protocol ArticlesSourceProtocol
{
    /// Fetches the list of articles usually on a background thread.
    ///
    /// - Parameter completion: Called on main thread when the fetch has finished.  Supplies an array of Article
    ///                         objects. On error, `nil` is supplied, together with an error string.
    func loadArticles(completion: @escaping (_ articles: [ArticleModel]?, _ errorString: String?) -> ())
}

/// Class to retrieves articles from the NYT web API.
class ArticlesSource: ArticlesSourceProtocol
{
    private let urlString = "https://api.nytimes.com/svc/mostpopular/v2/mostviewed/all-sections/7.json?apikey=6f1888ceb12041799e62181b35463f6b"

    private var webInterface: WebInterfaceProtocol

    init(webInterface: WebInterfaceProtocol)
    {
        self.webInterface = webInterface
    }

    // MARK: - ArticlesSourceProtocol

    func loadArticles(completion: @escaping (_ articles: [ArticleModel]?, _ errorString: String?) -> ())
    {
        webInterface.getRequest(toUrlString: urlString)
        { (data, errorString) in
            guard errorString == nil else
            {
                completion(nil, errorString);

                return
            }

            guard let data = data else
            {
                completion(nil, "No data received")

                return
            }

            guard let patchedData = ArticlesCodable.patchData(data) else
            {
                completion(nil, "Invalid data received")

                return
            }

            do
            {
                let decodedObject = try JSONDecoder().decode(ArticlesCodable.self, from: patchedData)

                if decodedObject.status == "OK"
                {
                    let articles = decodedObject.results.map
                    {
                        return ArticleModel(url:          $0.url,
                                            section:      $0.section,
                                            byline:       $0.byline,
                                            title:        $0.title,
                                            abstract:     $0.abstract,
                                            date:         $0.published_date,
                                            source:       $0.source,
                                            thumbnailUrl: ArticlesCodable.getThumbnailUrl(from: $0),
                                            imageUrl:     ArticlesCodable.getImageUrl(from: $0))
                    }

                    completion(articles, nil)
                }
                else
                {
                    completion(nil, "Error getting data from NYT")
                }
            }
            catch
            {
                completion(nil, "Unexpected data received")
            }
        }
    }
}
