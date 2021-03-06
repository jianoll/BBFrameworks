//
//  BBMediaViewerMovieViewController.m
//  BBFrameworks
//
//  Created by William Towe on 8/10/15.
//  Copyright (c) 2015 Bion Bilateral, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "BBMediaViewerMovieViewController.h"
#import "BBMediaViewerMovieView.h"
#import "BBMediaViewerDetailViewModel.h"
#import "UIImage+BBKitExtensionsPrivate.h"
#import "UIBarButtonItem+BBKitExtensions.h"
#import "UIImage+BBKitExtensions.h"
#import "BBKitColorMacros.h"
#import "BBFoundationDebugging.h"
#import "BBMediaViewerMovieSliderContainerView.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

#import <AVFoundation/AVFoundation.h>

@interface BBMediaViewerMovieViewController ()
@property (strong,nonatomic) BBMediaViewerMovieView *movieView;

@property (strong,nonatomic) id timeObserver;
@end

@implementation BBMediaViewerMovieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setMovieView:[[BBMediaViewerMovieView alloc] initWithViewModel:self.viewModel]];
    [self.view addSubview:self.movieView];
    
    [self setBottomContentView:[[BBMediaViewerMovieSliderContainerView alloc] initWithViewModel:self.viewModel]];
}
- (void)viewWillLayoutSubviews {
    [self.movieView setFrame:self.view.bounds];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (!self.isBeingPresented &&
        !self.isBeingDismissed) {
        
        [self.viewModel pause];
    }
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (!self.isBeingPresented &&
        !self.isBeingDismissed) {
        
        [self.viewModel stop];
    }
}

@end
