import time
import serial  
import matplotlib.pyplot as plt
import socket
import xlsxwriter
import xlrd
import numpy as np
import matplotlib.ticker as ticker
import  json
import  decimal
import os
from fuzzylogic.classes import Domain, Set, Rule
from fuzzylogic.classes import Domain
from fuzzylogic.functions import bounded_sigmoid
import matplotlib.pyplot as plt
from fuzzylogic.functions import R, S
from fuzzylogic.functions import (sigmoid, gauss, trapezoid,
                                  triangular_sigmoid, rectangular)


HOST = '192.168.125.1'
PORT = 1025

class SaveJson(object):

 def save_file(self, path, item):
        item = json.dumps(item)

        try:
            if not os.path.exists(path):
                with open(path, "w", encoding='utf-8') as f:
                    f.write(item + "\n")
                    print("^_^ write success")
            else:
                with open(path, "a", encoding='utf-8') as f:
                    f.write(item + "\n")
                    print("^_^ write success")
        except Exception as e:
            print("write error==>", e)

def readtodict(item):
    read_string = item.split(' ')
    read_list = [float(x) for x in read_string]
    title_list = ['accuracy', 'difference', 'target_weight', 'time']
    result_d = dict(zip(title_list, read_list))
    return result_d

def fuzzy_logic(x1,x2):

    D = Domain("Difference", -0.1, 2, res=0.02)
    A = Domain('angele', 10, 40, res=0.02)
    density = Domain("density", 0, 4, res=0.02)
    Sa = Domain("shaking", 0, 20)

    D.small = S(0.2, 0.4)
    D.large = R(0.6, 0.8)
    D.medium = trapezoid(0.2, 0.5, 0.6, 0.8, c_m=1)
    D.small.plot()
    D.medium.plot()
    D.large.plot()

    # plt.show()

    density.small = S(1.0, 2.5)
    density.large = R(3, 3.2)
    density.medium = trapezoid(2, 2.4, 2.8, 3.2, c_m=1)
    density.small.plot()
    density.medium.plot()
    density.large.plot()
    # plt.show()
    Sa.small = S(2, 4)
    Sa.large = R(10, 15)
    Sa.medium = trapezoid(2, 6, 10, 12, c_m=1)
    Sa.small.plot()
    Sa.medium.plot()
    Sa.large.plot()
    # plt.show()

    R1 = Rule({(D.small, density.medium): Sa.small})
    R2 = Rule({(D.small, density.small): Sa.small})
    R3 = Rule({(D.small, density.large): Sa.small})
    R4 = Rule({(D.medium, density.small): Sa.medium})
    R5 = Rule({(D.medium, density.medium): Sa.medium})
    R6 = Rule({(D.medium, density.large): Sa.medium})
    R7 = Rule({(D.large, density.small): Sa.large})
    R8 = Rule({(D.large, density.medium): Sa.large})
    R9 = Rule({(D.large, density.large): Sa.large})

    rules_shaking = sum([R1, R2, R3, R4, R5, R6, R7, R8, R9])
    X = {D: x1, density: x2} #differerence and density

    y = rules_shaking(X)
    return y


def main():


    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as soc:
       soc.connect((HOST, PORT))
       soc.settimeout(30) #15
       while True:
                soc.sendall(bytes('1', 'ascii'))
                print('send successful')
                read = soc.recv(10240)
                read_string=read.decode()
                print(read_string)
                if read_string:  # get the result from RAPID side and save it in result json file
                    with open('CaCO3.json') as f:
                        try:
                            last_json=json.loads(f.readlines()[-1])
                        except:
                                last_json = {}

                        if read_string != "9 9 9" :    # the wanted data
                           r=readtodict(read_string)
                           if r !=last_json:
                             print(r)
                             s = SaveJson()
                             s.save_file("CaCO3.json", r)
                             f.close()


if __name__ == '__main__':
    main()





