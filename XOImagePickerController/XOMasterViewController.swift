///*
//See LICENSE folder for this sample’s licensing information.
//
//Abstract:
//Implements the main view controller for album navigation.
//*/
//
//import UIKit
//import Photos
//
//class XOMasterViewController: UITableViewController {
//
//    // MARK: Types for managing sections, cell, and segue identifiers
//    enum Section: Int {
//        case allPhotos = 0
//        case smartAlbums
//        case userCollections
//
//        static let count = 3
//    }
//
//    enum CellIdentifier: String {
//        case allPhotos, collection
//    }
//
//    // MARK: Properties
//    var allPhotos: PHFetchResult<PHAsset>!
//    var smartAlbums: PHFetchResult<PHAssetCollection>!
//    var userCollections: PHFetchResult<PHCollection>!
//    let sectionLocalizedTitles = ["", NSLocalizedString("Smart Albums", comment: ""), NSLocalizedString("Albums", comment: "")]
//
//    // MARK: UIViewController / Life Cycle
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Create a PHFetchResult object for each section in the table view.
//        let allPhotosOptions = PHFetchOptions()
//        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
//        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
//        smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
//        userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
//        PHPhotoLibrary.shared().register(self)
//    }
//
//    /// - Tag: UnregisterChangeObserver
//    deinit {
//        PHPhotoLibrary.shared().unregisterChangeObserver(self)
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
//        super.viewWillAppear(animated)
//    }
//
//    // MARK: Table View
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return Section.count
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        switch Section(rawValue: section)! {
//        case .allPhotos: return 1
//        case .smartAlbums: return smartAlbums.count
//        case .userCollections: return userCollections.count
//        }
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        switch Section(rawValue: indexPath.section)! {
//        case .allPhotos:
//            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.allPhotos.rawValue, for: indexPath)
//            cell.textLabel!.text = NSLocalizedString("All Photos", comment: "")
//            return cell
//
//        case .smartAlbums:
//            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.collection.rawValue, for: indexPath)
//            let collection = smartAlbums.object(at: indexPath.row)
//            cell.textLabel!.text = collection.localizedTitle
//            return cell
//
//        case .userCollections:
//            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.collection.rawValue, for: indexPath)
//            let collection = userCollections.object(at: indexPath.row)
//            cell.textLabel!.text = collection.localizedTitle
//            return cell
//        }
//    }
//
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return sectionLocalizedTitles[section]
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        let vc = XOAssetGridViewController()
//
//        switch Section(rawValue: indexPath.section)! {
//        case .allPhotos:
//            vc.fetchResult = allPhotos
//            vc.title = NSLocalizedString("All Photos", comment: "")
//            self.navigationController?.pushViewController(vc, animated: true)
//            break
//        case .smartAlbums:
//            let collection = smartAlbums.object(at: indexPath.row)
//            // configure the view controller with the asset collection
//            let assetCollection = collection
//            vc.fetchResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
//            vc.assetCollection = assetCollection
//            vc.title = collection.localizedTitle
//            self.navigationController?.pushViewController(vc, animated: true)
//            break
//        case .userCollections:
//            let collection = userCollections.object(at: indexPath.row)
//            // configure the view controller with the asset collection
//            guard let assetCollection = collection as? PHAssetCollection
//                else { fatalError("Expected an asset collection.") }
//            vc.title = collection.localizedTitle
//            vc.fetchResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
//            vc.assetCollection = assetCollection
//            self.navigationController?.pushViewController(vc, animated: true)
//            break
//        }
//    }
//
//}
//
//// MARK: PHPhotoLibraryChangeObserver
//
//extension XOMasterViewController: PHPhotoLibraryChangeObserver {
//    /// - Tag: RespondToChanges
//    func photoLibraryDidChange(_ changeInstance: PHChange) {
//
//        // Change notifications may originate from a background queue.
//        // Re-dispatch to the main queue before acting on the change,
//        // so you can update the UI.
//        DispatchQueue.main.sync {
//            // Check each of the three top-level fetches for changes.
//            if let changeDetails = changeInstance.changeDetails(for: allPhotos) {
//                // Update the cached fetch result.
//                allPhotos = changeDetails.fetchResultAfterChanges
//                // Don't update the table row that always reads "All Photos."
//            }
//
//            // Update the cached fetch results, and reload the table sections to match.
//            if let changeDetails = changeInstance.changeDetails(for: smartAlbums) {
//                smartAlbums = changeDetails.fetchResultAfterChanges
//                tableView.reloadSections(IndexSet(integer: Section.smartAlbums.rawValue), with: .automatic)
//            }
//            if let changeDetails = changeInstance.changeDetails(for: userCollections) {
//                userCollections = changeDetails.fetchResultAfterChanges
//                tableView.reloadSections(IndexSet(integer: Section.userCollections.rawValue), with: .automatic)
//            }
//        }
//    }
//}
//
