//
//  UIImageExtension.swift
//  iTunesUpdated
//
//  Created by Jay Patel on 12/12/19.
//  Copyright © 2019 Lake. All rights reserved.
//

import UIKit

import Foundation
import UIKit

extension UIImageView
{
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit)
    {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
