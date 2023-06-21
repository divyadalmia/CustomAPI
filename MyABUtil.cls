public with sharing class MyABUtil {
    private static final rflib_logger LOGGER = rflib_LoggerUtil.getFactory().createLogger('ABUtil'); 
    
    public static final String POLICYNAME  = 'Customer First'; //Default policy Name
    public static final String OPERATINGHR  = 'HomeServe Appointment Hours'; //Default Operating Hour
    
    public static final String SA_STATUS_OPEN  = 'Open';
    public static final String SA_STATUS_SCHEDULED  = 'Scheduled';
    
    //Status Code
    public static final Integer FAILURE_STATUS_CODE  = 400;
    public static final Integer SUCCESS_STATUS_CODE  = 200;
    
    //Success message
    public static final String SUCCESSFULLY_SCHEDULED  = 'SCHEDULED SUCCESSFULLY'; 
    public static final String SUCCESSFULL  = 'GET SLOT SUCCESSFULL';
    
    //Fail message
    public static final String ERROR_MESSAGE = 'INVALID JSON';
    
    public static final String NO_SLOTAVAILABLE = 'NO SLOT AVAIABLE';
    public static final Integer NO_SLOTS_AVAILABLE_CODE  = 902;
    
    public static final String NO_SERVICETERRITORY = 'NO SERVICE TERRITORY FOUND ON SA';
    public static final Integer NO_SERVICE_TERRITORY_CODE  = 903;
    
    public static final String NOT_SCHEDULED_UNSCHEDULED = 'INVALID STATUS';
    public static final Integer DIFFERENT_STATUS_CODE  = 904;
    
    public static final String NO_SERVICEPOLICY = 'INVALID SERVICE POLICY';
    public static final Integer NO_SERVICEPOLICY_CODE  = 905;
    
    public static final String NO_SERVICE_APPOINTMENT_FOUND   = 'SERVICE APPOINTMENT NOT FOUND';
    public static final Integer NO_SERVICEAPPOINTMENT_STATUS_CODE  = 906;
    
    public static final String APPOINTMENT_REQUEST_FAILED  = 'APPOINTMENT WAS NOT BOOKED SUCCESSFULLY. TRY SELECTING ANOTHER SLOT.';
    public static final Integer APPOINTMENT_REQUEST_STATUS_CODE  = 907;
    
    public static final String MISSING_PARAMETER = 'MISSING PARAMETER';
    public static final Integer MISSING_PARAMETER_CODE = 908;
    
    
    public static List<ServiceAppointment> getServiceAppointment(String sANumber){
        LOGGER.info('CALLING getServiceAppointment FROM UTIL({0})', new Object[]{sANumber});
        String queryString = 'SELECT Id, AppointmentNumber, ParentRecordId, Status, DurationType, Duration,ArrivalWindowStartTime,ArrivalWindowEndTime,';
        queryString += ' ServiceTerritoryId, ServiceTerritory.OperatingHoursId, ServiceTerritory.OperatingHours.TimeZone, WorkType.Work_Type_Category__c, WorkType.SkipCapacityCalc__c, WorkType.Gantt_Icon__c FROM ServiceAppointment';
        queryString += ' WHERE AppointmentNumber =:sANumber';
        
        List <ServiceAppointment> saList = Database.query(queryString);
        return saList;
    }
    
    //Get the scheduling policy
    public static FSL__Scheduling_Policy__c fetchSchedulingPolicy(){
        List<FSL__Scheduling_Policy__c> policyRecord = [SELECT Id, Name from FSL__Scheduling_Policy__c where Used_for_Appointment_Booking__c = TRUE];

        if(policyRecord != null && policyRecord.Size()>0){
            return policyRecord[0];
        }
        else{
            for(FSL__Scheduling_Policy__c schedulingPolicyInstance:[SELECT Id, Name from FSL__Scheduling_Policy__c where Name =: POLICYNAME]) {
                return schedulingPolicyInstance;
            }
        }
        return null;
    }
    
    //Get the operating hour
    public static OperatingHours fetchOperatingHour(){
        
        List<OperatingHours> opHrRecord = [SELECT Id, Name from OperatingHours where Used_for_Appointment_Booking__c = TRUE];
        
        if(opHrRecord != null && opHrRecord.Size()>0){
            return opHrRecord[0];
        }
        else{
            for(OperatingHours operatingHrInstance:[SELECT Id, Name from OperatingHours where Name =: OPERATINGHR]) {
                return operatingHrInstance;
            }
        }
        return null;
    }
    
    public static ABWrapper.responseWrapper setAppointmentSlotsWrapper(String sAppointment, String message, Integer statusCode, List <FSL.AppointmentBookingSlot> slots){
        ABWrapper.responseWrapper responsewrap = new ABWrapper.responseWrapper();
        responsewrap.saNumber = sAppointment;
        responsewrap.message = message ;
        responsewrap.statusCode = statusCode;
        if(slots != null && !slots.isEmpty()){
            for (FSL.AppointmentBookingSlot slot: slots){
                ABWrapper.slotInfo slotWrapper = new ABWrapper.slotInfo();
                
                slotWrapper.Start = slot.Interval.Start;
                slotWrapper.Finish = slot.Interval.Finish;
                responsewrap.slotInfoList.add(slotWrapper);
            }
        }
        return responsewrap;
    }
    
    public static ABWrapper.bookApptResponseWrapper setBookApptResponseWrapper(String serviceAppt, String message, Integer statusCode, Datetime scheduledStartTime, Datetime scheduledFinishTime){
        ABWrapper.bookApptResponseWrapper responseWrap = new ABWrapper.bookApptResponseWrapper();
        
        responseWrap.saNumber = serviceAppt;
        responseWrap.message = message;
        responseWrap.statusCode = statusCode;
        responseWrap.scheduledStartTime = scheduledStartTime;
        responseWrap.schedueledFinishTime = scheduledFinishTime;
        
        return responseWrap;
    }

    public static List<FSL.AppointmentBookingSlot> getDefaultSlotsInfo(){
            
        LOGGER.info('CALLING METHOD TO CREATE DUMMY AB SLOTS FOR TESTING');
        List<FSL.AppointmentBookingSlot> slots = new List<FSL.AppointmentBookingSlot>();
        
        //Adding Slot 1
        FSL.AppointmentBookingSlot slot = new FSL.AppointmentBookingSlot();
        slot.grade = 100;
        
        Datetime dtNow = Datetime.now();
        Datetime dtStart = Datetime.newInstance(dtNow.year(), dtNow.month(), dtNow.day(), 3, 0, 0);
        Datetime dtFinish = dtStart.addMinutes(240);
        FSL.TimeInterval intervalTemp = new FSL.TimeInterval(dtStart, dtFinish);
        slot.interval = intervalTemp;
        slots.add(slot);

        //Adding Slot 2
        FSL.AppointmentBookingSlot slot2 = new FSL.AppointmentBookingSlot();
        slot2.grade = 100;
        
        Datetime dtNow2 = Datetime.now();
        Datetime dtStart2 = Datetime.newInstance(dtNow.year(), dtNow.month(), dtNow.day()+1, 3, 0, 0);
        Datetime dtFinish2 = dtStart2.addMinutes(240);
        FSL.TimeInterval intervalTemp2 = new FSL.TimeInterval(dtStart2, dtFinish2);
        slot2.interval = intervalTemp2;
        slots.add(slot2);
        return slots;
    }
}