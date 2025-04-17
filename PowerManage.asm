F_PowerSavingMode:
	lda		PC
	and		#$20
	beq		L_Low_Power								; 判断省电模式入口条件
	rts

L_Low_Power:
	jsr		Enter_LowPower							; 关闭耗电资源
PS_Mode_Loop:
	smb4	SYSCLK
	sta		HALT									; 休眠
	rmb4	SYSCLK
	jsr		F_Time_Run								; 在这个模式下只开半S中断用于走时
	lda		PC
	and		#$20
	beq		PS_Mode_Loop							; 若DC侦测口无高电平则跑省电模式循环

	jsr		Exit_LowPower							; 打开主循环使用的外设资源
	rts

Enter_LowPower:
	lda		#$40
	sta		IER
	rmb1	Backlight_Flag
	LED_SET_HIGH

	rmb4	Key_Flag
	rmb6	Key_Flag
	rmb1	RFC_Flag
	rmb7	Timer_Switch							; 关闭蜂鸣器时钟源
	rmb3	Timer_Switch							; 关闭21Hz计时
	lda		#0
	sta		Counter_21Hz
	lda		#00
	sta		Beep_Serial
	rts

Exit_LowPower:
	lda		#$59
	sta		IER
	rmb4	IFR

	lda		#%00001
	sta		Sys_Status_Flag
	lda		#0
	sta		Sys_Status_Ordinal
	REFLASH_DISPLAY

	smb1	Backlight_Flag
	rmb3	Backlight_Flag							; 恢复显示后
	rts



F_Display_LightLevel:
	bbr3	Backlight_Flag,NoDisLL
	bbs0	Timer_Flag,DisLL_Start
NoDisLL:
	rts
DisLL_Start:
	rmb0	Timer_Flag

	jsr		F_UnDisplay_D0_1
	jsr		F_UnDisplay_D2_3
	jsr		L_Dis_Lxx

	inc		Counter_LL
	lda		Counter_LL
	cmp		#3
	bcc		DisLL_Over
	lda		#0
	sta		Counter_LL
	rmb3	Backlight_Flag
DisLL_Over:
	REFLASH_DISPLAY
	rts




F_AutoLL_Get:
	bbs4	Backlight_Flag,GetLL_Start
	rts
GetLL_Start:
	rmb4	Backlight_Flag

	lda		PD
	and		#$20
	beq		High_Light_Mode
	lda		#0
	sta		Auto_LightLevel
	rts
High_Light_Mode:
	lda		#2
	sta		Auto_LightLevel
	rts


F_CloseLED_Count:
	bbr4	Clock_Flag,CloseLEDCount_Exit
	bbs7	Time_Flag,CloseLEDCount
	rts
CloseLEDCount:
	dec		CloseLED_Counter
	lda		CloseLED_Counter
	bne		CloseLEDCount_Exit
	rmb1	Backlight_Flag
	rmb1	RFC_Flag						; 重新启用RFC采样
	rmb4	Clock_Flag
	LED_SET_HIGH
	lda		#%00001
	sta		Sys_Status_Flag
	lda		#0
	sta		Sys_Status_Ordinal				; 30S计时到了之后熄屏
	jsr		Return_CD_Mode					; 返回时显
CloseLEDCount_Exit:
	rts
