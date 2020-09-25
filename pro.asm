TRIG    BIT    P2.1	 //����������˿�
ECHO    BIT    P2.0	//���������ն˿�
BEEP    BIT    P2.2	 //�������ӿ�
RS      BIT    P2.6	 //LCD1602����/����ѡ��ˣ�H/L��
RW      BIT    P2.5	 //LCD1602��/дѡ��ˣ�H/L��
E       BIT    P2.7	 //LCD1602ʹ�ܶ�
K       BIT    P1.4  //��������K1�Ľӿ�

        ORG	    0000H
		LJMP    START1
		ORG    0200H
START1:  MOV    SP,#70H
        LCALL   LCD1		  //��ʾС����Ϣ��Distance�������ӳ���
START2: LCALL    DELAY
KEY:    JNB    K,LCD3	  //�жϰ����Ƿ��£����¾͹رղ��ͱ���������ʾ---.---
        SETB   TRIG		  //TRIG��1 ����10us
        MOV    R7,#10

DEL10MS:    DJNZ   R7,DEL10MS	
        CLR    TRIG
		MOV    R0,#50H	   
		MOV    TMOD,#01H  //���ü�ʱ��0������״̬0	 
		MOV    TL0,#0
		MOV    TH0,#0
		JNB    ECHO,$	  //��ECHO	Ϊ1ʱ������ʱ��
		SETB   TR0
	    JB     ECHO,$	 //��ECHOΪ0ʱ���رռ�ʱ��
		CLR    TR0
		MOV    @R0,TL0	   //��TH0��TL0�ֱ����51H,50H
	    INC    R0
		MOV    @R0,TH0
	    LCALL   MULT	  //��TH0��TL0ת��ΪBCD��	 ��ȡ��λ����54H 53H 52H
SEND:   MOV     R5,#3		//���ڳ�ʼ��
        MOV     R0,#54H
		MOV     TMOD,#20H
		MOV     TL1,#0F3H
		MOV     TH1,#0F3H
		SETB    TR1
		MOV     SCON,#50H
		MOV     PCON,#80H
SEND1:  MOV     A,@R0	//����λ�����Ͳ���LCD1602��ʾ	  
        MOV     SBUF,A
		JNB     TI,$
		CLR     TI
		DEC     R0		 
		DJNZ    R5,SEND1
		SETB    TI
     	CALL    LCD2
ALARM:	MOV     A,53H	   //���� �����������1mʱ������54HΪ��λ����λcm��
        CJNE    A,#05H,DAXIAO   //START3
DAXIAO: JNC      START3               
CIRCLE: MOV     R7,#125
C1:   MOV     R6,#200
C2:   DJNZ    R6,C2
        CPL     BEEP
        LCALL   DELAY
		DJNZ    R7,C1          
START3:	LCALL   DELAY1
		LJMP     START2
LCD3:  	MOV     P0,#0C0H
		CALL    WCMD
		MOV     R6,#9
KG2:    MOV     P0,#14H		 //����ǰ���Distance����ʾ
		CALL    WCMD
		DJNZ    R6,KG2
		MOV     DPTR,#CGRAM3
	    CALL    DISPLAY
		LCALL   DELAY1
WAIT:	JB       K,WAIT
        LCALL   DELAY1
		RET
LCD1:    MOV     P0,#01H	//LCD����
        CALL    WCMD  //д����
		MOV     P0,#38H	// ������ʾģʽ
		CALL    WCMD
		MOV     P0,#0EH	 //��ʾ���
		CALL    WCMD
		MOV     P0,#06H	 //ָ���1
		CALL    WCMD
		MOV     P0,#80H	 //��������ָ�����
		CALL    WCMD
		MOV     DPTR,#CGRAM1 //д����ģ��	
		CALL    DISPLAY	  //��ʾ����ʼ��ַ
		MOV     P0,#0C0H
		CALL    WCMD
		MOV     DPTR,#CGRAM2
		CALL    DISPLAY
		RET
LCD2:  	MOV     P0,#0C0H
		CALL    WCMD
		MOV     R6,#9 //ѭ������
KG1:     MOV     P0,#14H
		CALL    WCMD
		DJNZ    R6,KG1
		CALL    DISPLAY1
		RET
WCMD:   CLR     RS	  //д����
        CLR     RW
		CLR     E
		CALL    DELAY
		SETB    E
		RET	  
DISPLAY:  MOV     R0,#00H
SHOWON:  MOV     A,R0		 //��ʾ........
          MOVC    A,@A+DPTR
		  CALL    SEND_DATA
		  INC     R0
		  CJNE    A,#90H,SHOWON
	      RET
