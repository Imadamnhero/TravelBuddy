//
//  IMSSqliteManager.h
//  Fun Spot AppΩßßå
//
//  Created by Pradeep Sundriyal on 09/10/12.
//
//

#import <Foundation/Foundation.h>
#import "ApplicationData.h"
#import "User.h"
#import "TripObj.h"
#import "NoteObj.h"
#import "VersionObj.h"
#import "ExpenseObj.h"
#import "PackingItemObj.h"
#import "PackingTitleObj.h"
#import "PremadeItemObj.h"
#import "PremadeListObj.h"
#import "PhotoObj.h"
#import "SlideVideo.h"
#import "SlideShow.h"
#import "CategoryObj.h"

@interface IMSSqliteManager : NSObject{
    
}

- (void)dropTable:(NSString*)tableName;
- (void)createTable:(NSString*)tableName;

- (void)addApplicationData:(ApplicationData *)applicationData;
- (void)addToFunKey:(NSString*)Key Value:(NSString*) Value;
//- (void)addEvents:(NSDictionary*)dictEvents;
- (void)addEvents:(NSString*)Key Value:(NSString*) Value;
- (void)addUpdates:(NSString*)Key Value:(NSString*)Value status:(bool)Status;

- (void)saveImage:(NSString *)imageName Image:(UIImage *)image;
- (NSData*)image:(NSString *)imageName;

//addEvents
//- (void)addFunSpotEvents:(Event *)event;

// Home Event
- (NSMutableArray*)getHomeEvents;
- (void)storeHomeEventList:(NSMutableArray*)arrEvents;
//- (void)updateHomeEvents:(Event *)event;

//Add Stores
- (void)storeEventCategories:(NSMutableArray*)arrCategory;
- (void)storeEventList:(NSMutableArray*)arrEvents;

- (void)saveStoreSection:(NSMutableArray*)arrStoreSection;
- (NSMutableArray*)getStoreSection;

- (void)saveStoreSubSection:(NSMutableArray*)arrSubSection;
- (NSMutableArray*)getStoreSubSection:(NSInteger)LevelId;

//-(void)saveStoreDescription:(NSMutableArray*)storeListArr;
- (void)saveStoreDescription:(NSMutableArray*)storeListArr;
- (NSMutableArray*)getStoreDescription:(NSInteger)SubLevelID;

//Choose (Application)
- (void)storePlaceApplication:(NSMutableArray*)arrPlaces;
- (NSMutableArray*)getPlaceApplicationList;
- (void)clearPlaceApplicationContent;

//Choose (Theme)
- (void)storePlaceTheme:(NSMutableArray*)arrPlaces;
- (NSMutableArray*)getPlaceThemeList;
- (void)clearPlaceThemeContent;

- (void)storePlaceThemeListApplications:(NSMutableArray*)arrPlaces;
- (NSMutableArray*)getPlaceThemeListApplications;
- (void)clearPlaceThemeListApplicationsContent;

//Videos
- (void)storeVideos:(NSMutableArray*)arrVideos;
- (NSMutableArray*)getVideoList;
- (void)clearVideoContent;

//Place
- (NSMutableArray*)getPlacesList : (NSInteger) groupeid;
- (void)clearPlacesContent;
- (void)storePlaces:(NSMutableArray*)arrPlaces ;
- (NSMutableArray*)getPlacesThemeList;

//- (NSDictionary*)readEvents:(NSString*)rowID;
- (NSDictionary*)readFun;
- (NSDictionary*)readImages;
- (NSInteger)funSpotTableCount;
- (NSDictionary *)readTimeofLastUpdate:(NSString*)Key;
//- (NSDictionary*)readAppImages;
- (NSMutableArray*)readEvents;//:(NSInteger)eventId
- (NSMutableArray*)getGalleryImages;
- (NSMutableArray *)readEventCategories;
- (NSMutableArray*)getEvents:(NSInteger)categoryId;
- (void)storeNews:(NSMutableArray*)arrNews;
- (NSMutableArray *)readNews;
- (void)storeEventPlaces:(NSMutableArray*)arrEvents;
- (NSMutableArray *)readPlaceEvents;
- (void)storeCoupons:(NSMutableArray*)arrCoupons;
- (NSMutableArray *)readCouponsForType:(DiscountType)type;
- (NSMutableArray*)getIconImages;

- (void)clearNewsContent;
- (void)clearInfosContent;
- (void)clearEventsContent;
- (void)clearIcons;
- (void)clearGalleryContent;

- (NSData*)getIconImage:(NSString *)imgName;
- (void)saveIconImage:(NSString *)imageName Image:(UIImage *)image;

- (void)addVersionUpdates:(float)versionNumber status:(bool)Status;
- (double)getApplicationVersion;
- (void)dropAndCreateTables;
- (UIImage*)getGalleryImageAtIndex:(NSInteger)index;

//============================== TRAVEL BUDDY =================================

// =========== TABLE USERS ===========
// add user
- (void)saveUser:(User*)dictUser;
//update user
- (void)updateUserInfor:(User *)dictUser;
//get list User in trip
- (NSMutableArray*)getUserInfor:(int)tripId;
//get all User
- (NSMutableArray*)getAllUserInfor:(int)tripId;
//delete user
- (void)deleteUser:(int)userId;

