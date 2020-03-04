//
//  ActualTable.swift
//  ios
//
//  Created by Matthew on 2/5/20.
//  Copyright © 2020 bahlsenwitz. All rights reserved.
//

import UIKit
import SwipeCellKit

class MenuTable: UITableViewController, SwipeTableViewCellDelegate {
    
    var pageCount: Int
    
    // MARK: ~
    var menu: Menu?
    func setSelf(menu: Menu) {
        self.menu = menu
    }
    
    func fetchMenuTableList() {
        print("0 - self.pageCount: \(self.pageCount)")
        
        self.menu!.setIndicator(on: true)
        let request: [String: Any] = ["id": self.menu!.playerSelf!.id, "index": self.pageCount, "size": Const().PAGE_SIZE, "self": true]
        RequestActual().execute(requestPayload: request) { (result) in
            self.menu!.setIndicator(on: false)
            if(result == nil){
                return
            }
            self.menuTableListAppend(list: result!)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.pageCount = 0
        super.init(coder: aDecoder)
    }
    
    // MARK: LIFECYCLE
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.tableFooterView = UIView()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
    }
    
    @objc func refresh(refreshControl: UIRefreshControl) {
        self.pageCount = 0
        let request: [String: Any] = ["id": self.menu!.playerSelf!.id, "index": self.pageCount, "size": Const().PAGE_SIZE, "self": true]
        RequestActual().execute(requestPayload: request) { (result) in
            self.menu!.setIndicator(on: false)
            if(result == nil){
                //error...
            }
            DispatchQueue.main.async {
                self.menu!.menuTableList = result!
                self.tableView.reloadData()
                refreshControl.endRefreshing()
            }
        }
    }
    
    func getPageListNext() {
        print("1 - self.pageCount: \(self.pageCount)")
        
        self.menu!.setIndicator(on: true)
        let request: [String: Any] = ["id": self.menu!.playerSelf!.id, "index": self.pageCount, "size": Const().PAGE_SIZE, "self": true]
        RequestActual().execute(requestPayload: request) { (result) in
            self.menu!.setIndicator(on: false)
            if(result == nil){
                return
            }
            self.menuTableListAppend(list: result!)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let visibleRows = self.tableView.indexPathsForVisibleRows
        let lastRow = visibleRows?.last?.row
        if(lastRow == nil){
            print(" L ")
            return
        }
        let index = self.pageCount
        //print(" index \(index) ")
        let indexFrom: Int =  index * Const().PAGE_SIZE
        //print(" indexFrom \(indexFrom) ")
        let indexTo: Int = indexFrom + Const().PAGE_SIZE - 2
        //print(" indexTo \(indexTo) ")
        //print(" lastRow! \(lastRow!) ")
        //if(lastRow! <= indexTo){
            //print(" -M- ")
            //return
        //}
        if lastRow == indexTo {
            
            print(" -N- ")
            
            self.pageCount += 1
            self.getPageListNext()
        }
        //print(" 0 ")
    }
    
    // MARK: TABLE
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menu!.menuTableList!.count
    }
    
    private func swipeResolved(orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if(orientation == .right) {
            let rematch = SwipeAction(style: .default, title: nil) { action, indexPath in
                let game: EntityGame = self.menu!.menuTableList![indexPath.row]
                let username: String = self.menu!.playerSelf!.username
                let playerOther: EntityPlayer = game.getPlayerOther(username: username)
                DispatchQueue.main.async {
                    let screenSize: CGRect = UIScreen.main.bounds
                    let height = screenSize.height
                    SelectChallenge().execute(selection: Int.random(in: 0...3), playerSelf: self.menu!.playerSelf!, playerOther: playerOther, BACK: "MENU", height: height)
                }
            }
            rematch.backgroundColor = .purple
            rematch.image = UIImage(named: "challenge")!
            return [rematch]
        }
        return nil
    }
    
    private func swipProposedInbound(orientation: SwipeActionsOrientation, game: EntityGame) -> [SwipeAction]? {
        if(orientation == .left) {
            let nAction = SwipeAction(style: .default, title: nil) { action, indexPath in
                self.menu!.setIndicator(on: true)
                let requestPayload: [String: Any] = ["id_game": game.id, "id_player": self.menu!.playerSelf!.id]
                UpdateNack().execute(requestPayload: requestPayload) { (player) in
                    self.menu!.setSelf(player: player!)
                    self.menu!.menuTableList!.remove(at: indexPath.row)
                    self.menu!.setIndicator(on: false)
                }
            }
            nAction.backgroundColor = .red
            nAction.image = UIImage(named: "td_w")!
            return [nAction]
        }
        let ackAction = SwipeAction(style: .default, title: nil) { action, indexPath in
            let game: EntityGame = self.menu!.menuTableList![indexPath.row]
            let username: String = self.menu!.playerSelf!.username
            let playerOther: EntityPlayer = game.getPlayerOther(username: username)
            DispatchQueue.main.async {
                let screenSize: CGRect = UIScreen.main.bounds
                let height = screenSize.height
                SelectAck().execute(selection: Int.random(in: 0...3), playerSelf: self.menu!.playerSelf!, playerOther: playerOther, game: game, height: height)
            }
        }
        ackAction.backgroundColor = .green
        ackAction.image = UIImage(named: "tu_w")!
        return [ackAction]
    }
    
