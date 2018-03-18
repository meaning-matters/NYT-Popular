//
//  WebArticlesSource.swift
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
///                     },
///                     ... <M 'media' items>
///                 ]
///             },
///             ... <R 'results' items>
///         ]
///     }
///
class WebArticlesSource: ArticlesSourceProtocol
{
    struct MostViewed: Codable
    {
        struct Result: Codable
        {
            var url:            String
            var section:        String
            var byline:         String
            var title:          String
            var abstract:       String
            var published_date: String
            var source:         String

            struct Media: Codable
            {
                struct Metadata: Codable
                {
                    var url:    String
                    var format: String
                }

                var type:     String
                var metadata: [Metadata]

                private enum CodingKeys: String, CodingKey
                {
                    case type     = "type"
                    case metadata = "media-metadata"
                }
            }

            var media: [Media]
        }

        var status:  String
        var results: [Result]
    }

    private let urlString = "https://api.nytimes.com/svc/mostpopular/v2/mostviewed/all-sections/7.json?apikey=6f1888ceb12041799e62181b35463f6b"

    private var webInterface: WebInterfaceProtocol

    init(webInterface: WebInterfaceProtocol)
    {
        self.webInterface = webInterface
    }

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

            guard let patchedData = self.patchData(data) else
            {
                completion(nil, "Invalid data received")

                return
            }

            do
            {
                let mostViewed = try JSONDecoder().decode(MostViewed.self, from: patchedData)

                if mostViewed.status == "OK"
                {
                    let articles = mostViewed.results.map
                    {
                        return ArticleModel(url:          $0.url,
                                            section:      $0.section,
                                            byline:       $0.byline,
                                            title:        $0.title,
                                            abstract:     $0.abstract,
                                            date:         $0.published_date,
                                            source:       $0.source,
                                            thumbnailUrl: self.getThumbnailUrl(from: $0),
                                            imageUrl:     self.getImageUrl(from: $0))
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

    /// Patches JSON to work around format design issue.
    ///
    /// There's a design issue with NYT's JSON format: When there are no images, the "media" is not an empty array as
    /// you'd expect, but an empty string instead.  This means that the data type of "media"'s value changes.  To
    /// allow the use of Swift 4's Decodable classes for easy JSON parsing, this issue is patched here.
    private func patchData(_ data: Data) -> Data?
    {
        var string = String(data: data, encoding: .utf8)

        // Replace occurences of empty "media" as string, with an empty array.
        string?.replaceMatches(of: "\"media\":\"\"", with: "\"media\":[]")

        return string?.data(using: .utf8)
    }

    /// Gets optional image URL of 150x150.
    ///
    /// - Parameter result: Data as received from NYT.
    /// - Returns:          URL to online image, or `nil`.
    private func getThumbnailUrl(from result: MostViewed.Result) -> String?
    {
        return self.getImageUrlWithFormat("Large Thumbnail", from: result)
    }

    /// Gets optional image URL of 640x640.
    ///
    /// - Parameter result: Data as received from NYT.
    /// - Returns:          URL to online image, or `nil`.
    private func getImageUrl(from result: MostViewed.Result) -> String?
    {
        return self.getImageUrlWithFormat("square640", from: result)
    }

    /// Descends in NYT's nested data to find the image URL marked with the supplied `format`.
    ///
    /// - Parameters:
    ///   - format: The NYT data's format specifier of the wanted image.
    ///   - result: Data as received from NYT.
    /// - Returns:  URL to online image that conform to supplied `format`, or `nil`.
    private func getImageUrlWithFormat(_ format: String, from result: MostViewed.Result) -> String?
    {
        if let images   = (result.media.filter { $0.type == "image" }).first,
           let metadata = (images.metadata.filter { $0.format == format }).first
        {
            return metadata.url
        }
        else
        {
            return nil
        }
    }
}
