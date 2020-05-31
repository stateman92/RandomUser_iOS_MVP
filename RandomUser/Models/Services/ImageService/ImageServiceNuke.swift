//
//  ImageServiceNuke.swift
//  RandomUser
//
//  Created by Kálai Kristóf on 2020. 05. 31..
//  Copyright © 2020. Kálai Kristóf. All rights reserved.
//

import UIKit
import Nuke

class ImageServiceNuke: ImageServiceProtocol {
    
    func load(url: URL, into imageView: UIImageView, completionHandler: @escaping () -> ()) {
        
        let options = ImageLoadingOptions(
            transition: .fadeIn(duration: 0.33)
        )
        Nuke.loadImage(with: url, options: options, into: imageView) { result in
            completionHandler()
        }
    }
}
