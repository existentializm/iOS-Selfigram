//
//  FeedViewController.swift
//  MySelfiegram
//
//  Created by Daniel Mathews on 2015-11-05.
//  Copyright © 2015 Daniel Mathews. All rights reserved.
//

import UIKit
import Photos
import Parse

class FeedViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    var posts = [Post]()
    
    var words = ["Hello", "my", "name", "is", "Selfigram"]
    
    func getPosts() {
        if let query = Post.query() {
            query.order(byDescending: "createdAt")
            query.includeKey("user")
            query.findObjectsInBackground(block: { (posts, error) -> Void in
                
                if let posts = posts as? [Post]{
                    self.posts = posts
                    self.tableView.reloadData()
                    // remove the spinning circle if needed
                    self.refreshControl?.endRefreshing()
                }
                
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = UIImageView(image: UIImage(named: "Selfigram-logo"))
        
        getPosts()
        
    }
    
    
    @IBAction func doubleTappedSelfie(_ sender: UITapGestureRecognizer) {
        
        print("double tapped selfie")
        
        let tapLocation = sender.location(in: tableView)
        if let indexPathAtTapLocation = tableView.indexPathForRow(at: tapLocation){
            let cell = tableView.cellForRow(at: indexPathAtTapLocation) as! SelfieCell
            cell.tapAnimation()
        }
        
        
        
        
    }
    
    
    
    
    @IBAction func refreshPulled(_ sender: UIRefreshControl) {
        getPosts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! SelfieCell
        
        let post = self.posts[indexPath.row]
        
        cell.post = post
        
        return cell
    }
    
    @IBAction func cameraButtonPressed(_ sender: AnyObject) {
        
        // 1: Create an ImagePickerController
        let pickerController = UIImagePickerController()
        
        // 2: Self in this line refers to this View Controller
        //    Setting the Delegate Property means you want to receive a message
        //    from pickerController when a specific event is triggered.
        pickerController.delegate = self
        
        if TARGET_OS_SIMULATOR == 1 {
            // 3. We check if we are running on a Simulator
            //    If so, we pick a photo from the simulators Photo Library
            pickerController.sourceType = .photoLibrary
        } else {
            // 4. We check if we are running on am iPhone or iPad (ie: not a simulator)
            //    If so, we open up the pickerController's Camera (Front Camera)
            pickerController.sourceType = .camera
            pickerController.cameraDevice = .front
            pickerController.cameraCaptureMode = .photo
        }
        
        // Preset the pickerController on screen
        self.present(pickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // 1. When the delegate method is returned, it passes along a dictionary called info.
        //    This dictionary contains multiple things that maybe useful to us.
        //    We are getting the image picked from the UIImagePickerControllerOriginalImage key in that dictionary
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            // setting the compression quality to 90%
            if let imageData = UIImageJPEGRepresentation(image, 0.9),
                let imageFile = PFFile(data: imageData),
                let user = PFUser.current(){
                    
                    //2. We create a Post object from the image
                    let post = Post(image: imageFile, user: user, comment: "A Selfie")

                    post.saveInBackground(block: { (success, error) -> Void in
                        if success {
                            print("Post successfully saved in Parse")
                            
                            //3. Add post to our posts array, chose index 0 so that it will be added
                            //   to the top of your table instead of at the bottom (default behaviour)
                            self.posts.insert(post, at: 0)
                            
                            //4. Now that we have added a post, updating our table
                            //   We are just inserting our new Post instead of reloading our whole tableView
                            //   Both method would work, however, this gives us a cool animation for free
                            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                            
                        }
                    })
            }
        }
        
        //5. We remember to dismiss the Image Picker from our screen.
        dismiss(animated: true, completion: nil)
        
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
