class Industry
{
  id = 0;

  constructor(industry_id)
  {
    this.id = industry_id;
  }

  function IsValid()
  {
    return GSIndustry.IsValidIndustry(this.id);
  }

  function IsServed()
  {
    local is_served = false;

    // Calculate if the industry is considered to be "served"

    // Check if the industry produces anything
    local industry_type = GSIndustry.GetIndustryType(this.id);

    local max_production = 0;
    local max_served_percentage = 0;

    foreach(c, _ in GSIndustryType.GetProducedCargo(industry_type))
    {
      local production = GSIndustry.GetLastMonthProduction(this.id, c);

      if(production > max_production) {
        max_production = production;
      }

      if(production > 0)
      {
        local served_percentage = (GSIndustry.GetLastMonthTransported(this.id, c) * 100) / production;
        if(served_percentage > max_served_percentage) {
          max_served_percentage = served_percentage;
        }
      }
    }

    if(max_production > 0)
    {
      // Producing industries must have > x % of cargo transported to be
      // considered served
      is_served = (max_served_percentage >= GSController.GetSetting("min_cargo_transported"));
    }
    else
    {
      // Non-producing industries (sinks or dormant factories) must have a station
      // nearby to be considered served (this is a limitation of the NoGo library,
      // we can't tell anything more useful about an industry which doesn't
      // produce anything)
      is_served = (GSIndustry.GetAmountOfStationsAround(this.id) > 0);
    }

    return is_served;
  }
}
