package sdc.ui.utils;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;

import android.annotation.SuppressLint;
import android.content.Context;

@SuppressLint({ "SimpleDateFormat", "DefaultLocale" })
public class DateTimeUtils {
	public static final SimpleDateFormat sDateFormat = new SimpleDateFormat(
			"M-d-yyyy", Locale.ENGLISH);
	public static final SimpleDateFormat sServerDateFormat = new SimpleDateFormat(
			"yyyy-MM-dd'T'HH:mm:ssZZZZZ");

	public static String getDateForSubmit(long timeInMiliseconds) {
		StringBuffer buffer = new StringBuffer(
				sServerDateFormat.format(new Date(timeInMiliseconds)));
		//buffer.insert(buffer.length() - 2, ':');
		return buffer.toString();
	}

	public static long parseServerDate(String time) {
		try {
			Date d = sServerDateFormat.parse(time);
			return d.getTime();
		} catch (ParseException e) {
			e.printStackTrace();
			return Calendar.getInstance().getTimeInMillis();
		}
	}

	/**
	 * Compare date in format dd-MM-yyy
	 * 
	 * @param fromDate
	 * @param toDate
	 * @return true if fromDate <= toDate, else is false
	 */
	public static boolean compareDate(String fromDate, String toDate) {
		Date fromD, toD;
		try {
			fromD = sDateFormat.parse(fromDate);
			toD = sDateFormat.parse(toDate);
			if (fromD.compareTo(toD) <= 0) {
				return true;
			}
			return false;
		} catch (java.text.ParseException e) {
			e.printStackTrace();
		}
		return false;
	}

	/**
	 * create Footer String for note. e.g: By Jessica on July 7, 2014 at 9:10 am
	 * 
	 * @param ownerInfo
	 * @param datetime
	 *            under format "dd-MM-yyyy hh:mm:ss"
	 * @return
	 */
	public static String formatFooterForNote(String name, long datetime) {
		Date date = new Date(datetime);
		SimpleDateFormat sdfDate = new SimpleDateFormat("M-d-yyyy ",
				Locale.ENGLISH);
		SimpleDateFormat sdfTime = new SimpleDateFormat(" h:mm a ",
				Locale.ENGLISH);
		String datetimeFormated = " on " + sdfDate.format(date) + "at"
				+ sdfTime.format(date);
		return "By " + name + datetimeFormated;
	}

	/**
	 * create right format of date for expense
	 * 
	 * @param date
	 *            format yyyy-MM-dd
	 * @return date format MMMM d, yyyy
	 */
	public static String formatDateForExpense(String date) {
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd",
				Locale.ENGLISH);
		try {
			Date d = sdf.parse(date);
			String dateFormated = sDateFormat.format(d);
			return dateFormated;
		} catch (ParseException e) {
			e.printStackTrace();
		}
		return "Loading...";
	}

	/**
	 * Get Current date under format: Added June 1, 9:43 am
	 * 
	 * @param context
	 * @return
	 */
	public static String formatDateForReceipt(Context context) {
		Calendar cal = Calendar.getInstance();
		SimpleDateFormat sdf = new SimpleDateFormat("M-d, " + " h:m a ",
				Locale.ENGLISH);
		return "Added " + sdf.format(cal.getTime());
	}

	/**
	 * 
	 * @param time
	 *            format: 0:43, 10:59
	 * @return time that is increased by 3 sec. e.t: 0:47, 11:02
	 */
	public static String increaseTimeOfVideo(String time) {
		String[] split = time.split(":");
		int sec = Integer.parseInt(split[1]);
		int min = Integer.parseInt(split[0]);
		if (sec + 3 >= 60) {
			min++;
			sec = (sec + 3) % 60;
		} else {
			sec += 3;
		}
		return String.format("%02d" + ":" + "%02d", min, sec);
	}

	/**
	 * 
	 * @param time
	 *            format: 0:43, 10:01
	 * @return time that is decreased by 3 sec. e.t: 0:40, 9:58
	 */
	public static String decreaseTimeOfVideo(String time) {
		String[] split = time.split(":");
		int sec = Integer.parseInt(split[1]);
		int min = Integer.parseInt(split[0]);
		if (sec - 3 < 0) {
			min--;
			sec = 60 + sec - 3;
		} else {
			sec -= 3;
		}
		return String.format("%02d" + ":" + "%02d", min, sec);
	}

}
