import UIKit

open class LightboxImage {

  open fileprivate(set) var image: UIImage?
  open fileprivate(set) var imageURL: URL?
  open fileprivate(set) var videoURL: URL?
  open fileprivate(set) var panoramaMode: Bool
  open var text: String

  // MARK: - Initialization

    public init(image: UIImage, text: String = "", videoURL: URL? = nil, panoramaMode: Bool = false) {
    self.image = image
    self.text = text
    self.videoURL = videoURL
    self.panoramaMode = panoramaMode
  }

    public init(imageURL: URL, text: String = "", videoURL: URL? = nil, panoramaMode: Bool = false ) {
    self.imageURL = imageURL
    self.text = text
    self.videoURL = videoURL
    self.panoramaMode = panoramaMode
  }

  open func addImageTo(_ imageView: UIImageView, completion: ((_ image: UIImage?) -> Void)? = nil) {
    if let image = image {
      imageView.image = image
      completion?(image)
    } else if let imageURL = imageURL {
      LightboxConfig.loadImage(imageView, imageURL) { [weak self] error, image in
        self?.image = image
        completion?(image)
      }
    }
  }
}
