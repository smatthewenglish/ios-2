//
//  Highlighter.swift
//  ios
//
//  Created by S. Matthew English on 8/21/20.
//  Copyright © 2020 bahlsenwitz. All rights reserved.
//

import UIKit

class Highlighter {
    
    func getHighlight(highlight: String) -> [[Int]] {
        let coords = Array(highlight)
        let h0a: Int = Int(String(coords[0]))!
        let h0b: Int = Int(String(coords[1]))!
        let h0: [Int] = [h0a,h0b]
        let h1a: Int = Int(String(coords[2]))!
        let h1b: Int = Int(String(coords[3]))!
        let h1: [Int] = [h1a,h1b]
        return [h0, h1]
    }
    
    func highlightCoord(coordNormal: [Int], coordHighlight: [[Int]], cell: SquareCell) -> SquareCell {
        for (_, coord) in coordHighlight.enumerated() {
            if(coord == coordNormal){
                return self.getOrnamentCell(highlight: true, cell: cell)
            }
        }
        return self.getOrnamentCell(highlight: false, cell: cell)
    }
    
    func getOrnamentCell(highlight: Bool, cell: SquareCell) -> SquareCell{
        var presnt: Bool = false
        if(highlight){
            cell.subviews.forEach({
                if($0.tag == 666){
                    presnt = true
                }
            })
            if(presnt){
                return cell
            }
            let ornament = UIImageView(image: UIImage(named: "pinkmamba_w")!)
            ornament.bounds = CGRect(origin: cell.bounds.origin, size: cell.bounds.size)
            ornament.center = CGPoint(x: cell.bounds.size.width/2, y: cell.bounds.size.height/2)
            ornament.tag = 666
            cell.insertSubview(ornament, at: 0)
            return cell
        }
        cell.subviews.forEach({
            if($0.tag == 666){
                $0.removeFromSuperview()
            }
        })
        return cell
    }
    
}
