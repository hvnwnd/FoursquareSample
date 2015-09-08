//
//  SNVenueCell.m
//  SNceshi
//
//  Created by CHEN Bin on 08/09/15.
//  Copyright (c) 2015 Fantestech. All rights reserved.
//

#import "SNVenueCell.h"

@implementation SNVenueCell

- (void)awakeFromNib{
    self.ratingControl.maxRating = 5.0;
    self.ratingControl.starImage = [UIImage imageNamed:@"star"];
    self.ratingControl.starHighlightedImage = [UIImage imageNamed:@"starhighlighted"];
}

- (void)setRating:(float)rating
{
    if (rating > 0){
        self.ratingControl.rating = rating/2.0;
        self.ratingNumber.text = [NSString stringWithFormat:@"%.1f", rating];
        self.ratingControl.hidden=  NO;
    }else{
        self.ratingControl.hidden = YES;
        self.ratingNumber.hidden = NO;
    }

}

@end
