F_Display_Time:									; 调用显示函数显示当前时间
	jsr		L_DisTime_Min
	jsr		L_DisTime_Hour
	rts

L_DisTime_Min:									; 显示分钟
	lda		R_Time_Min
	jsr		L_A_DecToHex
	pha
	and		#$0f
	ldx		#led_d3
	jsr		L_Dis_7Bit_DigitDot
	pla
	and		#$f0
	jsr		L_LSR_4Bit
	ldx		#led_d2
	jsr		L_Dis_7Bit_DigitDot
	rts

L_DisTime_Hour:									; 显示小时
	bbr0	Clock_Flag,L_24hMode_Time
	lda		R_Time_Hour
	cmp		#12
	bcs		L_Time12h_PM
	jsr		F_ClrPM								; 12h模式AM需要灭PM点
	lda		R_Time_Hour							; 改显存函数会改A值，重新取变量
	cmp		#0
	beq		L_Time_0Hour
	bra		L_Start_DisTime_Hour
L_Time12h_PM:
	jsr		F_DisPM								; 12h模式PM需要亮PM点
	lda		R_Time_Hour							; 改显存函数会改A值，重新取变量
	sec
	sbc		#12
	cmp		#0
	bne		L_Start_DisTime_Hour
L_Time_0Hour:									; 12h模式0点需要变成12点
	lda		#12
	bra		L_Start_DisTime_Hour

L_24hMode_Time:
	jsr		F_ClrPM								; 24h模式下需要灭PM点
	lda		R_Time_Hour
L_Start_DisTime_Hour:
	jsr		L_A_DecToHex
	pha
	and		#$0f
	ldx		#led_d1
	jsr		L_Dis_7Bit_DigitDot
	pla
	and		#$f0
	jsr		L_LSR_4Bit
	bne		L_Hour_Tens_NoZero					; 小时模式的十位0不显示
	lda		#$0a
L_Hour_Tens_NoZero:
	ldx		#led_d0
	jsr		L_Dis_7Bit_DigitDot
	rts




; Alarm_Group = 当前处理的闹钟组
F_Display_Alarm:								; 调用显示函数显示当前闹钟组
	jsr		L_DisAlarm_Min
	jsr		L_DisAlarm_Hour

	rts

L_DisAlarm_Min:
	ldx		Alarm_Group
	dex
	lda		Alarm_MinAddr,x
	sta		R_Alarm_Min
	lda		R_Alarm_Min

	jsr		L_A_DecToHex
	pha
	and		#$0f
	ldx		#led_d3
	jsr		L_Dis_7Bit_DigitDot
	pla
	and		#$f0
	jsr		L_LSR_4Bit
	ldx		#led_d2
	jsr		L_Dis_7Bit_DigitDot
	rts

L_DisAlarm_Hour:								; 显示闹钟小时
	ldx		Alarm_Group
	dex
	lda		Alarm_HourAddr,x
	sta		R_Alarm_Hour
	bbr0	Clock_Flag,L_24hMode_Alarm

	lda		R_Alarm_Hour
	cmp		#12
	bcs		L_Alarm12h_PM
	jsr		F_ClrPM								; 12h模式AM需要灭PM点
	lda		R_Alarm_Hour						; 改显存函数会改A值，重新取变量
	cmp		#0
	beq		L_Alarm_0Hour
	bra		L_Start_DisAlarm_Hour
L_Alarm12h_PM:
	jsr		F_DisPM								; 12h模式PM需要亮PM点
	lda		R_Alarm_Hour						; 改显存函数会改A值，重新取变量
	sec
	sbc		#12
	cmp		#0
	bne		L_Start_DisAlarm_Hour
L_Alarm_0Hour:									; 12h模式0点需要变成12点
	lda		#12
	bra		L_Start_DisAlarm_Hour

L_24hMode_Alarm:
	jsr		F_ClrPM								; 24h模式下需要灭PM点
	lda		R_Alarm_Hour
L_Start_DisAlarm_Hour:
	jsr		L_A_DecToHex
	pha
	and		#$0f
	ldx		#led_d1
	jsr		L_Dis_7Bit_DigitDot
	pla
	and		#$f0
	jsr		L_LSR_4Bit
	bne		L_AlarmHour_Tens_NoZero				; 小时模式的十位0不显示
	lda		#$0a
L_AlarmHour_Tens_NoZero:
	ldx		#led_d0
	jsr		L_Dis_7Bit_DigitDot
	rts


; 显示日期函数
F_Display_Date:
	jsr		L_DisDate_Day
	jsr		L_DisDate_Month
	rts

L_DisDate_Day:
	lda		R_Date_Day
	jsr		L_A_DecToHex
	pha
	and		#$0f
	ldx		#led_d7
	jsr		L_Dis_7Bit_DigitDot
	pla
	and		#$f0
	jsr		L_LSR_4Bit
	bne		L_Day_Tens_NoZero					; 日期十位0不显示
	lda		#10
L_Day_Tens_NoZero:
	ldx		#led_d6
	jsr		L_Dis_7Bit_DigitDot
	rts

