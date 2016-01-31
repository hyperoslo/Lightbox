import UIKit

public class LightboxImage {

  var image: UIImage?
  var imageURL: NSURL?
  var text: String

  // MARK: - Initialization

  public init(image: UIImage, text: String = "") {
    self.image = image
    self.text = text
  }

  public init(imageURL: NSURL, text: String = "") {
    self.imageURL = imageURL
    self.text = text
  }

  public func addImageTo(imageView: UIImageView, completion: (() -> Void)? = nil) {
    if let image = image {
      imageView.image = image
    } else if let imageURL = imageURL {
      LightboxModel.loadImage(imageView: imageView, URL: imageURL) { error in
        completion?()
      }
    }
  }
}
