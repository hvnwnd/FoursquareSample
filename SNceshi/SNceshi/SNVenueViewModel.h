//
// SNVenueViewModel.h
// SNceshi
//
// Created by CHEN Bin on 09/09/15.
// Copyright (c) 2015 Fantestech. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SNVenue;

@interface SNVenueViewModel : NSObject

@property (nonatomic) float     rating;
@property (nonatomic) NSString *ratingNumber;
@property (nonatomic) NSString *name;
@property (nonatomic) BOOL      showRating;

- (instancetype)initWithVenue:(SNVenue *)venue;

@end