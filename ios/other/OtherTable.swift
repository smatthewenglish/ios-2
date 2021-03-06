//
//  OtherMenuTable.swift
//  ios
//
//  Created by Matthew on 1/19/20.
//  Copyright © 2020 bahlsenwitz. All rights reserved.
//

import UIKit
import SwipeCellKit

class OtherTable: UITableViewController, SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let username: String = self.player!.username
        if(orientation == .right) {
            let rematch = SwipeAction(style: .default, title: nil) { action, indexPath in
                
                let cell = self.tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
                
                cell.hideSwipe(animated: false, completion: nil)
                
                let game: EntityGame = self.list[indexPath.row]
                
                DispatchQueue.main.async {
                    let storyboard: UIStoryboard = UIStoryboard(name: "Snapshot", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "Snapshot") as! Snapshot
                    viewController.game = game
                    viewController.player = self.player!
                    self.present(viewController, animated: false, completion: nil)
                }
            }
            rematch.backgroundColor = UIColor(red: 39.0/255, green: 41.0/255, blue: 44.0/255, alpha: 1.0)
            rematch.title = "Snapshot"
            let game: EntityGame = self.list[indexPath.row]
            if(game.condition == "DRAW"){
                rematch.textColor = .yellow
                rematch.image = UIImage(named: "challenge_yel")!
                return [rematch]
            }
            if(game.getWinner(username: username)){
                rematch.textColor = .green
                rematch.image = UIImage(named: "challenge_grn")!
                return [rematch]
            }
            rematch.textColor = .red
            rematch.image = UIImage(named: "challenge_red")!
            return [rematch]
        }
        return nil
    }
    
    var player: EntityPlayer?
    
    var list: [EntityGame] = [EntityGame]()
    
    var label: UILabel?
    
    public var pageCount: Int
    
    required init?(coder aDecoder: NSCoder) {
        self.pageCount = 0
        super.init(coder: aDecoder)
    }
    
    func getGameMenuTableList() -> [EntityGame] {
        return list
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let game = list[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OtherCell", for: indexPath) as! OtherCell
        cell.usernameLabel.text = game.getLabelTextUsernameOpponent(username: self.player!.username)
        cell.avatarImageView.image = game.getImageAvatarOpponent(username: self.player!.username)
        cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.size.width/2
        cell.avatarImageView.clipsToBounds = true
        
        cell.set(game: game, username: self.player!.username)
        
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let discoverSelectionDictionary = ["other_menu_selection": indexPath.row]
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: "OtherMenuTable"),
            object: nil,
            userInfo: discoverSelectionDictionary)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let visibleRows = self.tableView.indexPathsForVisibleRows
        let lastRow = visibleRows?.last?.row
        if(lastRow == nil){
            return
        }
        let REQUEST_PAGE_SIZE: Int = 9
        
        let index = self.pageCount
        let size = REQUEST_PAGE_SIZE
        let indexFrom: Int =  index * size
        let indexTo: Int = indexFrom + REQUEST_PAGE_SIZE - 2
        
        if(lastRow! <= indexTo){
            return
        }
        if lastRow == indexTo {
            self.pageCount += 1
            self.fetchMenuTableList()
        }
    }
    
    func fetchMenuTableList() {
        
        let requestPayload = [
            "id": self.player!.id,
            "index": self.pageCount,
            "size": Const().PAGE_SIZE,
            "self": false
        ] as [String: Any]
        RequestActual().execute(requestPayload: requestPayload) { (result) in
            self.appendToLeaderboardTableList(additionalCellList: result)
        }
    }
    
    var other: Other?
    
    func appendToLeaderboardTableList(additionalCellList: [EntityGame]) {
        if(additionalCellList.count == 0){
            DispatchQueue.main.async {
                self.other!.header!.setIndicator(on: false, tableView: self)
                let alert = UIAlertController(title: "❎ No concluded games ❎", message: "\n\(self.player!.username) hasn't yet finished any games.", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                action.setValue(UIColor.lightGray, forKey: "titleTextColor")
                alert.addAction(action)
                self.other!.present(alert, animated: true)
            }
            return
        }
        for game in additionalCellList {
            if(!self.list.contains(game)){
                self.list.append(game)
            }
        }
        self.other!.header!.setIndicator(on: false, tableView: self)
    }
    
}
