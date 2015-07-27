import UIKit

class LightboxTransition: NSObject {

  struct Timing {
    static let transition: NSTimeInterval = 0.5
  }

  lazy var panGestureRecognizer: UIPanGestureRecognizer = {
    let panGestureRecognizer = UIPanGestureRecognizer()
    panGestureRecognizer.addTarget(self, action: "handlePanGesture:")

    return panGestureRecognizer
    }()

  var presentingViewController = false
  var interactive = false
  var animator: UIDynamicAnimator!
  var attachmentBehavior: UIAttachmentBehavior!
  var gravityBehaviour: UIGravityBehavior!
  var snapBehavior: UISnapBehavior!

  var sourceViewCell: LightboxViewCell! {
    didSet {
      sourceViewCell.addGestureRecognizer(panGestureRecognizer)
    }
  }

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

  func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return self.interactive ? self : nil
  }

  func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return self.interactive ? self : nil
  }
}

// MARK: Interactive transition delegate

extension LightboxTransition : UIPercentDrivenInteractiveTransition {
  
  func handlePanGesture(panGestureRecognizer: UIPanGestureRecognizer) {
    let imageView = sourceViewCell.lightboxView.imageView
    let location = panGestureRecognizer.locationInView(sourceViewCell.lightboxView)
    let boxLocation = panGestureRecognizer.locationInView(imageView)
    let translation = panGestureRecognizer.translationInView(sourceViewCell.lightboxView)
    let maximumValue = UIScreen.mainScreen().bounds.height
    let calculation = abs(translation.y) / maximumValue
    let alphaValue = 1 - calculation

    sourceViewCell.parentViewController.view.alpha = alphaValue
    sourceViewCell.parentViewController.pageLabel.transform =
      CGAffineTransformMakeTranslation(0, calculation * 100)
    sourceViewCell.parentViewController.closeButton.transform =
      CGAffineTransformMakeTranslation(0, -(calculation * 100))

    if !sourceViewCell.parentViewController.physics {
      if panGestureRecognizer.state == UIGestureRecognizerState.Began {
        animator.removeBehavior(snapBehavior)
        let centerOffset = UIOffsetMake(boxLocation.x - CGRectGetMidX(imageView.bounds),
          boxLocation.y - CGRectGetMidY(imageView.bounds))
        attachmentBehavior = UIAttachmentBehavior(item: imageView,
          offsetFromCenter: centerOffset, attachedToAnchor: location)
        attachmentBehavior.frequency = 0
        animator.addBehavior(attachmentBehavior)
      } else if panGestureRecognizer.state == UIGestureRecognizerState.Changed {
        attachmentBehavior.anchorPoint = location
      } else if panGestureRecognizer.state == UIGestureRecognizerState.Ended {
        animator.removeBehavior(attachmentBehavior)
        snapBehavior = UISnapBehavior(item: imageView,
          snapToPoint: sourceViewCell.lightboxView.center)
        animator.addBehavior(snapBehavior)
        panGestureEnded(translation,
          imageView: imageView)
      }
    } else {
      if panGestureRecognizer.state == .Began || panGestureRecognizer.state == .Changed {
        imageView.center = CGPointMake(imageView.center.x, UIScreen.mainScreen().bounds.height/2 + translation.y)
      } else {
        panGestureEnded(translation, imageView: imageView)
      }
    }
  }

  private func panGestureEnded(translation: CGPoint, imageView: UIView) {
    if translation.y > 150 || translation.y < -150 {
      UIView.animateWithDuration(0.3, animations: {
        imageView.center = CGPointMake(imageView.center.x, 10 * translation.y)
        imageView.alpha = 0
      })
      sourceViewCell.parentViewController.dismissViewControllerAnimated(true, completion: { [unowned self] in
        if self.sourceViewCell.parentViewController.physics {
          self.animator.removeAllBehaviors()
          self.snapBehavior = UISnapBehavior(item: imageView,
            snapToPoint: self.sourceViewCell.lightboxView.center)
          self.animator.addBehavior(self.snapBehavior)
        } else {
          imageView.center = self.sourceViewCell.lightboxView.center
        }
        imageView.alpha = 1
        })
    } else {
      UIView.animateWithDuration(0.3, animations: { [unowned self] in
        self.sourceViewCell.parentViewController.view.alpha = 1
        self.sourceViewCell.parentViewController.pageLabel.transform = CGAffineTransformIdentity
        self.sourceViewCell.parentViewController.closeButton.transform = CGAffineTransformIdentity
        if !self.sourceViewCell.parentViewController.physics {
          imageView.center = CGPointMake(imageView.center.x, UIScreen.mainScreen().bounds.height/2)
        }
        })
    }
  }
}

// MARK: Gesture recognizer delegate methods

extension LightboxTransition : UIGestureRecognizerDelegate {

  public override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
      let translation = panGestureRecognizer.translationInView(superview!)
      if fabs(translation.x) < fabs(translation.y) {
        return true
      }
    }
    return false
  }
}
