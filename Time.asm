F_Time_Run:
	bbs0	Time_Flag,L_TimeRun_Add					; 有加时1S标志才进处理
	rts
L_TimeRun_Add:
	rmb0	Time_Flag								; 清增S标志

	inc		R_Time_Sec
	lda		R_Time_Sec
	cmp		#60
	bcc		L_Time_SecRun_Exit						; 未发生分钟进位
	lda		#0
	sta		R_Time_Sec
	inc		R_Time_Min
	;jsr		CompensationTime_CHG					; 每次加分钟的时候都要增减温补时间
	lda		R_Time_Min
	cmp		#60
	bcc		L_Time_SecRun_Exit						; 未发生小时进位
	lda		#0
	sta		R_Time_Min
	inc		R_Time_Hour
	lda		R_Time_Hour
	cmp		#24
	bcc		L_Time_SecRun_Exit						; 未发生天进位
	lda		#0
	sta		R_Time_Hour
	jsr		F_Calendar_Add
L_Time_SecRun_Exit:
	rts




; 时间显示
F_Time_Display:
	bbs1	Timer_Flag,L_TimeDot_Out
	rts
L_TimeDot_Out:
	rmb1	Timer_Flag								; 时间显示半S更新一次
	jsr		F_Display_Time
	REFLASH_DISPLAY									; 置位刷新显示标志位
	rts




; 时钟设置模式，根据子模式序号进入对应的设置项显示
F_Clock_Set:
	lda		Sys_Status_Ordinal
	bne		No_TMSwitch_Display
	jmp		F_TimeMode_Switch						; 12/24h模式切换
No_TMSwitch_Display:
	cmp		#1
	bne		No_HourSet_Display
	jmp		F_DisHour_Set
No_HourSet_Display:
	cmp		#2
	bne		No_MinSet_Display
	jmp		F_DisMin_Set
No_MinSet_Display:
	cmp		#3
	bne		No_YearSet_Display
	jsr		F_ClrCol								; 日期不显示COL和PM
	jsr		F_ClrPM
	jmp		F_DisYear_Set
No_YearSet_Display:
	cmp		#4
	bne		No_MonthSet_Display
	jsr		F_ClrCol								; 日期不显示COL和PM
	jsr		F_ClrPM
	jmp		F_DisMonth_Set
No_MonthSet_Display:
	jsr		F_ClrCol								; 日期不显示COL和PM
	jsr		F_ClrPM
	jmp		F_DisDay_Set




; 时间设置模式切换显示
F_TimeMode_Switch:
	bbs1	Timer_Flag,L_TimeMode_Out
	rts
L_TimeMode_Out:
	rmb1	Timer_Flag
	jsr		F_ClrCol
	jsr		F_ClrPM
	bbs2	Key_Flag,L_TimeMode_Display
	bbs5	IR_Flag,L_TimeMode_Display				; 有快加时常亮
	bbs0	Timer_Flag,L_Mode_Clear					; 1S灭
L_TimeMode_Display:
	jsr		L_Dis_xxHr
	REFLASH_DISPLAY									; 置位刷新显示标志
	rts
L_Mode_Clear:
	rmb0	Timer_Flag								; 清1S标志
	jsr		F_UnDisplay_D0_1
	jsr		F_UnDisplay_D2_3
	REFLASH_DISPLAY									; 置位刷新显示标志
	rts




F_DisHour_Set:
	bbs1	Timer_Flag,L_Blink_Hour
	rts
L_Blink_Hour:
	rmb1	Timer_Flag								; 清半S标志

	jsr		F_DisCol

	bbs2	Key_Flag,L_KeyTrigger_NoBlink_Hour		; 有快加时常亮
	bbs5	IR_Flag,L_KeyTrigger_NoBlink_Hour		; 有快加时常亮
	bbs0	Timer_Flag,L_Hour_Clear
L_KeyTrigger_NoBlink_Hour:
	jsr		L_DisTime_Hour							; 半S亮
	jsr		L_DisTime_Min
	REFLASH_DISPLAY									; 置位刷新显示标志
	rts
L_Hour_Clear:
	rmb0	Timer_Flag
	jsr		F_UnDisplay_D0_1						; 1S灭
	REFLASH_DISPLAY									; 置位刷新显示标志
	rts


F_DisMin_Set:
	bbs1	Timer_Flag,L_Blink_Min					; 没有半S标志时不闪烁
	rts
L_Blink_Min:
	rmb1	Timer_Flag								; 清半S标志

	jsr		F_DisCol

	bbs2	Key_Flag,L_KeyTrigger_NoBlink_Min		; 有快加时常亮
	bbs5	IR_Flag,L_KeyTrigger_NoBlink_Min		; 有快加时常亮
	bbs0	Timer_Flag,L_Min_Clear
L_KeyTrigger_NoBlink_Min:
	jsr		L_DisTime_Min							; 半S亮
	jsr		L_DisTime_Hour
	REFLASH_DISPLAY									; 置位刷新显示标志
	rts
L_Min_Clear:
	rmb0	Timer_Flag
	jsr		F_UnDisplay_D2_3						; 1S灭
	REFLASH_DISPLAY									; 置位刷新显示标志
	rts
