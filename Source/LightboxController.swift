import UIKit

public protocol LightboxControllerPageDelegate: class {

  func lightboxControllerDidMoveToPage(controller: LightboxController, page: Int)
}

public protocol LightboxControllerDismissalDelegate: class {

  func lightboxControllerDidDismiss(controller: LightboxController)
}

public class LightboxController: UIViewController {

  public weak var pageDelegate: LightboxControllerPageDelegate?
  public weak var dismissalDelegate: LightboxControllerDismissalDelegate?

  lazy var transitionManager: LightboxTransition = { [unowned self] in
    let manager = LightboxTransition()
    manager.sourceViewController = self

    return manager
    }()

  public var images = []
  public var collectionSize = CGSizeZero
  var pageLabelBottom: NSLayoutConstraint?
  var pageLabelAlternative: NSLayoutConstraint?
  var collectionViewHeight: NSLayoutConstraint?
  var collectionViewWidth: NSLayoutConstraint?
  var closeButtonTop: NSLayoutConstraint?
  var closeButtonRight: NSLayoutConstraint?
  var physics = false

  lazy var config: Config = {
    return LightboxConfig.sharedInstance.config
    }()

  var pageLabelBottomConstant: CGFloat {
    return collectionSize.width < collectionSize.height ? -20 : -2
  }

  var currentOrientation: UIDeviceOrientation?
  var beforeFaceOrientation: UIDeviceOrientation?

  var rotating = false

  public private(set) var page = 0 {
    didSet {
      page = min(images.count - 1, max(0, page))

      let text = "\(page + 1)/\(images.count)"

      pageLabel.attributedText = NSAttributedString(string: text,
        attributes: config.pageIndicator.textAttributes)
      pageLabel.sizeToFit()

      if page == images.count - 1 {
        seen = true
      }

      pageDelegate?.lightboxControllerDidMoveToPage(self, page: page)
    }
  }

  public private(set) var seen = false

