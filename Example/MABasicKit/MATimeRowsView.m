//
//  MATimeRowsView.m
//  MABasicKit_Example
//
//  Created by maqihan on 2020/12/4.
//  Copyright © 2020 Admin. All rights reserved.
//

#import "MATimeRowsView.h"
@interface MATimeRowsView()

@property (assign , nonatomic) NSRange hourRange;
@property (assign , nonatomic) NSUInteger rounding;
@property (assign , nonatomic) CGFloat insetsHeight;
@property (assign , nonatomic) CGFloat timeColumnWidth;    
@property (strong , nonatomic) NSCalendar *calendar;
@property (strong , nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation MATimeRowsView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _hourRange = NSMakeRange(0, 24);
        _rounding = 15;
        _hourSlotHeight = 65;
        _insetsHeight = 45;
    }
    return self;
}

- (NSAttributedString*)attributedStringForTimeMark:(MATimeMark)mark time:(NSTimeInterval)ti
{
    NSAttributedString *attrStr = nil;
    
    if (!attrStr) {
        BOOL rounded = (mark != MATimeMarkCurrent);
        BOOL minutesOnly = (mark == MATimeMarkFloating);

        NSString *str = [self stringForTime:ti rounded:rounded minutesOnly:minutesOnly];
    
        NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
        style.alignment = NSTextAlignmentRight;
        
        UIColor *color = (mark == MATimeMarkCurrent) ? [UIColor redColor] : [UIColor blackColor];
        UIFont *font = [UIFont systemFontOfSize:15];
        
        attrStr = [[NSAttributedString alloc] initWithString:str attributes:
                   @{NSFontAttributeName: font,
                     NSForegroundColorAttributeName: color,
                     NSParagraphStyleAttributeName: style}];
    }
    return attrStr;
}

- (NSString*)stringForTime:(NSTimeInterval)time rounded:(BOOL)rounded minutesOnly:(BOOL)minutesOnly
{
    if (rounded) {
        time = roundf(time / (self.rounding * 60)) * (self.rounding * 60);
    }
    
    int hour = (int)(time / 3600) % 24;
    int minutes = ((int)time % 3600) / 60;

    if (minutesOnly) {
        return [NSString stringWithFormat:@":%02d", minutes];
    }
    return [NSString stringWithFormat:@"%02d:%02d", hour, minutes];
}

- (CGFloat)yOffsetForTime:(NSTimeInterval)time rounded:(BOOL)rounded
{
    if (rounded) {
        time = roundf(time / (self.rounding * 60)) * (self.rounding * 60);
    }
    return (time / 3600. - self.hourRange.location) * self.hourSlotHeight + self.insetsHeight;
}

- (void)drawRect:(CGRect)rect
{
    const CGFloat kSpacing = 5.;
    const CGFloat dash[2]= {2, 3};
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGSize markSizeMax = CGSizeMake(CGRectGetWidth(self.frame), CGFLOAT_MAX);
    
    NSDate *now = [NSDate date];
    NSDateComponents *comps = [self.calendar components:NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:now];
    NSTimeInterval currentTime = comps.hour*3600.+comps.minute*60.+comps.second;
    
    NSAttributedString *markAttrStr = [self attributedStringForTimeMark:MATimeMarkCurrent time:currentTime];
    
    CGSize markSize = [markAttrStr boundingRectWithSize:markSizeMax options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    CGFloat y = [self yOffsetForTime:currentTime rounded:NO];
    CGRect rectCurTime = CGRectZero;
    
    //当前时间
    rectCurTime =  CGRectMake(kSpacing, y - markSize.height/2., markSizeMax.width, markSize.height);
    [markAttrStr drawInRect:rectCurTime];
    CGRect lineRect = CGRectMake(self.timeColumnWidth - kSpacing, y, self.bounds.size.width - self.timeColumnWidth + kSpacing, 1);
    CGContextSetFillColorWithColor(context, self.currentTimeColor.CGColor);
    UIRectFill(lineRect);

    
    NSAttributedString *floatingMarkAttrStr = [self attributedStringForTimeMark:MGCDayPlannerTimeMarkFloating time:self.timeMark];
    markSize = [floatingMarkAttrStr boundingRectWithSize:markSizeMax options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    y = [self yOffsetForTime:self.timeMark rounded:YES];
    CGRect rectTimeMark = CGRectMake(kSpacing, y - markSize.height/2., markSizeMax.width, markSize.height);
    
    BOOL drawTimeMark = self.timeMark != 0 && [self canDisplayTime:self.timeMark];
    CGFloat lineWidth = 1. / [UIScreen mainScreen].scale;
    
    for (NSUInteger i = self.hourRange.location; i <=  NSMaxRange(self.hourRange); i++) {
        
        markAttrStr = [self attributedStringForTimeMark:MGCDayPlannerTimeMarkHeader time:(i % 24)*3600];
        markSize = [markAttrStr boundingRectWithSize:markSizeMax options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        y = MGCAlignedFloat((i - self.hourRange.location) * self.hourSlotHeight + self.insetsHeight) - lineWidth * .5;
        CGRect r = MGCAlignedRectMake(kSpacing, y - markSize.height / 2., markSizeMax.width, markSize.height);

        if (!CGRectIntersectsRect(r, rectCurTime) || !self.showsCurrentTime) {
            [markAttrStr drawInRect:r];
         }
        
        CGContextSetStrokeColorWithColor(context, self.timeColor.CGColor);
        CGContextSetLineWidth(context, lineWidth);
        CGContextSetLineDash(context, 0, NULL, 0);
        CGContextMoveToPoint(context, self.timeColumnWidth, y);
        CGContextAddLineToPoint(context, self.timeColumnWidth + rect.size.width, y);
        CGContextStrokePath(context);
        
        if (self.showsHalfHourLines && i < NSMaxRange(self.hourRange)) {
            y = MGCAlignedFloat(y + self.hourSlotHeight/2.) - lineWidth * .5;
            CGContextSetLineDash(context, 0, dash, 2);
            CGContextMoveToPoint(context, self.timeColumnWidth, y),
            CGContextAddLineToPoint(context, self.timeColumnWidth + rect.size.width, y);
            CGContextStrokePath(context);
        }
        
        // don't draw time mark if it intersects any other mark
        drawTimeMark &= !CGRectIntersectsRect(r, rectTimeMark);
    }

    if (drawTimeMark) {
        [floatingMarkAttrStr drawInRect:rectTimeMark];
    }
}

- (NSCalendar *)calendar
{
    if (!_calendar) {
        _calendar = [NSCalendar currentCalendar];
    }
    return _calendar;;
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"HH:mm";
    }
    return _dateFormatter;
}

@end
