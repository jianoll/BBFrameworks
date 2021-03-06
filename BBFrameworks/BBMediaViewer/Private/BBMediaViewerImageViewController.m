//
//  BBMediaViewerDetailViewController.m
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

#import "BBMediaViewerImageViewController.h"
#import "BBMediaViewerDetailViewModel.h"
#import "BBMediaViewerImageScrollView.h"
#import "BBFoundationDebugging.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface BBMediaViewerImageViewController () <UIScrollViewDelegate>
@property (strong,nonatomic) BBMediaViewerImageScrollView *scrollView;
@property (strong,nonatomic) UIActivityIndicatorView *activityIndicatorView;

@property (strong,nonatomic) UITapGestureRecognizer *doubleTapGestureRecognizer;
@end

@implementation BBMediaViewerImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    [self setScrollView:[[BBMediaViewerImageScrollView alloc] initWithViewModel:self.viewModel]];
    [self.scrollView setDelegate:self];
    [self.view addSubview:self.scrollView];
    
    [self setActivityIndicatorView:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge]];
    [self.activityIndicatorView setHidesWhenStopped:YES];
    [self.view addSubview:self.activityIndicatorView];
    
    [self setDoubleTapGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:nil action:NULL]];
    [self.doubleTapGestureRecognizer setNumberOfTapsRequired:2];
    [self.doubleTapGestureRecognizer setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:self.doubleTapGestureRecognizer];
    
    @weakify(self);
    [[self.doubleTapGestureRecognizer
     rac_gestureSignal]
     subscribeNext:^(id _) {
         @strongify(self);
         CGPoint pointInView = [self.doubleTapGestureRecognizer locationInView:self.scrollView.viewForZooming];

         CGFloat newZoomScale = self.scrollView.maximumZoomScale;
         
         if (self.scrollView.zoomScale >= self.scrollView.maximumZoomScale) {
             newZoomScale = self.scrollView.minimumZoomScale;
         }
         
         CGSize scrollViewSize = self.scrollView.bounds.size;
         
         CGFloat width = scrollViewSize.width / newZoomScale;
         CGFloat height = scrollViewSize.height / newZoomScale;
         CGFloat originX = pointInView.x - (width / 2.0);
         CGFloat originY = pointInView.y - (height / 2.0);
         
         CGRect rectToZoomTo = CGRectMake(originX, originY, width, height);

         [self.scrollView zoomToRect:rectToZoomTo animated:YES];
     }];
}
- (void)viewWillLayoutSubviews {
    [self.scrollView setFrame:self.view.bounds];
    [self.activityIndicatorView setFrame:self.view.bounds];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.scrollView updateZoomScale];
    [self.scrollView centerImageView];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.viewModel.image) {
        [self.activityIndicatorView startAnimating];
        
        @weakify(self);
        [self.viewModel.media downloadMediaImageWithCompletion:^(BOOL success, NSError *error) {
            @strongify(self);
            [self.activityIndicatorView stopAnimating];
            
            [self.scrollView setImage:self.viewModel.image];
        }];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.scrollView.viewForZooming;
}

@end
