@isTest
private class TestTimesheets {

	static testMethod void testCreateTimesheet ()
	{
    	RecordType employeeType = [SELECT ID, Name FROM RecordType WHERE SobjectType='Contact' and DeveloperName='Internal_Employee'];
    	
    	Contact internalemployee = new Contact (LastName='Internal', RecordTypeID = employeeType.ID);
    	insert internalemployee;
    	
    	Timesheet__c ts = new Timesheet__c (Week_beginning__c = system.today(), Employee__c=internalemployee.id);
    	ts.Monday_Time_in__c='07:00';
    	ts.Monday_Time_out__c = '15:30';
    	ts.Friday_Time_in__c='07:00';
    	ts.Friday_Time_out__c = '10:00';
    	ts.Annual_leave_taken_this_week_in_hours__c = 20;
    	insert ts;
    	
		ts = [select Total_Hours_worked__c from Timesheet__c where ID=:ts.id];
		system.assertEquals(11.5, ts.Total_Hours_worked__c);
		
		internalemployee = [select ID, Annual_leave_used_this_year__c from Contact where ID = :internalemployee.id];
		system.assert (internalemployee.Annual_leave_used_this_year__c > 2);
	}
}