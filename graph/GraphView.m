//
//  GraphView.m
//  graph
//
//  Created by Konstantin Simakov on 24.09.13.
//  Copyright (c) 2013 Konstantin Simakov. All rights reserved.
//

#import "GraphView.h"
#import <QuartzCore/QuartzCore.h>

@implementation GraphView

CGContextRef context;

@synthesize xStepSize = _xStepSize;
@synthesize yStepSize = _yStepSize;
@synthesize fps = _fps;
@synthesize verticalAxisX = _verticalAxisX;
@synthesize horizontalAxisY = _horizontalAxisY;
@synthesize flexibleMax = _flexibleMax;
@synthesize horizontalAxisColor = _horizontalAxisColor;
@synthesize verticalAxisColor = _verticalAxisColor;
@synthesize graphLineColor = _graphLineColor;
@synthesize showVerticalMarks = _showVerticalMarks;
@synthesize verticalMarksMinCount = _verticalMarksMinCount;
@synthesize showVerticalMarksLabels = _showVerticalMarksLabels;

CGRect viewRect;
int graphLineWidth = 2;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        viewRect = frame;
        
        _fps = 25;
        _verticalAxisX = -1;
        _horizontalAxisY = -1;
        _flexibleMax = NO;
        
        _horizontalAxisColor = [UIColor blackColor];
        _verticalAxisColor = [UIColor blackColor];
        
        _verticalMarksMinCount = 5;
        _showVerticalMarksLabels = YES;
        _showVerticalMarks = YES;
        
        maxValue = 0;
        visibleValues = [NSMutableArray new];
        yMarkStep = 0;
        
        
        [self loadView];
        
        stack = [NSMutableArray new];
    }
    return self;
}

-(void)loadView
{
    if (!self.backgroundColor) {
    	self.backgroundColor = [UIColor colorWithRed:0.801 green:0.876 blue:1.000 alpha:1.000];
    }
    
	rootLayer = [CALayer layer];
	rootLayer.frame = CGRectMake(0, 0, viewRect.size.width, viewRect.size.height);
    
	[self.layer addSublayer:rootLayer];
    
    if (_horizontalAxisY == -1) {
        _horizontalAxisY = viewRect.size.height / 2;
    }
    if (_verticalAxisX == -1) {
        _verticalAxisX = 5;
    }
    
    //Background config
    
    CGMutablePathRef axis = CGPathCreateMutable();
    CGPathMoveToPoint(axis, nil, _verticalAxisX, _horizontalAxisY);
    CGPathAddLineToPoint(axis, nil, viewRect.size.width, _horizontalAxisY);
    
    horizontalAxisLayer = [CAShapeLayer layer];
	horizontalAxisLayer.strokeColor = _horizontalAxisColor.CGColor;
	horizontalAxisLayer.lineWidth = 1.0;
	horizontalAxisLayer.fillRule = kCAFillRuleNonZero;
    horizontalAxisLayer.path = axis;
    [rootLayer addSublayer:horizontalAxisLayer];
    
    
    CGMutablePathRef verticalAxis = CGPathCreateMutable();
    CGPathMoveToPoint(verticalAxis, nil, _verticalAxisX, 0);
    CGPathAddLineToPoint(verticalAxis, nil, _verticalAxisX, viewRect.size.height);
    
    verticalAxisLayer = [CAShapeLayer layer];
	verticalAxisLayer.strokeColor = _verticalAxisColor.CGColor;
	verticalAxisLayer.lineWidth = 1.0;
	verticalAxisLayer.fillRule = kCAFillRuleNonZero;
    verticalAxisLayer.path = verticalAxis;
    [rootLayer addSublayer:verticalAxisLayer];
    
    //Graph config
    curX = _verticalAxisX + graphLineWidth;
    curY = _horizontalAxisY;
}


#pragma mark - Setters for proprerties

-(void)setGraphLineColor:(UIColor *)graphLineColor
{
    shapeLayer.strokeColor = _graphLineColor.CGColor;
    _graphLineColor = graphLineColor;
}

-(void)setHorizontalAxisColor:(UIColor *)horizontalAxisColor
{
    horizontalAxisLayer.strokeColor = horizontalAxisColor.CGColor;
    _horizontalAxisColor = horizontalAxisColor;
}

-(void)setVerticalAxisColor:(UIColor *)verticalAxisColor
{
    verticalAxisLayer.strokeColor = verticalAxisColor.CGColor;
    _verticalAxisColor = verticalAxisColor;
}


-(void)setHorizontalAxisVisible:(BOOL)horizontalAxisVisible
{
    horizontalAxisLayer.lineWidth = horizontalAxisVisible ? 1.0 : 0.0;
}

-(void)setVerticalAxisVisible:(BOOL)verticalAxisVisible
{
    verticalAxisLayer.lineWidth = verticalAxisVisible ? 1.0 : 0.0;
}

#pragma mark - Draw functions

-(void)startAnimation
{
    graphPath = CGPathCreateMutable();
    CGPathMoveToPoint(graphPath, nil, curX , curY);
    CGPathAddLineToPoint(graphPath, nil, curX , curY);
    CGPathCloseSubpath(graphPath);
    
    newGraphPath = CGPathCreateMutableCopy(graphPath);
    CGPathAddLineToPoint(newGraphPath, nil, curX , curY);
    CGPathCloseSubpath(newGraphPath);
    
    shapeLayer = [CAShapeLayer layer];
	shapeLayer.strokeColor = _graphLineColor.CGColor;
	shapeLayer.lineWidth = graphLineWidth;
    shapeLayer.fillColor = nil;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineJoin = kCALineJoinRound;
    
    [rootLayer addSublayer:shapeLayer];
    
    renderTimer = [[NSTimer timerWithTimeInterval:(1.0 / (NSTimeInterval)_fps) target:self selector:@selector(drawStep) userInfo:nil repeats:YES] retain];
    [[NSRunLoop currentRunLoop] addTimer:renderTimer forMode:NSDefaultRunLoopMode];
}

