//
//  ImageLoadingService.swift
//  MarketPilot
//
//  Created by ömer kumek on 7.07.2026.
//

import Foundation
import UIKit

protocol ImageLoadingServiceProtocol {
    func loadImage(from imageURLString: String) async throws -> UIImage
}

final class ImageLoadingService: ImageLoadingServiceProtocol {
    private let imageCache = NSCache<NSString, UIImage>()


    func loadImage(from imageURLString: String) async throws -> UIImage {

        let cachedImage = imageCache.object(forKey: imageURLString as NSString)
        if let cachedImage = cachedImage {
            return cachedImage
        }



        guard let url = URL(string: imageURLString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }

        let cacheKey = imageURLString as NSString
        imageCache.setObject(image, forKey: cacheKey)


        return image
    }
}

