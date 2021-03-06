//
//  HomeMenuTable.swift
//  ios
//
//  Created by Matthew on 1/19/20.
//  Copyright © 2020 bahlsenwitz. All rights reserved.
//

import UIKit
import SwipeCellKit


class HomeTable: UITableViewController, SwipeTableViewCellDelegate {
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let listRowVisible: [IndexPath]? = self.tableView.indexPathsForVisibleRows
        let rowLast = listRowVisible?.last?.row
        if(rowLast == nil){
            return
        }
        let index = self.index
        let size = Const().PAGE_SIZE
        let indexFrom: Int =  index * size
        let indexTo: Int = indexFrom + Const().PAGE_SIZE - 2
        if rowLast == indexTo {
            self.index += 1
            self.fetch()
        }
    }
    
    @objc func refresh(refreshControl: UIRefreshControl?) {
        self.index = 0
        self.fetch(refreshControl: refreshControl, refresh: true)
    }
    
    func fetch(refreshControl: UIRefreshControl? = nil, refresh: Bool = false) {
        if(!refresh){
            self.activity!.header!.setIndicator(on: true)
        }
        let payload = ["id": self.activity!.player!.id,
                       "index": self.index,
                       "size": Const().PAGE_SIZE,
                       "self": true
        ] as [String: Any]
        RequestActual().execute(requestPayload: payload) { (result) in
            if(refreshControl != nil){
                self.list = [EntityGame]()
                DispatchQueue.main.async {
                    refreshControl!.endRefreshing()
                }
            }
            for game in result {
                //if(self.list.contains(game)){
                   //continue
                //}
                self.list.append(game)
            }
            self.activity!.header!.setIndicator(on: false, tableView: self)
        }
    }
    
    /**
     * ~~~
     */
    
    var index: Int
    var swiped: Bool
    var list: [EntityGame]
    var backgroundColor: UIColor
    var activity: Home?
    
    required init?(coder aDecoder: NSCoder) {
        self.index = 0
        self.swiped = false
        self.list = [EntityGame]()
        self.backgroundColor = UIColor(red: 31.0/255, green: 31.0/255, blue: 31.0/255, alpha: 1.0)
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.tableFooterView = UIView()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func viewDidLoad() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.backgroundColor = UIColor.clear
        refreshControl.tintColor = UIColor.white
        self.tableView.refreshControl = refreshControl
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let username: String = self.activity!.player!.username
        let game = self.list[indexPath.row]
        if(game.status == "ONGOING"){
            return nil
        }
        if(game.isResolved()){
            return self.swipeResolved(orientation: orientation, game: game)
        }
        let inbound: Bool = game.getInboundInvitation(username: username)
        if(inbound){
            return self.swipProposedInbound(orientation: orientation, game: game)
        }
        return self.swipProposedOutbound(orientation: orientation, game: game)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectSelectedRow(animated: true)
        let game = self.list[indexPath.row]
        if(game.isResolved()){
            let game: EntityGame = self.list[indexPath.row]
            let username: String = self.activity!.player!.username
            let opponent: EntityPlayer = game.getPlayerOther(username: username)
            self.invite(opponent: opponent, game: game, REMATCH: true)
            return
        }
        if(game.status == "ONGOING"){
            let opponent: EntityPlayer = game.getPlayerOther(username: self.activity!.player!.username)
            DispatchQueue.main.async {
                let storyboard: UIStoryboard = UIStoryboard(name: "Tschess", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "Tschess") as! Tschess
                viewController.playerOther = opponent
                viewController.player = self.activity!.player!
                viewController.game = game
                self.navigationController?.pushViewController(viewController, animated: false)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index: Int = indexPath.row
        let game: EntityGame = self.list[index]
        let username: String = self.activity!.player!.username
        let opponentUsername: String = game.getLabelTextUsernameOpponent(username: username)
        let opponentAvatar: UIImage = game.getImageAvatarOpponent(username: username)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as! HomeCell
        cell.delegate = self
        cell.setContent(usernameSelf: username, usernameOther: opponentUsername, game: game, avatarImageOther: opponentAvatar)
        return cell
    }
    
    func invite(opponent: EntityPlayer, game: EntityGame, ACCEPT: Bool = false, REMATCH: Bool = false) {
        
        var storyboard: UIStoryboard
        //var viewController: UIViewController
        let purchased: Bool = activity!.player!.subscription
        if (purchased){
            storyboard = UIStoryboard(name: "PopInvite", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "PopInvite") as! PopInvite
            viewController.game = game
            viewController.opponent = opponent
            viewController.player = self.activity!.player
            viewController.navigator = self.activity!.navigationController
            viewController.REMATCH = REMATCH
            viewController.ACCEPT = ACCEPT
            self.activity!.present(viewController, animated: true, completion: nil)
        } else {
            storyboard = UIStoryboard(name: "PopPurchase", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "PopPurchase") as! PopPurchase
            viewController.game = game
            viewController.opponent = opponent
            viewController.player = self.activity!.player
            viewController.navigator = self.activity!.navigationController
            viewController.REMATCH = REMATCH
            viewController.ACCEPT = ACCEPT
            self.activity!.present(viewController, animated: true, completion: nil)
        }
    }
    
    /**
     * Inbound, Outbound, & Resolved
     */
    
    private func swipProposedInbound(orientation: SwipeActionsOrientation, game: EntityGame) -> [SwipeAction]? {
        if(orientation == .left) {
            return nil
        }
        let nAction = SwipeAction(style: .default, title: nil) { action, indexPath in
            let cell = self.tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
            cell.hideSwipe(animated: false, completion: nil)
            self.activity!.header!.setIndicator(on: true)
            let requestPayload: [String: Any] = ["id_game": game.id, "id_self": self.activity!.player!.id]
            UpdateNack().execute(requestPayload: requestPayload) { (result) in
                self.list.remove(at: indexPath.row)
                self.activity!.header!.setIndicator(on: false, tableView: self.activity!.table!)
            }
        }
        nAction.backgroundColor = backgroundColor
        nAction.image = UIImage(named: "td_w")!
        nAction.title = "Reject"
        
        let ackAction = SwipeAction(style: .default, title: nil) { action, indexPath in
            let cell = self.tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
            cell.hideSwipe(animated: false, completion: nil)
            let game: EntityGame = self.list[indexPath.row]
            let username: String = self.activity!.player!.username
            let opponent: EntityPlayer = game.getPlayerOther(username: username)
            self.invite(opponent: opponent, game: game, ACCEPT: true)
        }
        ackAction.backgroundColor = backgroundColor
        ackAction.title = "Accept"
        ackAction.image = UIImage(named: "tu_w")!
        return [ackAction, nAction]
    }
    
    private func swipProposedOutbound(orientation: SwipeActionsOrientation, game: EntityGame) -> [SwipeAction]? {
        if(orientation == .right) {
            let rescind = SwipeAction(style: .default, title: nil) { action, indexPath in
                let cell = self.tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
                cell.hideSwipe(animated: false, completion: nil)
                self.activity!.header!.setIndicator(on: true)
                let game = self.list[indexPath.row]
                let requestPayload: [String: Any] = ["id_game": game.id, "id_self": self.activity!.player!.id]
                UpdateRescind().execute(requestPayload: requestPayload) { (result) in
                    self.list.remove(at: indexPath.row)
                    self.activity!.header!.setIndicator(on: false, tableView: self.activity!.table!)
                }
            }
            rescind.backgroundColor = backgroundColor
            rescind.image = UIImage(named: "close_w")!
            rescind.title = "Rescind"
            return [rescind]
        }
        return nil
    }
    
    private func swipeResolved(orientation: SwipeActionsOrientation, game: EntityGame) -> [SwipeAction]? {
        let username: String = self.activity!.player!.username
        if(orientation == .right) {
            let rematch = SwipeAction(style: .default, title: nil) { action, indexPath in
                let cell = self.tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
                cell.hideSwipe(animated: false, completion: nil)
                let game: EntityGame = self.list[indexPath.row]
                DispatchQueue.main.async {
                    let storyboard: UIStoryboard = UIStoryboard(name: "Snapshot", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "Snapshot") as! Snapshot
                    viewController.game = game
                    viewController.player = self.activity!.player!
                    self.activity!.present(viewController, animated: false, completion: nil)
                }
            }
            rematch.backgroundColor = backgroundColor
            rematch.title = "Snapshot"
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
    
}

extension UITableView {
    func deselectSelectedRow(animated: Bool) {
        if let indexPathForSelectedRow = self.indexPathForSelectedRow {
            self.deselectRow(at: indexPathForSelectedRow, animated: animated)
        }
    }
}
