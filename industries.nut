class Industries
{
  next_list_rebuild_tick = 0;

  is_enabled = false;
  industry_list = [];

  spawn_was_enabled = true;

  constructor()
  {
    // Rebuild industry list approximately every 3 momths
    this.next_list_rebuild_tick = GSController.GetTick() + (74 * 30 * 3);
  }

  function Count()
  {
    return industry_list.len();
  }

  function IsIndustrySpawningAllowed(industries_served)
  {
    // If we have no industries then spawning is allowed by default
    if(this.industry_list.len() == 0)
    {
      return true;
    }

    // If > n% of industries are served then the game can spawn,
    // otherwise set the options to funding-only
    return ((industries_served * 100) / this.industry_list.len() >= GSController.GetSetting("min_industries_served"))
  }

  function Process()
  {
    local industries_served = 0;

    if(!is_enabled || this.industry_list.len() == 0)
    {
      return;
    }

    foreach(industry in industry_list)
    {

      if(!industry.IsValid()) {
        return;
      }

      if(industry.IsServed())
      {
        industries_served++;
      }
    }

    this.UpdateGameSetting(industries_served);

    if(GSController.GetTick() >= this.next_list_rebuild_tick)
    {
      // Industry open/close events don't capture player actions so we
      // rebuild the list after several iterations.
      this.industry_list = [];
      this.BuildIndustryList();
      this.next_list_rebuild_tick = GSController.GetTick() + (74 * 30 * 3);
    }

  }

  function UpdateGameSetting(industries_served)
  {
    if(IsIndustrySpawningAllowed(industries_served))
    {
      if(!this.spawn_was_enabled)
      {
        GSLog.Info("Enabling industry spawn");
        GSGameSettings.SetValue("difficulty.industry_density", 4);
      }
      this.spawn_was_enabled = true;
    }
    else
    {
      if(this.spawn_was_enabled)
      {
        GSLog.Info("Disabling industry spawn");
        GSGameSettings.SetValue("difficulty.industry_density", 0);
      }
      this.spawn_was_enabled = false;
    }
  }

  function Initialise()
  {
    this.is_enabled = true;
    BuildIndustryList();
  }

  function BuildIndustryList()
  {
    local industries = GSIndustryList();

    foreach(i, _ in industries)
    {
      this.AddIndustry(i);
    }

    // GSLog.Info("(Re-)built industry list for " + industry_list.len() + " industries");

  }

  function AddIndustry(industry_id)
  {
    local industry = Industry(industry_id);
    this.industry_list.append(industry);
  }

}
