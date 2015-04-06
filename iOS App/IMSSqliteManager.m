//
//  IMSSqliteManager.m
//  Fun Spot App
//
//  Created by Pradeep Sundriyal on 09/10/12.
//
//

#import "IMSSqliteManager.h"
#import <sqlite3.h>
#import "Common.h"
//#import "EventCategory.h"
//#import "StoreSection.h"
//#import "StoreSubSection.h"
//#import "StoreItemDescription.h"

//#import "News.h"
//#import "Coupons.h"
//#import "ChooseItem.h"
//#import "Video.h"
//#import "Place.h"

@interface IMSSqliteManager ()
- (void)executeQuery:(NSString*)query;
- (int)recordExists:(NSString*)query;
- (char*)checkNull:(char*)str;
@end

static sqlite3 *database = nil;

static sqlite3_stmt *createStmt = nil;
static sqlite3_stmt *addStmt = nil;
static sqlite3_stmt *updateStmt = nil;
static sqlite3_stmt *deleteStmt = nil;
static sqlite3_stmt *queryStmt = nil;

@implementation IMSSqliteManager

- (void)executeQuery:(NSString*)query{
	if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
	{
		const char *sql = [query UTF8String];
		if(sqlite3_prepare_v2(database, sql, -1, &queryStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error :: while creating delete statement. '%s'", sqlite3_errmsg(database));
		else {
			sqlite3_exec(database, sql, NULL, NULL, NULL);
		}
		sqlite3_reset(queryStmt);
	}
	sqlite3_close(database);
}

- (int)recordExists:(NSString*)query {
    
	sqlite3 *database;
	
    // Open the database from the users filessytem
	if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
		
        // Setup the SQL Statement and compile it for faster access
		const char *sqlStatement = [query UTF8String];
		sqlite3_stmt *compiledStatement;
        
		if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			
            if (sqlite3_step(compiledStatement) == SQLITE_ROW) {

                int primaryKey = sqlite3_column_int(compiledStatement, 0);
                sqlite3_reset(compiledStatement);
				sqlite3_finalize(compiledStatement);
				sqlite3_close(database);
				return primaryKey;
			}
		}
        
		sqlite3_reset(compiledStatement);
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
    
	sqlite3_close(database);
	return 0;
}

- (void)dropTable:(NSString*)tableName
{
	if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
	{
		NSString *query=[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@",tableName];
        //#ifdef DEBUG
        //        NSLog( @"query = %@",query);
        //#endif
		const char *sql = [query UTF8String];
		if(sqlite3_prepare_v2(database, sql, -1, &deleteStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
		else {
			sqlite3_exec(database, sql, NULL, NULL, NULL);
		}
		sqlite3_reset(deleteStmt);
		sqlite3_finalize(deleteStmt);
	}
	sqlite3_close(database);
	
    //	[self createTable:tableName];
}




- (void)executeScript:(NSString*)query{
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
    {
        const char *sql = [query UTF8String];
        if(sqlite3_prepare_v2(database, sql, -1, &queryStmt, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
        else {
            sqlite3_exec(database, sql, NULL, NULL, NULL);
        }
        sqlite3_reset(queryStmt);
        sqlite3_finalize(queryStmt);
    }
    sqlite3_close(database);
}

- (void) clearIcons
{
    NSLog(@"drop");
    [self dropTable:@"IconImages"];
    [self createTable:@"IconImages"];
    
}

//
//
-(void)clearNewsContent{
    // NSLog(@"PATH FOR DB = %@",[Common getFilePath:DATABASE]);
    
    [self dropTable:@"News"];
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
	{
		NSString *query=@"DELETE from AppImages where imageName like '%News_%'";
        if(![self recordExists:query]){
            //do nothing
            NSLog(@"do nothing");
        }else{
            
            //#ifdef DEBUG
            NSLog( @"query = %@",query);
            //#endif
            const char *sql = [query UTF8String];
            if(sqlite3_prepare_v2(database, sql, -1, &deleteStmt, NULL) != SQLITE_OK)
                NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
            else {
                sqlite3_exec(database, sql, NULL, NULL, NULL);
            }
            sqlite3_reset(deleteStmt);
            sqlite3_finalize(deleteStmt);
        }
    }
	sqlite3_close(database);
}



-(void)clearInfosContent{
    [self dropTable:@"StoreItems"];
    [self dropTable:@"Themes"];
    [self dropTable:@"SubThemes"];
    [self dropTable:@"StoreSection"];
    [self dropTable:@"StoreSubSection"];
    [self dropTable:@"StoreDescription"];
    [self createTable:@"AppImages"];
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
	{
		NSString *query=@"DELETE from AppImages where imageName like '%Store_%'";
        //#ifdef DEBUG
        //        NSLog( @"query = %@",query);
        //#endif
		const char *sql = [query UTF8String];
		if(sqlite3_prepare_v2(database, sql, -1, &deleteStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
		else {
			sqlite3_exec(database, sql, NULL, NULL, NULL);
		}
		sqlite3_reset(deleteStmt);
		sqlite3_finalize(deleteStmt);
	}
	sqlite3_close(database);
    
}

-(void)clearEventsContent{
    [self dropTable:@"Events"];
    [self dropTable:@"EventCategory"];
    [self dropTable:@"EventPlace"];
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
	{
        
        NSString *query_ = @"SELECT 1 from AppImages where imageName like '%Event_%'";
        if([self recordExists:query_])
        {
            NSString *query=@"DELETE from AppImages where imageName like '%Event_%'";
            //#ifdef DEBUG
            //        NSLog( @"query = %@",query);
            //#endif
            const char *sql = [query UTF8String];
            if(sqlite3_prepare_v2(database, sql, -1, &deleteStmt, NULL) != SQLITE_OK)
                NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
            else {
                sqlite3_exec(database, sql, NULL, NULL, NULL);
            }
            sqlite3_reset(deleteStmt);
            sqlite3_finalize(deleteStmt);
        }
        
		
	}
	sqlite3_close(database);
}

- (void)clearGalleryContent {
    
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
        NSString *query_ = @"SELECT 1 from AppImages where imageName like '%GalleryImage_%'";
        
        if ([self recordExists:query_]) {
            NSString *query = @"DELETE from AppImages where imageName like '%GalleryImage_%'";

            const char *sql = [query UTF8String];
            if (sqlite3_prepare_v2(database, sql, -1, &deleteStmt, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
            } else {
                sqlite3_exec(database, sql, NULL, NULL, NULL);
            }
            
            sqlite3_reset(deleteStmt);
            sqlite3_finalize(deleteStmt);
        }
	}

	sqlite3_close(database);
}




- (char*)checkNull:(char*)str
{
    if(!str)
        return "";
    return str;
}

-(void)dropAndCreateTables{
    [self dropTable:@"Versions"];
    [self dropTable:@"Notes"];
    [self dropTable:@"Groups"];
    [self dropTable:@"Photos"];
    [self dropTable:@"Expenses"];
    [self dropTable:@"Categories"];
    [self dropTable:@"PackingTitles"];
    [self dropTable:@"PackingItems"];
    [self dropTable:@"PremadeLists"];
    [self dropTable:@"PremadeItems"];
    [self dropTable:@"Users"];
    [self dropTable:@"Trips"];
    [self dropTable:@"Colors"];
    [self dropTable:@"Slideshow"];
}

- (void)createTable:(NSString*)tableName{
    
    @synchronized(self)
    {
        if ([tableName isEqualToString:@"Versions"] || [tableName isEqualToString:@"Notes"] || [tableName isEqualToString:@"Groups"] || [tableName isEqualToString:@"Photos"] || [tableName isEqualToString:@"Expenses"]  || [tableName isEqualToString:@"Categories"] || [tableName isEqualToString:@"PackingTitles"] || [tableName isEqualToString:@"PackingItems"] || [tableName isEqualToString:@"PremadeLists"] || [tableName isEqualToString:@"PremadeItems"] || [tableName isEqualToString:@"Users"] || [tableName isEqualToString:@"AppImages"] || [tableName isEqualToString:@"Slideshow"] || [tableName isEqualToString:@"Colors"]) {
        } else {
            [self dropTable:tableName];
        }
    }
    
    NSString *query;
    
    if ([tableName isEqualToString:@"Versions"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY NOT NULL,noteversion INTEGER, categoryversion INTEGER, expenseversion INTEGER, groupversion INTEGER, photoversion INTEGER, packingtitleversion INTEGER, packingitemversion INTEGER, premadelistversion INTEGER, premadeitemversion INTEGER,userversion INTEGER, user_id INTEGER)",tableName];
    }else if ([tableName isEqualToString:@"Trips"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY NOT NULL, triplocation VARCHAR,startdate VARCHAR , finishdate VARCHAR,budget VARCHAR, owner_user_id INTEGER,trip_id INTEGER)",tableName];
    }else if ([tableName isEqualToString:@"Notes"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY NOT NULL, title VARCHAR, dateTime VARCHAR, content VARCHAR,owner_user_id INTEGER, trip_id INTEGER, server_id INTEGER, flag INTEGER)",tableName];
    }else if ([tableName isEqualToString:@"Groups"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY NOT NULL, trip_id INTEGER, server_id INTEGER, user_id INTEGER, flag INTEGER)",tableName];
    }else if ([tableName isEqualToString:@"Photos"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY NOT NULL, caption VARCHAR,urlphoto VARCHAR, isreceipt INTEGER, trip_id INTEGER, owner_user_id INTEGER, server_id INTEGER, flag INTEGER)",tableName];
    }else if ([tableName isEqualToString:@"Expenses"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY NOT NULL, cateId INTEGER, dateTime VARCHAR, money VARCHAR, item VARCHAR, trip_id INTEGER, owner_user_id INTEGER, server_id INTEGER, flag INTEGER)",tableName];
    }else if ([tableName isEqualToString:@"PackingTitles"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY NOT NULL, title VARCHAR, owner_user_id INTEGER, server_id INTEGER, flag INTEGER)",tableName];
    }else if ([tableName isEqualToString:@"PackingItems"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY NOT NULL, itemname VARCHAR, ischeck INTEGER, packing_id INTEGER, server_id INTEGER, flag INTEGER, idaddnew INTEGER)",tableName];
    }else if ([tableName isEqualToString:@"PremadeLists"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY NOT NULL, title VARCHAR, server_id INTEGER, flag INTEGER)",tableName];
    }else if ([tableName isEqualToString:@"PremadeItems"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY NOT NULL, nameitem VARCHAR, list_id INTEGER, server_id INTEGER, flag INTEGER)",tableName];
    }else if ([tableName isEqualToString:@"Users"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY NOT NULL,user_id INTEGER, trip_id INTEGER, name VARCHAR, avatarurl VARCHAR)",tableName];
    }else if ([tableName isEqualToString:@"Slideshow"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY NOT NULL,user_id INTEGER, trip_id INTEGER, serverurl VARCHAR, photourl VARCHAR)",tableName];
    }else if ([tableName isEqualToString:@"Categories"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY NOT NULL,user_id INTEGER, server_id INTEGER, title VARCHAR, color VARCHAR, flag INTEGER)",tableName];
    }else if ([tableName isEqualToString:@"Colors"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY NOT NULL,user_id INTEGER, color VARCHAR)",tableName];
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    else if ([tableName isEqualToString:@"Events"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY NOT NULL, CategoryId INTEGER,eventId INTEGER , eventDescription VARCHAR,eventPhoto VARCHAR, eventTitle VARCHAR,locationDateStart VARCHAR,locationDateEnd VARCHAR, rowOrder INTEGER,eID VARCHAR,latitude VARCHAR,longitude VARCHAR,EventUrl VARCHAR,LocationBillet VARCHAR, EventSound VARCHAR, EventVideo VARCHAR, adress VARCHAR, city VARCHAR ,location VARCHAR,typeadress VARCHAR, zip INTEGER, EventPhotoUrl VARCHAR)",tableName];
        
    } else if ([tableName isEqualToString:@"HomeEvents"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY NOT NULL, CategoryId INTEGER,eventId INTEGER , eventDescription VARCHAR,eventPhoto VARCHAR, eventTitle VARCHAR,locationDateStart VARCHAR,locationDateEnd VARCHAR, rowOrder INTEGER,eID VARCHAR,latitude VARCHAR,longitude VARCHAR,EventUrl VARCHAR,LocationBillet VARCHAR, EventSound VARCHAR, EventVideo VARCHAR, adress VARCHAR, city VARCHAR ,location VARCHAR,typeadress VARCHAR, zip INTEGER, EventPhotoUrl VARCHAR)",tableName];
        
    } else if ([tableName isEqualToString:@"AppImages"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY NOT NULL, imageName VARCHAR, image BLOB)",tableName];
        
    } else if ([tableName isEqualToString:@"IconImages"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY NOT NULL, imageName VARCHAR, image BLOB)",tableName];
        
    } else if ([tableName isEqualToString:@"StoreItems"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY NOT NULL, rowOrder INTEGER, storeItemID INTEGER, storeItemRef VARCHAR, storeItemPrice INTEGER, storeItemName VARCHAR,storeItemDesc VARCHAR,storeItemImage VARCHAR)",tableName];
        
    } else if ([tableName isEqualToString:@"Themes"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY NOT NULL, rowOrder INTEGER,magasinLevelId INTEGER,magasinLevelName VARCHAR)",tableName];
        
    } else if ([tableName isEqualToString:@"SubThemes"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY NOT NULL, rowOrder INTEGER,magasinSubLevelId INTEGER,magasinSubLevelName VARCHAR)",tableName];
        
    } else if ([tableName isEqualToString:@"EventCategory"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY NOT NULL, CategoryId INTEGER,rowOrder INTEGER,CategoryNom VARCHAR, CategoryLogo VARCHAR)",tableName];
        
    } else if ([tableName isEqualToString:@"StoreSection"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@  (LevelID INTEGER PRIMARY KEY NOT NULL,LevelLogo VARCHAR, LevelName VARCHAR, sid VARCHAR,  rowOrder INTEGER,MagasinId INTEGER)",tableName];
        
    } else if ([tableName isEqualToString:@"StoreSubSection"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (SubLevelID INTEGER PRIMARY KEY NOT NULL,LevelID integer,SubLevelLogo VARCHAR, SubLevelName VARCHAR, sid VARCHAR, rowOrder INTEGER, MagasinId INTEGER)",tableName];
        
    } else if ([tableName isEqualToString:@"StoreDescription"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ItemID INTEGER PRIMARY KEY NOT NULL,SubLevelID INTEGER,ItemDescription VARCHAR, ItemImage VARCHAR, ItemName int,ItemPrice int, ItemRef VARCHAR, sid VARCHAR,rowOrder INTEGER,ItemOrder INTEGER, ItemUrl VARCHAR,MagasinItemVideo VARCHAR,MagasinItemSound VARCHAR,MagasinId VARCHAR,MagasinItemFile VARCHAR)",tableName];
        
    } else if ([tableName isEqualToString:@"News"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY NOT NULL,NewsDate VARCHAR,NewsDescription VARCHAR, NewsId int, NewsPhoto varchar,NewsTitle varchar, rowOrder VARCHAR, NewsUrl VARCHAR,NewsVideo VARCHAR)",tableName];
        
    } else if ([tableName isEqualToString:@"EventPlace"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY NOT NULL,adress VARCHAR,city VARCHAR, location VARCHAR, latitude varchar,longitude varchar, rowOrder int, zip int, typeadress VARCHAR)",tableName];
        
    } else if ([tableName isEqualToString:@"Coupons"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY NOT NULL,CouponDateStart VARCHAR,CouponDateEnd VARCHAR, CouponText VARCHAR, CouponTitle varchar,CouponPhoto VARCHAR,rowOrder int,CouponId int,Type int)",tableName];
        
    } else if ([tableName isEqualToString:@"Version"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (versionNumber double)",tableName];
        
    } else if ([tableName isEqualToString:@"PlaceApplicationList"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (PlaceAppCode VARCHAR,PlaceAppName VARCHAR,_id VARCHAR,ordre VARCHAR,rowOrder VARCHAR,article_latitude VARCHAR,article_longitude VARCHAR)",tableName];
        
    } else if ([tableName isEqualToString:@"PlaceThemeList"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (PlaceAppThemeId VARCHAR,PlaceAppThemeName VARCHAR,_id VARCHAR,ordre VARCHAR,rowOrder VARCHAR,article_latitude VARCHAR,article_longitude VARCHAR)",tableName];
        
    } else if ([tableName isEqualToString:@"PlaceThemeListApplications"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (PlaceAppCode VARCHAR,PlaceAppName VARCHAR,_id VARCHAR,ordre VARCHAR,rowOrder VARCHAR,article_latitude VARCHAR,article_longitude VARCHAR)",tableName];
        
    } else if ([tableName isEqualToString:@"Videos"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (Video_nom VARCHAR,articleid int,_id VARCHAR,rowOrder VARCHAR,videoid int,videoimage varchar,limage VARCHAR)",tableName];
        
    } else if ([tableName isEqualToString:@"Places"]) {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (article_adresse VARCHAR,article_intro VARCHAR,article_latitude VARCHAR,article_longitude VARCHAR,article_mail VARCHAR,article_tel VARCHAR,article_titre VARCHAR, articleid int, articleversion int, groupe_logo VARCHAR, groupe_nom VARCHAR, groupeid int, _id VARCHAR,limage VARCHAR, rowOrder int, ville_cp varchar,ville_nom VARCHAR,PlaceCatalogueId INTEGER)",tableName];
        
    } else {
        query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY NOT NULL, KeyName VARCHAR,keyValue VARCHAR)",tableName];
    }
    
	const char *sql=[query UTF8String];
	
	if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
	{
		if(sqlite3_prepare_v2(database, sql, -1, &createStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error ::::while creating  statement. '%s'", sqlite3_errmsg(database));
		else {
			sqlite3_exec(database, sql, NULL, NULL, NULL);
		}
		sqlite3_reset(createStmt);
		sqlite3_finalize(createStmt);
	}
	sqlite3_close(database);
}

- (void)addApplicationData:(ApplicationData *)applicationData{
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
	{
//        NSArray *keys = @[@"DeviseSigle",@"HorizontalMainPhoto",@"LangueId",@"Logo",@"MainPhoto",@"Placedelegate.CurrentCode",@"PlaceAppId",@"PlaceCouponVersion",@"PlaceEventVersion",@"PlaceGalleryVersion",@"PlaceIsShowNews",@"PlaceMainVersion",@"PlaceNewsVersion",@"PlaceStoreVersion",@"PlaceVideoVersion",@"PlacePlaceVersion",@"PlaceCouponVersion",@"PlaceType",@"PlaceIsShowCoupon",@"PlaceIsShowEvent",@"SplashScreen",@"Store",@"StoreLevel",@"VerticalMainPhoto",@"annuaire_mail",@"article_adresse",@"article_intro",@"article_latitude",@"article_longitude",@"article_tel",@"article_texte",@"article_titre",@"articleid",@"color_bg",@"color_nav",@"color_text",@"id",@"rowOrder",@"ville_cp",@"ville_nom",@"TabLogoChoose",@"TabLogoContact",@"TabLogoCoupon",@"TabLogoEvent",@"TabLogoGallery",@"TabLogoLocation",@"TabLogoNews",@"TabLogoPlace",@"TabLogoSite",@"TabLogoSite2",@"TabLogoSite3",@"TabLogoStore",@"TabLogoStore2",@"TabLogoStore3",@"TabLogoVideo",@"TabChoose",@"TabContact",@"TabCoupon",@"TabEvent",@"TabGallery",@"TabLocation",@"TabNews",@"TabPlace",@"TabSite",@"TabSite2",@"TabSite3",@"TabStore",@"TabStore2",@"TabStore3",@"TabVideo",@"VerticalMainPhoto",@"PlaceIsShowMag",@"PlaceIsShowMag2",@"PlaceIsShowMag3",@"PlaceIsMap",@"PlaceIsGallery",@"PlaceIsContact",@"PlaceIsShowPlace",@"PlaceIsShowSite",@"PlaceIsShowSite2",@"PlaceIsShowSite3",@"PlaceIsShowVideo",@"PlaceIsMother",@"color_text_home",@"color_bg_home",@"color_active",@"PlaceAppDM",@"PlaceAppFB",@"PlaceAppTW",@"PlaceAppYT",@"PlaceAppGP",@"PlaceAppLK",@"PlaceAppSite",@"PlaceAppSite2",@"PlaceAppSite3",@"PlaceIsChildMap",@"PlaceIsTitle",@"PlaceTabLogo",@"color_nav_text",@"PlaceIsLangue",@"PlaceIsAlert",@"StoreId1",@"StoreId2",@"StoreId3",@"PlaceHomeTypeId",@"StoreLevel",@"StoreLevel2",@"StoreLevel3"];
         NSArray *keys = @[@"create_account",@"select_country",@"email",@"password",@"log_in",@"alert_country",@"memorize"];
        for(int i=0;i<[keys count];i++)
        {
            const char *sql = "insert into Fun(keyName,keyValue) Values(?,?)";
            if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
                NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
            else{
                sqlite3_bind_text(addStmt, 1, [keys[i] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(addStmt, 2, [[applicationData.dataDictionary valueForKey:keys[i]] UTF8String], -1, SQLITE_TRANSIENT);
                if(SQLITE_DONE != sqlite3_step(addStmt ))
                    NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
                
            }
        }
		
		//Reset the add statement.
		sqlite3_reset(addStmt);
		sqlite3_finalize(addStmt);
	}
	sqlite3_close(database);
}


//
- (void)addToFunKey:(NSString*)Key Value:(NSString*) Value{
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
    {
        const char *sql = "insert into Fun(keyName,keyValue) Values(?,?)";
        if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
        else{
            sqlite3_bind_text(addStmt, 1, [Key UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(addStmt, 2, [Value UTF8String], -1, SQLITE_TRANSIENT);
            if(SQLITE_DONE != sqlite3_step(addStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
            
        }
        sqlite3_reset(addStmt);
        sqlite3_finalize(addStmt);
        
        
    }
    sqlite3_close(database);
}

- (NSDictionary*)readFun {
    
	sqlite3 *database;
    NSMutableDictionary *funData = [[NSMutableDictionary alloc]init];
	
    // Open the database from the users filessytem
	if(sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
		const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from Fun NOLOCK"] UTF8String];
		
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
             	NSString *key = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 1)]);
				NSString *value = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 2)]);
                funData[key] = value;
			}
		}
		sqlite3_reset(compiledStatement);

		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
    
	sqlite3_close(database);
	return funData;
}

- (NSDictionary*)readImages{
	sqlite3 *database;
    NSMutableDictionary *funDataImages = [[NSMutableDictionary alloc]init];// [[[NSMutableDictionary alloc]init] autorelease];
	// Open the database from the users file;ssytem
	if(sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
        NSString *wildcardSearch = @"%image_%";
		const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from Fun where keyName like '%@'",wildcardSearch] UTF8String];
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
             	NSString *key = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 1)]);
				NSString *value = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 2)]);
                funDataImages[key] = value;
                
			}
		}
		sqlite3_reset(compiledStatement);
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
	return funDataImages;
}


//Insert events in Events Table
- (void)addEvents:(NSString*)Key Value:(NSString*) Value{
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
    {
        const char *sql = "insert into Events(keyName,keyValue) Values(?,?)";
        if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
        else{
            sqlite3_bind_text(addStmt, 1, [Key UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(addStmt, 2, [Value UTF8String], -1, SQLITE_TRANSIENT);
            if(SQLITE_DONE != sqlite3_step(addStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
        }
        sqlite3_reset(addStmt);
        sqlite3_finalize(addStmt);
    }
    sqlite3_close(database);
}


- (NSMutableArray*) getGalleryImages {
    
    sqlite3 *database;
    
    NSMutableArray *imgArr = [[NSMutableArray alloc] init];//[[[NSMutableArray alloc] init] autorelease];
    NSData *appImageData = nil;
    
    // Open the database from the users filessytem
	if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
        NSString *wildcardSearch = @"Gallery_%";

        const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from AppImages NOLOCK where imageName like '%@'",wildcardSearch] UTF8String];
        sqlite3_stmt *compiledStatement;
		
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                
                appImageData = [[NSData alloc] initWithBytes:sqlite3_column_blob(compiledStatement, 2) length:sqlite3_column_bytes(compiledStatement, 2)];
                [imgArr addObject:appImageData];
			}
		}
        
		sqlite3_reset(compiledStatement);
		sqlite3_finalize(compiledStatement);
	}
    
	sqlite3_close(database);
	return imgArr;
}


- (UIImage*)getGalleryImageAtIndex:(NSInteger)index {
    
    sqlite3 *database;
    UIImage *image = nil;
    
    // Open the database from the users filessytem
	if(sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
        const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from AppImages NOLOCK where imageName = 'GalleryImage_%d'",index] UTF8String];
        
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                NSData *data = [[NSData alloc] initWithBytes:sqlite3_column_blob(compiledStatement, 2) length:sqlite3_column_bytes(compiledStatement, 2)];
                image = [UIImage imageWithData:data];
            }
		}
        
		sqlite3_reset(compiledStatement);
		sqlite3_finalize(compiledStatement);
	}
    
	sqlite3_close(database);
	return image;
}

- (NSMutableArray*)getIconImages {
    
    sqlite3 *database;
    
    NSMutableArray *imgArr = [[NSMutableArray alloc] init];//[[[NSMutableArray alloc] init] autorelease];
    NSData *appImageData = nil;
    
    // Open the database from the users filessytem
	if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
        
        NSString *wildcardSearch = @"MenuIcon_%";
        
        const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from IconImages NOLOCK  where imageName like '%@'",wildcardSearch] UTF8String];
        sqlite3_stmt *compiledStatement;
		
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                
                appImageData = [[NSData alloc] initWithBytes:sqlite3_column_blob(compiledStatement, 2) length:sqlite3_column_bytes(compiledStatement, 2)];
                [imgArr addObject:appImageData];
			}
		}
        
		sqlite3_reset(compiledStatement);
		sqlite3_finalize(compiledStatement);
	}
    
	sqlite3_close(database);
	return imgArr;
}

- (NSData*)getIconImage:(NSString *)imgName{
    //NSLog(@"imgName = %@",imgName);
    sqlite3 *database;
    // NSMutableArray *imgArr = [[NSMutableArray alloc] init];//[[[NSMutableArray alloc] init] autorelease];
    NSData *appImageData = nil;
    // Open the database from the users filessytem
	if(sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
        // NSString *wildcardSearch = @"MenuIcon_%";
        const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from IconImages NOLOCK  where imageName = '%@'",imgName] UTF8String];
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                // NSString *imageName = [NSString stringWithUTF8String:[self checkNull:(char *)sqlite3_column_text(compiledStatement, 1)];
                appImageData = [[NSData alloc] initWithBytes:sqlite3_column_blob(compiledStatement, 2) length:sqlite3_column_bytes(compiledStatement, 2)];
                //[imgArr addObject:appImageData];
                // [appImageData release];
			}
		}
		sqlite3_reset(compiledStatement);
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
	return appImageData;
    
}




-(NSInteger)funSpotTableCount{
    int tblcount=0;
    // Open the database from the users filessytem
	if(sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
		const char *sqlStatement = [[NSString stringWithFormat:@"SELECT count(*) from Fun "] UTF8String];
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            tblcount++;
            
			//}
		}
        sqlite3_reset(compiledStatement);
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
	return tblcount;
}

//Insert updates in Events Table
- (void)addUpdates:(NSString*)Key Value:(NSString*)Value status:(bool)Status {
    
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
        
        const char *sql;

        if (Status) {
            sql = "insert into Updates(keyName, keyValue) Values(?, ?)";
        } else {
            sql = "update Updates set keyValue = ? where keyName = ?";
        }
        
        if (Status) {
            if (sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
                
            } else {
                sqlite3_bind_text(addStmt, 1, [Key UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(addStmt, 2, [Value UTF8String], -1, SQLITE_TRANSIENT);

                if(SQLITE_DONE != sqlite3_step(addStmt))
                    NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
            }
            
            sqlite3_reset(addStmt);
            sqlite3_finalize(addStmt);
            
        } else {
            
            if (sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
                
            } else {
                sqlite3_bind_text(updateStmt, 1,  [Value UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(updateStmt, 2,  [Key UTF8String], -1, SQLITE_TRANSIENT);
                
                if (SQLITE_DONE != sqlite3_step(updateStmt))
                    NSAssert1(0, @"Error while updating data. '%s'", sqlite3_errmsg(database));
            }
            
            sqlite3_reset(updateStmt);
            sqlite3_finalize(updateStmt);
        }
    }

    sqlite3_close(database);
}

- (NSDictionary *)readTimeofLastUpdate:(NSString*)Key {
    
    sqlite3 *database;
    NSMutableDictionary *updatesDict = [[NSMutableDictionary alloc]init];
	
    // Open the database from the users file;ssytem
	if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
        
		const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from Updates NOLOCK where keyName = '%@'", Key] UTF8String];
		sqlite3_stmt *compiledStatement;
		
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                
				// Read the data from the result row
             	NSString *key = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 1)]);
				NSString *value = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 2)]);
                updatesDict[key] = value;
			}
		}
        
		sqlite3_reset(compiledStatement);
		sqlite3_finalize(compiledStatement);
	}
    
	sqlite3_close(database);
	return updatesDict;
}

