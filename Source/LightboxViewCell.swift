import UIKit

public class LightboxViewCell: UICollectionViewCell {

  public static let reuseIdentifier: String = "LightboxViewCell"

  var constraintsAdded = false

  public lazy var lightboxView: LightboxView = { [unowned self] in
    let lightboxView = LightboxView(frame: self.bounds)
    lightboxView.setTranslatesAutoresizingMaskIntoConstraints(false)

    self.contentView.addSubview(lightboxView)

    return lightboxView
    }()

  lazy var panGestureRecognizer: UIPanGestureRecognizer = {
    let panGestureRecognizer = UIPanGestureRecognizer()
    panGestureRecognizer.addTarget(self, action: "handlePanGesture:")
    panGestureRecognizer.delegate = self

    return panGestureRecognizer
    }()

  public override func layoutSubviews() {
    super.layoutSubviews()
    animator = UIDynamicAnimator(referenceView: lightboxView)
    lightboxView.imageView.addGestureRecognizer(panGestureRecognizer)
    setupConstraints()
    lightboxView.updateViewLayout()
  }

  var animator: UIDynamicAnimator!
  var attachmentBehavior: UIAttachmentBehavior!
  var gravityBehaviour: UIGravityBehavior!
  var snapBehavior: UISnapBehavior!
  var parentViewController: LightboxController!

  private func setupConstraints() {
    if !constraintsAdded {

      let layoutAttributes: [NSLayoutAttribute] = [.Leading, .Trailing, .Top, .Bottom]
      for layoutAttribute in layoutAttributes {
        addConstraint(NSLayoutConstraint(item: lightboxView, attribute: layoutAttribute,
          relatedBy: .Equal, toItem: contentView, attribute: layoutAttribute,
          multiplier: 1, constant: 0))
      }

      constraintsAdded = true
    }
  }
}

// MARK: Pan gesture handler

extension LightboxViewCell {

  func handlePanGesture(panGestureRecognizer: UIPanGestureRecognizer) {
    let imageView = lightboxView.imageView
    let location = panGestureRecognizer.locationInView(lightboxView)
    let boxLocation = panGestureRecognizer.locationInView(imageView)
    let translation = panGestureRecognizer.translationInView(lightboxView)
    let maximumValue = UIScreen.mainScreen().bounds.height
    let calculation = abs(translation.y) / maximumValue
    let alphaValue = 1 - calculation

    parentViewController.view.alpha = alphaValue
    parentViewController.pageLabel.transform =
      CGAffineTransformMakeTranslation(0, calculation * 100)
    parentViewController.closeButton.transform =
      CGAffineTransformMakeTranslation(0, -(calculation * 100))

    if !parentViewController.physics {
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
          snapToPoint: lightboxView.center)
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
      parentViewController.dismissViewControllerAnimated(true, completion: { [unowned self] in
        if self.parentViewController.physics {
          self.animator.removeAllBehaviors()
          self.snapBehavior = UISnapBehavior(item: imageView,
            snapToPoint: self.lightboxView.center)
          self.animator.addBehavior(self.snapBehavior)
        } else {
          imageView.center = self.lightboxView.center
        }
        imageView.alpha = 1
        })
    } else {
      UIView.animateWithDuration(0.3, animations: { [unowned self] in
        self.parentViewController.view.alpha = 1
        self.parentViewController.pageLabel.transform = CGAffineTransformIdentity
        self.parentViewController.closeButton.transform = CGAffineTransformIdentity
        if !self.parentViewController.physics {
          imageView.center = CGPointMake(imageView.center.x, UIScreen.mainScreen().bounds.height/2)
        }
        })
    }
  }
}

// MARK: Gesture recognizer delegate methods

extension LightboxViewCell: UIGestureRecognizerDelegate {

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
