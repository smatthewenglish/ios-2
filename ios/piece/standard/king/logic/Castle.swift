//
//  Castle.swift
//  ios
//
//  Created by Matthew on 2/5/20.
//  Copyright © 2020 bahlsenwitz. All rights reserved.
//

import UIKit

class Castle {
    
    let white: Bool
    let transitioner: Transitioner?
    var tschess: Tschess?
    
    init(white: Bool, transitioner: Transitioner? = nil, tschess: Tschess? = nil){
        self.white = white
        self.transitioner = transitioner
        self.tschess = tschess
    }
    
    func opponentCoordinateList(kingCoordinate: [Int], state: [[Piece?]]) -> Array<[Int]> {
        var opponentCoordinateList = Array<[Int]>()
        //let tschessElementMatrix = gamestate.getTschessElementMatrix()
        let kingAffiliation = state[kingCoordinate[0]][kingCoordinate[1]]!.affiliation
        for i in (0 ..< 8) {
            for j in (0 ..< 8) {
                if(state[i][j] != nil){
                    if(state[i][j]!.affiliation != kingAffiliation) {
                        opponentCoordinateList.append([i,j])
                    }
                }
            }
        }
        //print("opponentCoordinateList: \(opponentCoordinateList)")
        return opponentCoordinateList
    }
    
    private func generateSearchSpace(proposed: [Int], affiliation: String) -> [[Int]]? {
        if(affiliation == "WHITE"){
            if(proposed == [7,6]){
                //print("kingSideWhite")
                return [[7,4], [7,5], [7,6]] //kingSideWhite
            }
            if(proposed == [7,2]){
                //print("queenSideWhite")
                return [[7,4], [7,3], [7,2]] //queenSideWhite
            }
        }
        if(affiliation == "BLACK"){
            if(proposed == [7,1]){
                //print("kingSideBlack")
                return [[7,3], [7,2], [7,1]] //kingSideBlack
            }
            if(proposed == [7,5]){
                //print("queenSideBlack")
                return [[7,3], [7,4], [7,5]] //queenSideBlack
            }
        }
        return nil
    }
    
    private func validateRookFirstTouch(proposed: [Int], state: [[Piece?]], affiliation: String) -> Bool {
        if(affiliation == "WHITE"){
            if(proposed == [7,6]){
                let candidateRook = state[7][7]
                if(candidateRook != nil){
                    if(!candidateRook!.name.contains("Rook")){
                        return false
                    } else {
                        return candidateRook!.firstTouch
                    }
                }
            }
            if(proposed == [7,2]){
                let candidateRook = state[7][0]
                if(candidateRook != nil){
                    if(!candidateRook!.name.contains("Rook")){
                        return false
                    } else {
                        return candidateRook!.firstTouch
                    }
                }
            }
        }
        if(affiliation == "BLACK"){
            if(proposed == [7,1]){
                let candidateRook = state[7][0]
                if(candidateRook != nil){
                    if(!candidateRook!.name.contains("Rook")){
                        return false
                    } else {
                        return candidateRook!.firstTouch
                    }
                }
            }
            if(proposed == [7,5]){
                let candidateRook = state[7][7]
                if(candidateRook != nil){
                    if(!candidateRook!.name.contains("Rook")){
                        return false
                    } else {
                        return candidateRook!.firstTouch
                    }
                }
            }
        }
        return false
    }
    
    private func validateKingFirstTouch(kingCoordinate: [Int], state: [[Piece?]]) -> Bool {
        let tschessElement = state[kingCoordinate[0]][kingCoordinate[1]]
        if(tschessElement != nil) {
            if(!state[kingCoordinate[0]][kingCoordinate[1]]!.name.contains("King")) {
                return false
            }
        }
        if(!tschessElement!.firstTouch){
            return false
        }
        return true
    }
    
