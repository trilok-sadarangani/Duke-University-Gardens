//
//  JSONSwift.swift
//  DukeGardensApp
//
//  Created by Trilok Sadarangani on 11/12/2018.
//  Copyright © 2018 Richard Vargo. All rights reserved.
//

import Foundation
import Firebase

class JSONSwift : UIViewController {
    
    let url = Firebase(url:"")
    
    func downloadJSONWithURL() {
        let url = NSURL(string: urlString)
        URLSession.shared.dataTask(with: (url as? URL)!, completionHandler: {(data, response, error)-> Void in }).resume()
        
        
    }
    
    
    
    
}
