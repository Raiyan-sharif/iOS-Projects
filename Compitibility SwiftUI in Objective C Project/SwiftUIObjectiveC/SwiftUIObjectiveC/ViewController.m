//
//  ViewController.m
//  SwiftUIObjectiveC
//
//  Created by Synesis Sqa on 28/4/25.
//

#import "ViewController.h"
#import "SwiftUIObjectiveC-Swift.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)buttonTapped:(UIButton *)sender {
    // Swift Extension will be called
    [self displaySwiftUIWapper];
}


@end