    public func castle(kingCoordinate: [Int], proposed: [Int], state: [[Piece?]]) ->  Bool {
        if(kingCoordinate[0] != 7 || proposed[0] != 7){
            return false
        }
        
        let king = state[kingCoordinate[0]][kingCoordinate[1]]
        if(king == nil){
            return false
        }
        let affiliation = king!.affiliation
        let searchSpace = generateSearchSpace(proposed: proposed, affiliation: affiliation)
        
        if(!validateKingFirstTouch(kingCoordinate: kingCoordinate, state: state)){
            return false
        }
        if(!validateRookFirstTouch(proposed: proposed, state: state, affiliation: affiliation)){
            return false
        }
        let opponentCoordinateList = self.opponentCoordinateList(kingCoordinate: kingCoordinate, state: state)
        for opponentCoordinate in opponentCoordinateList {
            let opponent = state[opponentCoordinate[0]][opponentCoordinate[1]]!
            //print("opponent: \(opponent)")
            if(searchSpace != nil) {
                for space in searchSpace! {
                    if(opponent.validate(present: opponentCoordinate, proposed: space, state: state)) {
                        return false
                    }
                    if(space == kingCoordinate){
                        continue
                    }
                    let spaceOccupant = state[space[0]][space[1]]
                    if(spaceOccupant != nil){
                        if(spaceOccupant!.name != "PieceAnte"){
                            return false
                        }
                    }
                }
            }
        }
        return true
    }
    
