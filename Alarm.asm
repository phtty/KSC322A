F_Alarm_GroupDis:
	bbs3	Backlight_Flag,F_Alarm_GroupNoDis
	jmp		F_Display_Alarm
F_Alarm_GroupNoDis:
	rts




F_Alarm_GroupSet:
	bbs3	Backlight_Flag,Alarm_GroupSet_NoDis

	lda		Sys_Status_Ordinal
	clc
	rol
	tax
	lda		AlarmGroupHandle_Table+1,x
	pha
	lda		AlarmGroupHandle_Table,x
	pha
Alarm_GroupSet_NoDis:
	rts											; 根据当前子模式，跳转到对应的显示函数

; 根据当前闹钟组进对应设置模式
AlarmGroupHandle_Table:
	dw		F_Alarm_SwitchStatue-1
	dw		F_AlarmHour_Set-1
	dw		F_AlarmMin_Set-1
	dw		F_AlarmWorkDay_Set-1




; 闹钟开关显示
F_Alarm_SwitchStatue:
	bbs1	Timer_Flag,?AlarmSW_BlinkStart
	rts
?AlarmSW_BlinkStart:
	rmb1	Timer_Flag
	bbs0	Timer_Flag,AlarmSW_UnDisplay
	ldx		Alarm_Group
	lda		Bit_Num_Table,x
	and		Alarm_Switch						; 和闹钟开关状态相与得出该位号是开还是关

	beq		ALSwitch_DisOff
	lda		#2
	ldx		#led_d0
	jsr		L_Dis_7Bit_WordDot					; 显示ON

	lda		#3
	ldx		#led_d1
	jsr		L_Dis_7Bit_WordDot
	bra		ALSwitch_DisNum

ALSwitch_DisOff:
	lda		#9
	ldx		#led_d0
	jsr		L_Dis_7Bit_WordDot					; 显示--

	lda		#9
	ldx		#led_d1
	jsr		L_Dis_7Bit_WordDot

ALSwitch_DisNum:
	lda		#4
	ldx		#led_d2
	jsr		L_Dis_7Bit_WordDot					; 显示A

	lda		Alarm_Group
	ldx		#led_d3
	jsr		L_Dis_7Bit_DigitDot					; 显示闹钟序号
	bra		AlarmSW_Blink_Exit

AlarmSW_UnDisplay:
	rmb0	Timer_Flag
	jsr		F_UnDisplay_D0_1
	jsr		F_UnDisplay_D2_3

AlarmSW_Blink_Exit:
	REFLASH_DISPLAY
	rts



F_AlarmHour_Set:
	bbs1	Timer_Flag,L_AlarmHour_Set
	rts
L_AlarmHour_Set:
	rmb1	Timer_Flag

	jsr		F_DisCol

	bbs2	Key_Flag,L_AlarmHour_Display		; 有快加时常亮
	bbs5	IR_Flag,L_AlarmHour_Display			; 有快加时常亮
	bbs0	Timer_Flag,L_AlarmHour_Clear
L_AlarmHour_Display:
	jsr		F_Display_Alarm
	REFLASH_DISPLAY								; 置位刷新显示标志位
	rts
L_AlarmHour_Clear:
	rmb0	Timer_Flag							; 清1S标志
	jsr		F_UnDisplay_D0_1
	REFLASH_DISPLAY								; 置位刷新显示标志位
	rts




F_AlarmMin_Set:
	bbs1	Timer_Flag,L_AlarmMin_Set
	rts
L_AlarmMin_Set:
	rmb1	Timer_Flag

	jsr		F_DisCol

	bbs2	Key_Flag,L_AlarmMin_Display			; 有快加时常亮
	bbs5	IR_Flag,L_AlarmMin_Display			; 有快加时常亮
	bbs0	Timer_Flag,L_AlarmMin_Clear
L_AlarmMin_Display:
	jsr		F_Display_Alarm
	REFLASH_DISPLAY								; 置位刷新显示标志位
	rts
L_AlarmMin_Clear:
	rmb0	Timer_Flag							; 清1S标志
	jsr		F_UnDisplay_D2_3
	REFLASH_DISPLAY								; 置位刷新显示标志位
	rts




F_AlarmWorkDay_Set:
	bbs1	Timer_Flag,L_AlarmWorkDay_Set
	rts
