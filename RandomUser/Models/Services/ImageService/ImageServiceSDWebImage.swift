//
//  ImageServiceSDWebImage.swift
//  RandomUser
//
//  Created by Kálai Kristóf on 2020. 05. 31..
//  Copyright © 2020. Kálai Kristóf. All rights reserved.
//

import Foundation
import SDWebImage

class ImageServiceSDWebImage: ImageServiceProtocol {
    
    func load(url: URL, into imageView: UIImageView, completionHandler: @escaping () -> ()) {
        imageView.sd_setImage(with: url) { (uiimage, error, cacheType, url) in
            completionHandler()
        }
    }
}
