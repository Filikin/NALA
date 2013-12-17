/*

Author: Eamon Kelly, Enclude

Purpose: Calculate hours worked

Called from: Trigger

*/
trigger Timesheets on Timesheet__c (before insert, before update) 
{
	for (Timesheet__c oneTS: trigger.new)
	{
		oneTS.Total_Hours_worked__c = oneTS.Monday_Hours_worked__c + oneTS.Tuesday_Hours_worked__c + oneTS.Wednesday_Hours_worked__c + oneTS.Thursday_Hours_worked__c + oneTS.Friday_Hours_worked__c + oneTS.Saturday_Hours_worked__c + oneTS.Sunday_Hours_worked__c; 
	}
}