L_AlarmWorkDay_Set:
	rmb1	Timer_Flag

	jsr		F_ClrCol

	bbs0	Timer_Flag,L_AlarmWorkDay_Clear
	ldx		#led_d1
	lda		#1
	jsr		L_Dis_7Bit_DigitDot					; 固定显示1-
	ldx		#led_d2
	lda		#10
	jsr		L_Dis_7Bit_DigitDot
	ldx		#led_d2+6
	jsr		F_DisSymbol

	ldx		Alarm_Group
	dex											; Alarm_Group-1为闹组实际对应的工作日
	lda		Alarm_WorkDayAddr,x
	clc
	adc		#5
	ldx		#led_d3
	jsr		L_Dis_7Bit_DigitDot
	REFLASH_DISPLAY								; 置位刷新显示标志位
	rts
L_AlarmWorkDay_Clear:
	rmb0	Timer_Flag							; 清1S标志
	jsr		F_UnDisplay_D0_1
	jsr		F_UnDisplay_D2_3
	REFLASH_DISPLAY								; 置位刷新显示标志位
	rts




AlarmDot_Blink:
	bbs1	Symbol_Flag,AL_Blink_Start
	rts
AL_Blink_Start:
	rmb1	Symbol_Flag
	bbs0	Symbol_Flag,AL_Blink_NoDis

	ldx		Alarm_Group
	lda		Bit_Num_Table,x
	ora		Triggered_AlarmGroup
	sta		P_Temp+1
	bbr0	P_Temp+1,AL1_NoDisplay				; 操作闹组和触发闹组或操作，再判断bit0和bit1决定亮AL1、AL2
	jsr		F_DisAL1
AL1_NoDisplay:
	bbr1	P_Temp+1,AL2_NoDisplay
	jsr		F_DisAL2
AL2_NoDisplay:
	rts

AL_Blink_NoDis:
	rmb0	Symbol_Flag
	ldx		Alarm_Group
	lda		Bit_Num_Table,x
	ora		Triggered_AlarmGroup
	sta		P_Temp+1
	bbr0	P_Temp+1,AL1_NoClear				; 操作闹组和触发闹组或操作，再判断bit0和bit1决定灭AL1、AL2
	jsr		F_ClrAL1
AL1_NoClear:
	bbr1	P_Temp+1,AL2_NoClear
	jsr		F_ClrAL2
AL2_NoClear:
	rts


AlarmDot_Const:
	bbs2	Symbol_Flag,AL_Const_Start
	rts
AL_Const_Start:
	rmb2	Symbol_Flag
	ldx		Alarm_Group
	lda		Bit_Num_Table,x
	ora		Triggered_AlarmGroup
	sta		P_Temp+1
	bbs0	P_Temp+1,AL2_Const_Juge				; 判断AL1有无操作闹组或响闹，有则不进行常显
	bbr0	Alarm_Switch,AL1_Const_Clear		; 根据Alarm Swtich亮灭AL1
	jsr		F_DisAL1
	bra		AL2_Const_Juge
AL1_Const_Clear:
	jsr		F_ClrAL1

AL2_Const_Juge:
	bbs1	P_Temp+1,AL_Const_Exit				; 判断AL2有无操作闹组或响闹，有则不进行常显
	bbr1	Alarm_Switch,AL2_Const_Clear		; 根据Alarm Swtich亮灭AL2
	jsr		F_DisAL2
	bra		AL_Const_Exit
AL2_Const_Clear:
	jsr		F_ClrAL2
AL_Const_Exit:
	rts




F_Alarm_Handler:
	bbr5	Time_Flag,Alarm_NoJuge				; 每S只进1次闹钟判断
	rmb5	Time_Flag
	lda		Alarm_Switch
	bne		Is_Alarm_Trigger					; 没有任何闹钟开启则不会判断闹钟是否触发
Alarm_NoJuge:
	rts

; 任意一组闹钟设定值的时、分符合当前时间，就设置闹钟触发标志位,并同步至触发闹钟
; 同时判断此闹钟是否处于工作日
Is_Alarm_Trigger:
	lda		Alarm_Switch
	and		#010B
	beq		L_Alarm2_NoMatch					; 如果此闹钟没有开启，则不会判断它
	lda		R_Time_Hour
	cmp		R_Alarm2_Hour
	beq		L_Alarm2_HourMatch
L_Alarm2_NoMatch:
	lda		Alarm_Switch
	and		#001B
	beq		L_Alarm1_NoMatch					; 如果此闹钟没有开启，则不会判断它
	lda		R_Time_Hour
	cmp		R_Alarm1_Hour
	beq		L_Alarm1_HourMatch
L_Alarm1_NoMatch:
	rts

L_Alarm1_HourMatch:
	lda		R_Time_Min
	cmp		R_Alarm1_Min
	beq		L_Alarm1_MinMatch						
	rts											; 闹钟1分钟不匹配，闹钟未触发