L_DisDate_Month:
	lda		R_Date_Month
	jsr		L_A_DecToHex
	pha
	and		#$0f
	ldx		#led_d5
	jsr		L_Dis_7Bit_DigitDot
	pla
	and		#$f0
	jsr		L_LSR_4Bit
	bne		L_Month_Tens_NoZero					; 月份十位0不显示
	lda		#0
L_Month_Tens_NoZero:
	ldx		#led_d4
	jsr		L_Dis_2Bit_DigitDot
	rts

L_DisDate_Year:
	lda		#00									; 20xx年的开头20是固定的
	ldx		#led_d1
	jsr		L_Dis_7Bit_DigitDot
	lda		#02
	jsr		L_A_DecToHex
	ldx		#led_d0
	jsr		L_Dis_7Bit_DigitDot

	lda		R_Date_Year							; 显示当前的年份
	jsr		L_A_DecToHex
	pha
	and		#$0f
	ldx		#led_d3
	jsr		L_Dis_7Bit_DigitDot
	pla
	and		#$f0
	jsr		L_LSR_4Bit
	ldx		#led_d2
	jsr		L_Dis_7Bit_DigitDot
	rts




F_UnDisplay_D0_1:								; 闪烁时取消显示用的函数
	lda		#10
	ldx		#led_d0
	jsr		L_Dis_7Bit_DigitDot
	lda		#10
	ldx		#led_d1
	jsr		L_Dis_7Bit_DigitDot
	rts


F_UnDisplay_D2_3:								; 闪烁时取消显示用的函数
	lda		#10
	ldx		#led_d2
	jsr		L_Dis_7Bit_DigitDot
	lda		#10
	ldx		#led_d3
	jsr		L_Dis_7Bit_DigitDot
	rts



F_UnDisplay_D4_5:								; 闪烁时取消显示用的函数
	lda		#0
	ldx		#led_d4
	jsr		L_Dis_2Bit_DigitDot
	lda		#10
	ldx		#led_d5
	jsr		L_Dis_7Bit_DigitDot
	rts


F_UnDisplay_D6_7:								; 闪烁时取消显示用的函数
	lda		#10
	ldx		#led_d6
	jsr		L_Dis_7Bit_DigitDot
	lda		#10
	ldx		#led_d7
	jsr		L_Dis_7Bit_DigitDot
	rts




F_Display_Week:
	jsr		L_GetWeek
	sta		R_Date_Week

	rmb2	Calendar_Flag
	ldx		#led_week1
	jsr		L_Dis_7Bit_WeekDot
	smb2	Calendar_Flag
	lda		R_Date_Week
	ldx		#led_week2
	jsr		L_Dis_7Bit_WeekDot
	rts



; 显示温度函数
F_Display_Temper:
	ldx		#led_minus
	jsr		F_ClrSymbol							; 清负号显示
	ldx		#led_d8
	lda		#0
	jsr		L_Dis_2Bit_DigitDot					; 清温度百位显示

	ldx		#led_TMPC
	jsr		F_ClrSymbol
	ldx		#led_TMPF
	jsr		F_ClrSymbol							; 清理温度单位显示

	bbr3	RFC_Flag,Dis_CDegree
	jmp		Display_FahrenheitDegree

Dis_CDegree:
	lda		R_Temperature
	jsr		L_A_DecToHex
	sta		P_Temp+7
	and		#$0f
	ldx		#led_d10
	jsr		L_Dis_7Bit_DigitDot
	lda		P_Temp+7
	and		#$f0
	beq		Degree_NoTens						; 高4位为0，则d9不显示
	jsr		L_LSR_4Bit
	ldx		#led_d9
	jsr		L_Dis_7Bit_DigitDot
	bra		Dis_CelSymbol
Degree_NoTens:
	lda		#10
	ldx		#led_d9
	jsr		L_Dis_7Bit_DigitDot
	bbr2	RFC_Flag,NoMinusTemper				; 温度是个位负数时，d9显示负号

	ldx		#led_d9+6
	jsr		F_DisSymbol
	bra		NoMinusTemper

Dis_CelSymbol:
	bbr2	RFC_Flag,NoMinusTemper				; 温度为十位负数时，d8显示负号
	ldx		#led_minus
	jsr		F_DisSymbol

NoMinusTemper:
	ldx		#led_TMPC							; 显示摄氏度C
	jsr		F_DisSymbol
	rts


Display_FahrenheitDegree:
	jsr		F_C2F
	lda		R_Temperature_F
	jsr		L_A_DecToHex

	pha
	txa
	ldx		#led_d8
	jsr		L_Dis_2Bit_DigitDot
	pla
	pha
	and		#$f0
	jsr		L_LSR_4Bit
	ldx		#led_d9
	jsr		L_Dis_7Bit_DigitDot
	pla
	and		#$0f
	ldx		#led_d10
	jsr		L_Dis_7Bit_DigitDot
	ldx		#led_TMPF							; 显示华氏度F
	jsr		F_DisSymbol
	rts




