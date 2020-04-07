class Company 
{
    bank_bal_last_year = 0;
    loan_last_year = 0;
    id = -1;

    constructor(id, bank_bal, loan)
    {
        this.bank_bal_last_year = bank_bal;
        this.loan_last_year = loan;
        this.id = id;
    }

    function GetSaveData()
    {
        return { bank_bal = this.bank_bal_last_year, loan = this.loan_last_year, id = this.id };
    }

    function GetID()
    {
        return this.id;
    }

    function GetLoan()
    {
        local mode = GSCompanyMode(id);
        return GSCompany.GetLoanAmount();
    }

    function ApplyTax()
    {
        if(GSCompany.ResolveCompanyID(this.id) == GSCompany.COMPANY_INVALID) {
            GSLog.Error("Attempt to resolve tax for invalid company");
            return;
        }

        local bank_bal_this_year = GSCompany.GetBankBalance(this.id);
        local loan_this_year = this.GetLoan();

        local profit = (bank_bal_this_year - loan_this_year) - (bank_bal_last_year - loan_last_year);
        local tax = (profit * GSController.GetSetting("corp_tax_level")) / 100;

        if(tax > 0) {
            GSCompany.ChangeBankBalance(this.id, -tax, GSCompany.EXPENSES_OTHER);
        }
        //GSLog.Info("Profit for company " + this.id + ": " + profit);
        //GSLog.Info("Tax    for company " + this.id + ": " + tax);

        this.bank_bal_last_year = GSCompany.GetBankBalance(this.id);
        this.loan_last_year = loan_this_year;
    }
}