import UIKit

public class LightboxTransition: UIPercentDrivenInteractiveTransition {

  public lazy var panGestureRecognizer: UIPanGestureRecognizer = { [unowned self] in
    let gesture = UIPanGestureRecognizer()
    gesture.addTarget(self, action: "handlePanGesture:")

    return gesture
    }()

  var interactive = false
  var dismissing = false
  var initialOrigin = CGPoint(x: 0, y: 0)

  public var scrollView: UIScrollView? {
    didSet {
      guard let scrollView = scrollView else { return }
      scrollView.addGestureRecognizer(panGestureRecognizer)
    }
  }

  public var lightboxController: LightboxController?

  // MARK: - Pan gesture recognizer

  func handlePanGesture(gesture: UIPanGestureRecognizer) {
    let translation = gesture.translationInView(scrollView)
    let percentage: CGFloat = 0.5

    switch panGestureRecognizer.state {
    case .Began:
      lightboxController?.dismissViewControllerAnimated(true, completion: nil)
      interactive = true
      if let origin = scrollView?.frame.origin { initialOrigin = origin }

      break
    case .Changed:
      updateInteractiveTransition(percentage)
      scrollView?.frame.origin.y = initialOrigin.y + translation.x

      break
    default:
      interactive = false
      percentage > 0.5 ? finishInteractiveTransition() : cancelInteractiveTransition()

      break
    }
  }
}

extension LightboxTransition: UIViewControllerAnimatedTransitioning {

  public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return 0.5
  }

  public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
//    // get reference to our fromView, toView and the container view that we should perform the transition in
//    let container = transitionContext.containerView()
//
//    // create a tuple of our screens
//    let screens : (from:UIViewController, to:UIViewController) = (transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!, transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!)
//
//    // assign references to our menu view controller and the 'bottom' view controller from the tuple
//    // remember that our menuViewController will alternate between the from and to view controller depending if we're presenting or dismissing
//    let menuViewController = !self.presenting ? screens.from as MenuViewController : screens.to as MenuViewController
//    let topViewController = !self.presenting ? screens.to as UIViewController : screens.from as UIViewController
//
//    let menuView = menuViewController.view
//    let topView = topViewController.view
//
//    // prepare menu items to slide in
//    if (self.presenting){
//      self.offStageMenuControllerInteractive(menuViewController) // offstage for interactive
//    }
//
//    // add the both views to our view controller
//
//    container.addSubview(menuView)
//    container.addSubview(topView)
//    container.addSubview(self.statusBarBackground)
//
//    let duration = self.transitionDuration(transitionContext)
//
//    // perform the animation!
//    UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: nil, animations: {
//
//      if (self.presenting){
//        self.onStageMenuController(menuViewController) // onstage items: slide in
//        topView.transform = self.offStage(290)
//      }
//      else {
//        topView.transform = CGAffineTransformIdentity
//        self.offStageMenuControllerInteractive(menuViewController)
//      }
//
//      }, completion: { finished in
//
//        // tell our transitionContext object that we've finished animating
//        if(transitionContext.transitionWasCancelled()){
//
//          transitionContext.completeTransition(false)
//          // bug: we have to manually add our 'to view' back http://openradar.appspot.com/radar?id=5320103646199808
//          UIApplication.sharedApplication().keyWindow.addSubview(screens.from.view)
//
//        }
//        else {
//
//          transitionContext.completeTransition(true)
//          // bug: we have to manually add our 'to view' back http://openradar.appspot.com/radar?id=5320103646199808
//          UIApplication.sharedApplication().keyWindow.addSubview(screens.to.view)
//
//        }
//        UIApplication.sharedApplication().keyWindow.addSubview(self.statusBarBackground)
//        
//    })
  }
}

extension LightboxTransition: UIViewControllerTransitioningDelegate {

  public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    dismissing = true
    return self
  }

  public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    dismissing = false
    return self
  }

  public func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactive ? self : nil
  }

  public func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactive ? self : nil
  }
}
