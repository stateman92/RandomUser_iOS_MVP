//
//  ImageProvider.swift
//  RandomUser
//
//  Created by Kálai Kristóf on 2020. 05. 31..
//  Copyright © 2020. Kálai Kristóf. All rights reserved.
//

import UIKit

// MARK: - A class that manages the imageloader dependencies.
class ImageServiceContainer: ImageServiceContainerProtocol {
    
    /// This class currently supports the 3 major imageloader external libraries.
    enum ISType {
        case nuke
        case kingfisher
        case sdwebimage
    }
    
    private let service: ImageServiceProtocol
    
    init(_ imageServiceType: ISType) {
        switch imageServiceType {
        case .nuke:
            service = ImageServiceNuke()
        case .kingfisher:
            service = ImageServiceKingfisher()
        case .sdwebimage:
            service = ImageServiceSDWebImage()
        }
    }
    
    /// Load an url into the image.
    /// - Parameters:
    ///   - urlString: the url in string format of the image.
    ///   - imageView: the `UIImageView` that will hold the image.
    ///   - completionHandler: will be called after the image loaded (optional parameter).
    ///   - type: the type of the used library (optional parameter, by default it uses Nuke).
    ///   - withDelay: seconds, after the image loading will start  (optional parameter, by default it is 0, so starts immediately).
    ///   - isLoadingPresenting: whether it shows a loading animation before it loaded (optional parameter, by default it is false).
    func load(url urlString: String, into imageView: UIImageView, withDelay delay: Double, isLoadingPresenting loading: Bool, completionHandler: @escaping () -> Void = { }) {
        
        var activityIndicator: UIActivityIndicatorView? = nil
        if loading {
            activityIndicator = imageView.setActivityIndicator()
        }
        
        guard let url = URL(string: urlString) else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.service.load(url: url, into: imageView) {
                self.loaded(activityIndicator, completionHandler)
            }
        }
    }
    
    private func loaded(_ activityIndicator: UIActivityIndicatorView?, _ completion: () -> () = { }) {
        activityIndicator?.stopAnimating()
        completion()
    }
}
