//
//  BannerView.m
//  BPGBanner
//
//  Created by baipeng on 2017/6/8.
//  Copyright © 2017年 BPG. All rights reserved.
//

#import "BannerView.h"
#import "UIImageView+WebCache.h"

#define KScreenWidth [UIScreen mainScreen].bounds.size.width
#define KScreenHeight [UIScreen mainScreen].bounds.size.height


@interface BannerView ()<UIScrollViewDelegate>
@property (nonatomic, weak) id<BannerViewDelegate> delegate;

@property (nonatomic, strong) NSArray *imageURLs;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) CGFloat timerInterval;
@property (nonatomic, copy) NSString *placeholderImage;


@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIPageControl *pageControl;

@end

@implementation BannerView

+(instancetype)bannerViewWithFrame:(CGRect)frame
                          delegate:(id<BannerViewDelegate>)delegate
                         imageURLs:(NSArray *)imageURLs
                  placeholderImage:(NSString *)placeholderImage
                     timerInterval:(NSInteger)timeInterval{
    return [[self alloc]initWithFrame:frame
                             delegate:delegate
                            imageURLs:imageURLs
                     placeholderImage:placeholderImage
                        timerInterval:timeInterval];

}
-(instancetype)initWithFrame:(CGRect)frame delegate:(id<BannerViewDelegate>)delegate
                   imageURLs:(NSArray *)imageURLs
            placeholderImage:(NSString *)placeholderImage
               timerInterval:(NSInteger)timeInterval{

    if (self == [super initWithFrame:frame]) {
        self.delegate = delegate;
        self.imageURLs = imageURLs;
        self.count = imageURLs.count;
        self.timerInterval = timeInterval;
        self.placeholderImage = placeholderImage;
         [self setupMainView];

    }
    return self;
}

-(void)setupMainView{

    CGFloat scrollW = self.frame.size.width;
    CGFloat scrollH = self.frame.size.height;

    if (self.imageURLs.count == 0) {
        return;
    }
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollW, scrollH)];
    //  1 2 3 4 5
    //5 1 2 3 4 5 1
    for (int i = 0; i < self.count + 2; i++) {
        NSInteger tag = 0;
        if (i == 0) {
            tag = self.count;
        } else if (i == self.count + 1) {
            tag = 1;
        } else {
            tag = i;
        }
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.tag = tag;
        [imageView sd_setImageWithURL:[NSURL URLWithString:self.imageURLs[tag - 1]] placeholderImage:self.placeholderImage.length > 0 ? [UIImage imageNamed:self.placeholderImage] : nil];

        imageView.clipsToBounds = YES;
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.frame = CGRectMake(scrollW * i, 0, scrollW, scrollH);
        [scrollView addSubview:imageView];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTaped:)];
        [imageView addGestureRecognizer:tap];



    }

    scrollView.delegate = self;
    scrollView.scrollsToTop = NO;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.contentOffset = CGPointMake(scrollW, 0);
    scrollView.contentSize = CGSizeMake((self.count + 2) * scrollW, 0);

    self.scrollView = scrollView;
    [self addSubview:self.scrollView];



    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, scrollH - 5 - 5, scrollW, 5)];
    pageControl.numberOfPages = self.count;
    pageControl.userInteractionEnabled = NO;
    pageControl.alpha = 0.5;
    pageControl.backgroundColor = [UIColor clearColor];
    self.pageControl = pageControl;
    [self addSubview:self.pageControl];


    [self addTimer];


}
-(void)bannerViewWithPageControlStyle:(PageControlStyle)pageControlStyle
             withPageControlAlignment:(PageControlAlignment)pageAlignment
    withCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor
           withPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor
    withCurrentPageIndicatorTintImage:(NSString *)currentPageIndicatorTintImage
           withPageIndicatorTintImage:(NSString *)pageIndicatorTintImage{


    switch (pageControlStyle) {
        case pageControlColor:
        {
            self.pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor ?: [UIColor whiteColor];
            self.pageControl.pageIndicatorTintColor = pageIndicatorTintColor ?: [UIColor redColor];
            
            CGRect frame = self.pageControl.frame;
            CGFloat width = 5 * (self.count+2);
            frame.size = CGSizeMake(15 + width + 15, 5);
            CGFloat orginX = (pageAlignment == PageControlAlignmentLeft)? 0:((pageAlignment == PageControlAlignmentCenter)?(KScreenWidth - frame.size.width)/2 : (KScreenWidth - frame.size.width));
            frame.origin = CGPointMake(orginX,self.frame.size.height - 5 - 5);
            self.pageControl.frame = frame;

            break;
        }
        case pageControlImage:
        {
            [self.pageControl setValue:[UIImage imageNamed:currentPageIndicatorTintImage] forKey:@"_currentPageImage"];
            [self.pageControl setValue:[UIImage imageNamed:pageIndicatorTintImage] forKey:@"_pageImage"];
            CGSize _pageImageSize = [UIImage imageNamed:@"current"].size;
            CGRect frame = self.pageControl.frame;
            CGFloat width = _pageImageSize.width * (self.count+2);
            frame.size = CGSizeMake(10 + width + 10, _pageImageSize.height);
            CGFloat orginX = (pageAlignment == PageControlAlignmentLeft)? 0:((pageAlignment == PageControlAlignmentCenter)?(KScreenWidth - frame.size.width)/2 : (KScreenWidth - frame.size.width));
            frame.origin = CGPointMake(orginX,self.frame.size.height - _pageImageSize.height);
            self.pageControl.frame = frame;

            break;
        }

        default:
            break;
    }


}




