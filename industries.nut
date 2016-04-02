class Industries
{
  industries_served = 0;
  current_industry = 0;

  is_enabled = false;
  industry_list = [];

  spawn_was_enabled = true;

  constructor()
  {

  }

  function Count()
  {
    return industry_list.len();
  }

  function IsIndustrySpawningAllowed()
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

  function ProcessNextIndustry()
  {
    if(!is_enabled || this.industry_list.len() == 0)
    {
      return;
    }

    local industry = industry_list[current_industry];

    if(!industry.IsValid()) {
      return;
    }

    local is_served = industry.IsServed();

    if(is_served)
    {
      this.industries_served++;
    }

    current_industry++;

    if(current_industry >= industry_list.len())
    {
      this.UpdateGameSetting();

      current_industry = 0;
      this.industries_served = 0;

      // Industry open/close events don't capture player actions so we
      // rebuild the list on each iteration through.
      this.industry_list = [];
      this.BuildIndustryList();
    }
  }

  function UpdateGameSetting()
  {
    if(IsIndustrySpawningAllowed())
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
  }

  function AddIndustry(industry_id)
  {
    local industry = Industry(industry_id);
    this.industry_list.append(industry);
  }

}
