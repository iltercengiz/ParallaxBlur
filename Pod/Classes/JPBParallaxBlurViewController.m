//
//  ParallaxBlurViewController.m
//  Pods
//
//  Created by Joseph Pintozzi on 8/22/14.
//
//

#import "JPBParallaxBlurViewController.h"
#import "FXBlurView.h"

@interface JPBParallaxBlurViewController ()<UIScrollViewDelegate> {
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

@implementation JPBParallaxBlurViewController

static CGFloat INVIS_DELTA = 50.0f;
static CGFloat BLUR_DISTANCE = 200.0f;
static CGFloat HEADER_HEIGHT = 60.0f;
static CGFloat IMAGE_HEIGHT = 320.0f;

-(void)viewDidLoad{
    [super viewDidLoad];
    
    _headerOverlayViews = [NSMutableArray array];
    
    /*** mainScrollView ***/
    self.mainScrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    self.mainScrollView.delegate = self;
    self.mainScrollView.bounces = YES;
    self.mainScrollView.alwaysBounceVertical = YES;
    self.mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width, 1000);
    self.mainScrollView.showsVerticalScrollIndicator = YES;
//    self.mainScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.mainScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.mainScrollView.autoresizesSubviews = YES;
    
    [self.view addSubview:self.mainScrollView];
//    self.view = self.mainScrollView;
    
    /*** backgroundScrollView ***/
    _backgroundScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), IMAGE_HEIGHT)];
    _backgroundScrollView.scrollEnabled = NO;
    _backgroundScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _backgroundScrollView.autoresizesSubviews = YES;
    _backgroundScrollView.contentSize = CGSizeMake(self.view.frame.size.width, 1000);
//    _backgroundScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.mainScrollView addSubview:_backgroundScrollView];
    
    /*** headerImageView ***/
//    _headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_backgroundScrollView.frame), CGRectGetHeight(_backgroundScrollView.frame))];
    _headerImageView = [[UIImageView alloc] initWithFrame:_backgroundScrollView.bounds];
    _headerImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_headerImageView setContentMode:UIViewContentModeScaleAspectFill];
    _headerImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_headerImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerImageTapped:)]];
    [_headerImageView setUserInteractionEnabled:YES];
//    _headerImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_backgroundScrollView addSubview:_headerImageView];
    
    /*** blurredImageView ***/
//    _blurredImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_backgroundScrollView.frame), CGRectGetHeight(_backgroundScrollView.frame))];
    _blurredImageView = [[UIImageView alloc] initWithFrame:_backgroundScrollView.bounds];
    [_blurredImageView setContentMode:UIViewContentModeScaleAspectFill];
    _blurredImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_blurredImageView setAlpha:0.0f];
    [_blurredImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerImageTapped:)]];
    [_blurredImageView setUserInteractionEnabled:YES];
//    _blurredImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_backgroundScrollView addSubview:_blurredImageView];
    
    /*** floatingHeaderView ***/
    _floatingHeaderView = [[UIView alloc] initWithFrame:_backgroundScrollView.bounds];
    [_floatingHeaderView setBackgroundColor:[UIColor clearColor]];
    [_floatingHeaderView setUserInteractionEnabled:NO];
//    _floatingHeaderView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.mainScrollView addSubview:_floatingHeaderView];
    
    /*** scrollViewContainer ***/
    _scrollViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_backgroundScrollView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - [self offsetHeight] )];
    _scrollViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    _scrollViewContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.mainScrollView addSubview:_scrollViewContainer];
    
    _contentView = [self contentView];
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollViewContainer addSubview:_contentView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_contentView setFrame:CGRectMake(0, 0, CGRectGetWidth(_scrollViewContainer.frame), CGRectGetHeight(self.view.frame) - [self offsetHeight] )];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self setNeedsScrollViewAppearanceUpdate];
}

