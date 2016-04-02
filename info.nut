SELF_VERSION <- 1;
SELF_DATE <- "2016-03-30";

class VillagesIsVillages extends GSInfo {
function GetAuthor()		{ return "Timberwolf"; }
function GetName()			{ return "Villages Is Villages"; }
function GetDescription() 	{ return "Sets growth limits on random towns to keep some villages as villages."; }
function GetVersion()		{ return SELF_VERSION; }
function GetDate()			{ return SELF_DATE; }
function CreateInstance()	{ return "VillagesIsVillages"; }
function GetShortName()		{ return "VIsV"; }
function GetAPIVersion()	{ return "1.6"; }
function GetUrl()			{ return ""; }
function GetSettings() {
  AddSetting({
    name = "min_town_size",
    description = "Maximum size of smallest village",
    easy_value = 500,
    medium_value = 250,
    hard_value = 100,
    custom_value = 100,
    flags = 0,
    min_value = 50,
    max_value = 5000,
    step_size = 50});
  AddSetting({
    name = "max_town_size",
    description = "Maximum size of largest non-city",
    easy_value = 15000,
    medium_value = 10000,/gam
    hard_value = 5000,
    custom_value = 5000,
    flags = 0,
    min_value = 1000,
    max_value = 25000,
    step_size = 1000});
  AddSetting({
    name = "min_pax_transported",
    description = "Percentage of passengers to transport for town to grow"
    easy_value = 0,
    medium_value = 25,
    hard_value = 50,
    custom_value = 50,
    flags = CONFIG_INGAME,
    min_value = 0,
    max_value = 100,
    step_size = 5
  });
  AddSetting({
    name = "min_mail_transported",
    description = "Percentage of mail to transport for town to grow"
    easy_value = 0,
    medium_value = 25,
    hard_value = 50,
    custom_value = 50,
    flags = CONFIG_INGAME,
    min_value = 0,
    max_value = 100,
    step_size = 5
  });
  AddSetting({
    name = "manage_industries",
    description = "Manage industries (experimental)",
    easy_value = 0,
    medium_value = 0,
    hard_value = 0,
    custom_value = 0,
    flags = CONFIG_BOOLEAN});
  AddSetting({
      name = "min_cargo_transported",
      description = "Percentage of cargo to transport from an industry"
      easy_value = 25,
      medium_value = 50,
      hard_value = 75,
      custom_value = 75,
      flags = CONFIG_INGAME,
      min_value = 0,
      max_value = 100,
      step_size = 5
    });
  AddSetting({
      name = "min_industries_served",
      description = "Percentage of industries which must be served"
      easy_value = 25,
      medium_value = 50,
      hard_value = 75,
      custom_value = 75,
      flags = CONFIG_INGAME,
      min_value = 0,
      max_value = 100,
      step_size = 5
    });
  AddSetting({
      name = "grow_like_crazy",
      description = "Towns grow like crazy until limit is reached (debug mode)",
      easy_value = 0,
      medium_value = 0,
      hard_value = 0,
      custom_value = 0,
      flags = CONFIG_BOOLEAN});
    AddLabels("grow_like_crazy", {_0 = "Disabled", _1 = "Enabled"});
}

RegisterGS(VillagesIsVillages());
