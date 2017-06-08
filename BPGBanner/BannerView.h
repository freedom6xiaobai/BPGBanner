//
//  BannerView.h
//  BPGBanner
//
//  Created by baipeng on 2017/6/8.
//  Copyright © 2017年 BPG. All rights reserved.
//

#import <UIKit/UIKit.h>

//page 样式
typedef NS_ENUM(NSInteger,PageControlStyle) {
    pageControlColor = 0,//颜色
    pageControlImage //图片
};
//
typedef NS_ENUM(NSInteger,PageControlAlignment) {
    PageControlAlignmentLeft = 0,//左
    PageControlAlignmentRight,  //右
    PageControlAlignmentCenter //中
};


@class BannerView;
@protocol BannerViewDelegate <NSObject>
@optional
- (void)bannerView:(BannerView *)bannerView didClickedImageIndex:(NSInteger)index;
@end

@interface BannerView : UIView
/**
 轮播图

 @param frame frame
 @param delegate delegate
 @param imageURLs 图片数组
 @param placeholderImage 占位图
 @param timeInterval 时间
 @return 轮播图view
 */
+ (instancetype)bannerViewWithFrame:(CGRect)frame
                           delegate:(id<BannerViewDelegate>)delegate
                          imageURLs:(NSArray *)imageURLs
                   placeholderImage:(NSString *)placeholderImage
                      timerInterval:(NSInteger)timeInterval;


/**
 page 样式
 @param pageControlStyle 类型
 @Param pageAlignment 对齐
 @param currentPageIndicatorTintColor 点击颜色
 @param pageIndicatorTintColor  page内容颜色
 @param currentPageIndicatorTintImage 点击图片
 @param pageIndicatorTintImage page内容图片
 */
-(void)bannerViewWithPageControlStyle:(PageControlStyle)pageControlStyle
             withPageControlAlignment:(PageControlAlignment)pageAlignment
    withCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor
           withPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor
    withCurrentPageIndicatorTintImage:(NSString *)currentPageIndicatorTintImage
           withPageIndicatorTintImage:(NSString *)pageIndicatorTintImage;


@end
