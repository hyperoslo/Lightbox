import UIKit

public class LightboxViewCell: UICollectionViewCell {

  public static let reuseIdentifier: String = "LightboxViewCell"

  var lightboxView: LightboxView?

  public func configureCell(image: UIImage) {
    if lightboxView == nil {
      lightboxView = LightboxView(frame: bounds,
        image: image)
    }

    contentView.addSubview(lightboxView!)
  }
}
