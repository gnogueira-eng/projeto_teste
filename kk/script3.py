#!/usr/bin/env python3

def Compare(files):
   div = files.split("/")
   svcName = div[0]

   if len(div) == 1:
      print(files+" : Arquivo na raiz do projeto.")
      return 1

   if len(svcName) > 50:
       print("Erro no servico:"+div[0]+": Nome muito longo")
       return 1
   if NameValidation(svcName) == False:
       print("Erro no servico:"+div[0]+": Caractere invalida")
       return 1
   return 0

def NameValidation(name):
   validate = list(name)
   invalid = ["?","!",".",">","<","z","Z"]
   i = 0
   validation = True
   for i in range(len(validate)):
       if validate[i] in invalid:
           validation = False
           break
   return validation