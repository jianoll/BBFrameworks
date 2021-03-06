//
//  BBMediaBrowserViewController.m
//  BBFrameworks
//
//  Created by William Towe on 8/8/15.
//  Copyright (c) 2015 Bion Bilateral, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "BBMediaViewerViewController.h"
#import "BBMediaViewerDetailViewController.h"
#import "BBMediaViewerDetailViewModel.h"
#import "BBMediaViewerViewModel.h"
#import "UIBarButtonItem+BBKitExtensions.h"
#import "BBFoundationGeometryFunctions.h"
#import "BBKitColorMacros.h"
#import "BBMediaViewerTopContainerView.h"
#import "BBMediaViewerBottomContainerView.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

static NSTimeInterval const kAnimationDuration = 0.33;

@interface BBMediaViewerViewController () <UIPageViewControllerDataSource,UIPageViewControllerDelegate,UIGestureRecognizerDelegate,UIViewControllerTransitioningDelegate,UIViewControllerAnimatedTransitioning>
@property (strong,nonatomic) UIPageViewController *pageViewController;
@property (strong,nonatomic) BBMediaViewerTopContainerView *topContainerView;
@property (strong,nonatomic) BBMediaViewerBottomContainerView *bottomContainerView;

@property (strong,nonatomic) BBMediaViewerViewModel *viewModel;

