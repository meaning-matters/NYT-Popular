//
//  WebArticlesSource.swift
//  NYT Polular
//
//  Created by Cornelis van der Bent on 17/03/2018.
//  Copyright © 2018 Cornelis. All rights reserved.
//

import Foundation

typealias Dictionary = [String:AnyObject]

/// Supplies a list articles.
protocol ArticlesSourceProtocol
{
    /// Fetches the list of articles usually on a background thread.
    ///
    /// - Parameter completion: Called on main thread when the fetch has finished.  Supplies an array of Article
    ///                         objects. On error, `nil` is supplied, together with an error string.
    func getArticles(completion: @escaping (_ articles: [ArticleModel]?, _ error: String?) -> ())
}

/// Retrieves articles from the NYT web API.  The returned JSON has the following format (with example data):
///
///     {
///         "status"      : "OK",
///         "copyright"   : "Copyright (c) 2018 The New York Times Company.  All Rights Reserved.",
///         "num_results" : 1783,
///         "results"     :
///         [
///             {
///                 "url"            : "https:/\/www.nytimes.com\/2018\/02\/16\/sports\/olympics\/lindsey-g.html",
///                 "adx_keywords"   : "United States;...;...",
///                 "column"         : null,
///                 "section"        : "Sports",
///                 "byline"         : "By MAX FISHER and JOSH KELLER",
///                 "type"           : "Article",
///                 "title"          : "Snowboarder Ester Ledecka Shocks Lindsey Vonn and the Super-G Field",
///                 "abstract"       : "Ledecka, a converted snowboarder, came out of nowhere to win ...",
///                 "published_date" : "2017-11-07",
///                 "source"         : "The New York Times",
///                 "id"             : 100000005537411,
///                 "asset_id"       : 100000005537411,
///                 "views"          : 16,
///                 "des_facet"      :
///                 [
///                     "ALPINE SKIING",
///                     "OLYMPIC GAMES (2018)"
///                 ],
///                 "org_facet"      : "",
///                 "per_facet"      : "",
///                 "geo_facet"      :
///                 [
///                     "UNITED STATES"
//                  ],
///                 "media"          :
///                 [
///                     {
///                         "type"                     : "image",
///                         "subtype"                  : "photo",
///                         "caption"                  : "",
///                         "copyright"                : "",
///                         "approved_for_syndication" : 1,
///                         "media-metadata"           :
///                         [
///                             {
///                                 "url"    : "https:\/\/static01.nyt.com\/images\/2017\/11\/07\/....png",
///                                 "format" : "Large Thumbnail",
///                                 "height" : 150,
///                                 "width"  : 150
///                             },
///                             {
///                                 "url"    : "https:\/\/static01.nyt.com\/images\/2017\/11\/07\/....png",
///                                 "format" : "square640",
///                                 "height" : 640,
///                                 "width"  : 640
///                             },
///                             ... <N 'media-metadata' items>
///                         ]
///                     }
///                 ]
///             },
///             ... <M 'results' items>
///         ]
///     }
///
/// This format is parsed in a hard-coded way and assumptions about the format are made.  This is acceptable for this
/// demo, but not for production quality code.
class WebArticlesSource: ArticlesSourceProtocol
{
    private let urlString = "https://api.nytimes.com/svc/mostpopular/v2/mostviewed/all-sections/7.json?apikey=6f1888ceb12041799e62181b35463f6b"

    private var webInterface: WebInterfaceProtocol

    init(webInterface: WebInterfaceProtocol)
    {
        self.webInterface = webInterface
    }

    func getArticles(completion: @escaping (_ articles: [ArticleModel]?, _ error: String?) -> ())
    {
        webInterface.getRequest(toUrlString: urlString)
        { (data, error) in
            guard error == nil else
            {
                completion(nil, error);

                return
            }

            guard let data = data else
            {
                completion(nil, "No data received")

                return
            }

            var object: AnyObject
            do
            {
                object = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
            }
            catch let error
            {
                completion(nil, error.localizedDescription)

                return
            }

            if let dictionary = object as? Dictionary, dictionary["status"] as? String == "OK"
            {
                if let results = dictionary["results"] as? [Dictionary]
                {
                    let articles = results.map
                    {
                        // It's assumed that all element, except the images, are always present. Yet, as a safegaurd,
                        // they are sinked to "" in case this assumption fails.
                        return ArticleModel(url:          $0["url"] as? String ?? "",
                                            section:      $0["section"] as? String ?? "",
                                            byline:       $0["byline"] as? String ?? "",
                                            title:        $0["title"] as? String ?? "",
                                            abstract:     $0["abstract"] as? String ?? "",
                                            date:         $0["published_date"] as? String ?? "",
                                            source:       $0["source"] as? String ?? "",
                                            thumbnailUrl: self.getThumbnailUrl(from: $0),
                                            imageUrl:     self.getImageUrl(from: $0))
                    }

                    completion(articles, nil)
                }
            }
            else
            {
                completion(nil, "Error getting data from NYT")
            }
        }
    }

    /// Gets optional image URL of 150x150.
    ///
    /// - Parameter result: Data as received from NYT.
    /// - Returns:          URL to online image, or `nil`.
    private func getThumbnailUrl(from result: Dictionary) -> String?
    {
        return self.getImageUrlWithFormat("Large Thumbnail", from: result)
    }

    /// Gets optional image URL of 640x640.
    ///
    /// - Parameter result: Data as received from NYT.
    /// - Returns:          URL to online image, or `nil`.
    private func getImageUrl(from result: Dictionary) -> String?
    {
        return self.getImageUrlWithFormat("square640", from: result)
    }

    /// Descends in NYT's nested data to find the image URL marked with the supplied `format`.
    ///
    /// - Parameters:
    ///   - format: The NYT data's format specifier of the wanted image.
    ///   - result: Data as received from NYT.
    /// - Returns:  URL to online image that conform to supplied `format`, or `nil`.
    private func getImageUrlWithFormat(_ format: String, from result: Dictionary) -> String?
    {
        if let media    = result["media"] as? [Dictionary],
            let metadata = media[0]["media-metadata"] as? [Dictionary],
            let item     = (metadata.filter { $0["format"] as? String == format }).first
        {
            return item["url"] as? String
        }
        else
        {
            return nil
        }
    }
}
