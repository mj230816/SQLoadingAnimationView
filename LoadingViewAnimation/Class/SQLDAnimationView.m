//
//  SQLDAnimationView.m
//  LoadingViewAnimation
//
//  Created by 宋千 on 16/1/20.
//  Copyright © 2016年 宋千. All rights reserved.
//

#import "SQLDAnimationView.h"
#import "CAKeyframeAnimation+AHEasing.h"
#import "easing.h"

// color
#define ANIMATION_NORMAL_COLOR      [UIColor blueColor]
#define ANIMATION_COMPLETE_COLOR    [UIColor greenColor]
#define ANIMATION_FAIL_COLOR        [UIColor redColor]

//static CGFloat const kBezierCircleControlPointKeyValue = (0.551784f);

// animationName
static NSString *const kAnimationKeyOfName = @"AnimationKeyOfName";
static NSString *const kAnimationOfNameStep0 = @"AnimationOfName0";
static NSString *const kAnimationOfNameStep1 = @"AnimationOfName1";
static NSString *const kAnimationOfNameStep2 = @"AnimationOfName2";
static NSString *const kAnimationOfNameStep3 = @"AnimationOfName3";
static NSString *const kAnimationOfNameStep4Circle  = @"AnimationOfName4Circle";    // circleLayer上的动画
static NSString *const kAnimationOfNameStep4Drop    = @"AnimationOfName4Drop";      // dropLineLayer上的动画
static NSString *const kAnimationOfNameStep5Circle  = @"AnimationOfName5Circle";    // circleLayer上的动画
static NSString *const kAnimationOfNameStep5Drop    = @"AnimationOfName5Drop";      // dropLineLayer上的动画
static NSString *const kAnimationOfNameStep6Success = @"AnimationOfName6Success";   // 成功
static NSString *const kAnimationOfNameStep6Fail    = @"AnimationOfName6Fail";      // 失败

// layerAnimationKey
static NSString *const kLayerAnimationKeyOfStep0 = @"AnimationKeyOfStep0";
static NSString *const kLayerAnimationKeyOfStep1 = @"AnimationKeyOfStep1";
static NSString *const kLayerAnimationKeyOfStep2 = @"AnimationKeyOfStep2";
static NSString *const kLayerAnimationKeyOfStep3 = @"AnimationKeyOfStep3";
static NSString *const kLayerAnimationKeyOfStep4Circle  = @"AnimationKeyOfStep4Circle";     // circleLayer上的动画
static NSString *const kLayerAnimationKeyOfStep4Drop    = @"AnimationKeyOfStep4Drop";       // dropLineLayer上的动画
static NSString *const kLayerAnimationKeyOfStep5Circle  = @"AnimationKeyOfStep5Circle";     // circleLayer上的动画
static NSString *const kLayerAnimationKeyOfStep5Drop    = @"AnimationKeyOfStep5Drop";       // dropLineLayer上的动画
static NSString *const kLayerAnimationKeyOfStep6Success = @"AnimationKeyOfStep6Success";    // 成功
static NSString *const kLayerAnimationKeyOfStep6Fail    = @"AnimationKeyOfStep6Fail";       // 失败

// originalityLength
static CGFloat const kOriginalityLength = 100.0f;

// time
static CGFloat const kSQLDAnimationSpeed = 2.0f;
static CGFloat const kSQLDAnimationCompletedStep0During = 1.00f / kSQLDAnimationSpeed;
static CGFloat const kSQLDAnimationCompletedStep1During = 0.75f / kSQLDAnimationSpeed;
static CGFloat const kSQLDAnimationCompletedStep2During = 0.45f / kSQLDAnimationSpeed;
static CGFloat const kSQLDAnimationCompletedStep3During = 0.25f / kSQLDAnimationSpeed;
static CGFloat const kSQLDAnimationCompletedStep4During = 0.35f / kSQLDAnimationSpeed;
static CGFloat const kSQLDAnimationCompletedStep5During = 0.40f / kSQLDAnimationSpeed;
static CGFloat const kSQLDAnimationCompletedStep6During = 0.80f / kSQLDAnimationSpeed;

