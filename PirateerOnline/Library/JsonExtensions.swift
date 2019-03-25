//
//  Json.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 31/1/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation

extension JSONSerialization {
    
    static public func load ( path: String ) throws -> Any {
        do {
            var url = URL(fileURLWithPath: path)
            guard url.isFileURL else {
                throw PirateerError.FileNotFound("Not a file path: " + path)
            }
            
            let file = url.lastPathComponent
            url.deleteLastPathComponent()
            let urlpath = Bundle.main.path(forResource: file, ofType: nil, inDirectory: url.path)
            let data = try Data(contentsOf: URL(fileURLWithPath: urlpath!), options: .dataReadingMapped)
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            return json
        } catch {
            throw PirateerError.FileNotFound("File not frond: " + path)
        }
    }
    static public func loadDictionary ( path: String ) throws -> Dictionary<String, AnyObject> {
        return try load(path: path) as! Dictionary<String, AnyObject>
    }
}
