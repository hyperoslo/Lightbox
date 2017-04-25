import UIKit

extension UIView {

  @discardableResult func addGradientLayer(_ colors: [UIColor]) -> CAGradientLayer {
    if let gradientLayer = gradientLayer { return gradientLayer }

    let gradient = CAGradientLayer()

    gradient.frame = bounds
    gradient.colors = colors.map { $0.cgColor }
    layer.insertSublayer(gradient, at: 0)

    return gradient
  }

  func removeGradientLayer() -> CAGradientLayer? {
    gradientLayer?.removeFromSuperlayer()

    return gradientLayer
  }

  func resizeGradientLayer() {
    gradientLayer?.frame = bounds
  }

  fileprivate var gradientLayer: CAGradientLayer? {
    return layer.sublayers?.first as? CAGradientLayer
  }
}
