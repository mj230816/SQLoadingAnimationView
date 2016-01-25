//
//  SQLDAnimationView.h
//  LoadingViewAnimation
//
//  Created by 宋千 on 16/1/20.
//  Copyright © 2016年 宋千. All rights reserved.
//

/**
 *  逃避了的问题
 *
 *  动画结束后block的回调
 */

/**
 *  step0 一个1/8圆的弧在转动
 *  step1 圆弧-》圆
 *  step2 抛物线
 *  step3 下落至圆的边
 *  step4 圆变形 + 点到达圆心
 *  step5 圆弹回 + 点变成对勾的初始状态
 *  step6 完成-》对勾，失败-》叹号
 */

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SQLDAnimationState) {
    
    SQLDAnimationStateOfSuccess     = 1 << 0,    // 加载成功
    SQLDAnimationStateOfFail        = 1 << 1,    // 加载失败
    SQLDAnimationStateOfNormal      = 1 << 2,    // 已经在加载
    SQLDAnimationStateOfNothing     = 1 << 3,    // 没有开始加载
    SQLDAnimationStateOfCompleted   = 1 << 4,    // 动画已经完成
};


@interface SQLDAnimationView : UIView

/**
 *  推荐配置非透明值
 *  默认值是clearColor，如果设定背景颜色将有助于动画更加流畅
 *  以及减少所占用的内存
 */
@property (nonatomic) UIColor *selfBackgroundColor;

@property (nonatomic,readonly) SQLDAnimationState state;

/**
 *  用于停止
 */
- (void)stop;

/**
 *  正在加载
 *  在loading状态下再次调用-loading，则从开始状态加载
 */
- (void)loading;

/**
 *  加载成功
 *
 *  @param block 成功动画完成后的回调block
 */
- (void)loadingSuccessedCompletedBlock:(void(^)(void))block;

/**
 *  加载失败
 *
 *  @param block 失败动画完成后的回调block
 */
- (void)loadingFailedCompletedBlock:(void(^)(void))block;


@end
