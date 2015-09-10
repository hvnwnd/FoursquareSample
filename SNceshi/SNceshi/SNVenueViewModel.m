//
// SNVenueViewModel.m
// SNceshi
//
// Created by CHEN Bin on 09/09/15.
// Copyright (c) 2015 Fantestech. All rights reserved.
//

#import "SNVenue.h"
#import "SNVenueViewModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation SNVenueViewModel

- (instancetype)initWithVenue:(SNVenue *)venue
{
    self = [super init];

    if (self) {
        _rating       = venue.rating;
        _name         = venue.name;
        _showRating   = (venue.rating > 0);
        _ratingNumber = [NSString stringWithFormat:@"%.1f", venue.rating];
    }

    return self;
}

@end