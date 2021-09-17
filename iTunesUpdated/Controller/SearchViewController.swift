//
//  SearchViewController.swift
//  iTunesUpdated
//
//  Created by lake on 10/7/18.
//  Copyright © 2018 Lake. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
var player: AVAudioPlayer!
var audioStuffed = false

class SearchViewController: UITableViewController, URLSessionDelegate, URLSessionDownloadDelegate, UISearchBarDelegate, TrackTableViewCellDelegate
{
    var hasTrack = false
    var trackToPlay: Track?
    
    var activeDownloads = [String: Download]()
    var searchResults = [Track]()
   // @IBOutlet weak var isExplicitLab: UILabel?
    
    let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
    
    var dataTask: URLSessionDataTask?
    
    //search missing
    
    @IBOutlet weak var searchBar: UISearchBar!
    
  
    
    //Lazy instantiation - only make this when it is needed
    lazy var tapRecognizer: UITapGestureRecognizer =
    {
        var recognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        
        return recognizer

            
    }()
    
    //Lazy again
    
    lazy var downloadsSession: Foundation.URLSession =
    {
        let configuration = URLSessionConfiguration.background(withIdentifier: "bgSessionConfiguration")
        let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()
    
    @objc func dismissKeyBoard()
    {
        self.searchBar.resignFirstResponder()
       // self.localFilePathForURL("")
    }
    
    //Download Helper Methods
    func localFilePathForURL(_ previewURL: String) -> URL?
    {
        let documentsPath =
            NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        
        let url = URL(string: previewURL)
        let lastPathComponent = url?.lastPathComponent
        let fullPath =
        documentsPath.appendingPathComponent(lastPathComponent!)
        
        return URL(fileURLWithPath: fullPath)
        
    }
    
    func localFileExistsForTrack(_ track: Track) -> Bool
    {
        
        if let urlString = track.previewUrl, let localUrl = localFilePathForURL(urlString)
        {
            var isDir: ObjCBool = false
            let path = localUrl.path
            return FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
        }
        
    return false
    }
    
    func trackIndexForDownloadTask(_ downloadTask: URLSessionDownloadTask) -> Int?
    {
        
        if let url = downloadTask.originalRequest?.url?.absoluteString
        {
            for(index, track) in searchResults.enumerated()
            {
                if url == track.previewUrl
                {
                    return index
                }
            }
        }
        
        
    return nil
    }
    
    //DELEGATION - TOO MUCH!!!
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession)
    {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate
        {
            if let completionHandler = appDelegate.backgroundSessionCompletionHandler
            {
                appDelegate.backgroundSessionCompletionHandler = nil
                //grand cental dispatch - Queueup
                DispatchQueue.main.async(execute:
                {
                    completionHandler()
                })
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location:URL)
    {
        if let originalURL = downloadTask.originalRequest?.url?.absoluteString,
        let destinationURL = localFilePathForURL(originalURL)
        {
            print(destinationURL)
            
            let fileManager = FileManager.default
            do
            {
                try fileManager.removeItem(at: destinationURL)
            }
            catch
            {
                //file does not exist
            }
            
            do
            {
                try fileManager.copyItem(at: location, to: destinationURL)
            }
            catch let error as NSError
            {
                print(error.localizedDescription)
            }
        }
        
        if let url = downloadTask.originalRequest?.url?.absoluteString
        {
            activeDownloads[url] = nil
            
            if let trackIndex = trackIndexForDownloadTask(downloadTask)
            {
                DispatchQueue.main.async(execute:
                    
            {
                self.tableView.reloadRows(at: [IndexPath(row: trackIndex, section: 0)], with: .none)
            
            })
               
            }
            
            
        }
        
    }
    
    
   /* func urlSession(_ session:URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64)
    {
        
    }*/
    
    
//PROGRESS BAR
    

    func urlSession(_ session:URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    {
            //keeps track of the download and update the progress bar
        if let downloadUrl = downloadTask.originalRequest?.url?.absoluteString,
        let download = activeDownloads[downloadUrl]
        {
            download.progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
            
            let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: ByteCountFormatter.CountStyle.binary)
            
            
            if let trackIndex = trackIndexForDownloadTask(downloadTask)
            {
                DispatchQueue.main.async(execute:
                {
                    let trackCell = self.tableView.cellForRow(at: IndexPath(row: trackIndex, section: 0))
                    as? TrackTableViewCell
                    
                    
                    trackCell?.progressView.progress = download.progress
                    print(String(format: "%.1f%% of %@", download.progress*100, totalSize))
                        
                })
                
                
            }
        }
    }
    
    /*
    
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask)
    {
        print("Session Timed Out!")
    }*/
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        self.dismissKeyBoard()
        if !searchBar.text!.isEmpty
        {
            if dataTask != nil
            {
                print("nil")
                dataTask?.cancel()
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            let expectedCharSet = CharacterSet.urlQueryAllowed
            let searchTerm = searchBar.text!.addingPercentEncoding(withAllowedCharacters: expectedCharSet)!
            
            
            let url = URL(string: "https://itunes.apple.com/search?term=\(searchTerm)")
        
            dataTask = defaultSession.dataTask(with: url!, completionHandler:
                { data, response, error in
                
                    DispatchQueue.main.async
                    {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        
                    }
                    
                    if let e = error
                    {
                        print(e.localizedDescription)
                    }
                    else if let httpResponse = response as? HTTPURLResponse
                    {
                        if httpResponse.statusCode == 200
                        {
                            self.updateSearchResults(data)
                            //MAKE!
                        }
                        /*else if httpsReponse.statusCode == 400
                        {
                            
                        }*/
                    }
            })
            
            dataTask?.resume()
        }
        
    
        
    }
    
    
   //TrackTableViewCellDelegate our delegate methods

    func cancelTapped(_ cell: TrackTableViewCell)
    {
        if let indexPath = tableView.indexPath(for: cell)
        {
            let track = searchResults[(indexPath as NSIndexPath).row]
            self.trackToPlay = searchResults[(indexPath as NSIndexPath).row]
           cancelDownload(track) //make method
            tableView.reloadRows(at: [IndexPath(row: (indexPath as NSIndexPath).row, section: 0)], with: .none)
        }
    }
    
    
    
    
 
    func downloadTapped(_ cell: TrackTableViewCell)
    {
        if let indexPath = tableView.indexPath(for: cell)
        {

            
            let track = searchResults[(indexPath as NSIndexPath).row]
            self.trackToPlay = searchResults[(indexPath as NSIndexPath).row]
           startDownload(track) //make method
            tableView.reloadRows(at: [IndexPath(row: (indexPath as NSIndexPath).row, section: 0)], with: .none)
            
        } 
    }
    
    //Table View Delegate Methods
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 110.0 //depends on how mabnt things on your cell
    }
    
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let track = searchResults[indexPath.row]
        self.trackToPlay = searchResults[(indexPath as NSIndexPath).row]
        
        if localFileExistsForTrack(track)
        {
            playDownload(track)
            //segue
            self.hasTrack = true
            self.trackToPlay = track
        
        }
        
        
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        
     
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell", for: indexPath) as! TrackTableViewCell
        cell.delegate = self
        let track = searchResults[indexPath.row]
        self.trackToPlay = searchResults[(indexPath as NSIndexPath).row]
        cell.titleLabel.text = track.name
        cell.artistLabel.text = track.artist
        
        cell.genreLabel.text = track.genre
        cell.albumArtwork.downloaded(from: track.Image!)
        cell.explicitnessLabel.text = track.explicit
        
        
        //downloaded
        var showDownloadControls = false
        if let download = activeDownloads[track.previewUrl!]
        {
            showDownloadControls = true
            cell.progressView.progress = download.progress
        }
        let downloaded = localFileExistsForTrack(track) //if you have the file already, hide the download button....
        
        //ternary oprator (true ... false)
        cell.selectionStyle = downloaded ? UITableViewCell.SelectionStyle.gray: UITableViewCell.SelectionStyle.none
        // IF STATEMENT! (cuts down lines of code!)
        // if downloaded, if its true, then the selectionstyle is gray, if its false then there is no selection style
        cell.progressView.isHidden = !showDownloadControls
        cell.downloadButton.isHidden = downloaded || showDownloadControls
        cell.cancelButton.isHidden = !showDownloadControls
        
        return cell
    }

    
    
