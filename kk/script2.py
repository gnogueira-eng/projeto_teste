#!/usr/bin/env python3

import os
import script3

def create():

   resp = "Testes aprovados, commit aceito"
   #filesf2 = os.popen("git diff --cached --name-status | cut -f2").read().splitlines()
   #print (files)
   namestatus = os.popen("git diff --cached --name-status").read()

   for i in namestatus[0]:
      if namestatus[i] == "R100":
         list(files) = os.popen("git diff --cached --name-status | cut -f3").read().splitlines()
      else:
         list(files) = os.popen("git diff --cached --name-status | cut -f2").read().splitlines()

   for i in range(len(files)):
          #caminho = os.popen("readlink -f "+documents[i]).read()  #Pega o endereco de todos os documentos presentes na variavel documents
          r = script3.Compare(files[i]) #Faz a verificacao definida em scriptPat.Compare
          if r == 0:
              print(files[i]+" : Teste Aprovado")    
          else:
              #print(files[i])
              resp = "Erro no teste. Commit recusado"
              block = 1
      
   print(resp)
   os._exit(block) #Bloqueia o commit

if  __name__ == '__main__':
   create()
