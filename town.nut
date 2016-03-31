class Town
{
  id = 0;
  location = 0;
  max_population = 0;

  constructor(town_id) {
    this.id = town_id;
    this.location = GSTown.GetLocation(this.id);
    this.max_population = this.GetSize();
  }

  function GetSize()
  {
    local min_town_size = GSController.GetSetting("min_town_size");
    local max_town_size = GSController.GetSetting("max_town_size");

    local intended_size = min_town_size + ((max_town_size - min_town_size) * (this.location % 101) / 100);
    local current_population = GSTown.GetPopulation(this.id);

    if(current_population > intended_size) {
      intended_size = current_population;
    }

    return intended_size;
  }

  function Process()
  {
    local current_population = GSTown.GetPopulation(this.id);

    if(current_population >= this.max_population)
    {
      GSTown.SetGrowthRate(this.id, GSTown.TOWN_GROWTH_NONE);
    }
    else
    {
      GSTown.SetGrowthRate(this.id, 1);
    }

    local text = GSText(GSText.STR_POP_LIMIT, this.max_population);
    GSTown.SetText(this.id, text);
  }
}
