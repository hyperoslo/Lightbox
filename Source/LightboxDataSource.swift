import UIKit

class LightboxDataSource: NSObject {

  var data: [UIImage]

  required init(data: [UIImage]) {
    self.data = data
    super.init()
  }
}

// MARK: - UICollectionViewDataSource

extension LightboxDataSource: UICollectionViewDataSource {

  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return data.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cellIdentifier = LightboxViewCell.reuseIdentifier
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier,
      forIndexPath: indexPath) as! LightboxViewCell
    let image = data[indexPath.row]

    cell.configureCell(image)

    return cell
  }
}
