//
//  UIImageView+Ext.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/3.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation

import Kingfisher
import RxCocoa
import RxSwift

typealias ImageOptions = KingfisherOptionsInfo

enum ImageResult {
    case success(UIImage)
    case failure(Error)

    var image: UIImage? {
        if case .success(let image) = self {
            return image
        } else {
            return nil
        }
    }

    var error: Error? {
        if case .failure(let error) = self {
            return error
        } else {
            return nil
        }
    }
}

extension UIImageView {
    @discardableResult
    func setImage(with resource: Resource?,
                  placeholder: UIImage? = nil,
                  options: ImageOptions? = nil,
                  progress: ((Int64, Int64) -> Void)? = nil,
                  completion: ((ImageResult) -> Void)? = nil
        ) -> RetrieveImageTask {
        var options = options ?? []
        // GIF will only animates in the AnimatedImageView
        if self is AnimatedImageView == false {
            options.append(.targetCache(.default))
//            options.append(.transition(.fade(0)))
        }
        let completionHandler: CompletionHandler = { image, error, cacheType, url in
            if let image = image {
                completion?(.success(image))
            } else if let error = error {
                completion?(.failure(error))
            }
        }
        return self.kf.setImage(
            with: resource,
            placeholder: placeholder,
            options: options,
            progressBlock: progress,
            completionHandler: completionHandler
        )
    }
}

extension Reactive where Base: UIImageView {
    func image(placeholder: UIImage? = nil, options: ImageOptions) -> Binder<Resource?> {
        return Binder(self.base) { imageView, resource in
            imageView.setImage(with: resource, placeholder: placeholder, options: options)
        }
    }
}