    private func swipProposedOutbound(orientation: SwipeActionsOrientation, game: EntityGame) -> [SwipeAction]? {
        if(orientation == .left) {
            let rescind = SwipeAction(style: .default, title: nil) { action, indexPath in
                self.menu!.setIndicator(on: true)
                let game = self.menu!.menuTableList![indexPath.row]
                let requestPayload: [String: Any] = ["id_game": game.id, "id_player": self.menu!.playerSelf!.id]
                UpdateRescind().execute(requestPayload: requestPayload) { (result) in
                    self.menu!.menuTableList!.remove(at: indexPath.row)
                    self.menu!.setIndicator(on: false)
                }
            }
            rescind.backgroundColor = .red
            rescind.image = UIImage(named: "close_w")!
            return [rescind]
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let username: String = self.menu!.playerSelf!.username
        let game = self.menu!.menuTableList![indexPath.row]
        let inbound: Bool = game.getInboundInvitation(username: username)
        
        if(game.status == "ONGOING"){
            return nil
        }
        if(game.status == "RESOLVED"){
            return self.swipeResolved(orientation: orientation)
        }
        if(inbound){
            return self.swipProposedInbound(orientation: orientation, game: game)
        }
        return self.swipProposedOutbound(orientation: orientation, game: game)
    }
    
    private func getCellActive(cell: MenuCell) -> MenuCell {
        cell.soLaLa.backgroundColor = UIColor.white
        cell.usernameLabel.textColor = UIColor.black
        cell.timeIndicatorLabel.textColor = UIColor.black
        cell.actionImageView.isHidden = false
        cell.dispImageView.isHidden = true
        cell.dispAdjacentLabel.isHidden = true
        cell.oddsIndicatorLabel.isHidden = true
        cell.oddsValueLabel.isHidden = true
        cell.dispImageView.isHidden = true
        cell.dispValueLabel.isHidden = true
        return cell
    }
    
    private func getCellHisto(cell: MenuCell) -> MenuCell {
        cell.soLaLa.backgroundColor = UIColor.black
        cell.usernameLabel.textColor = UIColor.lightGray
        cell.timeIndicatorLabel.textColor = UIColor.darkGray
        cell.actionImageView.isHidden = true
        cell.dispImageView.isHidden = false
        cell.dispAdjacentLabel.isHidden = false
        cell.dispAdjacentLabel.textColor = UIColor.darkGray
        cell.oddsIndicatorLabel.isHidden = false
        cell.oddsIndicatorLabel.textColor = UIColor.darkGray
        cell.oddsValueLabel.isHidden = false
        cell.oddsValueLabel.textColor = UIColor.lightGray
        cell.dispValueLabel.isHidden = false
        cell.dispValueLabel.textColor = UIColor.lightGray
        return cell
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index: Int = indexPath.row
        let game: EntityGame = self.menu!.menuTableList![index]
        let username: String = self.menu!.playerSelf!.username
        let usernameOther: String = game.getLabelTextUsernameOpponent(username: username)
        let avatarImageOther: UIImage = game.getImageAvatarOpponent(username: username)
        let date: String = game.getLabelTextDate()
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
        cell.delegate = self
        cell.timeIndicatorLabel.text = date
        cell.usernameLabel.text = usernameOther
        cell.avatarImageView.image = avatarImageOther
        if(game.status == "RESOLVED"){
            cell = self.getCellHisto(cell: cell)
            cell.dispImageView.image = game.getImageDisp(username: username)
            cell.oddsValueLabel.text = game.getOdds(username: username)
            cell.dispValueLabel.text = game.getLabelTextDisp(username: username)
            return cell
        }
        cell = self.getCellActive(cell: cell)
        let inbound: Bool = game.getInboundGame(username: username)
        if(game.status == "ONGOING"){
            if(inbound){
                let image: UIImage = UIImage(named: "turn.on")!
                cell.actionImageView.image = image
                return cell
            }
            let image: UIImage = UIImage(named: "turn.on")!
            cell.actionImageView.image = image
            return cell
        }
        if(game.status == "PROPOSED"){
            if(inbound){
                let image: UIImage = UIImage(named: "inbound")!
                cell.actionImageView.image = image
                return cell
            }
        }
        let image: UIImage = UIImage(named: "outbound")!
        cell.actionImageView.image = image
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! MenuCell
        let game = self.menu!.menuTableList![indexPath.row]
        if(game.status == "RESOLVED"){
            DispatchQueue.main.async {
                let skin: String = SelectSnapshot().getSkinGame(username: self.menu!.playerSelf!.username, game: game)
                SelectSnapshot().snapshot(skin: skin, playerSelf: self.menu!.playerSelf!, game: game, presentor: self)
            }
            return
        }
        if(game.status == "ONGOING"){
            DispatchQueue.main.async {
                let height: CGFloat = UIScreen.main.bounds.height
                let playerOther: EntityPlayer = game.getPlayerOther(username: self.menu!.playerSelf!.username)
                SelectTschess().tschess(playerSelf: self.menu!.playerSelf!, playerOther: playerOther, game: game, height: height)
            }
            return
        }
        if(game.getInboundInvitation(username: self.menu!.playerSelf!.username)){
            cell.showSwipe(orientation: .right, animated: true)
            return
        }
        return cell.showSwipe(orientation: .left, animated: true)
    }
    
    func menuTableListAppend(list: [EntityGame]) {
        let count0 = self.menu!.menuTableList!.count
        for game: EntityGame in list {
            if(self.menu!.menuTableList!.contains(game)){
                continue
            }
            self.menu!.menuTableList!.append(game)
        }
        let count1 = self.menu!.menuTableList!.count
        if(count0 != count1){
            self.menu!.setIndicator(on: false)
        }
        if(count1 > 0){
            DispatchQueue.main.async {
                let tutorial: Bool = self.menu!.containerView!.subviews.contains(self.menu!.enter)
                if(!tutorial){
                    return
                }
                self.menu!.enter.removeFromSuperview()
            }
        }
    }
}
