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
    
    
    var userStats = Stats(averageClicks: "No data..", totalClicks: "No data..", foundHitlerTimes: "No data..", leastClicks: "No data..", bestTime: "No data..")
    
    var worldwideStats = Stats(averageClicks: "Sign in to iCloud", totalClicks: "Sign in to iCloud", foundHitlerTimes: "Sign in to iCloud", leastClicks: "Sign in to iCloud", bestTime: "Sign in to iCloud")
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        checkInternet()
        populateTable()
        self.reloadTableView(self.tableView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
                
        populateTable()

    }
    
    func populateTable(){
        print("Populating table")
        
        loadWorldstats()

        loadUserStats()
        
        print("Populating table - Done")

    }
    
    func loadWorldstats(){
        print("Loading worldstats")
        
        if(UserDefaults.standard.integer(forKey: "worldTotalClicks") != 0){
            self.worldwideStats.totalClicks = "\(UserDefaults.standard.integer(forKey: "worldTotalClicks"))"
            self.worldwideStats.averageClicks = "\(round(100*UserDefaults.standard.double(forKey: "worldAverageClicks"))/100)"
            self.worldwideStats.bestTime = "\(round(100*UserDefaults.standard.double(forKey: "worldBestTime"))/100) s"
            self.worldwideStats.foundHitlerTimes = "\(UserDefaults.standard.integer(forKey: "worldFoundHitlerTimes"))"
            self.worldwideStats.leastClicks = "\(UserDefaults.standard.integer(forKey: "worldLeastClicks"))"
        
            reloadTableView(self.tableView)
            print("Loading worldstats - Done")
        }else{
            print("Could not get worldwide stats. Not logged in?")
        }
        
    }
    
    func reloadTableView(_ tableView: UITableView) {
        let contentOffset = tableView.contentOffset
        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableView.setContentOffset(contentOffset, animated: false)
    }
    
    func loadUserStats(){
        print("Loading user stats")
        
        // Total clicks
        
        loadTotalClicks()
        loadTotalHitlerFounds()
        loadLeastClicks()
        loadAverageClicks()
        loadBestTime()
        print("Loading user stats - Done")

    }
    
    
    func loadTotalClicks(){
        if let totalClicks = UserDefaults.standard.value(forKey: "totalClicks") as? Int{
            print("Found total-click-save on device")
            userStats.totalClicks = "\(totalClicks)"
        }
    }
    
    func loadTotalHitlerFounds(){
        if let totalFounds = UserDefaults.standard.value(forKey: "totalFounds") as? Int{
            print("Found total-found-save on device")
            userStats.foundHitlerTimes = "\(totalFounds)"
        }
    }
    
    func loadLeastClicks(){
        if let leastClicks = UserDefaults.standard.value(forKey: "leastClicks") as? Int{
            userStats.leastClicks = "\(leastClicks)"
        }
    }
    
    func loadAverageClicks(){
        if let average = UserDefaults.standard.value(forKey: "average") as? Double{
            userStats.averageClicks = "\(round(100*average)/100)"
        }
    }
    
    func loadBestTime(){
        if let bestTime = UserDefaults.standard.value(forKey: "bestTime") as? Double{
            userStats.bestTime = "\(round(100*bestTime)/100) s"
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
                cell.textLabel?.text = "Fewest clicks"
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
                cell.textLabel?.text = "Fewest clicks"
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
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
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