static CGFloat const kSQLDAnimationTotalDuring =
kSQLDAnimationCompletedStep1During + kSQLDAnimationCompletedStep2During +
kSQLDAnimationCompletedStep3During + kSQLDAnimationCompletedStep4During +
kSQLDAnimationCompletedStep5During + kSQLDAnimationCompletedStep6During ;


// line
static CGFloat const kSQLDOutCircleLineWidth = 30.0f;

// distance
static CGFloat const KSQLDCircleOffsetDistance = 18.0f;

@interface SQLDAnimationView ()


//-----------------Layer

// 外圆layer
@property (nonatomic) CAShapeLayer *circleLayer;
// 抛物线layer
@property (nonatomic) CAShapeLayer *parabolaLayer;
// 下落直线layer
@property (nonatomic) CAShapeLayer *dropLineLayer;
// 内部layer
@property (nonatomic) CAShapeLayer *contentLayer;

//-----------------Data

// 状态
@property (nonatomic) SQLDAnimationState state;

@end



@implementation SQLDAnimationView

- (void)dealloc {
    
    [self.circleLayer removeAllAnimations];
    [self.parabolaLayer removeAllAnimations];
    [self.dropLineLayer removeAllAnimations];
    [self.contentLayer removeAllAnimations];
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self initSelf];
        
    }
    return self;
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        [self initSelf];
    }
    
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

#pragma mark - public method

- (void)stop {
    [self resetSelf];
}

/**
 *  正在加载
 */
- (void)loading {
    
    // 为了保持动画完整性，将在整个动画完成后才可以再度加载
    if (self.state == SQLDAnimationStateOfSuccess ||
        self.state == SQLDAnimationStateOfFail) {
        return;
    }
    
    // 开始加载
    [self resetSelf];
    self.state = SQLDAnimationStateOfNormal;
    [self animationOfALoop];
}

/**
 *  加载成功
 *
 *  @param block 成功后的回调block
 */
- (void)loadingSuccessedCompletedBlock:(void(^)(void))block {
    
    self.state = SQLDAnimationStateOfSuccess;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kSQLDAnimationTotalDuring * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        block();
    });
}

/**
 *  加载失败
 *
 *  @param block 失败后的回调block
 */
- (void)loadingFailedCompletedBlock:(void(^)(void))block {
    
    self.state = SQLDAnimationStateOfFail;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kSQLDAnimationTotalDuring * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        block();
    });
    
}

#pragma mark - private method

/**
 *  移除layer上的动画，并且将其从父layer上移除
 *
 *  @param layer 需要移除的layer
 */
+ (void)removeLayerFormSuperLayer:(CALayer *)layer {
    
    [layer removeAllAnimations];
    [layer removeFromSuperlayer];
    layer = nil;
}

- (void)initSelf {
    
    // 仅仅考虑到线段宽度的
    CGFloat scale = (100.0f - kSQLDOutCircleLineWidth / 2) / 100.0f;
    self.layer.sublayerTransform = CATransform3DMakeScale(scale, scale, 1);
    
    [self resetSelf];
    
}

/**
 *  重置状态
 */
- (void)resetSelf {
    
    self.state = SQLDAnimationStateOfNothing;
    
    // 移除所有layer
    [SQLDAnimationView removeLayerFormSuperLayer:self.circleLayer];
    [SQLDAnimationView removeLayerFormSuperLayer:self.parabolaLayer];
    [SQLDAnimationView removeLayerFormSuperLayer:self.dropLineLayer];
    [SQLDAnimationView removeLayerFormSuperLayer:self.contentLayer];
    
    // 初始化circleLayer
    if (![self.layer.sublayers containsObject:self.circleLayer]) {
        [self.layer addSublayer:self.circleLayer];
    }
    
    UIBezierPath *oval = [UIBezierPath bezierPath];
    [oval moveToPoint:CGPointMake(0, 32.075)];
    // 动画初始 -》 动画完成
    // 第三区间 -》 第一区间
    [oval addCurveToPoint:CGPointMake(32.093, 64.149)
            controlPoint1:CGPointMake(-0, 49.789)
            controlPoint2:CGPointMake(14.369, 64.149)];
    // 第四区间 -》第二区间
    [oval addCurveToPoint:CGPointMake(64.186, 32.075)
            controlPoint1:CGPointMake(49.818, 64.149)
            controlPoint2:CGPointMake(64.186, 49.789)];
    // 第一区间 -》第三区间
    [oval addCurveToPoint:CGPointMake(32.093, 0)
            controlPoint1:CGPointMake(64.186, 14.36)
            controlPoint2:CGPointMake(49.818, -0)];
    // 第二区间 -》第四区间
    [oval addCurveToPoint:CGPointMake(0, 32.075)
            controlPoint1:CGPointMake(14.369, -0)
            controlPoint2:CGPointMake(-0, 14.36)];
    
    [self zoomPath:oval];
    self.circleLayer.lineWidth = kSQLDOutCircleLineWidth;
    self.circleLayer.path = oval.CGPath;
    self.circleLayer.strokeStart = 0.125f * 0;
    self.circleLayer.strokeEnd = 0.125f * 1;
    
}

