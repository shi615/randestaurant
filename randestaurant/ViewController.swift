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



struct Shop {
    var name: String?
    var phoneNumber: String?
    var website: URL?
    var location: CLLocationCoordinate2D?
}

class ViewController: UIViewController {
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var waitingView: UIView!
    @IBOutlet weak var shopNameLabel: UILabel!
    @IBOutlet weak var costTimeLabel: UILabel!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var noWebSiteLabel: UILabel!
    
    var userLocation: CLLocationCoordinate2D?
    var shops = [Shop]()
    var foodAnimationView = LottieAnimationView()
    var loadingAnimationView = LottieAnimationView()
    var waitingAnimationView = LottieAnimationView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpWallPaperView()
        setUpContainerView()
        setUpButton()
    }
    
    private func setUpContainerView() {
//        containerView.translatesAutoresizingMaskIntoConstraints = false

        // 4. 为容器视图设置阴影效果
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
        webView.isHidden = true
        webView.layer.cornerRadius = 20
        webView.clipsToBounds = true
        
        setUpLoadingView()
        setUpWaitingView()

    }
    
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
    
    private func startWaiting() {
        waitingView.isHidden = false
        waitingAnimationView.play()
    }
    
    private func startLoading() {
        shopNameLabel.isHidden = true
        costTimeLabel.isHidden = true
        webView.isHidden = true
        waitingView.isHidden = true
        waitingAnimationView.stop()
        
        loadingView.isHidden = false
        loadingAnimationView.play()
        foodAnimationView.play()
    }
    
    private func stopLoading() {
        shopNameLabel.isHidden = false
        costTimeLabel.isHidden = false
        webView.isHidden = false

        loadingView.isHidden = true
        loadingAnimationView.stop()
        foodAnimationView.stop()
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        foodAnimationView.play()
        startLoading()
        startSearch()
    }
    
    private func startSearch() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let location = appDelegate.userLocation {
            search_restaurant(userLocation: location)
        } else {
            button.titleLabel?.text = "座標見つかりません！"
        }
    }

    func search_restaurant(userLocation: CLLocationCoordinate2D) {
        let request = MKLocalSearch.Request()
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        
        request.naturalLanguageQuery = "レストラン" // 検索キーワードを入力
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
            guard let response = response else {
                print("Search error: \(error?.localizedDescription ?? "Unknown error")")
                self.stopLoading()
                return
            }

            for item in response.mapItems {
                let shop = Shop(
                    name: item.name ?? "おっと！何か問題あったようだ。。",
                    phoneNumber: item.phoneNumber,
                    website: item.url,
                    location: item.placemark.coordinate
                )
                self.shops.append(shop)
            }
            
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
    
    private func handleWebView(for shop: Shop) {
        if let url = shop.website {
//            let urlString = url.absoluteString
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

}