    public func execute(coordinate: [Int], proposed: [Int], state0: [[Piece?]]) -> Bool {
        if(coordinate[0] != 7 || proposed[0] != 7){
            return false
        }
        
        var state1 = state0
        let tschessElement = state1[coordinate[0]][coordinate[1]]
        if(tschessElement == nil){
            return false
        }
        if(!tschessElement!.name.contains("King")) {
            return false
        }
        let tschessElementProposed = state1[proposed[0]][proposed[1]]
        if(tschessElementProposed == nil){
            return false
        }
        if(tschessElementProposed!.name != "PieceAnte") {
            return false
        }
        let affiliation = tschessElement!.affiliation
        if(affiliation == "WHITE"){
            if(proposed == [7,6]){
                
                let rook = state1[7][7]
                if(rook == nil){
                    return false
                }
                if(!rook!.name.contains("Rook")){
                    return false
                }
                
                let imageDefault = tschessElement!.getImageDefault()
                tschessElement!.setImageVisible(imageVisible: imageDefault)
                state1[7][6] = tschessElement
                state1[7][6]!.setFirstTouch(firstTouch: false)
                state1[coordinate[0]][coordinate[1]] = nil
                state1[7][5] = rook!
                state1[7][5]!.setFirstTouch(firstTouch: false)
                state1[7][7] = nil
                
                self.tschess!.matrix = self.transitioner!.deselectHighlight(state0: self.tschess!.matrix!)
                let stateUpdate = SerializerState(white: white).renderServer(state: state1)
                
                let hx: Int = white ? proposed[0] : 7 - proposed[0]
                let hy: Int = white ? proposed[1] : 7 - proposed[1]
                let h0: Int = white ? coordinate[0] : 7 - coordinate[0]
                let h1: Int = white ? coordinate[1] : 7 - coordinate[1]
                let highlight: String = "\(hx)\(hy)\(h0)\(h1)"
                
                let requestPayload: [String: Any] = ["id_game": self.tschess!.game!.id, "state": stateUpdate, "highlight": highlight, "condition": "TBD"]
                DispatchQueue.main.async() {
                    //self.tschess!.activityIndicator.isHidden = false
                    //self.tschess!.activityIndicator.startAnimating()
                }
                GameUpdate().success(requestPayload: requestPayload) { (success) in
                    if(!success){
                        //error
                    }
                    self.transitioner!.clearCoordinate()
                }

                return true
                
            }
            if(proposed == [7,2]){
                
                let rook = state1[7][0]
                if(rook == nil){
                    return false
                }
                if(!rook!.name.contains("Rook")){
                    return false
                }
                let imageDefault = tschessElement!.getImageDefault()
                tschessElement!.setImageVisible(imageVisible: imageDefault)
                state1[7][2] = tschessElement
                state1[7][2]!.setFirstTouch(firstTouch: false)
                state1[coordinate[0]][coordinate[1]] = nil
                state1[7][3] = rook!
                state1[7][3]!.setFirstTouch(firstTouch: false)
                state1[7][0] = nil
                
                
                
                self.tschess!.matrix = self.transitioner!.deselectHighlight(state0: self.tschess!.matrix!)
                let stateUpdate = SerializerState(white: white).renderServer(state: state1)
                
                let hx: Int = white ? proposed[0] : 7 - proposed[0]
                let hy: Int = white ? proposed[1] : 7 - proposed[1]
                let h0: Int = white ? coordinate[0] : 7 - coordinate[0]
                let h1: Int = white ? coordinate[1] : 7 - coordinate[1]
                let highlight: String = "\(hx)\(hy)\(h0)\(h1)"
                
                let requestPayload: [String: Any] = ["id_game": self.tschess!.game!.id, "state": stateUpdate, "highlight": highlight, "condition": "TBD"]
                DispatchQueue.main.async() {
                    //self.tschess!.activityIndicator.isHidden = false
                    //self.tschess!.activityIndicator.startAnimating()
                }
                GameUpdate().success(requestPayload: requestPayload) { (success) in
                    if(!success){
                        //error
                    }
                    self.transitioner!.clearCoordinate()
                }
                
                

                return true
            }
        }
        if(affiliation == "BLACK"){
            if(proposed == [7,1]){
                
                let rook = state1[7][0]
                if(rook == nil){
                    return false
                }
                if(!rook!.name.contains("Rook")){
                    return false
                }
                let imageDefault = tschessElement!.getImageDefault()
                tschessElement!.setImageVisible(imageVisible: imageDefault)
                state1[7][1] = tschessElement
                state1[7][1]!.setFirstTouch(firstTouch: false)
                state1[coordinate[0]][coordinate[1]] = nil
                state1[7][2] = rook!
                state1[7][2]!.setFirstTouch(firstTouch: false)
                state1[7][0] = nil
                
                
                
                self.tschess!.matrix = self.transitioner!.deselectHighlight(state0: self.tschess!.matrix!)
                let stateUpdate = SerializerState(white: white).renderServer(state: state1)
                
                let hx: Int = white ? proposed[0] : 7 - proposed[0]
                let hy: Int = white ? proposed[1] : 7 - proposed[1]
                let h0: Int = white ? coordinate[0] : 7 - coordinate[0]
                let h1: Int = white ? coordinate[1] : 7 - coordinate[1]
                let highlight: String = "\(hx)\(hy)\(h0)\(h1)"
                
                let requestPayload: [String: Any] = ["id_game": self.tschess!.game!.id, "state": stateUpdate, "highlight": highlight, "condition": "TBD"]
                DispatchQueue.main.async() {
                    //self.tschess!.activityIndicator.isHidden = false
                    //self.tschess!.activityIndicator.startAnimating()
                }
                GameUpdate().success(requestPayload: requestPayload) { (success) in
                    if(!success){
                        //error
                    }
                    self.transitioner!.clearCoordinate()
                }
                
                

                return true
                
            }
            if(proposed == [7,5]){
                
                let rook = state1[7][7]
                if(rook == nil){
                    return false
                }
                if(!rook!.name.contains("Rook")){
                   return false
                }
                
                let imageDefault = tschessElement!.getImageDefault()
                tschessElement!.setImageVisible(imageVisible: imageDefault)
                state1[7][5] = tschessElement
                state1[7][5]!.setFirstTouch(firstTouch: false)
                state1[coordinate[0]][coordinate[1]] = nil
                state1[7][4] = rook!
                state1[7][4]!.setFirstTouch(firstTouch: false)
                state1[7][7] = nil
                
                
                self.tschess!.matrix = self.transitioner!.deselectHighlight(state0: self.tschess!.matrix!)
                let stateUpdate = SerializerState(white: white).renderServer(state: state1)
                
                let hx: Int = white ? proposed[0] : 7 - proposed[0]
                let hy: Int = white ? proposed[1] : 7 - proposed[1]
                let h0: Int = white ? coordinate[0] : 7 - coordinate[0]
                let h1: Int = white ? coordinate[1] : 7 - coordinate[1]
                let highlight: String = "\(hx)\(hy)\(h0)\(h1)"
                
                let requestPayload: [String: Any] = ["id_game": self.tschess!.game!.id, "state": stateUpdate, "highlight": highlight, "condition": "TBD"]
                DispatchQueue.main.async() {
                    //self.tschess!.activityIndicator.isHidden = false
                    //self.tschess!.activityIndicator.startAnimating()
                }
                GameUpdate().success(requestPayload: requestPayload) { (success) in
                    if(!success){
                        //error
                    }
                    self.transitioner!.clearCoordinate()
                }
                
                

                return true
            }
        }
        return false
    }
    
}
