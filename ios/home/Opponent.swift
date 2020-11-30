//
//  Opponent.swift
//  ios
//
//  Created by S. Matthew English on 11/23/20.
//  Copyright © 2020 bahlsenwitz. All rights reserved.
//

import UIKit

class Opponent: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return pickerSet.count }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {}
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { return pickerSet[row] }
    
    
    
    let pickerSet = ["feelin' lucky (random)", "config. 0", "config. 1", "config. 2", "traditional (chess)"]
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.light)
        label.text = pickerSet[row]
        
        return label
    }
    
    @IBOutlet weak var viewHolder00: UIView!
    @IBOutlet weak var imageAvatar00: UIImageView!
    @IBOutlet weak var labelUsername00: UILabel!
    @IBOutlet weak var viewHolder00width: NSLayoutConstraint!
    
    @IBOutlet weak var viewHolder01: UIView!
    @IBOutlet weak var imageAvatar01: UIImageView!
    @IBOutlet weak var labelUsername01: UILabel!
    @IBOutlet weak var viewHolder01width: NSLayoutConstraint!
    
    @IBOutlet weak var viewHolder02: UIView!
    @IBOutlet weak var imageAvatar02: UIImageView!
    @IBOutlet weak var labelUsername02: UILabel!
    @IBOutlet weak var viewHolder02width: NSLayoutConstraint!
    
    @IBOutlet weak var indicatorActivity: UIActivityIndicatorView!
    
    
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
        // Do what you want
        
        // create the alert
        //let alert = UIAlertController(title: "🤜 \(self.playerSelf!.username) vs. ${playerOther.username} 🤛", message: "Lauching this missile will destroy the entire universe. Is this what you intended to do?", preferredStyle: UIAlertController.Style.alert)
        
        //alert.addAction(UIAlertAction(title: "⚡ issue challenge ⚡", style: UIAlertAction.Style.default, handler: nil))
        //let option00 = UIAlertAction(title: "⚡ issue challenge ⚡", style: .default, handler: nil)
        //option00.setValue(UIColor.white, forKey: "titleTextColor")
        //alert.addAction(option00)
        
        //let option01 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        //option01.setValue(UIColor.lightGray, forKey: "titleTextColor")
        //alert.addAction(option01)
        
        // show the alert
        //self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        
        
        //        let vc = UIViewController()
        //        vc.preferredContentSize = CGSize(width: 250,height: 300)
        //        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 300))
        //        pickerView.delegate = self
        //        pickerView.dataSource = self
        //        vc.view.addSubview(pickerView)
        //        let editRadiusAlert = UIAlertController(title: "Choose distance", message: "", preferredStyle: UIAlertController.Style.alert)
        //        editRadiusAlert.setValue(vc, forKey: "contentViewController")
        //        editRadiusAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        //        editRadiusAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        //        self.window?.rootViewController?.present(editRadiusAlert, animated: true, completion: nil)
        
        
        //666
        
        
        
        
        let customView = Bundle.loadView(fromNib: "PickerConfig", withType: PickerConfig.self)
        customView.delegate = self
        customView.dataSource = self
        
        
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 300)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 300))
        pickerView.delegate = self
        pickerView.dataSource = self
        vc.view.addSubview(pickerView)
        let editRadiusAlert = UIAlertController(title: "Choose distance", message: "", preferredStyle: UIAlertController.Style.alert)
        editRadiusAlert.setValue(vc, forKey: "contentViewController")
        editRadiusAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        editRadiusAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        //self.present(editRadiusAlert, animated: true)
        
        self.window?.rootViewController?.present(editRadiusAlert, animated: true, completion: nil)
        
        
        
        
        
    }
    
    func doSomethingWithValue(value: Int) {
        //self.selection = value
    }
    
    
    var playerSelf: EntityPlayer?
    
    public func set(playerSelf: EntityPlayer) {
        
        self.playerSelf = playerSelf
        //showErrorMessage()
        
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        self.viewHolder00width.constant = screenWidth/3
        self.viewHolder01width.constant = screenWidth/3
        self.viewHolder02width.constant = screenWidth/3
        
        
        
        viewHolder00.isHidden = true
        viewHolder01.isHidden = true
        viewHolder02.isHidden = true
        
        indicatorActivity.isHidden = false
        indicatorActivity.startAnimating()
        
        
        
        let gesture00 = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        self.viewHolder00.isUserInteractionEnabled = true
        self.viewHolder00.addGestureRecognizer(gesture00)
        
        let gesture01 = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        self.viewHolder01.isUserInteractionEnabled = true
        self.viewHolder01.addGestureRecognizer(gesture01)
        
        let gesture02 = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        self.viewHolder02.isUserInteractionEnabled = true
        self.viewHolder02.addGestureRecognizer(gesture02)
        
        
        
        print("!!!!!!")
        self.execute(id: playerSelf.id) { (result) in
            
            DispatchQueue.main.async() {
                self.indicatorActivity.stopAnimating()
                self.indicatorActivity.isHidden = true
            }
            
            let opponent00: EntityPlayer = ParsePlayer().execute(json: result[0])
            DispatchQueue.main.async() {
                self.labelUsername00.text = opponent00.username
                self.imageAvatar00.image = opponent00.getImageAvatar()
                self.imageAvatar00.layer.cornerRadius = self.imageAvatar00.frame.size.width/2
                self.imageAvatar00.clipsToBounds = true
                self.viewHolder00.isHidden = false
                
                
            }
            
            let opponent01: EntityPlayer = ParsePlayer().execute(json: result[1])
            DispatchQueue.main.async() {
                self.labelUsername01.text = opponent01.username
                self.imageAvatar01.image = opponent01.getImageAvatar()
                self.imageAvatar01.layer.cornerRadius = self.imageAvatar01.frame.size.width/2
                self.imageAvatar01.clipsToBounds = true
                self.viewHolder01.isHidden = false
                
            }
            
            let opponent02: EntityPlayer = ParsePlayer().execute(json: result[2])
            DispatchQueue.main.async() {
                self.labelUsername02.text = opponent02.username
                self.imageAvatar02.image = opponent02.getImageAvatar()
                self.imageAvatar02.layer.cornerRadius = self.imageAvatar02.frame.size.width/2
                self.imageAvatar02.clipsToBounds = true
                self.viewHolder02.isHidden = false
                
            }
            
            
        }
        
        
    }
    
    func execute(id: String, completion: @escaping ([[String: Any]]) -> Void) {
        
        //val url = "${ServerAddress().IP}:8080/player/rivals/${this.playerSelf.id}"
        let url = URL(string: "http://\(ServerAddress().IP):8080/player/rivals/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil else {
                completion([["fail": "0"]])
                return
            }
            guard let data = data else {
                completion([["fail": "1"]])
                return
            }
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String: Any]] else {
                    completion([["fail": "2"]])
                    return
                }
                completion(json)
                
                
                
                
            } catch _ {
                completion([["fail": "3"]])
            }
        }).resume()
    }
    
    
}