@property (strong,nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@property (assign,nonatomic,getter=isPresenting) BOOL presenting;

- (void)_toggleNavigationBarAndToolbarAnimated:(BOOL)animated;
- (void)_updateToolbarItemsWithViewController:(BBMediaViewerDetailViewController *)viewController;
@end

@implementation BBMediaViewerViewController
#pragma mark *** Subclass Overrides ***
- (UIRectEdge)edgesForExtendedLayout {
    return UIRectEdgeNone;
}

- (UIModalPresentationStyle)modalPresentationStyle {
    if ([self.delegate respondsToSelector:@selector(mediaViewer:frameForMedia:inSourceView:)]) {
        UIView *sourceView = nil;
        CGRect frame = [self.delegate mediaViewer:self frameForMedia:self.viewModel.currentViewModel.media inSourceView:&sourceView];
        
        if (!CGRectIsEmpty(frame)) {
            return UIModalPresentationCustom;
        }
    }
    return UIModalPresentationFullScreen;
}

- (BOOL)hidesBottomBarWhenPushed {
    return self.tabBarController ? YES : NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (instancetype)init {
    if (!(self = [super init]))
        return nil;
    
    [self setTransitioningDelegate:self];
    
    [self setViewModel:[[BBMediaViewerViewModel alloc] init]];
    
    RAC(self,title) = RACObserve(self.viewModel, title);
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    [self setPageViewController:[[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{UIPageViewControllerOptionInterPageSpacingKey: @20.0}]];
    [self.pageViewController setDataSource:self];
    [self.pageViewController setDelegate:self];
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    [self.pageViewController.view setBackgroundColor:[UIColor blackColor]];
    
    [self setTopContainerView:[[BBMediaViewerTopContainerView alloc] initWithViewModel:self.viewModel]];
    [self.view addSubview:self.topContainerView];
    
    [self setBottomContainerView:[[BBMediaViewerBottomContainerView alloc] initWithViewModel:self.viewModel]];
    [self.view addSubview:self.bottomContainerView];
    
    [self setTapGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:nil action:NULL]];
    [self.tapGestureRecognizer setNumberOfTapsRequired:1];
    [self.tapGestureRecognizer setNumberOfTouchesRequired:1];
    [self.tapGestureRecognizer setDelegate:self];
    [self.pageViewController.view addGestureRecognizer:self.tapGestureRecognizer];
    
    id<BBMediaViewerMedia> media = nil;
    NSInteger index = 0;
    
    if ([self.dataSource respondsToSelector:@selector(initialMediaForMediaViewer:)]) {
        media = [self.dataSource initialMediaForMediaViewer:self];
        
        for (NSInteger i=0; i<[self.dataSource numberOfMediaInMediaViewer:self]; i++) {
            id<BBMediaViewerMedia> m = [self.dataSource mediaViewer:self mediaAtIndex:i];
            
            if ([m isEqual:media]) {
                index = i;
                break;
            }
        }
    }
    else {
        media = [self.dataSource mediaViewer:self mediaAtIndex:0];
    }
    
    @weakify(self);
    [self.pageViewController setViewControllers:@[[[BBMediaViewerDetailViewController alloc] initWithViewModel:[[BBMediaViewerDetailViewModel alloc] initWithMedia:media index:index]]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:^(BOOL finished) {
        @strongify(self);
        
        BBMediaViewerDetailViewController *viewController = self.pageViewController.viewControllers.firstObject;
        
        [self.viewModel setCurrentViewModel:viewController.viewModel];
        
        [self _updateToolbarItemsWithViewController:self.pageViewController.viewControllers.firstObject];
    }];
    
    [[self.tapGestureRecognizer
      rac_gestureSignal]
    subscribeNext:^(id _) {
        @strongify(self);
        [self _toggleNavigationBarAndToolbarAnimated:YES];
    }];
    
    if (self.presentingViewController) {
        [[[self.viewModel.doneCommand.executionSignals
           concat]
          deliverOn:[RACScheduler mainThreadScheduler]]
         subscribeNext:^(id _) {
             @strongify(self);
             if ([self.delegate respondsToSelector:@selector(mediaViewerWillDismiss:)]) {
                 [self.delegate mediaViewerWillDismiss:self];
             }
             
             [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
                 @strongify(self);
                 if ([self.delegate respondsToSelector:@selector(mediaViewerDidDismiss:)]) {
                     [self.delegate mediaViewerDidDismiss:self];
                 }
             }];
         }];
    }
    
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:YES];
        [self.navigationController setToolbarHidden:YES];
    }
}
- (void)viewWillLayoutSubviews {
    [self.pageViewController.view setFrame:self.view.bounds];
    [self.topContainerView setFrame:CGRectMake(0, [self.topLayoutGuide length], CGRectGetWidth(self.view.bounds), [self.topContainerView sizeThatFits:CGSizeZero].height)];
    [self.bottomContainerView setFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - [self.bottomContainerView sizeThatFits:CGSizeZero].height - [self.bottomLayoutGuide length], CGRectGetWidth(self.view.bounds), [self.bottomContainerView sizeThatFits:CGSizeZero].height)];
}
#pragma mark UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    [self setPresenting:YES];
    return self;
}
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    [self setPresenting:NO];
    return self;
}
#pragma mark UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return kAnimationDuration;
}
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *fromView = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view;
    UIView *toView = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view;
    UIView *containerView = [transitionContext containerView];
    
    // presenting
    if (self.isPresenting) {
        [containerView addSubview:toView];
        
        if ([transitionContext isAnimated]) {
            CGRect startFrame = CGRectZero;
            
            if ([self.delegate respondsToSelector:@selector(mediaViewer:frameForMedia:inSourceView:)]) {
                UIView *sourceView = nil;
                CGRect frame = [self.delegate mediaViewer:self frameForMedia:self.viewModel.currentViewModel.media inSourceView:&sourceView];
                
                if (!CGRectIsEmpty(frame)) {
                    if (sourceView) {
                        frame = [sourceView.window convertRect:[sourceView convertRect:frame toView:nil] toWindow:nil];
                    }
                    
                    startFrame = frame;
                }
            }
            
            UIView *toSnapshotView = [toView snapshotViewAfterScreenUpdates:YES];
            UIView *imageView = nil;
            
            if ([self.delegate respondsToSelector:@selector(mediaViewer:transitionImageForMedia:contentRect:)]) {
                CGRect contentRect = CGRectZero;
                imageView = [[UIImageView alloc] initWithImage:[self.delegate mediaViewer:self transitionImageForMedia:self.viewModel.currentViewModel.media contentRect:&contentRect]];
                
                if (!CGRectIsEmpty(contentRect)) {
                    imageView = [imageView resizableSnapshotViewFromRect:contentRect afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
                }
            }
            
            [containerView addSubview:toSnapshotView];
            [toSnapshotView setFrame:containerView.bounds];
            [toSnapshotView setAlpha:0.0];
            
            if (imageView) {
                [containerView addSubview:imageView];
            }
            
            [toView setAlpha:0.0];
            
            if (!CGRectIsEmpty(startFrame)) {
                [toSnapshotView setFrame:startFrame];
                [imageView setFrame:startFrame];
            }
            
            [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                [toSnapshotView setAlpha:1.0];
                [imageView setAlpha:0.0];
                
                if (!CGRectIsEmpty(startFrame)) {
                    [toSnapshotView setFrame:containerView.bounds];
                    [imageView setFrame:containerView.bounds];
                }
            } completion:^(BOOL finished) {
                [toView setAlpha:1.0];
                
                [toSnapshotView removeFromSuperview];
                [imageView removeFromSuperview];
                
                [transitionContext completeTransition:YES];
            }];
        }
        else {
            [transitionContext completeTransition:YES];
        }
    }
    // dismissing
    else {
        if ([transitionContext isAnimated]) {
            CGRect endFrame = CGRectZero;
            
            if ([self.delegate respondsToSelector:@selector(mediaViewer:frameForMedia:inSourceView:)]) {
                UIView *sourceView = nil;
                CGRect frame = [self.delegate mediaViewer:self frameForMedia:self.viewModel.currentViewModel.media inSourceView:&sourceView];
                
                if (!CGRectIsEmpty(frame)) {
                    if (sourceView) {
                        frame = [sourceView.window convertRect:[sourceView convertRect:frame toView:nil] toWindow:nil];
                    }
                    
                    endFrame = frame;
                }
            }
            
            UIView *fromSnapshotView = [fromView snapshotViewAfterScreenUpdates:YES];
            UIView *imageView = nil;
            
            if ([self.delegate respondsToSelector:@selector(mediaViewer:transitionImageForMedia:contentRect:)]) {
                CGRect contentRect = CGRectZero;
                imageView = [[UIImageView alloc] initWithImage:[self.delegate mediaViewer:self transitionImageForMedia:self.viewModel.currentViewModel.media contentRect:&contentRect]];
                
                if (!CGRectIsEmpty(contentRect)) {
                    imageView = [imageView resizableSnapshotViewFromRect:contentRect afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
                }
            }
            
            [containerView addSubview:fromSnapshotView];
            [fromSnapshotView setFrame:containerView.bounds];
            
            if (imageView) {
                [containerView addSubview:imageView];
                [imageView setFrame:containerView.bounds];
                [imageView setAlpha:0.0];
            }
            
            [fromView setAlpha:0.0];
            
            [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                [fromSnapshotView setAlpha:0.0];
                [imageView setAlpha:1.0];
                
                if (!CGRectIsEmpty(endFrame)) {
                    [fromSnapshotView setFrame:endFrame];
                    [imageView setFrame:endFrame];
                }
            } completion:^(BOOL finished) {
                [fromSnapshotView removeFromSuperview];
                
                [transitionContext completeTransition:YES];
            }];
        }
        else {
            [transitionContext completeTransition:YES];
        }
    }
}
#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return ([otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] &&
            [(UITapGestureRecognizer *)otherGestureRecognizer numberOfTapsRequired] == 2);
}
#pragma mark UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    BBMediaViewerDetailViewModel *viewModel = [(BBMediaViewerDetailViewController *)viewController viewModel];
    NSInteger index = viewModel.index;
    
    if ((++index) == [self.dataSource numberOfMediaInMediaViewer:self]) {
        return nil;
    }
    
    id<BBMediaViewerMedia> media = [self.dataSource mediaViewer:self mediaAtIndex:index];
    
    return [[BBMediaViewerDetailViewController alloc] initWithViewModel:[[BBMediaViewerDetailViewModel alloc] initWithMedia:media index:index]];
}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    BBMediaViewerDetailViewModel *viewModel = [(BBMediaViewerDetailViewController *)viewController viewModel];
    NSInteger index = viewModel.index;
    
    if ((--index) < 0) {
        return nil;
    }
    
    id<BBMediaViewerMedia> media = [self.dataSource mediaViewer:self mediaAtIndex:index];
    
    return [[BBMediaViewerDetailViewController alloc] initWithViewModel:[[BBMediaViewerDetailViewModel alloc] initWithMedia:media index:index]];
}
#pragma mark UIPageViewControllerDelegate
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.bottomContainerView setAlpha:0.0];
    } completion:nil];
}
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.bottomContainerView setAlpha:1.0];
    } completion:nil];
    
    if (completed) {
        BBMediaViewerDetailViewController *viewController = pageViewController.viewControllers.firstObject;
        
        [self.viewModel setCurrentViewModel:viewController.viewModel];
        
        [self _updateToolbarItemsWithViewController:self.pageViewController.viewControllers.firstObject];
    }
}
#pragma mark *** Public Methods ***
#pragma mark Properties
- (void)setDataSource:(id<BBMediaViewerViewControllerDataSource>)dataSource {
    _dataSource = dataSource;
    
    if (_dataSource) {
        [self.viewModel setNumberOfViewModels:[_dataSource numberOfMediaInMediaViewer:self]];
    }
}
#pragma mark *** Private Methods ***
- (void)_toggleNavigationBarAndToolbarAnimated:(BOOL)animated; {
    [UIView animateWithDuration:animated ? kAnimationDuration : 0.0 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.topContainerView setAlpha:self.topContainerView.alpha == 0.0 ? 1.0 : 0.0];
        [self.bottomContainerView setAlpha:self.bottomContainerView.alpha == 0.0 ? 1.0 : 0.0];
    } completion:nil];
}
- (void)_updateToolbarItemsWithViewController:(BBMediaViewerDetailViewController *)viewController; {
    [self.bottomContainerView setContentView:viewController.bottomContentView];
    
    [self.view setNeedsLayout];
}

@end
