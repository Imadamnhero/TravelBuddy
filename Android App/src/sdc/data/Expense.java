package sdc.data;

import java.util.List;
import java.util.Random;

import android.graphics.Color;
import sdc.travelapp.R;

public class Expense {
	// color name="pie_purpil">#d324ff</color>
	// <color name="pie_yellow">#ffed24</color>
	// <color name="pie_blue">#24b6ff</color>
	// public static final int[] COLOR = { R.color.pie_blue, R.color.pie_yellow,
	// R.color.pie_purpil, R.color.pie_white };
	public static final int[] DEFAULT_COLORS = { Color.parseColor("#d324ff"),
			Color.parseColor("#ffed24"), Color.parseColor("#24b6ff"),
			Color.parseColor("#2eff24"), Color.parseColor("#ff6224"),
			Color.parseColor("#242eff") };

	public static int getNextColor(List<Integer> colors) {
		if (colors.size() < DEFAULT_COLORS.length) {
			return DEFAULT_COLORS[colors.size()];
		}
		// create random color
		Random random = new Random();
		int red = random.nextInt(256);
		int green = random.nextInt(256);
		int blue = random.nextInt(256);
		int color = Color.rgb(red, green, blue);

		// check color is difference
		boolean isDifference = true;
		for (int c : colors) {
			if (!isDifference(color, c)) {
				isDifference = false;
				break;
			}
		}
		if (isDifference || colors.size() == 156 * 256 * 256) {
			return color;
		} else {
			return getNextColor(colors);
		}
	}

	// check color isDifference
	private static boolean isDifference(int color1, int color2) {
		int r1 = Color.red(color1), g1 = Color.green(color1), b1 = Color
				.blue(color1);
		int r2 = Color.red(color2), g2 = Color.green(color2), b2 = Color
				.blue(color2);
		return ((((r1 - r2) / 16) > 0) || (((g1 - g2) / 16) > 0) || (((b1 - b2) / 16) > 0));
	}

	public static final int DEFAULT_DRAWABLE = R.drawable.icon_dropdown;

	private int id;
	private int cateId;
	private int localCateId;
	private String item;
	private float money;
	private String date;
	private int ownerId;
	private int serverId;
	private int flag;

	public Expense(int id, int cateId, String item, float money, String date,
			int ownerId, int serverId, int flag) {
		super();
		this.id = id;
		this.cateId = cateId;
		this.item = item;
		this.money = money;
		this.date = date;
		this.ownerId = ownerId;
		this.serverId = serverId;
		this.flag = flag;
	}

	public Expense(int cateId, String item, float money, String date,
			int ownerId) {
		super();
		this.cateId = cateId;
		this.item = item;
		this.money = money;
		this.date = date;
		this.ownerId = ownerId;
	}

	public int getCateId() {
		return cateId;
	}

	public void setCateId(int cateId) {
		this.cateId = cateId;
	}

	public String getItem() {
		return item;
	}

	public void setItem(String item) {
		this.item = item;
	}

	public float getMoney() {
		return money;
	}

	public void setMoney(float money) {
		this.money = money;
	}

	public String getDate() {
		return date;
	}

	public void setDate(String date) {
		this.date = date;
	}

	public int getOwnerId() {
		return ownerId;
	}

	public void setOwnerId(int ownerId) {
		this.ownerId = ownerId;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getServerId() {
		return serverId;
	}

	public void setServerId(int serverId) {
		this.serverId = serverId;
	}

	public int getFlag() {
		return flag;
	}

	public void setFlag(int flag) {
		this.flag = flag;
	}

	public int getLocalCateId() {
		return localCateId;
	}

	public void setLocalCateId(int localCateId) {
		this.localCateId = localCateId;
	}

}
