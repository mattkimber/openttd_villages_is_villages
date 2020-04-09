class Economy 
{
    last_process_year = -1;
    last_process_month = -1;
    companies_list = [];

    constructor(economy_data)
    {  
        if(economy_data == null) {
            this.last_process_year = -1;
            this.last_process_month = -1;
            for(local c = GSCompany.COMPANY_FIRST; c <= GSCompany.COMPANY_LAST; c++) {
                AppendCompany(c);       
            }
        } else {
            this.last_process_year = economy_data.tax_year;
            this.last_process_month = economy_data.infrastructure_month;
            foreach(company in economy_data.companies) 
            {
                if(!("dividend_rate" in company)) company.dividend_rate <- 0;
                this.companies_list.append(Company(company.id, company.bank_bal, company.loan, company.dividend_rate));
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
            this.companies_list.append(Company(id, GSCompany.GetBankBalance(id),  GSCompany.GetLoanAmount(), 0));
        }
    }

    function GetTaxYear()
    {
        return last_process_year;
    }

    function GetSaveData()
    {
        local data = {};
        data.tax_year <- this.last_process_year;
        data.infrastructure_month <- this.last_process_month;
        data.companies <- [];

        foreach(company in this.companies_list) {
            data.companies.append(company.GetSaveData());
        }

        return data;
    }

    function ProcessMonthly()
    {
        if(GSDate.GetMonth(GSDate.GetCurrentDate()) == last_process_month) {
            return;
        }

        if(GSGameSettings.IsValid("infrastructure_maintenance") && GSGameSettings.GetValue("infrastructure_maintenance")) {
            ProcessInfrastructureCosts();
        }

        last_process_month = GSDate.GetMonth(GSDate.GetCurrentDate());
    }

    function ProcessInfrastructureCosts()
    {
        foreach(company in this.companies_list) {
            company.ApplyInfrastructureCost();
        }
    }
    
    function ProcessTaxAndDividends()
    {
        foreach(company in this.companies_list) {
            company.ApplyTaxAndDividends();
        }
    }

    function ProcessAnnual()
    {
        if(GSDate.GetYear(GSDate.GetCurrentDate()) == last_process_year) {
            return;
        }

        ProcessTaxAndDividends();
        last_process_year = GSDate.GetYear(GSDate.GetCurrentDate());
    }

    function Process()
    {

        ProcessAnnual();
    }
}