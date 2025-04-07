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