- (void)imageViewTaped:(UITapGestureRecognizer *)tap {
    if ([self.delegate respondsToSelector:@selector(bannerView:didClickedImageIndex:)]) {
        [self.delegate bannerView:self didClickedImageIndex:tap.view.tag - 1];
    }
}
#pragma mark - Timer

- (void)addTimer {
    dispatch_queue_t queue = dispatch_get_main_queue();
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    // 延迟时间
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.timerInterval * NSEC_PER_SEC));
    // 间隔时间
    uint64_t interval = (uint64_t)(self.timerInterval * NSEC_PER_SEC);
    dispatch_source_set_timer(self.timer, start, interval, 0);
    // 定时器回调事件
    dispatch_source_set_event_handler(self.timer, ^{
        [self nextImage];
    });
    // 启动定时器
    dispatch_resume(self.timer);

}
- (void)removeTimer {
    if (self.timer) {
        dispatch_cancel(self.timer);
        self.timer = nil;
    }
}
- (void)nextImage {
    NSInteger currentPage = self.pageControl.currentPage;
    [self.scrollView setContentOffset:CGPointMake((currentPage + 2) * self.scrollView.frame.size.width, 0)
                             animated:YES];
}
#pragma mark - UIScrollView Delegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    CGFloat scrollW = self.scrollView.frame.size.width;
    NSInteger currentPage = self.scrollView.contentOffset.x / scrollW;
    if (currentPage == self.count + 1) {
        self.pageControl.currentPage = 0;
    } else if (currentPage == 0) {
        self.pageControl.currentPage = self.count;
    } else {
        self.pageControl.currentPage = currentPage - 1;
    }
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    CGFloat scrollW = self.scrollView.frame.size.width;
    NSInteger currentPage = self.scrollView.contentOffset.x / scrollW;

    if (currentPage == self.count + 1) {
        self.pageControl.currentPage = 0;
        [self.scrollView setContentOffset:CGPointMake(scrollW, 0) animated:NO];
    } else if (currentPage == 0) {
        self.pageControl.currentPage = self.count;
        [self.scrollView setContentOffset:CGPointMake(self.count * scrollW, 0) animated:NO];
    } else {
        self.pageControl.currentPage = currentPage - 1;
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self removeTimer];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self addTimer];
}




@end
