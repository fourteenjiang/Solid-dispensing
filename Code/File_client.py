import socket
import xlsxwriter
import xlrd
from fuzzylogic.classes import Domain, Set, Rule
from fuzzylogic.classes import Domain
from fuzzylogic.functions import bounded_sigmoid
import matplotlib.pyplot as plt
from fuzzylogic.functions import R, S
from fuzzylogic.functions import (sigmoid, gauss, trapezoid,triangular_sigmoid, rectangular)
import serial
from fuzzylogic.classes import Domain, Set, Rule
from fuzzylogic.classes import Domain
from fuzzylogic.functions import bounded_sigmoid
import matplotlib.pyplot as plt
from fuzzylogic.functions import R, S
from fuzzylogic.functions import (sigmoid, gauss, trapezoid,triangular_sigmoid, rectangular)
ser = serial.Serial(port="COM3", baudrate=9600, bytesize=serial.EIGHTBITS, parity=serial.PARITY_NONE,
                    stopbits=serial.STOPBITS_ONE, timeout=5)  #
ser.flushInput()
HOST = '192.168.125.1'
PORT = 1023



def getw(switch=True): # get stable and valid weight from the balance

 while switch:
        count = ser.inWaiting()
        if count != 0:
            recv = ser.read(size=32).decode("ASCII")  # Read out serial data, data in ASCII code
            if recv==None:
                w=None
            elif recv.find('?') != -1:
                w = None # the weight on data no stable
            else:
                weight = recv.splitlines()
                w1 = [x for x in weight if weight.count(x) > 1]
                if w1:
                    w = w1[0]
                    w=float(w)

                else:
                    w = None #unvalid num

        else: w=None
        if w!=None:
            switch=False
            return w
        else:
            switch=True

def main():

    loc = ("C:\\Users\\fourteen\\Desktop\\500mg.xls")
    wb = xlrd.open_workbook(loc)
    sheet = wb.sheet_by_index(0)
    row = 1#1
    col = 1 #1
    density=2.11
    vial_weight=9.7
    particle_size=3

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as soc:
        soc.connect((HOST, PORT))
        soc.settimeout(30) #15

        yumi_done = False
        while not yumi_done:
            recv_msg = soc.recv(10240)
            recv_string=recv_msg.decode()
            if (recv_string == 'new_target'):
                if (row in range(sheet.nrows-1)):
                       row = row + 1
                else:
                  if (col in  range(sheet.ncols-1)):
                       row = row + 2- sheet.nrows
                       col = col + 1
                  else:
                        yumi_done = True
                target_weight = sheet.cell_value(row, col)
                W = getw()
                y=calculate_shaking(target_weight,density,vial_weight,particle_size,W)
                y_shaking=y[0] #shaking
                y_angle=y[1]#angle
                if y_shaking==None or W==None or y_angle==None: # send unvalid number to robot, robot will wait until stable number
                    y_shaking=1000
                    y_angle=1000
                    W=100
                new_target_weight=target_weight

                send_string=''+(str(target_weight))+' '+str(y_shaking)+' '+str(W)+' '+str(y_angle)+' '+'#'
                soc.send(send_string.encode())
            elif  ( 'executing' in recv_string ):
                W = getw()
                y= calculate_shaking(new_target_weight, density,vial_weight,particle_size,W)
                y_shaking=y[0] #shaking
                y_angle=y[1]#angle
                if y_shaking==None or W==None or y_angle==None:
                    y_shaking=1000
                    y_angle=1000
                    W=100
                send_string2 = '' + '0' + ' ' + str(y_shaking) + ' ' + str(W) + ' ' +str(y_angle)+' '+ '#'
                soc.send(send_string2.encode())
            elif (recv_msg!=0):
                vial_weight= float(recv_string)


if __name__ == '__main__':
    main()
