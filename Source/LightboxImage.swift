import UIKit
//import Imaginary

open class LightboxImage {

  open fileprivate(set) var image: UIImage?
  open fileprivate(set) var imagePlaceholder: UIImage?
  open fileprivate(set) var imageURL: URL?
  open fileprivate(set) var videoURL: URL?
  open fileprivate(set) var imageClosure: (() -> UIImage)?
  open var text: String
    
  open fileprivate(set) var httpHeaders: [String: String]?

  // MARK: - Initialization

  internal init(text: String = "") {
    self.text = text
  }

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

  public init(imageClosure: @escaping () -> UIImage, text: String = "", videoURL: URL? = nil) {
    self.imageClosure = imageClosure
    self.text = text
    self.videoURL = videoURL
  }

  open func addImageTo(_ imageView: UIImageView, completion: ((UIImage?) -> Void)? = nil) {
    if let image = image {
      imageView.image = image
      completion?(image)
    } else if let imageURL = imageURL {
//        LightboxConfig.loadImage(imageView, imageURL, httpHeaders) { error, image in
//            if error != nil {
//                completion?(nil)
//            } else {
//                completion?(image)
//            }
//        }
      LightboxConfig.loadImage(imageView, imageURL, httpHeaders, completion)
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
