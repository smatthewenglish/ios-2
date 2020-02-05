//
//  DiscoverSetTask.swift
//  ios
//
//  Created by Matthew on 9/24/19.
//  Copyright © 2019 bahlsenwitz. All rights reserved.
//

import Foundation

class RequestHistoric {
    
    func execute(requestPayload: [String: Any], completion: @escaping (([EntityGame]?) -> Void)) {

        

        let url = URL(string: "http://\(ServerAddress().IP):8080/game/historic")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestPayload, options: .prettyPrinted)
        } catch _ {
            completion(nil)
        }

        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in

            guard error == nil else {
                
                completion(nil)
                return
            }
            guard let data = data else {
              
                completion(nil)
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
               
                completion(nil)
                return
            }
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] else {
                   
                    completion(nil)
                    return
                }

         

                let leaderboardPage: [EntityGame] = self.generateLeaderboardPage(page: requestPayload["index"] as! Int, size: requestPayload["size"] as! Int, serverRespose: json)
                completion(leaderboardPage)
               

            } catch let error {
              
            }
        }).resume()
    }
    
    private func generateLeaderboardPage(page: Int, size: Int, serverRespose: [[String: Any]]) -> [EntityGame] {
        var leaderboardPage = [EntityGame]()
        for index in stride(from: 0, to: serverRespose.count, by: 1) {
             let game: EntityGame = ParseGame().execute(json: serverRespose[index])
            leaderboardPage.append(game)
        }
        return leaderboardPage
    }
    
}