  lazy var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: CGRectZero,
      collectionViewLayout: self.collectionViewLayout)

    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.backgroundColor = .blackColor()
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.decelerationRate = UIScrollViewDecelerationRateFast

    collectionView.registerClass(LightboxViewCell.self,
      forCellWithReuseIdentifier: LightboxViewCell.reuseIdentifier)

    return collectionView
    }()

  lazy var collectionViewLayout: UICollectionViewLayout = { [unowned self] in
    let layout = CenterCellCollectionViewFlowLayout()

    layout.scrollDirection = .Horizontal
    layout.minimumInteritemSpacing = self.config.spacing
    layout.minimumLineSpacing = self.config.spacing
    layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

    return layout
    }()

  lazy var pageLabel: UILabel = { [unowned self] in
    let label = UILabel(frame: CGRectZero)

    label.translatesAutoresizingMaskIntoConstraints = false
    label.hidden = !self.config.pageIndicator.enabled

    return label
    }()

  lazy var closeButton: UIButton = { [unowned self] in
    let title = NSAttributedString(
      string: self.config.closeButton.text,
      attributes: self.config.closeButton.textAttributes)
    let button = UIButton(type: .System)

    button.tintColor = self.config.closeButton.textAttributes[NSForegroundColorAttributeName] as? UIColor
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setAttributedTitle(title, forState: .Normal)
    button.addTarget(self, action: "closeButtonDidTouchUpInside:",
      forControlEvents: .TouchUpInside)

    if let image = self.config.closeButton.image {
      button.setBackgroundImage(image, forState: .Normal)
    }

    return button
    }()

  lazy var deleteButton: UIButton = { [unowned self] in
    let title = NSAttributedString(
      string: self.config.deleteButton.text,
      attributes: self.config.deleteButton.textAttributes)
    let button = UIButton(type: .System)

    button.tintColor = self.config.deleteButton.textAttributes[NSForegroundColorAttributeName] as? UIColor
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setAttributedTitle(title, forState: .Normal)
    button.alpha = self.config.deleteButton.alpha
    button.addTarget(self, action: "deleteButtonDidPress:",
      forControlEvents: .TouchUpInside)

    if let image = self.config.deleteButton.image {
      button.setBackgroundImage(image, forState: .Normal)
    }

    return button
    }()

  // MARK: Initializers

  public required init(images: [String], config: Config? = nil,
    pageDelegate: LightboxControllerPageDelegate? = nil,
    dismissalDelegate: LightboxControllerDismissalDelegate? = nil) {
      self.images = images
      self.pageDelegate = pageDelegate
      self.dismissalDelegate = dismissalDelegate

      if let config = config {
        LightboxConfig.sharedInstance.config = config
      }

      super.init(nibName: nil, bundle: nil)
  }

  public required init(imagesUI: [UIImage], config: Config? = nil,
    pageDelegate: LightboxControllerPageDelegate? = nil,
    dismissalDelegate: LightboxControllerDismissalDelegate? = nil) {
      self.images = imagesUI
      self.pageDelegate = pageDelegate
      self.dismissalDelegate = dismissalDelegate

      if let config = config {
        LightboxConfig.sharedInstance.config = config
      }

      super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View Lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    collectionSize = CGSizeMake(view.frame.width, view.frame.height)
    [collectionView, pageLabel, closeButton, deleteButton].map { self.view.addSubview($0) }

    transitioningDelegate = transitionManager
    transitionManager.delegate = self

    view.backgroundColor = UIColor.blackColor()

    let orientationsSupported: [String] = NSBundle.mainBundle().objectForInfoDictionaryKey("UISupportedInterfaceOrientations") as! [String]

    currentOrientation = UIDevice.currentDevice().orientation
    beforeFaceOrientation = UIDevice.currentDevice().orientation

    if orientationsSupported.first == "UIInterfaceOrientationPortrait"
      && orientationsSupported.count == 1 {
        NSNotificationCenter.defaultCenter().addObserver(
          self,
          selector: "deviceDidRotate",
          name: UIDeviceOrientationDidChangeNotification,
          object: nil)
    }

    setupConstraints()

    page = 0
  }

  public override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(true)

    if config.hideStatusBar {
      UIApplication.sharedApplication().setStatusBarHidden(true,
        withAnimation: .Fade)
    }

    let orientationsSupported: [String] = NSBundle.mainBundle().objectForInfoDictionaryKey("UISupportedInterfaceOrientations") as! [String]

    if orientationsSupported.first == "UIInterfaceOrientationPortrait"
      && orientationsSupported.count == 1 {
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft
          || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            deviceDidRotate()
        }
    }
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  // MARK: - Handle rotation

  func deviceDidRotate() {
    let orientation = UIDevice.currentDevice().orientation
    let orientations: [UIDeviceOrientation] = [.FaceUp, .FaceDown]
    let currentIsFace = orientations.filter({ $0 == self.currentOrientation }).first != nil
    let nextIsFace = orientations.filter({ $0 == orientation }).first != nil

    if nextIsFace {
      beforeFaceOrientation = currentOrientation
    }
    currentOrientation = orientation

    if (!currentIsFace && nextIsFace) ||
      (currentIsFace && !nextIsFace && orientation == beforeFaceOrientation) {
        return
    }

    rotating = true
    var transform = CGAffineTransformIdentity

    if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft {
      transform = moveCollectionView(true)
      moveViews(true)
      transitionManager.panGestureRecognizer.enabled = false
    } else if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
      transform = moveCollectionView(false)
      moveViews(false)
      transitionManager.panGestureRecognizer.enabled = false
    } else if UIDevice.currentDevice().orientation == UIDeviceOrientation.Portrait {
      [collectionViewHeight!, collectionViewWidth!,
        closeButtonTop!, closeButtonRight!,
        pageLabelAlternative!, pageLabelBottom!].map { self.view.removeConstraint($0) }

      standardCollectionViewConstraints()
      standardCloseButtonConstraints()
      standardPageLabelConstraints()
      collectionView.alpha = 0

      transitionManager.panGestureRecognizer.enabled = true
    }

    if UIDevice.currentDevice().orientation != UIDeviceOrientation.PortraitUpsideDown {
      UIView.animateWithDuration(0.1, animations: { [unowned self] in
        [self.collectionView, self.closeButton, self.pageLabel].map { $0.alpha = 0 }
        }, completion: { finished in
          [self.collectionView, self.closeButton, self.pageLabel].map { $0.transform = transform }
          let indexPath = NSIndexPath(forItem: self.page, inSection: 0)
          self.collectionView.scrollToItemAtIndexPath(indexPath,
            atScrollPosition: UICollectionViewScrollPosition(), animated: false)
          UIView.animateWithDuration(0.3, animations: { [unowned self] in
            [self.collectionView, self.closeButton, self.pageLabel].map { $0.alpha = 1 }
            self.rotating = false
            })
      })
    }

    if UIDevice.currentDevice().orientation != UIDeviceOrientation.PortraitUpsideDown {
      UIView.animateWithDuration(0.3, animations: { [unowned self] in
        self.collectionView.transform = transform
        self.closeButton.transform = transform
        self.pageLabel.transform = transform
        }, completion: { _ in
          let indexPath = NSIndexPath(forItem: self.page, inSection: 0)
          self.collectionView.scrollToItemAtIndexPath(indexPath,
            atScrollPosition: UICollectionViewScrollPosition(), animated: true)
          self.rotating = false
      })
    }

    if UIDevice.currentDevice().orientation == UIDeviceOrientation.PortraitUpsideDown {
      rotating = false
    }
  }

  // MARK: - Autolayout

  func setupConstraints() {
    let attributes: [NSLayoutAttribute] = [.CenterX, .CenterY]

    attributes.map { self.view.addConstraint(NSLayoutConstraint(item: self.collectionView, attribute: $0,
      relatedBy: .Equal, toItem: self.view, attribute: $0,
      multiplier: 1, constant: 0)) }

    standardCollectionViewConstraints()
    standardPageLabelConstraints()
    standardCloseButtonConstraints()
    standardDeleteButtonConstraints()

    view.addConstraint(NSLayoutConstraint(item: closeButton, attribute: .Width,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: config.closeButton.size.width))

    view.addConstraint(NSLayoutConstraint(item: closeButton, attribute: .Height,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: config.closeButton.size.height))

    view.addConstraint(NSLayoutConstraint(item: deleteButton, attribute: .Width,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: config.deleteButton.size.width))

    view.addConstraint(NSLayoutConstraint(item: deleteButton, attribute: .Height,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: config.deleteButton.size.height))
  }

  // MARK: - Orientation

  public override func shouldAutorotate() -> Bool {
    return true
  }

  public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.All
  }

  public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    rotating = true
    collectionSize = size
    collectionView.collectionViewLayout.invalidateLayout()

    coordinator.animateAlongsideTransition({ _ in
      self.collectionView.collectionViewLayout.invalidateLayout()
      self.pageLabelBottom?.constant = self.pageLabelBottomConstant
      }, completion: { _ in
        let indexPath = NSIndexPath(forItem: self.page, inSection: 0)

        self.view.layoutIfNeeded()
        self.collectionView.scrollToItemAtIndexPath(indexPath,
          atScrollPosition: .CenteredHorizontally,
          animated: false)
        self.rotating = false
    })
  }

  // MARK: - Pagination

  public func goTo(page: Int, animated: Bool = true) {
    if page >= 0 && page < images.count {
      var offset = collectionView.contentOffset

      offset.x = CGFloat(page) * collectionSize.width
      collectionView.setContentOffset(offset,
        animated: animated)
    }
  }

  public func next(animated: Bool = true) {
    goTo(page + 1, animated: animated)
  }

  public func previous(animated: Bool = true) {
    goTo(page - 1, animated: animated)
  }

  // MARK: - Actions

  func closeButtonDidTouchUpInside(sender: UIButton) {
    dismissalDelegate?.lightboxControllerDidDismiss(self)
  }

  func deleteButtonDidPress(button: UIButton) {
    button.enabled = false
    var indexPath = NSIndexPath()
    let index = page
    let array = images.mutableCopy() as! NSMutableArray

    if page < images.count - 1 {
      indexPath = NSIndexPath(forRow: page + 1, inSection: 0)
    } else if page == images.count - 1 && images.count != 1 {
      indexPath = NSIndexPath(forRow: page - 1, inSection: 0)
    } else {
      if array.count != 0 {
        array.removeObjectAtIndex(index)
      }
      images = array
      dismissalDelegate?.lightboxControllerDidDismiss(self)
    }

    if images.count != 0 {
      collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Left, animated: true)

      let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
      dispatch_after(delayTime, dispatch_get_main_queue()) { [unowned self] in
        array.removeObjectAtIndex(index)
        self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0), atScrollPosition: .Left, animated: false)
        self.images = array
        self.page = index
        self.collectionView.reloadData()
        button.enabled = true
      }
    }
  }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension LightboxController: UICollectionViewDelegateFlowLayout {

  public func collectionView(collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
      return collectionSize
  }
}

