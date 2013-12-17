trigger ChangeOwnerOnLearnerToTutorOrLSW on Learner__c (before insert, before update) 
{
	// need to change the owner of the record to the new tutor or lsw
	// if the status has changed to 'Assigned to LSW', then change the owner to the LSW
	// else if the status has changed to 'Assigned to tutor', then change owner to the tutor
	// else if the status has changed away from 'Assigned to LSW' then change owner and LSW to internal
	// else if the status has changed away from 'Assigned to tutor' then change owner and tutor to internal
	// 
	// if error, change the owner to internal
 
 	Contact internalContact=null;
 	try
 	{
    	RecordType tutorType = [SELECT ID, Name FROM RecordType WHERE SobjectType='Contact' and Name='NALA Tutor or LSW'];
 		internalContact = [select ID, OwnerID from Contact where Name like 'Internal%' and RecordTypeID=:tutorType.id limit 1];
 	}
 	catch (Exception e)
 	{
 	}
 	
    Map<Id, User> mapUsers = new Map<Id, User>();
    for (User oneUser: [select ID, ContactID from User])
    {
    	mapUsers.put (oneUser.ContactID, oneUser);
    }
 
	// who have the learners changed on (must have the status "Assigned to tutor")
    for(Learner__c learner : Trigger.new)
    {
    	if (learner.Current_DL_status__c.Contains ('Assigned to LSW') && learner.Learning_Support_Worker__c == null)
    	{
    		learner.Learning_Support_Worker__c.addError('If assigning a learner to a LSW, you must set the LSW');
    	}
    	else if (learner.Current_DL_status__c == 'Assigned to tutor' && learner.Tutor_for_DL__c == null)
    	{
    		learner.Tutor_for_DL__c.addError('If assigning a learner to a tutor, you must set the tutor');
    	}
    	else if (!System.Trigger.isInsert)
    	{
	    	Learner__c oldlearner = Trigger.oldMap.get(learner.id);
	        if (learner.Current_DL_status__c.Contains ('Assigned to LSW'))
	        {
	        	if ((!oldlearner.Current_DL_status__c.Contains ('Assigned to LSW')) || (learner.Learning_Support_Worker__c != oldlearner.Learning_Support_Worker__c))
	 	    	{
	    	    	ChangeOwner (learner, learner.Learning_Support_Worker__c);
	        	}
	        }
	        else if (learner.Current_DL_status__c == 'Assigned to tutor')
	        {
	        	if ((oldlearner.Current_DL_status__c != 'Assigned to tutor') || (learner.Tutor_for_DL__c != oldlearner.Tutor_for_DL__c))
	 	    	{
	    	    	ChangeOwner (learner, learner.Tutor_for_DL__c);
	        	}
	        }
	        else if (oldlearner.Current_DL_status__c.Contains ('Assigned to LSW'))
	        {
	        	learner.Learning_Support_Worker__c = internalContact.ID;
	        	learner.OwnerID = internalContact.OwnerID;
	        }
	        else if (oldlearner.Current_DL_status__c == 'Assigned to tutor')
	        {
	        	learner.Tutor_for_DL__c = internalContact.ID;
	        	learner.OwnerID = internalContact.OwnerID;
	        }
    	}
    	else
    	{
 	        if (learner.Current_DL_status__c == 'Assigned to tutor')
	        {
    	    	ChangeOwner (learner, learner.Tutor_for_DL__c);
	        }
	        else if (learner.Current_DL_status__c.Contains ('Assigned to LSW'))
	        {
	    	    ChangeOwner (learner, learner.Learning_Support_Worker__c);
	        }    		
    	}
    }
    
    void ChangeOwner (Learner__c learner, ID tutorOrLSW)
    {
 		// find the user 
        try
        {
           	User portalUser = mapUsers.get (tutorOrLSW);
           	if (portalUser == null)
           	{
           		learner.OwnerID = UserInfo.getUserId();
           	}
           	else
           	{
            	learner.OwnerID = portalUser.id;
            	learner.Send_email__c = true; // flag to the workflow to send an email
           	}
        }
        catch (Exception e)
        {
        	system.debug ('Tutor or LSW not found in user list, changing owner to internal user');
        	learner.OwnerID = internalContact.OwnerID;
        }
     }

}