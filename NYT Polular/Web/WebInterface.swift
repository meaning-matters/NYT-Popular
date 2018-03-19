//
//  WebInterface.swift
//  NYT Polular
//
//  Created by Cornelis van der Bent on 17/03/2018.
//  Copyright © 2018 Cornelis. All rights reserved.
//

import Foundation

/// Protocol for GETing data from an URL.
protocol WebInterfaceProtocol
{
    /// Loads data from the specified URL string.
    ///
    /// Loading is done on a background thread.
    ///
    /// - Parameters:
    ///   - urlString:  The URL string to load.
    ///   - completion: Called on the main thread when loading has finished or failed. Passes data or an error string.
    /// - Returns:      The session task that performs the load.
    @discardableResult func getRequest(toUrlString urlString: String,
                                       completion: @escaping(Data?, String?) -> Void) -> URLSessionDataTask
}

/// Class to perform web requests.
class WebInterface: WebInterfaceProtocol
{
    @discardableResult func getRequest(toUrlString urlString: String,
                                       completion: @escaping(Data?, String?) -> Void) -> URLSessionDataTask
    {
        let url     = URL(string: urlString)! // TODO: Check `url`; currently assume it's never `nil`.
        var request = URLRequest(url: url)

        // TODO: For this demo only, to make sure we always reload fresh data.
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        let dataTask = URLSession.shared.dataTask(with: request, completionHandler:
        { (data, response, error) in
            DispatchQueue.main.async
            {
                if let error = error
                {
                    completion(nil, error.localizedDescription)
                }
                else
                {
                    completion(data, nil)
                }
            }
        })

        dataTask.resume()

        return dataTask
    }
}
