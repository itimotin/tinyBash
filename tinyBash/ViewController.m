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
  [self queueRefresh:nil];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)queueRefresh:(id)sender
{
  navBar.topItem.title = @"loading";
  refreshBtn.enabled = NO;
  NSOperationQueue *queue = [NSOperationQueue new];
  NSInvocationOperation *load = [[NSInvocationOperation alloc]
                                 initWithTarget:self
                                 selector:@selector(fetchRss)
                                 object:nil];
  [queue addOperation:load];
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
  GDataXMLNode *titleNode = [[doc.rootElement nodesForXPath:@"channel/title" error:&error] objectAtIndex:0];
  if (error != nil) {
    [self loadFailure];
    return;
  }
  navBar.topItem.title = titleNode.stringValue;
  NSArray *itemNodes = [doc.rootElement nodesForXPath:@"channel/item/description" error:&error];
  if (error != nil) {
    [self loadFailure];
    return;
  }
  items = [NSMutableArray array];
  for (GDataXMLNode *descNode in itemNodes) {
    [items addObject:descNode.stringValue.stringByDecodingHTMLEntities.brToNewline];
  }
  refreshBtn.enabled = YES;
  [tableView reloadData];
  [tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (CGSize)sizeForText:(NSString *)text
{
  CGSize constraint = CGSizeMake(self.view.bounds.size.width - (TEXT_MARGIN * 2), 20000.0f);
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
    label.font = self.labelFont;
    label.numberOfLines = 0;
    label.tag = 17;
    [cell.contentView addSubview:label];
  } else {
    label = (UILabel*) [cell viewWithTag:17];
  }
  NSString *text = [items objectAtIndex:indexPath.row];
  label.text = text;
  [label setFrame:CGRectMake(TEXT_MARGIN, TEXT_MARGIN + CELL_MARGIN, self.view.bounds.size.width - TEXT_MARGIN * 2, [self sizeForText:text].height)];
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
  navBar.topItem.title = @"load failure";
  refreshBtn.enabled = YES;
}

@end
