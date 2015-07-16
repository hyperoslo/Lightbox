import UIKit

class LightboxTransition: NSObject {

  struct Timing {
    static let transition: NSTimeInterval = 0.5
  }

  var presentingViewController = false

  func transition(controller: LightboxController, show: Bool) {
    controller.view.backgroundColor = show ? .blackColor() : .clearColor()
    controller.view.alpha = show ? 1 : 0
    controller.collectionView.alpha = show ? 1 : 0
    controller.collectionView.transform = show ? CGAffineTransformIdentity : CGAffineTransformMakeScale(0.5, 0.5)
    controller.pageLabel.transform = show ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, 100)
    controller.closeButton.transform = show ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, -100)
  }
}

// MARK: Transitioning delegate

extension LightboxTransition : UIViewControllerAnimatedTransitioning {

  func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
    return Timing.transition
  }

  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    let containerView = transitionContext.containerView()
    let duration = transitionDuration(transitionContext)

    let screens : (from: UIViewController, to: UIViewController) = (
      transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!,
      transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!)

    let lightboxViewController = !presentingViewController
      ? screens.from as! LightboxController
      : screens.to as! LightboxController

    let viewController = !presentingViewController
      ? screens.to as UIViewController
      : screens.from as UIViewController

    [viewController, lightboxViewController].map { containerView.addSubview($0.view) }

    if presentingViewController {
      transition(lightboxViewController, show: false)
    }

    UIView.animateWithDuration(Timing.transition, animations: { [unowned self] in
      self.transition(lightboxViewController, show: self.presentingViewController)
      }, completion: { _ in
        transitionContext.completeTransition(true)
        UIApplication.sharedApplication().keyWindow!.addSubview(screens.to.view)
    })
  }
}

// MARK: Transition delegate

extension LightboxTransition : UIViewControllerTransitioningDelegate {

  func animationControllerForPresentedController(presented: UIViewController,
    presentingController presenting: UIViewController,
    sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
      presentingViewController = true
      return self
  }

  func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    presentingViewController = false
    return self
  }
}
