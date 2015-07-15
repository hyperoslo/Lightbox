import UIKit

class LightboxTransition: NSObject {

  struct Timing {
    static let Transition: NSTimeInterval = 0.4
  }

  var presentingViewController = false

  func dismissLightbox(controller: LightboxController) {
    controller.view.backgroundColor = UIColor.clearColor()
    controller.view.alpha = 0
    controller.collectionView.alpha = 0
    controller.collectionView.transform = CGAffineTransformMakeScale(0.5, 0.5)
    controller.pageLabel.transform = CGAffineTransformMakeTranslation(0, 100)
    controller.closeButton.transform = CGAffineTransformMakeTranslation(0, -100)
  }

  func showLightbox(controller: LightboxController) {
    controller.view.backgroundColor = UIColor.blackColor()
    controller.view.alpha = 1
    controller.collectionView.alpha = 1
    controller.collectionView.transform = CGAffineTransformIdentity
    controller.pageLabel.transform = CGAffineTransformIdentity
    controller.closeButton.transform = CGAffineTransformIdentity
  }
}

// MARK: Transitioning delegate

extension LightboxTransition : UIViewControllerAnimatedTransitioning {

  func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
    return Timing.Transition
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

    containerView.addSubview(viewController.view)
    containerView.addSubview(lightboxViewController.view)

    if presentingViewController {
      dismissLightbox(lightboxViewController)
    }

    UIView.animateWithDuration(Timing.Transition, animations: { [unowned self] in
      self.presentingViewController
        ? self.showLightbox(lightboxViewController)
        : self.dismissLightbox(lightboxViewController)

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