- (void)updateViewConstraints {
    
    [super updateViewConstraints];
    
    NSMutableArray *constraints;
    NSMutableDictionary *views;
    
    // mainScrollView to view constraints
    constraints = [NSMutableArray array];
    views = [NSMutableDictionary dictionary];
    
    views[@"mainScrollView"] = self.mainScrollView;
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[mainScrollView]-0-|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[mainScrollView]-0-|" options:0 metrics:nil views:views]];
    
    [self.view addConstraints:constraints];
    
    // backgroundScrollView to mainScrollView
//    constraints = [NSMutableArray array];
//    views = [NSMutableDictionary dictionary];
//    
//    views[@"backgroundScrollView"] = _backgroundScrollView;
//    
//    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-0-[backgroundScrollView(%f)]", IMAGE_HEIGHT] options:0 metrics:nil views:views]];
//    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[backgroundScrollView]-0-|" options:0 metrics:nil views:views]];
//    
//    [self.mainScrollView addConstraints:constraints];
//    
//    // headerImageView to backgroundScrollView constraints
//    constraints = [NSMutableArray array];
//    views = [NSMutableDictionary dictionary];
//    
//    views[@"headerImageView"] = _headerImageView;
//    
//    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-0-[headerImageView(%f)]", IMAGE_HEIGHT] options:0 metrics:nil views:views]];
//    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[headerImageView]-0-|" options:0 metrics:nil views:views]];
//    
//    [_backgroundScrollView addConstraints:constraints];
//    
//    // blurredImageView to backgroundScrollView constraints
//    constraints = [NSMutableArray array];
//    views = [NSMutableDictionary dictionary];
//    
//    views[@"blurredImageView"] = _blurredImageView;
//    
//    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-0-[blurredImageView(%f)]", IMAGE_HEIGHT] options:0 metrics:nil views:views]];
//    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[blurredImageView]-0-|" options:0 metrics:nil views:views]];
//    
//    [_backgroundScrollView addConstraints:constraints];
//    
//    // floatingHeaderView to mainScrollView
//    constraints = [NSMutableArray array];
//    views = [NSMutableDictionary dictionary];
//    
//    views[@"floatingHeaderView"] = _floatingHeaderView;
//    
//    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-0-[floatingHeaderView(%f)]", IMAGE_HEIGHT] options:0 metrics:nil views:views]];
//    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[floatingHeaderView]-0-|" options:0 metrics:nil views:views]];
//    
//    [self.mainScrollView addConstraints:constraints];
//    
//    // scrollViewContainer to mainScrollView
//    constraints = [NSMutableArray array];
//    views = [NSMutableDictionary dictionary];
//    
//    views[@"backgroundScrollView"] = _backgroundScrollView;
//    views[@"scrollViewContainer"] = _scrollViewContainer;
//    
//    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[backgroundScrollView]-0-[scrollViewContainer]-0-|" options:0 metrics:nil views:views]];
//    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[scrollViewContainer]-0-|" options:0 metrics:nil views:views]];
//    
//    [self.mainScrollView addConstraints:constraints];
//    
//    // contentView to scrollViewContainer
//    constraints = [NSMutableArray array];
//    views = [NSMutableDictionary dictionary];
//    
//    views[@"contentView"] = _contentView;
//    
//    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[contentView]-0-|" options:0 metrics:nil views:views]];
//    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[contentView]-0-|" options:0 metrics:nil views:views]];
//    
//    [_scrollViewContainer addConstraints:constraints];
    
}

- (void)setNeedsScrollViewAppearanceUpdate {
    self.mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), _contentView.contentSize.height + CGRectGetHeight(_backgroundScrollView.frame));
}

- (CGFloat)navBarHeight{
    if (self.navigationController && !self.navigationController.navigationBarHidden) {
        return CGRectGetHeight(self.navigationController.navigationBar.frame) + 20; //include 20 for the status bar
    }
    return 0.0f;
}

