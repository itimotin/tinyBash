//
//  ViewController.m
//  tinyBash
//
//  Created by Viktor Kotseruba on 9/4/12.
//  Copyright (c) 2012 Viktor Kotseruba. All rights reserved.
//

#import "ViewController.h"


@interface NSString(NoBR)

- (NSString*)brToNewline;

@end


@implementation NSString(NoBR)

- (NSString *)brToNewline
{
  return [self stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
}

@end


@interface ViewController ()

- (void)fetchRss;
- (CGSize)sizeForText:(NSString*)text;
- (UIFont*)labelFont;
- (void)loadFailure;

@end


@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  ViewController *this = self;
  [tableView addPullToRefreshWithActionHandler:^{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
      [this fetchRss];
    });

  }];
  [tableView.pullToRefreshView triggerRefresh];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)fetchRss
{
  NSData *xmlData = [[NSMutableData alloc]
                     initWithContentsOfURL:[NSURL URLWithString:RSS_URL]];
  NSError *error;
  GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
  if (error != nil) {
    [self loadFailure];
    return;
  }
  NSArray *itemNodes = [doc.rootElement nodesForXPath:@"channel/item/description" error:&error];
  if (error != nil) {
    [self loadFailure];
    return;
  }
  items = [NSMutableArray array];
  for (GDataXMLNode *descNode in itemNodes) {
    [items addObject:descNode.stringValue.gtm_stringByUnescapingFromHTML.brToNewline];
  }
  [tableView reloadData];
  [tableView.pullToRefreshView stopAnimating];
}

- (CGSize)sizeForText:(NSString *)text
{
  CGSize constraint = CGSizeMake(tableView.bounds.size.width - (TEXT_MARGIN * 2), 20000.0f);
  CGSize size = [text sizeWithFont:self.labelFont
                 constrainedToSize:constraint
                     lineBreakMode:UILineBreakModeWordWrap];
  return size;
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
  return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"Cell"];
  UILabel *label;
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.numberOfLines = 0;
    label.font = self.labelFont;
    label.tag = 1;
    [cell.contentView addSubview:label];
  } else {
    label = (UILabel*) [cell viewWithTag:1];
  }
  NSString *text = [items objectAtIndex:indexPath.row];
  label.text = text;
  [label setFrame:CGRectMake(TEXT_MARGIN, TEXT_MARGIN + CELL_MARGIN, tableView.bounds.size.width - TEXT_MARGIN * 2, [self sizeForText:text].height)];
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *text = [items objectAtIndex:indexPath.row];
  CGSize size = [self sizeForText:text];
  return size.height + TEXT_MARGIN * 2 + CELL_MARGIN * 2;
}

- (UIFont *)labelFont
{
  CGFloat fontSize;
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    fontSize = IPAD_FONT_SIZE;
  } else {
    fontSize = IPHONE_FONT_SIZE;
  }
  return [UIFont fontWithName:FONT_NAME size:fontSize];
}

- (void)loadFailure
{
  [tableView.pullToRefreshView stopAnimating];
  [SVProgressHUD showErrorWithStatus:@"network error" duration:10.0f];
}

@end
