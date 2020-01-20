//
//  HomeMenuTable.swift
//  ios
//
//  Created by Matthew on 1/19/20.
//  Copyright © 2020 bahlsenwitz. All rights reserved.
//

import UIKit

class HomeMenuTable: UITableViewController {
    
    var leaderboardTableList: [Game] = [Game]()
    var player: Player?
    
    public var pageFromWhichContentLoads: Int = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.fetchGameList(page: pageFromWhichContentLoads)
    }
    
    var searchHeaderAlignmentConstranit: NSLayoutConstraint?
    
    func setSearchHeaderAlignmentConstranit(searchHeaderAlignmentConstranit: NSLayoutConstraint){
        self.searchHeaderAlignmentConstranit = searchHeaderAlignmentConstranit
    }
    
    var searchHolderView: UIView?
    func setSearchHolderView(searchHolderView: UIView){
        self.searchHolderView = searchHolderView
    }
    
    var lastY: CGFloat?
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        print("self.searchHolderView!.frame.origin.y  \(self.searchHolderView!.frame.origin.y )")
        
        print("I'm scrolling! \(scrollView.contentOffset.y)")
        if(scrollView.contentOffset.y < -46) {
            //if(self.containerViewTopConstraint!.constant == 0){
                //self.containerViewTopConstraint!.constant += 46
            //}
            //if(self.searchHolderView!.frame.origin.y != 222){
                //self.searchHolderView!.frame.origin.y += 46
            //}
            //
            if(self.searchHeaderAlignmentConstranit!.constant == 0){
                self.searchHeaderAlignmentConstranit!.constant += 46
            }
        }
        if(lastY != nil){
            if(scrollView.contentOffset.y > 0) {
                if(scrollView.contentOffset.y > lastY!){
                    print("YES")
                    if(self.searchHeaderAlignmentConstranit!.constant > 0){
                        if(self.searchHeaderAlignmentConstranit!.constant.remainder(dividingBy: 2).isZero){
                            self.searchHeaderAlignmentConstranit!.constant -= 2
                        }
                        
                    }
                } else {
                    print("NO")
                }
            }
            
//            if(scrollView.contentOffset.y > 0) {
//                if(scrollView.contentOffset.y > lastY!){
//                    print("YES")
//                    if(self.searchHolderView!.frame.origin.y > 176){
//                        self.searchHolderView!.frame.origin.y -= 1
//                    }
//                } else {
//                    print("NO")
//                }
//            }
            
//            if(scrollView.contentOffset.y > 0) {
//                if(scrollView.contentOffset.y > lastY!){
//                    print("YES")
//                    if(self.containerViewTopConstraint!.constant > 0){
//                        self.containerViewTopConstraint!.constant -= 1
//                    }
//                } else {
//                    print("NO")
//                }
//            }
        }
        lastY = scrollView.contentOffset.y
        print("                     lastY: \(lastY!)")
    }
    

    
    
    var activityIndicator: UIActivityIndicatorView?
    
    public func setIndicator(indicator: UIActivityIndicatorView){
        self.activityIndicator = indicator
    }
    
    public func setPlayer(player: Player) {
        self.player = player
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.tableFooterView = UIView()
    }
    
    func appendToLeaderboardTableList(additionalCellList: [Game]) {
        let t0 = leaderboardTableList.count
        for game in additionalCellList.sorted(by: {Int($0.getOpponentElo())! > Int($1.getOpponentElo())!}) {
            if(!leaderboardTableList.contains(game)){
                leaderboardTableList.append(game)
            }
        }
        DispatchQueue.main.async() {
            if(t0 != self.leaderboardTableList.count){
                self.leaderboardTableList = self.leaderboardTableList.sorted(by: {Int($0.getOpponentElo())! > Int($1.getOpponentElo())!})
                //self.activityIndicator!.stopAnimating()
                //self.activityIndicator!.isHidden = true
                self.tableView.reloadData()
            }
        }
    }
    
    func getLeaderboardTableList() -> [Game] {
        return leaderboardTableList
    }
    
    func resetLeaderboardTableList() {
        self.pageFromWhichContentLoads = 0
        self.leaderboardTableList = [Game]()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaderboardTableList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeMenuCell", for: indexPath) as! HomeMenuCell
        let gameTableMenuItem = leaderboardTableList[indexPath.row]
        
        let dataDecoded: Data = Data(base64Encoded: gameTableMenuItem.getOpponentAvatar(), options: .ignoreUnknownCharacters)!
        let decodedimage = UIImage(data: dataDecoded)
        cell.avatarImageView.image = decodedimage
        cell.rankLabel.text = gameTableMenuItem.getOpponentRank()
        cell.usernameLabel.text = gameTableMenuItem.getOpponentName()
        
        //cell.actionLabel.text = "challenge"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let discoverSelectionDictionary = ["discover_selection": indexPath.row]
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: "DiscoverSelection"),
            object: nil,
            userInfo: discoverSelectionDictionary)
    }
    
    override open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == leaderboardTableList.count - 1 {
            pageFromWhichContentLoads += 1
            fetchGameList(page: pageFromWhichContentLoads)
        }
    }
    
    func fetchGameList(page: Int) {
        let requestPayload = ["page": page, "size": 13]
        LeaderboardPageTask().execute(requestPayload: requestPayload) { (result) in
            if(result == nil){
                return
            }
            self.appendToLeaderboardTableList(additionalCellList: result!)
        }
    }
}