- (CGFloat)offsetHeight{
    return HEADER_HEIGHT + [self navBarHeight];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat delta = 0.0f;
    CGRect rect = CGRectMake(0, 0, CGRectGetWidth(_scrollViewContainer.frame), IMAGE_HEIGHT);
    
    CGFloat backgroundScrollViewLimit = _backgroundScrollView.frame.size.height - [self offsetHeight];
    
    // Here is where I do the "Zooming" image and the quick fade out the text and toolbar
    if (scrollView.contentOffset.y < 0.0f) {
        //calculate delta
        delta = fabs(MIN(0.0f, self.mainScrollView.contentOffset.y + [self navBarHeight]));
        _backgroundScrollView.frame = CGRectMake(CGRectGetMinX(rect) - delta / 2.0f, CGRectGetMinY(rect) - delta, CGRectGetWidth(_scrollViewContainer.frame) + delta, CGRectGetHeight(rect) + delta);
        [_floatingHeaderView setAlpha:(INVIS_DELTA - delta) / INVIS_DELTA];
    } else {
        delta = self.mainScrollView.contentOffset.y;
        
        //set alfas
        CGFloat newAlpha = 1 - ((BLUR_DISTANCE - delta)/ BLUR_DISTANCE);
        [_blurredImageView setAlpha:newAlpha];
        [_floatingHeaderView setAlpha:1];
        
        // Here I check whether or not the user has scrolled passed the limit where I want to stick the header, if they have then I move the frame with the scroll view
        // to give it the sticky header look
        if (delta > backgroundScrollViewLimit) {
            _backgroundScrollView.frame = (CGRect) {.origin = {0, delta - _backgroundScrollView.frame.size.height + [self offsetHeight]}, .size = {CGRectGetWidth(_scrollViewContainer.frame), IMAGE_HEIGHT}};
            _floatingHeaderView.frame = (CGRect) {.origin = {0, delta - _floatingHeaderView.frame.size.height + [self offsetHeight]}, .size = {CGRectGetWidth(_scrollViewContainer.frame), IMAGE_HEIGHT}};
            _scrollViewContainer.frame = (CGRect){.origin = {0, CGRectGetMinY(_backgroundScrollView.frame) + CGRectGetHeight(_backgroundScrollView.frame)}, .size = _scrollViewContainer.frame.size };
            _contentView.contentOffset = CGPointMake (0, delta - backgroundScrollViewLimit);
            CGFloat contentOffsetY = -backgroundScrollViewLimit * 0.5f;
            [_backgroundScrollView setContentOffset:(CGPoint){0,contentOffsetY} animated:NO];
        } else {
            _backgroundScrollView.frame = rect;
            _floatingHeaderView.frame = rect;
            _scrollViewContainer.frame = (CGRect){.origin = {0, CGRectGetMinY(rect) + CGRectGetHeight(rect)}, .size = _scrollViewContainer.frame.size };
            [_contentView setContentOffset:(CGPoint){0,0} animated:NO];
            [_backgroundScrollView setContentOffset:CGPointMake(0, -delta * 0.5f)animated:NO];
        }
    }
    
}

- (UIScrollView*)contentView {
    UIScrollView *contentView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    contentView.scrollEnabled = NO;
    return contentView;
}

- (void)setHeaderImage:(UIImage*)headerImage {
    _originalImageView = headerImage;
    [_headerImageView setImage:headerImage];
    [_blurredImageView setImage:[headerImage blurredImageWithRadius:40.0f iterations:4 tintColor:[UIColor clearColor]]];
}

- (void)addHeaderOverlayView:(UIView*)overlay {
    [_headerOverlayViews addObject:overlay];
    [_floatingHeaderView addSubview:overlay];
}

- (CGFloat)headerHeight {
    return CGRectGetHeight(_backgroundScrollView.frame);
}

- (IBAction)headerImageTapped:(UITapGestureRecognizer*)tapGesture {
    if ([self.interactionsDelegate respondsToSelector:@selector(didTapHeaderImageView:)]) {
        [self.interactionsDelegate didTapHeaderImageView:_headerImageView];
    }
}

@end
