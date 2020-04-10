//
//  ViewController.swift
//  CAViewDebugger
//
//  Created by LuoHuanyu on 2020/3/26.
//  Copyright © 2020 LuoHuanyu. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    override func loadView() {
        let view = UIView()
        view.backgroundColor = UIColor.cyan
        view.frame = UIScreen.main.bounds
        
        let frames = view.bounds.divided(atDistance: view.bounds.width / 3, from: .minXEdge)
        let view1 = UIView()
        view1.backgroundColor = UIColor.magenta.withAlphaComponent(0.5)
        view1.frame = frames.slice
        
        let view2 = MKMapView()
        view2.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
        view2.frame = frames.remainder
        
        view.addSubview(view1)
        view.addSubview(view2)
        
        let frames1 = view1.bounds.divided(atDistance: view1.bounds.height / 3, from: .minYEdge)
        let view3 = UIView()
        view3.backgroundColor = .purple
        view3.frame = frames1.slice
        
        let overlay = UIView()
        overlay.backgroundColor = .cyan
        overlay.frame = view3.bounds.insetBy(dx: -20, dy: -20)
        view3.addSubview(overlay)
        
        let view4 = UIView()
        view4.backgroundColor = .yellow
        view4.frame = frames1.remainder
        
        view1.addSubview(view3)
        view1.addSubview(view4)
        
        let frames2 = view2.bounds.divided(atDistance: view2.bounds.height / 2, from: .minYEdge)
        let view5 = UIView()
        view5.backgroundColor = UIColor.systemRed.withAlphaComponent(0.5)
        view5.frame = frames2.slice
        
        let view6 = UIImageView(image: UIImage(named: "UIImageView"))
        view6.contentMode = .scaleAspectFit
        view6.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view6.frame = frames2.remainder
        view6.accessibilityIdentifier = "Test"
        
        view2.addSubview(view5)
        view2.addSubview(view6)
        
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
    }
    
    @objc func tap(_ gesture: UITapGestureRecognizer)  {
        if gesture.state == .ended {
            ViewDebuggerViewController.present(in: self.view.window!)
        }
    }

}




