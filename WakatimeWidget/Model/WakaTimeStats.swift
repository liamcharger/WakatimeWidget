//
//  WakaTimeStats.swift
//  WakatimeWidget
//
//  Created by Liam Willey on 1/28/25.
//

import Foundation

struct WakaTimeStats: Decodable {
    let userId: String
    let from: String
    let to: String
    let projects: [KeyValue]
    let languages: [KeyValue]
    let editors: [KeyValue]
    let operatingSystems: [KeyValue]
    let machines: [KeyValue]
    let labels: [KeyValue]
    let branches: [String]?
    let entities: [String]?
    let categories: [KeyValue]
    
    struct KeyValue: Decodable {
        let key: String
        let total: Int
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case from
        case to
        case projects
        case languages
        case editors
        case operatingSystems = "operating_systems"
        case machines
        case labels
        case categories
        case branches
        case entities
    }
}
