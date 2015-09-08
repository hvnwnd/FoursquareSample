//
// ViewController.m
// SNceshi
//
// Created by Titi on 9/1/15.
// Copyright (c) 2015 Fantestech. All rights reserved.
//

@import CoreLocation;

#import "Foursquare2.h"
#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ViewController () <CLLocationManagerDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocation *location;
@property (nonatomic) NSArray    *venues;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    self.locationManager.delegate = self;

    [self.tableView registerNib:[UINib nibWithNibName:@"SNVenueCell" bundle:nil] forCellReuseIdentifier:@"VenueCell"];

    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            // We never ask for authorization. Let's request it.
            [self.locationManager requestWhenInUseAuthorization];
        } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||
                   [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            // We have authorization. Let's update location.
            [self.locationManager startUpdatingLocation];
        } else {
            // If we are here we have no pormissions.
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No athorization"
                                                                message:@"Please, enable access to your location"
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"Open Settings", nil];
            [alertView show];
        }
    }

    RACSignal *locationSignal = RACObserve(self, location);

    [locationSignal subscribeNext:^(CLLocation *location) {
        [Foursquare2 venueSearchNearByLatitude:@(location.coordinate.latitude)
                                     longitude:@(location.coordinate.longitude)
                                         query:nil
                                         limit:nil
                                        intent:intentCheckin
                                        radius:@(500)
                                    categoryId:nil
                                      callback:^(BOOL success, id result) {
            if (success) {
                NSDictionary *dic = result;
                NSArray *venues = [dic valueForKeyPath:@"response.venues"];
                NSArray *ids = [venues valueForKey:@"id"];

                for (NSString *identifier in ids) {
                    [Foursquare2 venueGetDetail:identifier
                                       callback:^(BOOL success, id result) {
                        NSLog(@"%@", [result valueForKeyPath:@"response.venue.rating"]);
                    }];
                }
            }
        }];
    }];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.venues.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.venues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"VenueCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    return cell;
}

#pragma mark - CoreLocation Delegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if (newLocation != nil) {
        self.location = newLocation;
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"Location manager did fail with error %@", error);
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [manager startUpdatingLocation];
    }
}

@end