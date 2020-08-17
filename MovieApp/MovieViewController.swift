//
//  MovieViewController.swift
//  MovieApp
//
//  Created by Daniel Gray on 10/6/16.
//  Copyright © 2016 Daniel Gray. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import Dispatch



class MovieViewController : UIViewController{
    var movieTitle : String?
    var id : String?
    var year : Int?
    var rating : String?
    var runtime : String?
    var genre : String?
    var imageView : UIImageView?
    var label : UILabel?
    var backButton : UIButton?
    var favoriteButton : UIButton?
    var movieIsFavorite : Bool?
    var key : String?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieIsFavorite = false
        let xRoot = UIScreen.mainScreen().bounds.origin.x
        let yRoot = UIScreen.mainScreen().bounds.origin.y
        let rect = CGRect(x: xRoot, y: yRoot+30, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height/3*2)
        imageView = UIImageView(frame: rect)
        imageView!.backgroundColor = UIColor.whiteColor()
        let rect2 = CGRect(x: 0, y: UIScreen.mainScreen().bounds.height/3*2+30, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height/5-30)
        label = UILabel(frame: rect2)
        label!.numberOfLines = 5
        label!.backgroundColor = UIColor.whiteColor()
        let rect3 = CGRect(x: xRoot, y: 20, width: 100, height: 30)
        backButton = UIButton(frame: rect3)
        backButton?.setTitle("Back", forState: UIControlState.Normal)
        backButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        backButton!.backgroundColor = UIColor.whiteColor()
        backButton!.alpha = 0.75
        backButton!.addTarget(self, action: #selector(MovieViewController.goBack(_:)), forControlEvents: UIControlEvents.TouchUpInside)

        let rect4 = CGRect(x: 0, y: UIScreen.mainScreen().bounds.height/3*2 + UIScreen.mainScreen().bounds.height/5, width: UIScreen.mainScreen().bounds.width, height: 100)
        favoriteButton = UIButton(frame: rect4)
        if (movieIsFavorite!){
            favoriteButton?.setTitle("Remove From Favorites", forState: UIControlState.Normal)
        }else{
            favoriteButton?.setTitle("Add to Favorites", forState: UIControlState.Normal)

        }
        favoriteButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        favoriteButton!.backgroundColor = UIColor.whiteColor()
        favoriteButton!.alpha = 0.75
        favoriteButton!.addTarget(self, action: #selector(MovieViewController.addOrRemoveFavorite(_:)), forControlEvents: UIControlEvents.TouchUpInside)


        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func setProperties(imageLink: String, movieName: String, movieId: String, releaseYear: Int, rating: String, runtime: String, genre: String){
        
        self.movieTitle = movieName
        self.id = movieId
        self.rating = rating
        self.runtime = runtime
        self.genre = genre
        self.year = releaseYear
        
        let defaults = NSUserDefaults.standardUserDefaults()
        self.key = "MOVIEID:\(self.id!)"
        if (defaults.objectForKey(self.key!) == nil){
            favoriteButton?.setTitle("Add to Favorites", forState: UIControlState.Normal)

            self.movieIsFavorite = false
            
        }else{
            self.movieIsFavorite = true
            favoriteButton?.setTitle("Remove From Favorites", forState: UIControlState.Normal)


        }
        favoriteButton?.setNeedsDisplay()
        
        
        label!.text = "\(movieName)\nRated: \(rating)\nRuntime: \(runtime)\nGenre: \(genre)\nReleased: \(releaseYear)"
        label!.setNeedsDisplay()
        self.view.addSubview(label!)
        
        let spinner = UIActivityIndicatorView(frame: self.imageView!.frame)
        spinner.color = UIColor.blueColor()
        spinner.startAnimating()
        imageView!.addSubview(spinner)

        
        let request = NSURL(string: imageLink)
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            let imageData = NSData(contentsOfURL: request!)

            dispatch_async(dispatch_get_main_queue()) {
                spinner.stopAnimating()
                spinner.removeFromSuperview()

                if (imageData != nil){
                self.imageView!.image = UIImage(data: imageData!)
                }
            }
            
            
        }

        //let qName = movieName + "_queue"
        //  let q = dispatch_queue_create(qName, DISPATCH_QUEUE_CONCURRENT)
        //  dispatch_async(q){
        //  let data = NSData(contentsOfURL: url!)!
        //  self.image = UIImage(data: data)
        //  }
 
        
        imageView!.setNeedsDisplay()
 
        self.view.addSubview(imageView!)
        self.view.addSubview(backButton!)

        self.view.bringSubviewToFront(backButton!)
        backButton!.setNeedsDisplay()
        self.view.addSubview(favoriteButton!)
        favoriteButton?.setNeedsDisplay()




        }
        func goBack(sender:UIButton!) {
            self.dismissViewControllerAnimated(false, completion: nil)
            
        }
    
        func addOrRemoveFavorite(sender:UIButton!){
            let defaults = NSUserDefaults.standardUserDefaults()

            if (movieIsFavorite!){
                favoriteButton?.setTitle("Add to Favorites", forState: UIControlState.Normal)
                defaults.removeObjectForKey(self.key!)
                
                movieIsFavorite = false
            }else{
                favoriteButton?.setTitle("Remove From Favorites", forState: UIControlState.Normal)
                
                defaults.setObject(self.movieTitle!, forKey: self.key!)


                movieIsFavorite = true
                
            }
            favoriteButton?.setNeedsDisplay()
        
        }

    
    
    
    
    
    
}

