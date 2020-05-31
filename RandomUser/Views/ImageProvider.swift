//
//  ImageProvider.swift
//  RandomUser
//
//  Created by Kálai Kristóf on 2020. 05. 31..
//  Copyright © 2020. Kálai Kristóf. All rights reserved.
//

import UIKit
import Nuke
import Kingfisher
import SDWebImage

// MARK: - A class that loads images into `UIImageView`s.
class ImageProvider {
    
    /// This class currently supports the 3 major imageloader external libraries.
    enum ProviderType {
        case nuke
        case kingfisher
        case sdwebimage
    }
    
    /// Load an url into the image.
    /// - Parameters:
    ///   - urlString: the url in string format of the image.
    ///   - imageView: the `UIImageView` that will hold the image.
    ///   - completionHandler: will be called after the image loaded (optional parameter).
    ///   - type: the type of the used library (optional parameter, by default it uses Nuke).
    ///   - withDelay: seconds, after the image loading will start  (optional parameter, by default it is 0, so starts immediately).
    ///   - isLoadingPresenting: whether it shows a loading animation before it loaded (optional parameter, by default it is false).
    func load(url urlString: String, into imageView: UIImageView, completionHandler: @escaping () -> () = { }, type: ProviderType = .nuke, withDelay delay: Double = 0.0, isLoadingPresenting loading: Bool = false) {
        
        var activityIndicator: UIActivityIndicatorView? = nil
        if loading {
            activityIndicator = imageView.setActivityIndicator()
        }
        
        let url = URL(string: urlString)!
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            switch type {
            case .nuke:
                let options = ImageLoadingOptions(
                    transition: .fadeIn(duration: 0.33)
                )
                Nuke.loadImage(with: url, options: options, into: imageView) { result in
                    self.loaded(activityIndicator, completionHandler)
                }
            case .kingfisher:
                imageView.kf.indicatorType = .activity
                imageView.kf.setImage(with: url) { result in
                    self.loaded(activityIndicator, completionHandler)
                }
            case .sdwebimage:
                imageView.sd_setImage(with: url) { (uiimage, error, cacheType, url) in
                    self.loaded(activityIndicator, completionHandler)
                }
            }
        }
    }
    
    private func loaded(_ activityIndicator: UIActivityIndicatorView?, _ completion: () -> () = { }) {
        activityIndicator?.stopAnimating()
        completion()
    }
}
