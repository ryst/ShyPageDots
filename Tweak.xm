#define FADE_DURATION 0.5
#define DELAY_TO_FADE 1.0

NSString* const kIsFadingPropertyKey = @"isFadingPropertyKey";

@interface SBFolderView : UIView
@end

@interface SBIconListPageControl : UIPageControl
-(void)setIsFading:(BOOL)value;
-(BOOL)isFading;
@end

@interface SBFolderView (ShyPageDots)
-(void)_prepareHidePageControl;
-(void)_hidePageControl;
-(void)_showPageControl;
@end

%hook SBFolderView
- (void)pageControl:(id)arg1 didRecieveTouchInDirection:(int)arg2 {
	%orig;
	[self _prepareHidePageControl];
}

- (void)scrollViewDidEndDragging:(id)arg1 willDecelerate:(_Bool)arg2 {
	%orig;
	[self _prepareHidePageControl];
}

- (void)scrollViewWillBeginDragging:(id)arg1 {
	%orig;
	[self _showPageControl];
}

%new
-(void)_prepareHidePageControl {
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_hidePageControl) object:nil];
	[self performSelector:@selector(_hidePageControl) withObject:nil afterDelay:DELAY_TO_FADE];
}

%new
-(void)_hidePageControl {
	SBIconListPageControl* _pageControl = MSHookIvar<SBIconListPageControl*>(self, "_pageControl");
	[UIView animateWithDuration:FADE_DURATION animations:^{
		for (UIView* v in _pageControl.subviews) {
			v.alpha = 0;
		}
		_pageControl.alpha = 0;
		[_pageControl setIsFading:NO];
	}];
}

%new
-(void)_showPageControl {
	SBIconListPageControl* _pageControl = MSHookIvar<SBIconListPageControl*>(self, "_pageControl");
	if (_pageControl.numberOfPages > 1 || !_pageControl.hidesForSinglePage) {
		[_pageControl setIsFading:YES];
		[UIView animateWithDuration:FADE_DURATION animations:^{
			for (UIView* v in _pageControl.subviews) {
				v.alpha = 1;
			}
			_pageControl.alpha = 1;
		}];
	}
}
%end

%hook SBIconListPageControl
-(void)layoutSubviews {
	%orig;

	if ([self isFading])
		return;

	for (UIView* v in self.subviews) {
		v.alpha = 0;
	}
	self.alpha = 0;
}

-(SBIconListPageControl*)initWithFrame:(CGRect)rect {
	SBIconListPageControl* r = %orig;
	[r setIsFading:NO];
	return r;
}

%new
-(void)setIsFading:(BOOL)value {
	objc_setAssociatedObject(self, kIsFadingPropertyKey, [NSNumber numberWithBool:value], OBJC_ASSOCIATION_ASSIGN);
}

%new
-(BOOL)isFading {
	return [objc_getAssociatedObject(self, kIsFadingPropertyKey) boolValue];
}
%end
