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



struct Shop {
    var name: String?
    var phoneNumber: String?
    var website: URL?
}

class ViewController: UIViewController {
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var coordinateLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var shopTableView: UITableView!
    
    var userLocation: CLLocationCoordinate2D?
    var shops = [Shop]()
    var starAnimationView = LottieAnimationView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpShopTableView()
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
        containerView.layer.cornerRadius = 50
//        containerView.clipsToBounds = true

        // 5. 确保 UITableView 和 UITableViewCell 的背景是透明的
        shopTableView.backgroundColor = .clear

    }
    
    private func setUpShopTableView() {
        shopTableView.dataSource = self
        shopTableView.delegate = self
        shopTableView.register(UINib(nibName: "ShopTableViewCell", bundle: nil),forCellReuseIdentifier:"ShopTableViewCell")
        shopTableView.rowHeight = UITableView.automaticDimension
        shopTableView.estimatedRowHeight = 100.0

//        // 1. 设置背景颜色为白色
//        shopTableView.backgroundColor = .white
//
//        // 2. 添加阴影效果
//        shopTableView.layer.shadowColor = UIColor.black.cgColor // 阴影颜色
//        shopTableView.layer.shadowOffset = CGSize(width: 0, height: 2) // 阴影偏移量
//        shopTableView.layer.shadowRadius = 4  // 阴影半径
//        shopTableView.layer.shadowOpacity = 0.5 // 阴影不透明度
//        shopTableView.layer.masksToBounds = false // 允许阴影超出视图边界
//        shopTableView.layer.cornerRadius = 50

    }
    
    private func setUpStarView() {
        starAnimationView = LottieAnimationView(name: "food_01")
        starAnimationView.animationSpeed = 5
        starAnimationView.translatesAutoresizingMaskIntoConstraints = false
        starAnimationView.isUserInteractionEnabled = false
        
        button.addSubview(starAnimationView)
        
        NSLayoutConstraint.activate([
            starAnimationView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            starAnimationView.bottomAnchor.constraint(equalTo: button.titleLabel!.topAnchor, constant: -5),
            starAnimationView.heightAnchor.constraint(equalToConstant: 100)
        ])

        starAnimationView.play()
    }
    
    private func setUpButton() {
        
//        var transform = CATransform3DIdentity
//        transform.m34 = -1.0 / 500.0  // 透视效果
//        transform = CATransform3DRotate(transform, CGFloat.pi / 6, 1, 0, 0) // 绕x轴旋转
//        button.layer.transform = transform

        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 5
        button.layer.shadowOpacity = 0.5
        button.layer.cornerRadius = 50

        button.backgroundColor = .white
        
        button.configuration?.contentInsets.top = 100
        button.setNeedsLayout()
        setUpStarView()
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        starAnimationView.play()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let location = appDelegate.userLocation {
            search_restaurant(userLocation: location)
        } else {
            coordinateLabel.text = "座標見つかりません。"
        }
    }

    func search_restaurant(userLocation: CLLocationCoordinate2D) {
        let request = MKLocalSearch.Request()
        
        request.naturalLanguageQuery = "ファーストフード" // 検索キーワードを入力
        request.region = MKCoordinateRegion(center: userLocation , span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        //        let category: [MKPointOfInterestCategory] = [
        //            .airport,
        //            .library
        //        ]
        
        
        request.resultTypes = .pointOfInterest
        
        shops = [Shop]()
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else {
                print("Search error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            for item in response.mapItems {
                let shop = Shop(
                    name: item.name ?? "おっと！何か問題あったようだ。。",
                    phoneNumber: item.phoneNumber,
                    website: item.url
                )
                self.shops.append(shop)
                print(item.pointOfInterestCategory!)
            }
            
            self.shopTableView.reloadData()
        }

    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shops.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShopTableViewCell", for: indexPath) as! ShopTableViewCell
        
        let shop = shops[indexPath.row]
        cell.shopNameLabel?.text = shop.name
        cell.tellPhoneLabel?.text = shop.phoneNumber
        if let urlString = shop.website?.absoluteString {
            cell.webSiteLabel?.text = urlString
        }
        
        print(shop.name ?? "name??")
        print(cell.shopNameLabel?.text ?? "shopname??")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = shops[indexPath.row]
    }

}
