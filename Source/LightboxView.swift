import UIKit

class LightboxView: UIScrollView {

  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
  }()

  var imageConstraintTop: NSLayoutConstraint!
  var imageConstraintRight: NSLayoutConstraint!
  var imageConstraintLeft: NSLayoutConstraint!
  var imageConstraintBottom: NSLayoutConstraint!

  var lastZoomScale: CGFloat = -1

  init(frame: CGRect, image: UIImage) {
    super.init(frame: frame)
    imageView.image = image
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
