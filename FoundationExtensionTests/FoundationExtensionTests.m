//
//  FoundationExtensionTests.m
//  FoundationExtensionTests
//
//  Created by Jeong YunWon on 11. 3. 21..
//  Copyright 2011 youknowone.org All rights reserved.
//

#import <FoundationExtension/FoundationExtension.h>

#import "FoundationExtensionTests.h"

@interface TestObject : NSObject {
@private
    id obj1;
    NSString *obj2;
    NSString *obj3;
    NSInteger val;
}

@end

@implementation TestObject

- (id)init {
    self = [super init];
    self->obj1 = self;
    self->obj2 = (id)[self retain];
    self->obj3 = (id)[self retain];
    self->val = 42;
    return self;
}

@end


@interface TestObject (Private)

@property(nonatomic, readonly) NSInteger val;
@property(nonatomic, assign) id obj1;
@property(nonatomic, retain) NSString *obj2;
@property(nonatomic, retain) NSString *obj3;

@end


@implementation TestObject (Private)

NSAPropertyGetterForType(val, @"val", NSInteger)

NSAPropertyGetter(obj1, @"obj1")
NSAPropertyAssignSetter(setObj1, @"obj1")
NSAPropertyGetter(obj2, @"obj2")
NSAPropertyRetainSetter(setObj2, @"obj2")
NSAPropertyGetter(obj3, @"obj3")
NSAPropertyCopySetter(setObj3, @"obj3")

@end


@implementation FoundationExtensionTests

- (void)setUp
{
    [super setUp];

    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.

    [super tearDown];
}

- (void)testClassName {
    STAssertTrue([[[self class] name] isEqualToString:@"FoundationExtensionTests"], @"Taken name is: %@", [[self class] name]);
}

- (void)testClassObject {
    NSAString *string = [[[NSAString alloc] initWithString:@"blah"] autorelease];
    STAssertEquals(string.class, [NSAString class], @"");
}

- (void)testRuntimeAccessor {
    TestObject *obj = [[[TestObject alloc] init] autorelease];
    STAssertEquals(obj.val, (NSInteger)42, @"");

    NSString *new = [NSMutableString stringWithString:@"Hello"]; // to make new object.
    NSUInteger count = new.retainCount;

    STAssertEquals(obj.obj1, obj, @"");
    obj.obj1 = new;
    STAssertEquals(obj.obj1, new, @"");
    STAssertEquals(new.retainCount, count, @"");
    obj.obj1 = nil;
    STAssertEquals(obj.obj1, (NSObject *)nil, @"");
    STAssertEquals(new.retainCount, count, @"");

    STAssertEquals(obj.obj2, obj, @"");
    obj.obj2 = new;
    STAssertEquals(obj.obj2, new, @"");
    STAssertEquals(new.retainCount, count + 1, @"");
    obj.obj2 = nil;
    STAssertEquals(obj.obj2, (NSObject *)nil, @"");
    STAssertEquals(new.retainCount, count, @"");

    STAssertEquals(obj.obj3, obj, @"");
    obj.obj3 = new;
    STAssertFalse(obj.obj3 == new, @"");
    STAssertEqualObjects(obj.obj3, new, @"");
    STAssertEquals(new.retainCount, count, @"");
    obj.obj3 = nil;
    STAssertEquals(obj.obj3, (NSObject *)nil, @"");
    STAssertEquals(new.retainCount, count, @"");

}

- (int)return0 { return 0; }
- (int)return1 { return 1; }

- (void)testClassMethod {
    STAssertEquals(0, [self return0], @"");
    STAssertEquals(1, [self return1], @"");
    {
        NSAMethod *m0 = [self.class methodObjectForSelector:@selector(return0)];
        NSAMethod *m1 = [self.class methodObjectForSelector:@selector(return0)];
        STAssertEquals(m0.method, m1.method, @"");
        STAssertEqualObjects(m0, m1, @"");
    }
    {
        NSAMethod *m0 = [self.class methodObjectForSelector:@selector(return0)];
        NSAMethod *m1 = [self.class methodObjectForSelector:@selector(return1)];
        m0.implementation = m1.implementation;
        STAssertEquals(1, [self return0], @"");
    }
}



- (void)testString {
    STAssertEquals([@"Hello, World" hasSubstring:@""], NO, @"");
}

- (void)testStringFormat {
    {
        NSString *formatted = [@"%d %d %d" format0:nil, 10, 9, 8];
        STAssertTrue([formatted isEqualToString:@"10 9 8"], @"formatted was: %@", formatted);
    }
    {
        NSString *formatted = [@"%@ %d %s" format:@"Hello", 10, "World"];
        STAssertTrue([formatted isEqualToString:@"Hello 10 World"], @"formatted was: %@", formatted);
    }
    {
        NSString *formatted = [@"%@" format:@"Hello"];
        STAssertTrue([formatted isEqualToString:@"Hello"], @"formatted was: %@", formatted);
    }
    {
        NSString *formatted = [@"%%%%%@" format:@"Hello"];
        STAssertTrue([formatted isEqualToString:@"%%Hello"], @"formatted was: %@", formatted);
    }
    {
        NSString *aPath = @"/tmp";
        NSString *test = [aPath stringByAppendingPathFormat:@"/%@/%@", @"dir", @"file.ext"];
        STAssertTrue([test isEqualToString:@"/tmp/dir/file.ext"], @"result: %@", test);
    }
}