// MARK: - UICollectionViewDelegate

extension LightboxController: UICollectionViewDelegate { }

// MARK: - UIScrollViewDelegate

extension LightboxController: UIScrollViewDelegate {

  public func scrollViewDidScroll(scrollView: UIScrollView) {
    if !rotating {
      let pageWidth = collectionSize.width
      let currentPage = Int(floor((collectionView.contentOffset.x - pageWidth / 2) / pageWidth) + 1)
      if currentPage != page { page = currentPage }
    }
  }

  public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    if let cell = collectionView.visibleCells().first as? LightboxViewCell {
      cell.parentViewController = self
      cell.setupTransitionManager()
    }
  }
}

extension LightboxController: LightboxTransitionDelegate {

  func transitionDidDismissController(controller: LightboxController) {
    dismissalDelegate?.lightboxControllerDidDismiss(controller)
  }
}

// MARK: Custom autolayout

extension LightboxController {

  private func moveCollectionView(left: Bool) -> CGAffineTransform {
    let value: CGFloat = left ? 1.57 : -1.57
    let transform = CGAffineTransformMakeRotation(value)
    let size = CGSizeMake(view.frame.height, view.frame.width)

    view.removeConstraint(collectionViewHeight!)
    view.removeConstraint(collectionViewWidth!)

    collectionViewHeight = NSLayoutConstraint(item: collectionView, attribute: .Height,
      relatedBy: .Equal, toItem: view, attribute: .Width,
      multiplier: 1, constant: 0)

    collectionViewWidth = NSLayoutConstraint(item: collectionView, attribute: .Width,
      relatedBy: .Equal, toItem: view, attribute: .Height,
      multiplier: 1, constant: 0)

    view.addConstraint(collectionViewHeight!)
    view.addConstraint(collectionViewWidth!)

    collectionSize = size
    collectionView.alpha = 0

    collectionView.collectionViewLayout.invalidateLayout()
    view.layoutIfNeeded()

    return transform
  }

