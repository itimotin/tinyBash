//
//  ViewController.h
//  tinyBash
//
//  Created by Viktor Kotseruba on 9/4/12.
//  Copyright (c) 2012 Viktor Kotseruba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDataXMLNode.h"
#import "NSString+HTML.h"

#define RSS_URL @"http://bash.im/rss/"
#define TEXT_MARGIN 10.0f
#define CELL_MARGIN 10.0f
#define FONT_NAME @"Ubuntu-Light"
#define IPHONE_FONT_SIZE 18.0f
#define IPAD_FONT_SIZE 24.0f

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
  IBOutlet UINavigationBar *navBar;
  IBOutlet UIBarButtonItem *refreshBtn;
  IBOutlet UITableView *tableView;
  NSMutableArray *items;
}

- (IBAction)queueRefresh:(id)sender;

@end
