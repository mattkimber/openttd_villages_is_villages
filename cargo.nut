class Cargo
{

  setting = "";
  id = 0;

  function Setting()
  {
    return this.setting;
  }

  function Id()
  {
    return this.id;
  }

  constructor(cargo_id, cargo_setting)
  {
    this.id = cargo_id;
    this.setting = cargo_setting;
  }
}
