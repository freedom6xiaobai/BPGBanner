//
//  ViewController.m
//  BPGBanner
//
//  Created by baipeng on 2017/6/8.
//  Copyright © 2017年 BPG. All rights reserved.
//

#import "ViewController.h"
#import "BannerView.h"

@interface ViewController ()<BannerViewDelegate>
//666
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    BannerView *banner = [BannerView bannerViewWithFrame:
                          CGRectMake(0, 100, self.view.frame.size.width, 200)
                                                delegate:self
                                               imageURLs:@[@"http://cms-bucket.nosdn.127.net/be340abd504a468c9af677c58f91e1c020170608075328.jpeg",
                                                           @"http://cms-bucket.nosdn.127.net/659c220a361743e5bd5ece14436c30ff20170608081209.jpeg",
                                                           @"http://cms-bucket.nosdn.127.net/1ce463a922ef4a6bb94170b7c52be29920170608065739.png",
                                                           @"http://cms-bucket.nosdn.127.net/8d0b36ef5ef94314a98ad03ca5d6e1fd20170608084814.png"]
                                        placeholderImage:nil
                                           timerInterval:2];
    [banner bannerViewWithPageControlStyle:pageControlImage
     withPageControlAlignment:PageControlAlignmentCenter
         withCurrentPageIndicatorTintColor:[UIColor redColor]
                withPageIndicatorTintColor:[UIColor yellowColor]
         withCurrentPageIndicatorTintImage:@"other"
                withPageIndicatorTintImage:@"current"];
    [self.view addSubview:banner];
}
-(void)bannerView:(BannerView *)bannerView didClickedImageIndex:(NSInteger)index{
    NSLog(@"-----%d",index);


}

-(void)test{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
