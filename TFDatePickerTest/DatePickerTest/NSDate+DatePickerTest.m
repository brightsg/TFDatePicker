//
//  NSDate+DatePickerTest.m
//  TFDatePickerTest
//
//  Created by Jonathan Mitchell on 15/05/2014.
//  Copyright (c) 2014 Tom Fewster. All rights reserved.
//

#import "NSDate+DatePickerTest.h"

@implementation NSDate (DatePickerTest)

- (NSDate *)dpt_normalise
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self];
    
    // normalise to midnight UTC
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    components.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    return [calendar dateFromComponents:components];
}

@end
