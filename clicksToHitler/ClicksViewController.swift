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
import GoogleMobileAds

class ClicksViewController: UIViewController, UIWebViewDelegate, GKGameCenterControllerDelegate, GADInterstitialDelegate{
    
    
    var interstitial: GADInterstitial!

    var hitlerGratzPopup: UIAlertController = UIAlertController()
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    var hitlerFound = false
    
    var siteTrace = [String]()
    
    var startDate:Date = Date()
    
    var timeTicking = false
    
    var showingAd = false
    var siteReady = false
    var gratzScreenHasBeenShown = false
    
    @IBOutlet weak var web: UIWebView!
    @IBOutlet weak var clicksLabel: UIBarButtonItem!
    
    override func viewDidAppear(_ animated: Bool) {
        checkInternet()
    }
    
    @IBAction func resetButton(_ sender: Any) {
        
        showAd()
        
        checkInternet()
        
        web.alpha = 0
        loadingIndicator.alpha = 1
        loadingIndicator.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        timeTicking = false
        
        
        hitlerFound = false
        gratzScreenHasBeenShown = false
        
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
        
        print("\n\n")
        
        web.allowsLinkPreview = false
        web.allowsPictureInPictureMediaPlayback = false
        web.sizeToFit()
        
        interstitial = createAndLoadInterstitial()
        
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
    
    // ADMOB STUFF
    
    func createAndLoadInterstitial() -> GADInterstitial {
        var interstitial = GADInterstitial(adUnitID: "ca-app-pub-3033461333499330/7963329403")
        interstitial.delegate = self
        var request = GADRequest()
        request.testDevices = [ kGADSimulatorID, "fff49adc7690922a03c614377c2f2ad2" ];
        interstitial.load(request)
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
        
        print("User closed AD")
        showingAd = false
        
        if(hitlerFound){
            self.present(hitlerGratzPopup, animated: true, completion: {
                print("<Closed found hitler popup")
                self.gratzScreenHasBeenShown = true
            })
        }
        
        if(siteReady){
            print("Reseting Date! (in interstitialDidDismissScreen)")
            startDate = Date()
        }
        
    }
    
    func showAd(){
        if (self.interstitial.isReady && !gratzScreenHasBeenShown){
            print("\nPresenting ad!\n")
            showingAd = true
            self.interstitial.present(fromRootViewController: self)
        }else{
            print("\nAd was not ready\n")
        }
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
            
            showAd()
            
            timeTicking = false
            
            var time:Double = -(Double(startDate.timeIntervalSinceNow.description)!)
            print("\nTime: \(time)")
            print("\n\(ClicksViewController.getTimeString(time: time))")
            
            clicks += 1
            
            // Local save & Leaderboard save
            addTotalClicksToLocalSave(clicks: clicks)
            addTotalHitlerFound()
            checkLeastClicks(clicks: clicks)
            updateBestTime(time: time)
            updateAverage(clicks: clicks)
            ClicksViewController.updatingLeaderboardsFromDeviceSave()
            
            // Cloudkit stuff
            
            let publicDB = CKContainer.default().publicCloudDatabase
            
            let greatID = CKRecordID(recordName: "worldwideStats")
            
            publicDB.fetch(withRecordID: greatID) { fetchedPlace, error in
                guard let fetchedPlace = fetchedPlace else {

                    print("\n\nError: \(error) \n\n")
                    
                    return
                }
            
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
                
                }
            }
            
            
            // Build finish message
            siteTrace.append(parseStringFromLink(oldLink: request.description))
            
            clicksLabel.title = "Clicks: \(clicks)"
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
            
            hitlerGratzPopup = UIAlertController(title: "Congratulations!", message: "You found Adolf Hitler in: \n\(clicks) clicks \nand\n\(ClicksViewController.getTimeString(time: time))\n\n\(traceString)", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
                StartViewController.downloadLatestWorldStats()
            }
            let againAction = UIAlertAction(title: "Try again!", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in self.resetButton(self)
                StartViewController.downloadLatestWorldStats()
            }
            
            hitlerGratzPopup.addAction(okAction)
            hitlerGratzPopup.addAction(againAction)
        }
        return true;
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        removeLoadingInd()
        
