//
//  UserDetailsViewController.swift
//  RandomUser
//
//  Created by Kálai Kristóf on 2020. 05. 12..
//  Copyright © 2020. Kálai Kristóf. All rights reserved.
//

import UIKit
import SkeletonView
import Hero

// MARK: - The main ViewController base part.
class UserDetailsViewController: UIViewController {
    
    var user: User!
    private let imageServiceContainer: ImageServiceContainerProtocol = ImageServiceContainer(.nuke)
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userAccessibilitiesLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
}

// MARK: - UIViewController lifecycle part.
extension UserDetailsViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isSkeletonable = true
        userImageView.isSkeletonable = true
        
        navigationItem.title = "\(user.fullName) (\(user.gender))"
        fillLayoutWithData()
        
        userImageView.hero.id = HeroIDs.imageEnlarging.rawValue
        userAccessibilitiesLabel.hero.id = HeroIDs.textEnlarging.rawValue
    }
}

// MARK: - Additional UI-related functions, methods.
extension UserDetailsViewController {
    
    private func fillLayoutWithData() {
        userAccessibilitiesLabel.text = user.accessibilities
        userLocationLabel.text = user.expandedLocation
        userImageView.backgroundColor = .darkGray
        
        // The placeholder will be a SkeletonView, something like Facebook.
        let gradient = SkeletonGradient(baseColor: .darkGray)
        userImageView.showAnimatedGradientSkeleton(usingGradient: gradient, transition: .crossDissolve(1))
        
        imageServiceContainer.load(url: user.picture.large, into: userImageView, withDelay: 2.0) {
            self.userImageView.hideSkeleton()
        }
    }
}
