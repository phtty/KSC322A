F_Timekeep_Run:
	bbr0	Timekeep_Flag,?TimeStop				; 同时有计时开启标志和计时加时1S标志才会处理
	bbr0	Timer_Flag,?TimeStop
	rmb0	Timer_Flag
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
	lda		R_Timekeep_Sec						; 倒计时减S
	bne		TimeDown_NoOverflow					; 秒不为0则一定没倒计时结束

	lda		R_Timekeep_Min
	beq		TimekeepDown_Complete				; 分秒都为0时则为计时结束
	sec
	sbc		#1
	sta		R_Timekeep_Min						; 分不为0则重置秒，减分

	lda		#$59
	sta		R_Timekeep_Sec
	bra		TimeDown_Reflash_Dis
TimekeepDown_Complete:
	cld
	rmb0	Timekeep_Flag
	smb1	Timekeep_Flag						; 出现溢出置位倒计时完成标志并复位计时开启

	jsr		F_RFC_Abort							; 避免响闹时电压不稳终止RFC采样
	smb1	Time_Flag
	smb3	Timer_Switch						; 开启21Hz蜂鸣间隔定时
	bra		TimeDown_Reflash_Dis

TimeDown_NoOverflow:
	sec
	sbc		#1
	sta		R_Timekeep_Sec
	cld
TimeDown_Reflash_Dis:
	REFLASH_HALF_SEC
	REFLASH_DISPLAY
	rts


F_Timekeep_BeepHandler:
	bbr1	Timekeep_Flag,No_Timekeep_Process	; 有倒计时完成标志位再进处理
	jmp		Timekeep_BeepProcess
No_Timekeep_Process:
	bbs4	Key_Flag,BeepingNoClose				; 如果有按键提示音，则不关闭蜂鸣器
	rmb7	Timer_Switch						; 关闭蜂鸣器时钟源计时开关
	rmb3	PB

	rmb3	Timer_Flag
	rmb1	Timekeep_Flag
BeepingNoClose:
	lda		#0
	sta		TimekeepLoud_Counter
	rts


Timekeep_BeepProcess:
	bbs1	Time_Flag,?BeepStart				; 每响铃1S进一次
	rts
?BeepStart:
	rmb1	Time_Flag
	lda		AlarmLoud_Counter
	cmp		#60
	beq		CloseBeep							; 响铃60S后关闭响闹
	lda		#4									; 响闹的序列为4，2声
	sta		Beep_Serial
	inc		TimekeepLoud_Counter
	rts

CloseBeep:										; 结束并关闭响闹
	rmb1	RFC_Flag							; 取消禁用RFC采样

	rmb1	Timekeep_Flag						; 关闭倒计时完成标志

	bbs4	Key_Flag,?BeepJuge_Exit				; 如果有按键提示音，则不关闭蜂鸣器
	rmb7	Timer_Switch						; 关闭蜂鸣器时钟源计时开关
	rmb3	PB

	rmb3	Timer_Flag
	rmb1	Time_Flag
?BeepJuge_Exit:
	rts




F_Timekeep_Display:
	bbs1	Timekeep_Flag,Timekeep_Over
	bbs6	Time_Flag,Timekeep_FlashDis
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
