import UIKit

extension UIView {

  public func addGradientLayer(colors: [UIColor]) -> CAGradientLayer {
    if let gradientLayer = gradientLayer { return gradientLayer }

    let gradient = CAGradientLayer()

    gradient.frame = bounds
    gradient.colors = colors.map { $0.CGColor }
    layer.insertSublayer(gradient, atIndex: 0)

    return gradient
  }

  public func removeGradientLayer() -> CAGradientLayer? {
    gradientLayer?.removeFromSuperlayer()

    return gradientLayer
  }

  public func resizeGradientLayer() {
    gradientLayer?.frame = bounds
  }

  private var gradientLayer: CAGradientLayer? {
    return layer.sublayers?.first as? CAGradientLayer
  }
}