  private func standardPageLabelConstraints() {
    pageLabelAlternative = NSLayoutConstraint(item: pageLabel, attribute: .CenterX,
      relatedBy: .Equal, toItem: view, attribute: .CenterX,
      multiplier: 1, constant: 0)

    pageLabelBottom = NSLayoutConstraint(item: pageLabel, attribute: .Bottom,
      relatedBy: .Equal, toItem: view, attribute: .Bottom,
      multiplier: 1, constant: pageLabelBottomConstant)

    view.addConstraint(pageLabelAlternative!)
    view.addConstraint(pageLabelBottom!)
  }

  private func standardCollectionViewConstraints() {
    collectionViewWidth = NSLayoutConstraint(item: collectionView, attribute: .Width,
      relatedBy: .Equal, toItem: view, attribute: .Width,
      multiplier: 1, constant: 0)

    collectionViewHeight = NSLayoutConstraint(item: collectionView, attribute: .Height,
      relatedBy: .Equal, toItem: view, attribute: .Height,
      multiplier: 1, constant: 0)

    collectionSize = CGSizeMake(view.frame.width, view.frame.height)
    collectionView.reloadData()

    view.addConstraint(collectionViewWidth!)
    view.addConstraint(collectionViewHeight!)
  }

  private func standardCloseButtonConstraints() {
    closeButtonTop = NSLayoutConstraint(item: closeButton, attribute: .Top,
      relatedBy: .Equal, toItem: view, attribute: .Top,
      multiplier: 1, constant: 16)

    closeButtonRight = NSLayoutConstraint(item: closeButton, attribute: .Right,
      relatedBy: .Equal, toItem: view, attribute: .Right,
      multiplier: 1, constant: -17)

    view.addConstraint(closeButtonTop!)
    view.addConstraint(closeButtonRight!)
  }