- (void)testStringConcatnation {
    NSString *concat = [NSString stringWithConcatnatingStrings:@"Hello, ", @"World!", nil];

    STAssertTrue([concat isEqualToString:@"Hello, World!"], @"");
}

- (void)testArrayRearrangement {
    NSMutableArray *array = [NSMutableArray arrayWithObjects:@0, @1, @2, @3, @4, nil];
    STAssertEqualObjects(array, (@[@0, @1, @2, @3, @4]), @"result: %@", array);
    [array moveObjectAtIndex:3 toIndex:3];
    STAssertEqualObjects(array, (@[@0, @1, @2, @3, @4]), @"result: %@", array);

    array = [NSMutableArray arrayWithObjects:@0, @1, @2, @3, @4, nil];
    STAssertEqualObjects(array, (@[@0, @1, @2, @3, @4]), @"result: %@", array);
    [array moveObjectAtIndex:0 toIndex:3];
    STAssertEqualObjects(array, (@[@1, @2, @3, @0, @4]), @"result: %@", array);

    array = [NSMutableArray arrayWithObjects:@0, @1, @2, @3, @4, nil];
    STAssertEqualObjects(array, (@[@0, @1, @2, @3, @4]), @"result: %@", array);
    [array moveObjectAtIndex:4 toIndex:0];
    STAssertEqualObjects(array, (@[@4, @0, @1, @2, @3]), @"result: %@", array);
}

- (void)testHexadecimalString {
    NSData *data = [NSData dataWithBytes:"\0aa\0" length:4];
    NSString *result = [data hexadecimalString];
    STAssertTrue([result isEqualToString:@"00616100"], @"");
}

- (void)testBase64String {
    // test from http://en.wikipedia.org/wiki/Base64#Examples
    NSData *data = [@"Man is distinguished, not only by his reason, but by this singular passion from other animals, which is a lust of the mind, that by a perseverance of delight in the continued and indefatigable generation of knowledge, exceeds the short vehemence of any carnal pleasure." dataUsingUTF8Encoding];
    NSString *solution = @"TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlzIHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2YgdGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGludWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRoZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4=";
    NSString *encode = [data base64String];
    STAssertEquals(encode.length, solution.length, @"length: %d expected: %d", encode.length, solution.length);
    STAssertTrue([encode isEqualToString:solution], @"result: %@", encode);

    NSData *decode = [NSData dataWithBase64String:solution];
    STAssertEquals(decode.length, data.length, @"length: %d expected: %d", decode.length, data.length);
    STAssertTrue([decode isEqualToData:data], @"result: %@ expected: %@", [NSString stringWithUTF8Data:decode], [NSString stringWithUTF8Data:data]);
}

- (void)testHexadecimal
{
    NSData *data = [@"SAMPLE" dataUsingEncoding:NSUTF8StringEncoding];
    STAssertTrue([[data hexadecimalString] isEqual:@"53414d504c45"], @"hexadecimal encode");

    STAssertTrue([@"SAMPLE" isEqual:[NSString stringWithUTF8Data:[NSData dataWithHexadecimalString:@"53414d504c45"]]], @"hexadecimal decode: %@", [NSString stringWithUTF8Data:[NSData dataWithHexadecimalString:@"53414d504c45"]]);
}

- (void)testTuple
{
    NSAMutableTuple *tuple = [NSAMutableTuple tupleWithFirst:@1 second:@2];
    STAssertEquals((int)[tuple.first integerValue], 1, @"");
    STAssertEquals((int)[tuple.second integerValue], 2, @"");

    tuple.first = @3;
    tuple.second = @4;
    STAssertEquals((int)[tuple.first integerValue], 3, @"");
    STAssertEquals((int)[tuple.second integerValue], 4, @"");

    [tuple swap];
    STAssertEquals((int)[tuple.first integerValue], 4, @"");
    STAssertEquals((int)[tuple.second integerValue], 3, @"");
}

- (void)testTriple
{
    NSAMutableTriple *obj = [NSAMutableTriple tripleWithFirst:@1 second:@2 third:@3];
    STAssertEquals((int)[obj.first integerValue], 1, @"");
    STAssertEquals((int)[obj.second integerValue], 2, @"");
    STAssertEquals((int)[obj.third integerValue], 3, @"");

    obj.first = @4;
    obj.second = @5;
    obj.third = @6;
    STAssertEquals((int)[obj.first integerValue], 4, @"");
    STAssertEquals((int)[obj.second integerValue], 5, @"");
    STAssertEquals((int)[obj.third integerValue], 6, @"");
}

