class Town
{
  id = 0;
  max_population = 0;
  is_city = 0;

  constructor(town_id) {
    this.id = town_id;
    this.is_city = GSTown.IsCity(this.id);
  }

  function Initialise() {
    this.max_population = this.GetSize();
  }

  function InitialiseWithSize(max_size)
  {
    this.max_population = max_size;
  }

  function GetId()
  {
    return this.id;
  }

  function GetMaxPopulation()
  {
    return this.max_population;
  }

  function GetSize()
  {
    if(this.is_city)
    {
      return 0;
    }

    local min_town_size = GSController.GetSetting("min_town_size");
    local max_town_size = GSController.GetSetting("max_town_size");

    local intended_size = min_town_size + GSBase.RandRange(1 + (max_town_size - min_town_size));
    local current_population = GSTown.GetPopulation(this.id);

    if(current_population > intended_size) {
      intended_size = current_population;
    }

    return intended_size;
  }

  function GetGrowthProspectString(current_population)
  {
    if(this.is_city) {
      return GSText(GSText.STR_GROWTH_UNLIMITED);
    }

    local percentage = (this.max_population - current_population) / (max(current_population / 100, 1));

    if(percentage > 100) {
      return GSText(GSText.STR_GROWTH_OUTSTANDING);
    }

    if(percentage > 60) {
      return GSText(GSText.STR_GROWTH_EXCELLENT);
    }

    if(percentage > 30) {
      return GSText(GSText.STR_GROWTH_VERYGOOD);
    }

    if(percentage > 20) {
      return GSText(GSText.STR_GROWTH_GOOD);
    }

    if(percentage > 10) {
      return GSText(GSText.STR_GROWTH_MEDIOCRE);
    }

    if(percentage > 5) {
      return GSText(GSText.STR_GROWTH_POOR);
    }

    if(percentage > 0) {
      return GSText(GSText.STR_GROWTH_VERYPOOR);
    }

    return GSText(GSText.STR_GROWTH_NONE);
  }

  function Process()
  {
    local current_population = GSTown.GetPopulation(this.id);

    // If the player is funding buildings and we hit the limit then we increase the maximum population by 20% + 1
    // over the current population
    if(current_population >= this.max_population && GSTown.GetFundBuildingsDuration(this.id) > 0)
    {
      this.max_population = ((current_population * 12) / 10) + 1;
    }

    // Change growth metric based on maximum population
    if(current_population >= this.max_population)
    {
      GSTown.SetGrowthRate(this.id, GSTown.TOWN_GROWTH_NONE);
    }
    else
    {
      if(GSController.GetSetting("grow_like_crazy")) {
        GSTown.SetGrowthRate(this.id, 1);
      }
      else
      {
        GSTown.SetGrowthRate(this.id, GSTown.TOWN_GROWTH_NORMAL);
      }
    }

    local text = this.GetGrowthProspectString(current_population);
    GSTown.SetText(this.id, text);
  }
}
