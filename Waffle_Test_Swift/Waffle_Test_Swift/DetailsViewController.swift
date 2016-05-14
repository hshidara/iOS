//
//  DetailsView.swift
//  Waffle_Test_Swift
//
//  Created by Hidekazu Shidara on 5/11/16.
//  Copyright © 2016 Hidekazu Shidara. All rights reserved.
//

import Foundation
import UIKit

class DetailsViewController: UIViewController{
    
    var title_text                  = String()
    var publisher_text              = String()
    var url_text                    = String()
    var ingredients_text            = [String]()
    var photo                       = UIImageView()

    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var publisher_label: UILabel!
    @IBOutlet weak var url_label: UIButton!
    @IBOutlet weak var ingredients_label: UILabel!
    
    @IBAction func did_press_url(sender: UIButton) {
        if let _url = NSURL(string: url_text){
            UIApplication.sharedApplication().openURL(_url)
        }
    }

    override func viewDidLoad() {
        setLabels()
    }
    
    func setLabels(){
        setTitle()
        setPublisher()
        setURL()
        setPhoto()
        setIngredients()
    }
    
    
    func setTitle(){
        title_label.text               = title_text;
        title_label.backgroundColor    = UIColor.clearColor()
        title_label.font               = UIFont(name: "Futura-CondensedExtraBold", size: 18)
    }
    
    func setPublisher(){
        publisher_label.text                = "Brought to you by:\n" + publisher_text;
        publisher_label.backgroundColor     = UIColor.clearColor()
        publisher_label.font                = UIFont(name: "Futura-CondensedExtraBold", size: 15)

    }
    
    func setURL(){
        url_label.setTitle(url_text, forState: .Normal)
        url_label.tintColor                 = UIColor.redColor()
        url_label.titleLabel!.numberOfLines = 4;
        url_label.backgroundColor           = UIColor.clearColor()
    }
    
    func setPhoto(){
        photo.frame          = UIScreen.mainScreen().bounds
        photo.contentMode    = UIViewContentMode.ScaleAspectFill;
        photo.alpha          = 0.4;
        photo.tintColor      = UIColor.blackColor()
        
        self.view.addSubview(photo)
        self.view.sendSubviewToBack(photo)
    }
    
    func setIngredients(){
        ingredients_label.text     = "";
        for i in 0...ingredients_text.count-1 {
            ingredients_label.text = ingredients_label.text! + ingredients_text[i] + "\n"
        }

        ingredients_label.backgroundColor  = UIColor.clearColor()
        
        //  Some basic arithmetic is done to determine the size of the ingredient text. If there are a lot
        //  of ingredients, the size of the text will shrink, likewise, it will grow if there are fewer
        //  ingredients.
        //  FIXME: Can be done more dynamically and more smoothly.
        if(150/ingredients_text.count < 13){
            ingredients_label.font     =  UIFont(name: "Futura-Medium", size: CGFloat(150/ingredients_text.count))
        }
        else{
            ingredients_label.font     =  UIFont(name: "Futura-Medium", size: 13)
        }
    }
}