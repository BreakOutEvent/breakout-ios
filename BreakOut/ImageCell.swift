//
//  ImageCell.swift
//  BreakOut
//
//  Created by Mathias Quintero on 5/16/17.
//  Copyright © 2017 BreakOut. All rights reserved.
//

import UIKit
import Sweeft

@objc class StoryImageCell: UICollectionViewCell {
    
    let imageView: UIImageView
    
    var image: Image? {
        didSet {
            guard oldValue?.id != image?.id else {
                return
            }
            image >>> { image in
                self.imageView.image = image.image
            }
        }
    }
    
    override init(frame: CGRect) {
        imageView = UIImageView(frame: frame.atZero)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        super.init(frame: frame)
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

