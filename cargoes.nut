class Cargoes
{
  has_goods = false;
  has_building_materials = false;
  has_alcohol = false;

  goods_id = 0;
  building_materials_id = 0;
  alcohol_id = 0;

  constructor()
  {
    foreach(c, _ in GSCargoList())
    {
      local label = GSCargo.GetCargoLabel(c);

      if(label == "BDMT") {
        GSLog.Info("Building materials are available");
        this.has_building_materials = true;
        this.building_materials_id = c;
      }
      else if(label == "GOOD") {
        GSLog.Info("Goods are available");
        this.has_goods = true;
        this.goods_id = c;
      }
      else if(label == "BEER") {
        GSLog.Info("Alcohol is available");
        this.has_alcohol = true;
        this.alcohol_id = c;
      }

    }
  }

}