- (void)testFunctional {
    {
        NSArray *a = @[@1, @2, @3, @4];
        NSInteger idx = 0;
        for (id i in NSAMap(a.objectEnumerator, ^(id obj) { return @([obj integerValue] - 1); })) {
            STAssertEquals([i integerValue], idx, @"");
            idx += 1;
        }
        STAssertEquals((int)idx, 4, @"");

        idx = 0;
        for (id i in NSAFilter(a.objectEnumerator, ^(id obj) { return (BOOL)([obj integerValue] % 2 == 0); })) {
            idx += 1;
            STAssertEquals([i integerValue] / 2, (idx + 2) / 2, @"");
        }
        STAssertEquals((int)idx, 2, @"");

        idx = 0;
        for (id i in NSAMapFilter(a.objectEnumerator, ^(id obj) { return ([obj integerValue] % 2 != 0) ? @([obj integerValue] - 1) : nil; })) {
            idx += 1;
            STAssertEquals([i integerValue] / 2, idx / 2, @"");
        }
        STAssertEquals((int)idx, 2, @"");

        NSNumber *res = NSAReduceWithInitialObject(a.objectEnumerator, ^(id obj1, id obj2) { return @([obj1 integerValue] + [obj2 integerValue]); }, @0);
        STAssertEqualObjects(res, @10, @"");
    }

    {
        NSArray *a = @[@1, @2, @3, @4];
        NSArray *r = [a.reverseObjectEnumerator arrayByFilteringOperator:^BOOL(id obj) { return YES; }];
        STAssertEqualObjects(r, (@[@4, @3, @2, @1]), @"");
    }

    {
        NSMutableArray *a = [NSMutableArray arrayWithObjects:@1, @2, @3, @4, nil];
        NSInteger idx = 0;
        [a map:^(id obj) { return @([obj integerValue] - 1); }];
        for (id i in a) {
            STAssertEquals([i integerValue], idx, @"");
            idx += 1;
        }
        STAssertEquals((int)idx, 4, @"");

        a = [NSMutableArray arrayWithObjects:@1, @2, @3, @4, nil];
        idx = 0;
        [a filter:^(id obj) { return (BOOL)([obj integerValue] % 2 == 0); }];
        for (id i in a) {
            idx += 1;
            STAssertEquals([i integerValue] / 2, (idx + 2) / 2, @"");
        }
        STAssertEquals((int)idx, 2, @"");

        a = [NSMutableArray arrayWithObjects:@1, @2, @3, @4, nil];
        idx = 0;
        [a mapFilter:^(id obj) { return ([obj integerValue] % 2 != 0) ? @([obj integerValue] - 1) : nil; }];
        for (id i in a) {
            idx += 1;
            STAssertEquals([i integerValue] / 2, idx / 2, @"");
        }
    }
}

- (void)testAttributedString {
    NSAttributedString *obj = [NSAttributedString attributedString];
    STAssertEqualObjects(obj, [[[NSAttributedString alloc] initWithString:@""] autorelease], @"");
}

#if __MAC_OS_X_VERSION_MIN_REQUIRED >= 1070
- (void)testJSON {
    id object = [NSJSONSerialization JSONObjectWithString:@"[1, 2, 3]" options:0 error:NULL];
    STAssertEqualObjects(object, (@[@1, @2, @3]), @"");
}
#endif

- (void)testOrderedDictionary {
    NSAMutableOrderedDictionary *obj = [NSAMutableOrderedDictionary dictionary];
    obj[@1] = @"1";
    obj[@2] = @"2";
    obj[@3] = @"3";
    obj[@4] = @"4";
    obj[@5] = @"5";
    NSInteger count = 0;
    for (id key in obj) {
        count += 1;
        STAssertEqualObjects(obj[key], [NSString stringWithInteger:count], @"");
    }
}

- (void)testNumber {
    STAssertEqualObjects([@0 description], [@0 typeFormedDescription], @"");
    STAssertEqualObjects([[@1.0 description] stringByAppendingString:@".0"], [@1.0 typeFormedDescription], @"");
    NSNumber *b = @YES;
    STAssertEqualObjects(@"YES", [b typeFormedDescription], @"");
}

- (void)testVersion {
    NSAVersion *version = [NSAVersion versionWithString:@"10.8.4"];
    STAssertEquals(version.major, (NSInteger)10, @"");
    STAssertEquals(version.minor, (NSInteger)8, @"");
    STAssertEquals(version.bugfix, (NSInteger)4, @"");
}

- (void)testShuffle {
    NSMutableArray *array = [@[@"1", @"2", @"3"] mutableCopy];
    [array shuffle];
    STAssertEquals(array.count, (NSUInteger)3, nil);
}

@end
