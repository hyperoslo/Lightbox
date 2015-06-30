import UIKit

class LightboxViewCell: UICollectionViewCell {

  static let reuseIdentifier: String = "LightboxViewCell"

  var lightboxView: LightboxView?

  func configureCell(image: UIImage) {
    if lightboxView == nil {
      lightboxView = LightboxView(frame: bounds,
        image: image)
    }

    contentView.addSubview(lightboxView!)
  }
}
