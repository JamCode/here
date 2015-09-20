//
//  ImageEnlarge.m
//  ImageEnlarge
//
//  Created by wang jam on 9/9/15.
//  Copyright (c) 2015 jam wang. All rights reserved.
//

#import "ImageEnlarge.h"
#import "SDWebImage/UIImageView+WebCache.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@implementation ImageEnlarge
{
    NSString* thumbnailUrl;
    NSString* enlargeImageUrl;
    UIImageView* enlargeImageview;
    UIScrollView* backgroundView;
    UIView* parent;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (CGRect)relativeFrameForScreenWithView:(UIView *)v
{
    BOOL iOS7 = [[[UIDevice currentDevice] systemVersion] floatValue] >= 7;
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if (!iOS7) {
        screenHeight -= 20;
    }
    UIView *view = v;
    CGFloat x = .0;
    CGFloat y = .0;
    while (view.frame.size.width != ScreenWidth || view.frame.size.height != screenHeight) {
        x += view.frame.origin.x;
        y += view.frame.origin.y;
        view = view.superview;
        if ([view isKindOfClass:[UIScrollView class]]) {
            x -= ((UIScrollView *) view).contentOffset.x;
            y -= ((UIScrollView *) view).contentOffset.y;
        }
    }
    return CGRectMake(x, y, v.frame.size.width, v.frame.size.height);
}

- (void)zoomImage:(id)sender
{
    if(backgroundView.zoomScale == backgroundView.maximumZoomScale){
        [backgroundView setZoomScale:1 animated:YES];
    }else{
        [backgroundView setZoomScale:backgroundView.maximumZoomScale animated:YES];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if (enlargeImageview == view) {
        if (view.frame.size.width < ScreenWidth) {
            [scrollView setZoomScale:1.0 animated:YES];
        }
    }
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    
}

//告诉scrollview要缩放的是哪个子控件
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return enlargeImageview;
}


- (void)imagePress:(UITapGestureRecognizer*)sender
{
    UIImageView* imageview = (UIImageView*)sender.view;
    
    
    
    NSLog(@"contentImagePress");
    if (enlargeImageview == nil) {
        enlargeImageview = [[UIImageView alloc] init];
        enlargeImageview.image = imageview.image;
    }
    
    enlargeImageview.frame = [self relativeFrameForScreenWithView:imageview];
    enlargeImageview.contentMode = UIViewContentModeScaleAspectFit;
    enlargeImageview.backgroundColor = [UIColor blackColor];
    enlargeImageview.multipleTouchEnabled = YES;
    
    backgroundView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer* singleTab = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewPress:)];
    [singleTab setNumberOfTapsRequired:1];
    
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zoomImage:)];
    
    [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
    [backgroundView addGestureRecognizer:doubleTapGestureRecognizer];
    [backgroundView addGestureRecognizer:singleTab];
    [singleTab requireGestureRecognizerToFail:doubleTapGestureRecognizer];
    
    
    
    backgroundView.delegate = self;
    //设置最大伸缩比例
    backgroundView.maximumZoomScale=1.8;
    //设置最小伸缩比例
    backgroundView.minimumZoomScale=0.8;
    backgroundView.scrollEnabled = YES;
    //backgroundView.contentSize = enlargeImageview.image.size;
    
    [backgroundView addSubview:enlargeImageview];
    
    [backgroundView setAlpha:0.0];
    
    [parent addSubview:backgroundView];
    
    if (enlargeImageUrl!=nil) {
        [enlargeImageview sd_setImageWithURL:[[NSURL alloc] initWithString:enlargeImageUrl]  placeholderImage:imageview.image completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        }];
    }
    
    // animations settings
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView animateWithDuration:0.3 animations:^{
        [backgroundView setAlpha:1];
        
        if(imageview.image.size.height>ScreenHeight){
            enlargeImageview.frame = CGRectMake(0, 0, ScreenWidth,ScreenWidth*imageview.image.size.height/imageview.image.size.width);
            
        }else{
            enlargeImageview.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        }
        
        
        backgroundView.contentSize = CGSizeMake(enlargeImageview.frame.size.width, enlargeImageview.frame.size.height);
        [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
        
        
        
    } completion:^(BOOL finished) {
        ;
        //隐藏导航栏和tab栏
        
    }];

}



- (void)backgroundViewPress:(id)sender
{
    //    _parentViewController.navigationController.navigationBarHidden = NO;
    //    _parentViewController.tabBarController.tabBar.hidden = NO;
    
    // animations settings
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView animateWithDuration:0.3 animations:^{
        enlargeImageview.frame = [self relativeFrameForScreenWithView:self];
        [backgroundView setAlpha:0.0];
        [[UIApplication sharedApplication] setStatusBarHidden:FALSE];
        
    } completion:^(BOOL finished) {
        [enlargeImageview removeFromSuperview];
        [backgroundView removeFromSuperview];
        backgroundView = nil;
        enlargeImageview = nil;
    }];
}



- (void)setThumbnailUrl:(NSString*)imageUrl
{
    thumbnailUrl = imageUrl;
    [(UIImageView*)self sd_setImageWithURL:[[NSURL alloc] initWithString:thumbnailUrl]];
}

- (void)setImageUrl:(NSString*)imageUrl
{
    enlargeImageUrl = imageUrl;
}


- (id)initWithParentView:(UIView*)parentView;
{
    if (self = [super init]) {
        parent = parentView;
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTab = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imagePress:)];
        [self addGestureRecognizer:singleTab];
        
    }
    return self;
}





@end
