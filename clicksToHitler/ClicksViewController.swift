//
//  ViewController.swift
//  clicksToHitler
//
//  Created by Emil Söderlind on 2016-11-17.
//  Copyright © 2016 ENOS Pr. All rights reserved.
//

import UIKit
import CloudKit
import GameKit

class ClicksViewController: UIViewController, UIWebViewDelegate, GKGameCenterControllerDelegate{
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    var hitlerFound = false
    
    var siteTrace = [String]()
    
    var startDate:Date = Date()
    
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
            print("<NO INTERNET CONNECTION")
            
            
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
        
        web.alpha = 0
        
        
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        loadingIndicator.startAnimating()
        
        if(String(describing: currentReachabilityStatus) == "notReachable"){
            checkInternet()
        }else{
            print("<Connected to internet.")
            authPlayer()
        }
        
        
        print("<ViewDidLoad - Start")
        
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
        
        print("<ViewDidLoad - Done")
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
            print("<FOUND HITLER!")
            hitlerFound = true
            
            timeTicking = false
            
            var time:Double = -(Double(startDate.timeIntervalSinceNow.description)!)
            
            
            print("Time: \(time)")
            
            clicks += 1
            
            
            // Local save & Leaderboard save
            updateAverage(clicks: clicks)
            addTotalClicksToLocalSave(clicks: clicks)
            addTotalHitlerFound()
            checkLeastClicks(clicks: clicks)
            updateBestTime(time: time)
            
            
            
            
            
            // Cloudkit stuff
            
            let publicDB = CKContainer.default().publicCloudDatabase
            
            let greatID = CKRecordID(recordName: "worldwideStats")
            
            
            publicDB.fetch(withRecordID: greatID) { fetchedPlace, error in
                guard let fetchedPlace = fetchedPlace else {

                    print("\n\nError: \(error) \n\n")
                    
                    return
                }
                
                print("\nOld save: \(fetchedPlace.allKeys())")
                print("Old save: \(fetchedPlace.allTokens()) \n")

            
                var oldBestTime:Double = fetchedPlace["bestTime"] as! Double
                print("<Old best time: \(oldBestTime)")
                print("<New best time: \(time)")
                
                if (round(100*time)/100) < (round(100*oldBestTime)/100) {
                    print("<Replacing \(oldBestTime) with \(time)")
                    fetchedPlace["bestTime"] = time as CKRecordValue
                }else{
                    print("<Old best time is BETTER")
                }
                
                var oldLeastClicks:Int = fetchedPlace["leastClicks"] as! Int
                
                print("Old least clicks: \(oldLeastClicks)")
                print("New least clicks: \(self.clicks)")

                
                if(Int(oldLeastClicks) > (self.clicks)){
                    fetchedPlace["leastClicks"] = self.clicks as CKRecordValue
                }
                
                var oldTotalClicks:Int = fetchedPlace["totalClicks"] as! Int
                fetchedPlace["totalClicks"] = (oldTotalClicks + self.clicks) as CKRecordValue
            
                var oldFoundHitlerTimes = fetchedPlace["foundHitlerTimes"] as! Int
                fetchedPlace["foundHitlerTimes"] = (oldFoundHitlerTimes + 1) as CKRecordValue
                
                
                var newAverageClicks:Double = Double(oldTotalClicks + self.clicks) / Double(oldFoundHitlerTimes + 1)
                fetchedPlace["averageClicks"] = newAverageClicks as CKRecordValue
                
                
                publicDB.save(fetchedPlace) { savedPlace, savedError in
                    //...
                    
                    print("\n\nCloudKit error: \(savedError.debugDescription) \n\n")
                    
                    print("\nSaved: \(savedPlace?.allKeys())")
                    print("Saved: \(savedPlace?.allTokens())\n")

                
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
                StartViewController.downloadLatestWorldStats()
            }
            
            let againAction = UIAlertAction(title: "Try again!", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in self.resetButton(self)
                StartViewController.downloadLatestWorldStats()
            }
            
            alertController.addAction(okAction)
            alertController.addAction(againAction)

            self.present(alertController, animated: true, completion: { 
                print("<Closed found hitler popup")
            })
            
        }
        
        
        return true;
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        removeLoadingInd()
        
