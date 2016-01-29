import UIKit

extension UIView {

  public func setupGradient(colors: [UIColor]) {
    let gradient = CAGradientLayer()
    var gradientColors = [CGColor]()
    for color in colors {
      gradientColors.append(color.CGColor)
    }

    gradient.frame = bounds
    gradient.colors = gradientColors
    layer.insertSublayer(gradient, atIndex: 0)
  }
}
