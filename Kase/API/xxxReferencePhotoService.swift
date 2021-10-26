//
//  ReferencePhotoService.swift
//  Kase
//
//  Created by George Sequeira on 3/11/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//
import Photos

class PhotoService {

    internal lazy var imageManager = PHCachingImageManager()

    private lazy var queue = DispatchQueue(label: "PhotoService_queue",
                                           qos: .default, attributes: .concurrent,
                                           autoreleaseFrequency: .workItem, target: nil)
    private lazy var getImagesQueue = DispatchQueue(label: "PhotoService_getImagesQueue",
                                                    qos: .userInteractive, attributes: [],
                                                    autoreleaseFrequency: .inherit, target: nil)
    private lazy var thumbnailSize = CGSize(width: 200, height: 200)
    private lazy var imageAlbumsIds = AtomicArray<Int>()
    private let getImageSemaphore = DispatchSemaphore(value: 12)

    typealias AlbumData = (fetchResult: PHFetchResult<PHAsset>, assetCollection: PHAssetCollection?)
    private let _cachedAlbumsDataSemaphore = DispatchSemaphore(value: 1)
    private lazy var _cachedAlbumsData = [Int: AlbumData]()

    deinit {
        print("____ PhotoServiceImpl deinited")
        imageManager.stopCachingImagesForAllAssets()
    }
}


// albums

