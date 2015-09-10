//
// NSArray+map.m
// SNceshi
//
// Created by CHEN Bin on 09/09/15.
// Copyright (c) 2015 Fantestech. All rights reserved.
//

#import "NSArray+map.h"

@implementation NSArray (map)

- (NSArray *)map:(id (^)(id, int))closure
{
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:self.count];

    for (int i = 0; i < (int)self.count; i++) {
        [temp addObject:closure(self[i], i)];
    }

    return [temp copy];
}

@end