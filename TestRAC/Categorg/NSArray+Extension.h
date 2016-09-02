//
//  NSArray+Extension.h
//  TestRAC
//
//  Created by 李旭 on 16/9/1.
//  Copyright © 2016年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Extension)

- (NSArray *)dicToModel:(id (^) (id tweet))transform;

@end
