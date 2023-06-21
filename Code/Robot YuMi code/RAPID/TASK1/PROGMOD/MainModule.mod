MODULE MainModule
TASK PERS wobjdata wobjCalibR:=[FALSE,TRUE,"",[[317.006,-224.141,0.857552],[0.999786,-0.000786004,-0.00371968,0.0203487]],[[0,0,0],[1,0,0,0]]];
CONST robtarget p10:=[[458.24,-296.65,135.27],[0.000414402,0.904538,0.426386,0.00230888],[1,1,0,5],[130.654,9E+09,9E+09,9E+09,9E+09,9E+09]];
CONST speeddata speed1:=[3000,1000,10000,2000];
PERS num recv_reading:=9.735;
PERS num recv_target_weight;
PERS bool client_connected;
PERS bool leftfinish;
pers num weight{15};
VAR bool blocking;
VAR num targetweight;
VAR num difference1;
VAR num difference2;
VAR num difference3;
VAR num difference4;
VAR num difference5;
VAR num difference;! average difference betweeen traget weight and scale indicates
VAR num angle; !angle for joint7
VAR bool switch;
VAR num r1;! r2-r1 represting how much difference of two adjent indicates on balance
VAR num r2;
VAR num r2_1;
pers num erro;
PERS num result{5}; ! first parameter is precision, 2nd is difference, 3nd is targetweight, 4nd sample num, 5nd default state value 
PERS bool ready_new_command;
VAR num weight_vial1;
VAR num weight_vial2;
VAR num weight_vial3;
VAR num weight_vial4;
VAR num weight_vial5;
pers num weight_vial;
PERS bool vial_put;
PERS bool vial_back;
PERS bool Load_data_done;
PERS bool small;! if smallest spoon is picked
PERS bool medium;! if medium spoon is picked
VAR num i;
VAR num no_droping;
PERS bool send_result;
PERS bool recv_stable;
PERS bool put_vial_initial;
PERS bool dispensing_finish;
PERS bool hopper_back;
PERS num target_weight;
PERS String target_weight_string;
VAR clock timer;
VAR num time;
PERS num shake; !shake number from FLC controller
PERS bool hopperpick_done;
PERS bool hopper_back_start;
PERS bool weight_vial_reday;
PERS num a_smallspoon; ! angle for small spoon from FLC 
pers num over_error;! if solid is overdispenisng
pers bool send;
 
 PROC initialR1()

weight_vial_reday:=false;
hopper_back:=False;
dispensing_finish:=FAlse;
vial_put:=FALSE;
vial_back:=FALSE;
hopperpick_done:=FALSE;
send_result:=False;
recv_stable:=FALSE;
put_vial_initial:=FALSE;
blocking:=FALSE;
Load_data_done:=FALSE;
sampleL_start:=FALSE;
switch := TRUE;
small:=FALSE;
medium:=FALSE;
hopper_back_start:=FALSE;
r2_1:=2;
over_error:=0;
send:=FALSE;
     
 ENDPROC





