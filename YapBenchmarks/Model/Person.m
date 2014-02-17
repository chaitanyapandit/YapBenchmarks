//
//  Person.m
//  YapBenchmarks
//
//  Created by Chaitanya Pandit on 15/02/14.
//  Copyright (c) 2014 #include tech. All rights reserved.
//

#import "Person.h"


@implementation Person

@dynamic about;
@dynamic alive;
@dynamic id;
@dynamic name;
@dynamic udid;

- (void)updateWithInfo:(NSDictionary *)info
{
    [info enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key];
    }];
}

@end
