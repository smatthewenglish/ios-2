//
//  Recover.swift
//  ios
//
//  Created by S. Matthew English on 8/28/20.
//  Copyright © 2020 bahlsenwitz. All rights reserved.
//

import UIKit

class PopRecover: UIViewController {
    
    @IBOutlet weak var buttonAccept: UIButton!
    
    private let transDelegate: TransDelegate = TransDelegate(width: 272, height: 158)
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
        transitioningDelegate = transDelegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func buttonClickAccept(_ sender: Any) {
        DispatchQueue.main.async {
            
            self.presentingViewController!.dismiss(animated: false, completion: nil)
        }
    }
    
}
