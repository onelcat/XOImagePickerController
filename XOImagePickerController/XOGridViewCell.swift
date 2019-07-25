/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implements the collection view cell for displaying an asset in the grid view.
*/

import UIKit
import PhotosUI

class XOGridViewCell: UICollectionViewCell {
    
    private
    lazy var _imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    // 暂时不需要
    private
    lazy var _livePhotoBadgeImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    // 暂时不需要
    private
    lazy var _gifPhotoBadgeImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private
    lazy var _videoPhotoBadgeImageView: UIImageView = {
        let view = UIImageView()
        view.image = videoPhotoBadgeImage
        return view
    }()
    
    private
    lazy var _videoDurationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.textAlignment = .left
        return label
    }()
    
    private
    lazy var _livePhotoBadgeImage: UIImage? = {
        if #available(iOS 9.1, *) {
            let image = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
            return image
        } else {
            return nil
        }
    }()
    
    private
    lazy var _gifPhotoBadgeImage: UIImage? = {
        if #available(iOS 9.1, *) {
            let image = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
            return image
        } else {
            return nil
        }
    }()
    
    
    
    lazy var selectPhotoButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom)
        return button
    }()
    
//    var selectButtonImage:(UIImage?,UIImage?)! {
//        didSet {
//            _selectButton.setImage(selectButtonImage.0, for: UIControl.State.normal)
//            _selectButton.setImage(selectButtonImage.1, for: UIControl.State.selected)
//        }
//    }
    
    var asset: PHAsset?
    
    var videoPhotoBadgeImage: UIImage?
    
    var representedAssetIdentifier: String!
    
    var didSelectPhotoBlock: ((Bool)->Void)?
    
    var thumbnailImage: UIImage! {
        didSet {
            _imageView.image = thumbnailImage
        }
    }
    
    var mediaType: MediaType = .image {
        didSet {
            switch self.mediaType {
            case let .video(value):
                _videoPhotoBadgeImageView.image = videoPhotoBadgeImage
                _videoDurationLabel.text = XOHelper.formatSecond(Int(value))
                _videoPhotoBadgeImageView.isHidden = false
                _videoDurationLabel.isHidden = false
            default:
                _videoPhotoBadgeImageView.isHidden = true
                _videoDurationLabel.isHidden = true
                break
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _imageView.frame = contentView.bounds
        selectPhotoButton.addTarget(self, action: #selector(__selectPhotoButtonClick(_:)), for: .touchUpInside)
        contentView.addSubview(_imageView)
        contentView.addSubview(_videoPhotoBadgeImageView)
        contentView.addSubview(_videoDurationLabel)
        contentView.addSubview(selectPhotoButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let x:CGFloat = 4
        let height = self.contentView.bounds.height
        let width = self.contentView.bounds.width
        let y: CGFloat = height - 25
        _videoPhotoBadgeImageView.frame = CGRect(x: x, y: y, width: 17, height: 17)
        _videoDurationLabel.frame = CGRect(x: 28, y: y, width: width - 28, height: 17)
        
        selectPhotoButton.frame = CGRect(x: width - 30 - 2, y: 2, width: 30, height: 30)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        _imageView.image = nil
        _gifPhotoBadgeImageView.image = nil
        _livePhotoBadgeImageView.image = nil
        _videoPhotoBadgeImageView.image = nil
    }
}
private
extension XOGridViewCell {
    @objc
    func __selectPhotoButtonClick(_ sender: UIButton?) {
        guard let button = sender,let hander = self.didSelectPhotoBlock else {
            return
        }
        hander(button.isSelected)
    }
}
