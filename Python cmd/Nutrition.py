# -*- coding: utf-8 -*-
"""
Created on Sat Jan 25 18:30:13 2020

@author: anklis
"""
from Supplier import *
from Reciever import *
import math

def createSupplier(name,code,lat,long):
    newSupplier = Supplier(name,code,lat,long)
    return newSupplier

def createReciever(lat,long):
    newReciever = Reciever(lat,long)
    return newReciever

def addToSuppliers(newSupplier, suppliers):
    suppliers.append(newSupplier)
    infile = open("SuppliersList.txt", "a")
    
    totalSuppliers = len(suppliers)
    i = 0
    for i in range(len(suppliers)):
        infile.write(suppliers[i].getName() + ", ")
        infile.write(suppliers[i].getCode() + ", ")
        infile.write(suppliers[i].getLat() + ", ")
        infile.write(suppliers[i].getLong() + ", ")
    infile.write("Total Suppliers " + str(totalSuppliers) + "\n")
    infile.close()
    return suppliers

def addToRecievers(newReciever, recievers):
    recievers.append(newReciever)
    return recievers

def findMatch(reciever):
    infile = open("SuppliersList.txt", "r")
    distancesList = []
    lines = infile.readlines()
    dist1 = calcDistance2(reciever,float(lines[0].split(",")[2]),float(lines[0].split(",")[3]))
    for i in lines:
        lineData = i.split(",")
        if(lineData[0] == "\n"):
            break
        distance = calcDistance2(reciever,float(lineData[2]), float(lineData[3]))
        if(distance < dist1):
            dist1 = distance
            name = lineData[0]
        distancesList.append(distance)
    infile.close()
    j = 0
    #print(distancesList[0])
    least = distancesList[0]
    for j in range(len(distancesList)):
        #print(distancesList[j])
        if(distancesList[j] < least):
            least = distancesList[j]
    print("\n")
    print(least)
    print("The closest supplier is " + name)
    print("They are " + str(least) + " kilometers away")
    return name

def calcDistance2(reciever, supLat, supLong):
    #supLat = float(supLat)
    reciever.lat = float(reciever.lat)
    reciever.long = float(reciever.long)
    #supLong = float(supLong)
    a = (math.sin(math.radians((reciever.lat - supLat)/2))**2 + (math.cos(math.radians(reciever.lat)) * math.cos(math.radians(supLat)) * math.sin(math.radians((reciever.long - supLong)/2))**2))
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    radius = 6371
    d = radius * c
    return d

def calcDistance(reciever, supplier):
    a = (math.sin(math.radians((reciever.lat - supplier.lat)/2))**2 + (math.cos(math.radians(reciever.lat)) * math.cos(math.radians(supplier.lat)) * math.sin(math.radians((reciever.long - supplier.long)/2))**2))
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    radius = 6371
    d = radius * c
    return d
def menu():
    supplierList = []
    recieverList = []
    print("Welcome to Nourish, the app that facilitates the distribution of")
    print("food surpluses to local individuals in need by matching recievers and suppliers via location")
    response = input("Pick an option:\n1.Supplier\n2.Reciever\n(Press 1 or 2)\n")
    if(response == '1'):
        supplierCode = input("Are you a restaurant or a supermarket. Press 'r' for restaurant and 's' for supermarket\n")
        supplierName = input("Enter your name:\n")
        supplierLat = input("Enter your latitude as a decimal value (1 decimal place ex. 47.59)\n")
        supplierLong = input("Enter your longitude as a decimal value (1 decimal place ex. 47.59)\n")
        newSupplier = createSupplier(supplierName, supplierCode, supplierLat, supplierLong)
        supplierList = addToSuppliers(newSupplier, supplierList)
        
    elif(response == '2'):
        recieverLat = input("Enter your latitude as a decimal value (2 decimal place ex. 47.59)\n")
        if(float(recieverLat) < 0 and float(recieverLat) > 90):
            print("Error! Invalid input, try again\n")
            recieverLat = input("Enter your latitude as a decimal value (2 decimal place ex. 47.59)\n")
        recieverLong = input("Enter your longitude as a decimal value (2 decimal place ex. 47.59)\n")
        if(float(recieverLong) < -180 and float(recieverLong) > 180):
            print("Error! Invalid input, try again\n")
            recieverLong = input("Enter your longitude as a decimal value (2 decimal place ex. 47.59)\n")
        newReciever = createReciever(recieverLat,recieverLong)
        recieverList = addToRecievers(newReciever, recieverList)
        findMatch(newReciever)
        #exit()
    else:
        print("\n\n")
        print("Error! Invalid input, try again")
        print("\n\n")
        menu()

def main():
    menu()
main()