#pragma mark stpe0
/**
 *  外圈转动的动画（一个Loop）
 */
- (void)animationOfALoop {
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.rotation.z";
    animation.toValue = @(-M_PI * 2);
    animation.duration = kSQLDAnimationCompletedStep0During;
    animation.delegate = self;
    [animation setValue:kAnimationOfNameStep0
                 forKey:kAnimationKeyOfName];
    [self.circleLayer addAnimation:animation
                            forKey:kLayerAnimationKeyOfStep0];
}


#pragma mark stpe1
- (void)animationOfBecomeACircle {
    
    // 圆环合闭
    CABasicAnimation *animationTransform = [CABasicAnimation animation];
    animationTransform.keyPath = @"transform.rotation.z";
    animationTransform.toValue = @(-M_PI);
    
    // 圆环转动
    CABasicAnimation *animationStrokeEnd = [CABasicAnimation animation];
    animationStrokeEnd.keyPath = @"strokeEnd";
    animationStrokeEnd.toValue = @(1.0f);
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.delegate = self;
    [animationGroup setValue:kAnimationOfNameStep1
                      forKey:kAnimationKeyOfName];
    animationGroup.removedOnCompletion = NO;
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.duration = kSQLDAnimationCompletedStep1During;
    animationGroup.animations = @[animationStrokeEnd,animationTransform];
    
    [self.circleLayer addAnimation:animationGroup
                            forKey:kLayerAnimationKeyOfStep1];
    
}


#pragma mark stpe2
- (void)animationOfParabola {
    
    // 配置parabolaLayer
    if (![self.layer.sublayers containsObject:self.parabolaLayer]) {
        [self.layer addSublayer:self.parabolaLayer];
    }
    
    UIBezierPath *parabola = [UIBezierPath bezierPath];
    [parabola moveToPoint:CGPointMake(32.29, 67.614)];
    [parabola addCurveToPoint:CGPointMake(15.529, 8.396)
                controlPoint1:CGPointMake(32.29, 42.092)
                controlPoint2:CGPointMake(25.519, 19.877)];
    [parabola addCurveToPoint:CGPointMake(0, 0.088)
                controlPoint1:CGPointMake(10.922, 3.1)
                controlPoint2:CGPointMake(5.629, 0.088)];
    
    
    
    [self zoomPath:parabola];
    
    self.parabolaLayer.lineWidth = kSQLDOutCircleLineWidth;
    self.parabolaLayer.path = parabola.CGPath;
    self.parabolaLayer.strokeStart = 0.125f * 0;
    self.parabolaLayer.strokeEnd = 0.125f * 1;
    
    // animation
    CABasicAnimation *strokeStartAnimation = [CABasicAnimation
                                              animationWithKeyPath:@"strokeStart"];
    strokeStartAnimation.toValue = @(1.0 - 0.03125);
    
    CABasicAnimation *strokeEndAnimation = [CABasicAnimation
                                            animationWithKeyPath:@"strokeEnd"];
    strokeEndAnimation.toValue = @(1.0);
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[strokeEndAnimation, strokeStartAnimation];
    animationGroup.timingFunction = [CAMediaTimingFunction
                                     functionWithControlPoints:0.3 :1
                                     :0.3 :1];
    animationGroup.duration = kSQLDAnimationCompletedStep2During;
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    animationGroup.delegate = self;
    [animationGroup setValue:kAnimationOfNameStep2
                      forKey:kAnimationKeyOfName];
    [self.parabolaLayer addAnimation:animationGroup
                              forKey:kLayerAnimationKeyOfStep2];
}