DISPLAY1: MOV    R0,#54H //��ʾ�������
          MOV    R6,#3
DIS2:     MOV    A,@R0
          ADD    A,#30H
          CALL   SEND_DATA
		  DEC    R0
		  DJNZ   R6,DIS2
		  RET
SEND_DATA:MOV    P0,A  //д����
          SETB   RS
		  CLR    RW
		  CLR    E
		  CALL   DELAY
		  SETB   E
		  RET
DELAY:    MOV    R1,#10
D1:       MOV    R2,#248
          DJNZ   R2,$
		  DJNZ   R1,D1
		  RET
DELAY_10MS:MOV   R7,#25
DEL1:      MOV   R6,#200
DEL2:      DJNZ  R6,DEL2
           DJNZ  R7,DEL1
		   RET
MULT:MOV   R0,50H	//������������Ӧ�ļĴ浥Ԫ
      MOV   R1,51H
	  MOV   R2,#11H
	  MOV   R3,#00H
      MOV   A , R0
      MOV   B , R2
	  MUL   AB 
	  MOV   R4, A 
	  MOV   R5, B      
	  MOV   A , R1  
	  MOV   B , R2
	  MUL   AB  
	  ADD   A , R5
	  MOV   R5, A 
	  MOV   A , B 
	  ADDC  A , #0 
	  MOV   R6, A    
	  MOV   A , R0  
	  MOV   B , R3
	  MUL   AB  
	  ADD   A , R5
	  MOV   R5, A 
	  MOV   A , B 
	  ADDC  A , #0 
	  ADD   A , R6
	  MOV   R6, A   
	  MOV   A , R1 
	  MOV   B , R3
	  MUL   AB   
      ADD   A , R6
      MOV   R6, A 
      MOV   A , B
	  ADDC  A , #0 
	  MOV   R7, A 
	  MOV  R3,#03H
      MOV  R2,#0E8H
D4B2: MOV 57H,#20H
         MOV R0,#00H
         MOV R1,#00H
DIVC1:MOV A,R4
         RLC A
         MOV R4,A
         MOV A,R5
         RLC A
         MOV R5,A
         MOV A,R6
         RLC A
         MOV R6,A
         MOV A,R7
         RLC A
         MOV R7,A
         MOV A,R0
         RLC A
         MOV R0,A
         MOV A,R1
         RLC A
         MOV R1,A
         CLR C
         MOV A,R0
         SUBB A,R2
         MOV B,A
         MOV A,R1
         SUBB A,R3
         JC DIVC2
         MOV R0,B
         MOV R1,A
DIVC2:   CPL C
         DJNZ 57H,DIVC1
         MOV A,R4
         RLC A
         MOV R4,A
         MOV A,R5
         RLC A 
         MOV R5,A
         MOV A,R6
         RLC A
         MOV R6,A
         MOV A,R7
         RLC A
         MOV R7,A
	     MOV  50H,R4
	     MOV  51H,R5
         MOV  R0,50H
         MOV  R1,51H    
	     CLR   A
         MOV   R2,A
	     MOV   R3,A
	     MOV   R4,A
         MOV  R5,#16
LOOP:    CLR  C
         MOV  A,   R0        
         RLC  A
         MOV  R0, A
         MOV  A,   R1
         RLC  A
         MOV  R1, A
         MOV  A,   R4        
         ADDC A,   R4           
         DA   A                
         MOV  R4,  A
         MOV  A,   R3
         ADDC A,   R3
         DA   A
         MOV  R3,  A
         MOV  A,   R2
         ADDC A,   R2
         MOV  R2,  A
         DJNZ R5,  LOOP         
         MOV  A,   R4
         MOV  B,   #16
         DIV  AB
         MOV  53H,  A
         MOV  52H,  B
         MOV  A,   R2		 
         MOV  56H,  A		 
	     MOV  A,   R3
         MOV  B,   #16
         DIV  AB
         MOV  55H,  A
         MOV  54H,  B 
	     RET 
		  
CGRAM1:   DB	   'Group-20',90H
CGRAM2:   DB       'Distance:',90H
CGRAM3:	  DB	   '---.---',90H

DELAY1: MOV R4,#15;��ʱ���� 25SHI  1S
Y3:     MOV R2 ,#200
Y1:     MOV R3 ,#248
Y2:     DJNZ R3 ,Y2 
        DJNZ R2 ,Y1 
        DJNZ R4 ,Y3 
        RET
    
        END