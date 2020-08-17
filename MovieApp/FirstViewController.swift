//
//  FirstViewController.swift
//  MovieApp
//
//  Created by Daniel Gray on 10/5/16.
//  Copyright © 2016 Daniel Gray. All rights reserved.
//

import UIKit
import WebKit
import Dispatch

//Movie Search Tab
class FirstViewController: UIViewController, WKUIDelegate, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    var currentMovieName : String = ""
    var currentPageNumber : Int = 1
    var numMovies : Int = 0
    var movies = [Movie]()
    var finishedLoadingNext = true
    var thereAreMovies = true
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    var webView: WKWebView = WKWebView()
    @IBOutlet weak var movieView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellWidth = 200
        let cellHeight = 300

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.sectionInset = UIEdgeInsetsZero
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        movieView!.collectionViewLayout = layout



        
        searchBar.delegate = self
        webView.UIDelegate = self
        movieView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "theCell")
        movieView.delegate = self
        movieView.dataSource = self
        

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func searchForMovie(){
        let urlComponents = NSURLComponents(string: "https://www.omdbapi.com/")!
        let queryString = "s=\(currentMovieName)&page=\(currentPageNumber)"
        //let queryString = "s=\"\(currentMovieName)\"&page=\(currentPageNumber)"
        urlComponents.query = queryString
        let url = urlComponents.URL!
        //let request = NSMutableURLRequest(URL: url)
        let request = NSURL(string: url.absoluteString)

        let session = NSURLSession.sharedSession()
        
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
                    let movieData = JSON(data: jsonString)
                    for jsonMovie in movieData["Search"].arrayValue{
                        self.thereAreMovies = true
                        let movie = Movie()
                        movie.setProperties(jsonMovie["Poster"].stringValue, movieName: jsonMovie["Title"].stringValue, movieId: jsonMovie["imdbID"].stringValue, releaseYear: Int(jsonMovie["Year"].int64Value))
                        self.movies.append(movie)
                        self.numMovies += 1
                        
                    }
                    
                    self.movieView.reloadData()
                    self.finishedLoadingNext = true


                    
                    //                        let path = NSIndexPath(forRow: self.numMovies/3, inSection: self.numMovies%3)
                    //let path = self.movieView.indexPath
                    //let cell = self.collectionView(self.movieView, cellForItemAtIndexPath: path)
                    //cell?.contentView.addSubview(movie)
                    //cell.backgroundColor = UIColor.blueColor()
                }
                self.displayNoMovieMessage()

                
                
                
            }
        }


        

    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        currentMovieName = searchBar.text!
        currentPageNumber = 1
        numMovies = 0
        movies = [Movie]()
        thereAreMovies = false
        searchForMovie()

        
    }
    func displayNoMovieMessage(){
        if (!thereAreMovies){
            let alert = UIAlertController(title: "No Movies Found", message: "Sorry, no movies were found", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(action)
            presentViewController(alert, animated: true, completion: nil)

        }
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.numMovies
    }
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("theCell", forIndexPath: indexPath)
        let num = indexPath.item
        
        for subview in cell.subviews{
            subview.removeFromSuperview()
        }
        
        if (num < numMovies){
            //cell.backgroundView = movies[num]
            movies[num].frame = cell.bounds
            cell.addSubview(movies[num])
            
            let rect = cell.bounds.divide(60.0, fromEdge: .MaxYEdge).slice
            let label = UILabel(frame: rect)
            label.lineBreakMode = NSLineBreakMode.ByWordWrapping
            label.numberOfLines = 0
            label.text = movies[num].title
            label.backgroundColor = UIColor.blackColor()
            label.textColor = UIColor.whiteColor()
            label.alpha = CGFloat(0.6)
            cell.addSubview(label)
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
            searchForMovie()
        }

        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        let num = indexPath.item
        loadMovie(movies[num])
        
    }
    
    func sortMoviesByYear(sortAscending : Bool){
        let i = 0
        while (i < numMovies - 1){
            let j = i + 1
            while (j < numMovies){
                let iYear = movies[i].year
                let jYear = movies[j].year
                if ((jYear > iYear) == sortAscending){
                    let temp = movies[i]
                    movies[i] = movies[j]
                    movies[j] = temp
                }
            }
        }
    }
    
    func loadMovie(movie: Movie){
        let urlComponents = NSURLComponents(string: "https://www.omdbapi.com/")!
        let queryString = "i=\(movie.id!)"
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
}
class Movie : UIImageView{
    var title : String?
    var id : String?
    var year : Int?
    

//    func setProperties(imageLink: String, movieName: String, movieId: String, releaseYear: Int){
//        
//        
//        let spinner = UIActivityIndicatorView(frame: self.frame)
//        spinner.color = UIColor.blueColor()
//        spinner.startAnimating()
//        self.addSubview(spinner)
//        
//        let request = NSMutableURLRequest(URL: NSURL(string: imageLink)!)
//        
//        
//        
//        
//        let session = NSURLSession.sharedSession()
//        let task = session.dataTaskWithRequest(request) {
//            (data, response, error) -> Void in
//            spinner.stopAnimating()
//            spinner.removeFromSuperview()
//
//            if let imageData = data as NSData? {
//                self.image = UIImage(data: imageData)
//
//            }
//            
//        }
//        task.resume()
//        
//        
//        //let qName = movieName + "_queue"
//        //  let q = dispatch_queue_create(qName, DISPATCH_QUEUE_CONCURRENT)
//        //  dispatch_async(q){
//        //  let data = NSData(contentsOfURL: url!)!
//        //  self.image = UIImage(data: data)
//        //  }
//        self.title = movieName
//        self.id = movieId
//        self.year = releaseYear
//        
//    }

    func setProperties(imageLink: String, movieName: String, movieId: String, releaseYear: Int){
    
    
    let spinner = UIActivityIndicatorView(frame: self.frame)
    spinner.color = UIColor.blueColor()
    spinner.startAnimating()
    self.addSubview(spinner)
    
    let request = NSURL(string: imageLink)!
    
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
    
    let imageData = NSData(contentsOfURL: request)
    dispatch_async(dispatch_get_main_queue()) {
        spinner.stopAnimating()
        spinner.removeFromSuperview()
        if (imageData != nil){
           self.image = UIImage(data: imageData!)
        }
    
    }
    
    
    
    }
    
    
    
    //let qName = movieName + "_queue"
    //  let q = dispatch_queue_create(qName, DISPATCH_QUEUE_CONCURRENT)
    //  dispatch_async(q){
    //  let data = NSData(contentsOfURL: url!)!
    //  self.image = UIImage(data: data)
    //  }
    self.title = movieName
    self.id = movieId
    self.year = releaseYear
    
    }

    
    
    
    
    
    


}
