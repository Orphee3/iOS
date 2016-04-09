//
//  CreationsListVC.swift
//  Orphee
//
//  Created by Massil on 10/09/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import UIKit
import FileManagement

/** CreationsListVC subclasses UITableViewController

*/
class CreationsListVC : UITableViewController {
    var creations: [String]!
    weak var mainVC: pCreationListActor!;

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
        creations = try! PathManager.listFiles(kOrpheeFile_store, fileExtension: kOrpheeFile_extension);
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return creations.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        cell.textLabel?.text = creations[indexPath.row];
        return cell;
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let creation = creations[indexPath.row]
        mainVC.actOnSelectedCreation(creation)
        self.navigationController!.popViewControllerAnimated(true);
    }
}
