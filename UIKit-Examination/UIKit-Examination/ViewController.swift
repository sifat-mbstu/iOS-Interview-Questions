//
//  ViewController.swift
//  UIKit-Examination
//
//  Created by Sifatul on 27/6/26.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func openFrameVsButtonPage(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "FrameVsBound",
                                      bundle: nil)
        let frameVsBoundPage = storyboard.instantiateViewController(withIdentifier: "FrameVsBound")
        frameVsBoundPage.modalPresentationStyle = .formSheet
        self.present(frameVsBoundPage, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

