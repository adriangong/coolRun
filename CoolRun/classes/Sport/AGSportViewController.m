//
//  AGSportViewController.m
//  CoolRun
//
//  Created by adrian gong on 16/1/8.
//  Copyright © 2016年 Adrian Gong. All rights reserved.
//

#import "AGSportViewController.h"
#import "BMapKit.h"

@interface AGSportViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate>
/** 百度地图View */
@property (nonatomic,strong) BMKMapView *mapView;
/** 百度地图位置服务 */
@property (nonatomic,strong) BMKLocationService *bmkLocationService;

@end

@implementation AGSportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:self.mapView atIndex:0];
    
    [self setLocationServiceInit];
    [self setMapViewProperty];
    self.mapView.delegate = self;
    self.bmkLocationService.delegate = self;
    
    //启动定位服务
    [self.bmkLocationService startUserLocationService];

}

- (void) setLocationServiceInit{
    self.bmkLocationService = [[BMKLocationService alloc]init];
    //设置定位过滤
    [BMKLocationService setLocationDistanceFilter:6];
    //设置定位精度
    [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyBest];
}

- (void) setMapViewProperty{
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = BMKUserTrackingModeFollowWithHeading;
    self.mapView.rotateEnabled = NO;
    self.mapView.showMapScaleBar = YES;
    //比例尺显示在右下角
    self.mapView.mapScaleBarPosition = CGPointMake(self.view.frame.size.width - 50, self.view.frame.size.height - 50);
    
    //设置定位图层的 自定义显示
    BMKLocationViewDisplayParam *displayPara = [BMKLocationViewDisplayParam new];
    displayPara.isAccuracyCircleShow = NO;
    displayPara.isRotateAngleValid = YES;
    displayPara.locationViewOffsetX = 0;
    displayPara.locationViewOffsetY = 0;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark BMKit Delegate

- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    NSLog(@"用户位置(%lf,%lf)",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    [self.mapView updateLocationData:userLocation];
    
    //以用户的位置为中心点，并设定显示的扇区
    BMKCoordinateRegion adjustRegion = [self.mapView regionThatFits:BMKCoordinateRegionMake(userLocation.location.coordinate, BMKCoordinateSpanMake(0.002, 0.002))];
    [self.mapView setRegion:adjustRegion animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
