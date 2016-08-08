import UIKit

public class LightboxImage {

  public private(set) var image: UIImage?
  public private(set) var imageURL: NSURL?
  public private(set) var videoURL: NSURL?
  public var text: String

  // MARK: - Initialization

  public init(image: UIImage, text: String = "", videoURL: NSURL? = nil) {
    self.image = image
    self.text = text
    self.videoURL = videoURL
  }

  public init(imageURL: NSURL, text: String = "", videoURL: NSURL? = nil ) {
    self.imageURL = imageURL
    self.text = text
    self.videoURL = videoURL
  }

  public func addImageTo(imageView: UIImageView, completion: ((image: UIImage?) -> Void)? = nil) {
    if let image = image {
      imageView.image = image
    } else if let imageURL = imageURL {
      LightboxConfig.loadImage(imageView: imageView, URL: imageURL) { error, image in
        completion?(image: image)
      }
    }
  }
}
