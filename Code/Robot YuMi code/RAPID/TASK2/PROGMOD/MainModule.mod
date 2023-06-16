MODULE MainModule
TASK PERS tooldata tool1:=[TRUE,[[0,0,0],[1,0,0,0]],[-1,[0,0,0],[1,0,0,0],0,0,0]];
TASK PERS wobjdata wobjCalib:=[FALSE,TRUE,"",[[314.034,274.803,1.24622],[0.999945,-0.00160565,-0.00835892,0.00614249]],[[0,0,0],[1,0,0,0]]];
PERS num recv_reading:=9.735;
PERS bool client_connected;
VAR num targetweight:=0;
PERS num recv_target_weight;
VAR num difference;
PERS bool leftfinish;
VAR num flag;! to calculate the same gap between vial rack 
! points on the vials rack 
CONST robtarget p1:=[[330.40,187.06,55.05],[0.0139775,-0.020723,-0.999489,-0.0199153],[-1,2,0,4],[134.391,9E+09,9E+09,9E+09,9E+09,9E+09]]; !low
CONST robtarget p2:= [[329.89,160.36,55.67],[0.0139952,-0.0207114,-0.999489,-0.0199133],[-1,2,0,4],[134.388,9E+09,9E+09,9E+09,9E+09,9E+09]];
CONST robtarget p3:=[[329.26,133.87,55.35],[0.0139876,-0.0207179,-0.999489,-0.0199247],[-1,2,0,4],[134.387,9E+09,9E+09,9E+09,9E+09,9E+09]];
CONST robtarget p4:=[[330.40,187.06,69.2],[0.0139775,-0.020723,-0.999489,-0.0199153],[-1,2,0,4],[134.391,9E+09,9E+09,9E+09,9E+09,9E+09]]; !low
CONST robtarget p5:= [[329.89,160.36,69.82],[0.0139952,-0.0207114,-0.999489,-0.0199133],[-1,2,0,4],[134.388,9E+09,9E+09,9E+09,9E+09,9E+09]];
CONST robtarget p6:=[[329.26,133.87,69.5],[0.0139876,-0.0207179,-0.999489,-0.0199247],[-1,2,0,4],[134.387,9E+09,9E+09,9E+09,9E+09,9E+09]];
PERS bool ready_new_command;
VAR num no_vials_now:=0; ! this is the no of already dispensed vial to control the position of vial
VAR num reg_novials_now; ! this the remainder of the dispensed number of vials / the no holes of the rack
PERS bool vial_put;
PERS bool vial_back;
PERS bool Load_data_done;
VAR clock timer;
VAR num time; !how long it take for one whole dispensing 
PERS num result{5}; 
PERS bool send_result;
PERS bool put_vial_initial;
PERS String target_weight_string;
PERS bool initialL_done;
PERS bool hopperpick_done;
PERS bool hopper_back;
PERS bool hopper_back_start;
pers num over_error;
pers bool send;

    
	PROC LhomePos()
	MoveAbsJ [[0,-130,30,0,40,0],[135,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v6000, z50, GripperLeft;
	ENDPROC
    
	PROC LcamCalib()
	MoveJ [[439.09,273.63,286.84],[0.50907,-0.490757,0.50908,-0.490758],[-1,0,0,5],[115.735,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
	ENDPROC
    
    
    

PROC main()
    ! pre-dispensing
    ! pick hopper
    initialL_startL1;
    vial_inside_scaleL2;
    WaitUntil put_vial_initial;
    !hopperonholderL3;
    clkStart timer;
    hopperpick_done:=TRUE;
    waituntil hopper_back_start;
    hopper_back_L4; ! back hopper
    hopper_back:=TRUE;
    WaitUntil send;
    sendtosocketL5; ! send to socket 
    vial_back_L6; ! back vial to rack 
    leftfinish:=TRUE; 
    IF over_error=1 THEN
        reg_novials_now:=reg_novials_now-1;
    ENDIF    

ENDPROC
PROC initialL_startL1()

initialL_done:=FALSE;
g_GripIn;
WaitUntil client_connected;
WaitUntil Load_data_done;
leftfinish:=FALSE;
ClkReset timer;
clkStart timer;
ENDPROC
PROC vial_inside_scaleL2()
!left arm only put vial in temporary holder
WaitUntil client_connected;   

no_vials_now:=no_vials_now+1;
reg_novials_now:= (no_vials_now MOD 16)-1;
LhomePos;
pick_vial_ready ;
LhomePos;
    
ENDPROC

PROC hopperonholderL3() ! pick hopper
hopper_pick;
LhomePos;
ENDPROC

PROC hopper_back_L4()  ! back hopper
hopper_back1;

ENDPROC
    
PROC sendtosocketL5()
    ! send all result to the socket result{6}
    clkStop timer;
    time:=ClkRead(timer);
    TPWrite "time takes"+ValToStr(time);
    result{4}:=time;  
    result{5}:=-(100*0.7*abs(result{1})+0.2*((result{4}/60)-10));
    IF over_error=1 THEN
         send_result:=false;
    ELSE
        send_result:=TRUE;
    ENDIF
 
    WaitTime 1;
    LhomePos;
    send_result:=FALSE;
    ClkReset timer;
    
ENDPROC

PROC vial_back_L6() ! back vial to the rack 
  WaitUntil vial_back;
backvial_rack;
       
ENDPROC




PROC hopper_pick()
!pick funnel and support
MoveAbsJ [[-15.608,-130.004,50.1868,-20.3301,30.4243,80.9518],[96.198,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperLeft;
MoveL [[291.55,510.24,346.57],[0.486579,-0.486492,0.535635,-0.489553],[0,0,0,4],[107.456,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
g_GripIn;
MoveL [[396.70,497.04,384.06],[0.47915,-0.494542,0.528272,-0.496761],[-1,1,0,4],[107.446,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
MoveL [[569.14,546.80,378.91],[0.478685,-0.495271,0.51368,-0.511566],[-1,1,0,4],[107.44,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
WaitTime 3;
g_GripOut;
g_SetForce 200;
WaitTime 1;
MoveL [[570.75,547.13,395.50],[0.48209,-0.491828,0.516979,-0.508358],[-1,1,0,4],[107.442,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
MoveL [[394.42,547.16,390.28],[0.482075,-0.4919,0.516987,-0.508293],[-1,1,0,4],[107.438,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
MoveL [[370.08,280.73,405.93],[0.478606,-0.494716,0.528908,-0.496436],[0,2,-1,4],[133.127,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
MoveL [[568.07,311.44,406.25],[0.479011,-0.494252,0.528493,-0.496949],[-1,1,-1,4],[120.843,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
MoveL [[579.20,-152.95,406.24],[0.487037,-0.501792,0.521118,-0.489323],[-2,3,-1,4],[120.84,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
MoveL [[569.51,-152.38,409.30],[0.495023,-0.493856,0.513178,-0.497701],[-2,3,-1,4],[120.822,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
MoveL [[559.71,-152.38,368.22],[0.49502,-0.493853,0.513177,-0.497708],[-2,3,-2,4],[120.817,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
MoveL [[559.71,-152.38,343.72],[0.495018,-0.493841,0.513173,-0.497726],[-2,3,-2,4],[120.814,9E+09,9E+09,9E+09,9E+09,9E+09]], v100, z50, GripperLeft;
MoveL [[616.83,-152.71,328.60],[0.490932,-0.517308,0.517737,-0.472574],[-2,3,-2,4],[120.81,9E+09,9E+09,9E+09,9E+09,9E+09]], v100, z50, GripperLeft;
!MoveL [[618.60,-152.71,329.36],[0.479983,-0.508506,0.527894,-0.482044],[-2,3,-2,4],[120.819,9E+09,9E+09,9E+09,9E+09,9E+09]], v80, z50, GripperLeft;
WaitTime 3;
g_GripIn;
WaitTime 1;
MoveL [[496.87,-152.34,335.50],[0.487034,-0.501795,0.521118,-0.489322],[-1,3,-1,4],[120.836,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
MoveL [[365.00,200.92,293.33],[0.487136,-0.501848,0.521026,-0.489264],[0,3,-2,4],[120.838,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
ENDPROC 

PROC hopper_back1()
! back funnel support to the stirage box
MoveAbsJ [[-33.8484,-128.631,66.5416,261.555,21.0481,-192.885],[93.338,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperLeft;
g_GripIn;
MoveL [[532.04,-151.93,329.00],[0.48709,-0.501888,0.521025,-0.489269],[-1,3,-2,4],[131.764,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
MoveL [[618.44,-151.96,325.84],[0.491721,-0.497512,0.507435,-0.503191],[-2,3,-2,4],[131.759,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
WaitTime 2;
g_GripOut;
g_SetForce 100;
WaitTime 1;
MoveL [[618.44,-151.97,330.08],[0.491718,-0.497506,0.507436,-0.503199],[-2,3,-2,4],[131.758,9E+09,9E+09,9E+09,9E+09,9E+09]], v100, z50, GripperLeft;
MoveL [[599.19,-151.97,357.01],[0.491715,-0.497511,0.507436,-0.503198],[-2,3,-2,4],[131.755,9E+09,9E+09,9E+09,9E+09,9E+09]], v200, z50, GripperLeft;
MoveL [[598.93,-57.53,357.01],[0.491708,-0.497508,0.507436,-0.503206],[-1,2,-2,4],[131.753,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
!MoveL [[618.44,-151.97,436.79],[0.491709,-0.497515,0.50744,-0.503195],[-2,2,-2,4],[131.758,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
MoveL [[620.13,268.02,403.21],[0.487121,-0.501858,0.521021,-0.489273],[-1,2,-1,4],[131.771,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
MoveL [[354.92,267.98,402.43],[0.485968,-0.502998,0.522118,-0.488078],[0,2,-1,4],[128.574,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
MoveL [[354.92,467.66,402.43],[0.485966,-0.502997,0.522119,-0.488081],[0,0,0,4],[128.574,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
MoveL [[326.22,493.95,406.27],[0.485954,-0.502982,0.522161,-0.488063],[0,0,0,4],[128.519,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
MoveL [[413.45,546.80,398.60],[0.478683,-0.495292,0.513681,-0.511547],[-1,1,0,4],[107.441,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
MoveL [[569.14,546.80,398.6],[0.478685,-0.495271,0.51368,-0.511566],[-1,1,0,4],[107.44,9E+09,9E+09,9E+09,9E+09,9E+09]], v400, z50, GripperLeft;
MoveL [[569.14,546.80,378.91],[0.478685,-0.495271,0.51368,-0.511566],[-1,1,0,4],[107.44,9E+09,9E+09,9E+09,9E+09,9E+09]], v400, z50, GripperLeft;
WaitTime 3;
g_GripIn;
WaitTime 1;
MoveL [[456.84,494.06,383.15],[0.519898,-0.467825,0.486736,-0.523387],[-1,0,0,4],[128.564,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
MoveL [[453.41,236.11,385.64],[0.491549,-0.497532,0.516603,-0.493926],[-1,2,-1,4],[128.86,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
MoveAbsJ [[-33.8484,-128.631,66.5416,261.555,21.0481,-192.885],[93.338,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperLeft;

ENDPROC
   

    
PROC pick_vial_ready () ! pick vial in the rack 
    
    
        MoveAbsJ [[-10.6673,-112.178,45.0398,-30.5344,62.1438,120.456],[134.528,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperLeft;
        MoveAbsJ [[-65.6477,-111.844,64.9464,134.812,109.778,-33.7355],[54.1405,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperLeft;
        MoveL [[330.39,187.06,121.29],[0.0139927,-0.0207169,-0.999489,-0.0199197],[-1,2,0,4],[134.391,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
        
        
        g_MoveTo 19;
        
        IF reg_novials_now>=0 and reg_novials_now<=5 THEN
        !x:35.25 y:-1.442 z:0.09
        MoveL offs (p1,35.25*reg_novials_now,-1.442*reg_novials_now,66.24),v2000,z50,GripperLeft;
        MoveL offs (p1,35.25*reg_novials_now,-1.442*reg_novials_now,0.09*reg_novials_now),v200,z50,GripperLeft;
        WaitTime 5;
        g_GripOut;
        g_SetForce 40;
        WaitTime 1; 
        MoveL offs (p1,35.25*reg_novials_now,-1.442*reg_novials_now,66.24),v1000,z50,GripperLeft;  
        
        
        ELSEIf  reg_novials_now>=0 and reg_novials_now<=9 THEN
        flag:=reg_novials_now-6;
        ! x35.088 y:-1.04 z0.304
        IF reg_novials_now>=0 and  reg_novials_now<=7 THEN
        
        MoveL offs(p2,35.088*flag,-1.04*flag,65.33),v2000,z50,GripperLeft;
        MoveL offs(p2, 35.088*flag,-1.04*flag,0.304*flag),v200,z50,GripperLeft;
        WaitTime 5;
        g_GripOut;
        g_SetForce 40;
        WaitTime 1; 
        MoveL offs(p2,35.088*flag,-1.04*flag,65.33),v1000,z50,GripperLeft;
        
        
        ELSEIF reg_novials_now>=0 and reg_novials_now>7 THEN
        flag:=reg_novials_now-4;
        
        MoveL offs(p2,35.088*flag,-1.04*flag,65.33),v2000,z50,GripperLeft;
        MoveL offs(p2, 35.088*flag,-1.04*flag,0.304*flag),v200,z50,GripperLeft;
        WaitTime 5;
        g_GripOut;
        g_SetForce 40;
        WaitTime 1; 
        MoveL offs(p2,35.088*flag,-1.04*flag,65.33),v1000,z50,GripperLeft;
        endif   
        ELSE 
        IF reg_novials_now<0  THEN
        flag:=5;
        
        ELSE
        flag:=reg_novials_now-10;
        ENDIF
        
        
        ! x:35.032 y:-0.87 Z:-0.062
        
        MoveL offs(p3,35.032*flag,-0.87*flag,65.65),v2000,z50,GripperLeft;
        MoveL offs(p3, 35.032*flag,-0.87*flag,-0.062*flag),v200,z50,GripperLeft;
        WaitTime 5;
        g_GripOut;
        g_SetForce 40;
        WaitTime 1; 
        MoveL offs(p3,35.032*flag,-0.87*flag,65.65),v1000,z50,GripperLeft;
        ENDIF
        
        
        
        
        !+35 long  or -27 short 
        MoveL [[371.04,-8.47,200.38],[0.0102909,-0.0275184,-0.999497,-0.0119671],[-1,1,-1,4],[134.378,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
        MoveL [[371.02,-8.47,95.95],[0.0103365,-0.0275001,-0.999497,-0.0119839],[-1,2,-1,4],[134.376,9E+09,9E+09,9E+09,9E+09,9E+09]], v400, z50, GripperLeft;
        MoveL [[371.02,-8.47,71.39],[0.0103372,-0.0274993,-0.999497,-0.0119868],[-1,2,-1,4],[134.375,9E+09,9E+09,9E+09,9E+09,9E+09]], v200, z50, GripperLeft;
        WaitTime 4;
        g_GripIn;
        MoveL [[371.01,-8.47,149.47],[0.0103648,-0.0274916,-0.999496,-0.0119932],[-1,2,-1,4],[134.374,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
        LhomePos;
        vial_put:=TRUE;
        

	ENDPROC
    
PROC backvial_rack()
   !take the vial from the temprary hole to the rack

    MoveAbsJ [[-37.3371,-118.785,57.7839,129.52,84.5365,-10.7997],[61.7534,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperLeft;
    g_MoveTo 17.5;
    MoveL [[370.33,-8.22,193.61],[0.0178566,-0.0241315,-0.999355,-0.0196915],[-1,1,-1,4],[135.434,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
    MoveL [[370.34,-8.22,66.15],[0.017824,-0.0241463,-0.999356,-0.0196751],[-1,2,-1,4],[135.435,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
    WaitTime 3;
    g_GripOut;
    g_SetForce 40;
    WaitTime 2;
    MoveL [[370.33,-8.22,193.61],[0.0178573,-0.0241336,-0.999355,-0.0196919],[-1,1,-1,4],[135.434,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
    
    !for loop 
   
    
    loop_backvial_pos;
    
     MoveL [[238.36,248.58,130.85],[0.0174666,-0.0393068,-0.998892,-0.0190914],[0,1,0,4],[142.817,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperLeft;
        
           
ENDPROC
    
PROC loop_backvial_pos()


            IF reg_novials_now>=0 and reg_novials_now<=5 THEN
            !x:35.25 y:-1.442 z:0.09
            MoveL offs (p4,35.25*reg_novials_now,-1.442*reg_novials_now,66.24),v2000,z50,GripperLeft;
            MoveL offs (p4,35.25*reg_novials_now,-1.442*reg_novials_now,0.09*reg_novials_now),v200,z50,GripperLeft;
               WaitTime 3;
              g_MoveTo 17.5;
            MoveL offs (p4,35.25*reg_novials_now,-1.442*reg_novials_now,66.24),v1000,z50,GripperLeft;  
            
            
            ELSEIf  reg_novials_now>=0 and reg_novials_now<=9 THEN
            flag:=reg_novials_now-6;
            ! x35.088 y:-1.04 z0.304
            IF reg_novials_now>=0 and reg_novials_now<=7 THEN
            
            MoveL offs(p5,35.088*flag,-1.04*flag,66.24),v2000,z50,GripperLeft;
            MoveL offs(p5, 35.088*flag,-1.04*flag,0.304*flag),v200,z50,GripperLeft;
               WaitTime 3;
              g_MoveTo 17.5;
            MoveL offs(p5,35.088*flag,-1.04*flag,66.24),v1000,z50,GripperLeft;
            
            
            ELSEIF reg_novials_now>=0 and  reg_novials_now>7 THEN
            flag:=reg_novials_now-4;
            
            MoveL offs(p5,35.088*flag,-1.04*flag,66.24),v2000,z50,GripperLeft;
            MoveL offs(p5, 35.088*flag,-1.04*flag,0.304*flag),v200,z50,GripperLeft;
              WaitTime 3;
              g_MoveTo 17.5;
            MoveL offs(p5,35.088*flag,-1.04*flag,66.24),v1000,z50,GripperLeft;
            endif   
            ELSE 
            IF reg_novials_now<0  THEN
            flag:=5;
            
            ELSE
            flag:=reg_novials_now-10;
            ENDIF
            
            ! x:35.032 y:-0.87 Z:-0.062
            
            MoveL offs(p6,35.032*flag,-0.87*flag,65.65),v2000,z50,GripperLeft;
            MoveL offs(p6, 35.032*flag,-0.87*flag,-0.062*flag),v200,z50,GripperLeft;
               WaitTime 3;
              g_MoveTo 17.5;
            MoveL offs(p6,35.032*flag,-0.87*flag,65.65),v1000,z50,GripperLeft;
            ENDIF
            
            !if else
ENDPROC
  
    
ENDMODULE