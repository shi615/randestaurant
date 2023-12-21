//
//  ViewController.swift
//  randestaurant
//
//  Created by 石智光 on 2023/10/20.
//

import UIKit
import MapKit
import CoreLocation
import Lottie
import WebKit
import GoogleMaps
import GooglePlaces


// 店名、カテゴリ、URL、写真、営業時間、評価、電話番号
// name, types, website, photos, openingHours, rating, phoneNumber
struct Shop {
    var name: String?
    var types: [String?]
    var website: URL?
    var photos: [UIImage?]
    var openingWeekdayText: [String?]
    var rating: String?
    var phoneNumber: String?
    var location: CLLocationCoordinate2D?
}

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var shopNameLabel: UILabel!
    @IBOutlet weak var costTimeLabel: UILabel!
    @IBOutlet weak var noWebSiteLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var waitingView: UIView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageSlidesView: UIView!
    @IBOutlet weak var noPhotosLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var userLocation: CLLocationCoordinate2D?
    var shops = [Shop]()
    var foodAnimationView = LottieAnimationView()
    var loadingAnimationView = LottieAnimationView()
    var waitingAnimationView = LottieAnimationView()

    let locationManager = CLLocationManager()
    var searchQuery = "レストラン"
    var filterTypes = ["food", "restaurant", "cafe", "bakery"]
    var northEast = CLLocationCoordinate2D()
    var southWest = CLLocationCoordinate2D()
    var distance = 2.0 // ２km
    let latitudeDegreesPerKm = 1.0 / 111.0 // 緯度1kmあたりの差分
    let longitudeDegreesPerKmAt35Lat = 1.0 / 91.0 // 経度1kmあたりの差分（緯度35度の場合
    
    private var placesClient: GMSPlacesClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        setUpWallPaperView()
        setUpContainerView()
        setUpImageSlidesView([])
        setUpButton()
        placesClient = GMSPlacesClient.shared()
        getPlaceDetail()
    }

    // 現在地座標更新時に範囲座標を更新する
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            // 東北座標更新
            northEast = CLLocationCoordinate2D(latitude: location.coordinate.latitude + distance * latitudeDegreesPerKm, longitude: location.coordinate.longitude + distance * longitudeDegreesPerKmAt35Lat)
            // 南西座標更新
            southWest = CLLocationCoordinate2D(latitude: location.coordinate.latitude - distance * latitudeDegreesPerKm, longitude: location.coordinate.longitude - distance * longitudeDegreesPerKmAt35Lat)
            
            // Specify the place data types to return.
