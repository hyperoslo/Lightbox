import UIKit

public class LightboxController: UIViewController {

  var images = [UIImage]()
  var page = 0

  public lazy var dataSource: LightboxDataSource = { [unowned self] in
    let dataSource = LightboxDataSource(data: self.images)
    return dataSource
    }()

  lazy var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: CGRectZero,
      collectionViewLayout: self.collectionViewLayout)

    collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
    collectionView.pagingEnabled = true
    collectionView.backgroundColor = .redColor()
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

  // MARK: Initializers

  public required init(images: [UIImage]) {
    self.images = images
    super.init(nibName: nil, bundle: nil)
  }

  public required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View Lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(collectionView)
    setupConstraints()
  }

  // MARK: - Autolayout

  func setupConstraints() {
    let attributes: [NSLayoutAttribute] = [.Leading, .Trailing, .Top, .Bottom]

    attributes.map {
      self.view.addConstraint(NSLayoutConstraint(item: self.collectionView, attribute: $0,
        relatedBy: .Equal, toItem: self.view, attribute: $0,
        multiplier: 1, constant: 0))
    }
  }

  // MARK: - Pagination

  public func goTo(page: Int, animated: Bool = true) {
    if page >= 0 && page < images.count {
      var offset = collectionView.contentOffset
      offset.x = CGFloat(page) * collectionView.frame.size.width
      collectionView.setContentOffset(offset, animated: animated)
    }
  }

  public func next(animated: Bool = true) {
    page++
    goTo(page, animated: animated)
  }

  public func previous(animated: Bool = true) {
    page--
    goTo(page, animated: animated)
  }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension LightboxController: UICollectionViewDelegateFlowLayout {

  public func collectionView(collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
      return view.frame.size
  }
}

// MARK: - UICollectionViewDelegate

extension LightboxController: UICollectionViewDelegate { }

// MARK: - UIScrollViewDelegate

extension LightboxController: UIScrollViewDelegate {

  public func scrollViewDidScroll(scrollView: UIScrollView) {
    let pageWidth = collectionView.frame.size.width
    page = Int(floor((collectionView.contentOffset.x - pageWidth / 2) / pageWidth) + 1)
  }
}