- (NSData*)image:(NSString *)imageName {
    
    NSLog(@"image %@",imageName);
    
    sqlite3 *database;
    NSData *appImageData = nil;
    
    // Open the database from the users filessytem
	if(sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
        const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from AppImages NOLOCK where imageName='%@'",imageName] UTF8String];
		sqlite3_stmt *compiledStatement;
		
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                // NSString *imageName = [NSString stringWithUTF8String:[self checkNull:(char *)sqlite3_column_text(compiledStatement, 1)];
                appImageData = [[NSData alloc] initWithBytes:sqlite3_column_blob(compiledStatement, 2) length:sqlite3_column_bytes(compiledStatement, 2)];
			}
		}
		
        sqlite3_reset(compiledStatement);
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}

	sqlite3_close(database);
	return appImageData;
}


-(void)clearPlacesContent{
    // NSLog(@"PATH FOR DB = %@",[Common getFilePath:DATABASE]);
    
    [self dropTable:@"Places"];
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
	{
		NSString *query=@"DELETE from Videos";
        if(![self recordExists:query]){
            //do nothing
            NSLog(@"do nothing");
        }else{
            
            //#ifdef DEBUG
            NSLog( @"query = %@",query);
            //#endif
            const char *sql = [query UTF8String];
            if(sqlite3_prepare_v2(database, sql, -1, &deleteStmt, NULL) != SQLITE_OK)
                NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
            else {
                sqlite3_exec(database, sql, NULL, NULL, NULL);
            }
            sqlite3_reset(deleteStmt);
            sqlite3_finalize(deleteStmt);
        }
    }
	sqlite3_close(database);
}
//Image Save
- (void)saveImage:(NSString *)imageName Image:(UIImage *)image
{
    NSString *query = [NSString stringWithFormat:@"SELECT 1 FROM AppImages NOLOCK WHERE imageName='%@'", imageName];
    
    if ([self recordExists:query])
    {
        @synchronized(self)
        {
            [self updateImage:imageName Image:image];
        }
    }
    else
    {
        if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
        {
            const char *sql = [[NSString stringWithFormat:@"INSERT INTO AppImages (imageName,image) values(?,?)"] UTF8String];
            
            NSLog(@"SQLite saveImage==%@",imageName);
            if (sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
                NSLog(@"SQLite saveImage ERROR");
            } else {
                
                
                
                sqlite3_bind_text(addStmt, 1, [imageName UTF8String], -1, SQLITE_TRANSIENT);
                NSData *imgData = UIImagePNGRepresentation(image);
                //NSData *imgData = UIImageJPEGRepresentation(image,1.0);
                sqlite3_bind_blob(addStmt, 2, [imgData bytes], [imgData length], NULL);
                if(SQLITE_DONE != sqlite3_step(addStmt))
                    NSAssert1(0, @"Error while inserting data. Image '%s'", sqlite3_errmsg(database));
            }
            
            sqlite3_reset(addStmt);
            sqlite3_finalize(addStmt);
            sqlite3_close(database);
            
        }
        else
        {
            NSLog(@"not open database . Plz check method SaveImage");
        }
    }
}
- (void)updateImage:(NSString *)imageName Image:(UIImage *)image {
    
	if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
		const char *sql = "UPDATE AppImages SET image = ? Where imageName = ?";
        
		if (sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
        } else {
            
            // NSData *imgData = [NSData dataWithData:UIImagePNGRepresentation(image)];
            
            sqlite3_bind_text(updateStmt, 2, [imageName UTF8String], -1, SQLITE_TRANSIENT);
            NSData *imgData = UIImagePNGRepresentation(image);
            sqlite3_bind_blob(updateStmt, 1, [imgData bytes], [imgData length], NULL);
            
			if(SQLITE_DONE != sqlite3_step(updateStmt))
			{
				NSAssert1(0, @"Error while updating data. '%s'", sqlite3_errmsg(database));
			}
		}
		
		//Reset the add statement.
		sqlite3_reset(updateStmt);
		sqlite3_finalize(updateStmt);
	}
    
	sqlite3_close(database);
}

