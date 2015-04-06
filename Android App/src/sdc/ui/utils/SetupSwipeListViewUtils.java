package sdc.ui.utils;

import sdc.application.TravelApplication;
import android.content.Context;

import com.fortysevendeg.swipelistview.SwipeListView;

public class SetupSwipeListViewUtils {

	public static SwipeListView setup(SwipeListView lv, Context context) {
		lv.setOffsetLeft(TravelApplication.SCREEN_WIDTH
				- GraphicUtils.convertDpToPixel(context, 200f));
		lv.setSwipeActionLeft(SwipeListView.SWIPE_ACTION_REVEAL);
		lv.setSwipeActionRight(SwipeListView.SWIPE_ACTION_NONE);
		lv.setAnimationTime(100);
		lv.setSwipeCloseAllItemsWhenMoveList(true);
		lv.setSwipeMode(SwipeListView.SWIPE_MODE_LEFT);
		lv.setSwipeOpenOnLongPress(false);
		return lv;
	}
}
