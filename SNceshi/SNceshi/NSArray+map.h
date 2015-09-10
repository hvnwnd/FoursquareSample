//
// NSArray+map.h
// SNceshi
//
// Created by CHEN Bin on 09/09/15.
// Copyright (c) 2015 Fantestech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (map)

- (NSArray *)map:(id (^)(id, int))closure;

@end