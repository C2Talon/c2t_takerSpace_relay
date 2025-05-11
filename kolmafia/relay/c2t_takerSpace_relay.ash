//c2t takerSpace relay
//c2t


//returns modified page for the relay browser
string c2t_takerSpace_relay(string page);

//returns html of a button for the item
string c2t_takerSpace_relay_button(item ite);

//returns modified page with display of item amounts of each item added
buffer c2t_takerSpace_relay_itemAmount(buffer page);

//returns modified page with buttons disabled of items player cannot afford
buffer c2t_takerSpace_relay_disableUnaffordable(buffer page);

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
	string mod;
	foreach i,x in c2t_takerSpace_relay_order()
		if (!create_matcher(`<div style="margin-right: 1em">\\s*{x.name}<br`,page).find())
			mod += c2t_takerSpace_relay_button(x);
	if (mod != "") {
		mod = '<hr /><b>TakerSpace Formulas Unhidden:</b><br />' + mod;
		string replace = '<p><a href="campground.php">Back to Campground</a>';
		out.replace_string(replace,mod+replace);
	}
	out = out.c2t_takerSpace_relay_itemAmount();
	out = out.c2t_takerSpace_relay_disableUnaffordable();
	return out;
}
string c2t_takerSpace_relay_button(item ite) {
	buffer out;
	int[int] cost = c2t_takerSpace_relay_cost()[ite];
	string[int] key = c2t_takerSpace_relay_key();

	out.append('<form method="post" action="choice.php">');
	out.append(`<input type="hidden" name="pwd" value="{my_hash()}" />`);
	out.append('<input type="hidden" name="option" value="1" />');
	out.append('<input type="hidden" name="whichchoice" value="1537" />');
	foreach i,x in key
		out.append(`<input type="hidden" name="{x}" value="{cost[i]}" />`);
	out.append('<div style="display: flex"><button class="button" type="submit" style="display: flex"><div style="margin-right: 1em">');
	out.append(`{ite.name}<br />`);
	foreach i,x in key
		out.append((i == 0 ? "" : ", ") + `{cost[i]} {x}`);
	out.append("</div>");
	out.append(`<img src="/images/itemimages/{ite.image}" align="absmiddle" />`);
	out.append("</button>");
	out.append(`<img src="/images/itemimages/magnify.gif" align="absmiddle" onclick="descitem('{ite.descid}')" height="30" width="30" />`);
	out.append("</div></form>");

	return out;
}
buffer c2t_takerSpace_relay_itemAmount(buffer page) {
	buffer out = page;
	matcher mat;
	foreach i,x in c2t_takerSpace_relay_order() {
		mat = create_matcher(`(<div style="margin-right: 1em">\\s*{x.name})(<br)`,out);
		if (mat.find())
			out.replace_string(mat.group(0),`{mat.group(1)} <span style="color:#00f">(have:&nbsp;{item_amount(x)})</span>{mat.group(2)}`);
	}
	return out;
}
buffer c2t_takerSpace_relay_disableUnaffordable(buffer page) {
	int[int] currency = c2t_takerSpace_relay_currency();
	int[item,int] cost = c2t_takerSpace_relay_cost();
	matcher mat;
	foreach i,x in c2t_takerSpace_relay_order() {
		if (!c2t_takerSpace_relay_canAfford(currency,cost[x])) {
			mat = create_matcher(`(<button class="button" type="submit" style="display: flex")(>\\s*<div style="margin-right: 1em">\\s*)({x.name} <span[^>]*>[^<]*</span>[^<]*<br[^>]*>[^<]*)(</div>\\s*<img[^>]+)>`,page);
			if (mat.find())
				page.replace_string(mat.group(0),`{mat.group(1)}{mat.group(2)}<span style="opacity:0.5;">{mat.group(3)}</span>{mat.group(4)} style="opacity:0.5;" />`);
		}
	}
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

