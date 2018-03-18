//
//  WebImageCache.swift
//  NYT Polular
//
//  Created by Cornelis van der Bent on 17/03/2018.
//  Copyright © 2018 Cornelis. All rights reserved.
//

import Foundation
import UIKit

protocol WebImageCacheProtocol
{
    func getImage(at urlString: String, completion: @escaping (UIImage?) -> ())

    func flush()
}

/// Local cache of images downloaded from the web.
class WebImageCache: WebImageCacheProtocol
{
    private var webInterface: WebInterfaceProtocol

    private var dataTasks   = [String : URLSessionDataTask]()
    private var completions = [String : [(UIImage?) -> ()]]()
    private var images      = [String : UIImage]()

    init(webInterface: WebInterfaceProtocol)
    {
        self.webInterface = webInterface
    }

    /// Returns image from local cache if it's been downloaded earlier, otherwise returns the image after it has been
    /// downloaded. The image is downloaded on background thread.
    ///
    /// If an image, that's being downloaded, is requested multiple times, there will still be only one download task.
    /// Once that task completes, all completion handlers for that image will be called.
    ///
    /// This function must be called on the main thread. Calls on other threads are silently ignored.
    ///
    /// TODO: This demo implementation saves all images. For a real app that would store a lot of images, storage size
    ///       could matter and may require a mechanism to free up memory (e.g. by deleting the least recently used
    ///       images).
    ///
    /// - Parameters:
    ///   - urlString:  The URL string from which to download the image.
    ///   - completion: Called on the main thread to supply the image, or `nil` in case of error.
    func getImage(at urlString: String, completion: @escaping (UIImage?) -> ())
    {
        guard Thread.isMainThread else { return }

        if let image = self.images[urlString]
        {
            completion(image)

            return
        }

        self.completions[urlString] = self.completions[urlString] ?? []
        self.completions[urlString]?.append(completion)

        // Leave if the image is already being downloaded.
        if self.dataTasks[urlString] != nil
        {
            return
        }

        self.dataTasks[urlString] = self.webInterface.getRequest(toUrlString: urlString, completion:
        { (data, errorString) in
            if let data = data
            {
                let image = UIImage(data: data)
                self.images[urlString] = image
            }

            for completion in self.completions[urlString] ?? []
            {
                completion(self.images[urlString])
            }

            self.completions[urlString] = nil
            self.dataTasks[urlString]   = nil
        })
    }

    /// Flushes all images from the cache. Pending downloads are cancelled and the completion handlers are no longer
    /// called.
    ///
    /// This function must be called on the main thread. Calls on other threads are silently ignored.Common
    func flush()
    {
        guard Thread.isMainThread else { return }

        for dataTask in self.dataTasks.values
        {
            dataTask.cancel()
        }

        self.dataTasks.removeAll()
        self.completions.removeAll()
        self.images.removeAll()
    }
}
