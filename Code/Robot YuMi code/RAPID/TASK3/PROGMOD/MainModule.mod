MODULE MainModule
    
    VAR socketdev scaleServerSocket;
    VAR socketdev scaleClientSocket;
    VAR bool scaleClient_connected := FALSE;
    VAR socketdev commandServerSocket;
    VAR socketdev commandClientSocket;
    VAR bool commandClient_connected := FALSE;
    VAR socketstatus scaleSocketStat;
    VAR socketstatus commandSocketStat;
    VAR string client_ip;
    VAR string scale_recv_msg;
    VAR string command_recv_msg;
    PERS num recv_reading;
    PERS num recv_target_weight;
    PERS bool ready_new_command;
    PERS bool client_connected := TRUE;
    VAR bool ready; ! the error and now weight ready
    PERS num difference:=2.94725;
    PERS num result{5};!first parameter is precision, 2nd is difference, 3nd is targetweight, 4nd sample num, 5nd default state value 
    VAR num no_vials_now:=0;
    PERS bool send_result;
    PERS bool recv_stable;
    VAR clock timer;
    PERS num command{4}; ! 1 is the target weight, 2 is fuzzy controller out put shaking , 3 is rec_weigh 4is angle 
    PERS num shake;
    VAR string rec_json;! should 1 means connected 
    VAR bool con_rec;
    pers bool weight_vial_reday;
    PERS num weight_vial;
    PERS num a_smallspoon;


    
    
    PROC ServerStart(bool Recover)
        IF Recover THEN
            TPWrite "ServerStart with recovery";
            SocketClose scaleServerSocket;
            SocketClose scaleClientSocket;
            SocketClose commandServerSocket;
            SocketClose commandClientSocket;
        ELSE
            TPWrite "ServerStart without recovery";
        ENDIF
        SocketCreate scaleServerSocket;
        SocketBind scaleServerSocket, "192.168.125.1", 1025;
        recv_reading := 0;
        TPWrite "scale socket binded";
        SocketCreate commandServerSocket;
        SocketBind commandServerSocket, "192.168.125.1", 1023;
        TPWrite "command socket binded";
        SocketListen scaleServerSocket;
        SocketListen commandServerSocket;
        scaleSocketStat := SocketGetStatus(scaleServerSocket);
        commandSocketStat := SocketGetStatus(commandServerSocket);
        IF (scaleSocketStat = SOCKET_LISTENING) AND (commandSocketStat = SOCKET_LISTENING)THEN
            TPWrite "listening for connection on scale server";
            SocketAccept scaleServerSocket, scaleClientSocket\ClientAddress:=client_ip, \Time:=30;
            scaleClient_connected := TRUE;
            TPWrite "scale client accepted for connection from "+ client_ip;
            
            TPWrite "listening for connection on command server";
            SocketAccept commandServerSocket, commandClientSocket\ClientAddress:=client_ip, \Time:=30;
            commandClient_connected := TRUE;
            TPWrite "command client accepted for connection from "+ client_ip;
            client_connected := scaleClient_connected AND commandClient_connected;
        ENDIF
        
        ERROR
            IF ERRNO=ERR_SOCK_TIMEOUT THEN
                TPWrite "Socket connection timed out while listenning";
                RETRY;
            ELSEIF ERRNO=ERR_SOCK_CLOSED THEN
                TPWrite "Can't start a server. Socket is  closed";
                RETURN;
            ELSE
                TPWrite "Unknown error";
                RETURN;
            ENDIF
    ENDPROC
    PROC Parsemsg(string msg)! this is to assign the receieved message to command which include the fuzzy controlling parameters

!//Local variables
        VAR bool auxOk;
        VAR num ind:=1;
        VAR num newInd;
        VAR num length;
        VAR num indParam:=1;
        VAR string subString;
        VAR bool end:=FALSE;
        VAR num nParams;

        !//Find the end character
        length:=StrMatch(msg,1,"#");
        IF length>StrLen(msg) THEN
            !//Corrupt message
            nParams:=-1;
   
        ELSE    
              
                !//
                WHILE end=FALSE DO
                    newInd:=StrMatch(msg,ind," ")+1;
                    IF newInd>length THEN
                        end:=TRUE;
                    ELSE
                        subString:=StrPart(msg,ind,newInd-ind-1);
                        auxOk:=StrToVal(subString,command{indParam});
                        indParam:=indParam+1;
                        ind:=newInd;
                    ENDIF
                ENDWHILE
                nParams:=indParam-1;
            
     ENDIF
    ENDPROC
    
    PROC main()

        weight_vial_reday:=false;
        con_rec:=FALSE;
        send_result:=False;!
        recv_stable:=FALSE;
        ready:=FALSE;
        client_connected := false;!
        ready_new_command := TRUE;
        ServerStart FALSE;
        WHILE client_connected = TRUE DO
            SocketReceive scaleClientSocket \Str := rec_json;
            
          IF send_result THEN ! send_result true means dispensing process end and the result is ready to be sent
              Socketsend scaleClientSocket \Str :=numToStr(result{1},5)+" " + numToStr(result{2},4)+" "+ ValToStr(result{3})+" "+numToStr(result{4},1);  
              !send_result:=FALSE;
              
              TPWrite "result"+ ValToStr(result{1})+" " + ValToStr(result{2})+" "+ ValToStr(result{3})+" "+ValToStr(result{4})+" "+ValToStr(result{5});
          ELSE 
              
            Socketsend scaleClientSocket \Str :="9 9 9";   ! send_result false only trigger sending 9 9 9 which the pyhthon not save the unready result
            
          ENDIF
          
          IF weight_vial_reday=TRUE THEN
              
          Socketsend commandClientSocket \Str := ValToStr(weight_vial);

          ENDIF 
          weight_vial_reday:=FALSE;
          
        
         IF ready_new_command = TRUE THEN!
                no_vials_now:= no_vials_now+1;
               
                Socketsend commandClientSocket \Str := "new_target";

                SocketReceive commandClientSocket \Str :=  command_recv_msg;
                Parsemsg(command_recv_msg);
                


                recv_target_weight:=command{1};
              
                ready_new_command := FALSE;
            ELSE
                Socketsend commandClientSocket \Str := "executing";
                SocketReceive commandClientSocket \Str :=  command_recv_msg;
                Parsemsg(command_recv_msg);

            ENDIF
            
                IF command{3}=100 or command{2}=1000 or command{4}=1000 THEN  ! the value can be changed just for noting the receieve data no stable
           
    
                 recv_stable:=false;
            
           ELSE
                      shake:=command{2};
                recv_reading:=command{3};
                a_smallspoon:=command{4};
                 recv_stable:=TRUE;
           ENDIF
                
        ENDWHILE
        client_connected := FALSE;
        SocketClose scaleServerSocket;
        SocketClose scaleClientSocket;
        TPWrite "program ended";
 
        ERROR
            IF ERRNO=ERR_SOCK_TIMEOUT THEN
                TPWrite "Timeout while waiting for message! restarting connection and retrying!!!";
                ! Close connection and restart.
                ServerStart TRUE;
                Retry;
            ELSEIF ERRNO=ERR_SOCK_CLOSED THEN
                TPWrite "Socket closed by client!, terminating";
                client_connected := FALSE;
                SocketClose scaleServerSocket;
                SocketClose scaleClientSocket;
                RETURN;
            ELSE
                TPWrite "Unknown error";
        ENDIF
        
	ENDPROC 
    
ENDMODULE