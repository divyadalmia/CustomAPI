@RestResource(UrlMapping = '/GetABSlots/*')
global with sharing class GetABSlots {

    global static Integer statusCode=400;
    private static final rflib_logger LOGGER = rflib_LoggerUtil.getFactory().createLogger('ABGetSlots'); 

    @HttpPost
    global static void doPost() {
        
        RestRequest restReq = RestContext.request;
        String returnJson = '';
        ABWrapper.requestWrapper saWrapper = new ABWrapper.requestWrapper();
        try 
        {
            LOGGER.info('CALLING CUSTOM REST API: GET SLOTS');

            saWrapper = (ABWrapper.requestWrapper)JSON.deserialize(restReq.requestBody.toString(), ABWrapper.requestWrapper.class);
            if(saWrapper.serviceAppointmentNumber!=null)
            {
                returnJson = generateTimeSlots(saWrapper, false);
            }
        } 
        catch (Exception ex) 
        {
            LOGGER.error('EXCEPTION OCCURRED IN CUSTOM REST API: GET SLOTS({0})', new Object[]{ex});
            returnJson = JSON.serialize(MyABUtil.setAppointmentSlotsWrapper(null, MyABUtil.ERROR_MESSAGE, MyABUtil.FAILURE_STATUS_CODE, null));
        }
        finally 
        {
            RestResponse res = RestContext.response;
            res.statusCode = statusCode;
            res.responseBody = Blob.valueOf(returnJson);
        }
    }
    
    public static String generateTimeSlots(ABWrapper.requestWrapper req, Boolean isTest){
        String returnResponse = '';
        String appointNumber ='';
        ABWrapper.responseWrapper responseWrap = new ABWrapper.responseWrapper();
        List <FSL.AppointmentBookingSlot> slots =new List <FSL.AppointmentBookingSlot>();
        List <ServiceAppointment> serviceAppointments = new List <ServiceAppointment>();
        try
        {
            serviceAppointments = MyABUtil.getServiceAppointment(req.serviceAppointmentNumber);

            if(serviceAppointments.size() == 0) 
            {
                //In case of no service appointment
                LOGGER.info('SERVICE APPOINTMENT NOT FOUND');
                return JSON.serialize(MyABUtil.setAppointmentSlotsWrapper(req.serviceAppointmentNumber, 
                                                                        MyABUtil.NO_SERVICE_APPOINTMENT_FOUND, 
                                                                        MyABUtil.NO_SERVICEAPPOINTMENT_STATUS_CODE,
                                                                        slots));
            }
            
            appointNumber = serviceAppointments[0].AppointmentNumber;
            
            //Fetching the default scheduling policy
            FSL__Scheduling_Policy__c policy = MyABUtil.fetchSchedulingPolicy();
            if (policy == null){
                //Checking for valid Scheduling Policy
                LOGGER.info('INVALID SERVICE POLICY');
                return JSON.serialize(MyABUtil.setAppointmentSlotsWrapper(appointNumber,
                                                                        MyABUtil.NO_SERVICEPOLICY,
                                                                        MyABUtil.NO_SERVICEPOLICY_CODE,
                                                                        slots));  
            }
            
            if(serviceAppointments[0].Status != MyABUtil.SA_STATUS_OPEN && serviceAppointments[0].Status != MyABUtil.SA_STATUS_SCHEDULED ) 
            {
                //Checking for valid statuses for SA
                LOGGER.info('INVALID STATUS');
                return JSON.serialize(MyABUtil.setAppointmentSlotsWrapper(appointNumber, 
                                                                        MyABUtil.NOT_SCHEDULED_UNSCHEDULED,
                                                                        MyABUtil.DIFFERENT_STATUS_CODE,
                                                                        slots));         
            }
            
            if (serviceAppointments[0].ServiceTerritory == null){
                //Checking for valid Service Territory
                LOGGER.info('NO SERVICE TERRITORY FOUND ON SA');
                return JSON.serialize(MyABUtil.setAppointmentSlotsWrapper(appointNumber,
                                                                        MyABUtil.NO_SERVICETERRITORY,
                                                                        MyABUtil.NO_SERVICE_TERRITORY_CODE,
                                                                        slots));
            }
            
            OperatingHours operatingHr = MyABUtil.fetchOperatingHour();
            Timezone tz = TimeZone.getTimeZone(serviceAppointments[0].ServiceTerritory.OperatingHours.TimeZone);
            
            //Fetching the default operating hour
            if (policy != null && tz != null && operatingHr != null) {

                LOGGER.info('ALL THE PARAMETERS PRESENT. POLICY, TIMEZONE AND OPERATING HOUR({0},{1},{2})', new Object[]{policy,tz,operatingHr});
                //Calling the OOTB GetSlots API
               
               slots = FSL.AppointmentBookingService.getSlots(serviceAppointments[0].Id, policy.Id, operatingHr.Id, tz, false);
                
               if(isTest){
                slots = MyABUtil.getDefaultSlotsInfo();
                }

                if (slots != null && slots.size() > 0) {
                    LOGGER.info('OOTB SLOTS AVAILABLE');
                    LOGGER.info('OOTB SLOTS SIZE({0})', new Object[]{slots.size()});
                    
                            
                    responseWrap = MyABUtil.setAppointmentSlotsWrapper(appointNumber,
                                                                             MyABUtil.SUCCESSFULL,
                                                                             MyABUtil.SUCCESS_STATUS_CODE,
                                                                             slots);
                            
                    statusCode = 200;
                    
                    }
                else {
                    responseWrap = MyABUtil.setAppointmentSlotsWrapper(appointNumber,
                                                                     MyABUtil.NO_SLOTAVAILABLE,
                                                                     MyABUtil.NO_SLOTS_AVAILABLE_CODE,
                                                                     slots);
                }
            }   
        }
        catch(Exception e) {
            LOGGER.error('EXCEPTION OCCURRED IN FETCHING SLOT({0})', new Object[]{e});
            responseWrap = MyABUtil.setAppointmentSlotsWrapper(appointNumber,
                                                             MyABUtil.ERROR_MESSAGE,
                                                             MyABUtil.FAILURE_STATUS_CODE,
                                                             null);
        }    
        
        returnResponse =JSON.serialize(responseWrap);
        return returnResponse.removeStart('"').removeEnd('"').replace('\\"','"');
        
    }
}