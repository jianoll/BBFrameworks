//
//  BBAddressBookManager.h
//  BBFrameworks
//
//  Created by William Towe on 6/30/15.
//  Copyright (c) 2015 Bion Bilateral, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <Foundation/Foundation.h>
#import <AddressBook/ABAddressBook.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Enum describing the authorization status of the AddressBook framework.
 */
typedef NS_ENUM(NSInteger, BBAddressBookManagerAuthorizationStatus) {
    /**
     The status has not been determined for the calling application. The appropriate alert will be shown to grant access upon request.
     */
    BBAddressBookManagerAuthorizationStatusNotDetermined = kABAuthorizationStatusNotDetermined,
    /**
     The status has been restricted and the current user may not be able to modify it.
     */
    BBAddressBookManagerAuthorizationStatusRestricted = kABAuthorizationStatusRestricted,
    /**
     The user has denied access to the calling application. Prompt the user to adjust access in the Settings application.
     */
    BBAddressBookManagerAuthorizationStatusDenied = kABAuthorizationStatusDenied,
    /**
     The user has granted access to the calling application.
     */
    BBAddressBookManagerAuthorizationStatusAuthorized = kABAuthorizationStatusAuthorized
};

@class BBAddressBookPerson,BBAddressBookGroup;

/**
 Notification is posted when the contents of the address book change. Discard all model objects and reques them again.
 */
extern NSString *const BBAddressBookManagerNotificationNameExternalChange;

/**
 BBAddressBookManager is a NSObject subclass that manages a ABAddressBookRef object and provides the groups and people objects it contains. People and groups are represented by BBAddressBookPerson and BBAddressBookGroup.
 */
@interface BBAddressBookManager : NSObject

/**
 Returns the current authorization status.
 
 @see BBAddressBookManagerAuthorizationStatus
 */
+ (BBAddressBookManagerAuthorizationStatus)authorizationStatus;

/**
 Requests authorization to access the user's contacts and invokes the completion block with YES or NO, and an error if NO.
 
 @param completion The completion block that is invoked once authorization status has been determined
 @exception NSException Thrown if completion is nil
 */
- (void)requestAuthorizationWithCompletion:(void(^)(BOOL success, NSError *_Nullable error))completion;

/**
 Calls `[self requestPeopleWithRecordIDs:completion:]`, passing @[@(recordID)] and completion respectively.
 
 @param recordID The record id of the person
 @param completion The completion block to invoke once the request is complete
 @exception NSException Thrown if completion is nil
 */
- (void)requestPersonWithRecordID:(ABRecordID)recordID completion:(void(^)(BBAddressBookPerson *person, NSError *_Nullable error))completion;
/**
 Attempts to fetch BBAddressBookPerson objects for the provided record ids and invokes the completion block when the operation is complete.
 
 @param recordIDs The array of record ids to fetch people for
 @param completion The completion block to invoke once the request is complete
 @exception NSException Thrown if recordIDs or completion are nil
 */
- (void)requestPeopleWithRecordIDs:(NSArray<NSNumber *> *)recordIDs completion:(void(^)(NSArray<BBAddressBookPerson *> *people, NSError *_Nullable error))completion;

/**
 Calls `[self requestGroupsWithRecordIDs:completion:]`, passing @[@(recordID)] and completion respectively.
 
 @param recordID The record id of the group
 @param completion The completion block to invoke once the request is complete
 @exception NSException Thrown if completion is nil
 */
- (void)requestGroupWithRecordID:(ABRecordID)recordID completion:(void(^)(BBAddressBookGroup *group, NSError *_Nullable error))completion;
/**
 Attempts to fetch BBAddressBookGroup objects for the provided record ids and invokes the completion block when the operation is complete.
 
 @param recordIDs The array of record ids to fetch groups for
 @param completion The completion block to invoke once the request is complete
 @exception NSException Thrown if recordIDs or completion are nil
 */
- (void)requestGroupsWithRecordIDs:(NSArray<NSNumber *> *)recordIDs completion:(void(^)(NSArray<BBAddressBookGroup *> *groups, NSError *_Nullable error))completion;

/**
 Calls `[self requestAllPeopleWithSortDescriptors:completion:]`, passing nil and completion respectively.
 
 @param completion The completion block that is invoked when the request is complete
 @exception NSException Thrown if completion is nil
 */
- (void)requestAllPeopleWithCompletion:(void(^)(NSArray *people, NSError *_Nullable error))completion;
/**
 Requests all people in the address book sorted with the provided sort descriptors and invokes the completion block when the request is complete. The array of people in the completion block will contain BBAddressBookPerson instances. See BBAddressBookPerson.h for supported keys for sorting.
 
 @param sortDescriptors The array of sort descriptors to sort the return BBAddressBookPerson objects by
 @param completion The completion block to invoke when the operation is complete
 @exception NSException Thrown if completion is nil
 */
- (void)requestAllPeopleWithSortDescriptors:(nullable NSArray *)sortDescriptors completion:(void(^)(NSArray<BBAddressBookPerson *> *people, NSError *_Nullable error))completion;

/**
 Calls `[self requestAllGroupsWithSortDescriptors:completion:]`, passing nil and completion respectively.
 
 @param completion The completion block that is invoked when the request is complete
 @exception NSException Throw if completion is nil
 */
- (void)requestAllGroupsWithCompletion:(void(^)(NSArray<BBAddressBookGroup *> *groups, NSError *_Nullable error))completion;
/**
 Requests all groups in the address book sorted with the provided sort descriptors and invokes the completion block when the request is complete. The array of groups in the completion block will contain BBAddressBookGroup instances. See BBAddressBookGroup.h for supported keys for sorting.
 
 @param sortDescriptors The array of sort descriptors to sort the return BBAddressBookGroup objects by
 @param completion The completion block to invoke when the operation is complete
 @exception NSException Thrown if completion is nil
 */
- (void)requestAllGroupsWithSortDescriptors:(nullable NSArray *)sortDescriptors completion:(void(^)(NSArray<BBAddressBookGroup *> *groups, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