-(void)stopAnimation
{
    [renderTimer invalidate];
    [renderTimer release];
}

-(void)drawHorisontalAxis
{
    if (_horizontalAxisY == -1) {
        _horizontalAxisY = viewRect.size.height / 2;
    }
    
    CGMutablePathRef axis = CGPathCreateMutable();
    CGPathMoveToPoint(axis, nil, _verticalAxisX, _horizontalAxisY);
    CGPathAddLineToPoint(axis, nil, viewRect.size.width, _horizontalAxisY);
    
    horizontalAxisLayer.path = axis;
}

-(void)drawVerticalAxis
{
    if (_verticalAxisX == -1) {
        _verticalAxisX = 5;
    }
    
    CGMutablePathRef verticalAxis = CGPathCreateMutable();
    CGPathMoveToPoint(verticalAxis, nil, _verticalAxisX, 0);
    CGPathAddLineToPoint(verticalAxis, nil, _verticalAxisX, viewRect.size.height);
    
    verticalAxisLayer.path = verticalAxis;
    
    if (!_showVerticalMarksLabels && !_showVerticalMarks) {
        return;
    }
    
    if (yMarkStep == 0) {
        yMarkStep = maxValue / _verticalMarksMinCount;
    }
    
    int nowMarksCount = maxValue / yMarkStep;
    if (nowMarksCount > _verticalMarksMinCount * 2) {
        yMarkStep *= 2;
    }
    nowMarksCount = maxValue / yMarkStep;
    
    float value = - nowMarksCount * yMarkStep;
    
    verticalAxisLayer.sublayers = nil;
    while (value < maxValue) {
        CGFloat y = _horizontalAxisY - _horizontalAxisY * (value / maxValue);
        
        if (_showVerticalMarks) {
            CGMutablePathRef markPath = CGPathCreateMutable();
            CGPathMoveToPoint(markPath, nil, _verticalAxisX - 3, y);
            CGPathAddLineToPoint(markPath, nil, _verticalAxisX + 4, y);
            
            CAShapeLayer *markLayer = [CAShapeLayer layer];
            markLayer.path = markPath;
            markLayer.strokeColor = _verticalAxisColor.CGColor;
            markLayer.lineWidth = 1.0;
            markLayer.fillRule = kCAFillRuleNonZero;
            
            [verticalAxisLayer addSublayer:markLayer];
        }
        
        if (_showVerticalMarksLabels) {
            CATextLayer *label = [[CATextLayer alloc] init];
            [label setFont:@"Helvetica"];
            [label setFontSize: 9];
            [label setFrame: CGRectMake(1, y-5, _verticalAxisX - 5, 10)];
            [label setString:[NSString stringWithFormat:@"%.01f", value]];
            [label setAlignmentMode:kCAAlignmentRight];
            [label setForegroundColor:[[UIColor blackColor] CGColor]];
            [verticalAxisLayer addSublayer:label];
        }
        
        value += yMarkStep;
    }
    
//    [rootLayer addSublayer:verticalAxisLayer];
}

-(void)redrawPath
{
    curX = _verticalAxisX + graphLineWidth;
    [newGraphPath release];
    newGraphPath = CGPathCreateMutable();
    
    if (visibleValues.count > 0) {
        float value = [[visibleValues objectAtIndex:0] floatValue];
        curY = _horizontalAxisY - _horizontalAxisY * (value / maxValue);
    }
    
    CGPathMoveToPoint(newGraphPath, nil, curX , curY);
    CGPathAddLineToPoint(newGraphPath, nil, curX , curY);
    
    for (int valueIndex = 1; valueIndex < visibleValues.count; valueIndex++) {
        curX += _xStepSize;
        float value = [[visibleValues objectAtIndex: valueIndex] floatValue];
        curY = _horizontalAxisY - _horizontalAxisY * (value / maxValue);
        CGPathAddLineToPoint(newGraphPath, nil, curX , curY);
    }
}

-(void)drawStep
{
    [graphPath release];
    graphPath = CGPathCreateMutableCopy(newGraphPath);
    
    curX += _xStepSize;
    if (curX >= viewRect.size.width) {
        float value = [[visibleValues lastObject] floatValue];
        [visibleValues removeAllObjects];
        [visibleValues addObject:[NSNumber numberWithFloat:value]];
        
        [self redrawPath];
        [self drawVerticalAxis];
        [self drawHorisontalAxis];
    }
    
    if (stack.count > 0) {
        float value = [[stack lastObject] floatValue];
        [visibleValues addObject:[NSNumber numberWithFloat:value]];
        
        if (ABS(value) > maxValue) {
            maxValue = ABS(value);
            [self redrawPath];
            [self drawVerticalAxis];
            [self drawHorisontalAxis];
        }
        
        curY = _horizontalAxisY - _horizontalAxisY * (value / maxValue);
    }
    
    CGPathAddLineToPoint(newGraphPath, nil, curX , curY);
    
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
	animation.duration = 1 / _fps;
	animation.repeatCount = HUGE_VALF;
	animation.autoreverses = NO;
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	animation.fromValue = (id)graphPath;
	animation.toValue = (id)newGraphPath;
    animation.repeatCount = 1;
	[shapeLayer addAnimation:animation forKey:@"animatePath"];

    [stack removeAllObjects];
}

-(void)stackValue:(NSNumber *)value
{
    [stack addObject:value];
}

-(void)stackArray:(NSArray *)array
{
    [stack addObjectsFromArray:array];
}


@end
