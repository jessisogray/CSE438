//
//  SecondViewController.swift
//  MovieApp
//
//  Created by Daniel Gray on 10/5/16.
//  Copyright © 2016 Daniel Gray. All rights reserved.
//

import UIKit
import WebKit
import Dispatch


    class SecondViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {
        var currentMovieName : String = ""
        var currentPageNumber : Int = 1
        var favorites = [Favorite]()
        var finishedLoadingNext = true
        var messageBeenDisplayed = true
        var sortNameAscending : Bool = true
        
        @IBOutlet weak var sortButton: UIButton!
    //    @IBOutlet weak var FavoritesView: UICollectionView!
        @IBOutlet weak var filterTextField: UITextField!
        
        @IBOutlet weak var FavoritesView: UICollectionView!
//        @IBOutlet weak var sortButton: UIButton!
        override func viewDidLoad() {
            super.viewDidLoad()
            
            let cellWidth = 400
            let cellHeight = 70
            
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            
            layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
            layout.sectionInset = UIEdgeInsetsZero
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            FavoritesView!.collectionViewLayout = layout
            
            FavoritesView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "theCell")
            FavoritesView.delegate = self
            FavoritesView.dataSource = self
            
            sortButton?.setTitle("Currently Sorting Names Ascending, Tap To Change", forState: UIControlState.Normal)
            sortButton!.backgroundColor = UIColor.blackColor()
            sortButton!.addTarget(self, action: #selector(SecondViewController.sortButtonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)

            filterTextField.delegate = self
            filterTextField.addTarget(self, action: #selector(SecondViewController.filterEdited(_:)), forControlEvents:UIControlEvents.AllEditingEvents)

            
            
            
            // Do any additional setup after loading the view, typically from a nib.
        }
        override func viewDidAppear(animated: Bool){
            super.viewDidAppear(animated)
            calculateFavoritesArray(filterTextField.text!)
        }

        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        func displayNoMovieMessage(){
            if (favorites.count == 0 && !messageBeenDisplayed){
                let alert = UIAlertController(title: "No Movies Found", message: "Sorry, no favorites were found", preferredStyle: UIAlertControllerStyle.Alert)
                let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(action)
                presentViewController(alert, animated: true, completion: nil)
                messageBeenDisplayed = true
                
            }else if (favorites.count > 0 ){
                messageBeenDisplayed = false
            }
        }
        
        func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
        {
            return self.favorites.count
        }
        
        
        
        func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
        {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("theCell", forIndexPath: indexPath)
            let num = indexPath.item
            
            for subview in cell.subviews{
                subview.removeFromSuperview()
            }
            
            if (num < favorites.count){
                //cell.backgroundView = movies[num]
                favorites[num].frame = cell.bounds
                cell.addSubview(favorites[num])
                //cell.bringSubviewToFront(movies[num])
                //movies[num].setNeedsDisplay()
            }
            
            return cell
        }
        
        func scrollViewDidScroll(collectionView: UIScrollView){
            let bottomEdge = collectionView.contentOffset.y + collectionView.frame.size.height;
            
            if (finishedLoadingNext && bottomEdge >= collectionView.contentSize.height)
            {
                currentPageNumber += 1
                finishedLoadingNext = false
            }
            
            
        }
        
        func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
        {
            let num = indexPath.item
            loadMovie(favorites[num].id!)
            
        }
        
//        func sortMoviesByYear(sortAscending : Bool){
//            let i = 0
//            while (i < numMovies - 1){
//                let j = i + 1
//                while (j < numMovies){
//                    let iYear = movies[i].year
//                    let jYear = movies[j].year
//                    if ((jYear > iYear) == sortAscending){
//                        let temp = movies[i]
//                        movies[i] = movies[j]
//                        movies[j] = temp
//                    }
//                }
//            }
//        }
        
        func sortFavorites(){
            var i = 0
                        while (i < favorites.count - 1){
                            var j = i + 1
                            while (j < favorites.count){
                                let iName = String(favorites[i].text!)
                                let jName = String(favorites[j].text!)
                                if ((jName < iName) == sortNameAscending){
                                    let temp = favorites[i]
                                    favorites[i] = favorites[j]
                                    favorites[j] = temp
                                }
                                j += 1
                            }
                            i += 1
                        }
        }
        
        func loadMovie(movieId: String){
            let urlComponents = NSURLComponents(string: "https://www.omdbapi.com/")!
            let queryString = "i=\(movieId)"
            urlComponents.query = queryString
            let url = urlComponents.URL!
            let request = NSURL(string: url.absoluteString)
            //let movie = self.storyboard?.instantiateViewControllerWithIdentifier("MovieViewController") as? MovieViewController
            
            let movie = MovieViewController()
            
            let spinner = UIActivityIndicatorView(frame: self.view.frame)
            spinner.color = UIColor.blueColor()
            spinner.startAnimating()
            self.view.addSubview(spinner)
            
            
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) {
                
                let data = NSData(contentsOfURL: request!)
                let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                dispatch_async(dispatch_get_main_queue()) {
                    spinner.stopAnimating()
                    spinner.removeFromSuperview()
                    if let jsonString = dataString!.dataUsingEncoding(NSUTF8StringEncoding){
                        let jsonMovie = JSON(data: jsonString)
                        movie.setProperties(jsonMovie["Poster"].stringValue, movieName: jsonMovie["Title"].stringValue, movieId: jsonMovie["imdbID"].stringValue, releaseYear: Int(jsonMovie["Year"].int64Value), rating: jsonMovie["Rated"].stringValue, runtime: jsonMovie["Runtime"].stringValue, genre: jsonMovie["Genre"].stringValue)
                        
                        //                        let path = NSIndexPath(forRow: self.numMovies/3, inSection: self.numMovies%3)
                        //let path = self.movieView.indexPath
                        //let cell = self.collectionView(self.movieView, cellForItemAtIndexPath: path)
                        //cell?.contentView.addSubview(movie)
                        //cell.backgroundColor = UIColor.blueColor()
                    }
                    
                    
                    
                }
                
                //movie.viewDidLoad()
                
            }
            self.presentViewController(movie, animated: true, completion: nil)
            
            
            
            
        }
        
        func calculateFavoritesArray(filter: String){
            favorites = [Favorite]()
            let defaults = NSUserDefaults.standardUserDefaults()

            let prefixString = "MOVIEID:"
            for key in defaults.dictionaryRepresentation().keys{
                if (key.containsString(prefixString)){
                    let movieId = String(key).substringFromIndex(prefixString.endIndex)
                    let movieName = String(defaults.objectForKey(key)!)
                    
                    if (filter == "" ||                     movieName.capitalizedString.containsString(filter.capitalizedString)){

                        let newMovie = Favorite()
                        newMovie.setProperties(movieId, movieName: movieName)
                        favorites.append(newMovie)
                    }
                }
            }
            self.sortFavorites()
            
            
            
            FavoritesView.reloadData()
            FavoritesView.setNeedsDisplay()
            if (favorites.count == 0 && filter != ""){
                displayNoMovieMessage()
            }else if (favorites.count > 0){
                messageBeenDisplayed = false
            }
        }
        
        func sortButtonClicked(sender:UIButton!){
            sortNameAscending = !sortNameAscending
            if (sortNameAscending){
                sortButton?.setTitle("Currently Sorting Names Ascending, Tap To Change", forState: UIControlState.Normal)
            }else{
                sortButton?.setTitle("Currently Sorting Names Descending, Tap To Change", forState: UIControlState.Normal)
            }
            sortButton.setNeedsDisplay()
            calculateFavoritesArray(filterTextField.text!)
        }
        
        
       
        
        func filterEdited(sender: UITextField!){
            calculateFavoritesArray(String(sender.text!))

        }
}

class Favorite : UILabel{
    var id : String?
    
    func setProperties(movieId: String, movieName: String){
        self.backgroundColor = UIColor.whiteColor()
        self.id = movieId
        self.text = movieName
        self.textAlignment = NSTextAlignment.Center
        
    }
    
}


        
        
        
        
        
        
        

