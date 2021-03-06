//
//  TableViewController.m
//  BBFrameworks
//
//  Created by William Towe on 6/18/15.
//  Copyright (c) 2015 Bion Bilateral, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "TableViewController.h"
#import "ViewsRowViewController.h"
#import "ThumbnailsRowViewController.h"
#import "WebViewRowViewController.h"
#import "TooltipsRowViewController.h"
#import "MediaPickerViewController.h"
#import "MediaPlayerViewController.h"
#import "AddressBookViewController.h"
#import "FormViewController.h"
#import "TokenViewController.h"
#import "TransitionViewController.h"
#import "ValidationViewController.h"
#import "KeyValueObservingViewController.h"
#import "MediaViewerViewController.h"
#import "TimerViewController.h"

@interface TableViewController ()
@property (copy,nonatomic) NSArray *rowClasses;
@end

@implementation TableViewController

- (NSString *)title {
    return @"BBFrameworksiOSDemo";
}

- (instancetype)init {
    if (!(self = [super init]))
        return nil;
    
    [self setRowClasses:@[[TimerViewController class],
                          [MediaViewerViewController class],
                          [KeyValueObservingViewController class],
                          [ViewsRowViewController class],
                          [ValidationViewController class],
                          [FormViewController class],
                          [TokenViewController class],
                          [TransitionViewController class],
                          [ThumbnailsRowViewController class],
                          [WebViewRowViewController class],
                          [TooltipsRowViewController class],
                          [MediaPickerViewController class],
                          [MediaPlayerViewController class],
                          [AddressBookViewController class]]];
    
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rowClasses.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([UITableViewCell class])];
        
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    [cell.textLabel setText:[self.rowClasses[indexPath.row] rowClassTitle]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.splitViewController showDetailViewController:[[self.rowClasses[indexPath.row] alloc] init] sender:self];
}

@end
