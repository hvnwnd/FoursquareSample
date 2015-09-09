//
// ViewController.m
// SNceshi
//
// Created by Titi on 9/1/15.
// Copyright (c) 2015 Fantestech. All rights reserved.
//

@import CoreLocation;

#import "Foursquare2.h"
#import "SNVenue.h"
#import "SNVenueCell.h"
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

// RACSignal *venueReadySignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//
// }]
// RACSignal *reloadSignal = [RACSignal combineLatest:(id<NSFastEnumeration>) reduce:<#^id(void)reduceBlock#>]
    [RACObserve(self, venues) subscribeNext:^(id x) {
        [self.tableView reloadData];

        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id < RACSubscriber > subscriber) {
            __block NSUInteger count = 0;

            for (SNVenue *venue in self.venues) {
                [Foursquare2 venueGetDetail:venue.venueId
                                   callback:^(BOOL success, id result) {
                    count++;
                    float rating = [[result valueForKeyPath:@"response.venue.rating"] floatValue];

                    if (rating > 0) {
                        venue.rating = rating;
                    }

                    if (count == self.venues.count) {
                        [subscriber sendNext:venue];
                        [subscriber sendCompleted];
                    }
                }];
            }
            return nil;
        }];

        [signal subscribeNext:^(id x) {
            [self.tableView reloadData];
        }];
    }];


// [[RACSignal combineLatest:(signals.count > 0) ? [signals subarrayWithRange:NSMakeRange(0, 14)] : signals reduce:^id (SNVenue *venue) {
// NSLog(@"%f", venue.rating);
// return @(venue.rating > 0);
// }] subscribeNext:^(id x) {
// NSLog(@"hehe %@", x);
// [self.tableView reloadData];
// }];
// }];

    [RACObserve(self, location) subscribeNext:^(CLLocation *location) {
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
                NSMutableArray *tmpArray = [NSMutableArray array];

                for (NSDictionary *dict in venues) {
                    SNVenue *venue = [SNVenue new];
                    venue.venueId = dict[@"id"];
                    venue.name = dict[@"name"];
                    [tmpArray addObject:venue];


// [Foursquare2 venueGetDetail:venue.venueId
// callback:^(BOOL success, id result) {
// venue.rating = [[result valueForKeyPath:@"response.venue.rating"] floatValue];
//
// if (venue.rating > 0) {
// NSLog(@"%@ %f", venue.name, venue.rating);
// [self.tableView reloadData];
// }
// }];
                }
                self.venues = tmpArray;
            }
        }];
    }];
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
    SNVenueCell     *cell = (SNVenueCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    SNVenue *venue = self.venues[indexPath.row];
    cell.titleLabel.text = venue.name;
    [cell setRating:venue.rating];
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
    [self.locationManager stopUpdatingLocation];
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