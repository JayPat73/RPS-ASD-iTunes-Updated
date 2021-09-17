//
//  Track.swift
//  iTunesUpdated
//
//  Created by lake on 10/6/18.
//  Copyright © 2018 Lake. All rights reserved.
//

import UIKit

public class Track: NSObject
{
    var name: String?
    var artist: String?
    var previewUrl: String?
    var Image: String?
    var genre: String?
    var explicit: String?
    var clearImage: String?
    var trackId: Int?


    //take some more data
    
    
    init(name: String?, artist: String?, previewUrl: String?, Image: String?, genre: String?, explicit: String?, clearImage: String?, trackId: Int?)
    {
        self.name = name
        self.artist = artist
        self.previewUrl = previewUrl
        self.Image = Image
        self.genre = genre
        self.explicit = explicit
        self.clearImage = clearImage
        self.trackId = trackId


    }

}
