//
//  StatsViewController.swift
//  clicksToHitler
//
//  Created by Emil Söderlind on 2016-12-16.
//  Copyright © 2016 ENOS Pr. All rights reserved.
//

import UIKit

class StatsViewController: UITableViewController {
    
    struct Stats {
        var averageClicks: String
        var totalClicks: String
        var foundHitlerTimes: String
        var leastClicks: String
        var bestTime:String
    }
    
    
    var userStats = Stats(averageClicks: "Loading..", totalClicks: "Loading..", foundHitlerTimes: "Loading..", leastClicks: "Loading..", bestTime: "Loading..")
    
    var worldwideStats = Stats(averageClicks: "Loading..", totalClicks: "Loading..", foundHitlerTimes: "Loading..", leastClicks: "Loading..", bestTime: "Loading..")
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        checkInternet()
        populateTable()
        self.reloadTableView(self.tableView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func populateTable(){
        
        
        
        loadUserStats()
        loadWorldstats()
        
        
    }
    
    func loadWorldstats(){
        
        
        if let worldTotalClicks = UserDefaults.standard.value(forKey: "leastClicks") as? Int{
            self.worldwideStats.totalClicks = String(describing: worldTotalClicks)

        }
        if let worldAverageClicks = UserDefaults.standard.value(forKey: "worldAverageClicks") as? Double{
            self.worldwideStats.averageClicks = "\(round(Double(100*worldAverageClicks))/100)"
            
        }
        if let worldBestTime = UserDefaults.standard.value(forKey: "worldBestTime") as? Int{
            self.worldwideStats.bestTime = "\(worldBestTime) s"
        }
        if let worldFoundHitlerTimes = UserDefaults.standard.value(forKey: "worldFoundHitlerTimes") as? Int{
            self.worldwideStats.foundHitlerTimes = "\(worldFoundHitlerTimes)"
        }
        if let worldLeastClicks = UserDefaults.standard.value(forKey: "worldLeastClicks") as? Int{
            self.worldwideStats.leastClicks = "\(worldLeastClicks)"
            
        }
        
        
    }
    
    func reloadTableView(_ tableView: UITableView) {
        let contentOffset = tableView.contentOffset
        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableView.setContentOffset(contentOffset, animated: false)
    }
    
    func loadUserStats(){
        
        
        // Total clicks
        
        loadTotalClicks()
        loadTotalHitlerFounds()
        loadLeastClicks()
        loadAverageClicks()
        loadBestTime()
        
    }
    
    
    func loadTotalClicks(){
        if let totalClicks = UserDefaults.standard.value(forKey: "totalClicks") as? Int{
            print("Found total-click-save on device")
            userStats.totalClicks = "\(totalClicks)"
        }else{
            print("No total-click-save on device")
            userStats.totalClicks = "Never clicked"
        }
    }
    
    func loadTotalHitlerFounds(){
        if let totalFounds = UserDefaults.standard.value(forKey: "totalFounds") as? Int{
            print("Found total-found-save on device")
            userStats.foundHitlerTimes = "\(totalFounds)"
        }else{
            print("No total-found-save on device")
            userStats.foundHitlerTimes = "Never found"
        }
    }
    
    func loadLeastClicks(){
        if let leastClicks = UserDefaults.standard.value(forKey: "leastClicks") as? Int{
            userStats.leastClicks = "\(leastClicks)"
        }else{
            userStats.leastClicks = "Never found"
        }
    }
    
    func loadAverageClicks(){
        if let average = UserDefaults.standard.value(forKey: "average") as? Double{
            userStats.averageClicks = "\(round(100*average)/100)"
        }else{
            userStats.averageClicks = "Never found"
        }
    }
    
    func loadBestTime(){
        if let bestTime = UserDefaults.standard.value(forKey: "bestTime") as? Double{
            userStats.bestTime = "\(round(100*bestTime)/100) s"
        }else{
            userStats.bestTime = "Never found"
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if (section == 0){
            return "Your stats"
        }
        if (section == 1){
            return "Worldwide stats"
        }
        
        return "Someting went wrong.."
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
        
        

        return configCell(cell: cell, row:indexPath.row, section: indexPath.section)
    }
    
    func configCell(cell: UITableViewCell, row: Int, section: Int)-> UITableViewCell{
        
        if(section == 0){
        
            switch row {
            case 0:
                cell.textLabel?.text = "Best time"
                cell.detailTextLabel?.text = "\(userStats.bestTime)"
                break
            case 2:
                cell.textLabel?.text = "Average clicks"
                cell.detailTextLabel?.text = "\(userStats.averageClicks)"
                break
            case 1:
                cell.textLabel?.text = "Least clicks"
                cell.detailTextLabel?.text = "\(userStats.leastClicks)"
                break
            case 3:
                cell.textLabel?.text = "Times found Hitler"
                cell.detailTextLabel?.text = "\(userStats.foundHitlerTimes)"
                break
            case 4:
                cell.textLabel?.text = "Total clicks"
                cell.detailTextLabel?.text = "\(userStats.totalClicks)"
                break
            default: break
            }
        }else if(section == 1){
            
            switch row {
            case 0:
                cell.textLabel?.text = "Best time"
                cell.detailTextLabel?.text = "\(worldwideStats.bestTime)"
                break
            case 2:
                cell.textLabel?.text = "Average clicks"
                cell.detailTextLabel?.text = "\(worldwideStats.averageClicks)"
                break
            case 1:
                cell.textLabel?.text = "Least clicks"
                cell.detailTextLabel?.text = "\(worldwideStats.leastClicks)"
                break
            case 3:
                cell.textLabel?.text = "Times found Hitler"
                cell.detailTextLabel?.text = "\(worldwideStats.foundHitlerTimes)"
                break
            case 4:
                cell.textLabel?.text = "Total clicks"
                cell.detailTextLabel?.text = "\(worldwideStats.totalClicks)"
                break
            default: break
            }
        }
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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

}
