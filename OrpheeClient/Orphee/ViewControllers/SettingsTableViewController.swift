//
//  SettingsTableViewController.swift
//  Orphee
//
//  Created by Jeromin Lebon on 04/09/2015.
//  Copyright © 2015 __ORPHEE__. All rights reserved.
//

import Foundation
import UIKit
import RSKImageCropper

class SettingsTableViewController: UITableViewController {
//    var user: User!
//    @IBOutlet var imgProfile: UIImageView!
//    var imgProfileCropped = UIImageView()
//    let imagePicker = UIImagePickerController()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        imagePicker.delegate = self
//        if let data = NSUserDefaults.standardUserDefaults().objectForKey("myUser") as? NSData {
//            self.user = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! User
//            self.imgProfile.layer.cornerRadius = self.imgProfile.frame.width / 2
//            if let picture = self.user.picture{
//                self.imgProfile.sd_setImageWithURL(NSURL(string: picture), placeholderImage: UIImage(named: "emptygrayprofile"))
//            }else{
//                self.imgProfile.image = UIImage(named: "emptygrayprofile")
//            }
//        }
//    }
//    
//    @IBAction func disconnect(sender: UIButton){
//        NSUserDefaults.standardUserDefaults().removeObjectForKey("myUser")
//    }
//    
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        if (indexPath.row == 0){
//            let optionMenu = UIAlertController(title: nil, message: "D'où voulez-vous prendre votre image ?", preferredStyle: UIAlertControllerStyle.ActionSheet)
//            let photoLibraryOption = UIAlertAction(title: "Pellicule", style: UIAlertActionStyle.Default, handler: { (alert: UIAlertAction!) -> Void in
//                print("from library")
//                self.imagePicker.allowsEditing = false
//                self.imagePicker.sourceType = .PhotoLibrary
//                self.imagePicker.modalPresentationStyle = .Popover
//                self.presentViewController(self.imagePicker, animated: true, completion: nil)
//            })
//            let cameraOption = UIAlertAction(title: "Prendre une photo", style: UIAlertActionStyle.Default, handler: { (alert: UIAlertAction!) -> Void in
//                print("take a photo")
//                self.imagePicker.allowsEditing = false
//                self.imagePicker.sourceType = .Camera
//                self.imagePicker.modalPresentationStyle = .Popover
//                self.presentViewController(self.imagePicker, animated: true, completion: nil)
//                
//            })
//            let cancelOption = UIAlertAction(title: "Annuler", style: UIAlertActionStyle.Cancel, handler: {
//                (alert: UIAlertAction!) -> Void in
//                print("Cancel")
//                self.dismissViewControllerAnimated(true, completion: nil)
//            })
//            
//            optionMenu.addAction(photoLibraryOption)
//            optionMenu.addAction(cancelOption)
//            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) == true {
//                optionMenu.addAction(cameraOption)} else {
//                print ("I don't have a camera.")
//            }
//            
//            self.presentViewController(optionMenu, animated: true, completion: nil)
//            
//        }
//    }
//}
//
//extension SettingsTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
//        print("finished picking image")
//    }
//    
//    
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        print("imagePickerController called")
//        
//        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
//        let view = RSKImageCropViewController(image: chosenImage)
//        view.delegate = self
//        self.navigationController?.pushViewController(view, animated: true)
//        dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
//        dismissViewControllerAnimated(true, completion: nil)
//    }
//}
//
//extension SettingsTableViewController: RSKImageCropViewControllerDelegate{
//    func imageCropViewControllerDidCancelCrop(controller: RSKImageCropViewController) {
//        self.navigationController?.popViewControllerAnimated(true)
//    }
//    
//    func imageCropViewController(controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
//        self.imgProfileCropped.image = croppedImage
//        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
//        let destinationPath = documentsPath.stringByAppendingPathComponent("imgProfile.png")
//        UIImageJPEGRepresentation(croppedImage,0.25)!.writeToFile(destinationPath, atomically: true)
//        OrpheeApi().sendImgToServer(user.token, id: user.id, completion: {(response) in
//            print(response)
//        })
//        self.navigationController?.popViewControllerAnimated(true)
//    }
//    
//    func imageCropViewController(controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
//        self.imgProfileCropped.image = croppedImage
//        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
//        let destinationPath = documentsPath.stringByAppendingPathComponent("imgProfile.png")
//        UIImageJPEGRepresentation(croppedImage,0.25)!.writeToFile(destinationPath, atomically: true)
//        OrpheeApi().sendImgToServer(user.token, id: user.id, completion: {(response) in
//            print(response)
//        })
//
//        self.navigationController?.popViewControllerAnimated(true)
//    }
//    
//    func imageCropViewController(controller: RSKImageCropViewController, willCropImage originalImage: UIImage) {
//        print("crop")
//    }
}