#pragma mark stpe4
- (void)animationOfDropToCircle {
    
    // 配置dropLineLayer
    if (![self.layer.sublayers containsObject:self.dropLineLayer]) {
        [self.layer addSublayer:self.dropLineLayer];
    }
    
    // animation
    CABasicAnimation *animation = [CABasicAnimation
                                   animationWithKeyPath:@"transform.translation.y"];
    animation.byValue = @(35.0 * [self zoomScale] - kSQLDOutCircleLineWidth / 2);
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[animation];
    animationGroup.duration = kSQLDAnimationCompletedStep3During;
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    animationGroup.delegate = self;
    [animationGroup setValue:kAnimationOfNameStep3
                      forKey:kAnimationKeyOfName];
    [self.dropLineLayer addAnimation:animationGroup
                              forKey:kLayerAnimationKeyOfStep3];
}

#pragma mark stpe4
- (void)animationOfDropInCircle {
    
    [self animationOfDropInCircleForCircle];
    [self animationOfDropInCircleForBlock];
    
}


/**
 *  step4 circleLayer上的动画
 */
- (void)animationOfDropInCircleForCircle {
    
    // animation
    NSUInteger keyCount = 30;
    CGFloat distance = KSQLDCircleOffsetDistance;
    
    // Circle变形的动画
    CAKeyframeAnimation *animationOfCircle = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    NSMutableArray *keyValues = [NSMutableArray arrayWithCapacity:keyCount];
    for (int i = 1; i <= keyCount; i ++) {
        
        // 插值公式
        CGFloat start = 0.0f;
        CGFloat end = distance;
        CGFloat t = (i * 1.0f / keyCount);
        CGFloat interValue = start + (end - start) * CubicEaseOut(t);
        UIBezierPath *path = [self step4KeyframeAnimationWithT:interValue];
        [self zoomPath:path];
        [keyValues addObject:(__bridge id)path.CGPath];
    }
    animationOfCircle.values = keyValues;
    
    // 圆圈下震动画
    CABasicAnimation *animationOfBlock = [CABasicAnimation animation];
    animationOfBlock.keyPath = @"transform.translation.y";
    animationOfBlock.byValue = @(distance);
    
    // animationGroup
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[animationOfBlock,animationOfCircle];
    animationGroup.delegate = self;
    animationGroup.duration = kSQLDAnimationCompletedStep4During;
    [animationGroup setValue:kAnimationOfNameStep4Circle
                      forKey:kAnimationKeyOfName];
    animationGroup.removedOnCompletion = NO;
    animationGroup.fillMode = kCAFillModeForwards;
    [self.circleLayer addAnimation:animationGroup
                            forKey:kLayerAnimationKeyOfStep4Circle];
}

/**
 *  step4 dropLine上的动画
 */
- (void)animationOfDropInCircleForBlock {
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.translation.y";
    animation.byValue = @(32.0f * [self zoomScale] + 30.0f);
    animation.duration = kSQLDAnimationCompletedStep4During;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [animation setValue:kAnimationOfNameStep4Drop
                 forKey:kAnimationKeyOfName];
    animation.delegate = self;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [self.dropLineLayer addAnimation:animation
                              forKey:kLayerAnimationKeyOfStep4Drop];
    
}


/**
 *  根据插值公式给定step4中圆的path
 *
 *  @param t 0.0 - 1.0
 *
 *  @return 当前t所对应的UIBezierPath
 */
- (UIBezierPath *)step4KeyframeAnimationWithT:(CGFloat)t {
    
    CGFloat changeLength = t;
    
    UIBezierPath *oval = [UIBezierPath bezierPath];
    [oval moveToPoint:CGPointMake(64.186, 32.075)];
    // 3
    [oval addCurveToPoint:CGPointMake(32.093, 0)
            controlPoint1:CGPointMake(64.186, 14.36)
            controlPoint2:CGPointMake(49.818, 0)];
    // 2
    [oval addCurveToPoint:CGPointMake(-0, 32.075)
            controlPoint1:CGPointMake(14.369, 0)
            controlPoint2:CGPointMake(-0, 14.36)];
    // 1
    [oval addCurveToPoint:CGPointMake(32.093, 64.149 - changeLength)
            controlPoint1:CGPointMake(0, 49.789)
            controlPoint2:CGPointMake(14.369, 64.149 - changeLength)];
    // 4
    [oval addCurveToPoint:CGPointMake(64.186, 32.075)
            controlPoint1:CGPointMake(49.818, 64.149 - changeLength)
            controlPoint2:CGPointMake(64.186, 49.789)];
    
    return oval;
}

