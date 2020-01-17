//
//  PurchaseDetail.swift
//  ios
//
//  Created by Matthew on 1/17/20.
//  Copyright © 2020 bahlsenwitz. All rights reserved.
//

//
//  PurchaseNaptune.swift
//  ios
//
//  Created by Matthew on 1/14/20.
//  Copyright © 2020 bahlsenwitz. All rights reserved.
//

import UIKit
import StoreKit

class PurchaseDetail: UIViewController, UITabBarDelegate, UITextViewDelegate {
    
    var skin: Skin?
    
    public func setSkin(skin: Skin){
        self.skin = skin
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    //@IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    //@IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var rankLabel: UILabel!
    //@IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var tschxLabel: UILabel!
    //@IBOutlet weak var tschxLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    //@IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    //@IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var countdownTimerLabel: UILabel!
    
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var cellBackgroundImage: UIImageView!
    
    @IBOutlet weak var cellForegroundView: UIView!
    @IBOutlet weak var cellForegroundImage: UIImageView!
    //@IBOutlet weak var previewButton: UIButton!
    //@IBOutlet weak var purchaseButton: UIButton!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var purchaseButton: UIButton!
    //@IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    //@IBOutlet weak var tabBarMenu: UITabBar!
    @IBOutlet weak var tabBarMenu: UITabBar!
    
    var player: Player?
    
    public func setPlayer(player: Player){
        self.player = player
    }
    
    var remaining: Int?
    
    public func setRemaining(remaining: Int){
        self.remaining = remaining
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarMenu.delegate = self
        
        let description = "" +
            "• freshly minted individual edition of the iapetus game skin, one of fifty\r\r" +
            "• visible to oneself and opponent during gameplay\r\r" +
            "• globally visible in leaderboard and on challenge/review endgame snapshot\r\r" +
        "• design inspired by science fantasy novel \"the chessmen of mars\" by edgar rice burroughs\r\r"
        
        self.descriptionTextView.isEditable = false
        self.descriptionTextView.backgroundColor = UIColor.white
        self.descriptionTextView.textColor = UIColor.black
        self.descriptionTextView.text = description
        
        //Product.store.requestProducts{ [weak self] success, products in
            //guard let self = self else {
                //return
            //}
            //if success {
            //self.products = products!
            //let product: SKProduct = self.products[0]
            //DispatchQueue.main.async {
            //self.purchaseButton.setTitle( "$\(product.price.floatValue)" , for: .normal)
            //}
            //}
        //}
        
        self.titleLabel.text = self.skin!.getName()
        
        self.cellForegroundView.backgroundColor = self.skin!.getForeColor()
        self.cellForegroundView.alpha = self.skin!.getForeAlpha()
        self.cellForegroundImage.image = self.skin!.getForeImage()
        
        self.cellBackgroundView.backgroundColor = self.skin!.getBackColor()
        self.cellBackgroundView.alpha = self.skin!.getBackAlpha()
        self.cellBackgroundImage.image = self.skin!.getBackImage()
    }
    
    var products: [SKProduct] = [SKProduct]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let dataDecoded: Data = Data(base64Encoded: self.player!.getAvatar(), options: .ignoreUnknownCharacters)!
        let decodedimage = UIImage(data: dataDecoded)
        self.avatarImageView.image = decodedimage
        self.rankLabel.text = self.player!.getRank()
        self.tschxLabel.text = "₮\(self.player!.getTschx())"
        self.usernameLabel.text = self.player!.getName()
    }
    
    //    @IBAction func purchaseButtonClick(_ sender: Any) {
    //        if(self.products.isEmpty){
    //            return
    //        }
    //        let product = self.products[0]
    //        Product.store.buyProduct(product, player: self.player!)
    //    }
    
    //    @IBAction func previewButtonClick(_ sender: Any) {
    //        DispatchQueue.main.async {
    //            switch StoryboardSelector().device() {
    //            case "CALHOUN":
    //                let storyboard: UIStoryboard = UIStoryboard(name: "PurchaseDetail", bundle: nil)
    //                let viewController = storyboard.instantiateViewController(withIdentifier: "PurchaseDetail") as! PurchaseDetail
    //                viewController.setPlayer(player: self.player!)
    //                self.present(viewController, animated: false, completion: nil)
    //                return
    //            default:
    //                return
    //            }
    //        }
    //    }
    
    @IBAction func backButtonClick(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "ShowMeSkins", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ShowMeSkins") as! ShowMeSkins
        viewController.setPlayer(player: self.player!)
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 0:
            let storyboard: UIStoryboard = UIStoryboard(name: "ShowMeSkins", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ShowMeSkins") as! ShowMeSkins
            viewController.setPlayer(player: self.player!)
            UIApplication.shared.keyWindow?.rootViewController = viewController
        default:
            StoryboardSelector().home(player: self.player!)
        }
    }
}





