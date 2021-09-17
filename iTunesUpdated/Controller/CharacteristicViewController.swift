//
//  CharacteristicViewController.swift
//  iTunesUpdated
//
//  Created by Jay Patel on 12/9/19.
//  Copyright © 2019 Lake. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import FirebaseDatabase

class CharacteristicViewController: UIViewController
{
    var trackToPlay: Track?
    var searchResults = [Track]()
    var ref: DatabaseReference?
    var DatabaseHandle: DatabaseHandle?
    var likeCounter = 0.0
    var dislikeCounter = 0.0

 @IBOutlet weak var AlbumPicture: UIImageView!
    @IBOutlet weak var ArtistNameLabel: UILabel!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    @IBOutlet weak var ratingsLabel: UILabel!
    
 
    @IBAction func UpButtonClicked(_ sender: Any)
    {
   
        likeCounter += 1
      
    writeToDatbase()
     
        
       
     //  (sender as? UIButton)?.isEnabled = false
       // downButton.isEnabled = false
        
   
        let ratingString = self.likeCounter/(self.dislikeCounter+self.likeCounter) * 100
        let average = Double(round(ratingString*1000)/1000)
        let real = String(average)
        
      
        
       
        
                      
        self.ratingsLabel.text = real + "% of listeners liked this song"
    
                  
  
        readFromDatabase()
        let manager = PListManager.sharedInstance
                manager.writeToDocumentsDirectoryPlist(namePlist: "SongsPlist",
                                                       key: (trackToPlay?.name!)!,
                                                       data: (["Song Name": (trackToPlay?.name!)!, "Artist": (trackToPlay?.artist!)!, "LikeCounter": likeCounter, "DislikeCounter": dislikeCounter]))
              
                    let obj =  manager.readFromDocumentsDirectoryPlist(namePlist:
                        "SongsPlist", key: "Root")
                    print(obj)

             
                 let test = manager.readMainBundlePList(namePList: "SongsPlist")
                 print(test)
      
      
    }
    
    
    @IBAction func DislikeButtonClicked(_ sender: Any)
    {

        dislikeCounter += 1

     writeToDatbase()
      
                
       
        
           let ratingString = self.likeCounter/(self.dislikeCounter+self.likeCounter) * 100
              let average = Double(round(ratingString*1000)/1000)
              let real = String(average)
              
            
              
             
              
                            
              self.ratingsLabel.text = real + "% of listeners liked this song"
          
                   
      //  (sender as? UIButton)?.isEnabled = false
      // upButton.isEnabled = false
       
        readFromDatabase()
        let manager = PListManager.sharedInstance
                         manager.writeToDocumentsDirectoryPlist(namePlist: "SongsPlist",
                                                                key: (trackToPlay?.name!)!,
                                                                data: (["Song Name": (trackToPlay?.name!)!, "Artist": (trackToPlay?.artist!)!, "LikeCounter": likeCounter, "DislikeCounter": dislikeCounter]))
               
               let obj =  manager.readFromDocumentsDirectoryPlist(namePlist:
                          "SongsPlist", key: "Root")


               
                   let test = manager.readMainBundlePList(namePList: "SongsPlist")

               
    
               
    }

    
    
    
    @IBAction func slider(_ sender: UISlider)
    {
        if audioStuffed == true
        {
            player.volume = sender.value
        }
    }
    
    
    @IBAction func playButton(_ sender: UIButton)
    {
       if audioStuffed == true && player.isPlaying == false
        {

          player.play()
        }
        
    }
    @IBAction func pauseButton(_ sender: UIButton)
    {
       
               if audioStuffed == true && player.isPlaying
               {

                   player.pause()
               }
           
        
    }
    
    override func viewDidLoad()
    {
  
               super.viewDidLoad()
      
    ArtistNameLabel.text = "Artist: " + (trackToPlay?.artist!)!
    songNameLabel.text = "Song: " + (trackToPlay?.name!)!
        genreLabel.text = "Genre: " + (trackToPlay?.genre!)!
        
      
        
        AlbumPicture.downloaded(from: (trackToPlay?.Image!)!)
         
        if Reachability.isConnectedToNetwork()
        {
               readFromDatabase()
        }
        else
        {
            readFromPList()
        }
       

        
        
        
               
        
       
      
        // Do any additional setup after loading the view.
    }
    
    public func writeToDatbase()
    {
 
        

        self.ref = Database.database().reference()
        self.ref?.child((trackToPlay?.name!)!).setValue(["Song Name": (trackToPlay?.name!)!, "Artist": (trackToPlay?.artist!)!, "LikeCounter": likeCounter, "DislikeCounter": dislikeCounter] as NSDictionary)
   
        
      
    }
    
    public func readFromPList()
    {
        let manager = PListManager.sharedInstance
        let likes = (manager.readFromDocumentsDirectoryPlist(namePlist: "SongsPlist", key: (trackToPlay?.name!)!) as! NSDictionary).object(forKey: "LikeCounter") as! Double
        self.likeCounter = likes
        let disLikes = (manager.readFromDocumentsDirectoryPlist(namePlist: "SongsPlist", key: (trackToPlay?.name!)!) as! NSDictionary).object(forKey: "DislikeCounter") as! Double
        self.dislikeCounter = disLikes
               
    }
    
    public func readFromDatabase()
    {
        
        self.ref = Database.database().reference(withPath: ((trackToPlay?.name!)!))
        
      
        
        self.ref?.observeSingleEvent(of: .value, with: {snapshot in
            
            if !snapshot.exists() {return}
          
            print(snapshot.value!)
            
            let dict = snapshot.value! as? NSDictionary
                  
            let likes = dict?.object(forKey: "LikeCounter") as? Double
            self.likeCounter = likes!
            let dislikes = dict?.object(forKey: "DislikeCounter") as? Double
            self.dislikeCounter = dislikes!
          
            let manager = PListManager.sharedInstance
                            manager.writeToDocumentsDirectoryPlist(namePlist: "SongsPlist",
                                                                   key: "Root",
                                                                   data: snapshot.value as! NSMutableDictionary)
                   
        })
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
