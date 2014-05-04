//
//  ContainerViewController.m
//  Container Transitions
//
//  Created by Joachim Bondo on 30/04/2014.
//

#import "ContainerViewController.h"

static CGFloat const kButtonSlotWidth = 64; // Also distance between button centers
static CGFloat const kButtonSlotHeight = 44;

@interface ContainerViewController ()
@property (nonatomic, copy, readwrite) NSArray *viewControllers;
@property (nonatomic, strong) UIView *privateButtonsView; /// The view hosting the buttons of the child view controllers.
@property (nonatomic, strong) UIView *privateContainerView; /// The view hosting the child view controllers views.
@end

@implementation ContainerViewController

- (instancetype)initWithViewControllers:(NSArray *)viewControllers {
	NSParameterAssert ([viewControllers count] > 0);
	if ((self = [super init])) {
		self.viewControllers = [viewControllers copy];
	}
	return self;
}

- (void)loadView {
	
	// Add  container and buttons views.
	
	UIView *rootView = [[UIView alloc] init];
	rootView.backgroundColor = [UIColor blackColor];
	rootView.opaque = YES;
	
	self.privateContainerView = [[UIView alloc] init];
	self.privateContainerView.backgroundColor = [UIColor blackColor];
	self.privateContainerView.opaque = YES;
	
	self.privateButtonsView = [[UIView alloc] init];
	self.privateButtonsView.backgroundColor = [UIColor clearColor];
	self.privateButtonsView.tintColor = [UIColor colorWithWhite:1 alpha:0.75f];
	
	[self.privateContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self.privateButtonsView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[rootView addSubview:self.privateContainerView];
	[rootView addSubview:self.privateButtonsView];
	
	// Container view fills out entire root view.
	[rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateContainerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
	[rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateContainerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
	[rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateContainerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
	[rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateContainerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
	
	// Place buttons view in the top half, horizontally centered.
	[rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateButtonsView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:[self.viewControllers count] * kButtonSlotWidth]];
	[rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateButtonsView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.privateContainerView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	[rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateButtonsView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:kButtonSlotHeight]];
	[rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateButtonsView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.privateContainerView attribute:NSLayoutAttributeCenterY multiplier:0.4f constant:0]];
	
	[self _addChildViewControllerButtons];
	
	self.view = rootView;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.selectedViewController = (self.selectedViewController ?: self.viewControllers[0]);
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
	return self.selectedViewController;
}

-(void)setSelectedViewController:(UIViewController *)selectedViewController {
	NSParameterAssert (selectedViewController);
	[self _transitionToChildViewController:selectedViewController];
	_selectedViewController = selectedViewController;
	[self _updateButtonSelection];
}

#pragma mark Private Methods

- (void)_addChildViewControllerButtons {
	
	[self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *childViewController, NSUInteger idx, BOOL *stop) {
		
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		UIImage *icon = [childViewController.tabBarItem.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		[button setImage:icon forState:UIControlStateNormal];
		UIImage *selectedIcon = [childViewController.tabBarItem.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		[button setImage:selectedIcon forState:UIControlStateSelected];
		
		button.tag = idx;
		[button addTarget:self action:@selector(_buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
		
		[self.privateButtonsView addSubview:button];
		[button setTranslatesAutoresizingMaskIntoConstraints:NO];
		
		[self.privateButtonsView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.privateButtonsView attribute:NSLayoutAttributeLeading multiplier:1 constant:(idx + 0.5f) * kButtonSlotWidth]];
		[self.privateButtonsView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.privateButtonsView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
	}];
}

- (void)_buttonTapped:(UIButton *)button {
	UIViewController *selectedViewController = self.viewControllers[button.tag];
	self.selectedViewController = selectedViewController;
}

- (void)_updateButtonSelection {
	[self.privateButtonsView.subviews enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
		button.selected = (self.viewControllers[idx] == self.selectedViewController);
	}];
}

- (void)_transitionToChildViewController:(UIViewController *)toViewController {
	
	UIViewController *fromViewController = ([self.childViewControllers count] > 0 ? self.childViewControllers[0] : nil);
	if (toViewController == fromViewController || ![self isViewLoaded]) {
		return;
	}
	
	UIView *toView = toViewController.view;
	[toView setTranslatesAutoresizingMaskIntoConstraints:YES];
	toView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	toView.frame = self.privateContainerView.bounds;
	
	[fromViewController willMoveToParentViewController:nil];
	[self addChildViewController:toViewController];
	[self.privateContainerView addSubview:toView];
	[fromViewController.view removeFromSuperview];
	[fromViewController removeFromParentViewController];
	[toViewController didMoveToParentViewController:self];
}

@end
