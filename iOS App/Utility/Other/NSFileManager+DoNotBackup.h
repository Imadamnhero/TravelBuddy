//
//  NSFileManager+DoNotBackup.h
//  Fun Spot App
//
//  Created by PradeepSundriyal on 02/05/13.
//
//

#import <Foundation/Foundation.h>

@interface NSFileManager (DoNotBackup)

//- (BOOL)c:(NSURL *)URL;
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

@end
