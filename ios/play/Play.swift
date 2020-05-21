//
//  Play.swift
//  ios
//
//  Created by Matthew on 2/5/20.
//  Copyright © 2020 bahlsenwitz. All rights reserved.
//

import UIKit

class Play: UIViewController, UITabBarDelegate, UIGestureRecognizerDelegate {
    
    var config: [[Piece?]]?
    
    var selection: Int? = nil
    
    public func setSelection(selection: Int){
        self.selection = selection
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        default: //1
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            
            let requestPayload: [String: Any] = [
                "id_self": self.playerSelf!.id,
                "id_other": self.playerOther!.id,
                "config": self.selection!]
            
            RequestPlay().execute(requestPayload: requestPayload) { (game) in
                /**
                 * ERROR HANDLING!!!
                 */
                if(game == nil){
                    return
                }
                DispatchQueue.main.async {
                    let height: CGFloat = UIScreen.main.bounds.height
                    let playerOther: EntityPlayer = game!.getPlayerOther(username: self.playerSelf!.username)
                    SelectTschess().tschess(playerSelf: self.playerSelf!, playerOther: playerOther, game: game!, height: height)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.boardViewConfig.isHidden = true
        
       
        
        
        //TODO: set these fonts...
        let fontSizeLegacy0: CGFloat = CGFloat(24)
        self.attributeAlphaDotFull = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSizeLegacy0, weight: UIFont.Weight.bold)]
        self.attributeAlphaDotHalf = [
            NSAttributedString.Key.foregroundColor: UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.5),
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSizeLegacy0, weight: UIFont.Weight.bold)]
        self.alphaDotFull = NSMutableAttributedString(string: "•", attributes: self.attributeAlphaDotFull!)
        self.alphaDotHalf = NSMutableAttributedString(string: "•", attributes: self.attributeAlphaDotHalf!)
        
        self.renderHeaderOther()
        
        
        
        self.tabBarMenu.delegate = self
        self.boardViewConfig.delegate = self
        self.boardViewConfig.dataSource = self
        self.boardViewConfig.isUserInteractionEnabled = true
        self.boardViewConfig.dragInteractionEnabled = false
        
        self.activityIndicator.isHidden = true
        
        if(self.selection == nil){
            switch Int.random(in: 0 ... 3) {
            case 0:
                self.renderConfig0()
            case 1:
                self.renderConfig1()
            case 2:
                self.renderConfig2()
            default:
                self.renderConfigS()
            }
            return // !!! //
        }
        switch self.selection! {
        case 1:
            self.renderConfig1()
        case 2:
            self.renderConfig2()
        default:
            self.renderConfig0()
        }
    }
    
    func renderConfig0() {
        self.selection = 0
        
        self.config = self.playerSelf!.getConfig(index: 0)
        self.activeConfigNumber.text = "0̸"
        self.boardViewConfig.reloadData()
        
        self.configLabelView.isHidden = false
        self.traditionalLabel.isHidden = true
        
        let activeConfigFull = NSMutableAttributedString()
        activeConfigFull.append(self.alphaDotFull!)
        let activeConfigNull = NSMutableAttributedString()
        activeConfigNull.append(self.alphaDotHalf!)
        
        self.indicatorLabelS.attributedText = activeConfigFull
        self.indicatorLabel2.attributedText = activeConfigNull
        self.indicatorLabel1.attributedText = activeConfigNull
        self.indicatorLabel0.attributedText = activeConfigNull
    }
    
    func renderConfig1() {
        self.selection = 1
        
        self.config = self.playerSelf!.getConfig(index: 1)
        self.activeConfigNumber.text = "1"
        self.boardViewConfig.reloadData()
        
        self.configLabelView.isHidden = false
        self.traditionalLabel.isHidden = true
        
        let activeConfigFull = NSMutableAttributedString()
        activeConfigFull.append(self.alphaDotFull!)
        let activeConfigNull = NSMutableAttributedString()
        activeConfigNull.append(self.alphaDotHalf!)
        
        self.indicatorLabelS.attributedText = activeConfigNull
        self.indicatorLabel2.attributedText = activeConfigFull
        self.indicatorLabel1.attributedText = activeConfigNull
        self.indicatorLabel0.attributedText = activeConfigNull
    }
    
    func renderConfig2() {
        self.selection = 2
        
        self.config = self.playerSelf!.getConfig(index: 2)
        self.activeConfigNumber.text = "2"
        self.boardViewConfig.reloadData()
        
        self.configLabelView.isHidden = false
        self.traditionalLabel.isHidden = true
        
        let activeConfigFull = NSMutableAttributedString()
        activeConfigFull.append(self.alphaDotFull!)
        let activeConfigNull = NSMutableAttributedString()
        activeConfigNull.append(self.alphaDotHalf!)
        
        self.indicatorLabelS.attributedText = activeConfigNull
        self.indicatorLabel2.attributedText = activeConfigNull
        self.indicatorLabel1.attributedText = activeConfigFull
        self.indicatorLabel0.attributedText = activeConfigNull
    }
    
    func renderConfigS() {
        self.selection = 3
        
        self.config = self.generateTraditionalMatrix()
        self.boardViewConfig.reloadData()
        
        self.configLabelView.isHidden = true
        self.traditionalLabel.isHidden = false
        
        let activeConfigFull = NSMutableAttributedString()
        activeConfigFull.append(self.alphaDotFull!)
        let activeConfigNull = NSMutableAttributedString()
        activeConfigNull.append(self.alphaDotHalf!)
        
        self.indicatorLabelS.attributedText = activeConfigNull
        self.indicatorLabel2.attributedText = activeConfigNull
        self.indicatorLabel1.attributedText = activeConfigNull
        self.indicatorLabel0.attributedText = activeConfigFull
    }
    
    func generateTraditionalMatrix() -> [[Piece]] {
        let row0 = [Pawn(), Pawn(), Pawn(), Pawn(), Pawn(), Pawn(), Pawn(), Pawn()]
        let row1 = [Rook(), Knight(), Bishop(), Queen(), King(), Bishop(), Knight(), Rook()]
        return [row0, row1]
    }
    
    var playerOther: EntityPlayer?
    
    func setPlayerOther(playerOther: EntityPlayer){
        self.playerOther = playerOther
    }
    
    var playerSelf: EntityPlayer?
    
    func setPlayerSelf(playerSelf: EntityPlayer){
        self.playerSelf = playerSelf
    }
    
    @IBOutlet weak var configLabelView: UIView!
    @IBOutlet weak var traditionalLabel: UILabel!
    
    @IBOutlet weak var boardViewConfig: BoardView!
    @IBOutlet weak var boardViewConfigHeight: NSLayoutConstraint!
    
    @IBOutlet weak var rankDateLabel: UILabel!
    @IBOutlet weak var eloLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let reuseIdentifier = "square"
    
    @IBOutlet weak var activeConfigNumber: UILabel!
    
    var items = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16"]
    
    @IBOutlet weak var indicatorLabel0: UILabel!
    @IBOutlet weak var indicatorLabel1: UILabel!
    @IBOutlet weak var indicatorLabel2: UILabel!
    @IBOutlet weak var indicatorLabelS: UILabel!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.boardViewConfig.bounces = false
        self.boardViewConfig.alwaysBounceVertical = false
        self.boardViewConfigHeight.constant = self.boardViewConfig.contentSize.height
        
        
    }
    
    //MARK: Properties
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tabBarMenu: UITabBar!
    
   
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
 
    
    var attributeAlphaDotFull: [NSAttributedString.Key: NSObject]?
    var attributeAlphaDotHalf: [NSAttributedString.Key: NSObject]?
    
    var alphaDotFull: NSMutableAttributedString?
    var alphaDotHalf: NSMutableAttributedString?
    
    public func renderHeaderOther() {
        self.avatarImageView.image = self.playerOther!.getImageAvatar()
        self.usernameLabel.text = self.playerOther!.username
        self.eloLabel.text = self.playerOther!.getLabelTextElo()
        self.rankLabel.text = self.playerOther!.getLabelTextRank()
        self.rankDateLabel.text = self.playerOther!.getLabelTextDate()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.boardViewConfig.reloadData()
        self.boardViewConfig.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
     
        
        self.swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRightGesture!.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(self.swipeRightGesture!)
        self.swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeftGesture!.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(self.swipeLeftGesture!)
        
        let elementCollectionViewGesture = UITapGestureRecognizer(target: self, action: #selector(self.renderElementCollectionView))
        self.boardViewConfig.addGestureRecognizer(elementCollectionViewGesture)
    }
    
    func flash() {
        let flashFrame = UIView(frame: self.boardViewConfig.bounds)
        flashFrame.backgroundColor = UIColor.white
        flashFrame.alpha = 0.7
        self.boardViewConfig.addSubview(flashFrame)
        UIView.animate(withDuration: 0.1, animations: {
            flashFrame.alpha = 0.0
        }, completion: {(finished:Bool) in
            flashFrame.removeFromSuperview()
        })
    }
    
    @objc func renderElementCollectionView() {
        if(self.traditionalLabel.isHidden == false){
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            self.flash()
            return
        }
        if(self.selection! == 0){
//            DispatchQueue.main.async() {
//                let height: CGFloat = UIScreen.main.bounds.height
//                SelectEditOther().execute(playerSelf: self.playerSelf!, playerOther: self.playerOther!, title: "config. 0̸", selection: 0, BACK: "PLAY", height: height)
//            }
            DispatchQueue.main.async() {
                UIApplication.shared.keyWindow?.rootViewController = EditOther.create(
                    playerSelf: self.playerSelf!,
                    playerOther: self.playerOther!,
                    select: 0,
                    back: "PLAY",
                    height: UIScreen.main.bounds.height)
            }
            return
        }
        if(self.selection! == 1){
//            DispatchQueue.main.async() {
//                let height: CGFloat = UIScreen.main.bounds.height
//                SelectEditOther().execute(playerSelf: self.playerSelf!, playerOther: self.playerOther!, title: "config. 1", selection: 1, BACK: "PLAY", height: height)
//            }
            DispatchQueue.main.async() {
                UIApplication.shared.keyWindow?.rootViewController = EditOther.create(
                    playerSelf: self.playerSelf!,
                    playerOther: self.playerOther!,
                    select: 1,
                    back: "PLAY",
                    height: UIScreen.main.bounds.height)
            }
            return
        }
        DispatchQueue.main.async() {
            UIApplication.shared.keyWindow?.rootViewController = EditOther.create(
                playerSelf: self.playerSelf!,
                playerOther: self.playerOther!,
                select: 2,
                back: "PLAY",
                height: UIScreen.main.bounds.height)
        }
    }
    
    var swipeRightGesture: UISwipeGestureRecognizer?
    var swipeLeftGesture: UISwipeGestureRecognizer?
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.right:
                if(self.traditionalLabel.isHidden == false){
                    self.renderConfig2()
                    return
                }
                if(activeConfigNumber.text == "2"){
                    self.renderConfig1()
                    return
                }
                if(activeConfigNumber.text == "1"){
                    self.renderConfig0()
                    return
                }
            case UISwipeGestureRecognizer.Direction.left:
                if(activeConfigNumber.text == "0̸"){
                    self.renderConfig1()
                    return
                }
                if(activeConfigNumber.text == "1"){
                    self.renderConfig2()
                    return
                }
                if(activeConfigNumber.text == "2"){
                    self.renderConfigS()
                    return
                }
            default:
                break
            }
        }
    }
    
    @IBAction func backButtonClick(_ sender: Any) {
        //DispatchQueue.main.async {
            //let screenSize: CGRect = UIScreen.main.bounds
            //let height: CGFloat = screenSize.height
            //SelectHome().execute(player: self.playerSelf!, height: height)
        //}
        //self.presentingViewController!.dismiss(animated: false, completion: nil)
        self.modalTransitionStyle = .crossDissolve
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - UICollectionViewDataSource
extension Play: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "square", for: indexPath) as! SquareCell
        cell.backgroundColor = .black
        if (indexPath.row / 8 == 0) {
            cell.backgroundColor = .white
        }
        if (indexPath.row % 2 == 0) {
            cell.backgroundColor = .white
            if (indexPath.row / 8 == 0) {
                cell.backgroundColor = .black
            }
        }
        let x = indexPath.row / 8
        let y = indexPath.row % 8
        cell.imageView.image = nil
        if(self.config![x][y] != nil){
            cell.imageView.image = self.config![x][y]!.getImageDefault()
        }
        cell.imageView.bounds = CGRect(origin: cell.bounds.origin, size: cell.bounds.size)
        cell.imageView.center = CGPoint(x: cell.bounds.size.width/2, y: cell.bounds.size.height/2)
        return cell
    }
    
}

//MARK: - UICollectionViewDelegateFlowLayout
extension Play: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellsAcross: CGFloat = 8
        let dim = collectionView.frame.width / cellsAcross
        return CGSize(width: dim, height: dim)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
