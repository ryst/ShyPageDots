
#define FADE_DURATION 0.5
#define DELAY_TO_FADE 1.0

@interface SBFolderView : UIView
@end

@interface SBIconListPageControl : UIPageControl
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
	[UIView animateWithDuration:FADE_DURATION animations:^{ _pageControl.alpha = 0; }];
}

%new
-(void)_showPageControl {
	SBIconListPageControl* _pageControl = MSHookIvar<SBIconListPageControl*>(self, "_pageControl");
	if (_pageControl.numberOfPages > 1 || !_pageControl.hidesForSinglePage) {
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

	for (UIView* v in self.subviews) {
		v.alpha = 0;
	}
}
%end