#pragma mark stpe5
/**
 *  step5 circleLayer上的动画
 */
- (void)animationOfPreparedForCircle {
    
    // animation
    NSUInteger keyCount = 30;
    CGFloat distance = KSQLDCircleOffsetDistance;
    
    // Circle弹簧的动画
    CAKeyframeAnimation *animationOfCircle = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    
    NSMutableArray *keyValues = [NSMutableArray arrayWithCapacity:keyCount];
    for (int i = 1; i <= keyCount; i ++) {
        
        // 插值公式
        CGFloat start = distance;
        CGFloat end = 0.0f;
        CGFloat t = (i * 1.0f / keyCount);
        CGFloat interValue = start + (end - start) * BounceEaseOut(t);
        UIBezierPath *path = [self step4KeyframeAnimationWithT:interValue];
        [self zoomPath:path];
        [keyValues addObject:(__bridge id)path.CGPath];
    }
    animationOfCircle.values = keyValues;
    
    // 圆圈位置恢复动画
    CABasicAnimation *animationOfBlock = [CABasicAnimation animation];
    animationOfBlock.keyPath = @"transform.translation.y";
    animationOfBlock.byValue = @(-distance);
    
    // 圆圈的颜色动画
    CABasicAnimation *animationOfColor = [CABasicAnimation animation];
    animationOfColor.keyPath = @"strokeColor";
    if (self.state == SQLDAnimationStateOfSuccess) {
        animationOfColor.toValue = (__bridge id)ANIMATION_COMPLETE_COLOR.CGColor;
    } else {
        animationOfColor.toValue = (__bridge id)ANIMATION_FAIL_COLOR.CGColor;
    }
    
    
    // animationGroup
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[animationOfCircle,
                                  animationOfBlock,
                                  animationOfColor];
    animationGroup.delegate = self;
    animationGroup.duration = kSQLDAnimationCompletedStep5During;
    [animationGroup setValue:kAnimationOfNameStep5Circle
                      forKey:kAnimationKeyOfName];
    animationGroup.removedOnCompletion = NO;
    animationGroup.fillMode = kCAFillModeForwards;
    [self.circleLayer addAnimation:animationGroup
                            forKey:kLayerAnimationKeyOfStep5Circle];
}

/**
 *  step5 dropLine上的动画
 */
- (void)animationOfDropBecomeToADot{
    
    // animation
    CABasicAnimation *animationOfRotation = [CABasicAnimation animation];
    animationOfRotation.keyPath = @"transform.rotation";
    animationOfRotation.toValue = @(M_PI_4 + M_PI * 2.0f);
    
    CABasicAnimation *animationOfScale = [CABasicAnimation animation];
    animationOfScale.keyPath = @"transform.scale";
    animationOfScale.toValue = @(0.0f);
    
    CABasicAnimation *animationOfColor = [CABasicAnimation animation];
    animationOfColor.keyPath = @"backgroundColor";
    if (self.state == SQLDAnimationStateOfSuccess) {
        animationOfColor.toValue = (__bridge id)ANIMATION_COMPLETE_COLOR.CGColor;
    } else {
        animationOfColor.toValue = (__bridge id)ANIMATION_FAIL_COLOR.CGColor;
    }
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = kSQLDAnimationCompletedStep5During * 0.75f;
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [animationGroup setValue:kAnimationOfNameStep5Drop
                           forKey:kAnimationKeyOfName];
    animationGroup.delegate = self;
    animationGroup.removedOnCompletion = NO;
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.animations = @[animationOfRotation,
                                  animationOfScale,
                                  animationOfColor];
    
    [self.dropLineLayer addAnimation:animationGroup
                              forKey:kLayerAnimationKeyOfStep5Drop];
}