//============================== TRAVEL BUDDY =================================

// =========== TABLE USERS ===========
// add User
- (void)saveUser:(User*)dictUser{
        if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
        {
            const char *sql = "insert into Users (user_id, trip_id, name, avatarurl) Values(?,?,?,?)";
            if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
                NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
            else{
                sqlite3_bind_int(addStmt, 1, dictUser.userInTripId);
                sqlite3_bind_int(addStmt, 2, dictUser.tripId);
                sqlite3_bind_text(addStmt, 3, [dictUser.name UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(addStmt, 4, [dictUser.avatarUrl UTF8String], -1, SQLITE_TRANSIENT);
                if(SQLITE_DONE != sqlite3_step(addStmt ))
                    NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));

            }
            sqlite3_reset(addStmt);
            sqlite3_finalize(addStmt);
            
        }
        sqlite3_close(database);
}
// save User
- (void)updateUserInfor:(User *)dictUser
{
	if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
	{
        const char *sql = "UPDATE Users SET user_id = ?,trip_id = ?,name = ?,avatarurl = ? where id = ?";
		if(sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
		else {
            sqlite3_bind_int(updateStmt, 1, dictUser.userInTripId);
            sqlite3_bind_int(updateStmt, 2, dictUser.tripId);
            sqlite3_bind_text(updateStmt, 3, [dictUser.name UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(updateStmt, 4, [dictUser.avatarUrl UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(updateStmt, 5, dictUser.userId);
            if(SQLITE_DONE != sqlite3_step(updateStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
		}
		
		//Reset the add statement.
		sqlite3_reset(updateStmt);
		sqlite3_finalize(updateStmt);
	}
	sqlite3_close(database);
}

//get list User in trip
- (NSMutableArray*)getUserInfor:(int)tripId{
	sqlite3 *database;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    int userID = [[userDefault objectForKey:@"userId"] intValue];
    NSMutableArray *userArr = [[NSMutableArray alloc] init];
	if(sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
       
        const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from Users NOLOCK where trip_id = %d ",tripId] UTF8String];
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                // Read the data from the result row
                
                /////
                NSInteger userId = sqlite3_column_int(compiledStatement, 0);
                NSInteger userInTripId = sqlite3_column_int(compiledStatement, 1);
                NSInteger tripId = sqlite3_column_int(compiledStatement, 2);
                NSString *name = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 3)]);
                NSString *avatarUrl = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 4)]);
                
                User *userObj = [[User alloc] init];
                userObj.userId = userId;
                userObj.userInTripId = userInTripId;
                userObj.tripId = tripId;
                userObj.name = name;
                userObj.avatarUrl = avatarUrl;
                if (userID != userInTripId) {
                    [userArr addObject:userObj];
                }
                
			}
		}
      	sqlite3_reset(compiledStatement);
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
	return userArr;
}

