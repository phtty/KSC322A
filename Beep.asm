F_BeepManage:
	jsr		L_LoudManage
	bbs3	Timer_Flag,L_Beeping
	rts
L_Beeping:
	rmb3	Timer_Flag

	lda		Beep_Serial
	beq		L_NoBeep_Serial_Mode
	dec		Beep_Serial
	bbr0	Beep_Serial,L_NoBeep_Serial_Mode
	smb3	PB_TYPE								; PB3 设置CMOS输出
	lda		PB
	and		#$f7
	sta		PB
	smb7	Timer_Switch						; 开启PB3软件PWM输出
	rts

L_NoBeep_Serial_Mode:
	rmb7	Timer_Switch						; 关闭PB3软件PWM输出
	rmb3	PB_TYPE								; PB3选择NMOS输出1避免漏电
	smb3	PB

	lda		Beep_Serial
	bne		No_KeyBeep_Over	
	bbs4	Key_Flag,No_KeyBeep_Over
	bbs6	Key_Flag,No_KeyBeep_Over			; 存在错误音或按键音，则需要在响铃结束后关闭21Hz计时
	rmb4	Key_Flag
	rmb6	Key_Flag
	rmb1	RFC_Flag							; 按键音的响铃完毕重新取消禁用RFC采样
	rmb3	Timer_Switch						; 关闭21Hz计时
No_KeyBeep_Over:
	rts




; 响闹管理
L_LoudManage:
	bbr2	Clock_Flag,NoLouding				; 存在响闹标志位时才进处理
	bbs1	Time_Flag,LoudHandle_Start
NoLouding:
	rts
LoudHandle_Start:
	rmb1	Time_Flag

	bbs1	Clock_Flag,Alarm_LoudHandle
	bbs1	Timekeep_Flag,Timekeep_LoudHandle
	rts
Alarm_LoudHandle:
	lda		#8									; 闹钟响闹的序列为8，4声
	sta		Beep_Serial
	bra		LoudCounter_Juge
Timekeep_LoudHandle:
	lda		#4									; 计时响闹的序列为4，2声
	sta		Beep_Serial
LoudCounter_Juge:
	inc		Louding_Counter
	lda		Louding_Counter
	cmp		#60
	bcs		L_CloseLoud							; 响闹计时达到60S后关闭
	rts

L_CloseLoud:									; 结束并关闭响闹
	rmb1	RFC_Flag							; 取消禁用RFC采样
	lda		#0
	sta		Louding_Counter
	bbs4	Key_Flag,L_Beep_NoClose				; 如果有按键提示音，则不关闭蜂鸣器
	rmb7	Timer_Switch						; 关闭蜂鸣器时钟源计时开关
	rmb3	Timer_Switch						; 关闭21Hz计时
	rmb3	PB
	rmb3	Timer_Flag
L_Beep_NoClose:
	rmb1	Time_Flag
	rmb2	Clock_Flag							; 复位响闹模式和响闹加时1S

	bbs1	Clock_Flag,?AlarmLoud_Over
	bbs1	Timekeep_Flag,?TimekeepLoud_Over
	rts
?AlarmLoud_Over:
	lda		#0
	sta		Triggered_AlarmGroup
	rmb1	Clock_Flag							; 复位闹钟触发标志
	rts
?TimekeepLoud_Over:
	lda		R_TimekeepBak_Min
	sta		R_Timekeep_Min
	lda		R_TimekeepBak_Sec
	sta		R_Timekeep_Sec
	rmb1	Timekeep_Flag						; 复位倒计时完成标志
	REFLASH_DISPLAY
	rts
