public with sharing class TimesheetController 
{
    private final Timesheet__c ts;
    private boolean isEdit = false;
    ApexPages.StandardController std;

    public TimesheetController(ApexPages.StandardController stdController) 
    {
    	this.std = stdController;
        this.ts = (Timesheet__c)stdController.getRecord();
        this.isEdit = true;
    }

    public Boolean getIsEdit() {
        return isEdit;
    }
    
    public void edit() {
        isEdit=true;
    }    
    
    public void cancel() 
    {
        isEdit=false;
    }
    
    public void save ()
    {
    	ID userContactId = [select ContactID from User where ID = :UserInfo.getUserId()].ContactID;
 		if (ts.Employee__c == null) ts.Employee__c = userContactId; 
        isEdit=false;
    	std.save();
    }
}