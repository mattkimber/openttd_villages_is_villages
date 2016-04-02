class Town
{
  id = 0;
  max_population = 0;
  current_population = 0;
  is_city = 0;

  passenger_shortfall = 0;
  mail_shortfall = 0;

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
    this.current_population = GSTown.GetPopulation(this.id);

    if(this.current_population > intended_size) {
      intended_size = this.current_population;
    }

    return intended_size;
  }

  function CanGrowOnPopulation()
  {
    // No population limit on cities
    if(this.is_city)
    {
      return true;
    }

    local current_population = GSTown.GetPopulation(this.id);

    // If the player is funding buildings and we hit the limit then we increase the maximum population by 20% + 1
    // over the current population
    if(this.current_population >= this.max_population && GSTown.GetFundBuildingsDuration(this.id) > 0)
    {
      this.max_population = ((this.current_population * 12) / 10) + 1;
    }

    return (this.max_population > this.current_population);
  }

  function GetShortfall(cargo_type, config_setting)
  {
    local cargo_needed = GSController.GetSetting(config_setting);

    if(cargo_needed == 0)
    {
      return 0;
    }

    local cargo_transported = GSTown.GetLastMonthTransportedPercentage (this.id, cargo_type);

    if(cargo_transported >= cargo_needed)
    {
      return 0;
    }

    local production = GSTown.GetLastMonthProduction(this.id, cargo_type);

    return ((cargo_needed - cargo_transported) * production) / 100;
  }

  function CanGrowOnCargo()
  {
    this.passenger_shortfall = GetShortfall(Helper.GetPAXCargo(), "min_pax_transported");
    this.mail_shortfall = GetShortfall(Helper.GetMailCargo(), "min_mail_transported");

    return (this.passenger_shortfall <= 0 && this.mail_shortfall <= 0);
  }

  function Process()
  {
    this.current_population = GSTown.GetPopulation(this.id);

    // If the player is funding buildings and we hit the limit then we increase the maximum population by 20% + 1
    // over the current population
    if(this.current_population >= this.max_population && GSTown.GetFundBuildingsDuration(this.id) > 0)
    {
      this.max_population = ((this.current_population * 12) / 10) + 1;
    }

    if(this.CanGrowOnPopulation() && this.CanGrowOnCargo())
    {
      // Always grow the smallest towns to prevent them getting stuck at 0 population
      if(this.current_population == 0)
      {
        GSTown.SetGrowthRate(this.id, 10);
      }
      else if(GSController.GetSetting("grow_like_crazy"))
      {
        GSTown.SetGrowthRate(this.id, 1);
      }
      else
      {
        GSTown.SetGrowthRate(this.id, GSTown.TOWN_GROWTH_NORMAL);
      }
    }
    else
    {
      GSTown.SetGrowthRate(this.id, GSTown.TOWN_GROWTH_NONE);
    }

    SetTownText();
  }

  function SetTownText()
  {
    local prospect_text = this.GetGrowthProspectString();
    local passenger_text = this.passenger_shortfall > 0 ? GSText(GSText.STR_PASSENGER_SHORTFALL, this.passenger_shortfall) : GSText(GSText.STR_PASSENGER_OK, this.passenger_shortfall);
    local mail_text = this.mail_shortfall > 0 ? GSText(GSText.STR_MAIL_SHORTFALL, this.mail_shortfall) : GSText(GSText.STR_MAIL_OK, this.mail_shortfall);

    GSTown.SetText(this.id, GSText(GSText.STR_CONCAT_3, prospect_text, passenger_text, mail_text));
  }

  function GetGrowthProspectString()
  {
    if(this.is_city) {
      return GSText(GSText.STR_GROWTH_UNLIMITED);
    }

    local percentage = (this.max_population - this.current_population) / (max(current_population / 100, 1));

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

}
