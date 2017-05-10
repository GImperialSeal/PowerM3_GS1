//
//  GPSPositionManager.m
//  PowerPMS
//
//  Created by ImperialSeal on 16/6/7.
//  Copyright © 2016年 shPower. All rights reserved.
//

#import "GFLocationHelper.h"
@import UIKit;
@implementation GFLocationHelper
- (instancetype)init{
    self = [super init];
    if (self){
        if (![CLLocationManager locationServicesEnabled])
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Hint", nil)
                                                           message:NSLocalizedString(@"Location service is not open", nil)
                                                          delegate:self
                                                 cancelButtonTitle:NSLocalizedString(@"Cancle", nil)
                                                 otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
            [alert show];
#pragma clang diagnostic pop

            return nil;
        }
        //如果没有授权则请求用户授权
        if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined)
        {
            [self requestWhenInUseAuthorization];
        }
        else if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedWhenInUse)
        {
            //设置代理
            self.delegate=self;
            //设置定位精度
            self.desiredAccuracy=kCLLocationAccuracyBest;
            //定位频率,每隔多少米定位一次
            CLLocationDistance distance=10.0;//十米定位一次
            self.distanceFilter=distance;
            //启动跟踪定位
            [self startUpdatingLocation];
        }
        _geocoder = [[CLGeocoder alloc]init];//反地理编码
    }
    
    return self;
}

#pragma mark - CoreLocation 代理
#pragma mark 跟踪定位代理方法，每次位置发生变化即会执行（只要定位到相应位置）
//可以通过模拟器设置一个虚拟位置，否则在模拟器中无法调用此方法
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *location=[locations firstObject];//取出第一个位置
    CLLocationCoordinate2D coordinate=location.coordinate;//位置坐标
    //BLog(@"-----------------------------经度：%f,纬度：%f,海拔：%f,航向：%f,行走速度：%f",coordinate.longitude,coordinate.latitude,location.altitude,location.course,location.speed);
    
    [self getAddressByLatitude:coordinate.latitude longitude:coordinate.longitude];
    //如果不需要实时定位，使用完即使关闭定位服务
    [self stopUpdatingLocation];
}

#pragma mark -
#pragma mark -地理编码

//根据坐标获取地理位置
-(void)getAddressByLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude{
    //反地理编码
    CLLocation *location=[[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        //CLPlacemark *placemark=[placemarks firstObject];
         //BLog(@"---------------------------详细信息:%@",placemark.addressDictionary);
        //NSString *city = placemark.addressDictionary[@"City"];
        
//        NSDictionary *dic = @{@"Longitude":@(longitude),@"Latitude":@(latitude)};
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"GPSPosition" object:nil userInfo:dic];
        self.positionInformation(latitude,longitude);
    }];
}



@end