        if(clicks == 0){
            print("<Reseting date")
            timeTicking = true
            siteReady = true
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if(!showingAd){
                print("Reseting Date! (in webViewDidFinishLoad)")
                startDate = Date()
            }else{
                print("Not done with AD, waiting with reseting date (in webViewDidFinishLoad)")
            }
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
            
            ClicksViewController.saveFoundsLeaderboard(founds: oldFounds + 1)
            
        }else{
            
            UserDefaults.standard.setValue(1, forKey: "totalFounds")
            
            ClicksViewController.saveFoundsLeaderboard(founds: 1)

            
        }
    }
    
    func updateBestTime(time: Double){
        if let oldBestTime = UserDefaults.standard.value(forKey: "bestTime") as? Double{
            
            print("OldBest Time: \(oldBestTime)")
            print("newTime: \(time)")
            
            ClicksViewController.saveBestTimeToLeaderboards(time: time)
            
            if(time < oldBestTime){
                UserDefaults.standard.setValue(time, forKey: "bestTime")
            }
            
        }else{
            UserDefaults.standard.setValue(time, forKey: "bestTime")
        }
    }
    
    func updateAverage(clicks: Int){
        
        var hitlerFound: Double = 0
        var totalClicks: Double = 0
        
        if let hitlerFoundSave = UserDefaults.standard.value(forKey: "totalFounds") as? Int{
            hitlerFound = Double(hitlerFoundSave)
        }
        
        if let totalClicksSave = UserDefaults.standard.value(forKey: "totalClicks") as? Int{
            totalClicks = Double(totalClicksSave)
        }
        
        ClicksViewController.saveAverageToLeaderboards(average: totalClicks/hitlerFound)
        
        UserDefaults.standard.setValue(totalClicks/hitlerFound, forKey: "average")

    }
    
    func checkLeastClicks(clicks: Int){
        if let oldLeast = UserDefaults.standard.value(forKey: "leastClicks") as? Int{
            
            ClicksViewController.saveLeastClicksToLeaderboards(clicks: clicks)

            
            if(oldLeast > clicks){
                UserDefaults.standard.setValue(clicks, forKey: "leastClicks")
                
            }
            
        }else{
            UserDefaults.standard.setValue(clicks, forKey: "leastClicks")
        }
    }
    
    
    // Leaderboard stuff
    
    static func saveLeastClicksToLeaderboards(clicks: Int){
        print("\nReporting Least clicks to Leaderboards")

        
        if GKLocalPlayer.localPlayer().isAuthenticated {
            
            let scoreReporter = GKScore(leaderboardIdentifier: "leastClicksToHitler_ID")
            
            scoreReporter.value = Int64(clicks)
            
            let scoreArray : [GKScore] = [scoreReporter]
            
            GKScore.report(scoreArray, withCompletionHandler: { (error) in
                
                if(error != nil){
                    print("Error in reporting score: \(error)")
                }else{
                    print("\nReporting Least clicks to Leaderboards - Done")
                }
                
                
            })
            
        }else{
            print("NOT AUTHENTICATED fewest clicks -> Leaderboards")
        }

        
        
        
    }
    
    static func saveAverageToLeaderboards(average: Double){
        print("\nReporting Average to Leaderboards")
        
        if GKLocalPlayer.localPlayer().isAuthenticated {
            
            let scoreReporter = GKScore(leaderboardIdentifier: "average_ID")
            
            var roundedAverage:Double = round(100*average)
            scoreReporter.value = Int64(roundedAverage)
            
            
            let scoreArray : [GKScore] = [scoreReporter]
            
            GKScore.report(scoreArray, withCompletionHandler: { (error) in
                
                if(error != nil){
                    print("Error in reporting  average to Leaderboards: \(error)")
                }else{
                    print("\nReporting Average to Leaderboards - Done")
                }
                
                
            })
            
        }else{
            print("NOT AUTHENTICATED average -> leaderboards")
        }

        
        
        
        
    }
    
    static func saveBestTimeToLeaderboards(time : Double){
        print("\nReporting bestTime to Leaderboards")

        
        if GKLocalPlayer.localPlayer().isAuthenticated {
            
            let scoreReporter = GKScore(leaderboardIdentifier: "shortestTime_ID")
            
            var bestTime:Double = round(100*time)
            scoreReporter.value = Int64(bestTime)
            
            
            let scoreArray : [GKScore] = [scoreReporter]
            
            GKScore.report(scoreArray, withCompletionHandler: { (error) in
                
                if(error != nil){
                    print("Error in reporting best time to Leaderboards: \(error)")
                }else{
                    print("\nReporting bestTime to Leaderboards - Done")
                }
                
                
            })
            
        }else{
            print("NOT AUTHENTICATED best time -> Leaderboards")
        }
        
        
    }
    
    static func saveFoundsLeaderboard(founds : Int){
        print("\nReporting Founds to Leaderboards")

        
        if GKLocalPlayer.localPlayer().isAuthenticated {
            
            let scoreReporter = GKScore(leaderboardIdentifier: "mostHitlersFound_ID")
            
            scoreReporter.value = Int64(founds)
            
            let scoreArray : [GKScore] = [scoreReporter]
            
            GKScore.report(scoreArray, withCompletionHandler: { (error) in
                
                if(error != nil){
                    print("\n\nError in reporting Founds to Leaderboards: \(error)")
                }else{
                    print("\nReporting Founds to Leaderboards - Done")
                }
                
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
        print("Gamecenter view was closed")
    }
    
    
    static func getTimeString(time: Double)-> String{
        
        
            var timeCopy:Double = time
        
            var hours = 0
            var minutes = 0
        
        
            while (timeCopy > 3600){
                hours += 1
                timeCopy = timeCopy - 3600
            }
            while(timeCopy > 60){
                minutes += 1
                timeCopy = timeCopy - 60
            }
                
                
        if(hours != 0){
            return "\(hours) hours \(minutes) min \(round(100*timeCopy)/100) sec"
        }else if(minutes != 0){
            return "\(minutes) min \(round(100*timeCopy)/100) sec"
        }else{
            return "\(round(100*timeCopy)/100) sec"
        }
    }
    
    // Check if there is better stats saved localy, otherwise we only upload the latest.
    static func updatingLeaderboardsFromDeviceSave(){
        
        if let totalFounds = UserDefaults.standard.value(forKey: "totalFounds") as? Int{
            saveFoundsLeaderboard(founds: totalFounds)
        }
        
        
        if let leastClicks = UserDefaults.standard.value(forKey: "leastClicks") as? Int{
            saveLeastClicksToLeaderboards(clicks: leastClicks)
        }
        
        
        if let average = UserDefaults.standard.value(forKey: "average") as? Double{
            saveAverageToLeaderboards(average: average)
        }
        
        
        if let bestTime = UserDefaults.standard.value(forKey: "bestTime") as? Double{
            saveBestTimeToLeaderboards(time: bestTime)
        }
    }
}
