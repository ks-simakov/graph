//
//  GraphView.h
//  graph
//
//  Created by Konstantin Simakov on 24.09.13.
//  Copyright (c) 2013 Konstantin Simakov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface GraphView : UIView
{
    CALayer	*rootLayer;
    
    CAShapeLayer *shapeLayer;
    
    CGMutablePathRef squarePath;
    CGMutablePathRef roundPath;
    CGMutablePathRef boxPath;
    
    CGMutablePathRef graphPath;
    CGMutablePathRef newGraphPath;
    
    CAShapeLayer *horizontalAxisLayer;
    CAShapeLayer *verticalAxisLayer;
    
    CGFloat curX;
    CGFloat curY;
    
    NSTimer *renderTimer;
    
    NSMutableArray *stack;
    
    CGFloat maxValue;
    
    NSMutableArray *visibleValues;
    
    CGFloat yMarkStep;
}

@property (assign) int xStepSize;           // Размер шага отрисовки значения по оси Х
@property (assign) int yStepSize;           // Размер шага отрисовки значения по оси Y
@property (assign) int fps;                 // Скорость отрисовки нового значения (кадров в секунду)

@property (assign) int horizontalAxisY;     // Координата, по которой отрисовывать ось X (по-умолчанию рисуется посередине)
@property (assign) int verticalAxisX;       // Координата, по которой отрисовывать ось Y (по-умолчанию 5)

@property (assign) BOOL flexibleMax;        // Изменять ли высоту графика при выходе из диапазона значений

@property (assign) BOOL horizontalAxisVisible;
@property (assign) BOOL verticalAxisVisible;

@property (retain) UIColor *horizontalAxisColor;
@property (retain) UIColor *verticalAxisColor;
@property (retain) UIColor *graphLineColor;

@property (assign) BOOL showVerticalMarks;
@property (assign) int verticalMarksMinCount;
@property (assign) BOOL showVerticalMarksLabels;

-(void)startAnimation;
-(void)stopAnimation;
-(void)stackValue:(NSNumber *)value;
-(void)stackArray:(NSArray *)array;

@end
