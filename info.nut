SELF_VERSION <- 4;
SELF_DATE <- "2016-04-27";

class VillagesIsVillages extends GSInfo {
  function GetAuthor()	      { return "Timberwolf"; }
  function GetName()			    { return "Villages Is Villages"; }
  function GetDescription()   { return "Keep villages as villages! Stops every village from growing into a metropolis, and prevents industries from taking over the map."; }
  function GetVersion()		    { return SELF_VERSION; }
  function GetDate()			    { return SELF_DATE; }
  function CreateInstance()	  { return "VillagesIsVillages"; }
  function GetShortName()		  { return "VIsV"; }
  function GetAPIVersion()	  { return "1.5"; }
  function GetUrl()			      { return "https://github.com/mattkimber/openttd_villages_is_villages"; }
  function GetSettings()
  {
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
      step_size = 50
    });
    AddSetting({
      name = "max_town_size",
      description = "Maximum size of largest non-city",
      easy_value = 15000,
      medium_value = 10000,
      hard_value = 5000,
      custom_value = 5000,
      flags = 0,
      min_value = 1000,
      max_value = 25000,
      step_size = 1000
    });
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
      flags = CONFIG_BOOLEAN
    });
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
      name = "display_text",
      description = "Show growth statistics in town window",
      easy_value = 1,
      medium_value = 1,
      hard_value = 1,
      custom_value = 1,
      flags = CONFIG_BOOLEAN
    });
    AddSetting({
      name = "growth_goods",
      description = "Maximum town growth per 100 crates goods delivered"
      easy_value = 10,
      medium_value = 5,
      hard_value = 2,
      custom_value = 2,
      flags = CONFIG_INGAME,
      min_value = 0,
      max_value = 100,
      step_size = 1
    });
    AddSetting({
      name = "growth_building_materials",
      description = "Maximum town growth per 100 crates building materials delivered"
      easy_value = 20,
      medium_value = 10,
      hard_value = 5,
      custom_value = 5,
      flags = CONFIG_INGAME,
      min_value = 0,
      max_value = 100,
      step_size = 1
    });
    AddSetting({
      name = "growth_petrol",
      description = "Maximum town growth per 100 litres petroleum fuels delivered"
      easy_value = 20,
      medium_value = 10,
      hard_value = 5,
      custom_value = 5,
      flags = CONFIG_INGAME,
      min_value = 0,
      max_value = 100,
      step_size = 1
    });
    AddSetting({
      name = "growth_alcohol",
      description = "Maximum town growth per 100 litres alcohol delivered"
      easy_value = 5,
      medium_value = 2,
      hard_value = 1,
      custom_value = 1,
      flags = CONFIG_INGAME,
      min_value = 0,
      max_value = 100,
      step_size = 1
    });
    AddSetting({
      name = "growth_food",
      description = "Maximum town growth per 100 tons food delivered"
      easy_value = 5,
      medium_value = 2,
      hard_value = 1,
      custom_value = 1,
      flags = CONFIG_INGAME,
      min_value = 0,
      max_value = 100,
      step_size = 1
    });
  }
}

RegisterGS(VillagesIsVillages());
