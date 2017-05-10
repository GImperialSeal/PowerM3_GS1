//
//  GPSPositionManager.h
//  PowerPMS
//
//  Created by ImperialSeal on 16/6/7.
//  Copyright © 2016年 shPower. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

typedef void (^positionInformation)(CGFloat logintude,CGFloat latitude);

@interface GFLocationHelper : CLLocationManager<CLLocationManagerDelegate>


- (instancetype)init;
@property (nonatomic,strong) CLGeocoder *geocoder;//地理编码

@property (nonatomic,copy) positionInformation positionInformation;

@end
