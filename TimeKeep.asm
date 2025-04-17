F_Timekeep_Run:
	bbr0	Timekeep_Flag,Timekeep_NoRun		; 同时有计时开启标志和计时加时1S标志才会处理
	bbs4	Time_Flag,Timekeep_Run_Start
Timekeep_NoRun
	rts
Timekeep_Run_Start:
	rmb4	Time_Flag
	REFLASH_DISPLAY

	lda		Sys_Status_Ordinal
	bne		TimekeepDown_Mode
	sed											; 正计时增S
	lda		R_Timekeep_Sec
	clc
	adc		#1
	sta		R_Timekeep_Sec
	cmp		#$60
	bcc		?TimeStop							; 计时秒未溢出
	lda		#0
	sta		R_Timekeep_Sec
	lda		R_Timekeep_Min
	clc
	adc		#1
	sta		R_Timekeep_Min
?TimeStop:
	cld
	rts


TimekeepDown_Mode:
	sed
	lda		R_Timekeep_Sec
	beq		Timekeep_SecOverflowJuge			; 分借位发生
	sec
	sbc		#1
	sta		R_Timekeep_Sec
	bne		TimekeepDown_NoComplete
	lda		R_Timekeep_Min
	beq		TimekeepDown_Complete				; 计时完成
TimekeepDown_NoComplete:
	bra		TimeDown_Reflash_Dis
Timekeep_SecOverflowJuge:
	lda		R_Timekeep_Min
	beq		TimekeepDown_Complete				; 计时完成
	sec
	sbc		#1
	sta		R_Timekeep_Min						; 分不为0则减分，重置秒
	lda		#$59
	sta		R_Timekeep_Sec
	bra		TimeDown_Reflash_Dis
TimekeepDown_Complete:
	cld
	rmb0	Timekeep_Flag
	smb1	Timekeep_Flag						; 出现溢出则置位倒计时完成标志并复位计时开启

	smb1	Time_Flag
	smb3	Timer_Switch						; 开启21Hz蜂鸣间隔定时
	lda		#0
	sta		Counter_21Hz
	sta		Louding_Counter
	smb2	Clock_Flag							; 开启响闹模式
	rmb1	Clock_Flag							; 打断闹钟触发
TimeDown_Reflash_Dis:
	REFLASH_HALF_SEC
	REFLASH_DISPLAY
	rts




F_Timekeep_Display:
	bbs3	Backlight_Flag,Timekeep_NoDisplay
	bbs1	Timekeep_Flag,Timekeep_Over
	bbs6	Time_Flag,Timekeep_FlashDis
Timekeep_NoDisplay:
	rts
Timekeep_FlashDis:
	jmp		F_Display_Timekeep


Timekeep_Over:										; 倒计时完成时闪烁
	bbs1	Timer_Flag,TimekeepDownOver_Start
	rts
TimekeepDownOver_Start:
	rmb1	Timer_Flag

	bbs0	Timer_Flag,TimekeepDownOver_Clr			; 1S灭
	jsr		F_Display_Timekeep
	REFLASH_DISPLAY									; 置位刷新显示标志
	rts
TimekeepDownOver_Clr:
	rmb0	Timer_Flag								; 清1S标志
	jsr		F_UnDisplay_D0_1
	jsr		F_UnDisplay_D2_3
	REFLASH_DISPLAY									; 置位刷新显示标志
	rts