PROC RhomePos()
 MoveAbsJ [[0,-130,30,0,40,0],[-135,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v5000, z50, GripperR;
ENDPROC

PROC RcamCalib()
 MoveAbsJ [[57.7349,-143.377,51.5897,111.55,2.23142,-0.00329059],[-67.9156,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperR;
 ENDPROC
 


PROC main_()

initialR_startR1; !pre- dispensing
vial_inside_scaleR2; !put vial in the scale 
WaitUntil hopperpick_done;

! dispensing 1 solid

agitatedR3;! using smallest spoon to mix the solid 
L; ! large spoon manipulate

M; ! medium spoon manipulate

SM; ! small spoon

get_dispensingresult;


hopper_back_start:=TRUE;
WaitUntil hopper_back;
endR4; ! back hopper, vial, close balance dooor

waituntil leftfinish;

ENDPROC



PROC initialR_startR1()
 
! this is the first sample start process:including data loading and put vial in scale and no include putting hopper
WaitUntil client_connected; 

initialR1;
Load_data_done:=TRUE;
RhomePos;    
ready_new_command:=TRUE;
targetweight:=recv_target_weight;
    

ENDPROC

PROC vial_inside_scaleR2()
! open scale door
! vial in scale
! close scale door

RhomePos;        
WaitUntil vial_put;
open_door;
vial_inscale;
close_door; 
vial_weight;
RhomePos;
put_vial_initial:=TRUE;
    
ENDPROC
PROC agitatedR3()
mix;
ENDPROC

PROC L()
    ! scoop 
    ! shake 
    ! back large spoon to spoon holder 
IF targetweight>=0.8 THEN
    pickspoon_large;
    shakespoon_large; 
    calculate_difference;
    WHILE difference>0.8 DO
         g_SetForce 100;
        scoop_large;
        shakespoon_large;  
        calculate_difference;
    ENDWHILE
    backspoon_large;
ELSE
!do nothing
ENDIF
ENDPROC

PROC M ()
! if weight doesn't change for a long time, scoop more 
! scoop 
! tilt and shake 
! back medium spoon to spoon holder 
medium:=TRUE;
calculate_difference;
IF difference>0.1 THEN
    pickspoon_medium;
    WHILE difference>=0.1 DO
            r1:=recv_reading;
            g_SetForce 100;
            calculate_difference;
            shakespoon_medium;!shake_no{2} pass parameters from python side
            WaitTime 3;
            r2:=recv_reading;
            load_nodropping;
            r2_1:=r2-r1;
            TPWrite " r2_1 medium: " \Num:=r2_1;
        IF r2_1<no_droping THEN
            scoop_medium;
        ENDIF
        WaitTime 3;
        calculate_difference;
    ENDWHILE
       backspoon_meidum;
ELSE
! do nothing  
ENDIF
  medium:=false;          

ENDPROC

PROC SM ()
! if weight doesn't change for a long time, scoop more 
! scoop 
! tilt
! back medium spoon to spoon holder 

!IF difference<=0.0015 THEN

!ELSE
small:=TRUE;
pickspoon_small;

WHILE difference>=0.0015  DO!and  time_SM<12 !0.0015
            r1:=recv_reading;
            g_SetForce 100;
            calculate_difference;
            shakespoon_small;!shake_no{2} pass parameters from python side
            WaitTime 3;
            r2:=recv_reading;
            load_nodropping;
            
            r2_1:=r2-r1;
            TPWrite " r2_1 small: " \Num:=r2_1;
            IF  r2_1<no_droping  THEN!
            scoop_small;
            ENDIF
            WaitTime 3;
            calculate_difference;
ENDWHILE
       backspoon_small;
       small:=FALSE;
!ENDIF 
ENDPROC
PROC endR4 ()

open_door;
vial_outscale;
close_door;
error_determine;

vial_back:=TRUE;  
RhomePos;




ENDPROC

PROC calculate_difference()
    
! calcuate differnence and set some default value
waitTIme 2;
WaitUntil recv_stable;
difference1:= targetweight - recv_reading+ weight_vial;
WaitUntil recv_stable;
difference2:= targetweight - recv_reading+ weight_vial;
WaitUntil recv_stable;
difference3:= targetweight - recv_reading+ weight_vial;
WaitUntil recv_stable;
difference4:= targetweight - recv_reading+ weight_vial;
WaitUntil recv_stable;
difference5:= targetweight - recv_reading+ weight_vial;
difference:=(difference1+difference2+difference3+difference4+difference5)/5;
TPWrite "calculated difference: " \Num:=difference;

      
ENDPROC

PROC load_nodropping()! no_dropping is a flag to scoop more
 
IF small= TRUE then
    no_droping:=0.001;
ELSEIF medium=true THEN 
    no_droping:=0.002;
ELSE
    no_droping:=0.1;
ENDIF
ENDPROC

PROC get_dispensingresult()

calculate_difference;
waittime 1;
result{2}:= difference;

result{3}:=targetweight;   
result{1}:= result{2}/result{3};

waittime 1;
ENDPROC

PROC error_determine()
turn_vial;
IF result{2}>0.02 OR result{2}<-0.02 THEN 
over_error:=1;
ELSE
ENDIF
send:=TRUE; ! send message to socket
ENDPROC


PROC vial_weight()
    
waittime 2;
WaitUntil recv_stable;
! based on the target weight, pick 1 of 3 spoon
weight_vial1:=recv_reading; 
WaitUntil recv_stable;
weight_vial2:=recv_reading; 
WaitUntil recv_stable;
weight_vial3:=recv_reading; 
WaitUntil recv_stable;
weight_vial4:=recv_reading; 
WaitUntil recv_stable;
weight_vial5:=recv_reading; 
weight_vial:=(weight_vial1+weight_vial2+weight_vial3+weight_vial4+weight_vial5)/5;
weight_vial_reday:=TRUE;
ENDPROC

proc mix()
    
MoveAbsJ [[23.4889,-102.875,55.0657,74.4949,-74.5303,106.163],[-54.7101,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperR;
MoveL [[345.94,-496.83,249.55],[0.00887996,0.707956,-0.706034,-0.0153614],[1,1,1,5],[-178.25,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
g_GripIn;

MoveL [[346.24,-497.72,112.19],[0.0112058,0.719741,-0.693996,-0.014756],[1,1,1,5],[-178.383,9E+09,9E+09,9E+09,9E+09,9E+09]], v200, z50, GripperR;
WaitTime 3;
g_GripOut;
g_SetForce 100;
MoveL [[345.99,-496.86,298.60],[0.00888097,0.707951,-0.706039,-0.0153459],[0,1,1,5],[171.028,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
WaitTime 1;
!pick small spoon already
MoveAbsJ [[-3.56175,-80.1984,21.2591,66.5579,67.6568,123.771],[-83.0382,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperR;
MoveL [[413.59,-150.12,312.45],[0.501306,-0.46313,0.532076,-0.501096],[1,1,0,4],[-118.581,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[483.03,-150.12,312.37],[0.506025,-0.457945,0.526892,-0.506566],[1,2,0,4],[-118.582,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[483.03,-150.17,407.23],[0.505947,-0.45792,0.526963,-0.506593],[1,2,0,4],[-127.023,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[526.72,-150.17,407.23],[0.505948,-0.457922,0.526966,-0.506587],[1,2,0,4],[-127.024,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;


MoveL [[584.33,-169.91,381.83],[0.285748,-0.637886,0.646863,-0.304988],[1,3,0,4],[-173.625,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
! start stir 
MoveL [[608.08,-169.93,382.22],[0.285751,-0.637874,0.646875,-0.304984],[1,3,0,4],[-173.636,9E+09,9E+09,9E+09,9E+09,9E+09]], v800, z50, GripperR;
MoveL [[608.08,-135.18,384.45],[0.285745,-0.637881,0.646874,-0.304978],[1,3,0,4],[-173.646,9E+09,9E+09,9E+09,9E+09,9E+09]], v800, z50, GripperR;
MoveL [[586.77,-131.16,383.21],[0.285749,-0.637858,0.646896,-0.304975],[1,3,0,4],[-173.662,9E+09,9E+09,9E+09,9E+09,9E+09]], v300, z50, GripperR;
MoveL [[586.76,-156.14,379.33],[0.285749,-0.63784,0.646917,-0.30497],[1,3,0,4],[-173.671,9E+09,9E+09,9E+09,9E+09,9E+09]], v300, z50, GripperR;
MoveL [[586.66,-160.66,382.98],[0.285745,-0.637886,0.64686,-0.304996],[1,3,0,4],[-173.668,9E+09,9E+09,9E+09,9E+09,9E+09]], v300, z50, GripperR;
MoveL [[611.19,-160.68,384.30],[0.285744,-0.637871,0.64688,-0.304986],[1,3,0,4],[-173.665,9E+09,9E+09,9E+09,9E+09,9E+09]], v300, z50, GripperR;
MoveL [[608.89,-145.85,385.96],[0.285745,-0.637842,0.646916,-0.304971],[1,3,0,4],[-173.689,9E+09,9E+09,9E+09,9E+09,9E+09]], v300, z50, GripperR;
MoveL [[595.19,-134.48,384.28],[0.285745,-0.637854,0.646899,-0.304982],[1,3,0,4],[-173.681,9E+09,9E+09,9E+09,9E+09,9E+09]], v300, z50, GripperR;
MoveL [[595.18,-159.48,383.53],[0.285745,-0.637853,0.646899,-0.304984],[1,3,0,4],[-173.677,9E+09,9E+09,9E+09,9E+09,9E+09]], v300, z50, GripperR;
MoveL [[608.71,-159.46,387.09],[0.285744,-0.637869,0.646879,-0.304994],[1,3,0,4],[-173.676,9E+09,9E+09,9E+09,9E+09,9E+09]], v300, z50, GripperR;
!back spoon 
MoveL [[560.88,-155.07,354.76],[0.490533,-0.482142,0.521713,-0.504711],[1,2,0,4],[-173.764,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveL [[579.10,-152.39,354.88],[0.49053,-0.482178,0.521702,-0.504691],[1,2,0,4],[-173.766,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveL [[579.10,-152.40,354.89],[0.482646,0.542402,0.458756,0.512247],[1,2,-2,4],[-173.792,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;

MoveL [[579.10,-152.40,354.89],[0.477087,0.536192,0.464533,0.518744],[1,2,-2,4],[-173.794,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;


MoveAbsJ [[63.5175,-68.626,50.4493,151.996,63.6106,-166.267],[-59.6394,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v500, z50, GripperR;
MoveAbsJ [[62.9799,-68.9676,50.1321,151.471,61.423,-165.687],[-59.398,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v500, z50, GripperR;



FOR i FROM 1 TO 10 DO
MoveAbsJ [[63.5175,-68.626,50.4493,151.996,63.6106,-166.267],[-59.6394,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, vmax, z50, GripperR;
MoveAbsJ [[62.9799,-68.9676,50.1321,151.471,61.423,-165.687],[-59.398,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v300, z50, GripperR;

ENDFOR
MoveL [[579.10,-152.39,354.88],[0.49053,-0.482178,0.521702,-0.504691],[1,2,0,4],[-173.766,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveL [[579.10,-152.40,408.19],[0.490536,-0.482148,0.521716,-0.504698],[1,2,0,4],[-173.769,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveL [[579.10,-327.71,408.20],[0.490535,-0.482128,0.521736,-0.504696],[1,2,0,4],[-173.771,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveL [[310.18,-493.61,409.08],[0.491499,-0.510277,0.513438,-0.484176],[0,1,1,4],[-157.273,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveAbsJ [[40.85,-80.1037,-1.93773,91.7756,-85.564,74.6621],[-36.0564,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v500, z50, GripperR;

MoveL [[346.24,-497.72,114.16],[0.0112058,0.719741,-0.693996,-0.014756],[1,1,1,5],[-178.383,9E+09,9E+09,9E+09,9E+09,9E+09]], v200, z50, GripperR;
WaitTime 4;
g_GripIn;
WaitTime 1;
MoveL [[345.30,-496.87,221.64],[0.00890158,0.707937,-0.706053,-0.0153288],[1,1,1,5],[-177.077,9E+09,9E+09,9E+09,9E+09,9E+09]], v2000, z50, GripperR;

MoveAbsJ [[23.4889,-102.875,55.0657,74.4949,-74.5303,106.163],[-54.7101,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperR;
RhomePos;

ENDPROC

PROC pickspoon_large()
MoveAbsJ [[23.4889,-102.875,55.0657,74.4949,-74.5303,106.163],[-54.7101,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperR;
 MoveL [[275.40,-493.34,268.50],[0.00883905,0.707939,-0.706053,-0.0152617],[0,1,1,5],[179.381,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
 g_GripIn;
 MoveL [[275.38,-493.34,112.48],[0.0088492,0.70793,-0.706062,-0.0152809],[0,1,1,5],[-178.274,9E+09,9E+09,9E+09,9E+09,9E+09]], v200, z50, GripperR;
 WaitTime 3;
 g_GripOut;
 g_SetForce 100;
 MoveL [[275.43,-493.35,283.27],[0.00884303,0.707926,-0.706067,-0.0152281],[0,1,1,5],[178.271,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
 WaitTime 1;
 !pick spoon already
 MoveAbsJ [[-3.56175,-80.1984,21.2591,66.5579,67.6568,123.771],[-83.0382,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperR;
 MoveL [[413.59,-150.12,312.45],[0.501306,-0.46313,0.532076,-0.501096],[1,1,0,4],[-118.581,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
 MoveL [[483.03,-150.12,312.37],[0.506025,-0.457945,0.526892,-0.506566],[1,2,0,4],[-118.582,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
 MoveL [[483.03,-150.17,407.23],[0.505947,-0.45792,0.526963,-0.506593],[1,2,0,4],[-127.023,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
 MoveL [[526.72,-150.17,407.23],[0.505948,-0.457922,0.526966,-0.506587],[1,2,0,4],[-127.024,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
     
 MoveL [[583.41,-144.82,390.29],[0.285743,-0.637923,0.646823,-0.304999],[1,3,0,4],[-173.603,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
 ! scoop
 MoveL [[581.37,-144.92,384.01],[0.285742,-0.637844,0.646918,-0.304965],[1,3,0,4],[-173.636,9E+09,9E+09,9E+09,9E+09,9E+09]], v800, z50, GripperR;
 IF targetweight<1.5 THEN
 MoveL [[604.44,-145.13,382.60],[0.285742,-0.637707,0.647103,-0.30486],[1,3,0,4],[-173.722,9E+09,9E+09,9E+09,9E+09,9E+09]], v800, z50, GripperR;
 ELSE
 MoveL [[606.34,-145.14,380.28],[0.285744,-0.637681,0.647137,-0.304839],[1,3,0,4],[-173.738,9E+09,9E+09,9E+09,9E+09,9E+09]], v800, z50, GripperR;
 ENDIF
 MoveL [[583.64,-144.87,353.12],[0.491097,-0.492995,0.527306,-0.487574],[1,2,0,4],[-173.713,9E+09,9E+09,9E+09,9E+09,9E+09]], v300, z50, GripperR;
 MoveAbsJ [[64.4601,-67.7632,49.8184,155.443,62.3276,7.62243],[-58.7256,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v300, z50, GripperR;
 !to make the new spoonshaking more chemical and prepae to shaking 
 MoveL [[583.64,-144.88,353.13],[0.48688,-0.489059,0.531226,-0.491495],[1,2,0,4],[-173.717,9E+09,9E+09,9E+09,9E+09,9E+09]], v300, z50, GripperR;
 MoveAbsJ [[64.8333,-67.5291,49.9963,155.608,63.8068,7.36628],[-58.9384,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v300, z50, GripperR;
 
 FOR i FROM 1 TO 90 DO
      
 MoveAbsJ [[64.4601,-67.7632,49.8184,155.443,62.3276,7.62243],[-58.7256,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v300, z50, GripperR;
 MoveAbsJ [[64.8333,-67.5291,49.9963,155.608,63.8068,7.36628],[-58.9384,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, vmax, z50, GripperR;

 ENDFOR
 MoveL [[572.11,-159.47,376.07],[0.48463,-0.499352,0.533614,-0.480664],[1,2,0,4],[-173.708,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
 MoveL [[616.09,-159.48,418.36],[0.484639,-0.499325,0.533632,-0.480663],[1,2,0,4],[-173.713,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
 ! start to go the shaking point
ENDPROC

PROC pickspoon_medium()

MoveAbsJ [[23.4889,-102.875,55.0657,74.4949,-74.5303,106.163],[-54.7101,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperR;
MoveL [[207.04,-493.78,294.53],[0.00881936,0.707952,-0.706043,-0.0151605],[0,1,1,5],[165.266,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
g_GripIn;
MoveL [[207.00,-493.77,112.33],[0.00882987,0.707948,-0.706046,-0.0151972],[0,1,1,5],[179.36,9E+09,9E+09,9E+09,9E+09,9E+09]], v200, z50, GripperR;
WaitTime 3;
g_GripOut;
g_SetForce 100;
MoveL [[207.11,-493.82,266.29],[0.00885358,0.707966,-0.706031,-0.0150156],[0,1,1,5],[179.395,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
WaitTime 1;
!pick spoon already
MoveAbsJ [[-3.56175,-80.1984,21.2591,66.5579,67.6568,123.771],[-83.0382,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperR;
MoveL [[413.59,-150.12,312.45],[0.501306,-0.46313,0.532076,-0.501096],[1,1,0,4],[-118.581,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[483.03,-150.12,312.37],[0.506025,-0.457945,0.526892,-0.506566],[1,2,0,4],[-118.582,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[483.03,-150.17,407.23],[0.505947,-0.45792,0.526963,-0.506593],[1,2,0,4],[-127.023,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[526.72,-150.17,407.23],[0.505948,-0.457922,0.526966,-0.506587],[1,2,0,4],[-127.024,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;

! ready to dig, near the scoop point 
MoveL [[590.86,-156.73,384.09],[0.264586,-0.646956,0.65655,-0.283522],[1,3,0,4],[-173.625,9E+09,9E+09,9E+09,9E+09,9E+09]], v800, z50, GripperR;
MoveL [[593.52,-156.94,376.73],[0.285743,-0.637746,0.647035,-0.304921],[1,3,0,4],[-173.68,9E+09,9E+09,9E+09,9E+09,9E+09]], v800, z50, GripperR;
MoveL [[583.64,-155.22,349.96],[0.484637,-0.499325,0.533629,-0.480668],[1,2,0,4],[-173.714,9E+09,9E+09,9E+09,9E+09,9E+09]], v300, z50, GripperR;
!prepare to shake
MoveL [[577.41,-156.26,348.43],[0.498636,-0.485348,0.519746,-0.495645],[1,2,0,4],[-173.717,9E+09,9E+09,9E+09,9E+09,9E+09]], v300, z50, GripperR;
MoveAbsJ [[62.6192,-69.5716,49.7987,150.297,60.8667,10.7261],[-60.3644,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v300, z50, GripperR;
MoveL [[577.41,-155.22,348.42],[0.506586,-0.492386,0.51283,-0.487783],[1,2,0,4],[-173.716,9E+09,9E+09,9E+09,9E+09,9E+09]], v300, z50, GripperR;
MoveAbsJ [[62.1179,-69.8589,49.4398,149.896,58.3362,11.3812],[-60.0405,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v300, z50, GripperR;

FOR i FROM 1 TO 90 DO
MoveAbsJ [[62.6192,-69.5716,49.7987,150.297,60.8667,10.7262],[-60.3643,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, vmax, z50, GripperR;

MoveAbsJ [[62.1181,-69.8591,49.4398,149.896,58.3362,11.3812],[-60.0405,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v300, z50, GripperR;

ENDFOR
MoveL [[572.11,-159.47,376.07],[0.48463,-0.499352,0.533614,-0.480664],[1,2,0,4],[-173.708,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveL [[616.09,-159.48,418.36],[0.484639,-0.499325,0.533632,-0.480663],[1,2,0,4],[-173.713,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
! start to go to the shaking point
ENDPROC

PROC pickspoon_small()
! this is the smallest spoon will be used to finish pickspoon and also scoop action
MoveAbsJ [[23.4889,-102.875,55.0657,74.4949,-74.5303,106.163],[-54.7101,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperR;
MoveL [[345.94,-496.83,249.55],[0.00887996,0.707956,-0.706034,-0.0153614],[1,1,1,5],[-178.25,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
g_GripIn;
MoveL [[346.24,-497.72,112.19],[0.0112058,0.719741,-0.693996,-0.014756],[1,1,1,5],[-178.383,9E+09,9E+09,9E+09,9E+09,9E+09]], v200, z50, GripperR;

WaitTime 3;
g_GripOut;
g_SetForce 100;
MoveL [[345.99,-496.86,298.60],[0.00888097,0.707951,-0.706039,-0.0153459],[0,1,1,5],[171.028,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
WaitTime 1;
!pick spoon already
MoveAbsJ [[-3.56175,-80.1984,21.2591,66.5579,67.6568,123.771],[-83.0382,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperR;
MoveL [[413.59,-150.12,312.45],[0.501306,-0.46313,0.532076,-0.501096],[1,1,0,4],[-118.581,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[483.03,-150.12,312.37],[0.506025,-0.457945,0.526892,-0.506566],[1,2,0,4],[-118.582,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[483.03,-150.17,407.23],[0.505947,-0.45792,0.526963,-0.506593],[1,2,0,4],[-127.023,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[526.72,-150.17,407.23],[0.505948,-0.457922,0.526966,-0.506587],[1,2,0,4],[-127.024,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
! ready to scoop, near the scoop point 

MoveL [[594.18,-169.89,381.86],[0.285747,-0.637905,0.646841,-0.304995],[1,3,0,4],[-173.623,9E+09,9E+09,9E+09,9E+09,9E+09]], v800, z50, GripperR;
MoveL [[610.56,-169.91,377.10],[0.285748,-0.637891,0.646859,-0.304986],[1,3,0,4],[-173.64,9E+09,9E+09,9E+09,9E+09,9E+09]], v800, z50, GripperR;
MoveL [[583.64,-155.23,355.09],[0.484645,-0.499298,0.533645,-0.480671],[1,2,0,4],[-173.715,9E+09,9E+09,9E+09,9E+09,9E+09]], v300, z50, GripperR;
MoveAbsJ [[62.5375,-68.6253,49.9754,158.565,60.1563,6.73193],[-56.3994,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v300, z50, GripperR;
!to make the new spoonshaking more chemical and prepae to shaking 
MoveL [[583.64,-155.24,355.10],[0.478528,-0.49375,0.539158,-0.486344],[1,2,0,4],[-173.718,9E+09,9E+09,9E+09,9E+09,9E+09]], v300, z50, GripperR;
MoveAbsJ [[63.0393,-68.2861,50.2591,158.777,62.2909,6.39817],[-56.6784,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v300, z50, GripperR;

FOR i_pre FROM 1 TO 5 DO


MoveAbsJ [[62.5375,-68.6253,49.9754,158.565,60.1563,6.73193],[-56.3994,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, vmax, z50, GripperR;
MoveAbsJ [[63.0393,-68.2861,50.2591,158.777,62.2909,6.39817],[-56.6784,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, vmax, z50, GripperR;

ENDFOR
MoveL [[572.11,-159.47,376.07],[0.48463,-0.499352,0.533614,-0.480664],[1,2,0,4],[-173.708,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveL [[616.09,-159.48,418.36],[0.484639,-0.499325,0.533632,-0.480663],[1,2,0,4],[-173.713,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
! start to go to shaking point
MoveL [[624.12,-159.49,390.79],[0.484648,-0.4993,0.533649,-0.48066],[1,2,0,4],[-173.718,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveAbsJ [[65.0814,-63.804,42.4909,169.384,56.2906,2.0483],[-47.8917,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperR;
ENDPROC

PROC preshaking_large()
calculate_difference;
! this is to shaking the extra chemica to ensure there no much material in spoon avoid spitting too much 
FOR i FROM 1 TO (2-difference)*45  DO

!(1.5-difference)*40
MoveAbsJ [[61.3649,-69.2156,50.7232,160.004,60.9019,5.67889],[-55.6397,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, vmax, z50, GripperR;
MoveAbsJ [[60.9589,-69.7126,49.9293,156.814,57.8666,7.65028],[-56.3405,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v300, z50, GripperR;

 ENDFOR
TPWrite " (shaking_largedifference): " \Num:=difference;
ENDPROC

PROC  preshaking_medium()
calculate_difference;
! this is to shaking the extra chemical to ensure there no much material in spoon avoid spitting too much 
FOR i FROM 1 TO (1-difference)*45  Do

MoveAbsJ [[62.7288,-68.5279,50.6043,158.952,62.3566,5.83528],[-57.2808,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v300, z50, GripperR;

MoveAbsJ [[62.1429,-68.9016,50.1906,158.652,59.1243,6.28089],[-56.9419,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, vmax, z50, GripperR; 
ENDFOR
TPWrite " (shaking_mediumIdifference): " \Num:=difference;
ENDPROC

PROC  preshaking_small()
calculate_difference;
! this is to shaking the extra chemica to ensure there no much material in spoon avoid spitting too much
IF difference<0 THEN
FOR i FROM 1 TO 60 DO
MoveAbsJ [[62.5375,-68.6253,49.9754,158.565,60.1563,6.73193],[-56.3994,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, vmax, z50, GripperR;
MoveAbsJ [[63.0393,-68.2861,50.2591,158.777,62.2909,6.39817],[-56.6784,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, vmax, z50, GripperR;

ENDFOR

ELSEIF difference>0 AND difference<=0.02 THEN

IF difference<=0.01  THEN   
    FOR i FROM 1 TO 10 DO
!   
MoveAbsJ [[62.5375,-68.6253,49.9754,158.565,60.1563,6.73193],[-56.3994,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, vmax, z50, GripperR;
MoveAbsJ [[63.0393,-68.2861,50.2591,158.777,62.2909,6.39817],[-56.6784,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, vmax, z50, GripperR;

ENDFOR 
ELSEIF difference<=0.005  THEN
    
    FOR i FROM 1 TO 12 DO
!   
MoveAbsJ [[62.5375,-68.6253,49.9754,158.565,60.1563,6.73193],[-56.3994,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, vmax, z50, GripperR;
MoveAbsJ [[63.0393,-68.2861,50.2591,158.777,62.2909,6.39817],[-56.6784,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, vmax, z50, GripperR;

ENDFOR 

ELSE
FOR i FROM 1 TO 8 DO
!   
MoveAbsJ [[62.5375,-68.6253,49.9754,158.565,60.1563,6.73193],[-56.3994,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, vmax, z50, GripperR;
MoveAbsJ [[63.0393,-68.2861,50.2591,158.777,62.2909,6.39817],[-56.6784,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, vmax, z50, GripperR;

ENDFOR

ENDIF
ELSEIF difference>=0.02 AND difference<=0.05  THEN
TPWrite " (shaking_smallIdifference): " \Num:=difference;
ENDIF
ENDPROC

PROC shakespoon_large()
g_SetForce 100;
MoveL [[630.23,-159.50,416.58],[0.490508,-0.482237,0.521668,-0.50469],[1,2,0,4],[-173.751,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveL [[630.20,-159.52,430.94],[0.308108,-0.623888,0.655381,-0.293785],[1,3,0,4],[-173.764,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveAbsJ [[62.2232,-52.0984,29.6084,238.121,70.2173,-33.9595],[-20.6803,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v500, z50, GripperR;
FOR i FROM 1 TO 20 DO
MoveAbsJ [[62.2233,-52.0983,29.6082,238.121,70.2173,-33.9594],[-20.6806,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v2000, z50, GripperR;
MoveAbsJ [[62.399,-51.7411,29.7615,237.392,71.337,-33.3108],[-20.7692,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v2000, z50, GripperR;
ENDFOR
!movel 
MoveL [[630.23,-159.51,416.59],[0.49052,-0.482214,0.521684,-0.504684],[1,2,0,4],[-173.752,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
ENDPROC

PROC shakespoon_medium()
g_SetForce 100;
WHILE  shake=1000 DO ! 1000 means balance unstable
Waittime 0.5;
ENDWHILE 
shake_no:=shake;
MoveL [[630.23,-159.50,416.58],[0.490508,-0.482237,0.521668,-0.50469],[1,2,0,4],[-173.751,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveL [[630.22,-159.51,416.57],[0.364184,-0.592918,0.625567,-0.352825],[1,2,0,4],[-173.746,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveAbsJ [[62.8391,-56.8099,36.4882,220.747,63.4015,-25.0195],[-27.6267,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v500, z50, GripperR;
FOR i_pre1 FROM 1 TO shake_no DO
MoveAbsJ [[62.8391,-56.8099,36.4882,220.747,63.4015,-25.0195],[-27.6267,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v2000, z50, GripperR;
MoveAbsJ [[63.1537,-56.3065,36.7472,219.836,65.3443,-24.1598],[-27.785,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v2000, z50, GripperR;
ENDFOR
!movel 
MoveL [[630.23,-159.50,416.58],[0.490508,-0.482237,0.521668,-0.50469],[1,2,0,4],[-173.751,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
TPWrite "shaking medium spoon";
ENDPROC

PROC shakespoon_small()
g_SetForce 100;
WHILE  angle=1000 DO 
Waittime 0.5;
ENDWHILE 
angle:= a_smallspoon;
MoveAbsJ [[65.0816,-63.804,42.4909,169.384,56.2906,2.0483],[-47.8916,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperR;
MoveAbsJ [[65.0816,-63.804,42.4909,169.384,56.2906,2.0483-angle],[-47.8916,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperR;

WaitTime n;

MoveAbsJ [[65.0816,-63.804,42.4909,169.384,56.2906,2.0483],[-47.8916,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperR;
MoveL [[630.23,-159.50,416.58],[0.490508,-0.482237,0.521668,-0.50469],[1,2,0,4],[-173.751,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;

ENDPROC

PROC scoop_large()
! scoop another 
MoveL [[630.23,-159.50,416.58],[0.490508,-0.482237,0.521668,-0.50469],[1,2,0,4],[-173.751,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;

MoveL [[542.30,-159.10,416.60],[0.490522,-0.482205,0.521682,-0.504692],[1,2,0,4],[-173.757,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
IF difference>0.7 THEN
MoveL [[585.41,-166.10,376.34],[0.335201,-0.600588,0.642577,-0.337682],[1,2,0,4],[-173.807,9E+09,9E+09,9E+09,9E+09,9E+09]], v800, z50, GripperR;
MoveL [[607.14,-166.30,372.40],[0.335232,-0.600391,0.642773,-0.337629],[1,2,0,4],[-173.891,9E+09,9E+09,9E+09,9E+09,9E+09]], v800, z50, GripperR;
ELSE
MoveL [[589.05,-166.09,376.33],[0.335197,-0.600608,0.642558,-0.337686],[1,2,0,4],[-173.803,9E+09,9E+09,9E+09,9E+09,9E+09]], v800, z50, GripperR;
MoveL [[604.42,-166.21,372.10],[0.335219,-0.60047,0.642693,-0.337653],[1,2,0,4],[-173.863,9E+09,9E+09,9E+09,9E+09,9E+09]], v800, z50, GripperR;
ENDIF

MoveL [[580.84,-163.20,354.80],[0.472188,-0.499965,0.540308,-0.484914],[1,2,0,4],[-173.834,9E+09,9E+09,9E+09,9E+09,9E+09]], v300, z50, GripperR;
MoveAbsJ [[61.3649,-69.2156,50.7232,160.004,60.9019,5.67889],[-55.6397,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v300, z50, GripperR;

! shaking much chemical 
MoveL [[580.84,-162.41,354.82],[0.488291,-0.502264,0.525608,-0.482742],[1,2,0,4],[-173.844,9E+09,9E+09,9E+09,9E+09,9E+09]], v300, z50, GripperR;
MoveAbsJ [[60.9589,-69.7126,49.9293,156.814,57.8666,7.65028],[-56.3405,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v300, z50, GripperR;


preshaking_large;
! up
MoveL [[573.63,-155.66,386.20],[0.477996,-0.505204,0.53515,-0.479482],[1,2,0,4],[-173.836,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
! start to the preshaking point which related to the shaking point

MoveL [[630.23,-159.50,416.58],[0.490508,-0.482237,0.521668,-0.50469],[1,2,0,4],[-173.751,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
ENDPROC

PROC scoop_medium ()
MoveL [[630.23,-159.50,416.58],[0.490508,-0.482237,0.521668,-0.50469],[1,2,0,4],[-173.751,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
!
! dig another time for spoon 2
MoveL [[542.30,-159.10,416.60],[0.490522,-0.482205,0.521682,-0.504692],[1,2,0,4],[-173.757,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[587.51,-155.58,377.77],[0.29837,-0.619695,0.661792,-0.298304],[1,3,0,4],[-173.829,9E+09,9E+09,9E+09,9E+09,9E+09]], v800, z50, GripperR;
MoveL [[593.14,-155.79,370.16],[0.335235,-0.600368,0.642794,-0.337627],[1,2,0,4],[-173.883,9E+09,9E+09,9E+09,9E+09,9E+09]], v800, z50, GripperR;
MoveL [[580.84,-155.64,349.90],[0.472172,-0.500018,0.540278,-0.484907],[1,2,0,4],[-173.83,9E+09,9E+09,9E+09,9E+09,9E+09]], v300, z50, GripperR;
MoveAbsJ [[62.7288,-68.5279,50.6043,158.952,62.3566,5.83528],[-57.2808,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v300, z50, GripperR;


! shaking much chemical 
MoveL [[580.84,-153.82,349.91],[0.482479,-0.509222,0.531115,-0.47521],[1,2,0,4],[-173.838,9E+09,9E+09,9E+09,9E+09,9E+09]], v300, z50, GripperR;
MoveAbsJ [[62.1429,-68.9016,50.1906,158.652,59.1243,6.28089],[-56.9419,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v300, z50, GripperR;



preshaking_medium;
! up
MoveL [[573.63,-155.66,386.20],[0.477996,-0.505204,0.53515,-0.479482],[1,2,0,4],[-173.836,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
! start to the preshaking point which related to the shaking point

MoveL [[630.23,-159.50,416.58],[0.490508,-0.482237,0.521668,-0.50469],[1,2,0,4],[-173.751,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;

ENDPROC

PROC scoop_small()
MoveL [[630.23,-159.50,416.58],[0.490508,-0.482237,0.521668,-0.50469],[1,2,0,4],[-173.751,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;

! scoop
MoveL [[548.30,-159.11,416.62],[0.490535,-0.482176,0.52169,-0.504699],[1,2,0,4],[-173.76,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveL [[548.30,-159.11,383.61],[0.490533,-0.482175,0.521691,-0.504701],[1,2,0,4],[-173.765,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveL [[586.88,-155.55,377.88],[0.335198,-0.600609,0.642559,-0.337682],[1,2,0,4],[-173.794,9E+09,9E+09,9E+09,9E+09,9E+09]], v300, z50, GripperR;
MoveL [[602.26,-155.62,368.87],[0.335205,-0.600549,0.64262,-0.337666],[1,2,0,4],[-173.822,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveL [[580.84,-155.65,351.80],[0.472181,-0.499993,0.540294,-0.484906],[1,2,0,4],[-173.83,9E+09,9E+09,9E+09,9E+09,9E+09]], v300, z50, GripperR;
MoveAbsJ [[62.6168,-68.5074,50.7802,159.385,62.3895,5.61061],[-56.8693,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v300, z50, GripperR;


! shaking much chemical 
MoveL [[580.84,-155.66,351.81],[0.484006,-0.510551,0.52975,-0.473752],[1,2,0,4],[-173.835,9E+09,9E+09,9E+09,9E+09,9E+09]], v300, z50, GripperR;
MoveL [[583.64,-155.24,355.10],[0.478528,-0.49375,0.539158,-0.486344],[1,2,0,4],[-173.718,9E+09,9E+09,9E+09,9E+09,9E+09]], v300, z50, GripperR;
MoveAbsJ [[63.0393,-68.2861,50.2591,158.777,62.2909,6.39817],[-56.6784,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v300, z50, GripperR;

preshaking_small;
! up
MoveL [[573.63,-155.66,386.20],[0.477996,-0.505204,0.53515,-0.479482],[1,2,0,4],[-173.836,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
! start to the preshaking point which related to the shaking point

MoveL [[630.23,-159.50,416.58],[0.490508,-0.482237,0.521668,-0.50469],[1,2,0,4],[-173.751,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
   

ENDPROC
PROC open_door()
! slide the door to open
MoveAbsJ [[14.3117,-123.368,33.6186,31.009,53.4378,86.9471],[-110.566,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperR;
g_GripIn;
MoveL [[407.13,-80.30,134.57],[0.471548,-0.517042,0.492907,-0.517061],[1,1,0,4],[-114.73,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[622.25,-80.02,133.89],[0.488575,-0.50028,0.509906,-0.501009],[1,1,0,4],[-112.49,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
WaitTime 2;
g_GripOut;
g_SetForce 40;

MoveL [[621.39,-204.80,134.36],[0.476633,-0.505472,0.51345,-0.503674],[1,1,0,4],[-103.385,9E+09,9E+09,9E+09,9E+09,9E+09]], v300, z50, GripperR;
!MoveL [[621.78,-219.16,134.11],[0.476179,-0.505725,0.513876,-0.503415],[1,1,0,4],[-103.373,9E+09,9E+09,9E+09,9E+09,9E+09]], v400, z50, GripperR;
WaitTime 2;
g_GripIn;
MoveL [[532.13,-204.83,134.31],[0.476537,-0.505516,0.513533,-0.503636],[1,1,0,4],[-103.384,9E+09,9E+09,9E+09,9E+09,9E+09]], v400, z50, GripperR;
MoveL [[251.03,-219.16,134.11],[0.476185,-0.505728,0.513857,-0.503427],[0,0,1,4],[-108.482,9E+09,9E+09,9E+09,9E+09,9E+09]], v400, z50, GripperR;

ENDPROC
PROC close_door()
! close the door
g_GripIn;
MoveAbsJ [[54.7576,-128.75,28.7597,51.6867,37.729,57.2685],[-89.9813,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperR;
!MoveL [[620.70,-217.52,133.10],[0.496147,-0.492701,0.493233,-0.517498],[1,1,0,4],[-120.559,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[621.39,-204.80,134.36],[0.476633,-0.505472,0.51345,-0.503674],[1,1,0,4],[-103.385,9E+09,9E+09,9E+09,9E+09,9E+09]], v400, z50, GripperR;
WaitTime 2;
g_GripOut;
g_SetForce 20;
WaitTime 1;
!MoveL [[621.39,-204.80,134.36],[0.476633,-0.505472,0.51345,-0.503674],[1,1,0,4],[-103.385,9E+09,9E+09,9E+09,9E+09,9E+09]], v400, z50, GripperR;
!MoveL [[623.36,-78.81,134.57],[0.488588,-0.500269,0.509909,-0.501005],[1,1,0,4],[-112.491,9E+09,9E+09,9E+09,9E+09,9E+09]], v400, z50, GripperR;
MoveL [[622.25,-80.02,133.89],[0.488575,-0.50028,0.509906,-0.501009],[1,1,0,4],[-112.49,9E+09,9E+09,9E+09,9E+09,9E+09]], v50, z50, GripperR;
!MoveL [[621.39,-80.10,134.34],[0.476601,-0.505499,0.513464,-0.503665],[1,1,0,4],[-103.379,9E+09,9E+09,9E+09,9E+09,9E+09]], v150, z50, GripperR;
WaitTime 8;
g_GripIn;
MoveL [[377.58,-78.81,134.57],[0.488576,-0.500275,0.509905,-0.501015],[1,1,0,4],[-118.854,9E+09,9E+09,9E+09,9E+09,9E+09]], v400, z50, GripperR;
RhomePos;

ENDPROC

PROC vial_inscale()
! put the vial in scale 

MoveAbsJ [[30.0093,-137.244,27.5263,29.2448,45.9256,74.6106],[-109.971,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperR;
g_GripIn;
MoveL [[251.03,-1.85,134.11],[0.476175,-0.505725,0.513867,-0.503429],[1,1,0,4],[-131.393,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[366.05,-8.34,59.36],[0.476147,-0.50571,0.513879,-0.503457],[1,1,0,4],[-131.388,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
WaitTime 2;
g_GripOut;
g_SetForce 40;
MoveL [[366.06,-8.35,146.61],[0.476143,-0.505691,0.513882,-0.503478],[1,1,0,4],[-131.388,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[539.14,-8.33,144.22],[0.476134,-0.505721,0.513893,-0.503445],[1,1,0,4],[-131.389,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[529.54,-97.67,197.06],[0.476093,-0.505717,0.513913,-0.503467],[1,1,0,4],[-131.384,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[529.54,-97.68,197.06],[0.400263,-0.431054,0.57494,-0.568705],[1,1,0,4],[-131.383,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[529.54,-97.69,161.12],[0.40025,-0.431052,0.574945,-0.568711],[1,1,0,4],[-131.382,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[686.94,-138.02,154.29],[0.399902,-0.43123,0.575346,-0.568415],[1,1,0,4],[-131.395,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[719.50,-149.78,153.27],[0.399835,-0.431297,0.57536,-0.568398],[1,1,0,4],[-131.4,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
WaitTime 2;
g_GripIn;
WaitTime 1;
MoveL [[563.51,-96.68,158.26],[0.399888,-0.431235,0.575351,-0.568416],[1,1,0,4],[-131.397,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveAbsJ [[14.3117,-123.368,33.6186,31.009,53.4378,86.9471],[-110.566,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperR;
ENDPROC
PROC vial_outscale()
! pick out the vial in scale to the hole

MoveAbsJ [[30.0093,-137.244,27.5263,29.2448,45.9256,74.6106],[-109.971,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperR;
g_GripIn;

MoveL [[366.05,-8.33,144.23],[0.476152,-0.505712,0.513874,-0.503457],[1,1,0,4],[-131.391,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[529.54,-97.67,197.06],[0.476093,-0.505717,0.513913,-0.503467],[1,1,0,4],[-131.384,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[529.54,-97.68,197.06],[0.400263,-0.431054,0.57494,-0.568705],[1,1,0,4],[-131.383,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[608.10,-124.69,197.06],[0.40024,-0.431059,0.574961,-0.568696],[1,1,0,4],[-131.385,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[717.89,-148.24,170.32],[0.400192,-0.431094,0.575,-0.568664],[1,1,0,4],[-131.395,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[719.50,-149.78,153.25],[0.399822,-0.431311,0.575361,-0.568394],[1,1,0,4],[-131.4,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
WaitTime 2;
g_GripOut;
g_SetForce 40;
WaitTime 1;
MoveL [[686.94,-138.02,154.29],[0.399902,-0.43123,0.575346,-0.568415],[1,1,0,4],[-131.395,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[380.07,-147.00,182.80],[0.400176,-0.431097,0.575,-0.568673],[1,1,0,4],[-131.399,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[366.05,-8.34,165.44],[0.476146,-0.505701,0.513879,-0.503468],[1,1,0,4],[-131.39,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[367.13,-8.33,71.38],[0.476143,-0.505721,0.513869,-0.503461],[1,1,0,4],[-131.388,9E+09,9E+09,9E+09,9E+09,9E+09]], v400, z50, GripperR;
WaitTime 2;
g_GripIn;
MoveL [[366.05,-8.34,197.05],[0.476147,-0.505696,0.513882,-0.503469],[1,1,0,4],[-131.39,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[366.06,-301.69,197.06],[0.476151,-0.505669,0.513868,-0.503506],[0,1,1,4],[-131.391,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;

ENDPROC

PROC backspoon_large()
! this to back the largest spoon to pos 1
MoveL [[630.23,-159.51,416.59],[0.490521,-0.482214,0.521682,-0.504685],[1,2,0,4],[-173.752,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveL [[567.13,-159.51,416.61],[0.490524,-0.482205,0.521689,-0.504684],[1,2,0,4],[-173.753,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveL [[579.10,-142.09,350.70],[0.490546,-0.482128,0.521731,-0.504691],[1,2,0,4],[-173.775,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveL [[579.10,-137.29,352.29],[0.503274,0.523111,0.48191,0.490747],[1,2,2,4],[-173.798,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;


MoveL [[579.10,-137.30,352.30],[0.497222,0.516958,0.488128,0.497249],[1,2,2,4],[-173.803,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;


MoveAbsJ [[65.4105,-67.6042,50.4513,151.655,64.1904,188.312],[-61.0257,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v500, z50, GripperR;
MoveAbsJ [[66.0506,-67.25,50.6911,151.919,66.4762,187.852],[-61.3977,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v500, z50, GripperR;

FOR i FROM 1 TO 50 DO
MoveAbsJ [[65.4105,-67.6042,50.4513,151.655,64.1904,188.312],[-61.0257,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v300, z50, GripperR;
MoveAbsJ [[66.0506,-67.25,50.6911,151.919,66.4762,187.852],[-61.3977,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, vmax, z50, GripperR;

ENDFOR

MoveL [[579.11,-150.08,352.30],[0.503279,0.523124,0.481884,0.490754],[1,2,2,4],[-173.802,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveL [[579.11,-150.08,352.30],[0.511387,-0.459568,0.542835,-0.482298],[1,2,0,4],[-173.804,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveL [[579.10,-152.40,408.19],[0.490536,-0.482148,0.521716,-0.504698],[1,2,0,4],[-173.769,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;

MoveL [[579.10,-327.71,408.20],[0.490535,-0.482128,0.521736,-0.504696],[1,2,0,4],[-173.771,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveL [[310.18,-493.61,409.08],[0.491499,-0.510277,0.513438,-0.484176],[0,1,1,4],[-157.273,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveAbsJ [[31.0917,-91.0975,11.1301,92.5237,-80.2166,72.8247],[-40.8142,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v500, z50, GripperR;
MoveL [[275.39,-493.35,114.66],[0.00884724,0.707927,-0.706065,-0.0152671],[0,1,1,5],[-178.276,9E+09,9E+09,9E+09,9E+09,9E+09]], v200, z50, GripperR;
WaitTime 4;
g_GripIn;
WaitTime 1;
MoveL [[275.45,-493.36,320.78],[0.00881921,0.707927,-0.706066,-0.0152248],[0,1,1,5],[156.756,9E+09,9E+09,9E+09,9E+09,9E+09]], v2000, z50, GripperR;

MoveAbsJ [[23.4889,-102.875,55.0657,74.4949,-74.5303,106.163],[-54.7101,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperR;
RhomePos;

ENDPROC

PROC backspoon_meidum()
! this to back the largest spoon to pos 1
MoveL [[630.23,-159.51,416.59],[0.490521,-0.482214,0.521682,-0.504685],[1,2,0,4],[-173.752,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveL [[567.13,-159.51,416.61],[0.490524,-0.482205,0.521689,-0.504684],[1,2,0,4],[-173.753,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveL [[574.95,-152.44,357.72],[0.516729,-0.465351,0.529556,-0.485808],[1,2,0,4],[-173.802,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveL [[579.10,-151.83,357.71],[0.474192,0.532984,0.467412,0.522107],[1,2,-2,4],[-173.799,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;


MoveAbsJ [[62.8063,-68.937,50.4102,152.105,61.4427,-166.023],[-58.8012,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v500, z50, GripperR;
MoveAbsJ [[62.6261,-69.0533,50.2579,151.84,60.4264,-165.761],[-58.725,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v500, z50, GripperR;

FOR i FROM 1 TO 30 DO
MoveAbsJ [[62.8063,-68.937,50.4102,152.105,61.4427,-166.023],[-58.8012,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, vmax, z50, GripperR;
MoveAbsJ [[62.6261,-69.0533,50.2579,151.84,60.4264,-165.761],[-58.725,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v300, z50, GripperR;

ENDFOR
MoveL [[579.10,-152.39,354.88],[0.49053,-0.482178,0.521702,-0.504691],[1,2,0,4],[-173.766,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveL [[554.18,-149.93,363.22],[0.497972,-0.494599,0.522783,-0.483833],[1,2,0,4],[-173.864,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveL [[594.10,-149.90,453.24],[0.179419,-0.667999,0.694777,-0.197157],[1,3,0,4],[-173.838,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveAbsJ [[59.4587,-44.3902,21.7615,259.937,90.1494,-40.6778],[-9.78292,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v500, z50, GripperR;
FOR i FROM 1 TO 30 DO
MoveAbsJ [[59.4587,-44.3902,21.7615,259.937,90.1494,-40.6778],[-9.78292,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v300, z50, GripperR;
MoveAbsJ [[59.559,-44.0744,21.7926,259.463,90.8046,-39.0948],[-9.84801,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, vmax, z50, GripperR;
ENDFOR

MoveL [[554.18,-149.93,363.22],[0.497972,-0.494599,0.522783,-0.483833],[1,2,0,4],[-173.864,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;

MoveL [[579.10,-327.71,408.20],[0.490535,-0.482128,0.521736,-0.504696],[1,2,0,4],[-173.771,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveL [[310.18,-493.61,409.08],[0.491499,-0.510277,0.513438,-0.484176],[0,1,1,4],[-157.273,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveAbsJ [[18.7633,-93.915,16.6342,97.6689,-65.9458,65.5504],[-55.3097,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v500, z50, GripperR;
MoveL [[207.00,-493.77,113.80],[0.00882987,0.707948,-0.706046,-0.0151972],[0,1,1,5],[179.36,9E+09,9E+09,9E+09,9E+09,9E+09]], v200, z50, GripperR;


WaitTime 4;
g_GripIn;
WaitTime 1;
MoveL [[207.46,-494.70,269.08],[0.0088464,0.707949,-0.706047,-0.0150725],[0,1,1,5],[167.44,9E+09,9E+09,9E+09,9E+09,9E+09]], v2000, z50, GripperR;

MoveAbsJ [[23.4889,-102.875,55.0657,74.4949,-74.5303,106.163],[-54.7101,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperR;
RhomePos;


ENDPROC

PROC backspoon_small()
! this is to back the sugar and also drop the spoon
MoveL [[630.23,-159.51,416.59],[0.490521,-0.482214,0.521682,-0.504685],[1,2,0,4],[-173.752,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveL [[567.13,-159.51,416.61],[0.490524,-0.482205,0.521689,-0.504684],[1,2,0,4],[-173.753,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveL [[579.10,-152.39,354.88],[0.49053,-0.482178,0.521702,-0.504691],[1,2,0,4],[-173.766,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveL [[579.10,-152.40,354.89],[0.482646,0.542402,0.458756,0.512247],[1,2,-2,4],[-173.792,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;

MoveL [[579.10,-152.40,354.89],[0.477087,0.536192,0.464533,0.518744],[1,2,-2,4],[-173.794,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;


MoveAbsJ [[63.5175,-68.626,50.4493,151.996,63.6106,-166.267],[-59.6394,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v500, z50, GripperR;
MoveAbsJ [[62.9799,-68.9676,50.1321,151.471,61.423,-165.687],[-59.398,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v500, z50, GripperR;



FOR i FROM 1 TO 50 DO
MoveAbsJ [[63.5175,-68.626,50.4493,151.996,63.6106,-166.267],[-59.6394,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, vmax, z50, GripperR;
MoveAbsJ [[62.9799,-68.9676,50.1321,151.471,61.423,-165.687],[-59.398,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v300, z50, GripperR;


ENDFOR
MoveL [[579.10,-152.39,354.88],[0.49053,-0.482178,0.521702,-0.504691],[1,2,0,4],[-173.766,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveL [[579.10,-152.40,408.19],[0.490536,-0.482148,0.521716,-0.504698],[1,2,0,4],[-173.769,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveL [[579.10,-327.71,408.20],[0.490535,-0.482128,0.521736,-0.504696],[1,2,0,4],[-173.771,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveL [[310.18,-493.61,409.08],[0.491499,-0.510277,0.513438,-0.484176],[0,1,1,4],[-157.273,9E+09,9E+09,9E+09,9E+09,9E+09]], v500, z50, GripperR;
MoveAbsJ [[40.85,-80.1037,-1.93773,91.7756,-85.564,74.6621],[-36.0564,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v500, z50, GripperR;
MoveL [[346.25,-497.73,114.16],[0.0112119,0.719736,-0.694001,-0.0147469],[1,1,1,5],[-178.389,9E+09,9E+09,9E+09,9E+09,9E+09]], v200, z50, GripperR;

WaitTime 4;
g_GripIn;
WaitTime 1;
MoveL [[345.30,-496.87,221.64],[0.00890158,0.707937,-0.706053,-0.0153288],[1,1,1,5],[-177.077,9E+09,9E+09,9E+09,9E+09,9E+09]], v2000, z50, GripperR;

MoveAbsJ [[23.4889,-102.875,55.0657,74.4949,-74.5303,106.163],[-54.7101,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperR;
RhomePos;


ENDPROC


PROC funnelorspoon_bocking()
i:=1;

! continue 5 times the weight keep the same and no change 
WHILE i <15 DO 
IF weight{i}=weight{i+1} THEN
i:=i+1;
waittime 0.2;
ELSE
i:=666;
ENDIF

ENDWHILE 


IF i=15 THEN

! blocking happen 
switch:=FALSE;
blocking:=TRUE;
StopMove;

ENDIF

ENDPROC

PROC saveweight()
!save weight to the weight{6}

IF i=0 THEN
weight{15}:=recv_reading;
else
weight{i}:=recv_reading;
endif

ENDPROC

PROC back_vial()
! this need to cooperate with left arm to back the vial to the rack

 MoveAbsJ [[21.6821,-110.547,36.8653,53.5029,65.5555,68.8954],[-118.931,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperR;
 g_GripIn;
 MoveL [[235.60,-31.48,201.75],[0.48029,-0.459006,0.536146,-0.520752],[0,0,0,4],[-129.953,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
 MoveL [[365.27,0.87,130.43],[0.496534,-0.475029,0.521093,-0.506225],[1,1,0,4],[-130.287,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
 MoveL [[653.79,0.85,130.40],[0.496485,-0.47506,0.521127,-0.506209],[1,1,0,4],[-130.287,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
 MoveL [[653.79,0.84,122.94],[0.496473,-0.475053,0.52114,-0.506214],[1,1,0,4],[-130.287,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
 WaitTime 3;
 g_GripOut;
 g_SetForce 40;
 WaitTime 2;
 MoveL [[653.80,0.83,129.99],[0.496449,-0.475041,0.521167,-0.506221],[1,1,0,4],[-130.286,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
 MoveL [[389.09,-13.46,130.00],[0.496442,-0.475043,0.52117,-0.506222],[1,1,0,4],[-130.285,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
 MoveL [[396.36,-11.12,151.54],[0.496414,-0.475006,0.521174,-0.506281],[1,1,0,4],[-130.273,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
 MoveL [[396.36,-11.11,62.60],[0.496422,-0.475011,0.521178,-0.506264],[1,1,0,4],[-130.274,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
 WaitTime 3;
 g_GripIn;
 WaitTime 2;
 MoveL [[396.36,-11.12,235.67],[0.496413,-0.474983,0.521193,-0.506284],[1,1,0,4],[-130.272,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
 MoveAbsJ [[17.5099,-107.962,13.0204,43.0656,98.3991,77.5041],[-141.153,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperR;
 RhomePos;

ENDPROC

PROC turn_vial()
! back the chemical to the hopper
MoveL [[366.05,-8.34,165.44],[0.476144,-0.505707,0.513868,-0.503475],[1,1,0,4],[-131.39,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[371.75,-11.11,62.60],[0.496412,-0.475022,0.521173,-0.506269],[1,1,0,4],[-130.273,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
WaitTime 3;
g_GripOut;
g_SetForce 100;
MoveL [[371.76,-11.13,260.42],[0.496398,-0.474996,0.521178,-0.506301],[1,1,0,4],[-130.271,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[552.83,-61.46,404.25],[0.496357,-0.475042,0.521232,-0.506243],[1,2,0,4],[-130.268,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[647.40,-93.63,425.34],[0.496363,-0.475041,0.521242,-0.506228],[1,2,0,4],[-130.271,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[647.45,-126.92,425.34],[0.69826,-0.0829546,0.700338,-0.122796],[1,2,0,4],[-130.278,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[656.10,-148.74,387.49],[0.522908,0.504699,0.492576,0.478764],[1,2,2,4],[-130.307,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
FOR i FROM 1 TO 20 DO
MoveAbsJ [[100.446,-87.9159,36.7644,164.244,52.1147,138.256],[-42.5231,9E+09,9E+09,9E+09,9E+09,9E+09]]\NoEOffs, v1000, z50, GripperR;
MoveL [[656.10,-148.74,387.49],[0.522908,0.504699,0.492576,0.478764],[1,2,2,4],[-130.307,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
ENDFOR
WaitTime 2;
MoveL [[647.39,-93.63,425.34],[0.496374,-0.475034,0.521248,-0.506217],[1,2,0,4],[-130.271,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[559.10,-93.65,425.36],[0.496386,-0.475017,0.521263,-0.506206],[1,2,0,4],[-130.271,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[372.64,-11.79,79.20],[0.49638,-0.474891,0.521214,-0.50638],[1,1,0,4],[-130.265,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
MoveL [[372.64,-11.79,71.59],[0.49638,-0.47489,0.521215,-0.50638],[1,1,0,4],[-130.264,9E+09,9E+09,9E+09,9E+09,9E+09]], v100, z50, GripperR;
WaitTime 2;
g_GripIn;
MoveL [[396.36,-11.12,235.67],[0.496413,-0.474983,0.521193,-0.506284],[1,1,0,4],[-130.272,9E+09,9E+09,9E+09,9E+09,9E+09]], v1000, z50, GripperR;
RhomePos;

ENDPROC


ENDMODULE