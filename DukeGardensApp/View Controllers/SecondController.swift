//
//  SecondController.swift
//  DukeGardensApp
//
//  Created by Trilok Sadarangani on 13/12/2018.
//  Copyright © 2018 Richard Vargo. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase



class SecondController: UIViewController {
    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var blomqTLabel: UILabel!
    @IBOutlet weak var culbTLabel: UILabel!
    @IBOutlet weak var dorisTLabel: UILabel!
    @IBOutlet weak var historicTLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extractPosts()
        
    }
    func extractPosts()
    {
        
        var current = 0
        var blomqT = [String]()
        var culbT = [String]()
        var dorisT = [String]()
        var historicT = [String]()
        
        let ref = Database.database().reference().child("posts")
        ref.observe(.value, with: { snapshot in
            if (snapshot.value is NSNull ) {
                print("No Data")
            } else {
                
                for child in (snapshot.children) {
                    
                    let g = (snapshot.childrenCount)
                    
                    let yo = (g - 1)
                    
                    
                    
                    
                    let snap = child as! DataSnapshot
                    let dict = snap.value as! NSDictionary
                    let date = dict["date"]! as! String
                    
                    
                    var year = String(date.prefix(4))
                    
                    let start = date.index(date.startIndex, offsetBy: 5)
                    let end = date.index(date.endIndex, offsetBy: -3)
                    let range = start..<end
                    var month = String(date[range])
                    
                    let start2 = date.index(date.startIndex, offsetBy: 8)
                    let end2 = date.index(date.endIndex, offsetBy: 0)
                    let range2 = start2..<end2
                    var day = String(date[range2])
                    
                    let DATE = day + "/" + month + "/" + year
                    
                    let blom = dict["blomqT"] as! NSArray
                    let culb = dict["culbT"] as! NSArray
                    let doris = dict["dorisT"] as! NSArray
                    let hist = dict["historicT"] as! NSArray
                    
                    if current == yo {
                        
                        for b in blom {
                            let a = b as! [String:String]
                            blomqT.append(a["plant"]!)
                        }
                        let joined_blom = blomqT.joined(separator: ",")
                        for c in culb {
                            let a = c as! [String:String]
                            culbT.append(a["plant"]!)
                        }
                        let joined_culb = culbT.joined(separator: ",")
                        for d in doris {
                            let a = d as! [String:String]
                            dorisT.append(a["plant"]!)
                        }
                        let joined_doris = dorisT.joined(separator: ",")
                        for h in hist {
                            let a = h as! [String:String]
                            historicT.append(a["plant"]!)
                        }
                        let joined_hist = historicT.joined(separator: ",")
                        
                        self.dateLabel.text = DATE
                        self.blomqTLabel.text = joined_blom
                        self.culbTLabel.text = joined_culb
                        self.dorisTLabel.text = joined_doris
                        self.historicTLabel.text = joined_hist
                        
                        break
                    }
                    current+=1
                    
                    
                }
                
            }
        })
        
    }
    
    
}
//protocol MyDelegate{
//    func didFetchData(data:String, blom: String, culb: String, doris: String, hist: String)
//}

//        extractPosts { (String) in
//            return
//        }

//    func didFetchData(data:String, blom: String, culb: String, doris: String, hist: String){
//    }

//success:(String)->Void)

//                    self.didFetchData(data: DATE, blom: joined_blom, culb: joined_culb, doris: joined_doris, hist: joined_hist)
