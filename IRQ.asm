I_DivIRQ_Handler:
	bbr3	IR_Flag,L_4096Hz_Juge			; IR计数开关，用于计算两边沿之间的间隔
	inc		IR_Counter
L_4096Hz_Juge:
	bbr7	Timer_Switch,L_50Hz_Juge		; 4096Hz计数开关
	lda		Counter_4096Hz
	eor		#$01
	sta		Counter_4096Hz
	bbs0	Counter_4096Hz,L_50Hz_Juge
	lda		PB
	eor		#%00001000
	sta		PB

L_50Hz_Juge:
	bbr5	Timer_Switch,L_EndIrq			; 50Hz计数开关
	inc		Counter_50Hz
	lda		Counter_50Hz
	cmp		#1
	beq		RFC_Start
	cmp		#163
	bcs		RFC_Sample
	jmp		L_EndIrq
RFC_Start:
	jsr		F_RFC_Channel_Select
	jmp		L_EndIrq
RFC_Sample:
	jsr		L_Get_RFC_Data
	lda		#0
	sta		Counter_50Hz
	jmp		L_EndIrq


I_Timer0IRQ_Handler:
	nop										; 未使用Tim0中断
	jmp		L_EndIrq


I_Timer1IRQ_Handler:
	nop										; 未使用Tim1中断
	jmp		L_EndIrq


I_Timer2IRQ_Handler:
	bbr1	Backlight_Flag,L_32Hz_Juge		; PWM调光开关
	lda		Light_Level
	cmp		Counter_256Hz
	bcc		PWM_Set_High
	LED_SET_LOW								; PWM调光口输出低
	bra		L_256Hz_Juge
PWM_Set_High:
	LED_SET_HIGH							; PWM调光口输出高

L_256Hz_Juge:
	inc		Counter_256Hz
	lda		Counter_256Hz
	cmp		#4
	bcc		L_32Hz_Juge
	; bcc		Timer2IRQ_Exit
	lda		#0
	sta		Counter_256Hz

L_32Hz_Juge:
	bbr4	Timer_Switch,L_21Hz_Juge		; 32Hz计数开关
	inc		Counter_32Hz
	lda		Counter_32Hz
	cmp		#32
	bcc		L_21Hz_Juge
	lda		#0
	sta		Counter_32Hz
	smb4	Timer_Flag						; 32Hz标志

L_21Hz_Juge:
	bbr3	Timer_Switch,L_4Hz_Juge			; 21Hz计数开关
	inc		Counter_21Hz
	lda		Counter_21Hz
	cmp		#48
	bcc		L_4Hz_Juge
	lda		#0
	sta		Counter_21Hz
	smb3	Timer_Flag						; 21Hz标志

L_4Hz_Juge:
	bbr2	Timer_Switch,Timer2IRQ_Exit		; 4Hz计数开关
	inc		Counter_21Hz
	beq		Timer2IRQ_Exit
	smb2	Timer_Flag						; 4Hz标志

Timer2IRQ_Exit:
	jmp		L_EndIrq


I_PaIRQ_Handler:
	rmb4	SYSCLK
	smb0	Key_Flag
	smb1	Key_Flag						; 首次触发
	rmb2	Key_Flag						; 如果有新的下降沿到来，清快加标志位
	rmb4	Timer_Flag						; 清32Hz标志位
	smb4	Timer_Switch					; 打开快加定时

	rmb5	IR_Flag
	jsr		F_ClearScreen
	jsr		L_Send_DRAM

	jmp		L_EndIrq


I_LcdIRQ_Handler:
	inc		Counter_2Hz
	lda		Counter_2Hz						; 2Hz计数
	cmp		#4
	bcc		L_1Hz_Juge
	lda		#0
	sta		Counter_2Hz
	smb1	Timer_Flag						; 1Hz标志
	lda		#$0f
	ora		Time_Flag						; 走时加时、响铃加时、返回加时，RFC采样加时
	sta		Time_Flag
	rmb4	Time_Flag						; 清除响闹阻塞状态

L_1Hz_Juge:
	inc		Counter_1Hz
	lda		Counter_1Hz						; 2Hz计数
	cmp		#8
	bcc		LcdIRQ_Exit
	lda		#0
	sta		Counter_1Hz
	smb0	Timer_Flag

LcdIRQ_Exit:
	jmp		L_EndIrq
