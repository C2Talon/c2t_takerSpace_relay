//c2t takerSpace relay
//c2t


//returns modified page for the relay browser
string c2t_takerSpace_relay(string page);

//adds all the improved buttons to the page
buffer c2t_takerSpace_relay_improvedButtons(buffer page);

//purges page of recipes known by the script; unknown ones will end up at the top of the list
buffer c2t_takerSpace_relay_purgeKnown(buffer page);

//makes the current supplies section stay at the top of the page even when scrolling down
buffer c2t_takerSpace_relay_stickySupplies(buffer page);

//returns map of cost of each item
int[item,int] c2t_takerSpace_relay_cost();

//returns map of current amount of supplies
int[int] c2t_takerSpace_relay_currency();

//returns whether can afford the thing of cost with currency
boolean c2t_takerSpace_relay_canAfford(int[int] currency,int[int] cost);

//keys for item cost
string[int] c2t_takerSpace_relay_key();

//returns the order that each item shows up in the relay browser
item[int] c2t_takerSpace_relay_order();


/* implementations */

string c2t_takerSpace_relay(string page) {
	buffer out = page;
	out.c2t_takerSpace_relay_stickySupplies();
	out.c2t_takerSpace_relay_improvedButtons();
	return out;
}
buffer c2t_takerSpace_relay_improvedButtons(buffer page) {
	int[item,int] cost = c2t_takerSpace_relay_cost();
	string[int] key = c2t_takerSpace_relay_key();
	int[int] currency = c2t_takerSpace_relay_currency();
	buffer mod;
	boolean afford;

	page.c2t_takerSpace_relay_purgeKnown();

	foreach num,ite in c2t_takerSpace_relay_order() {
		afford = c2t_takerSpace_relay_canAfford(currency,cost[ite]);

		mod.append('<form method="post" action="choice.php">');
		mod.append(`<input type="hidden" name="pwd" value="{my_hash()}" />`);
		mod.append('<input type="hidden" name="option" value="1" />');
		mod.append('<input type="hidden" name="whichchoice" value="1537" />');
		foreach i,x in key
			mod.append(`<input type="hidden" name="{x}" value="{cost[ite,i]}" />`);
		mod.append('<div style="display: flex"><button class="button" type="submit" style="display: flex"><div style="margin-right: 1em">');
		if (!afford)
			mod.append('<span style="opacity:0.5;">');
		mod.append(`{ite.name} <span style="color:#00f">(have:&nbsp;{available_amount(ite)})</span><br />`);
		foreach i,x in key
			mod.append((i == 0 ? "" : ", ") + `{cost[ite,i]} {x}`);
		if (!afford)
			mod.append('</span>');
		mod.append("</div>");
		mod.append(`<img src="/images/itemimages/{ite.image}" align="absmiddle" `);
		if (!afford)
			mod.append('style="opacity:0.5;" ');
		mod.append("/></button>");
		mod.append(`<img src="/images/itemimages/magnify.gif" align="absmiddle" onclick="descitem('{ite.descid}')" height="30" width="30" />`);
		mod.append("</div></form>");
	}
	string replace = '<p><a href="campground.php">Back to Campground</a>';
	page.replace_string(replace,mod+replace);

	return page;
}
buffer c2t_takerSpace_relay_purgeKnown(buffer page) {
	matcher mat = create_matcher(`<form\.+?</form>`,page);
	mat.find();//skip first form

	if (mat.find()) foreach i,x in c2t_takerSpace_relay_order() {
		if (create_matcher(`<div style="margin-right: 1em">\\s*{x.name}<br`,mat.group(0)).find()) {
			page.replace_string(mat.group(0),"");
			if (!mat.find())
				break;
		}
	}
	return page;
}
buffer c2t_takerSpace_relay_stickySupplies(buffer page) {
	matcher mat = create_matcher(`(<b>Current Supplies:</b>[^\\n]+)<br>`,page);
	if (mat.find())
		page.replace_string(mat.group(0),`<div style="background-color:#fff;position:sticky;top:0;z-index:10;">{mat.group(1)}<hr /></div>`);
	return page;
}
int[item,int] c2t_takerSpace_relay_cost() {
	return int[item,int]{
		$item[deft pirate hook]:		{0,0,1,1,0,1},
		$item[iron tricorn hat]:		{0,0,2,1,0,0},
		$item[jolly roger flag]:		{0,1,0,1,1,0},
		$item[sleeping profane parrot]:		{15,3,0,0,2,1},
		$item[pirrrate's currrse]:		{2,2,0,0,0,0},
		$item[tankard of spiced rum]:		{1,2,0,0,0,0},
		$item[tankard of spiced goldschlepper]:	{0,2,0,0,0,1},
		$item[packaged luxury garment]:		{0,0,0,0,3,2},
		$item[harpoon]:				{0,0,0,2,0,0},
		$item[chili powder cutlass]:		{5,0,1,0,0,0},
		$item[cursed aztec tamale]:		{2,0,0,0,0,0},
		$item[jolly roger tattoo kit]:		{0,6,1,1,0,6},
		$item[golden pet rock]:			{0,0,0,0,0,7},
		$item[groggles]:			{0,6,0,0,0,0},
		$item[pirate dinghy]:			{0,0,1,1,1,0},
		$item[anchor bomb]:			{0,1,3,1,0,1},
		$item[silky pirate drawers]:		{0,0,0,0,2,0},
		$item[spices]:				{1,0,0,0,0,0},
	};
}
int[int] c2t_takerSpace_relay_currency() {
	return int[int]{
		get_property("takerSpaceSpice").to_int(),
		get_property("takerSpaceRum").to_int(),
		get_property("takerSpaceAnchor").to_int(),
		get_property("takerSpaceMast").to_int(),
		get_property("takerSpaceSilk").to_int(),
		get_property("takerSpaceGold").to_int(),
	};
}
boolean c2t_takerSpace_relay_canAfford(int[int] currency,int[int] cost) {
	foreach i,x in currency
		if (x < cost[i])
			return false;
	return true;
}
string[int] c2t_takerSpace_relay_key() {
	return string[int]{
		"spice",
		"rum",
		"anchor",
		"mast",
		"silk",
		"gold",
	};
}
item[int] c2t_takerSpace_relay_order() {
	return item[int]{
		$item[deft pirate hook],
		$item[iron tricorn hat],
		$item[jolly roger flag],
		$item[sleeping profane parrot],
		$item[pirrrate's currrse],
		$item[tankard of spiced rum],
		$item[tankard of spiced goldschlepper],
		$item[packaged luxury garment],
		$item[harpoon],
		$item[chili powder cutlass],
		$item[cursed aztec tamale],
		$item[jolly roger tattoo kit],
		$item[golden pet rock],
		$item[groggles],
		$item[pirate dinghy],
		$item[anchor bomb],
		$item[silky pirate drawers],
		$item[spices],
	};
}

