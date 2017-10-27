import UIKit
import Imaginary

open class LightboxImage {

  open fileprivate(set) var image: UIImage?
  open fileprivate(set) var imagePlaceholder: UIImage?
  open fileprivate(set) var imageURL: URL?
  open fileprivate(set) var videoURL: URL?
  open var text: String
    
  open fileprivate(set) var httpHeaders: [String: String]?

  // MARK: - Initialization

  public init(image: UIImage, text: String = "", videoURL: URL? = nil) {
    self.image = image
    self.text = text
    self.videoURL = videoURL
  }

  public init(imageURL: URL, imagePlaceholder: UIImage? = nil, text: String = "", videoURL: URL? = nil, httpHeaders: [String: String]? = nil) {
    self.imageURL = imageURL
    self.imagePlaceholder = imagePlaceholder
    self.text = text
    self.videoURL = videoURL
    self.httpHeaders = httpHeaders
  }

  open func addImageTo(_ imageView: UIImageView, completion: ((_ image: UIImage?) -> Void)? = nil) {
    if let placeholder = imagePlaceholder {
        imageView.image = placeholder
    }
    
    if let image = image {
      imageView.image = image
      completion?(image)
    } else if let imageURL = imageURL {
        LightboxConfig.loadImage(imageView, imageURL, httpHeaders) { error, image in
            completion?(image)
        }
    }
  }
}
