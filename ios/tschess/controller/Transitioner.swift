//
//  Transitioner.swift
//  ios
//
//  Created by Matthew on 2/5/20.
//  Copyright © 2020 bahlsenwitz. All rights reserved.
//

import UIKit

class Transitioner {
    
    var coordinate: [Int]?
    
    public func getCoordinate() -> [Int]? {
        return coordinate
    }
    
    public func clearCoordinate() {
        self.coordinate = nil
    }
    
    public func movable(square: Piece?) -> Bool {
        if(square == nil){
            return false
        }
        if(square!.isTarget){
            return true
        }
        if(square!.name == "PieceAnte"){
            return true
        }
        return false
    }
    
    public func validMove(propose: [Int], state0: [[Piece?]]) -> Bool {
        if(self.coordinate! == propose){
            return false
        }
        let squarePropose = state0[propose[0]][propose[1]]
        if(self.movable(square: squarePropose)){
            return true
        }
        return false
    }
    
    public func executeMove(propose: [Int], state0: [[Piece?]]) -> [[Piece?]] {
        var state1 = state0
        let squarePresent = state1[self.coordinate![0]][self.coordinate![1]]
        state1[propose[0]][propose[1]] = squarePresent
        /* - * - */
        state1[propose[0]][propose[1]]!.firstTouch = false
        /* - * - */
        state1[self.coordinate![0]][self.coordinate![1]] = nil
        return state1
    }
    
    public func deselectHighlight(state0: [[Piece?]]) -> [[Piece?]] {
        var state1 = state0
        for i in (0 ..< 8) {
            for j in (0 ..< 8) {
                let square = state1[i][j]
                if(square != nil){
                    if(square!.name == "PieceAnte"){
                        state1[i][j] = nil
                    }
                    if(square!.isTarget == true) { //targets...
                        let imageDefault = square!.getImageDefault()
                        state1[i][j]!.setImageVisible(imageVisible: imageDefault)
                        state1[i][j]!.isTarget = false
                    }
                }
            }
        }
        let imageDefault = state1[self.coordinate![0]][self.coordinate![1]]!.getImageDefault()
        state1[self.coordinate![0]][self.coordinate![1]]!.setImageVisible(imageVisible: imageDefault)
        return state1
    }
    
    public func evaluateHighlightSelection(coordinate: [Int], state0: [[Piece?]]) -> [[Piece?]] {
        if(self.invalid(coordinate: coordinate, state: state0)){
            return state0
        }
        var state1 = state0
        self.coordinate = coordinate
        let imageSelection = state1[self.coordinate![0]][self.coordinate![1]]!.getImageSelection()
        state1[self.coordinate![0]][self.coordinate![1]]!.setImageVisible(imageVisible: imageSelection)
        loop0: for i in (0 ..< 8) {
            loop1: for j in (0 ..< 8) {
                let piece = state1[self.coordinate![0]][self.coordinate![1]]!
                if(piece.validate(present: coordinate, proposed: [i,j], state: state1)){
                    
                    /**
                     * - - - - - - - - - - - - - - - -
                     * - why does that make it work? -
                     * - renderServer() with false   -
                     * - renderClient() with true    -
                     * - - - - - - - - - - - - - - - -
                     */
                    
                    /*-*-*/
                    var stateH: [[Piece?]] = state1
                    let pieceH = stateH[self.coordinate![0]][self.coordinate![1]]
                    stateH[i][j] = pieceH
                    stateH[self.coordinate![0]][self.coordinate![1]] = nil
                    let kingH: [Int] = Checker().kingCoordinate(affiliation: piece.affiliation, state: stateH)
                    // the king moved (avoiid nil)
                    // if they match in the operational world...
                    if(coordinate == kingH){
                        let stateK0 = SerializerState(white: false).renderServer(state: stateH)
                        let stateK1 = SerializerState(white: true).renderClient(state: stateK0)
                        let hi: Int = white ? i : 7 - i
                        let hj: Int = white ? j : 7 - j
                        if(Checker().check(coordinate: [hi,hj], state: stateK1)){
                            continue loop1
                        }
                    }
                    else {
                        let stateK0 = SerializerState(white: false).renderServer(state: stateH)
                        let stateK1 = SerializerState(white: true).renderClient(state: stateK0)
                        let kingK: [Int] = Checker().kingCoordinate(affiliation: piece.affiliation, state: stateK1)
                        if(Checker().check(coordinate: kingK, state: stateK1)){
                            continue loop1
                        }
                    }
                    /*-*-*/
                    
                    let square = state1[i][j]
                    if(square == nil){
                        state1[i][j] = PieceAnte()
                        continue loop1
                    }
                    if(square!.affiliation == piece.affiliation){
                        continue loop1
                    }
                    let imageTarget = square!.getImageTarget()
                    square!.setImageVisible(imageVisible: imageTarget)
                    square!.isTarget = true
                }
            }
        }
        return state1
    }
    
    private func invalid(coordinate: [Int], state: [[Piece?]]) -> Bool {
        if(self.coordinate == nil){
            let tschessElement = state[coordinate[0]][coordinate[1]]
            if(tschessElement == nil){
                self.flash()
                return true
            }
            if(self.white){
                if(tschessElement!.affiliation != "WHITE"){
                    //print("A")
                    self.flash()
                    return true
                }
            }
            else if(tschessElement!.affiliation != "BLACK"){
                //print("B")
                self.flash()
                return true
            }
        }
        return false
    }
    
    var white: Bool
    var collectionView: BoardView
    
    init(white: Bool, collectionView: BoardView){
        self.white = white
        self.collectionView = collectionView
    }
    
    func flash() {
        let flashFrame = UIView(frame: collectionView.bounds)
        flashFrame.backgroundColor = UIColor.white
        flashFrame.alpha = 0.7
        self.collectionView.addSubview(flashFrame)
        UIView.animate(withDuration: 0.1, animations: {
            flashFrame.alpha = 0.0
        }, completion: {(finished:Bool) in
            flashFrame.removeFromSuperview()
        })
    }
    
}
