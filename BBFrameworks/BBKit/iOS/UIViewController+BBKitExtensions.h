//
//  UIViewController+BBKitExtensions.h
//  BBFrameworks
//
//  Created by William Towe on 5/29/15.
//  Copyright (c) 2015 Bion Bilateral, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Category on UIViewController adding various convenience methods.
 */
@interface UIViewController (BBKitExtensions)

/**
 Calls `[[UIApplication sharedApplication].keyWindow.rootViewController BB_viewControllerForPresenting]`.
 
 @return The view controller
 */
+ (UIViewController *)BB_viewControllerForPresenting;
/**
 Returns the view controller that should be used for modal presentation.
 
 @return The view controller
 */
- (UIViewController *)BB_viewControllerForPresenting;

/**
 Creates and returns an array of the receiver's child view controllers recursively.
 
 For each child view controller in the receiver, the child view controller is added to the return array followed by the array of recursive child view controllers.
 
 @return The array of recursive child view controllers
 */
- (NSArray<__kindof UIViewController *> *)BB_recursiveChildViewControllers;

@end

NS_ASSUME_NONNULL_END