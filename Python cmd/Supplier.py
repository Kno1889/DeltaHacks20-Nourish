# -*- coding: utf-8 -*-
"""
Created on Sat Jan 25 18:31:56 2020

@author: ankli
"""

class Supplier:
    
    def __init__(self,name,code,latitude,longitude):
        self.name = name
        self.code = code
        self.lat = latitude
        self.long = longitude
        
    #getters
    def getName(self):
        return self.name
    def getCode(self):
        return self.code
    def getLat(self):
        return self.lat
    def getLong(self):
        return self.long
    
    
    
    
        