// =========== TABLE TRIPS ===========
// add trip
- (void)addTripInfor:(TripObj*)dictTrip;
// update trip
- (void)updateTripInfor:(TripObj*)dictTrip;
//update name trip
- (void)updateNameTrip:(NSInteger )tripID name:(NSString *)newName  owner:(NSInteger) userId_owner_current;
// get trip
- (NSMutableArray*)getTripInfor:(int)userId;
//update trip budget
- (void)updateTripBudget:(NSString*)budget tripId:(NSInteger)tripID;

// =========== TABLE NOTES===========
// add note
- (void)addNoteInfor:(NoteObj*)dictNote;
//get all note
- (NSMutableArray*)getNotes;
// update Note
- (void)updateNote:(NoteObj*)dictNote;
// update Note from Server
- (void)updateNoteFromServer:(int)clientId withServerId:(int)serverId;
//delete Note
- (void)deleteNote:(int)noteId;


// =========== TABLE VERSION ===========
// add version
- (void)addVersionInfor:(VersionObj*)dictVersion;
// update Version
- (void)updateVersion:(VersionObj*)dictVersion;
//get version of trip
- (NSMutableArray*)getVersion;
// update Version from Server
- (void)updateVersionFromServer:(NSString*)versionName withVersion:(int)newVersion andUserId:(int)userId;


// =========== TABLE EXPENSES ===========
// add EXPENSES
- (void)addExpenseInfor:(ExpenseObj*)dictExp;
//GET ALL EXPENSES
- (NSMutableArray*)getAllExpenses;
//GET EXPENSES
- (NSMutableArray*)getExpenses:(int)categoryId;
// update EXPENSES
- (void)updateExpense:(ExpenseObj*)dictExp;
// update EXPENSES from Server
- (void)updateExpenseFromServer:(int)clientId withServerId:(int)serverId;
//delete Expense
- (void)deleteExpense:(int)expenseId;
//delete Expense
- (void)deleteExpenseCategory:(int)cateId;


// =========== TABLE PACKING TITLE ===========
// add PACKING TITLE
- (int)addPackingTitleInfor:(PackingTitleObj*)dictPackingTitle;
//GET PACKING TITLE
- (NSMutableArray*)getPackingTitle;
// update PACKING TITLE
- (void)updatePackingTitle:(PackingTitleObj*)dictPackingTitle;
// update EXPENSES from Server
- (void)updatePackingTitleFromServer:(int)clientId withServerId:(int)serverId;
// update Packing Title ServerId
- (void)updateServerIdPackingTitle:(int)packingTitleId withServerId:(int)serverId;
//delete Packing Item
- (void)deletePackingTitle:(int)packingTitleId;

// =========== TABLE PACKING ITEM ===========
// add PACKING ITEM
- (void)addPackingItemInfor:(PackingItemObj*)dictPackItem;
//GET PACKING ITEM
- (NSMutableArray*)getPackingItems:(int)packingId;
// update PACKING ITEM
- (void)updatePackingItem:(PackingItemObj*)dictPackingItem;
// update Packing Item from Server
- (void)updatePackingItemFromServer:(int)clientId withServerId:(int)serverId;
//delete Packing Item
- (void)deletePackingItem:(int)packingItemId;

// =========== TABLE PREMADE LIST ===========
// add PREMADE LIST
- (void)addPremadeListInfor:(PremadeListObj*)dictPremadeList;
//GET PREMADE LIST
- (NSMutableArray*)getPremadeList;


// =========== TABLE PREMADE ITEM ===========
// add PREMADE ITEM
- (void)addPremadeItemInfor:(PremadeItemObj*)dictPremadeItem;
//GET PREMADE ITEM
- (NSMutableArray*)getPremadeItem:(int)listId;


// =========== TABLE PHOTO ===========
// add PHOTO
- (void)addPhotoInfor:(PhotoObj*)dictPhoto;
// add PHOTO Receipt
- (int)addPhotoReceiptInfor:(PhotoObj*)dictPhoto;
//GET PHOTO ITEM
- (NSMutableArray*)getPhotoItems:(int)userId andReceipt:(int)isReceipt;
// update Photos from Server
- (void)updatePhotoFromServer:(int)clientId withServerId:(int)serverId;
// update Photos Url from Server
- (void)updatePhotoUrlFromServer:(int)clientId withPhotoUrl:(NSString*)imageName;
//delete Photo
- (void)deletePhoto:(int)photoId;
//GET PHOTO SYNCHRONIZED
- (NSMutableArray*)getPhotoItemsSync:(int)userId andReceipt:(int)isReceipt;


// =========== TABLE SLIDESHOW ===========
// add slideshow
- (void)saveSlideshow:(NSString*)urlServerLink photo:(NSString*)urlPhoto;
//delete Slideshow
- (void)deleteSlideshow:(int)slideshowId;
//get slideshow list
- (NSMutableArray*)getSlideshowList:(int)tripId;


// =========== TABLE CATEGORIES ===========
// add Category
- (int)addCategoryInfor:(CategoryObj*)dictCategory;
//GET Category LIST
- (NSMutableArray*)getCategoryList;
// update Category from Server
- (void)updateCategoryFromServer:(int)clientId withServerId:(int)serverId;
// update Category
- (void)updateCategory:(CategoryObj*)dictExp;
//delete Category
- (void)deleteCategory:(int)categoryId;


// =========== TABLE COLORS ===========
// add Color
- (void)addColor:(NSString*)color;
//GET Category LIST
- (NSMutableArray*)getColor;


@end