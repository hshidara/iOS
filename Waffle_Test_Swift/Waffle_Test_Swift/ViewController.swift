//
//  ViewController.swift
//  Waffle_Test_Swift
//
//  Created by Hidekazu Shidara on 5/9/16.
//  Copyright © 2016 Hidekazu Shidara. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    //  MARK: Instance Variables
    let tableView = UITableView(frame: UIScreen.mainScreen().bounds, style: .Grouped)
    var recipes = [Recipe]()
    var index : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.topItem!.title = "2016 Best Recipes"
        
        fetch_recipes()
        set_tableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //  MARK: Setup Methods
    
    func set_tableView(){
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate      = self
        tableView.dataSource    = self
        view.addSubview(tableView)
    }
    
    //  MARK: TableView Data Source Methods

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.selected = false
        index = indexPath.row
        performSegueWithIdentifier("segue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "segue") {
            // pass data to next view
            let vc = segue.destinationViewController as! DetailsViewController
            vc.title_text           = recipes[index].get_title()
            vc.publisher_text       = recipes[index].get_publisher()
            vc.url_text             = recipes[index].get_link()
            vc.photo.image          = recipes[index].get_photo()
            vc.ingredients_text     = recipes[index].get_ingredients()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "cell")
        cell.accessoryType              = .DisclosureIndicator
        cell.textLabel?.text            = recipes[indexPath.row].get_title()
        cell.detailTextLabel?.text      = recipes[indexPath.row].get_publisher()
        
        //  Format the pictures
        cell.imageView?.image           = recipes[indexPath.row].get_photo()
        return cell
    }
    
    //  MARK: Fetching Methods
    func fetch_recipes(){
        let url = NSURL(string: "http://food2fork.com/api/search?key={API_KEY}&sort=t")
        if let _url = url {
            let session = NSURLSession.sharedSession().dataTaskWithURL(_url) { (data, response, error) in
                if (error == nil) {
                    do{
                        let list = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                        let count = list["count"] as! Int
                        let ar = list["recipes"] as! [NSDictionary]
                        //  Time to fill up the recipe list
                        for index in 0...count-1 {
                            self.recipes.append(Recipe(dictionary: ar[index]))
                        }
                        dispatch_async(dispatch_get_main_queue()) {
                            self.tableView.reloadData()
                        }
                    }
                    catch{
                        print(error)
                    }
                }
            }
            session.resume()
        }

    }
}

class Recipe {
    
    //  MARK: Instance Variables
    var publisher,title,photo_url,link,recipeID     : String
    var photo                                       = UIImage()
    var ingredients                                 = [String]()
    
    init(dictionary: NSDictionary){
        publisher                   = dictionary["publisher"] as! String
        title                       = dictionary["title"] as! String
        photo_url                   = dictionary["image_url"] as! String
        link                        = dictionary["source_url"] as! String
        recipeID                    = dictionary["recipe_id"] as! String
        photo                       = set_photo(photo_url)
        
        fetch_ingredients(recipeID)
    }
    
    func fetch_ingredients(id: String){
        let str = "http://food2fork.com/api/get?key={API_KEY}&rId=" + id
        let url = NSURL(string: str)
        let session = NSURLSession.sharedSession().dataTaskWithURL(url!){(data,response,error) in
            if(error == nil){
                do{
                    let list = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as! NSDictionary
                    let recipe_list = list["recipe"]
                    let _ingredients = recipe_list!["ingredients"] as! NSArray
                    for i in 0..._ingredients.count - 1{
                        self.ingredients.append(_ingredients[i] as! String)
                    }
                }
                catch{
                    print(error)
                }
            }
        }
        session.resume()
    }
    
    //  Done Synchronously
    func set_photo(str: String)-> UIImage{
        let url = NSURL(string: str)
        let data = NSData(contentsOfURL: url!)
        return UIImage(data: data!)!
    }
    
    //  Getter Methods, don't really need these, but it's consistent with Obj-C.
    func get_publisher()-> String{
        return publisher
    }
    
    func get_title()-> String{
        return title
    }
    
    func get_photo()-> UIImage{
        return photo
    }
    
    func get_link()-> String{
        return link
    }
    
    func get_ingredients()-> [String]{
        return ingredients
    }
    
    func get_recipeID()->String{
        return recipeID
    }
    
}