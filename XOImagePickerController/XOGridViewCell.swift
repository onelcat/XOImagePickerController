/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implements the collection view cell for displaying an asset in the grid view.
*/

import UIKit
import PhotosUI

class XOGridViewCell: UICollectionViewCell {
    
    private
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private
    lazy var livePhotoBadgeImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private
    lazy var gifPhotoBadgeImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private
    lazy var videoPhotoBadgeImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private
    lazy var videoLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private
    lazy var livePhotoBadgeImage: UIImage? = {
        if #available(iOS 9.1, *) {
            let image = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
            return image
        } else {
            return nil
        }
    }()
    
    private
    lazy var gifPhotoBadgeImage: UIImage? = {
        if #available(iOS 9.1, *) {
            let image = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
            return image
        } else {
            return nil
        }
    }()
    
    private
    lazy var videoPhotoBadgeImage: UIImage? = {
        if #available(iOS 9.1, *) {
            let image = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
            return image
        } else {
            return nil
        }
    }()
    
    var representedAssetIdentifier: String!
    
    var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage
        }
    }
    
    var mediaType: MediaType = .image
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.frame = contentView.bounds
        contentView.addSubview(imageView)
        
//        addSubview(imageView)
//        imageView.frame = bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        gifPhotoBadgeImageView.image = nil
        livePhotoBadgeImageView.image = nil
        videoPhotoBadgeImageView.image = nil
    }
}