#pragma mark stpe6
/**
 *  content成功动画（对勾）
 */
- (void)animationOfDrawARight {
    
    if (![self.layer.sublayers containsObject:self.contentLayer]) {
        [self.layer addSublayer:self.contentLayer];
    }
    
    // 画对勾
    self.contentLayer.strokeColor = ANIMATION_COMPLETE_COLOR.CGColor;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(14.917, 35.356)];
    [path addLineToPoint:CGPointMake(29.065, 46.338)];
    [path addLineToPoint:CGPointMake(54.643, 22.456)];
    
    
    // 等比例缩放
    [self zoomPath:path];
    _contentLayer.path = path.CGPath;
    
    CAKeyframeAnimation *animationX = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.x"
                                                                      function:BounceEaseOut
                                                                     fromValue:0.1
                                                                       toValue:1.0];
    CAKeyframeAnimation *animationY = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.y"
                                                                      function:BounceEaseOut
                                                                     fromValue:0.1
                                                                       toValue:1.0];
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[animationX,animationY];
    animationGroup.duration = kSQLDAnimationCompletedStep6During;
    animationGroup.delegate = self;
    [animationGroup setValue:kAnimationOfNameStep6Fail
                      forKey:kAnimationKeyOfName];
    [self.contentLayer addAnimation:animationGroup
                             forKey:kLayerAnimationKeyOfStep6Fail];
    
}

/**
 *  content失败动画（叹号）
 */
- (void)animationOfDrawAWarning {
    
    if (![self.layer.sublayers containsObject:self.contentLayer]) {
        [self.layer addSublayer:self.contentLayer];
    }
    
    // 画叹号
    _contentLayer.strokeColor = ANIMATION_FAIL_COLOR.CGColor;
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    /// Warningdotpath drawing
    UIBezierPath *warningDotPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(30.593,
                                                                                     47.239,
                                                                                     3,
                                                                                     2.9531)];
    
    //// Warningverticalpath drawing
    UIBezierPath *warningVerticalPath = [UIBezierPath bezierPath];
    [warningVerticalPath moveToPoint:CGPointMake(32.125, 13.957)];
    [warningVerticalPath addCurveToPoint:CGPointMake(29.125, 16.63)
                           controlPoint1:CGPointMake(31.346, 13.957)
                           controlPoint2:CGPointMake(29.658, 13.974)];
    [warningVerticalPath addCurveToPoint:CGPointMake(31.929, 42.48)
                           controlPoint1:CGPointMake(28.523, 19.624)
                           controlPoint2:CGPointMake(31.929, 37.687)];
    [warningVerticalPath moveToPoint:CGPointMake(32.131, 42.48)];
    [warningVerticalPath addCurveToPoint:CGPointMake(35.059, 16.63)
                           controlPoint1:CGPointMake(32.131, 37.588)
                           controlPoint2:CGPointMake(35.683, 19.63)];
    [warningVerticalPath addCurveToPoint:CGPointMake(32.125, 13.957)
                           controlPoint1:CGPointMake(34.531, 14.084)
                           controlPoint2:CGPointMake(32.885, 13.957)];
    
    [path appendPath:warningDotPath];
    [path appendPath:warningVerticalPath];
    // 等比例缩放
    [self zoomPath:path];
    self.contentLayer.path = path.CGPath;
    
    CAKeyframeAnimation *animationX = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.x"
                                                                       function:BounceEaseOut
                                                                      fromValue:0.1
                                                                        toValue:1.0];
    CAKeyframeAnimation *animationY = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.y"
                                                                       function:BounceEaseOut
                                                                      fromValue:0.1
                                                                        toValue:1.0];
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.delegate = self;
    animationGroup.animations = @[animationX,animationY];
    animationGroup.duration = kSQLDAnimationCompletedStep6During;
    [animationGroup setValue:kAnimationOfNameStep6Success
                      forKey:kAnimationKeyOfName];
    [self.contentLayer addAnimation:animationGroup
                             forKey:kLayerAnimationKeyOfStep6Success];
    
}

#pragma mark - 缩放处理
/**
 *  缩放比例
 */
