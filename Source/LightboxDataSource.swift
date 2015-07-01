import UIKit

public class LightboxDataSource: NSObject {

  public var data: [UIImage]

  public required init(data: [UIImage]) {
    self.data = data
    super.init()
  }
}

// MARK: - UICollectionViewDataSource

extension LightboxDataSource: UICollectionViewDataSource {

  public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }

  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return data.count
  }

  public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cellIdentifier = LightboxViewCell.reuseIdentifier
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier,
      forIndexPath: indexPath) as! LightboxViewCell
    let image = data[indexPath.row]

    cell.lightboxView.image = image

    return cell
  }
}
