require("towns.nut");
require("town.nut");
require("industries.nut");
require("industry.nut");
require("cargoes.nut");
require("cargo.nut");
require("economy.nut");
require("company.nut");
require("cargohelper.nut");

class VillagesIsVillages extends GSController
{
  data_loaded = false;
  towns = null;
  industries = null;
  cargoes = null;
  economy = null;
  total_towns_processed = 0;

  constructor()
  {
    GSLog.Info("Starting Villages Is Villages...")
    this.cargoes = Cargoes();
  }
}

function VillagesIsVillages::Start()
{
  GSLog.Info("Villages Is Villages has started");

  if(!this.data_loaded)
  {
    GSLog.Info("Initialising towns");

    // Start with no  previous tax year
    this.economy = Economy(null);

    this.towns = Towns(cargoes);
    this.towns.UpdateTownList();


    GSLog.Info("Number of towns managed: " + this.towns.Count());
  }



  this.industries = Industries();

  if(GSController.GetSetting("manage_industries"))
  {
    if(!GSGameSettings.IsValid("difficulty.industry_density"))
    {
      GSLog.Error("Cannot manage industries - industry funding level setting not found");
      return;
    }
    this.industries.Initialise();
    GSLog.Info("Number of industries managed: " + this.industries.Count());
  }
  else
  {
    GSLog.Info("Not managing industries.")
  }

  local last_industry_process_tick = this.GetTick() - 750;
  local last_town_complete_tick = this.GetTick() - 750;


  while (true) {
    this.Sleep(1);
 
    if(GSController.GetSetting("manage_economy"))
    {
      this.economy.Process();
      
      if(GSController.GetSetting("manage_economy")) {
        local max_additional_world_population = this.economy.GetMaxAdditionalWorldPopulation();
        local max_city_population = this.economy.GetMaxCityPopulation();
        this.towns.UpdateWorldPopulation(max_additional_world_population, max_city_population);
      } else {
        this.towns.EnableUnlimitedWorldGrowth();
      }
    }

    if(this.GetTick() > last_town_complete_tick + 740)
    {
      local i = 0;
      local town_count = towns.Count();
      local end_town_processing_tick = this.GetTick() + 70;

      while(i < town_count && this.GetTick() < end_town_processing_tick)
      {
        this.towns.ProcessNextTown();
        i++;
      }

      this.total_towns_processed = this.total_towns_processed + i;

      if(this.total_towns_processed >= town_count) {
        this.total_towns_processed = 0;
        this.towns.UpdateTownList();
        last_town_complete_tick = this.GetTick();
        this.Sleep(1);
      }
    }

    if(GSController.GetSetting("manage_industries") && this.GetTick() > last_industry_process_tick + 740)
    {
      this.Sleep(1);
      this.industries.Process();
      last_industry_process_tick = this.GetTick();
    }

    // Process any events which happened while we were sleeping
    while(GSEventController.IsEventWaiting())
    {
      local event = GSEventController.GetNextEvent();
      if(event != null)
      {
        if(event.GetEventType() == GSEvent.ET_TOWN_FOUNDED)
        {
          local townEvent = GSEventTownFounded.Convert(event);
          this.towns.AddTown(townEvent.GetTownID());
        }

        if(event.GetEventType() == GSEvent.ET_COMPANY_NEW)
        {
          local companyEvent = GSEventCompanyNew.Convert(event);
          this.economy.AddCompany(companyEvent.GetCompanyID());
        }

        if(event.GetEventType() == GSEvent.ET_COMPANY_MERGER)
        {
          local companyEvent = GSEventCompanyMerger.Convert(event);
          this.economy.RemoveCompanyIfExists(companyEvent.GetOldCompanyID());
        }

        if(event.GetEventType() == GSEvent.ET_COMPANY_BANKRUPT)
        {
          local companyEvent = GSEventCompanyBankrupt.Convert(event);
          this.economy.RemoveCompanyIfExists(companyEvent.GetCompanyID());
        }
      }
    }
  }
}

function VillagesIsVillages::Save()
{
  local townData = [];
  local cache = [];

  foreach(t in towns.GetTownList())
  {
    townData.append({ id = t.GetId(), max_population = t.GetMaxPopulation() });
    if (GSController.GetOpsTillSuspend() < 200) {
      GSLog.Warning("Not enough opcodes to process town array, cannot save complete town data. Try increasing the '#opcodes before scripts are suspended' setting.")
      GSLog.Info("Attempting to use town data cache...")
      cache = towns.GetTownCache();
      if (cache.len() > townData.len()) {
        GSLog.Info("Success!")
        townData = cache
      } else {
        GSLog.Warning("Cache has not been populated yet (not all towns have been processed in this game session). Please wait longer before saving, so all towns can be processed at least once.")
      }
      break;
    }
  }

  GSLog.Info("Town data: " + townData.len() + " towns saved.");

  return { towns = townData, baseline_population = towns.GetBaselinePopulation(), economy = economy.GetSaveData() };
}

function VillagesIsVillages::Load(version, data)
{
  local townData = [];
  local baseline_population = 0;

  if(data.rawin("economy")) {
    local economy_data = data.rawget("economy");
    this.economy = Economy(economy_data);
  } else {
    this.economy = Economy(null);
  }

  if(data.rawin("baseline_population")) {
    baseline_population = data.baseline_population;
  }

  if(data.rawin("towns")) {
    townData = data.rawget("towns");

    this.towns = Towns(cargoes);
    towns.SetTownData(townData, baseline_population);

    GSLog.Info("Town data: " + townData.len() + " towns loaded.");

    this.data_loaded = true;
  }
}
