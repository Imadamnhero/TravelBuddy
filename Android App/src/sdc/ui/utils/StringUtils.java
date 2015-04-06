package sdc.ui.utils;

import java.text.DecimalFormat;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import android.text.TextUtils;

public class StringUtils {
	public static final DecimalFormat sExpensiveNumberFormat = new DecimalFormat(
			"0.00");

	/**
	 * method is used for checking valid email id format.
	 * 
	 * @param email
	 * @return boolean true for valid false for invalid
	 */
	public static boolean isEmailValid(String email) {
		boolean isValid = false;

		// String expression = "^[\\w\\.-]+@([\\w\\-]+\\.)+[A-Z]{2,4}$";
		String expression = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@"
				+ "[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$";
		CharSequence inputStr = email;

		Pattern pattern = Pattern.compile(expression, Pattern.CASE_INSENSITIVE);
		Matcher matcher = pattern.matcher(inputStr);
		if (matcher.matches()) {
			isValid = true;
		}
		return isValid;
	}

	/**
	 * Pass must be 6 -> 15 character
	 * 
	 * @param pass
	 * @return
	 */
	public static boolean isPassValid(String pass) {
		if (!TextUtils.isEmpty(pass) && pass.length() >= 4
				&& pass.length() <= 15) {
			return true;
		}
		return false;
	}

	/**
	 * Check whether the text is just contain space character?
	 * 
	 * @param text
	 * @return
	 */
	public static boolean isOnlyContainSpace(String text) {
		if (text.length() > 0) {
			for (int i = 0; i < text.length(); i++)
				if (text.charAt(i) != ' ')
					return false;
		} else
			return false;
		return true;
	}
}
