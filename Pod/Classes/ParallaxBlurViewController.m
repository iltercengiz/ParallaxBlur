//
//  ParallaxBlurViewController.m
//  Pods
//
//  Created by Joseph Pintozzi on 8/22/14.
//
//

#import "ParallaxBlurViewController.h"
#import "FXBlurView.h"

@interface ParallaxBlurViewController ()<UIScrollViewDelegate> {
    UIScrollView *_mainScrollView;
    UIScrollView *_backgroundScrollView;
    UIView *_floatingHeaderView;
    UIImageView *_headerImageView;
    UIImageView *_blurredImageView;
    UIImage *_originalImageView;
    UIView *_scrollViewContainer;
    UIScrollView *_contentView;
    
    NSMutableArray *_headerOverlayViews;
}
@end

@implementation ParallaxBlurViewController

static CGFloat INVIS_DELTA = 50.0f;
static CGFloat BLUR_DISTANCE = 200.0f;

-(void)viewDidLoad{
    [super viewDidLoad];
    
    _headerOverlayViews = [NSMutableArray array];
    
    _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _mainScrollView.delegate = self;
    _mainScrollView.bounces = YES;
    _mainScrollView.alwaysBounceVertical = YES;
    _mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width, 1000);
    _mainScrollView.showsVerticalScrollIndicator = YES;
    self.view = _mainScrollView;
    
    _backgroundScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    _backgroundScrollView.scrollEnabled = NO;
    _backgroundScrollView.contentSize = CGSizeMake(self.view.frame.size.width, 1000);
    _headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_backgroundScrollView.frame), CGRectGetHeight(_backgroundScrollView.frame))];
    [_headerImageView setContentMode:UIViewContentModeScaleAspectFill];
    _headerImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_backgroundScrollView addSubview:_headerImageView];
    
    _blurredImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_backgroundScrollView.frame), CGRectGetHeight(_backgroundScrollView.frame))];
    [_blurredImageView setContentMode:UIViewContentModeScaleAspectFill];
    _blurredImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_blurredImageView setAlpha:0.0f];
    
    _floatingHeaderView = [[UIView alloc] initWithFrame:_backgroundScrollView.frame];
    [_floatingHeaderView setBackgroundColor:[UIColor clearColor]];
    
    [_backgroundScrollView addSubview:_blurredImageView];
    
    _scrollViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_backgroundScrollView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 50.0f )];
    [_scrollViewContainer setBackgroundColor:[UIColor yellowColor]];
    
    _contentView = [self contentView];
    [_scrollViewContainer addSubview:_contentView];
    
    [_mainScrollView addSubview:_backgroundScrollView];
    [_mainScrollView addSubview:_floatingHeaderView];
    [_mainScrollView addSubview:_scrollViewContainer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), _contentView.contentSize.height + CGRectGetHeight(_backgroundScrollView.frame));
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat delta = 0.0f;
    CGRect rect = CGRectMake(0, 0, 320, 320);
    // Here is where I do the "Zooming" image and the quick fade out the text and toolbar
    if (scrollView.contentOffset.y < 0.0f) {
        //calculate delta
        delta = fabs(MIN(0.0f, _mainScrollView.contentOffset.y));
        _backgroundScrollView.frame = CGRectMake(CGRectGetMinX(rect) - delta / 2.0f, CGRectGetMinY(rect) - delta, CGRectGetWidth(rect) + delta, CGRectGetHeight(rect) + delta);
        [_floatingHeaderView setAlpha:(INVIS_DELTA - delta) / INVIS_DELTA];
    } else {
        delta = _mainScrollView.contentOffset.y;
        
        //set alfas
        CGFloat newAlpha = 1 - ((BLUR_DISTANCE - delta)/ BLUR_DISTANCE);
        [_blurredImageView setAlpha:newAlpha];
        [_floatingHeaderView setAlpha:1];
        
        CGFloat backgroundScrollViewLimit = _backgroundScrollView.frame.size.height - 50;
        // Here I check whether or not the user has scrolled passed the limit where I want to stick the header, if they have then I move the frame with the scroll view
        // to give it the sticky header look
        if (delta > backgroundScrollViewLimit) {
            _backgroundScrollView.frame = (CGRect) {.origin = {0, delta - _backgroundScrollView.frame.size.height + 50}, .size = {self.view.frame.size.width, 320}};
            _floatingHeaderView.frame = (CGRect) {.origin = {0, delta - _floatingHeaderView.frame.size.height + 50}, .size = {self.view.frame.size.width, 320}};
            _scrollViewContainer.frame = (CGRect){.origin = {0, CGRectGetMinY(_backgroundScrollView.frame) + CGRectGetHeight(_backgroundScrollView.frame)}, .size = _scrollViewContainer.frame.size };
            _contentView.contentOffset = CGPointMake (0, delta - backgroundScrollViewLimit);
            CGFloat contentOffsetY = -backgroundScrollViewLimit * 0.5f;
            [_backgroundScrollView setContentOffset:(CGPoint){0,contentOffsetY} animated:NO];
        }
        else {
            _backgroundScrollView.frame = rect;
            _floatingHeaderView.frame = rect;
            _scrollViewContainer.frame = (CGRect){.origin = {0, CGRectGetMinY(rect) + CGRectGetHeight(rect)}, .size = _scrollViewContainer.frame.size };
            [_contentView setContentOffset:(CGPoint){0,0} animated:NO];
            [_backgroundScrollView setContentOffset:CGPointMake(0, -delta * 0.5f)animated:NO];
        }
    }
}

- (UIScrollView*)contentView{
    UIScrollView *contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 50.0f )];
        contentView.scrollEnabled = NO;
    return contentView;
}

- (void)setHeaderImage:(UIImage*)headerImage{
    _originalImageView = headerImage;
    [_headerImageView setImage:headerImage];
    [_blurredImageView setImage:[headerImage blurredImageWithRadius:40.0f iterations:4 tintColor:[UIColor clearColor]]];
}

- (void)addHeaderOverlayView:(UIView*)overlay{
    [_headerOverlayViews addObject:overlay];
    [_floatingHeaderView addSubview:overlay];
}

- (CGFloat)headerHeight{
    return CGRectGetHeight(_backgroundScrollView.frame);
}

@end