//            let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt64(UInt(GMSPlaceField.name.rawValue) | UInt(GMSPlaceField.placeID.rawValue)))
//            placesClient?.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: fields, callback: {
//              (placeLikelihoodList: Array<GMSPlaceLikelihood>?, error: Error?) in
//              if let error = error {
//                print("An error occurred: \(error.localizedDescription)")
//                return
//              }
//
//              if let placeLikelihoodList = placeLikelihoodList {
//                for likelihood in placeLikelihoodList {
//                  let place = likelihood.place
//                  print("Current Place name \(String(describing: place.name)) at likelihood \(likelihood.likelihood)")
//                  print("Current PlaceID \(String(describing: place.placeID))")
//                }
//              }
//            })
        }
    }
    
    // 背景を設置する
    private func setUpWallPaperView() {
        let wallPaperView = LottieAnimationView(name: "wallPaperAnimation")
        wallPaperView.translatesAutoresizingMaskIntoConstraints = false
        wallPaperView.isUserInteractionEnabled = false
        
        view.insertSubview(wallPaperView, at: 0)
        
        NSLayoutConstraint.activate([
            wallPaperView.topAnchor.constraint(equalTo: view.topAnchor),
            wallPaperView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            wallPaperView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wallPaperView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        wallPaperView.loopMode = .loop
        wallPaperView.play()
    }
    
    // お店コンテナViewを設置する
    private func setUpContainerView() {
        containerView.backgroundColor = .white
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.5
        containerView.layer.cornerRadius = 30
        
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        shopNameLabel.adjustsFontSizeToFitWidth = true
        shopNameLabel.minimumScaleFactor = 0.5
        shopNameLabel.numberOfLines = 0
        
        shopNameLabel.isHidden = true
        costTimeLabel.isHidden = true
        ratingLabel.isHidden = true
        noPhotosLabel.isHidden = true
        webView.isHidden = true
        webView.layer.cornerRadius = 20
        webView.clipsToBounds = true
        
        setUpLoadingView()
        setUpWaitingView()

    }
    
    // ローディング画面を設置する
    private func setUpLoadingView() {
        loadingView.isHidden = true
        loadingView.backgroundColor = UIColor.white.withAlphaComponent(0)

        loadingAnimationView = LottieAnimationView(name : "loading_01")
        loadingAnimationView.translatesAutoresizingMaskIntoConstraints = false
        
        loadingView.addSubview(loadingAnimationView)
        
        NSLayoutConstraint.activate([
            loadingAnimationView.topAnchor.constraint(equalTo: loadingView.topAnchor),
            loadingAnimationView.bottomAnchor.constraint(equalTo: loadingView.bottomAnchor),
            loadingAnimationView.leadingAnchor.constraint(equalTo: loadingView.leadingAnchor),
            loadingAnimationView.trailingAnchor.constraint(equalTo: loadingView.trailingAnchor)
        ])
        
        loadingAnimationView.loopMode = .loop
    }
    
    // 待ち画面を設置する
    private func setUpWaitingView() {
        waitingView.isHidden = true
        waitingView.backgroundColor = UIColor.white.withAlphaComponent(0)
        
        waitingAnimationView = LottieAnimationView(name : "waiting_01")
        waitingAnimationView.translatesAutoresizingMaskIntoConstraints = false
        
        waitingView.addSubview(waitingAnimationView)
        
        NSLayoutConstraint.activate([
            waitingAnimationView.topAnchor.constraint(equalTo: waitingView.topAnchor),
            waitingAnimationView.bottomAnchor.constraint(equalTo: waitingView.bottomAnchor),
            waitingAnimationView.leadingAnchor.constraint(equalTo: waitingView.leadingAnchor),
            waitingAnimationView.trailingAnchor.constraint(equalTo: waitingView.trailingAnchor)
        ])
        
        waitingAnimationView.loopMode = .loop
        
        noWebSiteLabel.isHidden = true
        
        startWaiting()
    }
    
    // 待ち画面を表示する
    private func startWaiting() {
        waitingView.isHidden = false
        waitingAnimationView.play()
    }
    
    private func setUpImageSlidesView(_ images: [UIImage]) {
        // 初期化
        for subview in imageSlidesView.subviews {
            subview.removeFromSuperview()
        }
        // 加载图片资源
//        let images = [UIImage(named: "wallPaper"), UIImage(named: "wallPaper_02")].compactMap { $0 }
        let slideshowView = ImageSlideshowView(frame: .zero, images: images)
        imageSlidesView.backgroundColor = .clear
        imageSlidesView.addSubview(slideshowView)
        
        // 禁用 autoresizing mask 转换为约束
        slideshowView.translatesAutoresizingMaskIntoConstraints = false

        // 添加约束
        NSLayoutConstraint.activate([
            slideshowView.topAnchor.constraint(equalTo: imageSlidesView.topAnchor),
            slideshowView.bottomAnchor.constraint(equalTo: imageSlidesView.bottomAnchor),
            slideshowView.leadingAnchor.constraint(equalTo: imageSlidesView.leadingAnchor),
            slideshowView.trailingAnchor.constraint(equalTo: imageSlidesView.trailingAnchor)
        ])
    }
    
    // ボタンを設置する
    private func setUpButton() {
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 5
        button.layer.shadowOpacity = 0.5
        button.layer.cornerRadius = 30

        button.backgroundColor = .white
        
        button.configuration?.contentInsets.top = 100
        button.setNeedsLayout()
        setUpFoodView()
    }
    
    // ボタンが押された時
    @IBAction func buttonPressed(_ sender: UIButton) {
        foodAnimationView.play()
        startLoading()
        getPlaceDetail()
    }
    
    // ローディング画面を表示する
    private func startLoading() {
        shopNameLabel.isHidden = true
        costTimeLabel.isHidden = true
        ratingLabel.isHidden = true
        webView.isHidden = true
        waitingView.isHidden = true
        noPhotosLabel.isHidden = true
        imageSlidesView.isHidden = true
        waitingAnimationView.stop()
        
        loadingView.isHidden = false
        loadingAnimationView.play()
        foodAnimationView.play()
    }
    
    // ローディング画面を隠す
    private func stopLoading() {
        shopNameLabel.isHidden = false
        costTimeLabel.isHidden = false
        ratingLabel.isHidden = false
        webView.isHidden = false

        loadingView.isHidden = true
        loadingAnimationView.stop()
        foodAnimationView.stop()
    }
    
    // ボタン上のフードアニメーションを設置する
    private func setUpFoodView() {
        foodAnimationView = LottieAnimationView(name: "food_01")
        foodAnimationView.animationSpeed = 3
        foodAnimationView.translatesAutoresizingMaskIntoConstraints = false
        foodAnimationView.isUserInteractionEnabled = false
        foodAnimationView.loopMode = .loop
        
        button.addSubview(foodAnimationView)
        
        NSLayoutConstraint.activate([
            foodAnimationView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            foodAnimationView.bottomAnchor.constraint(equalTo: button.titleLabel!.topAnchor, constant: -5),
            foodAnimationView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    // GMSPlace情報を取得する
    private func getPlaceDetail() {
        shops = [Shop]()

        // フィルター設定
        let filter = GMSAutocompleteFilter()

        // フィルター設定：カテゴリ
//        filter.types = filterTypes
        
        // フィルター設定 検索範囲を特定
        filter.origin = CLLocation(latitude: northEast.latitude, longitude: northEast.longitude)
        filter.locationRestriction = GMSPlaceRectangularLocationOption(northEast, southWest)
        
        // Placeを取得開始
        self.placesClient.findAutocompletePredictions(
            fromQuery: searchQuery,
            filter: filter,
            sessionToken: nil
        ) { [self]
            (results_findAutocompletePredictions, error) -> Void in
            guard error == nil else {
                print("Autocomplete error: \(error!.localizedDescription)")
                return
            }

            // Placeが返ってきた時
            if let results = results_findAutocompletePredictions, !results.isEmpty {
                print("Responsed \(results.count) Store(s).")
                if let randomResult = results.randomElement() {
                    placesClient.lookUpPlaceID(randomResult.placeID, callback: {
                        (results_lookUpPlaceID, error) -> Void in
                        // imagesを取得
                        if let results = results_lookUpPlaceID {
                            // 店名、カテゴリ、URL、写真、営業時間、評価、電話番号、座標
                            // name, types, website, photos, openingHours, rating, phoneNumber, location
                            var images: [UIImage] = []
                            if let photos = results.photos {
                                for photo in photos {
                                    self.placesClient?.loadPlacePhoto(
                                        photo,
                                        callback: {
                                            (photo_loadPlacePhoto, error) -> Void in
                                            guard error == nil else {
                                                print("Autocomplete error: \(error!.localizedDescription)")
                                                return
                                            }
                                            
                                            if let photo_loadPlacePhoto = photo_loadPlacePhoto {
                                                if images.isEmpty {
                                                    self.imageView.image = photo_loadPlacePhoto
                                                    // 画面を再描画、写真を反応させるために
                                                    self.view.setNeedsDisplay()
                                                }
                                                images.append(photo_loadPlacePhoto);
                                            } else {
                                                self.imageView.image = nil
                                                self.view.setNeedsDisplay()
                                            }
                                        }
                                    )
                                }
                                
                            }
                            
                            if images.isEmpty {
                                self.noPhotosLabel.isHidden = false
                            } else {
                                self.noPhotosLabel.isHidden = true
                                self.imageSlidesView.isHidden = false
                                self.setUpImageSlidesView(images)
                            }
                            self.view.setNeedsDisplay()

                            // openingHoursを取得
                            var openingWeekdayText: [String]!
                            if let weekdayText = results.openingHours?.weekdayText {
                                openingWeekdayText = weekdayText
                            }
                            
                            // お店情報を構造体に格納
                            let shop = Shop(
                                name: results.name,
                                types: results.types ?? ["種類がありません"],
                                website: results.website ?? nil,
                                photos: images,
                                openingWeekdayText: openingWeekdayText ?? ["営業時間を取得失敗"],
                                rating: String(describing: results.rating),
                                phoneNumber: results.phoneNumber ?? "電話番号がありません",
                                location: results.coordinate
                            )
                            self.shops.append(shop)
                            print("There is(are) \(shop.photos.count) photo(s).")
                            
                            // 画面を更新
                            self.showDetail()
                            self.stopLoading()
                        }
                    })
                }
            } else {
                print("近くにお店がない？！何だと！")
                stopLoading()
            
                shopNameLabel.isHidden = true
                costTimeLabel.isHidden = true
                ratingLabel.isHidden = true
                webView.isHidden = true
                startWaiting()
            }
        }
    }
    
    private func showDetail() {
        shopNameLabel.isHidden = false
        costTimeLabel.isHidden = false
        ratingLabel.isHidden = false
        webView.isHidden = false
        
        if !shops.isEmpty, let shopLocation = shops[shops.count - 1].location {
            calculateWalkingTime(destination: shopLocation) { (time, error) in
                if let time = time {
                    self.costTimeLabel.text = "歩いて約 \(time) 分"
                } else if let error = error {
                    print("Error getting walking time: \(error)")
                }
                
                self.shopNameLabel.text = self.shops[self.shops.count - 1].name
                self.ratingLabel.text = "⭐️ " + String(describing: self.shops[self.shops.count - 1].rating ?? "")
                
                self.handleWebView(for: self.shops[self.shops.count - 1])
                self.view.setNeedsDisplay()
            }
        }
    }
    
    private func handleWebView(for shop: Shop) {
        if let url = shop.website {
            let request = URLRequest(url: url)
            webView.alpha = 1
            webView.isUserInteractionEnabled = true
            noWebSiteLabel.isHidden = true
            webView.load(request)
            print(url)
        } else {
            webView.alpha = 0
            webView.isUserInteractionEnabled = false
            noWebSiteLabel.isHidden = false
            print("URLがない！")
            startWaiting()
        }
    }


    private func calculateWalkingTime(destination: CLLocationCoordinate2D, completion: @escaping (Int?, Error?) -> Void) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let location = appDelegate.userLocation {
            let sourcePlacemark = MKPlacemark(coordinate: location)
            let destinationPlacemark = MKPlacemark(coordinate: destination)

            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: sourcePlacemark)
            request.destination = MKMapItem(placemark: destinationPlacemark)
            request.transportType = .walking

            let directions = MKDirections(request: request)
            directions.calculate { (response, error) in
                if let route = response?.routes.first {
                    let timeInMinutes = Int(route.expectedTravelTime / 60.0)
                    completion(timeInMinutes, nil)
                } else {
                    completion(nil, error)
                }
            }
        } else {
            button.titleLabel?.text = "座標見つかりません！"
        }
    }

    private func search_restaurant(userLocation: CLLocationCoordinate2D) {
        let request = MKLocalSearch.Request()
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        
        request.naturalLanguageQuery = "パン屋" // 検索キーワードを入力
        request.region = MKCoordinateRegion(center: userLocation , span: span)
        
//        let category: [MKPointOfInterestCategory] = [
//            .airport,
//            .library,
//            ...
//        ]
        
        
        request.resultTypes = .pointOfInterest
        
        shops = [Shop]()
        
        let search = MKLocalSearch(request: request)

        search.start { (response, error) in
            guard response != nil else {
                print("Search error: \(error?.localizedDescription ?? "Unknown error")")
                self.stopLoading()
                return
            }

//            for item in response.mapItems {
//                let shop = Shop(
//                    name: item.name ?? "おっと！何か問題あったようだ。。",
//                    category: item.phoneNumber,
//                    website: item.url,
//                    photos: item.placemark.coordinate
//                )
//                self.shops.append(shop)
//            }
            
            self.randomRestaurant()
            self.stopLoading()
        }
    }
    
    private func randomRestaurant() {
        shopNameLabel.isHidden = false
        costTimeLabel.isHidden = false
        webView.isHidden = false

        if let randomShop = shops.randomElement() {
            shopNameLabel.text = randomShop.name
            handleWebView(for: randomShop)
            
            if let shopLocation = randomShop.location {
                calculateWalkingTime(destination: shopLocation) { (time, error) in
                    if let time = time {
                        self.costTimeLabel.text = "歩いて約 \(time) 分"
                    } else if let error = error {
                        print("Error getting walking time: \(error)")
                    }
                }
            }
        }
    }

}
