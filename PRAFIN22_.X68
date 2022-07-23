*-----------------------------------------------------------
* Title      : PRAFIN22
* Written by : Nicolás Sanz Tuñón y Constantino Byelov Serdiuk
* Date       : 31/05/2022
* Description: Emulador de la JARVIS
*-----------------------------------------------------------
 ORG $1000
EMEM: DC.W $2800,$2A03,$50E0,$0B60,$5114,$0C70,$1430,$0E40,$7140,$3001,$32FF,$90D0
      DC.W $8020,$C000,$0002,$0003,$0001,$0003,$0002,$0004,$0000,$0000,$0000
EIR: DC.W 0 ;eregistro de instruccion
EPC: DC.W 0 ;econtador de programa
EB0: DC.W 0 ;eregistro B0
EB1: DC.W 0 ;eregistro B1
ER2: DC.W 0 ;eregistro R2
ER3: DC.W 0 ;eregistro R3
ER4: DC.W 0 ;eregistro R4
ER5: DC.W 0 ;eregistro R5
ET6: DC.W 0 ;eregistro T6
ET7: DC.W 0 ;eregistro T7
ESR: DC.W 0 ;eregistro de estado (00000000 00000ZCN)






START:
    CLR.W EPC

FETCH:
    ;--- IFETCH: INICIO FETCH
        ;*** En esta seccion debeis introducir el codigo necesario para cargar
        ;*** en el EIR la siguiente instruccion a ejecutar, indicada por el EPC,
	    ;*** y dejar listo el EPC para que apunte a la siguiente instruccion
	
	    ; ESCRIBID VUESTRO CODIGO AQUI
	    MOVE.W EPC, A0
	    ADD.W EPC, A0
	    MOVE.W EMEM(A0),EIR
	    ADDQ.W #1, EPC
	    
        
    ;--- FFETCH: FIN FETCH
    
    
    ;--- IBRDECOD: INICIO SALTO A DECOD
        ;*** En esta seccion debeis preparar la pila para llamar a la subrutina
        ;*** DECOD, llamar a la subrutina, y vaciar la pila correctamente,
        ;*** almacenando el resultado de la decodificacion en D1

    	; ESCRIBID VUESTRO CODIGO AQUI
    	MOVE.W #0,-(SP)  ;Espacio extra para el decod del resultado
    	MOVE.W EIR,-(SP) ;EIR = parámetro entrada pila
    	
    	JSR DECOD
    	
    	MOVE.W (SP)+,D0
	    MOVE.W (SP)+,D1
        
    ;--- FBRDECOD: FIN SALTO A DECOD
    
    
    ;--- IBREXEC: INICIO SALTO A FASE DE EJECUCION
        ;*** Esta seccion se usa para saltar a la fase de ejecucion
        ;*** NO HACE FALTA MODIFICARLA
    MULU #6,D1
    MOVEA.L D1,A1
    JMP JMPLIST(A1)
JMPLIST:
    JMP ETRA
    JMP EADD
    JMP ESUB
    JMP ENAN
    JMP ESTC
    JMP EINC
    JMP ELOA
    JMP ELOAX
    JMP ESTO
    JMP ESTOX
    JMP EBRI
    JMP EBRZ
    JMP EBRN
    JMP ESTP
    ;--- FBREXEC: FIN SALTO A FASE DE EJECUCION
    
    
    ;--- IEXEC: INICIO EJECUCION
        ;*** En esta seccion debeis implementar la ejecucion de cada einstr.
	
	; ESCRIBID EN CADA ETIQUETA LA FASE DE EJECUCION DE CADA INSTRUCCION
ETRA:
      MOVE.W D0,D1
      JSR OBTENER_Xa        ;Salto a subrutina para obtener Xa en D0
      JSR OBTENER_Xb        ;Obtenemos Xb en D1
      JSR ENCONTRAR_REGISTRO_Xa 
      JSR ENCONTRAR_REGISTRO_Xb ;Y direccion Xb en A1
      
      MOVE.W D0,(A1)  ;Ejecutamos la intrucción deseada

      JSR ACTU_FLAG_Z_A1
      JSR ACTU_FLAG_N_A1
      BRA FETCH

      

