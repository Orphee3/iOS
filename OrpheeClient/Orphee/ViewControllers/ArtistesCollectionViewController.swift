//
//  ArtistesCollectionViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 28/02/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit

class ArtisteCollectionViewController: UICollectionViewController {
    var arrayUsers: [User] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        OrpheeApi().getUsers(0, size: 100) { (users) in
            for elem in users{
                do {
                    let user = try User.decode(elem)
                    self.arrayUsers.append(user)
                } catch let error {
                    print(error)
                }
            }
            self.collectionView?.reloadData()
        }
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (!arrayUsers.isEmpty){
            print(arrayUsers.count)
            return arrayUsers.count
        }
        return 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ArtistesCollectionViewCell", forIndexPath: indexPath) as? ArtistesCollectionViewCell{
            cell.fillCell(arrayUsers[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("toDetailsUser", sender: indexPath.row)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "toDetailsUser"){
            if let controller = segue.destinationViewController as? UserTableViewController{
                controller.id = arrayUsers[sender as! Int].id
                controller.user = arrayUsers[sender as! Int]
            }
        }
    }
}