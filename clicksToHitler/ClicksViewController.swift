//
//  ViewController.swift
//  clicksToHitler
//
//  Created by Emil Söderlind on 2016-11-17.
//  Copyright © 2016 ENOS Pr. All rights reserved.
//

import UIKit
import CloudKit

class ClicksViewController: UIViewController,UIWebViewDelegate {
    
    var hitlerFound = false
    
    var siteTrace = [String]()
    
    var startDate:Date = Date()
    var time:Double = 1000
    
    var timeTicking = false
    
    @IBOutlet weak var web: UIWebView!
    @IBOutlet weak var clicksLabel: UIBarButtonItem!
    
    override func viewDidAppear(_ animated: Bool) {
        checkInternet()
    }
    
    @IBAction func resetButton(_ sender: Any) {
        
        checkInternet()
        
        timeTicking = false
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        web.alpha = 0
        
        navigationItem.leftBarButtonItem?.title = "Hello"
        
        hitlerFound = false
        
        siteTrace.removeAll()
        
        let url = NSURL (string: "https://en.m.wikipedia.org/wiki/Special:Random/#/random");
        let requestObj = NSURLRequest(url: url! as URL);
        
        DispatchQueue.global(qos: .background).async {
            
            self.web.loadRequest(requestObj as URLRequest);
            
            DispatchQueue.main.async {

            }
        }
        
        
        clicks = -2
        
    }
    
    var clicks: Int = -2
    
    func checkInternet(){
        
        if(String(describing: currentReachabilityStatus) == "notReachable"){
            print("NO INTERNET CONNECTION")
            
            
            let alertController = UIAlertController(title: "No internet connection", message: "You will need a internet connection for this game", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            let okAction = UIAlertAction(title: "Retry", style: UIAlertActionStyle.destructive) { (result : UIAlertAction) -> Void in
                
                self.checkInternet()

            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: {
                
                self.checkInternet()
                
            })
            
            
            
        }else{
            print(currentReachabilityStatus)
        }
        
        
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if(String(describing: currentReachabilityStatus) == "notReachable"){
            checkInternet()
        }else{
            print("Connected to internet.")
        }
        
        
        print("ViewDidLoad - Start")
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 204.0/255.0, green: 21.0/255.0, blue: 24.0/255.0, alpha: 1.0)

        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        web.delegate = self
        web.scalesPageToFit = true
        
        DispatchQueue.global(qos: .background).async {
            print("Starting site-loading thread")
            
            let url = NSURL (string: "https://en.m.wikipedia.org/wiki/Special:Random/#/random");
            let requestObj = NSURLRequest(url: url! as URL);
            
            self.web.loadRequest(requestObj as URLRequest);
            
            DispatchQueue.main.async {
                print("Done site-loading thread")
            }
        }

        
        clicksLabel.title = "Clicks: 0"
        
        print("ViewDidLoad - Done")
    }
    
    func updateTimeLabel(){
    
            self.clicksLabel.title = "Clicks: \(self.clicks)"
        
    }
    
