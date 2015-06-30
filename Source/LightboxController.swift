import UIKit

public class LightboxController: UIViewController {

  var images = [UIImage]()

  public lazy var dataSource: LightboxDataSource = { [unowned self] in
    let dataSource = LightboxDataSource(data: self.images)
    return dataSource
    }()

  lazy var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: CGRectZero,
      collectionViewLayout: self.collectionViewLayout)

    collectionView.registerClass(LightboxViewCell.self,
      forCellWithReuseIdentifier: LightboxViewCell.reuseIdentifier)

    collectionView.backgroundColor = .blackColor()
    collectionView.dataSource = self.dataSource
    collectionView.delegate = self

    return collectionView
    }()

  lazy var collectionViewLayout: UICollectionViewLayout = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .Horizontal
    layout.minimumLineSpacing = 10
    layout.minimumInteritemSpacing = 2
    layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
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
