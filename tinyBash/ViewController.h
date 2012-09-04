//
//  ViewController.h
//  tinyBash
//
//  Created by Viktor Kotseruba on 9/4/12.
//  Copyright (c) 2012 Viktor Kotseruba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SVPullToRefresh/SVPullToRefresh.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <GDataXML-HTML/GDataXMLNode.h>
#import "GTMNSString+HTML.h"
#import "config.h"


@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
  IBOutlet UITableView *tableView;
  NSMutableArray *items;
}

@end
