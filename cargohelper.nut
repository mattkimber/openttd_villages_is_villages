class CargoHelper
{
    mail_cargo = null;
    pass_cargo = null;

    constructor() 
    {
        this.mail_cargo = EvaluateCargo(GSCargo.CC_MAIL, GSCargo.TE_MAIL);
        this.pass_cargo = EvaluateCargo(GSCargo.CC_PASSENGERS, GSCargo.TE_PASSENGERS);
    }

    function GetPAXCargo() 
    {
        return this.pass_cargo;
    }

    function GetMailCargo()
    {
        return this.mail_cargo;
    }

    function EvaluateCargo(cargo_flag, town_flag) 
    {
        local cargo_list = GSCargoList();
        cargo_list.Valuate(GSCargo.HasCargoClass, cargo_flag);
		cargo_list.KeepValue(1);
		cargo_list.Valuate(GSCargo.GetTownEffect);
		cargo_list.KeepValue(town_flag);

        if(cargo_list.Count() < 1) {
            GSLog.Error("No cargo found for flag " + cargo_flag);
            return -1;
        }

        return cargo_list.Begin();
    }
}