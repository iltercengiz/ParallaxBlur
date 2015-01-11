//
//  ParallaxBlurViewController.h
//  Pods
//
//  Created by Joseph Pintozzi on 8/22/14.
//
//

#import <UIKit/UIKit.h>

@protocol JPBParallaxBlurInteractionsDelegate;

@interface JPBParallaxBlurViewController : UIViewController

- (void)setHeaderImage:(UIImage*)headerImage;
- (void)addHeaderOverlayView:(UIView*)overlay;
- (CGFloat)headerHeight;
- (UIScrollView*)mainScrollView;

/**
 *  This should be called whenever the content size of the scrollview need to be adjusted.
 */
- (void)setNeedsScrollViewAppearanceUpdate;

@property (weak, nonatomic, readwrite) id <JPBParallaxBlurInteractionsDelegate> interactionsDelegate;

@property (nonatomic) UIScrollView *mainScrollView;
@property (nonatomic) UIImageView *headerImageView;

@property (nonatomic) NSLayoutConstraint *mainScrollViewTopToSuperViewConstraint;
@property (nonatomic) NSLayoutConstraint *mainScrollViewBottomToSuperViewConstraint;
@property (nonatomic) NSLayoutConstraint *mainScrollViewLeftToSuperViewConstraint;
@property (nonatomic) NSLayoutConstraint *mainScrollViewRightToSuperViewConstraint;

@end

///-------------------------------------------------------------------------------------------------------
/// Interactions Delegate
///-------------------------------------------------------------------------------------------------------

@protocol JPBParallaxBlurInteractionsDelegate <NSObject>

@optional

/**
 Called when the header imageview is tapped.
 */
- (void)didTapHeaderImageView:(UIImageView*)imageView;

@end
