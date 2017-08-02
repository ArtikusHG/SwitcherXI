@interface SBDisplayItem : NSObject
@property (nonatomic,copy,readonly) NSString * displayIdentifier;
@end

@interface SBDeckSwitcherItemContainer : UIView
@property (nonatomic,readonly) SBDisplayItem * displayItem;
-(void)_handlePageViewTap:(id)arg1;
@end

@interface SBDeckSwitcherPageView
@end

@interface SBDeckSwitcherViewController : UIViewController
@property (nonatomic,copy) NSArray * displayItems;
@property (setter=_setReturnToDisplayItem:,nonatomic,copy) SBDisplayItem * _returnToDisplayItem;
-(id)_itemContainerForDisplayItem:(id)arg1;
-(void)_updateScrollViewContentOffsetToCenterIndex:(NSUInteger)arg1 
animated:(BOOL)arg2 completion:(id)arg3;
-(NSInteger)_topIndexForLocationInScrollView:(CGPoint)arg1;
-(void)dismissSwitcher;
@end
%hook SBDeckSwitcherViewController
-(void)_sendViewPresentingToPageViewsForTransitionRequest:(id)arg1 {
	%orig(arg1);
	if ([self.displayItems count] <= 1) {
	[self dismissSwitcher];	
	}
}
-(void)removeDisplayItem:(id)arg1 forReason:(NSInteger)arg2 completion:(id)arg3 {
	%orig(arg1, arg2, arg3);

	if ([self.displayItems count] <= 1) {
	[self dismissSwitcher];
}
}

-(NSUInteger)_indexForPresentationOrDismissalIsPresenting:(BOOL)arg1 {
	NSUInteger result = %orig(arg1);
	if (arg1 && [[self _returnToDisplayItem].displayIdentifier isEqualToString:@"com.apple.springboard"])
		result++;
	return result;
}

-(CGFloat)_opacityForIndex:(NSUInteger)arg1 {
	if (arg1 == 0)
		return 0.0;
	else if (arg1 == 1)
		return 1.0;
	return %orig(arg1);
}

-(BOOL)_isItemVisible:(SBDisplayItem *)arg1 {
	if ([arg1.displayIdentifier isEqualToString:@"com.apple.springboard"])
		return NO;
	return %orig(arg1);
}

-(BOOL)_isIndexVisible:(NSUInteger)arg1 {
	if (arg1 == 0)
		return NO;
	else if (arg1 == 1)
		return YES;
	return %orig(arg1);
}

-(CGFloat)_blurForIndex:(NSUInteger)arg1 {
	if (arg1 == 1)
		return %orig(0);
	return %orig(arg1);
}
-(void)scrollViewDidEndDragging:(UIScrollView *)arg1 
willDecelerate:(BOOL)arg2 {
	%orig(arg1, arg2);

	if (!arg2 && [self 
_topIndexForLocationInScrollView:arg1.contentOffset] <= 2)
		[self _updateScrollViewContentOffsetToCenterIndex:1 
animated:YES completion:nil];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)arg1 {
	%orig(arg1);

	if ([self _topIndexForLocationInScrollView:arg1.contentOffset] 
<= 2)
		[self _updateScrollViewContentOffsetToCenterIndex:1 
animated:YES completion:nil];
}
%new
-(void)dismissSwitcher {
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
SBDisplayItem *returnDisplayItem = MSHookIvar<SBDisplayItem *>(self, "_returnToDisplayItem");
SBDeckSwitcherItemContainer *returnContainer = [self _itemContainerForDisplayItem:returnDisplayItem];
SBDeckSwitcherPageView *returnPage = MSHookIvar<SBDeckSwitcherPageView *>(returnContainer, "_pageView");
[returnContainer _handlePageViewTap:returnPage];
});

}

%end
