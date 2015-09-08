//
// SNVenueCell.h
// SNceshi
//
// Created by CHEN Bin on 08/09/15.
// Copyright (c) 2015 Fantestech. All rights reserved.
//

#import "EDStarRating.h"
#import <UIKit/UIKit.h>

@interface SNVenueCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) EDStarRating     *ratingControl;

@end