//
//  WebInterface.swift
//  NYT Polular
//
//  Created by Cornelis van der Bent on 17/03/2018.
//  Copyright © 2018 Cornelis. All rights reserved.
//

import Foundation

protocol WebInterfaceProtocol
{
    func getRequest(toUrlString urlString: String, completion: @escaping(Data?, String?) -> Void)
}

/// Class to perform web requests.
class WebInterface: WebInterfaceProtocol
{
    /// Performs a GET request on background thread.
    ///
    /// - Parameters:
    ///   - urlString:  The URL that needs to be loaded in string format.
    ///   - completion: Called on the main thread to supply the result object, or an error string.
    func getRequest(toUrlString urlString: String, completion: @escaping(Data?, String?) -> Void)
    {
        let url     = URL(string: urlString)! // TODO: Check `url`; currently assume it's never `nil`.
        var request = URLRequest(url: url)

        // TODO: For this demo only, to make sure we always reload fresh data.
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        URLSession.shared.dataTask(with: request, completionHandler:
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
        }).resume()
    }
}
