class Economy 
{
    last_tax_year = -1;
    last_infrastructure_month = -1;
    companies_list = [];

    constructor(economy_data)
    {  
        if(economy_data == null) {
            this.last_tax_year = -1;
            this.last_infrastructure_month = -1;
            for(local c = GSCompany.COMPANY_FIRST; c <= GSCompany.COMPANY_LAST; c++) {
                AppendCompany(c);       
            }
        } else {
            this.last_tax_year = economy_data.tax_year;
            this.last_infrastructure_month = economy_data.infrastructure_month;
            foreach(company in economy_data.companies) 
            {
                this.companies_list.append(Company(company.id, company.bank_bal, company.loan));
            }
        }
    }

    function AddCompany(id)
    {
        RemoveCompanyIfExists(id);
        AppendCompany(id);
    }

    function RemoveCompanyIfExists(id) 
    {
        for(local i = 0; i < this.companies_list.len(); i++) {
            if(this.companies_list[i].GetID() == id) {
                this.companies_list.remove(i);
            }
        }
    }

    function AppendCompany(id)
    {
        if(GSCompany.ResolveCompanyID(id) != GSCompany.COMPANY_INVALID) {
            local mode = GSCompanyMode(id);
            this.companies_list.append(Company(id, GSCompany.GetBankBalance(id),  GSCompany.GetLoanAmount()));
        }
    }

    function GetTaxYear()
    {
        return last_tax_year;
    }

    function GetSaveData()
    {
        local data = {};
        data.tax_year <- this.last_tax_year;
        data.infrastructure_month <- this.last_infrastructure_month;
        data.companies <- [];

        foreach(company in this.companies_list) {
            data.companies.append(company.GetSaveData());
        }

        return data;
    }

    function ProcessInfrastructureCosts()
    {
        if(GSDate.GetMonth(GSDate.GetCurrentDate()) == last_infrastructure_month) {
            return;
        }

        foreach(company in this.companies_list) {
            company.ApplyInfrastructureCost();
        }

        last_infrastructure_month = GSDate.GetMonth(GSDate.GetCurrentDate());
    }
    
    function ProcessCorporationTax()
    {
        if(GSDate.GetYear(GSDate.GetCurrentDate()) == last_tax_year) {
            return;
        }

        foreach(company in this.companies_list) {
            company.ApplyTax();
        }

        last_tax_year = GSDate.GetYear(GSDate.GetCurrentDate());
    }

    function Process()
    {
        if(GSGameSettings.IsValid("infrastructure_maintenance") && GSGameSettings.GetValue("infrastructure_maintenance")) {
            ProcessInfrastructureCosts();
        }
        ProcessCorporationTax();
    }
}