TRIG    BIT    P2.1	 //超声波发射端口
ECHO    BIT    P2.0	//超声波接收端口
BEEP    BIT    P2.2	 //蜂鸣器接口
RS      BIT    P2.6	 //LCD1602数据/命令选择端（H/L）
RW      BIT    P2.5	 //LCD1602读/写选择端（H/L）
E       BIT    P2.7	 //LCD1602使能端
K       BIT    P1.4  //独立按键K1的接口

        ORG	    0000H
		LJMP    START1
		ORG    0200H
START1:  MOV    SP,#70H
        LCALL   LCD1		  //显示小组信息和Distance，调用子程序
START2: LCALL    DELAY
KEY:    JNB    K,LCD3	  //判断按键是否按下，按下就关闭测距和报警，并显示---.---
        SETB   TRIG		  //TRIG置1 超过10us
        MOV    R7,#10

DEL10MS:    DJNZ   R7,DEL10MS	
        CLR    TRIG
		MOV    R0,#50H	   
		MOV    TMOD,#01H  //设置计时器0，工作状态0	 
		MOV    TL0,#0
		MOV    TH0,#0
		JNB    ECHO,$	  //当ECHO	为1时，开计时器
		SETB   TR0
	    JB     ECHO,$	 //当ECHO为0时，关闭计时器
		CLR    TR0
		MOV    @R0,TL0	   //将TH0，TL0分别放入51H,50H
	    INC    R0
		MOV    @R0,TH0
	    LCALL   MULT	  //将TH0，TL0转换为BCD码	 ，取三位放入54H 53H 52H
SEND:   MOV     R5,#3		//串口初始化
        MOV     R0,#54H
		MOV     TMOD,#20H
		MOV     TL1,#0F3H
		MOV     TH1,#0F3H
		SETB    TR1
		MOV     SCON,#50H
		MOV     PCON,#80H
SEND1:  MOV     A,@R0	//向上位机发送并在LCD1602显示	  
        MOV     SBUF,A
		JNB     TI,$
		CLR     TI
		DEC     R0		 
		DJNZ    R5,SEND1
		SETB    TI
     	CALL    LCD2
ALARM:	MOV     A,53H	   //报警 ，当距离大于1m时报警（54H为百位，单位cm）
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
KG2:    MOV     P0,#14H		 //跳过前面的Distance：显示
		CALL    WCMD
		DJNZ    R6,KG2
		MOV     DPTR,#CGRAM3
	    CALL    DISPLAY
		LCALL   DELAY1
WAIT:	JB       K,WAIT
        LCALL   DELAY1
		RET
LCD1:    MOV     P0,#01H	//LCD清屏
        CALL    WCMD  //写命令
		MOV     P0,#38H	// 设置显示模式
		CALL    WCMD
		MOV     P0,#0EH	 //显示光标
		CALL    WCMD
		MOV     P0,#06H	 //指针加1
		CALL    WCMD
		MOV     P0,#80H	 //设置数据指针起点
		CALL    WCMD
		MOV     DPTR,#CGRAM1 //写入字模块	
		CALL    DISPLAY	  //显示的起始地址
		MOV     P0,#0C0H
		CALL    WCMD
		MOV     DPTR,#CGRAM2
		CALL    DISPLAY
		RET
LCD2:  	MOV     P0,#0C0H
		CALL    WCMD
		MOV     R6,#9 //循环次数
KG1:     MOV     P0,#14H
		CALL    WCMD
		DJNZ    R6,KG1
		CALL    DISPLAY1
		RET
WCMD:   CLR     RS	  //写命令
        CLR     RW
		CLR     E
		CALL    DELAY
		SETB    E
		RET	  
DISPLAY:  MOV     R0,#00H
SHOWON:  MOV     A,R0		 //显示........
          MOVC    A,@A+DPTR
		  CALL    SEND_DATA
		  INC     R0
		  CJNE    A,#90H,SHOWON
	      RET
DISPLAY1: MOV    R0,#54H //显示测量结果
          MOV    R6,#3
DIS2:     MOV    A,@R0
          ADD    A,#30H
          CALL   SEND_DATA
		  DEC    R0
		  DJNZ   R6,DIS2
		  RET
SEND_DATA:MOV    P0,A  //写数据
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
MULT:MOV   R0,50H	//计算结果存入相应的寄存单元
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

DELAY1: MOV R4,#15;延时程序， 25SHI  1S
Y3:     MOV R2 ,#200
Y1:     MOV R3 ,#248
Y2:     DJNZ R3 ,Y2 
        DJNZ R2 ,Y1 
        DJNZ R4 ,Y3 
        RET
    
        END