//
//  FoundationExtensionCoreFoundationTest.m
//  FoundationExtension
//
//  Created by youknowone on 12. 10. 25..
//  Copyright (c) 2012 youknowone.org. All rights reserved.
//

#import <FoundationExtension/FoundationExtension.h>

#import "FoundationExtensionCoreFoundationTest.h"

@implementation FoundationExtensionCoreFoundationTest

- (void)testArray {
    NSAArray *obj;
    NSURL *tmpURL = @"tmp://test.plist".temporaryURL;

    obj = [[[NSAArray alloc] init] autorelease];
    STAssertEquals(0, (int)obj.count, @"");

    obj = [NSAArray array];
    STAssertEquals(0, (int)obj.count, @"");

    obj = [NSAArray arrayWithArray:@[@1, @2, @3, @4, @5]];
    STAssertEquals(5, (int)obj.count, @"");

    obj = [[[NSAArray alloc] initWithArray:@[@1, @2, @3, @4, @5] copyItems:YES] autorelease];
    STAssertEquals(5, (int)obj.count, @"");

    for (id o in obj) {
        STAssertNotNil(o, @"");
    }


    [obj writeToURL:tmpURL atomically:YES];
    NSAArray *array2 = [NSAArray arrayWithContentsOfURL:tmpURL];

    STAssertEquals(obj.count, array2.count, @"");
    STAssertTrue([[obj objectAtIndex:0] isEqual:@1], @"");

    obj = [NSAArray arrayWithObject:@1];
    STAssertTrue([@1 isEqual:[obj lastObject]], @"");

    obj = [NSAArray arrayWithObjects:@1, @2, @3, @4, @5, nil];
    STAssertTrue([@5 isEqual:[obj lastObject]], @"");
    STAssertTrue([obj containsObject:@1], @"");
    STAssertFalse([obj containsObject:@0], @"");

    NSArray *subarray = [obj subarrayWithRange:NSMakeRange(1, 3)];
    STAssertEquals(3, (int)subarray.count, @"");
    NSArray *solution = @[@2, @3, @4];
    STAssertTrue([subarray isEqual:solution], @"");
    STAssertEquals(subarray.class, NSAArray.class, @"");

    STAssertEquals((int)[obj indexOfInteger:3], 2, @"");

    NSAArray *copy = [obj copy];
    STAssertFalse(copy == obj, @"");
    STAssertEquals(copy.count, obj.count, @"");
    STAssertEquals(copy.class, obj.class, @"");

    NSMutableArray *marray = [NSAMutableArray arrayWithCapacity:5];
    STAssertEquals(0, (int)marray.count, @"");

}

- (void)testDictionary {
    NSADictionary *obj;
    NSURL *tmpURL = @"tmp://test.plist".temporaryURL;

    obj = [[[NSADictionary alloc] init] autorelease];
    STAssertEquals(0, (int)obj.count, @"");

    obj = [NSADictionary dictionary];
    STAssertEquals(0, (int)obj.count, @"");

    obj = [NSADictionary dictionaryWithObjectsAndKeys:
           @1, @"1",
           @2, @"2",
           nil];
    STAssertEquals(2, (int)obj.count, @"");

    [obj writeToURL:tmpURL atomically:YES];
    NSADictionary *array2 = [NSADictionary dictionaryWithContentsOfURL:tmpURL];

    STAssertEquals(obj.count, array2.count, @"");
    STAssertTrue([[obj objectForKey:@"2"] isEqual:@2], @"");

    obj = [NSADictionary dictionaryWithObjects:@[@1, @2, @3] forKeys:@[@1, @2, @3]];
    STAssertEquals(3, (int)obj.count, @"");

    obj = [NSAMutableDictionary dictionaryWithCapacity:4];
    STAssertEquals(0, (int)obj.count, @"");

    NSADictionary *copy = [obj copy];
    STAssertFalse(copy == obj, @"");
    STAssertEquals(copy.count, obj.count, @"");
    STAssertEquals(copy.class, obj.class, @"");
}

@end
