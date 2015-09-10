//
// ViewController.m
// SNceshi
//
// Created by Titi on 9/1/15.
// Copyright (c) 2015 Fantestech. All rights reserved.
//

@import CoreLocation;

#import "Foursquare2.h"
#import "NSArray+map.h"
#import "SNVenue.h"
#import "SNVenueCell.h"
#import "SNVenueViewModel.h"
#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

#define MIN_DISTANCE 20

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
    [self.tableView registerNib:[UINib nibWithNibName:@"SNVenueCell" bundle:nil] forCellReuseIdentifier:@"VenueCell"];

    [self initLocationManager];
    [self observeUpdateVenues];
    [self observeUpdateRatings];
}

- (void)initLocationManager
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;

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
}

- (void)observeUpdateVenues
{
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
                NSLog(@"%@", location);
                NSDictionary *dic = result;
                NSArray *venues = [dic valueForKeyPath:@"response.venues"];

                self.venues = [venues map:^id (id obj, int index) {
                    SNVenue *venue = [SNVenue new];
                    venue.venueId = obj[@"id"];
                    venue.name = obj[@"name"];
                    return venue;
                }];
            }
        }];
    }];
}

- (void)observeUpdateRatings
{
    [RACObserve(self, venues) subscribeNext:^(NSArray *venues) {
        NSLog(@"refresh venue %ld", (long)[venues count]);
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
            NSLog(@"refresh ratings");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
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
    SNVenueViewModel *viewModel     = [[SNVenueViewModel alloc] initWithVenue:venue];
    cell.viewModel = viewModel;

    return cell;
}

#pragma mark - CoreLocation Delegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if (newLocation != nil && ((oldLocation == nil || [newLocation distanceFromLocation:oldLocation] > MIN_DISTANCE))) {
        self.location = newLocation;
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"Location manager did fail with error %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [manager startUpdatingLocation];
    }
}

@end