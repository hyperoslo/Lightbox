import UIKit

extension UIView {

  public func addGradientLayer(colors: [UIColor]) -> CAGradientLayer {
    if let gradientLayer = gradientLayer { return gradientLayer }

    let gradient = CAGradientLayer()
    var gradientColors = [CGColor]()
    for color in colors {
      gradientColors.append(color.CGColor)
    }

    gradient.frame = bounds
    gradient.colors = gradientColors
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
    return layer.sublayers?[0] as? CAGradientLayer
  }
}
