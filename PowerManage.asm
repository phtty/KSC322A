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
	rts

Exit_LowPower:
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