//extension PhotoService {
//
//    private func getAlbumData(id: Int, completion: ((AlbumData?) -> Void)?) {
//        _ = _cachedAlbumsDataSemaphore.wait(timeout: .now() + .seconds(3))
//        if let cachedAlbum = _cachedAlbumsData[id] {
//            completion?(cachedAlbum)
//            _cachedAlbumsDataSemaphore.signal()
//            return
//        } else {
//            _cachedAlbumsDataSemaphore.signal()
//        }
//        var result: AlbumData? = nil
//        switch id {
//            case 0:
//                let fetchOptions = PHFetchOptions()
//                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
//                let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
//                result = (allPhotos, nil)
//
//            default:
//                let collections = getAllAlbumsAssetCollections()
//                let id = id - 1
//                if  id < collections.count {
//                    _fetchAssets(in: collections[id]) { fetchResult in
//                        result = (fetchResult, collections[id])
//                    }
//                }
//        }
//        guard let _result = result else { completion?(nil); return }
//        _ = _cachedAlbumsDataSemaphore.wait(timeout: .now() + .seconds(3))
//        _cachedAlbumsData[id] = _result
//        _cachedAlbumsDataSemaphore.signal()
//        completion?(_result)
//    }
//
//    private func getAllAlbumsAssetCollections() -> PHFetchResult<PHAssetCollection> {
//        let fetchOptions = PHFetchOptions()
//        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "endDate", ascending: true)]
//        fetchOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
//        return PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
//    }
//
//    func getAllAlbums(completion: (([PhotoAlbumViewModel])->Void)?) {
//        queue.async { [weak self] in
//            guard let self = self else { return }
//            var viewModels = AtomicArray<PhotoAlbumViewModel>()
//
//            var allPhotosAlbumViewModel: PhotoAlbumViewModel?
//            let dispatchGroup = DispatchGroup()
//            dispatchGroup.enter()
//            self.getAlbumData(id: 0) { data in
//                   guard let data = data, let asset = data.fetchResult.lastObject else { dispatchGroup.leave(); return }
//                self._fetchImage(from: asset, userInfo: nil, targetSize: self.thumbnailSize,
//                                     deliveryMode: .fastFormat, resizeMode: .fast) { [weak self] (image, _) in
//                                        guard let self = self, let image = image else { dispatchGroup.leave(); return }
//                                        allPhotosAlbumViewModel = .allPhotos(id: 0, title: "All Photos",
//                                                                             count: data.fetchResult.count,
//                                                                             image: image, isSelected: false)
//                                    self.imageAlbumsIds.append(0)
//                                    dispatchGroup.leave()
//                }
//            }
//
//            let numberOfAlbums = self.getAllAlbumsAssetCollections().count + 1
//            for id in 1 ..< numberOfAlbums {
//                dispatchGroup.enter()
//                self.getAlbumData(id: id) { [weak self] data in
//                    guard let self = self else { return }
//                    guard let assetCollection = data?.assetCollection else { dispatchGroup.leave(); return }
//                    self.imageAlbumsIds.append(id)
//                    self.getAlbumViewModel(id: id, collection: assetCollection) { [weak self] model in
//                        guard let self = self else { return }
//                        defer { dispatchGroup.leave() }
//                        guard let model = model else { return }
//                        viewModels.append(model)
//                    }
//                }
//            }
//
//            _ = dispatchGroup.wait(timeout: .now() + .seconds(3))
//            var _viewModels = [PhotoAlbumViewModel]()
//            if let allPhotosAlbumViewModel = allPhotosAlbumViewModel {
//                _viewModels.append(allPhotosAlbumViewModel)
//            }
//            _viewModels += viewModels.get()
//            DispatchQueue.main.async { completion?(_viewModels) }
//        }
//    }
//
//    private func getAlbumViewModel(id: Int, collection: PHAssetCollection, completion: ((PhotoAlbumViewModel?) -> Void)?) {
//        _fetchAssets(in: collection) { [weak self] fetchResult in
//            guard let self = self, let asset = fetchResult.lastObject else { completion?(nil); return }
//            self._fetchImage(from: asset, userInfo: nil, targetSize: self.thumbnailSize,
//                             deliveryMode: .fastFormat, resizeMode: .fast) { (image, nil) in
//                                guard let image = image else { completion?(nil); return }
//                                completion?(.regular(id: id,
//                                                     title: collection.localizedTitle ?? "",
//                                                     count: collection.estimatedAssetCount,
//                                                     image: image, isSelected: false))
//            }
//        }
//    }
//}
//
//// fetch
//
//extension PhotoService {
//
//    fileprivate func _fetchImage(from photoAsset: PHAsset,
//                                 userInfo: [AnyHashable: Any]? = nil,
//                                 targetSize: CGSize, //= PHImageManagerMaximumSize,
//                                 deliveryMode: PHImageRequestOptionsDeliveryMode = .fastFormat,
//                                 resizeMode: PHImageRequestOptionsResizeMode,
//                                 completion: ((_ image: UIImage?, _ userInfo: [AnyHashable: Any]?) -> Void)?) {
//        // guard authorizationStatus() == .authorized else { completion(nil); return }
//        let options = PHImageRequestOptions()
//        options.resizeMode = resizeMode
//        options.isSynchronous = true
//        options.deliveryMode = deliveryMode
//        imageManager.requestImage(for: photoAsset,
//                                  targetSize: targetSize,
//                                  contentMode: .aspectFill,
//                                  options: options) { (image, info) -> Void in
//                                    guard   let info = info,
//                                            let isImageDegraded = info[PHImageResultIsDegradedKey] as? Int,
//                                            isImageDegraded == 0 else { completion?(nil, nil); return }
//                                    completion?(image, userInfo)
//        }
//    }
//
//    private func _fetchAssets(in collection: PHAssetCollection, completion: @escaping (PHFetchResult<PHAsset>) -> Void) {
//        let fetchOptions = PHFetchOptions()
//        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
//        let assets = PHAsset.fetchAssets(in: collection, options: fetchOptions)
//        completion(assets)
//    }
//
//    private func fetchImage(from asset: PHAsset,
//                            userInfo: [AnyHashable: Any]?,
//                            targetSize: CGSize,
//                            deliveryMode: PHImageRequestOptionsDeliveryMode,
//                            resizeMode: PHImageRequestOptionsResizeMode,
//                            completion:  ((UIImage?, _ userInfo: [AnyHashable: Any]?) -> Void)?) {
//        queue.async { [weak self] in
//            self?._fetchImage(from: asset, userInfo: userInfo, targetSize: targetSize,
//                              deliveryMode: deliveryMode, resizeMode: resizeMode) { (image, _) in
//                                DispatchQueue.main.async { completion?(image, userInfo) }
//            }
//        }
//    }
//
//    func getImage(albumId: Int, index: Int,
//                  userInfo: [AnyHashable: Any]?,
//                  targetSize: CGSize,
//                  deliveryMode: PHImageRequestOptionsDeliveryMode,
//                  resizeMode: PHImageRequestOptionsResizeMode,
//                  completion:  ((_ image: UIImage?, _ userInfo: [AnyHashable: Any]?) -> Void)?) {
//        getImagesQueue.async { [weak self] in
//            guard let self = self else { return }
//            let indexPath = IndexPath(item: index, section: albumId)
//            self.getAlbumData(id: albumId) { data in
//                _ = self.getImageSemaphore.wait(timeout: .now() + .seconds(3))
//                guard let photoAsset = data?.fetchResult.object(at: index) else { self.getImageSemaphore.signal(); return }
//                self.fetchImage(from: photoAsset,
//                                userInfo: userInfo,
//                                targetSize: targetSize,
//                                deliveryMode: deliveryMode,
//                                resizeMode: resizeMode) { [weak self] (image, userInfo) in
//                                    defer { self?.getImageSemaphore.signal() }
//                                    completion?(image, userInfo)
//                }
//            }
//        }
//    }
//}
//
////....
////
////// Get albums
////photoLibrary.getAllAlbums { [weak self] albums in
////    self?.albums = albums
////    // reload views
////}
////
////// Get photo
////photoLibrary.getImage(albumId: albums[0].id,
////                      index: 1, userInfo: nil,
////                      targetSize: CGSize(width: 200, height: 200),
////                      deliveryMode: .fastFormat,
////                      resizeMode: .fast) { [weak self, weak cell] (image, userInfo) in
////                        // reload views
////}
////
////
////
////import UIKit
////import Photos
////
////class ViewController: UIViewController {
////
////    private weak var collectionView: UICollectionView?
////    var collectionViewFlowLayout: UICollectionViewFlowLayout? {
////        return collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
////    }
////
////    private lazy var photoLibrary = PhotoService()
////    private lazy var numberOfElementsInRow = 4
////
////    private lazy var cellIdentifier = "cellIdentifier"
////    private lazy var supplementaryViewIdentifier = "supplementaryViewIdentifier"
////    private var albums = [PhotoAlbumViewModel]()
////
////    private lazy var cellsTags = [IndexPath: Int]()
////    private lazy var tagKey = "cellTag"
////    private lazy var thumbnailImageSize = CGSize(width: 200, height: 200)
////
////    override func viewDidLoad() {
////
////        collectionView.backgroundColor = .white
////        self.collectionView = collectionView
////        collectionView.delegate = self
////        showAllPhotosButtonTouchedInside()
////
////        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "All", style: .done, target: self,
////                                                           action: #selector(showAllPhotosButtonTouchedInside))
////        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "last 3", style: .done, target: self,
////                                                            action: #selector(showLastSeveralPhotosButtonTouchedInside))
////    }
////
////    @objc func showAllPhotosButtonTouchedInside() {
////    photoLibrary.getAllAlbums { [weak self] albums in
////        self?.set(albums: albums)
////        if self?.collectionView?.dataSource == nil {
////            self?.collectionView?.dataSource = self
////        } else {
////            self?.collectionView?.reloadData()
////        }
////    }
////    }
////
////    @objc func showLastSeveralPhotosButtonTouchedInside() {
////        photoLibrary.getAllAlbums { [weak self] albums in
////            guard let firstAlbum = albums.first else { return }
////            var album: PhotoAlbumViewModel!
////            let maxPhotosToDisplay = 3
////            switch firstAlbum {
////                case .allPhotos(let id, let title, let count, let image, let isSelected):
////                    let newCount = count > maxPhotosToDisplay ? maxPhotosToDisplay : count
////                    album = .allPhotos(id: id, title: title, count: newCount, image: image, isSelected: isSelected)
////                case .regular(let id, let title, let count, let image, let isSelected):
////                    let newCount = count > maxPhotosToDisplay ? maxPhotosToDisplay : count
////                    album = .regular(id: id, title: title, count: newCount, image: image, isSelected: isSelected)
////            }
////            self?.set(albums: [album])
////            if self?.collectionView?.dataSource == nil {
////                self?.collectionView?.dataSource = self
////            } else {
////                self?.collectionView?.reloadData()
////            }
////        }
////    }
////
////    private func set(albums: [PhotoAlbumViewModel]) {
////        self.albums = albums
////        var counter = 0
////        for (section, album) in albums.enumerated() {
////            for row in 0..<album.count {
////                self.cellsTags[IndexPath(row: row, section: section)] = counter
////                counter += 1
////            }
////        }
////    }
////}
////
////extension ViewController: UICollectionViewDataSource {
////
////    func numberOfSections(in collectionView: UICollectionView) -> Int { return albums.count }
////    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
////        return albums[section].count
////    }
////
////    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
////        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: supplementaryViewIdentifier, for: indexPath) as! SupplementaryView
////        header.label?.text = albums[indexPath.section].title
////        return header
////    }
////
////    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
////        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! CollectionViewCell
////        let tag = cellsTags[indexPath]!
////        cell.tag = tag
////        photoLibrary.getImage(albumId: albums[indexPath.section].id,
////                              index: indexPath.item, userInfo: [tagKey: tag],
////                              targetSize: thumbnailImageSize,
////                              deliveryMode: .fastFormat,
////                              resizeMode: .fast) { [weak self, weak cell] (image, userInfo) in
////                                guard   let cell = cell, let tagKey = self?.tagKey,
////                                        let cellTag = userInfo?[tagKey] as? Int,
////                                        cellTag == cell.tag else { return }
////                                cell.imageView?.image = image
////        }
////        return cell
////    }
////}
////
////extension ViewController: UICollectionViewDelegate {}