        if(clicks == 0){
            print("<Reseting date")
            timeTicking = true
            startDate = Date()
        }
        
        
        if(!(clicks < 0)){
            loadingIndicator.alpha = 0
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
            
            saveFoundsLeaderboard(founds: oldFounds + 1)
            
        }else{
            
            UserDefaults.standard.setValue(1, forKey: "totalFounds")
            
            saveFoundsLeaderboard(founds: 1)

            
        }
    }
    
    func updateBestTime(time: Double){
        if let oldBestTime = UserDefaults.standard.value(forKey: "bestTime") as? Double{
            
            
            print("OldBest Time: \(oldBestTime)")
            print("newTime: \(time)")
            
            if(time < oldBestTime){
            
                UserDefaults.standard.setValue(time, forKey: "bestTime")
                
                saveBestTimeToLeaderboards(time: time)
                
                
            }
            
        }else{
            
            UserDefaults.standard.setValue(time, forKey: "bestTime")
            saveBestTimeToLeaderboards(time: time)
            
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
        
        saveAverageToLeaderboards(average: newTotalClicks/Double((hitlerFound + 1)))
        
        UserDefaults.standard.setValue(newTotalClicks/Double((hitlerFound + 1)), forKey: "average")

    }
    
    func checkLeastClicks(clicks: Int){
        if let oldLeast = UserDefaults.standard.value(forKey: "leastClicks") as? Int{
            
            if(oldLeast > clicks){
                UserDefaults.standard.setValue(clicks, forKey: "leastClicks")
                
                
                saveLeastClicksToLeaderboards(clicks: clicks)
                
            }
            
        }else{
            UserDefaults.standard.setValue(clicks, forKey: "leastClicks")
            saveLeastClicksToLeaderboards(clicks: clicks)
        }
    }
    
    
    // Leaderboard stuff
    
    func saveLeastClicksToLeaderboards(clicks: Int){
        
        if GKLocalPlayer.localPlayer().isAuthenticated {
            
            let scoreReporter = GKScore(leaderboardIdentifier: "leastClicksToHitler_ID")
            
            scoreReporter.value = Int64(clicks)
            
            let scoreArray : [GKScore] = [scoreReporter]
            
            GKScore.report(scoreArray, withCompletionHandler: { (error) in
                
                if(error != nil){
                    print("Error in reporting score: \(error)")
                }else{
                    print("Uploaded least clicks")
                }
                
                
            })
            
        }else{
            print("NOT AUTHENTICATED fewest clicks -> Leaderboards")
        }

        
        
        
    }
    
    func saveAverageToLeaderboards(average: Double){
        
        if GKLocalPlayer.localPlayer().isAuthenticated {
            
            let scoreReporter = GKScore(leaderboardIdentifier: "average_ID")
            
            var roundedAverage:Double = round(100*average)
            scoreReporter.value = Int64(roundedAverage)
            
            
            let scoreArray : [GKScore] = [scoreReporter]
            
            GKScore.report(scoreArray, withCompletionHandler: { (error) in
                
                if(error != nil){
                    print("Error in reporting score: \(error)")
                }else{
                    print("Uploaded average")
                }
                
                
            })
            
        }else{
            print("NOT AUTHENTICATED average -> leaderboards")
        }

        
        
        
        
    }
    
    func saveBestTimeToLeaderboards(time : Double){
        
        if GKLocalPlayer.localPlayer().isAuthenticated {
            
            let scoreReporter = GKScore(leaderboardIdentifier: "shortestTime_ID")
            
            var bestTime:Double = round(100*time)
            scoreReporter.value = Int64(bestTime)
            
            
            let scoreArray : [GKScore] = [scoreReporter]
            
            GKScore.report(scoreArray, withCompletionHandler: { (error) in
                
                if(error != nil){
                    print("Error in reporting score: \(error)")
                }else{
                    print("Uploaded best time")
                }
                
                
            })
            
        }else{
            print("NOT AUTHENTICATED best time -> Leaderboards")
        }
        
        
    }
    
    func saveFoundsLeaderboard(founds : Int){
        
        if GKLocalPlayer.localPlayer().isAuthenticated {
            
            let scoreReporter = GKScore(leaderboardIdentifier: "mostHitlersFound_ID")
            
            scoreReporter.value = Int64(founds)
            
            let scoreArray : [GKScore] = [scoreReporter]
            
            GKScore.report(scoreArray, withCompletionHandler: { (error) in
                
                    print("Error in reporting score: \(error)")
                
                
            })
            
        }else{
            print("NOT AUTHENTICATED founds -> Leaderboards")
        }
        
        
    }

    
    func authPlayer(){
        let localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {
            (view, error) in
            
            if view != nil {
                
                self.present(view!, animated: true, completion: nil)
                
            }
            else {
                
                print(GKLocalPlayer.localPlayer().isAuthenticated)
                
            }
            
        }
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
        
    }



}