- (CGFloat)zoomScale {
    
    CGFloat currentLength = MIN(CGRectGetWidth(self.bounds),
                                CGRectGetHeight(self.bounds));
    // 不考虑线段宽度
    CGFloat zoomScale = (currentLength / kOriginalityLength);
    return zoomScale;
    
}

/**
 *  按照现在bounds缩放path
 */
- (void)zoomPath:(UIBezierPath *)path {
    
    // path缩放比例
    CGFloat applyTransformScale = [self zoomScale];
    
    // 缩放path
    [path applyTransform:CGAffineTransformMakeScale(applyTransformScale,
                                                    applyTransformScale)];
}

- (void)zoomFrameWithLayer:(CALayer *)layer {
    
    // 缩放比例
    CGFloat zoomScale = [self zoomScale];
    
    CGRect otherFrame = CGRectMake(CGRectGetMinX(layer.frame) * zoomScale,
                                   CGRectGetMinY(layer.frame) * zoomScale,
                                   CGRectGetWidth(layer.frame) * zoomScale,
                                   CGRectGetHeight(layer.frame) * zoomScale);
    
    // 已经缩放过了
    if (CGRectContainsRect(layer.frame, otherFrame)) {
        return;
    }
    
    layer.frame = otherFrame;
    
}

#pragma mark - CAAniamtionDelegate

- (void)animationDidStart:(CAAnimation *)anim {
    
    NSString *animationName = [anim valueForKey:kAnimationKeyOfName];
    
    if ([animationName isEqualToString:kAnimationOfNameStep1]) {
        [SQLDAnimationView removeLayerFormSuperLayer:self.contentLayer];
    }
    
    if ([animationName isEqualToString:kAnimationOfNameStep3]) {
        [self.parabolaLayer removeAnimationForKey:kLayerAnimationKeyOfStep2];
        [self.parabolaLayer removeFromSuperlayer];
    }
    
    if ([animationName isEqualToString:kAnimationOfNameStep6Fail] ||
        [animationName isEqualToString:kAnimationOfNameStep6Success]) {
        [self.dropLineLayer removeAllAnimations];
        [self.dropLineLayer removeFromSuperlayer];
    }
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    // 如果动画变成“停止”则强制回到初始值
    if (self.state == SQLDAnimationStateOfNothing) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.circleLayer.transform = CATransform3DIdentity;
        [CATransaction commit];
        return;
    }
    
    
    
    // 各部分动画结束处理
    NSString *animationName = [anim valueForKey:kAnimationKeyOfName];
    NSLog(@"\nStop Animation Key Of Name:%@",animationName);
    
    // step 0
    if ([animationName isEqualToString:kAnimationOfNameStep0]) {
        
        [self loadingAnimationCompleteToALoopNeedRepeat:flag];
        
    }
    
    // step1
    if ([animationName isEqualToString:kAnimationOfNameStep1]) {
        
        [self loadingAnimationCompletedToParabola];
        
    }
    
    // step2
    if ([animationName isEqualToString:kAnimationOfNameStep2]) {
        
        [self animationOfDropToCircle];
    }
    
    // step3
    if ([animationName isEqualToString:kAnimationOfNameStep3]) {
        
        [self animationOfDropInCircle];
    }
    
    // step4
    if ([animationName isEqualToString:kAnimationOfNameStep4Circle]) {
        [self animationOfPreparedForCircle];
    }
    
    if ([animationName isEqualToString:kAnimationOfNameStep4Drop]) {
        [self animationOfDropBecomeToADot];
    }
    
    // step5
    if ([animationName isEqualToString:kAnimationOfNameStep5Circle]) {
        
    }
    
    if ([animationName isEqualToString:kAnimationOfNameStep5Drop]) {
        
        if (self.state == SQLDAnimationStateOfSuccess) {
            [self animationOfDrawARight];
        } else {
            [self animationOfDrawAWarning];
        }
    }
    
    // step6
    if ([animationName isEqualToString:kAnimationOfNameStep6Success]) {
        self.state = SQLDAnimationStateOfCompleted;
    }
    
    if ([animationName isEqualToString:kAnimationOfNameStep6Fail]) {
        self.state = SQLDAnimationStateOfCompleted;
    }
}

/**
 *  加载动画完成了一个loop
 */
