class Town
{
  id = 0;
  max_population = 0;
  current_population = 0;
  is_city = 0;

  passenger_shortfall = 0;
  mail_shortfall = 0;

  most_needed_cargo = 0;
  biggest_cargo_effect = 0;

  last_passenger_shortfall = -1;
  last_mail_shortfall = -1;
  last_growth_prospect = -1;
  last_growth_state = GSTown.TOWN_GROWTH_NORMAL;
  last_needed_cargo = 0;
  use_cached_growth_value = false;

  next_cargo_process_tick = 0;

  cargoes = null;
  cargo_helper = null;


  constructor(town_id, cargo_class) {
    this.id = town_id;
    this.is_city = GSTown.IsCity(this.id);
    this.cargoes = cargo_class;
    this.cargo_helper = CargoHelper();
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

  function GetCurrentPopulation()
  {
    return this.current_population;
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

    local cargo_transported = GSTown.GetLastMonthTransportedPercentage(this.id, cargo_type);

    if(cargo_transported >= cargo_needed)
    {
      return 0;
    }

    local production = GSTown.GetLastMonthProduction(this.id, cargo_type);

    return ((cargo_needed - cargo_transported) * production) / 100;
  }

  function CanGrowOnPassengerAndMail()
  {
    this.last_passenger_shortfall = this.passenger_shortfall;
    this.last_mail_shortfall = this.mail_shortfall;

    this.passenger_shortfall = this.GetShortfall(this.cargo_helper.GetPAXCargo(), "min_pax_transported");
    this.mail_shortfall = this.GetShortfall(this.cargo_helper.GetMailCargo(), "min_mail_transported");

    return (this.passenger_shortfall <= 0 && this.mail_shortfall <= 0);
  }

  function ApplyCargoEffect(cargo_id, effect)
  {
    local cargo_delivered = 0;

    for(local company_id = GSCompany.COMPANY_FIRST; company_id <= GSCompany.COMPANY_LAST; company_id++) {
      cargo_delivered += GSCargoMonitor.GetTownDeliveryAmount(company_id, cargo_id, this.id, true);
		}

    if(this.max_population <= (this.current_population * 12) / 10) {
      if(cargo_delivered > 0) {
        this.max_population += (cargo_delivered * effect) / 100;
      } else if(effect > this.biggest_cargo_effect) {
        this.biggest_cargo_effect = effect;
        this.most_needed_cargo = cargo_id;
      }
    }
  }

  function ProcessDeliveredCargo()
  {
    this.last_needed_cargo = this.most_needed_cargo;
    this.biggest_cargo_effect = 0;
    this.most_needed_cargo = 0;

    foreach(cargo in cargoes.GetHandledCargoes())
    {
      local effect = GSController.GetSetting(cargo.Setting());

      if(effect > 0) {
        this.ApplyCargoEffect(cargo.Id(), effect);
      }
    }
  }

  function Expand(houses) {
    GSTown.ExpandTown(this.id, houses)
  }

  function CanGrowOnFinances(world_can_grow, max_city_population) 
  {
    // This is only enabled when managing the economy
    if(!GSController.GetSetting("manage_economy")) {
      return true;
    }

    if (this.is_city) {
      // Cities grow based on the dividend system
      return this.current_population < max_city_population;
    } 

    return world_can_grow
  }

  function Process(world_can_grow, max_world_population, max_city_population)
  {
    this.current_population = GSTown.GetPopulation(this.id);
    local new_growth_state = GSTown.TOWN_GROWTH_NONE;

    // If the player is funding buildings and we hit the limit then we increase the maximum population by 20% + 1
    // over the current population
    if(this.current_population >= this.max_population && GSTown.GetFundBuildingsDuration(this.id) > 0)
    {
      this.max_population = ((this.current_population * 12) / 10) + 1;
    }

    // Apply any population increases from delivered cargo if it's been 90 days or more since we last checked it
    if(GSController.GetTick() > this.next_cargo_process_tick)
    {
      this.next_cargo_process_tick = GSController.GetTick() + (90 * 74);
      this.ProcessDeliveredCargo();
    }

    if(this.CanGrowOnPassengerAndMail() && this.CanGrowOnPopulation() && CanGrowOnFinances(world_can_grow, max_city_population))
    {
      // Always grow the smallest towns to prevent them getting stuck at 0 population
      new_growth_state = this.current_population == 0 ? 10 : GSTown.TOWN_GROWTH_NORMAL;
      if (this.current_population == 0) {
        this.Expand(1)
      }
    }
  
    // SetGrowthRate is pretty slow so we only change it if
    // necessary - if it is actually different, or if this
    // is the first time we are changing after game load.
    if(!this.use_cached_growth_value || new_growth_state != this.last_growth_state) {
      GSTown.SetGrowthRate(this.id, new_growth_state);
      this.last_growth_state = new_growth_state;
      this.use_cached_growth_value = true;
    }

    if(GSController.GetSetting("display_text"))
    {
      this.SetTownText(world_can_grow, max_city_population);
    }
  }

  function SetTownText(world_can_grow, max_city_population)
  {
    local percentage = (this.max_population - this.current_population) / (max(current_population / 100, 1));

    if(
        percentage != this.last_growth_prospect ||
        this.passenger_shortfall != this.last_passenger_shortfall ||
        this.mail_shortfall != this.last_mail_shortfall ||
        this.most_needed_cargo != this.last_needed_cargo
      )
    {
      this.last_growth_prospect = percentage;

      local prospect_text = this.GetGrowthProspectString(percentage);
      local passenger_text = this.passenger_shortfall > 0 ? GSText(GSText.STR_PASSENGER_SHORTFALL, this.passenger_shortfall) : GSText(GSText.STR_PASSENGER_OK, this.passenger_shortfall);
      local mail_text = this.mail_shortfall > 0 ? GSText(GSText.STR_MAIL_SHORTFALL, this.mail_shortfall) : GSText(GSText.STR_MAIL_OK, this.mail_shortfall);

      local advice_text = this.GetTownGrowthAdviceString(world_can_grow, max_city_population);

      GSTown.SetText(this.id, GSText(GSText.STR_CONCAT_4, prospect_text, passenger_text, mail_text, advice_text));
    }
  }

  function GetTownGrowthAdviceString(world_can_grow, max_city_population)
  {
    if(!world_can_grow && !this.is_city && GSController.GetSetting("manage_economy")) {
      return GSText(GSText.STR_PAY_TAX);
    }

    if(this.is_city && this.current_population >= max_city_population && GSController.GetSetting("manage_economy")) {
      return GSText(GSText.STR_PAY_DIVIDEND);
    }

    if(this.passenger_shortfall > 0) {
      return GSText(GSText.STR_DELIVER_PASSENGERS);
    }

    if(this.mail_shortfall > 0) {
      return GSText(GSText.STR_DELIVER_MAIL);
    }

    if(this.last_growth_prospect > 0 || this.is_city) {
      return GSText(GSText.STR_NULL);
    }

    if(this.most_needed_cargo != 0) {
      return GSText(GSText.STR_DELIVER_CARGO, 1 << this.most_needed_cargo);
    }

    return GSText(GSText.STR_FUND_BUILDINGS);
  }

  // TODO: find a nicer, less boilerplatey way of doing this
  function GetGrowthProspectString(percentage)
  {
    if(this.is_city) {
      return GSText(GSText.STR_GROWTH_UNLIMITED);
    }

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