    func removeLoadingInd(){
           UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if(hitlerFound){
            return false
        }
        
        
        print("CLICKED LINK!")
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        print(request.description)
        
        if(request.description.contains("/search") && clicks >= 0){
            
            print("Tried to search on wikipedia -> Reset")
            
            let alertController = UIAlertController(title: "Don't use search Wikipedia", message: "You are not allowed to use search Wikipedia. Try again.", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
            resetButton(self)
            
        }
        else if(!request.description.contains("https://en.m.wikipedia.org/wiki/")){
            
            print("Tried to leave wikipedia -> Reset")
            
            let alertController = UIAlertController(title: "Don't leave Wikipedia", message: "You are not allowed to leave Wikipedia. Try again.", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
            resetButton(self)
        }
        else if(request.description.contains("/editor/")){
            
            print("Tried to edit page  -> Reset")
            
            let alertController = UIAlertController(title: "Follow the rules!", message: "You are not allowed edit wikipedia pages. Try again.", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
            resetButton(self)
        }
        else if(request.description.contains("#/languages")){
            
            print("Tried to change language  -> Reset")
            
            let alertController = UIAlertController(title: "Only english wikipedia", message: "You are not allowed to change language. Try again.", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
            resetButton(self)
        }
        else if(request.description != "https://en.m.wikipedia.org/wiki/Adolf_Hitler"){
            
            // Add site to tracequeue
            
            if(clicks > -2){
                
                siteTrace.append(parseStringFromLink(oldLink: request.description))
            }
            
            clicks += 1
            
            
            if(!(clicks < 0)){
                updateTimeLabel()
            }else{
                clicksLabel.title = "Clicks: 0"
            }
        }else{
            print("YOU FOUND HITLER!")
            hitlerFound = true
            
            timeTicking = false
            
            var time:Double = -(Double(startDate.timeIntervalSinceNow.description)!)
            
            
            print("Time: \(time)")
            
            clicks += 1
            
            updateAverage(clicks: clicks)
            addTotalClicksToLocalSave(clicks: clicks)
            addTotalHitlerFound()
            checkLeastClicks(clicks: clicks)
            updateBestTime(time: time)
            
            
            
            let publicDB = CKContainer.default().publicCloudDatabase
            
            let greatID = CKRecordID(recordName: "worldwideStats")
            
            
            publicDB.fetch(withRecordID: greatID) { fetchedPlace, error in
                guard let fetchedPlace = fetchedPlace else {
                    // handle errors here
                    return
                }
            
                var oldBestTime:Double = fetchedPlace["bestTime"] as! Double
                if(oldBestTime > self.time){
                    fetchedPlace["bestTime"] = self.time as CKRecordValue?
                }
                
                var oldLeastClicks:Int = fetchedPlace["leastClicks"] as! Int
                
                if(oldLeastClicks > self.clicks){
                    fetchedPlace["leastClicks"] = self.clicks as CKRecordValue?
                }
                
                var oldTotalClicks:Int = fetchedPlace["totalClicks"] as! Int
                fetchedPlace["totalClicks"] = (oldTotalClicks + self.clicks) as CKRecordValue
            
                var oldFoundHitlerTimes = fetchedPlace["foundHitlerTimes"] as! Int
                fetchedPlace["foundHitlerTimes"] = (oldFoundHitlerTimes + 1) as CKRecordValue
                
                
                var newAverageClicks = (oldTotalClicks + self.clicks) / (oldFoundHitlerTimes + 1)
                fetchedPlace["averageClicks"] = newAverageClicks as CKRecordValue?
                
                
                publicDB.save(fetchedPlace) { savedPlace, savedError in
                    //...
                }
            }
            
            
            
            
            
            
            
            
            
            siteTrace.append(parseStringFromLink(oldLink: request.description))
            
            
            clicksLabel.title = "Clicks: \(clicks)"
            print("TRACE: \(siteTrace)")
            
            
            var traceString: String = ""
            var index = 0
            
            for i in siteTrace{
                
                if(index != 0){
                    traceString = traceString + "\n" + siteTrace[index]
                }else{
                    traceString = siteTrace[0]
                }
                
                index = index + 1
                
            }
            
            let alertController = UIAlertController(title: "Congratulations!", message: "You found Adolf Hitler in: \n\(clicks) clicks \nand\n\(round(100*time)/100) sec.\n\n\(traceString)", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
            }
            
            let againAction = UIAlertAction(title: "Try again!", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in self.resetButton(self)
            }
            
            alertController.addAction(okAction)
            alertController.addAction(againAction)

            self.present(alertController, animated: true, completion: { 
                self.downloadLatestWorldStats()
            })
            
        }
        
        
        return true;
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        removeLoadingInd()
        
        if(clicks == 0){
            print("Reseting date")
            timeTicking = true
            startDate = Date()
        }
        
        
        if(!(clicks < 0)){
            web.alpha = 1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func parseStringFromLink(oldLink: String)->String{
        
        
        var link:String = oldLink.replacingOccurrences(of: "#/random", with: "")
        
        link = link.replacingOccurrences(of: "https://en.m.wikipedia.org/wiki/", with: "")
        
        var siteName:String = link.replacingOccurrences(of: "_", with: " ")

        
        print(siteName)
        
        return siteName
        
    }
    
    func addTotalClicksToLocalSave(clicks: Int){
        if let oldClicks = UserDefaults.standard.value(forKey: "totalClicks") as? Int{
            print("Found total-click-save on device")
            
            print("OldClicks: \(oldClicks)")
            print("newClicks: \(oldClicks + clicks)")
            
            UserDefaults.standard.setValue(oldClicks + clicks, forKey: "totalClicks")
            
        }else{
            print("No total-click-save on device")
            
            UserDefaults.standard.setValue(clicks, forKey: "totalClicks")
            
        }
    }
    
    func addTotalHitlerFound(){
        if let oldFounds = UserDefaults.standard.value(forKey: "totalFounds") as? Int{
            
            UserDefaults.standard.setValue(oldFounds + 1, forKey: "totalFounds")
            
        }else{
            
            UserDefaults.standard.setValue(1, forKey: "totalFounds")
            
        }
    }
    
    func addTotalTime(time: Double){
        if let oldTotalTime = UserDefaults.standard.value(forKey: "totalTime") as? Double{
        
            print("Old: \(oldTotalTime)")
            print("New: \(oldTotalTime + time)")
            
            UserDefaults.standard.setValue(oldTotalTime + time, forKey: "totalTime")
            
        }else{
            UserDefaults.standard.setValue(time, forKey: "totalTime")
            
        }
    }
    
    func updateBestTime(time: Double){
        if let oldBestTime = UserDefaults.standard.value(forKey: "bestTime") as? Double{
            
            if(time < oldBestTime){
            
                UserDefaults.standard.setValue(time, forKey: "bestTime")
                
            }
            
        }else{
            
            UserDefaults.standard.setValue(time, forKey: "bestTime")
            
        }
    }
    
    func updateAverage(clicks: Int){
        
        var hitlerFound: Int = 0
        var average: Double = 0
        
        if let hitlerFoundSave = UserDefaults.standard.value(forKey: "totalFounds") as? Int{
            hitlerFound = hitlerFoundSave
        }
        
        if let averageSave = UserDefaults.standard.value(forKey: "average") as? Double{
            average = averageSave
        }
        
        
        var totalClicksToHitler: Double = Double(hitlerFound)*average
        var newTotalClicks:Double = totalClicksToHitler + Double(clicks)
        
        
        
        UserDefaults.standard.setValue(newTotalClicks/Double((hitlerFound + 1)), forKey: "average")

    }
    
    func checkLeastClicks(clicks: Int){
        if let oldLeast = UserDefaults.standard.value(forKey: "leastClicks") as? Int{
            
            if(oldLeast > clicks){
                UserDefaults.standard.setValue(clicks, forKey: "leastClicks")

            }
            
        }else{
            UserDefaults.standard.setValue(clicks, forKey: "leastClicks")
            
        }
    }
    
    func downloadLatestWorldStats(){
        
        
        
        let publicDB = CKContainer.default().publicCloudDatabase
        
        let greatID = CKRecordID(recordName: "worldwideStats")
        
        
        publicDB.fetch(withRecordID: greatID) { fetchedPlace, error in
            guard let fetchedPlace = fetchedPlace else {
                // handle errors here
                
                print("\n\n")
                print(error)
                print("\n\n")
                
                
                return
            }
            
            
            
            var totalClicks = fetchedPlace["totalClicks"]! as! Int
            var averageClicks = fetchedPlace["averageClicks"]! as! Double
            var bestTime = fetchedPlace["bestTime"]! as! Double
            var foundHitlerTimes = fetchedPlace["foundHitlerTimes"]! as! Int
            var leastClicks = fetchedPlace["leastClicks"]! as! Int
            
            
            UserDefaults.standard.setValue(totalClicks, forKey: "worldTotalClicks")
            UserDefaults.standard.setValue(averageClicks, forKey: "worldAverageClicks")
            UserDefaults.standard.setValue(bestTime, forKey: "worldBestTime")
            UserDefaults.standard.setValue(foundHitlerTimes, forKey: "worldFoundHitlerTimes")
            UserDefaults.standard.setValue(leastClicks, forKey: "worldLeastClicks")
            
            
            print("Downloaded latest worldstats")
        }

    
    }


}

