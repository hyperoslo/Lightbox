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

  public var dismissed = false

  public lazy var scrollView: UIScrollView = { [unowned self] in
    let scrollView = UIScrollView()
    scrollView.frame = UIScreen.mainScreen().bounds
    scrollView.pagingEnabled = true
    scrollView.delegate = self
    scrollView.userInteractionEnabled = true
    scrollView.showsHorizontalScrollIndicator = false

    return scrollView
    }()

  lazy var closeButton: UIButton = { [unowned self] in
    let title = NSAttributedString(
      string: self.config.closeButton.text,
      attributes: self.config.closeButton.textAttributes)
    let button = UIButton(type: .System)

    button.tintColor = self.config.closeButton.textAttributes[NSForegroundColorAttributeName] as? UIColor
    button.setAttributedTitle(title, forState: .Normal)
    button.addTarget(self, action: "closeButtonDidPress:",
      forControlEvents: .TouchUpInside)

    if let image = self.config.closeButton.image {
      button.setBackgroundImage(image, forState: .Normal)
    }

    button.hidden = !self.config.deleteButton.enabled

    return button
    }()

  lazy var deleteButton: UIButton = { [unowned self] in
    let title = NSAttributedString(
      string: self.config.deleteButton.text,
      attributes: self.config.deleteButton.textAttributes)
    let button = UIButton(type: .System)

    button.tintColor = self.config.deleteButton.textAttributes[NSForegroundColorAttributeName] as? UIColor
    button.setAttributedTitle(title, forState: .Normal)
    button.alpha = self.config.deleteButton.alpha
    button.addTarget(self, action: "deleteButtonDidPress:",
      forControlEvents: .TouchUpInside)

    if let image = self.config.deleteButton.image {
      button.setBackgroundImage(image, forState: .Normal)
    }

    button.hidden = !self.config.deleteButton.enabled

    return button
    }()

  lazy var pageLabel: UILabel = { [unowned self] in
    let label = UILabel(frame: CGRectZero)
    label.backgroundColor = UIColor.blackColor()

    label.hidden = !self.config.pageIndicator.enabled

    return label
    }()

  public var numberOfPages: Int {
    return pageViews.count
  }

  public var pageViews = [PageView]()
  var imageURLs: [NSURL]?
  public lazy var transitionManager: LightboxTransition = LightboxTransition()

  var statusBarHidden = false
  public private(set) var seen = false
  var rotating = false
  var config: LightboxConfig

  public private(set) var currentPage = 0 {
    didSet {
      currentPage = min(numberOfPages - 1, max(0, currentPage))

      let text = "\(currentPage + 1)/\(numberOfPages)"

      pageLabel.attributedText = NSAttributedString(string: text,
        attributes: config.pageIndicator.textAttributes)
      pageLabel.sizeToFit()

      if currentPage == numberOfPages - 1 {
        seen = true
      }

      pageDelegate?.lightboxControllerDidMoveToPage(self, page: currentPage)
    }
  }

  // MARK: - Initializers

  public init(images: [UIImage], config: LightboxConfig = LightboxConfig.config, pageDelegate: LightboxControllerPageDelegate? = nil, dismissalDelegate: LightboxControllerDismissalDelegate? = nil) {
    self.config = config
    self.pageDelegate = pageDelegate
    self.dismissalDelegate = dismissalDelegate

    super.init(nibName: nil, bundle: nil)

    for image in images {
      let pageView = PageView(image: image)

      scrollView.addSubview(pageView)
      pageViews.append(pageView)
    }
  }

  public init(imageURLs: [NSURL], config: LightboxConfig = LightboxConfig.config,
    pageDelegate: LightboxControllerPageDelegate? = nil,
    dismissalDelegate: LightboxControllerDismissalDelegate? = nil) {
      self.config = config
      self.pageDelegate = pageDelegate
      self.dismissalDelegate = dismissalDelegate

      super.init(nibName: nil, bundle: nil)

      for imageURL in imageURLs {
        let pageView = PageView(imageURL: imageURL)

        scrollView.addSubview(pageView)
        pageViews.append(pageView)
      }
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.blackColor()
    transitionManager.lightboxController = self
    transitionManager.scrollView = scrollView
    transitioningDelegate = transitionManager

    [scrollView, closeButton, deleteButton, pageLabel].forEach { view.addSubview($0) }

    configureLayout()
    configureFrames()

    currentPage = 0
  }

  public override func viewWillAppear(animated: Bool) {
    super.viewWillDisappear(animated)

    statusBarHidden = UIApplication.sharedApplication().statusBarHidden
    UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
  }

  public override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)

    UIApplication.sharedApplication().setStatusBarHidden(statusBarHidden, withAnimation: .Fade)
  }

  override public func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

    scrollView.frame.size = size
    scrollView.contentSize = CGSize(
      width: size.width * CGFloat(numberOfPages),
      height: size.height)
    scrollView.contentOffset = CGPoint(x: CGFloat(currentPage) * size.width, y: 0)

    configureFrames()
  }

  // MARK: - Layout

  public override func viewDidLayoutSubviews() {
    let bounds = UIScreen.mainScreen().bounds

    closeButton.frame = CGRect(x: bounds.width - config.closeButton.size.width - 17, y: 16,
      width: config.closeButton.size.width, height: config.closeButton.size.height)
    deleteButton.frame = CGRect(x: 17, y: 16,
      width: config.deleteButton.size.width, height: config.deleteButton.size.height)

    let pageLabelX: CGFloat = bounds.width < bounds.height
      ? (bounds.width - pageLabel.frame.width) / 2
      : deleteButton.center.x

    pageLabel.frame.origin = CGPoint(
      x: pageLabelX,
      y: bounds.height - pageLabel.frame.height - 20)
  }

  public func configureLayout() {
    scrollView.contentSize.width = UIScreen.mainScreen().bounds.width * CGFloat(numberOfPages)
  }

  public func configureFrames() {
    for (index, pageView) in pageViews.enumerate() {
      var frame = scrollView.bounds
      frame.origin.x = frame.width * CGFloat(index)
      pageView.configureFrame(frame)
    }
  }

  // MARK: - Action methods

  public func handlePageControl() {
    UIView.animateWithDuration(0.35, animations: {
      self.scrollView.contentOffset.x = UIScreen.mainScreen().bounds.width * CGFloat(self.currentPage)
    })
  }

  public func closeButtonDidPress() {
    dismissed = true

    dismissViewControllerAnimated(true, completion: nil)
  }
}

// MARK: - ScrollView delegate

extension LightboxController: UIScrollViewDelegate {

  public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    currentPage = Int(scrollView.contentOffset.x / UIScreen.mainScreen().bounds.width)
  }
}
