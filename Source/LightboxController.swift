import UIKit

public protocol LightboxControllerDelegate: class {

  func lightboxControllerDidMoveToPage(controller: LightboxController, page: Int)
}

public class LightboxController: UIViewController {

  var images = [UIImage]()

  public var delegate: LightboxControllerDelegate?

  var collectionSize = CGSizeZero

  public private(set) var page = 0 {
    didSet {
      let config = LightboxConfig.sharedInstance.config.pageIndicator
      let text = "\(page + 1)/\(images.count)"
      
      pageLabel.attributedText = NSAttributedString(string: text,
        attributes: config.textAttributes)
      pageLabel.sizeToFit()
      delegate?.lightboxControllerDidMoveToPage(self, page: page)
    }
  }

  public lazy var dataSource: LightboxDataSource = { [unowned self] in
    let dataSource = LightboxDataSource(data: self.images)
    return dataSource
    }()

  lazy var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: CGRectZero,
      collectionViewLayout: self.collectionViewLayout)

    collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
    collectionView.pagingEnabled = true
    collectionView.backgroundColor = .blackColor()
    collectionView.dataSource = self.dataSource
    collectionView.delegate = self

    collectionView.registerClass(LightboxViewCell.self,
      forCellWithReuseIdentifier: LightboxViewCell.reuseIdentifier)

    return collectionView
    }()

  lazy var collectionViewLayout: UICollectionViewLayout = {
    let layout = UICollectionViewFlowLayout()
    
    layout.scrollDirection = .Horizontal
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    return layout
    }()

  lazy var pageLabel: UILabel = { [unowned self] in
    let config = LightboxConfig.sharedInstance.config.pageIndicator
    let label = UILabel(frame: CGRectZero)
    
    label.setTranslatesAutoresizingMaskIntoConstraints(false)
    label.hidden = !config.enabled
    
    return label
    }()
  
  lazy var closeButton: UIButton = {
    let config = LightboxConfig.sharedInstance.config.closeButton
    let button = UIButton(frame: CGRectZero)
    
    button.setTranslatesAutoresizingMaskIntoConstraints(false)
    button.layer.borderColor = config.borderColor.CGColor
    button.layer.cornerRadius = 5
    button.layer.borderWidth = 1
    button.titleLabel?.attributedText = NSAttributedString(
      string: config.text, attributes: config.textAttributes)
    
    return button
    }()

  // MARK: Initializers

  public required init(images: [UIImage], delegate: LightboxControllerDelegate? = nil) {
    self.images = images
    self.delegate = delegate

    super.init(nibName: nil, bundle: nil)
  }

  public required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View Lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    let width = CGRectGetWidth(view.frame)
    let height = CGRectGetHeight(view.frame)

    collectionSize = CGSize(
      width: width < height ? width : height,
      height: height > width ? height : width)

    view.addSubview(collectionView)
    view.addSubview(pageLabel)
    view.addSubview(closeButton)
    
    setupConstraints()

    page = 0
  }

  // MARK: - Autolayout

  func setupConstraints() {
    let attributes: [NSLayoutAttribute] = [.Leading, .Trailing, .Top, .Bottom]

    attributes.map {
      self.view.addConstraint(NSLayoutConstraint(item: self.collectionView,
        attribute: $0, relatedBy: .Equal, toItem: self.view, attribute: $0,
        multiplier: 1, constant: 0))
    }
    
    let config = LightboxConfig.sharedInstance.config

    view.addConstraint(NSLayoutConstraint(item: pageLabel, attribute: .Leading,
      relatedBy: .Equal, toItem: view, attribute: .Leading,
      multiplier: 1, constant: 0))

    view.addConstraint(NSLayoutConstraint(item: pageLabel, attribute: .Trailing,
      relatedBy: .Equal, toItem: view, attribute: .Trailing,
      multiplier: 1, constant: 0))

    view.addConstraint(NSLayoutConstraint(item: pageLabel, attribute: .Bottom,
      relatedBy: .Equal, toItem: view, attribute: .Bottom,
      multiplier: 1, constant: -20))
    
    view.addConstraint(NSLayoutConstraint(item: closeButton, attribute: .Top,
      relatedBy: .Equal, toItem: view, attribute: .Top,
      multiplier: 1, constant: 16))
    
    view.addConstraint(NSLayoutConstraint(item: closeButton, attribute: .Trailing,
      relatedBy: .Equal, toItem: view, attribute: .Trailing,
      multiplier: 1, constant: 17))
    
    view.addConstraint(NSLayoutConstraint(item: closeButton, attribute: .Width,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: config.closeButton.size.width))
    
    view.addConstraint(NSLayoutConstraint(item: closeButton, attribute: .Height,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: config.closeButton.size.height))
  }

  // MARK: - Orientation

  public override func shouldAutorotate() -> Bool {
    return false
  }

  public override func supportedInterfaceOrientations() -> Int {
    return Int(UIInterfaceOrientationMask.Portrait.rawValue)
  }

  // MARK: - Pagination

  public func goTo(page: Int, animated: Bool = true) {
    if page >= 0 && page < images.count {
      var offset = collectionView.contentOffset

      offset.x = CGFloat(page) * collectionSize.width
      offset.y = CGFloat(page) * collectionSize.height

      collectionView.setContentOffset(offset, animated: animated)
    }
  }

  public func next(animated: Bool = true) {
    goTo(page + 1, animated: animated)
  }

  public func previous(animated: Bool = true) {
    goTo(page - 1, animated: animated)
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
    let pageWidth = collectionSize.width
    let currentPage = Int(floor((collectionView.contentOffset.x - pageWidth / 2) / pageWidth) + 1)
    if currentPage != page {
      page = currentPage
    }
  }
}
