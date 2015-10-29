//
//  BBMediaPickerViewController.h
//  BBFrameworks
//
//  Created by William Towe on 7/29/15.
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
#import "BBMediaPickerDefines.h"
#import "BBMediaPickerViewControllerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Completion block that is invoked when authorization status is requested.
 
 @param success YES if the user granted access to their media, otherwise NO
 @param error If the user denied access to their media and more information is available, this will be non-nil
 */
typedef void(^BBMediaPickerAuthorizationCompletionBlock)(BOOL success, NSError *_Nullable error);

/**
 BBMediaPickerViewController is a UIViewController subclass that mirrors the media browsing functionality provided by UIImagePickerController.
 */
@interface BBMediaPickerViewController : UIViewController

/**
 The authorization status of the app to access the user's media.
 
 @see BBMediaPickerAuthorizationStatus
 */
+ (BBMediaPickerAuthorizationStatus)authorizationStatus;
/**
 Requests access to the user's media and invokes the completion handler with the result. If the user has denied access and more information is available, error will be non-nil.
 
 @param completion The completion block that is invoked once the authorization status is determined
 */
+ (void)requestAuthorizationWithCompletion:(nullable BBMediaPickerAuthorizationCompletionBlock)completion;

/**
 Set and get the delegate of the receiver.
 
 @see BBMediaPickerViewControllerDelegate
 */
@property (weak,nonatomic,nullable) id<BBMediaPickerViewControllerDelegate> delegate;

/**
 Set and get whether the receiver allows multiple selection.
 
 The default is NO.
 */
@property (assign,nonatomic) BOOL allowsMultipleSelection;
/**
 Set and get whether the receiver hides empty media groups.
 
 The default is NO.
 */
@property (assign,nonatomic) BOOL hidesEmptyMediaGroups;
/**
 Set and get whether the receiver should automatically dismiss itself when the user selects media in single selection mode.
 
 The default is YES.
 */
@property (assign,nonatomic) BOOL automaticallyDismissForSingleSelection;

/**
 Set and get the block used to transform the title displayed in the navigation bar.
 
 The default is nil.
 
 @see BBMediaPickerTitleTransformBlock
 */
@property (copy,nonatomic,nullable) BBMediaPickerTitleTransformBlock titleTransformBlock;

/**
 Set and get whether the receiver should create and display the cancel and done bar button items. If NO, the bar button items are not displayed on the right side of the navigation bar and dismissing the client is up to the client.
 
 The default is YES.
 */
@property (assign,nonatomic) BOOL shouldShowCancelAndDoneBarButtonItems;
/**
 Set and get the custom cancel bar button item displayed in the top right of the receiver's navigation bar. The standard system cancel is used by default.
 */
@property (strong,nonatomic,null_resettable) UIBarButtonItem *cancelBarButtonItem;

/**
 Set and get the allowed media types of the receiver.
 
 The default is BBMediaPickerMediaTypesAll.
 
 @see BBMediaPickerMediaTypes
 */
@property (assign,nonatomic) BBMediaPickerMediaTypes mediaTypes;

/**
 Set and get the media filter block of the receiver. The allows the client fine grained control over the media that is displayed. The block will be invoked once for each media object after the media has been filtered according to the mediaTypes value of the receiver.
 
 The default is nil.
 
 @see BBMediaPickerMediaFilterBlock
 */
@property (copy,nonatomic,nullable) BBMediaPickerMediaFilterBlock mediaFilterBlock;

/**
 Set and get the cancel confirm block of the receiver. If non-nil, this will be invoked and the completion block value consulted before dismissing the receiver. This can be used to provide confirmation to the user before ending interaction with the receiver.
 
 The default is nil.
 
 @see BBMediaPickerCancelConfirmBlock
 */
@property (copy,nonatomic,nullable) BBMediaPickerCancelConfirmBlock cancelConfirmBlock;

/**
 Set and get the asset bottom accessory view class. If non-nil, an instance of this class is placed at the bottom of each view in the picker anchored to the bottom of its superview. It should implement the `sizeThatFits:` so its desired height can be determined. It will always have its width set to the width of its superview.
 
 The default is Nil.
 */
@property (strong,nonatomic,nullable) Class bottomAccessoryViewClass;

/**
 Returns the number of media objects being displayed.
 
 @return The number of media objects
 */
- (NSInteger)countOfMedia;
/**
 Returns the index of the provided media object, or NSNotFound if the media object cannot be found.
 
 @param media The media object for which to return index
 @return The index of media or NSNotFound if media does not exist
 */
- (NSInteger)indexOfMedia:(id<BBMediaPickerMedia>)media;
/**
 Returns the media at the provided index or nil if index is out of bounds.
 
 @param index The index of the media object to return
 @return The media object or nil
 */
- (nullable id<BBMediaPickerMedia>)mediaAtIndex:(NSInteger)index;

/**
 Scrolls the collection view containing media so that it is visible, centered vertically. If the media does not exist in the collection view, does nothing.
 
 @param media The media to scroll to visible
 */
- (void)scrollMediaToVisible:(id<BBMediaPickerMedia>)media;

@end

/**
 Category on UIViewController providing access to the nearest media picker view controller.
 */
@interface UIViewController (BBMediaPickerViewControllerExtensions)

/**
 Returns the nearest media picker view controller in the view hierarchy, or nil if there is not one.
 
 @return The media picker view controller or nil
 */
- (nullable BBMediaPickerViewController *)BB_mediaPickerViewController;

@end

NS_ASSUME_NONNULL_END