//get all User
- (NSMutableArray*)getAllUserInfor:(int)tripId{
    sqlite3 *database;
    NSMutableArray *userArr = [[NSMutableArray alloc] init];
    if(sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
        
        const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from Users NOLOCK where trip_id = %d ",tripId] UTF8String];
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                // Read the data from the result row
                
                /////
                NSInteger userId = sqlite3_column_int(compiledStatement, 0);
                NSInteger userInTripId = sqlite3_column_int(compiledStatement, 1);
                NSInteger tripId = sqlite3_column_int(compiledStatement, 2);
                NSString *name = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 3)]);
                NSString *avatarUrl = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 4)]);
                
                User *userObj = [[User alloc] init];
                userObj.userId = userId;
                userObj.userInTripId = userInTripId;
                userObj.tripId = tripId;
                userObj.name = name;
                userObj.avatarUrl = avatarUrl;
                [userArr addObject:userObj];
            }
        }
        sqlite3_reset(compiledStatement);
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    return userArr;
}

//delete user
- (void)deleteUser:(int)userId {
    
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
        //        NSString *query_ = @"SELECT 1 from AppImages where id like '%GalleryImage_%'";
        //
        //        if ([self recordExists:query_]) {
        NSString *query = [NSString stringWithFormat:@"DELETE from Users where user_id = %d",userId];
        
        const char *sql = [query UTF8String];
        if (sqlite3_prepare_v2(database, sql, -1, &deleteStmt, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
        } else {
            sqlite3_exec(database, sql, NULL, NULL, NULL);
        }
        
        sqlite3_reset(deleteStmt);
        sqlite3_finalize(deleteStmt);
        //        }
    }
    
    sqlite3_close(database);
}


