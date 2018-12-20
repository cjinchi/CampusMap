//
//  BottomSheetViewController.swift
//  CampusMap
//
//  Created by 陈金池 on 2018/12/20.
//  Copyright © 2018 Nemoworks. All rights reserved.
//

import UIKit

class BottomSheetViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        let ges = UIPanGestureRecognizer(target: self, action: #selector(BottomSheetViewController.pan(rec:)))
        view.addGestureRecognizer(ges)
    }
    
    init(_ cvc:CampusViewController) {
        self.cvc = cvc
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var cvc:CampusViewController? = nil
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    let reloadButton = UIButton()
    let exitButton = UIButton()
    let navText = UITextView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        blurView.frame = UIScreen.main.bounds
        
        reloadButton.setImage(UIImage(named: "reload"), for: .normal)
        reloadButton.frame = CGRect(x: 20, y: 30, width: 30 , height: 30)
//        reloadButton.addTarget(self, action: #selector(BottomSheetViewController.hide), for: .touchUpInside)
        

        exitButton.setImage(UIImage(named: "exit"), for: .normal)
        exitButton.frame = CGRect(x:20 ,y: 100, width: 30 , height: 30)
        exitButton.addTarget(self, action: #selector(BottomSheetViewController.exit), for: .touchUpInside)
        
        navText.isEditable = false
        navText.textColor = UIColor.black
        navText.text = ""
        navText.frame = CGRect(x: 80, y: 30, width: 230, height: 600)
        navText.backgroundColor = UIColor.clear
        navText.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        
        blurView.contentView.addSubview(reloadButton)
        blurView.contentView.addSubview(exitButton)
        blurView.contentView.addSubview(navText)
        self.view.insertSubview(blurView, at: 0)

    }
    
    @objc func exit(){
        self.view.isHidden = true
        cvc?.removeRoute()
    }
    
    @objc func reload(){
        exit()
        
        cvc?.reload()
    }
    
    func setNavText(text:String){
        navText.text = text
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3){
            let frame = self.view.frame
            let y = UIScreen.main.bounds.height - 200
            self.view.frame=CGRect(x: 0, y: y, width: frame.width, height: frame.height)
        }
        
        
    }
    
    @objc func pan(rec:UIPanGestureRecognizer){
        let trans = rec.translation(in: self.view)
        let y = self.view.frame.minY
        self.view.frame = CGRect(x: 0, y: y+trans.y, width: view.frame.width, height: view.frame.height)
        rec.setTranslation(CGPoint.zero, in: self.view)
    }

}
