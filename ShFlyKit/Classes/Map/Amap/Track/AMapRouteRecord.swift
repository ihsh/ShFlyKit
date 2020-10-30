//
//  AMapRouteRecord.swift
//  SHKit
//
//  Created by hsh on 2018/12/14.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit
import CoreLocation
import AMapNaviKit

public class AMapRouteRecord: NSObject {
    
    public var locations = [CLLocation]()
    public var tracedLocations = [MATracePoint]()
    
    
    private var startTime:Date = Date()
    private var endTime:Date!
    
    
    // MARK: - Interface
    public func updateTracedLocations(traces:[MATracePoint])->Void{
        for trace in traces {
            self.tracedLocations.append(trace);
        }
    }
    
    
    public func addLocation(location:CLLocation?)->Void{
        if location != nil {
            self.endTime = Date()
            self.locations.append(location!);
        }
    }
    
    
    public func startLocation()->CLLocation?{
        return self.locations.first
    }
    
    
    public func endLocation()->CLLocation?{
        return self.locations.last
    }
    
    
    public func coordinates()->UnsafeMutablePointer<CLLocationCoordinate2D>{
        let coordinates:UnsafeMutablePointer<CLLocationCoordinate2D> =  UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: self.locations.count);
        for (index,location) in locations.enumerated() {
            coordinates[index] = location.coordinate
        }
        return coordinates;
    }
    
    
    public func totalDistance()->CLLocationDistance{
        var distance:CLLocationDistance = 0
        if self.locations.count > 0 {
            var currentLocation = locations.first;
            for location in locations{
                distance += location.distance(from: currentLocation!);
                currentLocation = location;
            }
        }
        return distance;
    }
    
    
    public func totalDuration()->TimeInterval{
        return endTime.timeIntervalSince(startTime);
    }
    
    
    
    public func numOfLocations()->NSInteger{
        return self.locations.count;
    }
    
}