// =========== TABLE TRIPS ===========
// add trip
- (void)addTripInfor:(TripObj*)dictTrip{
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
    {
        const char *sql = "insert into Trips (triplocation, startdate, finishdate,budget,owner_user_id,trip_id) Values(?,?,?,?,?,?)";
        if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
        else{
            sqlite3_bind_text(addStmt, 1, [dictTrip.tripLocation UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(addStmt, 2, [dictTrip.startDate UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(addStmt, 3, [dictTrip.finishDate UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(addStmt, 4, [dictTrip.budget UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(addStmt, 5, dictTrip.ownerUserId);
            sqlite3_bind_int(addStmt, 6, dictTrip.tripId);
            
            if(SQLITE_DONE != sqlite3_step(addStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
            
        }
        sqlite3_reset(addStmt);
        sqlite3_finalize(addStmt);
        
    }
    sqlite3_close(database);
}
// update trip
- (void)updateTripInfor:(TripObj*)dictTrip
{
	if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
	{
        const char *sql = "UPDATE Trips SET triplocation = ?,startdate = ?,finishdate = ?,budget = ?,owner_user_id = ? where id = ?";
		if(sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
		else {
            
            sqlite3_bind_text(updateStmt, 1, [dictTrip.tripLocation UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(updateStmt, 2, [dictTrip.startDate UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(updateStmt, 3, [dictTrip.finishDate UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(updateStmt, 4, [dictTrip.budget UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(updateStmt, 5, dictTrip.ownerUserId);
            sqlite3_bind_int(updateStmt, 6, dictTrip.tripId);
            
            if(SQLITE_DONE != sqlite3_step(updateStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
		}
		
		//Reset the add statement.
		sqlite3_reset(updateStmt);
		sqlite3_finalize(updateStmt);
	}
	sqlite3_close(database);
}
//query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY NOT NULL, triplocation VARCHAR,startdate VARCHAR , finishdate VARCHAR,budget VARCHAR, owner_user_id INTEGER)",tableName];

- (void)updateNameTrip:(NSInteger )tripID name:(NSString *)newName  owner:(NSInteger) userId_owner_current
{
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
	{
        const char *sql = "UPDATE Trips SET triplocation = ? where id = ? AND owner_user_id = ?";
		if(sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
		else {
            
            sqlite3_bind_text(updateStmt, 1, [newName UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(updateStmt, 2, tripID);
            sqlite3_bind_int(updateStmt, 3, userId_owner_current);
            
            if(SQLITE_DONE != sqlite3_step(updateStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
		}
		
		//Reset the add statement.
		sqlite3_reset(updateStmt);
		sqlite3_finalize(updateStmt);
	}
	sqlite3_close(database);

}
- (void)updateTripBudget:(NSString*)budget tripId:(NSInteger)tripID
{
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
    {
        const char *sql = "UPDATE Trips SET budget = ? where trip_id = ?";
        if(sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
        else {
            sqlite3_bind_text(updateStmt, 1, [budget UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(updateStmt, 2, tripID);
            
            if(SQLITE_DONE != sqlite3_step(updateStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
        }
        
        //Reset the add statement.
        sqlite3_reset(updateStmt);
        sqlite3_finalize(updateStmt);
    }
    sqlite3_close(database);
    
}
// get trip
- (NSMutableArray*)getTripInfor:(int)userId{
	sqlite3 *database;
    NSMutableArray *placeArr = [[NSMutableArray alloc] init];
	if(sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
        //triplocation VARCHAR,startdate VARCHAR , finishdate VARCHAR,budget VARCHAR, owner_user_id
        const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from Trips NOLOCK where trip_id = %d ",userId] UTF8String];
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                // Read the data from the result row
                
                /////
                NSString *triplocation = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 1)]);
                NSString *startdate = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 2)]);
                NSString *finishdate = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 3)]);
                NSString *budget = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 4)]);
                NSInteger owner_user_id = sqlite3_column_int(compiledStatement, 5);
                
                TripObj *tripItem = [[TripObj alloc] init];
                tripItem.tripLocation = triplocation;
                tripItem.startDate = startdate;
                tripItem.finishDate = finishdate;
                tripItem.budget = budget;
                tripItem.ownerUserId = owner_user_id;
                [placeArr addObject:tripItem];
			}
		}
      	sqlite3_reset(compiledStatement);
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
	return placeArr;
}

// =========== TABLE NOTES ===========

// add Note
- (void)addNoteInfor:(NoteObj*)dictNote{
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
    {
        const char *sql = "insert into Notes (title, dateTime, content,owner_user_id,trip_id,server_id,flag) Values(?,?,?,?,?,?,?)";
        if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
        else{
            sqlite3_bind_text(addStmt, 1, [dictNote.title UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(addStmt, 2, [dictNote.dateTime UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(addStmt, 3, [dictNote.content UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(addStmt, 4, dictNote.ownerUserId);
            sqlite3_bind_int(addStmt, 5, dictNote.tripId);
            sqlite3_bind_int(addStmt, 6, dictNote.serverId);
            sqlite3_bind_int(addStmt, 7, dictNote.flag);
            
            if(SQLITE_DONE != sqlite3_step(addStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
            
        }
        sqlite3_reset(addStmt);
        sqlite3_finalize(addStmt);
        
    }
    sqlite3_close(database);
}

//add note
- (NSMutableArray*)getNotes{ 
	sqlite3 *database;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    int userId = [[userDefault objectForKey:@"userId"] intValue];
    int tripId = [[userDefault objectForKey:@"userTripId"] intValue];
    NSMutableArray *noteArr = [[NSMutableArray alloc] init];
	if(sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
		//const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from Events where keyName = %@",rowID] UTF8String];
        const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from Notes NOLOCK where trip_id = %d",tripId] UTF8String];
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                NSInteger noteId      = sqlite3_column_int(compiledStatement, 0);
				NSString *title       = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 1)]);
                NSString *dateTime    = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 2)]);
				NSString *content     = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 3)]);
                NSInteger ownerUserId = sqlite3_column_int(compiledStatement, 4);
				NSInteger tripId      = sqlite3_column_int(compiledStatement, 5);
                NSInteger serverId     = sqlite3_column_int(compiledStatement,6);
				NSInteger flag        = sqlite3_column_int(compiledStatement, 7);
                
                NoteObj *objNote = [[NoteObj alloc] init];
                objNote.noteId = noteId;
                objNote.title = title;
                objNote.dateTime = dateTime;
                objNote.content =  content;
                objNote.ownerUserId = ownerUserId;
                objNote.tripId  = tripId;
                objNote.serverId = serverId;
                objNote.flag = flag;
                
                [noteArr addObject:objNote];
			}
		}
      	sqlite3_reset(compiledStatement);
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
	return noteArr;
}

// update Note
- (void)updateNote:(NoteObj*)dictNote
{
	if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
	{
        //title, dateTime, content,owner_user_id,trip_id,server_id,flag
        const char *sql = "UPDATE Notes SET title = ?,dateTime = ?,content = ?,owner_user_id = ?,trip_id = ?,server_id = ?,flag = ? where id = ?";
		if(sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
		else {
            sqlite3_bind_text(updateStmt, 1, [dictNote.title UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(updateStmt, 2, [dictNote.dateTime UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(updateStmt, 3, [dictNote.content UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(updateStmt, 4, dictNote.ownerUserId);
            sqlite3_bind_int(updateStmt, 5, dictNote.tripId);
            sqlite3_bind_int(updateStmt, 6, dictNote.serverId);
            sqlite3_bind_int(updateStmt, 7, dictNote.flag);
            sqlite3_bind_int(updateStmt, 8, dictNote.noteId);
            
            if(SQLITE_DONE != sqlite3_step(updateStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
		}
		
		//Reset the add statement.
		sqlite3_reset(updateStmt);
		sqlite3_finalize(updateStmt);
	}
	sqlite3_close(database);
}

// update Note from Server
- (void)updateNoteFromServer:(int)clientId withServerId:(int)serverId
{
	if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
	{
        //title, dateTime, content,owner_user_id,trip_id,server_id,flag
        const char *sql = "UPDATE Notes SET server_id = ?,flag = ? where id = ?";
		if(sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
		else {
            
            sqlite3_bind_int(updateStmt, 1, serverId);
            sqlite3_bind_int(updateStmt, 2, 0);
            sqlite3_bind_int(updateStmt, 3, clientId);
            
            if(SQLITE_DONE != sqlite3_step(updateStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
		}
		
		//Reset the add statement.
		sqlite3_reset(updateStmt);
		sqlite3_finalize(updateStmt);
	}
	sqlite3_close(database);
}
//delete Note
- (void)deleteNote:(int)noteId {
    
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
//        NSString *query_ = @"SELECT 1 from AppImages where id like '%GalleryImage_%'";
//        
//        if ([self recordExists:query_]) {
            NSString *query = [NSString stringWithFormat:@"DELETE from Notes where id = %d",noteId];
            
            const char *sql = [query UTF8String];
            if (sqlite3_prepare_v2(database, sql, -1, &deleteStmt, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
            } else {
                sqlite3_exec(database, sql, NULL, NULL, NULL);
            }
            
            sqlite3_reset(deleteStmt);
            sqlite3_finalize(deleteStmt);
//        }
	}
    
	sqlite3_close(database);
}


// =========== TABLE VERSION ===========

// add version
- (void)addVersionInfor:(VersionObj*)dictVersion{
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
    {
        const char *sql = "insert into Versions (noteversion, categoryversion, expenseversion,groupversion,photoversion,packingtitleversion,packingitemversion,premadelistversion,premadeitemversion,userversion,user_id) Values(?,?,?,?,?,?,?,?,?,?,?)";
        if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
        else{
            sqlite3_bind_int(addStmt, 1, dictVersion.noteVersion);
            sqlite3_bind_int(addStmt, 2, dictVersion.categoryVersion);
            sqlite3_bind_int(addStmt, 3, dictVersion.expenseVersion);
            sqlite3_bind_int(addStmt, 4, dictVersion.groupVersion);
            sqlite3_bind_int(addStmt, 5, dictVersion.photoVersion);
            sqlite3_bind_int(addStmt, 6, dictVersion.packingTitleVersion);
            sqlite3_bind_int(addStmt, 7, dictVersion.packingItemVersion);
            sqlite3_bind_int(addStmt, 8, dictVersion.premadeListVersion);
            sqlite3_bind_int(addStmt, 9, dictVersion.premadeItemVersion);
            sqlite3_bind_int(addStmt, 10, dictVersion.userVersion);
            sqlite3_bind_int(addStmt, 11, dictVersion.userId);
            
            if(SQLITE_DONE != sqlite3_step(addStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
            
        }
        sqlite3_reset(addStmt);
        sqlite3_finalize(addStmt);
        
    }
    sqlite3_close(database);
}

// update Version
- (void)updateVersion:(VersionObj*)dictVersion
{
	if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
	{
        const char *sql = "UPDATE Versions SET noteversion = ?,categoryversion = ?,expenseversion = ?,groupversion = ?,photoversion = ?,packingtitleversion = ?,packingitemversion = ?,premadelistversion = ?,premadeitemversion = ?, userversion = ?  where user_id = ?";
		if(sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
		else {
            sqlite3_bind_int(updateStmt, 1, dictVersion.noteVersion);
            sqlite3_bind_int(updateStmt, 2, dictVersion.categoryVersion);
            sqlite3_bind_int(updateStmt, 3, dictVersion.expenseVersion);
            sqlite3_bind_int(updateStmt, 4, dictVersion.groupVersion);
            sqlite3_bind_int(updateStmt, 5, dictVersion.photoVersion);
            sqlite3_bind_int(updateStmt, 6, dictVersion.packingTitleVersion);
            sqlite3_bind_int(updateStmt, 7, dictVersion.packingItemVersion);
            sqlite3_bind_int(updateStmt, 8, dictVersion.premadeListVersion);
            sqlite3_bind_int(updateStmt, 9, dictVersion.premadeItemVersion);
            sqlite3_bind_int(updateStmt, 10, dictVersion.userVersion);
            sqlite3_bind_int(updateStmt, 11, dictVersion.userId);
            
            if(SQLITE_DONE != sqlite3_step(updateStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
		}
		
		//Reset the add statement.
		sqlite3_reset(updateStmt);
		sqlite3_finalize(updateStmt);
	}
	sqlite3_close(database);
}

// update Version from Server
- (void)updateVersionFromServer:(NSString*)versionName withVersion:(int)newVersion andUserId:(int)userId
{
	if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
	{
        const char *sql = "UPDATE Versions SET ? = ?  where user_id = ?";
		if(sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
		else {
            sqlite3_bind_text(updateStmt, 1, [versionName UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(updateStmt, 2, newVersion);
            sqlite3_bind_int(updateStmt, 3, userId);
            
            if(SQLITE_DONE != sqlite3_step(updateStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
		}
		
		//Reset the add statement.
		sqlite3_reset(updateStmt);
		sqlite3_finalize(updateStmt);
	}
	sqlite3_close(database);
}


//get version of trip
- (NSMutableArray*)getVersion{
	sqlite3 *database;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    int userId = [[userDefault objectForKey:@"userId"] intValue];
    NSMutableArray *versionArr = [[NSMutableArray alloc] init];
	if(sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
		//const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from Events where keyName = %@",rowID] UTF8String];
        const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from Versions NOLOCK where user_id =%d",userId] UTF8String];
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                NSInteger versionId = sqlite3_column_int(compiledStatement, 0);
                NSInteger noteVersion = sqlite3_column_int(compiledStatement, 1);
                NSInteger categoryVersion = sqlite3_column_int(compiledStatement, 2);
                NSInteger expenseVersion = sqlite3_column_int(compiledStatement, 3);
                NSInteger groupVersion = sqlite3_column_int(compiledStatement, 4);
                NSInteger photoVersion = sqlite3_column_int(compiledStatement, 5);
                NSInteger packingTitleVersion = sqlite3_column_int(compiledStatement, 6);
                NSInteger packingItemVersion = sqlite3_column_int(compiledStatement, 7);
                NSInteger premadeListVersion = sqlite3_column_int(compiledStatement, 8);
                NSInteger premadeItemVersion = sqlite3_column_int(compiledStatement, 9);
                NSInteger userVersion = sqlite3_column_int(compiledStatement, 10);
                NSInteger userid = sqlite3_column_int(compiledStatement, 11);
                
                VersionObj *versionObj = [[VersionObj alloc] init];
                versionObj.versionId = versionId;
                versionObj.noteVersion = noteVersion;
                versionObj.categoryVersion = categoryVersion;
                versionObj.expenseVersion = expenseVersion;
                versionObj.groupVersion =  groupVersion;
                versionObj.photoVersion = photoVersion;
                versionObj.packingItemVersion  = packingItemVersion;
                versionObj.packingTitleVersion = packingTitleVersion;
                versionObj.premadeItemVersion = premadeItemVersion;
                versionObj.premadeListVersion = premadeListVersion;
                versionObj.userVersion = userVersion;
                versionObj.userId = userid;
                
                [versionArr addObject:versionObj];
			}
		}
      	sqlite3_reset(compiledStatement);
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
	return versionArr;
}


// =========== TABLE EXPENSES ===========

// add EXPENSES
- (void)addExpenseInfor:(ExpenseObj*)dictExp{
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
    {
        const char *sql = "insert into Expenses (cateId, dateTime, money, item, trip_id, owner_user_id, server_id, flag) Values(?,?,?,?,?,?,?,?)";
        if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
        else{
            sqlite3_bind_int(addStmt, 1, dictExp.cateId);
            sqlite3_bind_text(addStmt, 2, [dictExp.dateTime UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(addStmt, 3, [dictExp.money UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(addStmt, 4, [dictExp.item UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(addStmt, 5, dictExp.tripId);
            sqlite3_bind_int(addStmt, 6, dictExp.ownerUserId);
            sqlite3_bind_int(addStmt, 7, dictExp.serverId);
            sqlite3_bind_int(addStmt, 8, dictExp.flag);
            
            if(SQLITE_DONE != sqlite3_step(addStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
            
        }
        sqlite3_reset(addStmt);
        sqlite3_finalize(addStmt);
        
    }
    sqlite3_close(database);
}

//GET EXPENSES
- (NSMutableArray*)getExpenses:(int)categoryId{
	sqlite3 *database;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    int userId = [[userDefault objectForKey:@"userId"] intValue];
    int tripId = [[userDefault objectForKey:@"userTripId"] intValue];
    NSMutableArray *ExpArr = [[NSMutableArray alloc] init];
	if(sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
		//const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from Events where keyName = %@",rowID] UTF8String];
        NSString *strStatement = [NSString stringWithFormat:@"SELECT * from Expenses NOLOCK where trip_id = %d",tripId];
        if (categoryId != 0) {
            strStatement = [NSString stringWithFormat:@"SELECT * from Expenses NOLOCK where trip_id = %d and cateId = %d",tripId,categoryId];
        }
        
        const char *sqlStatement = [strStatement UTF8String];
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                NSInteger expenseId   = sqlite3_column_int(compiledStatement, 0);
                NSInteger cateId      = sqlite3_column_int(compiledStatement, 1);
                NSString *dateTime    = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 2)]);
                NSString *money       = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 3)]);
				NSString *item        = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 4)]);
                NSInteger tripId      = sqlite3_column_int(compiledStatement, 5);
                NSInteger ownerUserId = sqlite3_column_int(compiledStatement, 6);
                NSInteger serverId    = sqlite3_column_int(compiledStatement, 7);
				NSInteger flag        = sqlite3_column_int(compiledStatement, 8);
                
                ExpenseObj *objExp = [[ExpenseObj alloc] init];
                objExp.expenseId = expenseId;
                objExp.cateId = cateId;
                objExp.dateTime = dateTime;
                objExp.money = money;
                objExp.item =  item;
                objExp.ownerUserId = ownerUserId;
                objExp.tripId  = tripId;
                objExp.serverId = serverId;
                objExp.flag = flag;
                if (flag < 3) {
                    [ExpArr addObject:objExp];
                }
			}
		}
      	sqlite3_reset(compiledStatement);
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
	return ExpArr;
}

//GET EXPENSES
- (NSMutableArray*)getAllExpenses{
    sqlite3 *database;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    //    int userId = [[userDefault objectForKey:@"userId"] intValue];
    int tripId = [[userDefault objectForKey:@"userTripId"] intValue];
    NSMutableArray *ExpArr = [[NSMutableArray alloc] init];
    if(sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
        //const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from Events where keyName = %@",rowID] UTF8String];
        NSString *strStatement = [NSString stringWithFormat:@"SELECT * from Expenses NOLOCK where trip_id = %d",tripId];
        
        const char *sqlStatement = [strStatement UTF8String];
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                // Read the data from the result row
                NSInteger expenseId   = sqlite3_column_int(compiledStatement, 0);
                NSInteger cateId      = sqlite3_column_int(compiledStatement, 1);
                NSString *dateTime    = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 2)]);
                NSString *money       = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 3)]);
                NSString *item        = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 4)]);
                NSInteger tripId      = sqlite3_column_int(compiledStatement, 5);
                NSInteger ownerUserId = sqlite3_column_int(compiledStatement, 6);
                NSInteger serverId    = sqlite3_column_int(compiledStatement, 7);
                NSInteger flag        = sqlite3_column_int(compiledStatement, 8);
                
                ExpenseObj *objExp = [[ExpenseObj alloc] init];
                objExp.expenseId = expenseId;
                objExp.cateId = cateId;
                objExp.dateTime = dateTime;
                objExp.money = money;
                objExp.item =  item;
                objExp.ownerUserId = ownerUserId;
                objExp.tripId  = tripId;
                objExp.serverId = serverId;
                objExp.flag = flag;
                
                [ExpArr addObject:objExp];
            }
        }
        sqlite3_reset(compiledStatement);
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    return ExpArr;
}

// update EXPENSES
- (void)updateExpense:(ExpenseObj*)dictExp
{
	if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
	{
        //title, dateTime, content,owner_user_id,trip_id,server_id,flag
        const char *sql = "UPDATE Expenses SET cateId = ?,dateTime = ?,money = ?,item = ?,trip_id = ?,owner_user_id = ?,server_id = ?,flag = ? where id = ?";
		if(sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
		else {
            sqlite3_bind_int(updateStmt, 1, dictExp.cateId);
            sqlite3_bind_text(updateStmt, 2, [dictExp.dateTime UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(updateStmt, 3, [dictExp.money UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(updateStmt, 4, [dictExp.item UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(updateStmt, 5, dictExp.tripId);
            sqlite3_bind_int(updateStmt, 6, dictExp.ownerUserId);
            sqlite3_bind_int(updateStmt, 7, dictExp.serverId);
            sqlite3_bind_int(updateStmt, 8, dictExp.flag);
            sqlite3_bind_int(updateStmt, 9, dictExp.expenseId);
            
            if(SQLITE_DONE != sqlite3_step(updateStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
		}
		
		//Reset the add statement.
		sqlite3_reset(updateStmt);
		sqlite3_finalize(updateStmt);
	}
	sqlite3_close(database);
}

// update EXPENSES from Server
- (void)updateExpenseFromServer:(int)clientId withServerId:(int)serverId
{
	if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
	{
        //title, dateTime, content,owner_user_id,trip_id,server_id,flag
        const char *sql = "UPDATE Expenses SET server_id = ?,flag = ? where id = ?";
		if(sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
		else {
            
            sqlite3_bind_int(updateStmt, 1, serverId);
            sqlite3_bind_int(updateStmt, 2, 0);
            sqlite3_bind_int(updateStmt, 3, clientId);
            
            if(SQLITE_DONE != sqlite3_step(updateStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
		}
		
		//Reset the add statement.
		sqlite3_reset(updateStmt);
		sqlite3_finalize(updateStmt);
	}
	sqlite3_close(database);
}
//delete Expense
- (void)deleteExpense:(int)expenseId {
    
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
        //        NSString *query_ = @"SELECT 1 from AppImages where id like '%GalleryImage_%'";
        //
        //        if ([self recordExists:query_]) {
        NSString *query = [NSString stringWithFormat:@"DELETE from Expenses where id = %d",expenseId];
        
        const char *sql = [query UTF8String];
        if (sqlite3_prepare_v2(database, sql, -1, &deleteStmt, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
        } else {
            sqlite3_exec(database, sql, NULL, NULL, NULL);
        }
        
        sqlite3_reset(deleteStmt);
        sqlite3_finalize(deleteStmt);
        //        }
	}
    
	sqlite3_close(database);
}

//delete Expense
- (void)deleteExpenseCategory:(int)cateId {
    
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
        //        NSString *query_ = @"SELECT 1 from AppImages where id like '%GalleryImage_%'";
        //
        //        if ([self recordExists:query_]) {
        NSString *query = [NSString stringWithFormat:@"DELETE from Expenses where cateId = %d",cateId];
        
        const char *sql = [query UTF8String];
        if (sqlite3_prepare_v2(database, sql, -1, &deleteStmt, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
        } else {
            sqlite3_exec(database, sql, NULL, NULL, NULL);
        }
        
        sqlite3_reset(deleteStmt);
        sqlite3_finalize(deleteStmt);
        //        }
    }
    
    sqlite3_close(database);
}


// =========== TABLE PACKING TITLE ===========

// add PACKING TITLE
- (int)addPackingTitleInfor:(PackingTitleObj*)dictPackingTitle{
    int rowId;
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
    {
        const char *sql = "insert into PackingTitles (title, owner_user_id, server_id, flag) Values(?,?,?,?)";
        if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
        else{
            sqlite3_bind_text(addStmt, 1, [dictPackingTitle.title UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(addStmt, 2, dictPackingTitle.ownerUserId);
            sqlite3_bind_int(addStmt, 3, dictPackingTitle.serverId);
            sqlite3_bind_int(addStmt, 4, dictPackingTitle.flag);
            
            if(SQLITE_DONE != sqlite3_step(addStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
        }
        sqlite3_reset(addStmt);
        sqlite3_finalize(addStmt);
        
    }
    rowId = [[[NSNumber alloc] initWithLongLong:sqlite3_last_insert_rowid(database)] intValue];
    sqlite3_close(database);
    return rowId;
}
//GET PACKING TITLE
- (NSMutableArray*)getPackingTitle{
	sqlite3 *database;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    int userId = [[userDefault objectForKey:@"userId"] intValue];
    NSMutableArray *packingTitleArr = [[NSMutableArray alloc] init];
	if(sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
		//const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from Events where keyName = %@",rowID] UTF8String];
        const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from PackingTitles NOLOCK where owner_user_id = %d",userId] UTF8String];
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                NSInteger packingId   = sqlite3_column_int(compiledStatement, 0);
                NSString *title       = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 1)]);
                NSInteger ownerUserId = sqlite3_column_int(compiledStatement, 2);
                NSInteger serverId    = sqlite3_column_int(compiledStatement, 3);
				NSInteger flag        = sqlite3_column_int(compiledStatement, 4);
                
                PackingTitleObj *objPackTitle = [[PackingTitleObj alloc] init];
                objPackTitle.packingId = packingId;
                objPackTitle.title = title;
                objPackTitle.ownerUserId = ownerUserId;
                objPackTitle.serverId = serverId;
                objPackTitle.flag = flag;
                
                [packingTitleArr addObject:objPackTitle];
			}
		}
      	sqlite3_reset(compiledStatement);
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
	return packingTitleArr;
}
// update PACKING TITLE
- (void)updatePackingTitle:(PackingTitleObj*)dictPackingTitle
{
	if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
	{
        //title, dateTime, content,owner_user_id,trip_id,server_id,flag
        const char *sql = "UPDATE PackingTitles SET title = ?,server_id = ?, owner_user_id = ?, flag = ? where id = ?";
		if(sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
		else {
            sqlite3_bind_text(updateStmt, 1, [dictPackingTitle.title UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(updateStmt, 2, dictPackingTitle.serverId);
            sqlite3_bind_int(updateStmt, 3, dictPackingTitle.ownerUserId);
            sqlite3_bind_int(updateStmt, 4, dictPackingTitle.flag);
            sqlite3_bind_int(updateStmt, 5, dictPackingTitle.packingId);
            
            //itemname, ischeck, packing_id, server_id, flag
            if(SQLITE_DONE != sqlite3_step(updateStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
		}
		
		//Reset the add statement.
		sqlite3_reset(updateStmt);
		sqlite3_finalize(updateStmt);
	}
	sqlite3_close(database);
}
// update Packing Title from Server
- (void)updatePackingTitleFromServer:(int)clientId withServerId:(int)serverId
{
	if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
	{
        //title, dateTime, content,owner_user_id,trip_id,server_id,flag
        const char *sql = "UPDATE PackingTitles SET server_id = ?,flag = ? where id = ?";
		if(sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
		else {
            
            sqlite3_bind_int(updateStmt, 1, serverId);
            sqlite3_bind_int(updateStmt, 2, 0);
            sqlite3_bind_int(updateStmt, 3, clientId);
            
            if(SQLITE_DONE != sqlite3_step(updateStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
		}
		
		//Reset the add statement.
		sqlite3_reset(updateStmt);
		sqlite3_finalize(updateStmt);
	}
	sqlite3_close(database);
}
// update Packing Title ServerId
- (void)updateServerIdPackingTitle:(int)packingTitleId withServerId:(int)serverId
{
	if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
	{
        //title, dateTime, content,owner_user_id,trip_id,server_id,flag
        const char *sql = "UPDATE PackingTitles SET server_id = ? where id = ?";
		if(sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
		else {
            
            sqlite3_bind_int(updateStmt, 1, serverId);
            sqlite3_bind_int(updateStmt, 2, packingTitleId);
            
            if(SQLITE_DONE != sqlite3_step(updateStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
		}
		
		//Reset the add statement.
		sqlite3_reset(updateStmt);
		sqlite3_finalize(updateStmt);
	}
	sqlite3_close(database);
}
//delete Packing Item
- (void)deletePackingTitle:(int)packingTitleId {
    
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
        
        NSString *query = [NSString stringWithFormat:@"DELETE from PackingTitles where id = %d",packingTitleId];
        
        const char *sql = [query UTF8String];
        if (sqlite3_prepare_v2(database, sql, -1, &deleteStmt, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
        } else {
            sqlite3_exec(database, sql, NULL, NULL, NULL);
        }
        
        sqlite3_reset(deleteStmt);
        sqlite3_finalize(deleteStmt);
    }
    
    sqlite3_close(database);
}


// =========== TABLE PACKING ITEM ===========

// add PACKING ITEM
- (void)addPackingItemInfor:(PackingItemObj*)dictPackItem{
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
    {
        const char *sql = "insert into PackingItems (itemname, ischeck, packing_id, server_id, flag, idaddnew) Values(?,?,?,?,?,?)";
        if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
        else{
            sqlite3_bind_text(addStmt, 1, [dictPackItem.itemName UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(addStmt, 2, dictPackItem.isCheck);
            sqlite3_bind_int(addStmt, 3, dictPackItem.packingId);
            sqlite3_bind_int(addStmt, 4, dictPackItem.serverId);
            sqlite3_bind_int(addStmt, 5, dictPackItem.flag);
            sqlite3_bind_int(addStmt, 6, dictPackItem.idAddNew);
            
            if(SQLITE_DONE != sqlite3_step(addStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
            
        }
        sqlite3_reset(addStmt);
        sqlite3_finalize(addStmt);
        
    }
    sqlite3_close(database);
}

//GET PACKING ITEM
- (NSMutableArray*)getPackingItems:(int)packingId{
	sqlite3 *database;
    NSMutableArray *packingItemArr = [[NSMutableArray alloc] init];
	if(sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
		//const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from Events where keyName = %@",rowID] UTF8String];
        NSString *str = [NSString stringWithFormat:@"SELECT * from PackingItems NOLOCK"];
        if (packingId != 0) {
            str = [NSString stringWithFormat:@"SELECT * from PackingItems NOLOCK where packing_id = %d",packingId];
        }
        const char *sqlStatement = [str UTF8String];
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                NSInteger itemId      = sqlite3_column_int(compiledStatement, 0);
                NSString *itemName    = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 1)]);
                NSInteger isCheck      = sqlite3_column_int(compiledStatement, 2);
                NSInteger packingId = sqlite3_column_int(compiledStatement, 3);
                NSInteger serverId    = sqlite3_column_int(compiledStatement, 4);
				NSInteger flag        = sqlite3_column_int(compiledStatement, 5);
                
                PackingItemObj *objPackItem = [[PackingItemObj alloc] init];
                objPackItem.itemId = itemId;
                objPackItem.itemName = itemName;
                objPackItem.isCheck = isCheck;
                objPackItem.packingId  = packingId;
                objPackItem.serverId = serverId;
                objPackItem.flag = flag;
                
                [packingItemArr addObject:objPackItem];
			}
            if (packingItemArr.count  == 0) {
                str = [NSString stringWithFormat:@"SELECT * from PackingItems NOLOCK where idaddnew = %d",packingId];
                const char *sqlStatement = [str UTF8String];
                sqlite3_stmt *compiledStatement;
                if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
                    while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                        // Read the data from the result row
                        NSInteger itemId      = sqlite3_column_int(compiledStatement, 0);
                        NSString *itemName    = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 1)]);
                        NSInteger isCheck      = sqlite3_column_int(compiledStatement, 2);
                        NSInteger packingId = sqlite3_column_int(compiledStatement, 3);
                        NSInteger serverId    = sqlite3_column_int(compiledStatement, 4);
                        NSInteger flag        = sqlite3_column_int(compiledStatement, 5);
                        
                        PackingItemObj *objPackItem = [[PackingItemObj alloc] init];
                        objPackItem.itemId = itemId;
                        objPackItem.itemName = itemName;
                        objPackItem.isCheck = isCheck;
                        objPackItem.packingId  = packingId;
                        objPackItem.serverId = serverId;
                        objPackItem.flag = flag;
                        
                        [packingItemArr addObject:objPackItem];
                    }
                }
            }
		}
      	sqlite3_reset(compiledStatement);
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
	return packingItemArr;
}
// update PACKING ITEM
- (void)updatePackingItem:(PackingItemObj*)dictPackingItem
{
	if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
	{
        //title, dateTime, content,owner_user_id,trip_id,server_id,flag
        const char *sql = "UPDATE PackingItems SET itemname = ?,isCheck = ?,packing_id = ?,server_id = ?,flag = ? where id = ?";
		if(sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
		else {
            sqlite3_bind_text(updateStmt, 1, [dictPackingItem.itemName UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(updateStmt, 2, dictPackingItem.isCheck);
            sqlite3_bind_int(updateStmt, 3, dictPackingItem.packingId);
            sqlite3_bind_int(updateStmt, 4, dictPackingItem.serverId);
            sqlite3_bind_int(updateStmt, 5, dictPackingItem.flag);
            sqlite3_bind_int(updateStmt, 6, dictPackingItem.itemId);
            
            //itemname, ischeck, packing_id, server_id, flag
            if(SQLITE_DONE != sqlite3_step(updateStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
		}
		
		//Reset the add statement.
		sqlite3_reset(updateStmt);
		sqlite3_finalize(updateStmt);
	}
	sqlite3_close(database);
}
// update Packing Item from Server
- (void)updatePackingItemFromServer:(int)clientId withServerId:(int)serverId
{
	if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
	{
        //title, dateTime, content,owner_user_id,trip_id,server_id,flag
        const char *sql = "UPDATE PackingItems SET server_id = ?,flag = ? where id = ?";
		if(sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
		else {
            
            sqlite3_bind_int(updateStmt, 1, serverId);
            sqlite3_bind_int(updateStmt, 2, 0);
            sqlite3_bind_int(updateStmt, 3, clientId);
            
            if(SQLITE_DONE != sqlite3_step(updateStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
		}
		
		//Reset the add statement.
		sqlite3_reset(updateStmt);
		sqlite3_finalize(updateStmt);
	}
	sqlite3_close(database);
}

//delete Packing Item
- (void)deletePackingItem:(int)packingItemId {
    
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
        NSString *query = [NSString stringWithFormat:@"SELECT 1 from PackingItems where id = %d",packingItemId];
        if(![self recordExists:query]){
            //do nothing
            NSLog(@"do nothing");
        }else{
            query = [NSString stringWithFormat:@"DELETE from PackingItems where id = %d",packingItemId];
            
            const char *sql = [query UTF8String];
            if (sqlite3_prepare_v2(database, sql, -1, &deleteStmt, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
            } else {
                sqlite3_exec(database, sql, NULL, NULL, NULL);
            }
            
            sqlite3_reset(deleteStmt);
            sqlite3_finalize(deleteStmt);
        }
    }
    
    sqlite3_close(database);
}


// =========== TABLE PREMADE LIST ===========

// add PREMADE LIST
- (void)addPremadeListInfor:(PremadeListObj*)dictPremadeList{
    
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
    {
        const char *sql = "insert into PremadeLists (title, server_id, flag) Values(?,?,?)";
        if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
        else{
            sqlite3_bind_text(addStmt, 1, [dictPremadeList.title UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(addStmt, 2, dictPremadeList.serverId);
            sqlite3_bind_int(addStmt, 3, dictPremadeList.flag);
            
            if(SQLITE_DONE != sqlite3_step(addStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
        }
        sqlite3_reset(addStmt);
        sqlite3_finalize(addStmt);
        
    }
    sqlite3_close(database);
}

//GET PREMADE LIST
- (NSMutableArray*)getPremadeList{
	sqlite3 *database;
    NSMutableArray *premadeListArr = [[NSMutableArray alloc] init];
	if(sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
		//const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from Events where keyName = %@",rowID] UTF8String];
        const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from PremadeLists NOLOCK"] UTF8String];
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                NSInteger listId   = sqlite3_column_int(compiledStatement, 0);
                NSString *title       = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 1)]);
                NSInteger serverId    = sqlite3_column_int(compiledStatement, 2);
				NSInteger flag        = sqlite3_column_int(compiledStatement, 3);
                
                PremadeListObj *objPremadeList = [[PremadeListObj alloc] init];
                objPremadeList.listId = listId;
                objPremadeList.title = title;
                objPremadeList.serverId = serverId;
                objPremadeList.flag = flag;
                
                [premadeListArr addObject:objPremadeList];
			}
		}
      	sqlite3_reset(compiledStatement);
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
	return premadeListArr;
}


// =========== TABLE PREMADE ITEM ===========

// add PREMADE ITEM
- (void)addPremadeItemInfor:(PremadeItemObj*)dictPremadeItem{
    
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
    {
        const char *sql = "insert into PremadeItems (nameitem, list_id, server_id, flag) Values(?,?,?,?)";
        if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
        else{
            sqlite3_bind_text(addStmt, 1, [dictPremadeItem.itemName UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(addStmt, 2, dictPremadeItem.listId);
            sqlite3_bind_int(addStmt, 3, dictPremadeItem.serverId);
            sqlite3_bind_int(addStmt, 4, dictPremadeItem.flag);
            
            if(SQLITE_DONE != sqlite3_step(addStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
        }
        sqlite3_reset(addStmt);
        sqlite3_finalize(addStmt);
        
    }
    sqlite3_close(database);
}

//GET PREMADE ITEM
- (NSMutableArray*)getPremadeItem:(int)listId{
	sqlite3 *database;
    NSMutableArray *premadeItemArr = [[NSMutableArray alloc] init];
	if(sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
		//const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from Events where keyName = %@",rowID] UTF8String];
        NSString *str = [NSString stringWithFormat:@"SELECT * from PremadeItems NOLOCK"];
        if (listId != 0) {
            str = [NSString stringWithFormat:@"SELECT * from PremadeItems NOLOCK where list_id = %d",listId];
        }
        const char *sqlStatement = [str UTF8String];
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                NSInteger itemId      = sqlite3_column_int(compiledStatement, 0);
                NSString *itemName    = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 1)]);
                NSInteger listId      = sqlite3_column_int(compiledStatement, 2);
                NSInteger serverId    = sqlite3_column_int(compiledStatement, 3);
				NSInteger flag        = sqlite3_column_int(compiledStatement, 4);
                
                PremadeItemObj *objPremadeList = [[PremadeItemObj alloc] init];
                objPremadeList.itemId = itemId;
                objPremadeList.listId = listId;
                objPremadeList.itemName = itemName;
                objPremadeList.serverId = serverId;
                objPremadeList.flag = flag;
                
                [premadeItemArr addObject:objPremadeList];
			}
		}
      	sqlite3_reset(compiledStatement);
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
	return premadeItemArr;
}
#pragma mark PHOTO DATA
// =========== TABLE PHOTO ===========

// add PHOTO
- (void)addPhotoInfor:(PhotoObj*)dictPhoto{
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
    {
        const char *sql = "insert into Photos (caption, urlphoto, isreceipt, trip_id, owner_user_id, server_id, flag) Values(?,?,?,?,?,?,?)";
        if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
        else{
            sqlite3_bind_text(addStmt, 1, [dictPhoto.caption UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(addStmt, 2, [dictPhoto.urlPhoto UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(addStmt, 3, dictPhoto.isReceipt);
            sqlite3_bind_int(addStmt, 4, dictPhoto.tripId);
            sqlite3_bind_int(addStmt, 5, dictPhoto.ownerUserId);
            sqlite3_bind_int(addStmt, 6, dictPhoto.serverId);
            sqlite3_bind_int(addStmt, 7, dictPhoto.flag);
            
            if(SQLITE_DONE != sqlite3_step(addStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
            
        }
        sqlite3_reset(addStmt);
        sqlite3_finalize(addStmt);
        
    }
    sqlite3_close(database);
}

// add PHOTO Receipt
- (int)addPhotoReceiptInfor:(PhotoObj*)dictPhoto{
    int rowId;
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
    {
        const char *sql = "insert into Photos (caption, urlphoto, isreceipt, trip_id, owner_user_id, server_id, flag) Values(?,?,?,?,?,?,?)";
        if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
        else{
            sqlite3_bind_text(addStmt, 1, [dictPhoto.caption UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(addStmt, 2, [dictPhoto.urlPhoto UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(addStmt, 3, dictPhoto.isReceipt);
            sqlite3_bind_int(addStmt, 4, dictPhoto.tripId);
            sqlite3_bind_int(addStmt, 5, dictPhoto.ownerUserId);
            sqlite3_bind_int(addStmt, 6, dictPhoto.serverId);
            sqlite3_bind_int(addStmt, 7, dictPhoto.flag);
            
            if(SQLITE_DONE != sqlite3_step(addStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
            
        }
        sqlite3_reset(addStmt);
        sqlite3_finalize(addStmt);
        
    }
    rowId = [[[NSNumber alloc] initWithLongLong:sqlite3_last_insert_rowid(database)] intValue];
    sqlite3_close(database);
    return rowId;
}

//GET PHOTO
- (NSMutableArray*)getPhotoItems:(int)tripId andReceipt:(int)isReceipt{
	sqlite3 *database;
    NSMutableArray *photoArray = [[NSMutableArray alloc] init];
	if(sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
		//const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from Events where keyName = %@",rowID] UTF8String];
        NSString *str = [NSString stringWithFormat:@"SELECT * from Photos NOLOCK"];
        if (tripId != 0) {
            str = [NSString stringWithFormat:@"SELECT * from Photos NOLOCK where trip_id = %d and isReceipt = %d",tripId,isReceipt];
        }
        const char *sqlStatement = [str UTF8String];
        sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                NSInteger itemId      = sqlite3_column_int(compiledStatement, 0);
                NSString *caption    = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 1)]);
                NSString *urlPhoto    = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 2)]);
                NSInteger isReceipt      = sqlite3_column_int(compiledStatement, 3);
                NSInteger tripId      = sqlite3_column_int(compiledStatement, 4);
                NSInteger ownerUserId = sqlite3_column_int(compiledStatement, 5);
                NSInteger serverId    = sqlite3_column_int(compiledStatement, 6);
				NSInteger flag        = sqlite3_column_int(compiledStatement, 7);
                
                PhotoObj *objPhoto = [[PhotoObj alloc] init];
                objPhoto.photoId = itemId;
                objPhoto.caption = caption;
                objPhoto.urlPhoto = urlPhoto;
                objPhoto.isReceipt = isReceipt;
                objPhoto.tripId  = tripId;
                objPhoto.ownerUserId  = ownerUserId;
                objPhoto.serverId = serverId;
                objPhoto.flag = flag;
                 if (tripId == 0)
                     [photoArray addObject:objPhoto];
                 else{
                      if (flag != 3)
                          [photoArray addObject:objPhoto];
                 }
			}
		}
      	sqlite3_reset(compiledStatement);
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
	return photoArray;
}

//GET PHOTO
- (NSMutableArray*)getPhotoItemsSync:(int)userId andReceipt:(int)isReceipt{
    sqlite3 *database;
    NSMutableArray *photoArray = [[NSMutableArray alloc] init];
    if(sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
        //const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from Events where keyName = %@",rowID] UTF8String];
        NSString *str = [NSString stringWithFormat:@"SELECT * from Photos NOLOCK"];
        if (userId != 0) {
            str = [NSString stringWithFormat:@"SELECT * from Photos NOLOCK where trip_id = %d and isReceipt = %d",userId,isReceipt];
        }
        const char *sqlStatement = [str UTF8String];
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                // Read the data from the result row
                NSInteger itemId      = sqlite3_column_int(compiledStatement, 0);
                NSString *caption    = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 1)]);
                NSString *urlPhoto    = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 2)]);
                NSInteger isReceipt      = sqlite3_column_int(compiledStatement, 3);
                NSInteger tripId      = sqlite3_column_int(compiledStatement, 4);
                NSInteger ownerUserId = sqlite3_column_int(compiledStatement, 5);
                NSInteger serverId    = sqlite3_column_int(compiledStatement, 6);
                NSInteger flag        = sqlite3_column_int(compiledStatement, 7);
                
                PhotoObj *objPhoto = [[PhotoObj alloc] init];
                objPhoto.photoId = itemId;
                objPhoto.caption = caption;
                objPhoto.urlPhoto = urlPhoto;
                objPhoto.isReceipt = isReceipt;
                objPhoto.tripId  = tripId;
                objPhoto.ownerUserId  = ownerUserId;
                objPhoto.serverId = serverId;
                objPhoto.flag = flag;
                if (serverId > 0) {
                    [photoArray addObject:objPhoto];
                }
            }
        }
        sqlite3_reset(compiledStatement);
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    return photoArray;
}

// update Photos from Server
- (void)updatePhotoFromServer:(int)clientId withServerId:(int)serverId
{
	if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
	{
        //title, dateTime, content,owner_user_id,trip_id,server_id,flag
        const char *sql = "UPDATE Photos SET server_id = ?,flag = ? where id = ?";
		if(sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
		else {
            
            sqlite3_bind_int(updateStmt, 1, serverId);
            sqlite3_bind_int(updateStmt, 2, 0);
            sqlite3_bind_int(updateStmt, 3, clientId);
            
            if(SQLITE_DONE != sqlite3_step(updateStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
		}
		
		//Reset the add statement.
		sqlite3_reset(updateStmt);
		sqlite3_finalize(updateStmt);
	}
	sqlite3_close(database);
}
// update Photos Url from Server
- (void)updatePhotoUrlFromServer:(int)clientId withPhotoUrl:(NSString*)imageName
{
	if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
	{
        //title, dateTime, content,owner_user_id,trip_id,server_id,flag
        const char *sql = "UPDATE Photos SET urlphoto = ? where id = ?";
		if(sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
		else {
            
            sqlite3_bind_text(updateStmt, 1, [imageName UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(updateStmt, 2, clientId);
            
            if(SQLITE_DONE != sqlite3_step(updateStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
		}
		
		//Reset the add statement.
		sqlite3_reset(updateStmt);
		sqlite3_finalize(updateStmt);
	}
	sqlite3_close(database);
}
//delete Photo
- (void)deletePhoto:(int)photoId {
    
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
//        NSString *query_ = @"SELECT 1 from AppImages where id like '%GalleryImage_%'";
//        
//        if ([self recordExists:query_]) {
        NSString *query = [NSString stringWithFormat:@"SELECT 1 from Photos where id = %d",photoId];
        if(![self recordExists:query]){
            //do nothing
            NSLog(@"do nothing");
        }else{
            query = [NSString stringWithFormat:@"DELETE from Photos where id = %d",photoId];
            const char *sql = [query UTF8String];
            if (sqlite3_prepare_v2(database, sql, -1, &deleteStmt, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
            } else {
                sqlite3_exec(database, sql, NULL, NULL, NULL);
            }
            
            sqlite3_reset(deleteStmt);
            sqlite3_finalize(deleteStmt);
        }
	}
    
	sqlite3_close(database);
}

// =========== TABLE SLIDESHOW ===========
// add slideshow
- (void)saveSlideshow:(NSString*)urlServerLink photo:(NSString*)urlPhoto{
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
    {
        const char *sql = "insert into Slideshow (user_id, trip_id, serverurl, photourl) Values(?,?,?,?)";
        if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
        else{
            sqlite3_bind_int(addStmt, 1, [[USER_DEFAULT objectForKey:@"userId"] intValue]);
            sqlite3_bind_int(addStmt, 2, [[USER_DEFAULT objectForKey:@"userTripId"] intValue]);
            sqlite3_bind_text(addStmt, 3, [urlServerLink UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(addStmt, 4, [urlPhoto UTF8String], -1, SQLITE_TRANSIENT);
            if(SQLITE_DONE != sqlite3_step(addStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
            
        }
        sqlite3_reset(addStmt);
        sqlite3_finalize(addStmt);
        
    }
    sqlite3_close(database);
}

//delete Slideshow
- (void)deleteSlideshow:(int)slideshowId {
    
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
        NSString *query = [NSString stringWithFormat:@"DELETE from Slideshow where id = %d",slideshowId];
        
        const char *sql = [query UTF8String];
        if (sqlite3_prepare_v2(database, sql, -1, &deleteStmt, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
        } else {
            sqlite3_exec(database, sql, NULL, NULL, NULL);
        }
        
        sqlite3_reset(deleteStmt);
        sqlite3_finalize(deleteStmt);
        //        }
    }
    
    sqlite3_close(database);
}

//GET SLIDESHOW LIST
- (NSMutableArray*)getSlideshowList:(int)tripId{
    sqlite3 *database;
    NSMutableArray *SlideshowListArr = [[NSMutableArray alloc] init];
    if(sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
        //const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from Events where keyName = %@",rowID] UTF8String];
        const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from Slideshow NOLOCK where trip_id = %d",tripId] UTF8String];
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                // Read the data from the result row
                NSInteger videoId    = sqlite3_column_int(compiledStatement, 0);
                NSInteger userId     = sqlite3_column_int(compiledStatement, 1);
                NSInteger tripId     = sqlite3_column_int(compiledStatement, 2);
                NSString *serverUrl  = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 3)]);
                NSString *photoUrl  = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 4)]);
                                                                                     
                SlideShow *objVideo = [[SlideShow alloc] init];
                objVideo.videoId = videoId;
                objVideo.userId = userId;
                objVideo.tripId = tripId;
                objVideo.serverUrl = serverUrl;
                objVideo.photoUrl = photoUrl;
                
                [SlideshowListArr addObject:objVideo];
            }
        }
        sqlite3_reset(compiledStatement);
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    return SlideshowListArr;
}


// =========== TABLE CATEGORIES ===========
// add Category
- (int)addCategoryInfor:(CategoryObj*)dictCategory{
    int rowId;
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
    {
        const char *sql = "insert into Categories (user_id, server_id, title, color, flag) Values(?,?,?,?,?)";
        if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
        else{
            sqlite3_bind_int(addStmt, 1, dictCategory.ownerUserId);
            sqlite3_bind_int(addStmt, 2, dictCategory.serverId);
            sqlite3_bind_text(addStmt, 3, [dictCategory.title UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(addStmt, 4, [dictCategory.color UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(addStmt, 5, dictCategory.flag);
            
            if(SQLITE_DONE != sqlite3_step(addStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
            
        }
        sqlite3_reset(addStmt);
        sqlite3_finalize(addStmt);
        
    }
    rowId = [[[NSNumber alloc] initWithLongLong:sqlite3_last_insert_rowid(database)] intValue];
    sqlite3_close(database);
    if (rowId > 6) {
        [self getNextColor];
    }
    return rowId;
}
// get next color
- (void)getNextColor{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    float randomRed    = arc4random() % 255;
    float randomGreen  = arc4random() % 255;
    float randomBlue   = arc4random() % 255;
    NSInteger HexRed   = randomRed;
    NSInteger HexGreen = randomGreen;
    NSInteger HexBlue  = randomBlue;
    NSString *strNewColor = [NSString stringWithFormat:@"%X%x%x",HexRed,HexGreen,HexBlue];
    BOOL isExist = false;
    for (int i = 0; i < delegate.arrayColor.count; i++) {
        NSString *strColor = [delegate.arrayColor objectAtIndex:i];
        if ([strNewColor isEqualToString:strColor]) {
            isExist = true;
            break;
        }
    }
    if (isExist) {
        [self getNextColor];
    }else{
        [delegate.arrayColor addObject:strNewColor];
        @synchronized(self)
        {
            [self createTable:@"Colors"];
            [self addColor:strNewColor];
        }
    }
}
//GET Category LIST
- (NSMutableArray*)getCategoryList{
    sqlite3 *database;
    int userId = [[USER_DEFAULT objectForKey:@"userId"] intValue];
    NSMutableArray *CategoryListArr = [[NSMutableArray alloc] init];
    if(sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
        //const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from Events where keyName = %@",rowID] UTF8String];
        const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from Categories NOLOCK where user_id = %d",userId] UTF8String];
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                // Read the data from the result row
                NSInteger categoryId   = sqlite3_column_int(compiledStatement, 0);
                NSInteger ownerUserId  = sqlite3_column_int(compiledStatement, 1);
                NSInteger serverId     = sqlite3_column_int(compiledStatement, 2);
                NSString *title        = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 3)]);
                NSString *color        = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 4)]);
                NSInteger flag         = sqlite3_column_int(compiledStatement, 5);
                
                CategoryObj *objCat = [[CategoryObj alloc] init];
                objCat.categoryId = categoryId;
                objCat.ownerUserId = ownerUserId;
                objCat.serverId = serverId;
                objCat.title = title;
                objCat.color = color;
                objCat.flag = flag;
                
                [CategoryListArr addObject:objCat];
            }
        }
        sqlite3_reset(compiledStatement);
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    return CategoryListArr;
}

// update EXPENSES from Server
- (void)updateCategoryFromServer:(int)clientId withServerId:(int)serverId
{
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
    {
        //title, dateTime, content,owner_user_id,trip_id,server_id,flag
        const char *sql = "UPDATE Categories SET server_id = ?,flag = ? where id = ?";
        if(sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
        else {
            
            sqlite3_bind_int(updateStmt, 1, serverId);
            sqlite3_bind_int(updateStmt, 2, 0);
            sqlite3_bind_int(updateStmt, 3, clientId);
            
            if(SQLITE_DONE != sqlite3_step(updateStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
        }
        
        //Reset the add statement.
        sqlite3_reset(updateStmt);
        sqlite3_finalize(updateStmt);
    }
    sqlite3_close(database);
}

// update EXPENSES
- (void)updateCategory:(CategoryObj*)dictExp
{
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
    {
        //title, dateTime, content,owner_user_id,trip_id,server_id,flag
        const char *sql = "UPDATE Categories SET user_id = ?,server_id = ?,title = ?,flag = ? where id = ?";
        if(sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
        else {
            sqlite3_bind_int(updateStmt, 1, dictExp.ownerUserId);
            sqlite3_bind_int(updateStmt, 2, dictExp.serverId);
            sqlite3_bind_text(updateStmt, 3, [dictExp.title UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(updateStmt, 4, dictExp.flag);
            sqlite3_bind_int(updateStmt, 5, dictExp.categoryId);
            
            if(SQLITE_DONE != sqlite3_step(updateStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
        }
        
        //Reset the add statement.
        sqlite3_reset(updateStmt);
        sqlite3_finalize(updateStmt);
    }
    sqlite3_close(database);
}

//delete Category
- (void)deleteCategory:(int)categoryId {
    
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
        //        NSString *query_ = @"SELECT 1 from AppImages where id like '%GalleryImage_%'";
        //
        //        if ([self recordExists:query_]) {
        NSString *query = [NSString stringWithFormat:@"DELETE from Categories where id = %d",categoryId];
        
        const char *sql = [query UTF8String];
        if (sqlite3_prepare_v2(database, sql, -1, &deleteStmt, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
        } else {
            sqlite3_exec(database, sql, NULL, NULL, NULL);
        }
        
        sqlite3_reset(deleteStmt);
        sqlite3_finalize(deleteStmt);
        //        }
    }
    
    sqlite3_close(database);
}
//(id INTEGER PRIMARY KEY NOT NULL,user_id INTEGER, server_id INTEGER, title VARCHAR, color VARCHAR, flag INTEGER)


// =========== TABLE COLORS ===========
// add Color
- (void)addColor:(NSString*)color{
    if (sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK)
    {
        const char *sql = "insert into Colors (user_id, color) Values(?,?)";
        if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
        else{
            sqlite3_bind_int(addStmt, 1, [[USER_DEFAULT objectForKey:@"userId"] intValue]);
            sqlite3_bind_text(addStmt, 2, [color UTF8String], -1, SQLITE_TRANSIENT);
            
            if(SQLITE_DONE != sqlite3_step(addStmt ))
                NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
            
        }
        sqlite3_reset(addStmt);
        sqlite3_finalize(addStmt);
        
    }
    sqlite3_close(database);
}

//GET Category LIST
- (NSMutableArray*)getColor{
    sqlite3 *database;
    int userId = [[USER_DEFAULT objectForKey:@"userId"] intValue];
    NSMutableArray *ColorArr = [[NSMutableArray alloc] init];
    if(sqlite3_open([[Common getFilePath:DATABASE] UTF8String], &database) == SQLITE_OK) {
        //const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from Events where keyName = %@",rowID] UTF8String];
        const char *sqlStatement = [[NSString stringWithFormat:@"SELECT * from Colors NOLOCK where user_id = %d",userId] UTF8String];
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                // Read the data from the result row
                NSInteger colorId   = sqlite3_column_int(compiledStatement, 0);
                NSInteger ownerUserId  = sqlite3_column_int(compiledStatement, 1);
                NSString *color        = @([self checkNull:(char *)sqlite3_column_text(compiledStatement, 2)]);
                
                NSDictionary *objColor = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:colorId],@"colorId",color,@"color",[NSNumber numberWithInteger:ownerUserId],@"ownerUserId", nil];
                
                [ColorArr addObject:objColor];
            }
        }
        sqlite3_reset(compiledStatement);
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    return ColorArr;
}

@end
