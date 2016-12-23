//
//  StartViewController.swift
//  clicksToHitler
//
//  Created by Emil Söderlind on 2016-11-17.
//  Copyright © 2016 ENOS Pr. All rights reserved.
//

import UIKit
import CloudKit
import GameKit

class StartViewController: UIViewController, GKGameCenterControllerDelegate{
    
    @IBOutlet weak var hitlerStart: UIImageView!
    
    @IBOutlet weak var startText: UILabel!
    
    var animateAngle = 0.5
    var animateSpeed:Double = 1
    
    var loggedIn:Bool = true
    
    override func viewDidAppear(_ animated: Bool) {
        checkInternet()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(String(describing: currentReachabilityStatus) == "notReachable"){
            checkInternet()
        }else{
            print("Connected to internet.")
            StartViewController.downloadLatestWorldStats()
            authPlayer()
        }
        
        startText.text = "Clicks to Hitler is a Wikipedia race game with one simple goal, get to Adolf Hitler! \n\nYou are only allowed to click on the links. \n\nFind the shortest and fastest path to Adolf!"
        
        rotateHitlerPlus()
        
        // Do any additional setup after loading the view.
    }
    
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
    
    func rotateHitlerPlus(){
        
        UIView.animate(withDuration: animateSpeed, animations: {
                    self.hitlerStart.transform = CGAffineTransform(rotationAngle: CGFloat(self.animateAngle))
            },completion: { (b) in
                self.rotateHitlerMinus()
        })
        
    }
    
    func rotateHitlerMinus(){
        
        UIView.animate(withDuration: animateSpeed, animations: {
            self.hitlerStart.transform = CGAffineTransform(rotationAngle: -(CGFloat)(self.animateAngle))
            
        }, completion: { (b) in
            self.rotateHitlerPlus()
        })
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    static func downloadLatestWorldStats(){
        print("Download latest worldstats")

        
        
        let publicDB = CKContainer.default().publicCloudDatabase
        
        let greatID = CKRecordID(recordName: "worldwideStats")
        
        
        publicDB.fetch(withRecordID: greatID) { fetchedPlace, error in
            guard let fetchedPlace = fetchedPlace else {
                // handle errors here
                
                print("\n")
                print("Fetch (CloudKIt) error: \(error.debugDescription)")
                print("\n")
                
                if(error != nil){
                    print("NOT LOGGED IN TO iCLOUD?")
                }
                
                
                return
            }
            var totalClicks = fetchedPlace["totalClicks"]! as! Int
            var averageClicks = fetchedPlace["averageClicks"]! as! Double
            var bestTime = fetchedPlace["bestTime"]! as! Double
            var foundHitlerTimes = fetchedPlace["foundHitlerTimes"]! as! Int
            var leastClicks = fetchedPlace["leastClicks"]! as! Int
            
            print("world total clicks: \(totalClicks)")
            print("world average clicks: \(averageClicks)")
            print("world best time: \(bestTime)")
            print("world found hitler times: \(foundHitlerTimes)")
            print("world least clicks: \(leastClicks)")

            UserDefaults.standard.setValue(totalClicks, forKey: "worldTotalClicks")
            UserDefaults.standard.setValue(averageClicks, forKey: "worldAverageClicks")
            UserDefaults.standard.setValue(bestTime, forKey: "worldBestTime")
            UserDefaults.standard.setValue(foundHitlerTimes, forKey: "worldFoundHitlerTimes")
            UserDefaults.standard.setValue(leastClicks, forKey: "worldLeastClicks")
            
            print("Download latest worldstats - Done")
        }
        
    
        
        
        
        
        
        
        
        
    }
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func gameCenterButton(_ sender: Any) {
        print("Game center button pressed")
        
        var dateWhenPressed = Date()
        
        if(GKLocalPlayer.localPlayer().isAuthenticated){
            print("GC authenticated")
            showLeaderBoard()
        }else{
            DispatchQueue.global(qos: .background).async {
                while(!GKLocalPlayer.localPlayer().isAuthenticated){
                    print("Not yet authenticated")
                    
                    if(dateWhenPressed.timeIntervalSinceNow < -15){
                        print("Giving up showing leaderboards, fuck it.")
                        return
                    }
                }
                DispatchQueue.main.async {
                    if(GKLocalPlayer.localPlayer().isAuthenticated){
                        print("Authenticated!")
                        self.showLeaderBoard()
                    }else{
                        print("Giving up showing leaderboards, fuck it.")
                    }
                }
            }
        }
    }
    
    @IBAction func startButtonPushed(_ sender: Any) {
        
        tabBarController?.selectedIndex = 1

    }
    @IBAction func invisButton(_ sender: Any) {
        animateAngle = 20
        animateSpeed = 0.25
    }
    
    func authPlayer(){
        let localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {
            (view, error) in
            
            if view != nil {
                
                self.present(view!, animated: true, completion: nil)
                
            }
            else {
                
                print("----> Authenticated: \(GKLocalPlayer.localPlayer().isAuthenticated)")
                
                if(!GKLocalPlayer.localPlayer().isAuthenticated){
                    
                        print("Presenting \"plz loggin to iCloud & game center\"-screen")
                        
                        let alertController = UIAlertController(title: "iCloud & Game Center", message: "You need to be signed in to iCloud and Game Center to get leaderboards and worldwide statistics", preferredStyle: UIAlertControllerStyle.alert)
                        
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
                            
                            
                        }
                        
                        alertController.addAction(okAction)
                        
                        self.present(alertController, animated: true, completion: {
                            print("<Closed \"plz loggin to iCloud & game center\"-screen")
                        })
                    
                    
                } else {
                    ClicksViewController.updatingLeaderboardsFromDeviceSave()
                }
                
            }
            
        }
    }
    
    func resetLocalSave(){
        
        UserDefaults.standard.removeObject(forKey: "totalFounds")
        UserDefaults.standard.removeObject(forKey: "totalClicks")
        UserDefaults.standard.removeObject(forKey: "leastClicks")
        UserDefaults.standard.removeObject(forKey: "average")
        UserDefaults.standard.removeObject(forKey: "bestTime")

    }
    
    func showLeaderBoard(){
        let viewController = self.view.window?.rootViewController
        let gcvc = GKGameCenterViewController()
        
        gcvc.gameCenterDelegate = self
        
        viewController?.present(gcvc, animated: true, completion: nil)
        
    }
    
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        
        gameCenterViewController.dismiss(animated: true) { 
            
        }
        
    }
}