F_ALDot_Regulate:								; AL符号的闪烁和常显管理
	jsr		AlarmDot_Blink
	bbs1	Sys_Status_Flag,ALDot_Regulate_Exit
	jsr		AlarmDot_Const
ALDot_Regulate_Exit:
	rts




L_Dis_xxHr:
	ldx		#led_d3
	lda		#8
	jsr		L_Dis_7Bit_WordDot

	ldx		#led_d2
	lda		#7
	jsr		L_Dis_7Bit_WordDot

	bbr0	Clock_Flag,L_24hMode_Set
	ldx		#led_d1
	lda		#2
	jsr		L_Dis_7Bit_DigitDot
	ldx		#led_d0
	lda		#1
	jsr		L_Dis_7Bit_DigitDot
	rts
L_24hMode_Set:
	ldx		#led_d1
	lda		#4
	jsr		L_Dis_7Bit_DigitDot
	ldx		#led_d0
	lda		#2
	jsr		L_Dis_7Bit_DigitDot
	rts




L_Dis_Lxx:
	ldx		#led_d1
	lda		#5
	jsr		L_Dis_7Bit_WordDot

	lda		Light_Level
	clc
	adc		#1
	cmp		#4
	bcs		Dis_Auto_LightLevel
	ldx		#led_d3
	jsr		L_Dis_7Bit_DigitDot					; 显示当前亮度等级
	ldx		#led_d2
	lda		#0
	jsr		L_Dis_7Bit_DigitDot
	rts
Dis_Auto_LightLevel:
	ldx		#led_d3
	lda		#6
	jsr		L_Dis_7Bit_WordDot					; 显示自动亮度AU
	ldx		#led_d2
	lda		#4
	jsr		L_Dis_7Bit_WordDot
	rts




F_Display_Timekeep:
	lda		R_Timekeep_Sec
	and		#$0f
	ldx		#led_d3
	jsr		L_Dis_7Bit_DigitDot

	lda		R_Timekeep_Sec
	and		#$f0
	jsr		L_LSR_4Bit
	ldx		#led_d2
	jsr		L_Dis_7Bit_DigitDot

	lda		R_Timekeep_Min
	and		#$0f
	ldx		#led_d1
	jsr		L_Dis_7Bit_DigitDot

	lda		R_Timekeep_Min
	and		#$f0
	jsr		L_LSR_4Bit
	ldx		#led_d0
	jsr		L_Dis_7Bit_DigitDot

	jsr		F_DisCol
	rts




; 亮秒点
F_DisCol:
	ldx		#led_COL1
	jsr		F_DisSymbol
	ldx		#led_COL2
	jsr		F_DisSymbol
	rts

; 灭秒点
F_ClrCol:
	ldx		#led_COL1
	jsr		F_ClrSymbol
	ldx		#led_COL2
	jsr		F_ClrSymbol
	rts

; 亮PM点
F_DisPM:
	ldx		#led_PM
	jsr		F_DisSymbol
	rts

; 灭PM点
F_ClrPM:
	ldx		#led_PM
	jsr		F_ClrSymbol
	rts

; 亮AL1点
F_DisAL1:
	ldx		#led_AL1
	jsr		F_DisSymbol
	rts

; 灭AL1点
F_ClrAL1:
	ldx		#led_AL1
	jsr		F_ClrSymbol
	rts

; 亮AL2点
F_DisAL2:
	ldx		#led_AL2
	jsr		F_DisSymbol
	rts

; 灭AL2点
F_ClrAL2:
	ldx		#led_AL2
	jsr		F_ClrSymbol
	rts




L_LSR_4Bit:
	clc
	ror
	ror
	ror
	ror
	rts

L_ASL_4Bit:
	clc
	rol
	rol
	rol
	rol
	rts



; 将A的值进行BCD转换
; A==转换的数，X==百位
L_A_DecToHex:
	sta		P_Temp								; 将十进制输入保存到P_Temp
	ldx		#0
	lda		#0
	sta		P_Temp+1							; 十位清零
	sta		P_Temp+2							; 个位清零

L_DecToHex_Loop:
	lda		P_Temp
	cmp		#10
	bcc		L_DecToHex_End						; 如果小于10，则不用转换

	sec
	sbc		#10									; 减去10
	sta		P_Temp								; 更新十进制值
	inc		P_Temp+1							; 十位+1，累加十六进制的十位
	bra		L_DecToHex_Loop						; 重复循环

L_DecToHex_End:
	lda		P_Temp								; 最后剩余的值是个位
	sta		P_Temp+2							; 存入个位

Juge_3Positions:
	lda		P_Temp+1							; 将十位放入A寄存器组合
	cmp		#10
	bcc		No_3Positions						; 判断是否有百位
	sec
	sbc		#10
	sta		P_Temp+1
	inx
	bra		Juge_3Positions
No_3Positions:
	clc
	rol
	rol
	rol
	rol											; 左移4次，完成乘16
	clc
	adc		P_Temp+2							; 加上个位值

	rts
