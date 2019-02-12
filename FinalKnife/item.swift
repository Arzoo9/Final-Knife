//
//  Item.swift
//  FinalKnife
//
//  Created by Trivedi on 12/5/18.
//  Copyright © 2018 Trivedi. All rights reserved.
//

import Foundation

class Item{
    //Data class for items in recipe
    var id : String! = nil
    var text : String = ""
   init(id : String, text : String){
        self.id = id
        self.text = text
    }
    init(text:String) {
        self.text = text
    }
    func setText(text:String){
        self.text = text
    }
}
