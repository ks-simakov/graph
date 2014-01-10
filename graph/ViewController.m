//
//  ViewController.m
//  graph
//
//  Created by Konstantin Simakov on 24.09.13.
//  Copyright (c) 2013 Konstantin Simakov. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

int value = 0;

@implementation ViewController

- (void)loadView
{
    CGRect viewRect = [[UIScreen mainScreen] bounds];
    
    UIView *view = [[[UIView alloc] initWithFrame:viewRect] autorelease];
    view.backgroundColor = [UIColor colorWithRed:0.241 green:0.869 blue:0.558 alpha:1.000];
    
    graphView = [[GraphView alloc] initWithFrame:CGRectMake(0, 75, viewRect.size.width, viewRect.size.height - 150)];
    graphView.xStepSize = 3;
    graphView.yStepSize = 1;
    graphView.horizontalAxisY = -1;                     // Y-координата оси X (если -1, то будет посередине)
    graphView.verticalAxisX = 10;                       // X-координата оси Y (по-умолчанию 5)
    graphView.fps = 15;                                 // Скорость отрисовки графика (frames per second)
    graphView.flexibleMax = YES;                        // Автоматическое масштабирование графика, если значения выходят за пределы графика
    graphView.backgroundColor = [UIColor grayColor];     // Цвет фона графика
//    graphView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed: @"cat.jpeg"]];         // Картинка на фоне графика
    graphView.horizontalAxisVisible = YES;              // Видимость оси Х
    graphView.verticalAxisVisible = YES;                // Видимость оси Y
    graphView.horizontalAxisColor = [UIColor redColor]; // Цвет оси Х
    graphView.verticalAxisColor = [UIColor redColor];   // Цвет оси Y
    graphView.graphLineColor = [UIColor yellowColor];   // Цвет графика
    graphView.showVerticalMarks = YES;                  // Видимость засечек по оси Y
    graphView.showVerticalMarksLabels = NO;             // Видимость подписей по оси Y
    graphView.verticalMarksMinCount = 5;                // Минимальное кол-во засечек по оси Y
    [view addSubview:graphView];
    
    self.view = view;
    
    NSTimer *generatorTimer = [[NSTimer timerWithTimeInterval:(1.0 / 15) target:self selector:@selector(generateData) userInfo:nil repeats:YES] retain];
    [[NSRunLoop currentRunLoop] addTimer:generatorTimer forMode:NSDefaultRunLoopMode];
    
    [graphView startAnimation];
//    [graphView stopAnimation];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void)generateData
{
    int maxRandom = 20;
    int minRandom = -20;
    
    value += rand() % (maxRandom - minRandom) + minRandom;
    
//    [graphView stackValue:[NSNumber numberWithInt:value]];
    
    NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithInt:value], nil];
    [graphView stackArray:values]; //TODO
}

- (void)dealloc 
{
    [super dealloc];
}

@end
