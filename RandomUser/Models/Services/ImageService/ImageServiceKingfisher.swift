//
//  ImageServiceKingfisher.swift
//  RandomUser
//
//  Created by Kálai Kristóf on 2020. 05. 31..
//  Copyright © 2020. Kálai Kristóf. All rights reserved.
//

import UIKit
import Kingfisher

class ImageServiceKingfisher: ImageServiceProtocol {
    
    func load(url: URL, into imageView: UIImageView, completionHandler: @escaping () -> ()) {
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url) { result in
            completionHandler()
        }
    }
}
