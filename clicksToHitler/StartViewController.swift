//
//  StartViewController.swift
//  clicksToHitler
//
//  Created by Emil Söderlind on 2016-11-17.
//  Copyright © 2016 ENOS Pr. All rights reserved.
//

import UIKit
import CloudKit

class StartViewController: UIViewController{
    
    @IBOutlet weak var hitlerStart: UIImageView!
    
    @IBOutlet weak var startText: UILabel!
    
    var animateAngle = 0.5
    var animateSpeed:Double = 1
    
    
    override func viewDidAppear(_ animated: Bool) {
        checkInternet()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(String(describing: currentReachabilityStatus) == "notReachable"){
            checkInternet()
        }else{
            print("Connected to internet.")
            downloadLatestWorldStats()
        }
        
        startText.text = "Clicks to Hitler is a Wikipedia race game with one simple goal, get to Adolf Hitler! \n\nYou are only allowed to click on the links. \n\nFind the shortest and fastest path to Adolf!"
        
        rotateHitlerPlus()
        
        /*tableView.delegate = self
        tableView.dataSource = self*/
        
        
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
    
    
    /*func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        
        
        if(indexPath.row == 0){
            cell?.textLabel?.text = "Least clicks to Hitler"
            cell?.detailTextLabel?.text = "2"
        }else if(indexPath.row == 1){
            cell?.textLabel?.text = "Average clicks to Hitler"
            cell?.detailTextLabel?.text = "4.67"
        }else if(indexPath.row == 2){
            cell?.textLabel?.text = "Total number of clicks"
            cell?.detailTextLabel?.text = "3435"
        }else if(indexPath.row == 3){
            cell?.textLabel?.text = "Times found Hitler"
            cell?.detailTextLabel?.text = "22"
        }
        
        return cell!
    }*/
    
    
    
    /*override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell

        
        cell.textLabel?.text = "Number Of Clicks"
        cell.detailTextLabel?.text = "3345"
        
        
        return cell
    }*/
    
    

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
    
    }
    
    
    
    @IBAction func startButtonPushed(_ sender: Any) {
        
        tabBarController?.selectedIndex = 1

    }
    @IBAction func invisButton(_ sender: Any) {
        animateAngle = 20
        animateSpeed = 0.25
    }

}
