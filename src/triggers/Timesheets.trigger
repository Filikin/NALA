/*

Author: Eamon Kelly, Enclude

Purpose: 
1) Calculate hours worked
2) If the employee is not set, set it (because a portal user cannot access contacts)
3) Update the annual leave used this year on the contact

Called from: Trigger

*/
trigger Timesheets on Timesheet__c (before insert, before update, after insert, after update) 
{
    ID userContactId = [select ContactID from User where ID = :UserInfo.getUserId()].ContactID;
    Set <ID>employeesSet = new Set<ID>();
    for (Timesheet__c oneTS: trigger.new)
    {
        if (trigger.isBefore) 
        {
        	oneTS.Total_Hours_worked__c = oneTS.Monday_Hours_worked__c + oneTS.Tuesday_Hours_worked__c + oneTS.Wednesday_Hours_worked__c + oneTS.Thursday_Hours_worked__c + oneTS.Friday_Hours_worked__c + oneTS.Saturday_Hours_worked__c + oneTS.Sunday_Hours_worked__c;
	        if (oneTS.Employee__c == null) oneTS.Employee__c = userContactId;
        }
        employeesSet.add (oneTS.Employee__c); 
    }
    
    if (trigger.isAfter)
    {
	    List<Contact> employees = [select ID, Annual_leave_used_this_year__c from Contact where ID in :employeesSet];
	    
	    // get all the relevant time sheets and recalculate the annual leave used
	    // THIS_YEAR is fine in Salesforce, but not in the IDE
	    Integer this_year = system.today().year();
	    List <Timesheet__c> timesheetsThisYear = [select ID, Annual_leave_taken_this_week_in_hours__c, Employee__c from Timesheet__c where Employee__c in :employeesSet and CALENDAR_YEAR(Week_beginning__c) = :this_year and Annual_leave_taken_this_week_in_hours__c>0];
		
		for (Contact oneEmployee: employees)
		{
			oneEmployee.Annual_leave_used_this_year__c  = 0;
			for (Timesheet__c oneTS: timesheetsThisYear)
			{
				if (oneTS.Employee__c == oneEmployee.id) oneEmployee.Annual_leave_used_this_year__c += oneTS.Annual_leave_taken_this_week_in_hours__c; 
			}
			system.debug ('oneEmployee.Annual_leave_used_this_year__c: ' + oneEmployee.Annual_leave_used_this_year__c);
			oneEmployee.Annual_leave_used_this_year__c /= (37/5);
		}    
	    update employees;
    }
}