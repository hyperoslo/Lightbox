import UIKit

extension UIView {
  
  private func getSafeAreaInsets() -> UIEdgeInsets? {
    if #available(iOS 11, *) {
      return safeAreaInsets
    }
    
    return nil
  }
  
  public func getTopOrigin() -> CGPoint {
    // The size of the iPhone status bar.
    let statusBarHeight: CGFloat = 20
    
    var point = CGPoint(x: 0, y: 0)
    
    let orientation = UIApplication.shared.statusBarOrientation
    
    if let edges = getSafeAreaInsets() {
      var y = edges.top - statusBarHeight
      
      if y < 0 {
        y = 0 // Fix for negative drawing in landscape
      } else if y > 0 {
        /**
         * On phones other than the iPhone X in portrait this value
         * is 0 and the bar draws correctly. On the X, it's partially
         * covered by the notch, so we add a little more padding to it.
         */
        y -= 8
      }
      
      point.y = y
      
      // Add a little of padding in the landscape orientation, due to the notch in iPhone X.
      if orientation == .landscapeLeft || orientation == .landscapeRight {
        point.x = 24
      }
    }
    
    if orientation == .portrait || orientation == .portraitUpsideDown {
      point.y += 32
    } else {
      point.y += 16
    }
    
    return point
  }
  
}

