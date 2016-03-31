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
function GetAPIVersion()	{ return "1.5"; }
function GetUrl()			{ return ""; }
function GetSettings() {
  AddSetting({
    name = "min_town_size",
    description = "Maximum size of smallest village",
    easy_value = 500,
    medium_value = 250,
    hard_value = 100,
    custom_value = 100,
    flags = CONFIG_INGAME,
    min_value = 0,
    max_value = 5000,
    step_size = 50});
  AddSetting({
    name = "max_town_size",
    description = "Maximum size of largest non-city",
    easy_value = 15000,
    medium_value = 10000,
    hard_value = 5000,
    custom_value = 5000,
    flags = CONFIG_INGAME,
    min_value = 0,
    max_value = 25000,
    step_size = 1000});
    }
}

RegisterGS(VillagesIsVillages());