  private func standardDeleteButtonConstraints() {
    view.addConstraint(NSLayoutConstraint(item: deleteButton, attribute: .Top,
      relatedBy: .Equal, toItem: view, attribute: .Top,
      multiplier: 1, constant: 16))

    view.addConstraint(NSLayoutConstraint(item: deleteButton, attribute: .Left,
      relatedBy: .Equal, toItem: view, attribute: .Left,
      multiplier: 1, constant: 17))
  }

  private func moveViews(left: Bool) {
    [closeButtonTop!, closeButtonRight!,
      pageLabelAlternative!, pageLabelBottom!].map { self.view.removeConstraint($0) }

    closeButtonRight = left ?
      NSLayoutConstraint(item: closeButton, attribute: .Right,
        relatedBy: .Equal, toItem: view, attribute: .Right,
        multiplier: 1, constant: 0) :
      NSLayoutConstraint(item: closeButton, attribute: .Left,
        relatedBy: .Equal, toItem: view, attribute: .Left,
        multiplier: 1, constant: 0)

    closeButtonTop = left
      ? NSLayoutConstraint(item: closeButton, attribute: .Bottom,
        relatedBy: .Equal, toItem: view, attribute: .Bottom,
        multiplier: 1, constant: -35)
      : NSLayoutConstraint(item: closeButton, attribute: .Top,
        relatedBy: .Equal, toItem: view, attribute: .Top,
        multiplier: 1, constant: 35)

    pageLabelBottom = left
      ? NSLayoutConstraint(item: pageLabel, attribute: .Left,
        relatedBy: .Equal, toItem: view, attribute: .Left,
        multiplier: 1, constant: 20)
      : NSLayoutConstraint(item: pageLabel, attribute: .Top,
        relatedBy: .Equal, toItem: view, attribute: .Top,
        multiplier: 1, constant: 20)

    pageLabelAlternative = left
      ? NSLayoutConstraint(item: pageLabel, attribute: .Bottom,
        relatedBy: .Equal, toItem: view, attribute: .Bottom,
        multiplier: 1, constant: -20)
      : NSLayoutConstraint(item: pageLabel, attribute: .Right,
        relatedBy: .Equal, toItem: view, attribute: .Right,
        multiplier: 1, constant: -20)

    [closeButtonTop!, closeButtonRight!,
      pageLabelAlternative!, pageLabelBottom!].map { self.view.addConstraint($0) }
  }
}
