//
//  NSArray+Extension.m
//  TestRAC
//
//  Created by 李旭 on 16/9/1.
//  Copyright © 2016年 LX. All rights reserved.
//

#import "NSArray+Extension.h"

@implementation NSArray (Extension)

- (NSArray *)dicToModel:(id (^) (id tweet))transform
{
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:self.count];
    for(id item in self) {
        id object = transform(item);
        [result addObject:(object) ? object : [NSNull null]];
    }
    return result;
}

@end
