//
// SNVenueCell.m
// SNceshi
//
// Created by CHEN Bin on 08/09/15.
// Copyright (c) 2015 Fantestech. All rights reserved.
//

#import "SNVenueCell.h"
#import "SNVenueViewModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface SNVenueCell ()
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *ratingNumber;

@property (nonatomic, weak) IBOutlet EDStarRating *ratingControl;

@end
@implementation SNVenueCell

- (void)awakeFromNib
{
    self.ratingControl.maxRating = 5.0;
    self.ratingControl.starImage = [UIImage imageNamed:@"star"];
    self.ratingControl.starHighlightedImage = [UIImage imageNamed:@"starhighlighted"];
}

- (void)setViewModel:(SNVenueViewModel *)viewModel
{
    self.titleLabel.text      = viewModel.name;
    self.ratingNumber.text    = viewModel.ratingNumber;
    self.ratingControl.rating = viewModel.rating;
    self.ratingControl.hidden = !viewModel.showRating;
    self.ratingNumber.hidden  = !viewModel.showRating;
}

@end