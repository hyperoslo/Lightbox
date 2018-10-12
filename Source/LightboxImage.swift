import UIKit
import Imaginary

open class LightboxImage {

  open fileprivate(set) var image: UIImage?
  open fileprivate(set) var imageURL: URL?
  open fileprivate(set) var videoURL: URL?
  open fileprivate(set) var panoramaMode: Bool
  open fileprivate(set) var imageClosure: (() -> UIImage)?
  open var text: String

  // MARK: - Initialization

  internal init(text: String = "") {
    self.text = text
    self.panoramaMode = false
  }

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

  public init(imageClosure: @escaping () -> UIImage, text: String = "", videoURL: URL? = nil) {
    self.imageClosure = imageClosure
    self.text = text
    self.videoURL = videoURL
    self.panoramaMode = false
  }

  open func addImageTo(_ imageView: UIImageView, completion: ((UIImage?) -> Void)? = nil) {
    if let image = image {
      imageView.image = image
      completion?(image)
    } else if let imageURL = imageURL {
      LightboxConfig.loadImage(imageView, imageURL) { [weak self] image in
            self?.image = image
            completion?(image)
        }
    } else if let imageClosure = imageClosure {
      let img = imageClosure()
      imageView.image = img
      completion?(img)
    } else {
      imageView.image = nil
      completion?(nil)
    }
  }
}