- (void)loadingAnimationCompleteToALoopNeedRepeat:(BOOL)repeat {
    
    
    if (self.state == SQLDAnimationStateOfNormal) {
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.circleLayer.transform = CATransform3DIdentity;
        [CATransaction commit];
        
        if (repeat) {
            [self animationOfALoop];
        }
        
    } else {
        
        [self animationOfBecomeACircle];
    }
    
}

/**
 *  完成step1 -》 step2
 */
- (void)loadingAnimationCompletedToParabola {
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.circleLayer.strokeStart = 0.0f;
    self.circleLayer.strokeEnd = 1.0f;
    [CATransaction commit];
    
    [self animationOfParabola];
}

#pragma mark - setter


#pragma mark - getter
- (CAShapeLayer *)circleLayer {
    
    if (!_circleLayer) {
        _circleLayer = [CAShapeLayer layer];
        _circleLayer.frame = CGRectMake(18.0f, 35.0f,
                                        64.0, 64.0f);
        _circleLayer.contentsScale = [UIScreen mainScreen].scale;
        _circleLayer.strokeColor = ANIMATION_NORMAL_COLOR.CGColor;
        
        UIColor *backgroundColor;
        backgroundColor = [UIColor clearColor];
        if (self.selfBackgroundColor) {
            backgroundColor = self.selfBackgroundColor;
        }
        _circleLayer.fillColor = backgroundColor.CGColor;
        [self zoomFrameWithLayer:_circleLayer];
    }
    
    return _circleLayer;
}

- (CAShapeLayer *)parabolaLayer {
    
    if (!_parabolaLayer) {
        _parabolaLayer = [CAShapeLayer layer];
        _parabolaLayer.frame = CGRectMake(50.0f, 0.0f,
                                          32.0, 68.0f);
        _parabolaLayer.contentsScale = [UIScreen mainScreen].scale;
        _parabolaLayer.strokeColor = ANIMATION_NORMAL_COLOR.CGColor;
        _parabolaLayer.fillColor = [UIColor clearColor].CGColor;
        [self zoomFrameWithLayer:_parabolaLayer];

    }
    
    return _parabolaLayer;
    
}

- (CAShapeLayer *)dropLineLayer {
    
    if (!_dropLineLayer) {
        _dropLineLayer = [CAShapeLayer layer];
        _dropLineLayer.frame = CGRectMake((self.frame.size.width - kSQLDOutCircleLineWidth) / 2,
                                          0,
                                          kSQLDOutCircleLineWidth,
                                          kSQLDOutCircleLineWidth);
        _dropLineLayer.contentsScale = [UIScreen mainScreen].scale;
        _dropLineLayer.backgroundColor = ANIMATION_NORMAL_COLOR.CGColor;
    }
    
    return _dropLineLayer;
    
}

- (CAShapeLayer *)contentLayer {
    
    if (!_contentLayer) {
        _contentLayer = [CAShapeLayer layer];
        _contentLayer.contentsScale = [UIScreen mainScreen].scale;
        _contentLayer.frame = CGRectMake(18.0f, 35.0f,
                                        64.0, 64.0f);
        [self zoomFrameWithLayer:_contentLayer];
    }
    
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if (self.state == SQLDAnimationStateOfFail) {
        // 配置锚点
        CGRect frame = _contentLayer.frame;
        _contentLayer.anchorPoint = CGPointMake(0.5f,0.5f);
        _contentLayer.frame = frame;
        
        // 线段长度
        _contentLayer.lineWidth = 1.0f;
        
        // 颜色
        _contentLayer.fillColor = ANIMATION_FAIL_COLOR.CGColor;
    } else {
        
        // 配置锚点
        CGRect frame = _contentLayer.frame;
        _contentLayer.anchorPoint = CGPointMake(29.065f / 64.0f,
                                                46.338f / 64.0f);
        _contentLayer.frame = frame;
        
        // 线段长度
        _contentLayer.lineWidth = kSQLDOutCircleLineWidth;
        
        // 颜色
        UIColor *backgroundColor;
        backgroundColor = [UIColor clearColor];
        if (self.selfBackgroundColor) {
            backgroundColor = self.selfBackgroundColor;
        }

        _contentLayer.fillColor = backgroundColor.CGColor;
        
    }
    [CATransaction commit];
    
    return _contentLayer;
    
}

@end