EADD:
      MOVE.W D0,D1
      JSR OBTENER_Xa        ;Salto a subrutina para obtener Xa en D0
      JSR OBTENER_Xb        ;Obtenemos Xb en D1
      JSR ENCONTRAR_REGISTRO_Xa 
      JSR ENCONTRAR_REGISTRO_Xb 
      
      ADD.W D0,(A1)  ;Ejecutamos la instrucción deseada
      
      MOVE.W SR,D2 ;Registro estados 68K a D2 para comprobar
                   ;los flags del resultado de la operación
      JSR ACTU_FLAG_C_RESULTADO
      JSR ACTU_FLAG_Z_RESULTADO
      JSR ACTU_FLAG_N_RESULTADO
      BRA FETCH
      

ESUB:
      MOVE.W D0,D1
      JSR OBTENER_Xa        ;Salto a subrutina para obtener Xa en D0
      JSR OBTENER_Xb        ;Obtenemos Xb en D1
      JSR ENCONTRAR_REGISTRO_Xa 
      JSR ENCONTRAR_REGISTRO_Xb 
      
      NOT.W D0              ;D0'
      ADDQ.W #1,D0          ;D0' + 1
      ADD.W D0,(A1)         ;Operación resta: D1 + (D0'+1)

      MOVE.W SR,D2 ;Registro estados 68K a D2 para comprobar
                   ;los flags del resultado de la operación
      JSR ACTU_FLAG_C_RESULTADO
      JSR ACTU_FLAG_Z_RESULTADO
      JSR ACTU_FLAG_N_RESULTADO
      BRA FETCH
      
ENAN:
      MOVE.W D0,D1
      JSR OBTENER_Xa        ;Salto a subrutina para obtener Xa en D0
      JSR OBTENER_Xb        ;Obtenemos Xb en D1
      JSR ENCONTRAR_REGISTRO_Xa 
      JSR ENCONTRAR_REGISTRO_Xb 
      
      AND.W D0,(A1)  
      NOT.W (A1)

      MOVE.W SR,D2 ;Registro estados 68K a D2 para comprobar
                   ;los flags del resultado de la operación
      JSR ACTU_FLAG_Z_RESULTADO
      JSR ACTU_FLAG_N_RESULTADO
      BRA FETCH
ESTC:
      MOVE.W D0,D1
      ;JSR OBTENER_Xa        ;Salto a subrutina para obtener Xa en D0
      JSR OBTENER_Xb        ;Obtenemos Xb en D1
      ;JSR ENCONTRAR_REGISTRO_Xa 
      JSR ENCONTRAR_REGISTRO_Xb 
      
      ;Extensión de signo a Xb
      MOVE.W D0,D1
      AND.W #$00FF,D1 ;las k estan en los 8 primeros bits
      EXT.W D1
      MOVE.W D1,(A1)


      JSR ACTU_FLAG_Z_A1
      JSR ACTU_FLAG_N_A1
      BRA FETCH
EINC:
      MOVE.W D0,D1
      ;JSR OBTENER_Xa        ;Salto a subrutina para obtener Xa en D0
      JSR OBTENER_Xb        ;Obtenemos Xb en D1
      ;JSR ENCONTRAR_REGISTRO_Xa 
      JSR ENCONTRAR_REGISTRO_Xb 
      
      ;Extensión de signo a Xb
      MOVE.W D0,D1
      AND.W #$00FF,D1 ;las k estan en los 8 primeros bits
      EXT.W D1
      ADD.W D1,(A1)   ;Sumamos la k extendida al contenido de Xb

      MOVE.W SR,D2 ;Registro estados 68K a D2 para comprobar
                   ;los flags del resultado de la operación
      JSR ACTU_FLAG_C_RESULTADO
      JSR ACTU_FLAG_Z_RESULTADO
      JSR ACTU_FLAG_N_RESULTADO
      BRA FETCH
ELOA:     
      JSR OBTENER_M 
      
      
      ADD.W D0,D0
      MOVE.W D0,A1 
      
      
      MOVE.W EMEM(A1),ET6
      
      LEA.L ET6,A1          ;Para la act. de flags
       
      JSR ACTU_FLAG_Z_A1
      JSR ACTU_FLAG_N_A1
      BRA FETCH
ELOAX:
      BTST.L #3,D0   ;Miramos la i para saber si se trata de B0 o B1
      BEQ LOAX_B0
      MOVE.W D0,D5
      JSR OBTENER_M         ; D0 = M
      ADD.W EB1,D0          ;M+B1
      ADD.W D0,D0           ;*2
      MOVE.W D0,A1  

      LOAX_T6_T7:
      BTST.L #2,D5
      BEQ LOAX_T6
      
      MOVE.W EMEM(A1),ET7
      
      LEA.L ET7,A1          ; Para la act. de flags
      JSR ACTU_FLAG_Z_A1
      JSR ACTU_FLAG_N_A1
      BRA FETCH
      
      
      
      LOAX_B0:
      MOVE.W D0,D5
      JSR OBTENER_M         ; D0 = M
      ADD.W EB0,D0          ;M+B0
      ADD.W D0,D0           ;*2
      MOVE.W D0,A1  

      BRA LOAX_T6_T7
      
      LOAX_T6:
      MOVE.W EMEM(A1),ET6
      
      LEA.L ET6,A1          ; Para la act. de flags
      JSR ACTU_FLAG_Z_A1
      JSR ACTU_FLAG_N_A1
      BRA FETCH
      
      
ESTO:
      JSR OBTENER_M         ; D0 = M
      ADD.W D0,D0
      MOVE.W D0,A1          ; A1 = indice para @M
      
      MOVE.W ET6,EMEM(A1)
      BRA FETCH

ESTOX:
      BTST.L #3,D0   ;Miramos la i para saber si se trata de B0 o B1
      BEQ STOX_B0
      MOVE.W D0,D5
      JSR OBTENER_M         ; D0 = M
      ADD.W EB1,D0          ;M+B1
      ADD.W D0,D0           ;*2
      MOVE.W D0,A1  
 
      STOX_T6_T7:
      BTST.L #2,D5
      BEQ STOX_T6
      
      MOVE.W ET7,EMEM(A1)
      BRA FETCH
      
      
      
      STOX_B0:
      MOVE.W D0,D5
      JSR OBTENER_M         ; D0 = M
      ADD.W EB0,D0          ;M+B0
      ADD.W D0,D0           ;*2
      MOVE.W D0,A1

      BRA STOX_T6_T7
      
      STOX_T6:
      MOVE.W ET6,EMEM(A1)
      BRA FETCH
EBRI:
      JSR OBTENER_M         
      MOVE.W D0,EPC
      BRA FETCH

EBRZ:
      MOVE.W ESR,D3
      BTST.L #2,D3
      BNE EBRI              ; si Z=1, M -> PC
      BRA FETCH
EBRN:
      MOVE.W ESR,D3
      BTST.L #0,D3
      BNE EBRI              ; si N = 1, M -> PC
      BRA FETCH
ESTP:
     BRA FINAL
    ;--- FEXEC: FIN EJECUCION
    

    ;--- ISUBR: INICIO SUBRUTINAS
        ;*** Aqui debeis incluir las subrutinas que necesite vuestra solucion
        ;*** SALVO DECOD, que va en la siguiente seccion

	    ; ESCRIBID VUESTRO CODIGO AQUI
OBTENER_Xa:
      AND.W #$0070,D0
	  LSR.L #4,D0
	  RTS
	  
OBTENER_Xb:
      AND.W #$0700,D1
      LSR.L #8,D1
	  RTS
	  
OBTENER_M:
    AND.W #$0FF0,D0
	LSR.L #4,D0
	RTS
	  
ENCONTRAR_REGISTRO_Xa:
      BTST.L #2,D0
      BEQ ET_R0_Xa     ;Salta si tercer bit 0 (B0,B1,R2,R3)
                       ;Sino, tercer bit 1 (R4,R5,T6,T7)
      BTST.L #1,D0  
      BEQ ET_R10_Xa    ;Salta si secuencia 10 (R4,R5)
                       ;Sino, secuencia 11 (T6,T7)
      BTST.L #0,D0  
      BEQ ET_R110_Xa   ;Salta si T6 (secuencia 110)
    
      MOVE.W ET7,D0    ;Sino, se trata del registro T7 (111)
      RTS
           
      
ET_R0_Xa:
     BTST.L #1,D0  
     BEQ ET_R00_Xa    ;Salta si secuencia 00 (B0,B1)
                      ;Sino, secuencia 01 (R2,R3)
     BTST.L #0,D0
     BEQ ET_R010_Xa   ;Salta si R2 (010)
     
     MOVE.W ER3,D0    ;Sino, secuencia 011 (R3)
     RTS             
      
ET_R00_Xa:
     BTST.L #0,D0
     BEQ ET_R000_Xa    ;Salta si R0 (000)
     
     MOVE.W EB1,D0     ;Sino, R1 (001)
     RTS
     
ET_R000_Xa:
     MOVE.W EB0,D0     ;Sino, R0 (000)
     RTS 

ET_R010_Xa:
     MOVE.W ER2,D0     ;Sino, secuencia 010 (R2)
     RTS 

ET_R10_Xa:
     BTST.L #0,D0
     BEQ ET_R100_Xa   ;Si salta, se trata de R4
     MOVE.W ER5,D0    ;Sino, secuencia 101 (R5)
     RTS
     
ET_R100_Xa:
     MOVE.W ER4,D0    ;Se trata del registro R4 (100)
     RTS

ET_R110_Xa:
     MOVE.W ET6,D0    ;Se trata del registro T6 (110)
     RTS
     
     
     
ENCONTRAR_REGISTRO_Xb:
      BTST.L #2,D1
      BEQ ET_R0_Xb     ;Salta si tercer bit 0 (B0,B1,R2,R3)
                       ;Sino, tercer bit 1 (R4,R5,T6,T7)
      BTST.L #1,D1  
      BEQ ET_R10_Xb    ;Salta si secuencia 10 (R4,R5)
                       ;Sino, secuencia 11 (T6,T7)
      BTST.L #0,D1  
      BEQ ET_R110_Xb   ;Salta si T6 (secuencia 110)
    
      LEA.L ET7,A1    ;Sino, se trata del registro T7 (111)
      RTS
           
      
ET_R0_Xb:
     BTST.L #1,D1  
     BEQ ET_R00_Xb    ;Salta si secuencia 00 (B0,B1)
                      ;Sino, secuencia 01 (R2,R3)
     BTST.L #0,D1
     BEQ ET_R010_Xb   ;Salta si R2 (010)
     
     LEA.L ER3,A1    ;Sino, secuencia 011 (R3)
     RTS             
      
ET_R00_Xb:
     BTST.L #0,D1
     BEQ ET_R000_Xb    ;Salta si R0 (000)
     
     LEA.L EB1,A1     ;Sino, R1 (001)
     RTS
     
ET_R000_Xb:
     LEA.L EB0,A1     ;Sino, R0 (000)
     RTS 

ET_R010_Xb:
     LEA.L ER2,A1     ;Sino, secuencia 010 (R2)
     RTS 

ET_R10_Xb:
     BTST.L #0,D1
     BEQ ET_R100_Xb   ;Si salta, se trata de R4
     LEA.L ER5,A1    ;Sino, secuencia 101 (R5)
     RTS
     
ET_R100_Xb:
     LEA.L ER4,A1    ;Se trata del registro R4 (100)
     RTS

ET_R110_Xb:
     LEA.L ET6,A1    ;Se trata del registro T6 (110)
     RTS

;Actualización del flag Z segín el valor del contenido
;de A1   
ACTU_FLAG_Z_A1:
     MOVE.W ESR,D3     ;Movemos registro de estado a D3
     MOVE.W (A1),D2    ;Contenido A1 a D2
     CMP.W #0,D2       ;Si z = 0, salta y actualizamos flag z = 0
     BNE FLAG_Z0          
     BSET #2,D3      ;Ponemos especificamente el flag Z a 1
     MOVE.W D3,ESR     ;Actualizamos registro de estado
     RTS
     
FLAG_Z0:
     BCLR #2,D3      ;Ponemos especificamente el flag Z a 0
     MOVE.W D3,ESR     ;Actualizamos registro de estado
     RTS

;Actualización del flag N segín el valor del contenido
;de A1      
ACTU_FLAG_N_A1:
     MOVE.W ESR,D3     ;Movemos registro de estado a D3
     MOVE.W (A1),D2    ;Contenido A1 a D2
     CMP.W #0,D2       ;Si N = 0, salta 
     BGE FLAG_Z0          
     BSET #0,D3      ;Ponemos especificamente el flag N a 1
     MOVE.W D3,ESR     ;Actualizamos registro de estado
     RTS
     
FLAG_N0:
     BCLR #0,D3      ;Ponemos especificamente el flag N a 0
     MOVE.W D3,ESR     ;Actualizamos registro de estado
     RTS
     
     
ACTU_FLAG_C_RESULTADO:
     MOVE.W ESR,D3
     BTST.L #0,D2
     BNE FLAG_C1          
     BCLR #1,D3
     MOVE.W D3,ESR
     RTS
     
FLAG_C1:
    BSET #1,D3
    MOVE.W D3,ESR
    RTS
    
ACTU_FLAG_Z_RESULTADO:
     MOVE.W ESR,D3
     BTST.L #2,D2
     BNE FLAG_Z1          
     BCLR #2,D3
     MOVE.W D3,ESR
     RTS
     
FLAG_Z1:
    BSET.L #2,D3
    MOVE.W D3,ESR
    RTS
    
ACTU_FLAG_N_RESULTADO:
     MOVE.W ESR,D3
     BTST.L #3,D2
     BNE FLAG_C1           
     BCLR #0,D3
     MOVE.W D3,ESR
     RTS
     
FLAG_N1:
    BSET.L #0,D3
    MOVE.W D3,ESR
    RTS



      
           
        
    ;--- FSUBR: FIN SUBRUTINAS
    

    ;--- IDECOD: INICIO DECOD
        ;*** Tras la etiqueta DECOD, debeis implementar la subrutina de 
        ;*** decodificacion, que debera ser de libreria, siguiendo la interfaz
        ;*** especificada en el enunciado
DECOD:
	    ; ESCRIBID VUESTRO CODIGO AQUI
        MOVE.L D1,-(SP)
        MOVE.W 8(SP),D1
        
        BTST.L #15,D1
        BEQ ET_0           ;Si salta, primer bit 0
                           ;Sino, primer bit 1
        BTST.L #14,D1 
        BEQ ET_10          ;Si salta, secuencia 10
                           ;Sino, secuencia 11
        MOVE.W #13,10(SP)  ;Instruccion STP encontrada
        BRA FINAL_DECOD
        
ET_0:
        BTST.L #14,D1       
        BEQ ET_00          ;Si salta, secuencia 00
                           ;Sino, secuencia 01
        
        BTST.L #13,D1
        BEQ ET_010         ;Si salta, secuencia 010
                           ;Sino, secuencia 011
        BTST.L #12,D1
        BEQ ET_0110        ;Si salta, secuencia 0110
                           ;Sino, secuencia 0111
        MOVE.W #9,10(SP)   ;Intruccion STOX encontrada
        BRA FINAL_DECOD


ET_00:
        BTST.L #13,D1       
        BEQ ET_000          ;Si salta, secuencia 000
                            ;Sino, secuencia 001
        BTST.L #12,D1
        BEQ ET_0010        ;Si salta, secuencia 0010
                           ;Sino, secuencia 0011
        MOVE.W #5,10(SP)   ;Instruccion INC encontrada
        BRA FINAL_DECOD                   
        
        
        
ET_000:
        BTST.L #12,D1 
        BEQ ET_0000        ;Si salta, secuencia 0000
                           ;Sino, secuencia 0001
        BTST.L #11,D1
        BEQ ET_00010       ;Si salta, secuencia 00010
                           ;Sino, secuencia 00011
        MOVE.W #2,10(SP)   ;Instruccion SUB encontrada
        BRA FINAL_DECOD 


ET_00010:
        MOVE.W #1,10(SP)   ;Instruccion ADD encontrada
        BRA FINAL_DECOD 



ET_0000:
        MOVE.W #0,10(SP)   ;Instruccion TRA encontrada
        BRA FINAL_DECOD

ET_0010:
        BTST.L #11,D1      
        BEQ ET_00100       ;Si salta, secuencia 00100
                           ;Sino, secuencia 00101
        MOVE.W #4,10(SP)   ;Instruccion STC encontrada
        BRA FINAL_DECOD

ET_00100:
        MOVE.W #3,10(SP)   ;Instruccion NAN encontrada
        BRA FINAL_DECOD

     
ET_010:
        BTST.L #12,D1
        BEQ ET_0100        ;Si salta, secuencia 0100
                           ;Sino, secuencia 0101
        MOVE.W #7,10(SP)   ;Instruccion LOAX encontrada
        BRA FINAL_DECOD
        
        
ET_0100: 
        MOVE.W #6,10(SP)   ;Instruccion LOA encontrada
        BRA FINAL_DECOD




ET_0110:
        MOVE.W #8,10(SP)   ;Intruccion STO encontrada
        BRA FINAL_DECOD


ET_10:
        BTST.L #13,D1
        BEQ ET_100         ;Si salta, secuencia 100
                           ;Sino, secuencia 101
        MOVE.W #12,10(SP)  ;Instruccion BRN encontrada
        BRA FINAL_DECOD
        
        
        
ET_100:
        BTST.L #12,D1
        BEQ ET_1000        ;Si salta, secuencia 1000
                           ;Sino, secuencia 1001
        MOVE.W #11,10(SP)  ;Instruccion BRZ encontrada
        BRA FINAL_DECOD
        
ET_1000:
        MOVE.W #10,10(SP)  ;Instruccion BRI encontrada
        BRA FINAL_DECOD



FINAL_DECOD:             
                        
     MOVE.L (SP)+,D1 
     RTS
     
FINAL:
    ;--- FDECOD: FIN DECOD
    END    START


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
