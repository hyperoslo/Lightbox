import UIKit

public protocol LightboxControllerPageDelegate: class {

  func lightboxControllerDidMoveToPage(controller: LightboxController, page: Int)
}

public protocol LightboxControllerDismissalDelegate: class {
  
  func lightboxControllerDidDismiss(controller: LightboxController)
}

public class LightboxController: UIViewController {

  public var pageDelegate: LightboxControllerPageDelegate?
  public var dismissalDelegate: LightboxControllerDismissalDelegate?

  let transitionManager = LightboxTransition()
  var images = [String]()
  var collectionSize = CGSizeZero
  var pageLabelBottom: NSLayoutConstraint?
  var physics = true

  lazy var config: Config = {
    return LightboxConfig.sharedInstance.config
  }()

  var pageLabelBottomConstant: CGFloat {
    return collectionSize.width < collectionSize.height ? -20 : -2
  }

  var rotating = false

  public private(set) var page = 0 {
    didSet {
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
    collectionView.backgroundColor = .clearColor()
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

  public required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View Lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    collectionSize = view.bounds.size
    [collectionView, pageLabel, closeButton].map { self.view.addSubview($0) }

    transitioningDelegate = transitionManager
    setupConstraints()

    page = 0
  }
  
  public override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(true)

    if config.hideStatusBar {
      UIApplication.sharedApplication().setStatusBarHidden(true,
        withAnimation: .Fade)
    }
  }

  // MARK: - Autolayout

  func setupConstraints() {
    let attributes: [NSLayoutAttribute] = [.Leading, .Trailing, .Top, .Bottom]

    attributes.map {
      self.view.addConstraint(NSLayoutConstraint(item: self.collectionView,
        attribute: $0, relatedBy: .Equal, toItem: self.view, attribute: $0,
        multiplier: 1, constant: 0))
    }
    
    view.addConstraint(NSLayoutConstraint(item: pageLabel, attribute: .Leading,
      relatedBy: .Equal, toItem: view, attribute: .Leading,
      multiplier: 1, constant: 0))

    view.addConstraint(NSLayoutConstraint(item: pageLabel, attribute: .Trailing,
      relatedBy: .Equal, toItem: view, attribute: .Trailing,
      multiplier: 1, constant: 0))

    pageLabelBottom = NSLayoutConstraint(item: pageLabel, attribute: .Bottom,
      relatedBy: .Equal, toItem: view, attribute: .Bottom,
      multiplier: 1, constant: pageLabelBottomConstant)
    view.addConstraint(pageLabelBottom!)
    
    view.addConstraint(NSLayoutConstraint(item: closeButton, attribute: .Top,
      relatedBy: .Equal, toItem: view, attribute: .Top,
      multiplier: 1, constant: 16))
    
    view.addConstraint(NSLayoutConstraint(item: closeButton, attribute: .Trailing,
      relatedBy: .Equal, toItem: view, attribute: .Trailing,
      multiplier: 1, constant: -17))
    
    view.addConstraint(NSLayoutConstraint(item: closeButton, attribute: .Width,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: config.closeButton.size.width))
    
    view.addConstraint(NSLayoutConstraint(item: closeButton, attribute: .Height,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: config.closeButton.size.height))
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
}
