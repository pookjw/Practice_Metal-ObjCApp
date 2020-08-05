//
//  MainTableViewController.m
//  Practice_Metal-ObjCApp
//
//  Created by pook on 8/2/20.
//

#import "MainTableViewController.h"
#import "Chapter1ViewController.h"
#import "Chapter2ViewController.h"

@interface MainTableViewController ()
@property NSDictionary *listOfChapter;
@end

@implementation MainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setAttribute];
    [self setChapters];
    [self loadLastChapter];
}

- (void)setupUI {
    self.title = [NSString stringWithFormat:@"Metal"];
    self.navigationController.navigationBar.prefersLargeTitles = YES;
}

- (void)setAttribute {
    [self.tableView registerClass:UITableViewCell.self forCellReuseIdentifier:@"cell"];
}

- (void)setChapters {
    self.listOfChapter = @{
        @"Chapter 1": Chapter1ViewController.self,
        @"Chapter 2": Chapter2ViewController.self
    };
}

- (void)loadLastChapter {
    NSUInteger idx = self.listOfChapter.count;
    [self pushChapter:idx];
}

- (void)pushChapter:(NSUInteger)idx {
    UIViewController *vc = [[self.listOfChapter[[NSString stringWithFormat:@"Chapter %ld", idx]] alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Chapters";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listOfChapter.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"Chapter %ld", (long)indexPath.row + 1];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger idx = indexPath.row + 1;
    [self pushChapter:idx];
}

@end
