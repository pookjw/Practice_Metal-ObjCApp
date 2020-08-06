//
//  Chapter3ViewController.m
//  Practice_Metal-ObjCApp
//
//  Created by pook on 8/5/20.
//

#import "Chapter3ViewController.h"
#import "Chapter3Renderer.h"

@interface Chapter3ViewController ()
@property UIView *presentationView;
@property Chapter3Renderer *renderer;
@end

@implementation Chapter3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self runPractice];
    [self setupUI];
}

-(void)setupUI {
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    self.title = @"Chapter 3";
    
    [self.view addSubview:self.presentationView];
    self.presentationView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.presentationView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.presentationView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.presentationView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.presentationView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    self.presentationView.backgroundColor = UIColor.systemBackgroundColor;
}

-(void)runPractice {
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width);
    MTKView *view = [[MTKView alloc] initWithFrame:frame device:Chapter3Renderer.device];
    self.renderer = [Chapter3Renderer initWithMTKView:view];
    self.presentationView = view;
}

@end
