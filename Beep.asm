F_BeepManage:
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
