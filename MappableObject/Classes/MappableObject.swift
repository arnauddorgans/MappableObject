//
//  MappableObject.swift
//  Pods
//
//  Created by Arnaud Dorgans on 01/09/2017.
//
//

import UIKit
import Realm
import RealmSwift
import ObjectMapper

open class MappableObject: Object, Mappable, StaticMappable {
    
    open class func jsonPrimaryKey() -> String? {
        return nil
    }
    
    private static func _objectForMapping(map: Map) -> Self? {
        return try! RealmMapper(map: map).map(JSONObject: map.JSON)
    }
    
    public class func objectForMapping(map: Map) -> BaseMappable? {
        return _objectForMapping(map: map)
    }
    
    open func mappingPrimaryKey(map: Map) { }
    
    open func mapping(map: Map) {
        self.validate(map: map)
        
        if type(of: self).hasPrimaryKey,
            let primaryKey = type(of: self).primaryKey(),
            let preferedPrimaryKey = type(of: self).preferredPrimaryKey {
            switch map.mappingType {
            case .toJSON:
                var value = self[primaryKey]
                value <- map[preferedPrimaryKey]
            case .fromJSON where !self.isSync:
                self.mappingPrimaryKey(map: map)
            default:
                break
            }
        }
    }
    
    required public init?(map: Map) {
        if type(of: self).hasPrimaryKey,
            let preferredPrimaryKey = type(of: self).preferredPrimaryKey,
            map.JSON[preferredPrimaryKey] == nil {
            return nil
        }
        super.init()
    }
    
    required public init() {
        super.init()
    }
    
    required public init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    required public init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
}