L_Alarm2_HourMatch:
	lda		R_Time_Min
	cmp		R_Alarm2_Min
	beq		L_Alarm2_MinMatch
	bra		L_Alarm2_NoMatch					; 闹钟2分钟不匹配，判断闹钟1


L_Alarm1_MinMatch:
	lda		R_Time_Sec
	cmp		#00
	beq		Alarm1_SecMatch
	rts											; 若秒不匹配，则闹钟不触发并退出
Alarm1_SecMatch:
	lda		Alarm1_WorkDay
	cmp		#2
	beq		?No_WorkDay_Juge					; 若是周内全为工作日，则一定响闹
	cmp		#1
	bne		?No_WorkDay_1_6
	lda		R_Date_Week
	beq		L_Alarm1_NoMatch					; 单休周天不响闹
	bra		?No_WorkDay_Juge
?No_WorkDay_1_6:
	lda		R_Date_Week 
	beq		L_Alarm1_NoMatch					; 双休周天不响闹
	cmp		#6
	beq		L_Alarm1_NoMatch					; 双休周六也不响闹
?No_WorkDay_Juge:
	bbs1	Triggered_AlarmGroup,AL2_Triggered	; 闹钟2已经触发的情况下不再重复执行响闹初始化
	jsr		L_Alarm_Match_Handle
AL2_Triggered:
	lda		Triggered_AlarmGroup
	ora		#001B
	sta		Triggered_AlarmGroup
	rts

L_Alarm2_MinMatch:
	lda		R_Time_Sec
	cmp		#00
	beq		Alarm2_SecMatch						; 若秒不匹配，则闹钟不触发并退出
	rts
Alarm2_SecMatch:
	lda		Alarm2_WorkDay
	cmp		#2
	beq		?No_WorkDay_Juge					; 若是周内全为工作日，则一定响闹
	cmp		#1
	bne		?No_WorkDay_1_6
	lda		R_Date_Week
	beq		L_Alarm2_NoMatch					; 单休周天不响闹
	bra		?No_WorkDay_Juge
?No_WorkDay_1_6:
	lda		R_Date_Week
	beq		L_Alarm2_NoMatch					; 双休周天不响闹
	cmp		#6
	beq		L_Alarm2_NoMatch					; 双休周六也不响闹
?No_WorkDay_Juge:
	jsr		L_Alarm_Match_Handle
	lda		#010B
	sta		Triggered_AlarmGroup
	bra		L_Alarm2_NoMatch					; 判断完AL2继续判断AL1




; 确定闹钟触发后的处理
L_Alarm_Match_Handle:
	smb1	Clock_Flag							; 同时满足小时和分钟的匹配，设置闹钟触发
	smb2	Clock_Flag							; 开启响闹模式
	rmb1	Timekeep_Flag						; 打断倒计时完成触发

	jsr		F_RFC_Abort							; 避免响闹时电压不稳终止RFC采样
	smb1	Time_Flag
	smb3	Timer_Switch						; 开启21Hz蜂鸣间隔定时
	lda		#0
	sta		Counter_21Hz
	sta		Louding_Counter

	bbs4	Sys_Status_Flag,?Timekeep_Mode
	lda		#%00001
	sta		Sys_Status_Flag
	lda		#0
	sta		Sys_Status_Ordinal					; 唤醒熄屏后会回到时间显示模式
?Timekeep_Mode:
	REFLASH_DISPLAY

	bbs1	Backlight_Flag,No_CloseScreen_Alarm
	smb1	Backlight_Flag
	smb4	Clock_Flag							; 灭屏触发的响闹，需要计时30S后关屏
	rmb7	Time_Flag
	lda		#90
	sta		CloseLED_Counter
No_CloseScreen_Alarm:
	rts




; X存商，A为余数
L_A_Div_3:
	ldx		#0
L_A_Div_3_Start:
	cmp		#3
	bcc		L_A_Div_3_Over
	sec
	sbc		#3
	inx
	bra		L_A_Div_3_Start
L_A_Div_3_Over:
	rts


; 将A左移X位
L_A_LeftShift_XBit:
	sta		P_Temp
Shift_Start:
	txa
	beq		Shift_End
	lda		P_Temp
	clc
	rol		P_Temp
	dex
	bra		Shift_Start
Shift_End:
	lda		P_Temp
	rts


Bit_Num_Table:
	db		00H
	db		01H
	db		02H
	db		04H
	db		08H
	db		10H
	db		20H
	db		40H
	db		80H