    //View Controller Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        searchBar.delegate = self
        _ = self.downloadsSession
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition
    {
        return .topAttached
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        view.addGestureRecognizer(tapRecognizer)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
    {
        view.removeGestureRecognizer(tapRecognizer)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == ""
        {
            self.searchResults.removeAll()
            self.tableView.reloadData()
        }
    }
    
    
    //connectivity
    /* func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask)
    {
        print("Session timed out!")
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?)
    {
     
    }*/
    
    //helper methods to update the search results and parse the JSON yah yeet yah
    func updateSearchResults(_ data: Data?)
    {
        //start: anything we have from the previous results, get rid of it
        searchResults.removeAll()
        do
        {
        //how to write a try and catch -- currently lost...
    if let data = data, let response = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: AnyObject]
    {
        if let array: AnyObject = response["results"]
        {
            // i lit rally dont know what this means
            for trackDictionary in array as! [AnyObject]
            {
        if let trackDictionary = trackDictionary as? [String: AnyObject], let previewUrl = trackDictionary["previewUrl"] as? String
        {
            let name = trackDictionary["trackName"] as? String //track names are exact. Ex: "An1k3t"
            let artist = trackDictionary["artistName"] as? String
            
            let trackExplicitness = trackDictionary["trackExplicitness"] as? String
            let genre = trackDictionary["primaryGenreName"] as? String
            let explicit = trackDictionary["trackExplicitness"] as? String
            let trackId = trackDictionary["trackId"] as? Int
            /*if trackExplicitness == "notExplicit"
            {
             
               
            }
            else
            {
   
            }*/
            let clearImage = trackDictionary["artworkUrl100"] as? String
        
            let Image = trackDictionary["artworkUrl100"] as? String
            
            
           var includeExplicit = false
            DispatchQueue.main.async
            {
                
            
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate
                           {
                            includeExplicit = appDelegate.hasExplicit
                            if(includeExplicit)
                            {
                            
                                
                             
                                self.searchResults.append(Track(name: name, artist: artist, previewUrl: previewUrl, Image: Image, genre: genre, explicit: explicit, clearImage: clearImage, trackId: trackId))
                            }
                            else
                            {
                                if trackExplicitness == "notExplicit"
                                {
                                   
                            
                             
                           
                                    self.searchResults.append(Track(name: name, artist: artist, previewUrl: previewUrl, Image: Image, genre: genre, explicit: explicit, clearImage: clearImage, trackId: trackId))
                                }
                                
                            }
                            
                                          
                           }
                
            }

            
           
            //searchResults.append(Track(name: name, artist: artist, previewUrl: previewUrl, Image: Image))
                }
            }
            
        }
        
    }
        }
        catch let error as NSError
        {
            //say something is wrong
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.async
        {
            
            self.tableView.reloadData()
            self.tableView.setContentOffset(CGPoint.zero, animated: false)
        }
    }
    
    func startDownload(_ track: Track)
    {
        if let urlString = track.previewUrl, let url = URL(string: urlString)
        {
            let download = Download(url: urlString)
            download.downloadTask = downloadsSession.downloadTask(with: url)
            download.downloadTask?.resume()
            download.isDownloading = true
            activeDownloads[download.url] = download
        }
    }
    
    func cancelDownload(_ track: Track)
    {
        if let urlString = track.previewUrl,
                let download = activeDownloads[urlString]
            {
                download.downloadTask?.cancel()
                activeDownloads[urlString] = nil
            }
        
    }
    
    func playDownload(_ track: Track)
    {
    
        
        
    if let urlString = track.previewUrl, let url = localFilePathForURL(urlString)
       {
    
        
            /*
            let player = AVPlayer(url: url)
            print(url)
            let playerViewController = AVPlayerViewController() //can change
            playerViewController.player = player
            self.present(playerViewController, animated: true)
            {
                playerViewController.player!.play()
            }*/
            
        
        //if let path = Bundle.main.path(forResource: "TryAgainWav", ofType: ".m4a") {
        do
        {
            //player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            player = try AVAudioPlayer(contentsOf: url)
            
            player.play()
            audioStuffed = true
        } catch
        {
            print( "Could not find file")
        }
            
        }
          
        
        
            
            
            
        
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let controller = segue.destination as! CharacteristicViewController
        controller.trackToPlay = self.trackToPlay
    }
    
   
    
    
} //class end

