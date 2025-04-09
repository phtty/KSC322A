; 切换到闹钟显示状态
SwitchState_AlarmDis:
	lda		#5
	sta		Return_MaxTime						; 设置模式，5S返回时显
	smb3	Clock_Flag							; 置位返回初始状态标志

	lda		Sys_Status_Flag
	cmp		#00010B
	beq		L_Change_Group_AD					; 判断当前状态是否已经是闹钟显示
	lda		#00010B
	sta		Sys_Status_Flag						; 当前状态非闹显则切换至闹显
	lda		#0
	sta		Sys_Status_Ordinal					; 清零子模式序号和闹钟组
	sta		Alarm_Group
	rts
L_Change_Group_AD:
	inc		Alarm_Group							; 当前状态为闹显，则递增闹钟组
	lda		Alarm_Group
	cmp		#2
	bcc		L_Group_Exit_AD
	lda		#0
	sta		Alarm_Group							; 闹钟组大于1时，回到时显模式
L_Group_Exit_AD:
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	REFLASH_HALF_SEC
	rts




; 切换到时钟设置模式
SwitchState_ClockSet:
	lda		#10
	sta		Return_MaxTime						; 设置模式，10S返回时显
	smb3	Clock_Flag							; 置位返回初始状态标志

	lda		Sys_Status_Flag
	cmp		#0100B
	beq		L_Change_Ordinal_CS					; 判断当前状态是否已经是时钟设置
	lda		#0100B
	sta		Sys_Status_Flag						; 当前状态非时设则切换至时设
	lda		#0
	sta		Sys_Status_Ordinal					; 清零子模式序号
	bra		L_Ordinal_Exit_CS
L_Change_Ordinal_CS:
	inc		Sys_Status_Ordinal					; 当前状态为时设，则递增子模式序号
	lda		Sys_Status_Ordinal
	cmp		#6
	bcc		L_Ordinal_Exit_CS
Return_CD_Mode:
	lda		#0
	sta		Sys_Status_Ordinal					; 子模式序号大于5时，则回到时显模式，并清空序号
	lda		#0001B
	sta		Sys_Status_Flag
	rmb3	Clock_Flag							; 复位返回初始状态标志
L_Ordinal_Exit_CS:
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	REFLASH_HALF_SEC
	rts




; 切换到闹钟设置模式
SwitchState_AlarmSet:
	lda		#10
	sta		Return_MaxTime						; 设置模式，10S返回时显
	smb3	Clock_Flag							; 置位返回初始状态标志

	lda		Sys_Status_Flag
	cmp		#1000B
	beq		L_Change_Ordinal_AS					; 判断当前状态是否已经是闹钟设置
	bbr1	Sys_Status_Flag,No_AlarmDis2Set
	lda		#1000B
	sta		Sys_Status_Flag						; 当前状态非闹设则切换至闹设
	lda		Sys_Status_Ordinal					; 若当前处于闹显状态
	clc
	rol
	clc
	adc		Sys_Status_Ordinal					; 则对当前显示的闹组设置
	sta		Sys_Status_Ordinal
	bra		L_Ordinal_Exit_AS
No_AlarmDis2Set:
	lda		#0
	sta		Sys_Status_Ordinal					; 清零子模式序号
	lda		#1000B
	sta		Sys_Status_Flag						; 当前状态非闹设则切换至闹设
	bra		L_Ordinal_Exit_AS
L_Change_Ordinal_AS:
	inc		Sys_Status_Ordinal					; 当前状态为闹设，则递增子模式序号
	lda		Sys_Status_Ordinal
	cmp		#4
	bcc		L_Ordinal_Exit_AS
	lda		#0
	sta		Sys_Status_Ordinal					; 子模式序号大于3时，则回到时显模式，并清空序号
	lda		#0001B
	sta		Sys_Status_Flag
L_Ordinal_Exit_AS:
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	REFLASH_HALF_SEC
	rts




; 切换到正计时模式
SwitchState_TimeUpMode:
	lda		#%10000
	sta		Sys_Status_Flag
	lda		#$0
	sta		Sys_Status_Ordinal
	sta		Timekeep_Flag
	sta		R_Timekeep_Min
	sta		R_Timekeep_Sec
	sta		R_TimekeepBak_Min
	sta		R_TimekeepBak_Sec
	sta		Timekeep_NumberSet
	jsr		F_ClearScreen
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	REFLASH_HALF_SEC
	rts


; 切换到倒计时模式
SwitchState_TimeDownMode:
	lda		#%10000
	sta		Sys_Status_Flag
	lda		#1
	sta		Sys_Status_Ordinal
	lda		#0
	sta		Timekeep_Flag
	sta		R_Timekeep_Min
	sta		R_Timekeep_Sec
	sta		R_TimekeepBak_Min
	sta		R_TimekeepBak_Sec
	sta		Timekeep_NumberSet
	jsr		F_ClearScreen
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	REFLASH_HALF_SEC
	rts




; 切换三档灯光亮度
; 0低亮，1半亮，2高亮，3自动亮度
LightLevel_Change:
	lda		#0
	sta		Counter_LL

	inc		Light_Level
	lda		Light_Level
	cmp		#4
	bcc		LightLevel_CHG_Exit
	lda		#0
	sta		Light_Level							; 亮度等级溢出
LightLevel_CHG_Exit:
	smb3	Backlight_Flag						; 显示亮度等级
	smb0	Timer_Flag							; 立刻进行一次显示
	rts




; 时钟设置下的12、24h模式切换
ClockSet_SW_TimeMode:
	lda		Clock_Flag
	eor		#%01								; 翻转12/24h模式的状态
	sta		Clock_Flag

	jsr		L_Dis_xxHr
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	REFLASH_HALF_SEC
	rts

; 显示模式下12、24h模式切换
DM_SW_TimeMode:
	lda		Clock_Flag
	eor		#%01								; 翻转12/24h模式的状态
	sta		Clock_Flag

	REFLASH_DISPLAY								; 按键操作结束刷新显示
	REFLASH_HALF_SEC
	rts




; 切换温度单位
TemperMode_Change:
	lda		RFC_Flag							; 取反标志位，切换华氏度和摄氏度
	eor		#%01000
	sta		RFC_Flag
	jsr		F_Display_Temper					; 更新温度单位和温度

	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts




; 时设模式增数
AddNum_CS:
	lda		Sys_Status_Ordinal
	bne		No_CS_TMSwitch
	jmp		ClockSet_SW_TimeMode
No_CS_TMSwitch:
	cmp		#1
	bne		No_CS_HourAdd
	jmp		L_TimeHour_Add
No_CS_HourAdd:
	cmp		#2
	bne		No_CS_MinAdd
	jmp		L_TimeMin_Add
No_CS_MinAdd:
	cmp		#3
	bne		No_CS_YearAdd
	jmp		L_DateYear_Add
No_CS_YearAdd:
	cmp		#4
	bne		No_CS_MonthAdd
	jmp		L_DateMonth_Add
No_CS_MonthAdd:
	jmp		L_DateDay_Add




; 闹设模式增数
AddNum_AS:
	ldx		Alarm_Group
	lda		Sys_Status_Ordinal
	bne		No_AlarmSwitch_AddCHG
	lda		#1
	jsr		L_A_LeftShift_XBit
	jmp		L_Alarm_Switch
No_AlarmSwitch_AddCHG:
	cmp		#1
	bne		No_AlarmHourSet_Add
	jmp		L_AlarmHour_Add						; 闹钟小时减数
No_AlarmHourSet_Add:
	cmp		#2
	bne		No_AlarmWorkdaySet_Add
	jmp		L_AlarmMin_Add						; 闹钟分钟减数
No_AlarmWorkdaySet_Add:
	jmp		L_AlarmWorkDay_Add



; 时设模式减数
SubNum_CS:
	lda		Sys_Status_Ordinal
	bne		No_CS_TMSwitch2
	jmp		ClockSet_SW_TimeMode
No_CS_TMSwitch2:
	cmp		#1
	bne		No_CS_HourSub
	jmp		L_TimeHour_Sub
No_CS_HourSub:
	cmp		#2
	bne		No_CS_MinSub
	jmp		L_TimeMin_Sub
No_CS_MinSub:
	cmp		#3
	bne		No_CS_YearSub
	jmp		L_DateYear_Sub
No_CS_YearSub:
	cmp		#4
	bne		No_CS_MonthSub
	jmp		L_DateMonth_Sub
No_CS_MonthSub:
	jmp		L_DateDay_Sub




; 闹设模式减数
SubNum_AS:
	ldx		Alarm_Group
	lda		Sys_Status_Ordinal
	cmp		#0
	bne		No_AlarmSwitch_SubCHG
	lda		#1
	jsr		L_A_LeftShift_XBit
	jmp		L_Alarm_Switch
No_AlarmSwitch_SubCHG:
	cmp		#1
	bne		No_AlarmHourSet_Sub
	jmp		L_AlarmHour_Sub						; 闹钟小时减数
No_AlarmHourSet_Sub:
	cmp		#2
	bne		No_AlarmWorkdaySet_Sub
	jmp		L_AlarmMin_Sub						; 闹钟分钟减数
No_AlarmWorkdaySet_Sub:
	jmp		L_AlarmWorkDay_Sub




; 时增加
L_TimeHour_Add:
	lda		R_Time_Hour
	cmp		#23
	bcs		TimeHour_AddOverflow
	inc		R_Time_Hour
	bra		TimeHour_Add_Exit
TimeHour_AddOverflow:
	lda		#0
	sta		R_Time_Hour
TimeHour_Add_Exit:
	;jsr		L_LightLevel_WithKeyU
	jsr		F_Display_Time
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts

; 时减少
L_TimeHour_Sub:
	lda		R_Time_Hour
	beq		TimeHour_SubOverflow
	dec		R_Time_Hour
	bra		TimeHour_Sub_Exit
TimeHour_SubOverflow:
	lda		#23
	sta		R_Time_Hour
TimeHour_Sub_Exit:
	;jsr		L_LightLevel_WithKeyD
	jsr		F_Display_Time
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts




; 分增加
L_TimeMin_Add:
	lda		#0
	sta		R_Time_Sec							; 调整分钟会清空秒

	lda		R_Time_Min
	cmp		#59
	bcs		TimeMin_AddOverflow
	inc		R_Time_Min
	bra		TimeMin_Add_Exit
TimeMin_AddOverflow:
	lda		#0
	sta		R_Time_Min
TimeMin_Add_Exit:
	jsr		F_Display_Time
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts

; 分减少
L_TimeMin_Sub:
	lda		#0
	sta		R_Time_Sec							; 调整分钟会清空秒

	lda		R_Time_Min
	beq		TimeMin_SubOverflow
	dec		R_Time_Min
	bra		TimeMin_Sub_Exit
TimeMin_SubOverflow:
	lda		#59
	sta		R_Time_Min
TimeMin_Sub_Exit:
	jsr		F_Display_Time
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts




; 年增加
L_DateYear_Add:
	lda		R_Date_Year
	cmp		#99
	bcs		DateYear_AddOverflow
	inc		R_Date_Year
	bra		DateYear_Add_Exit
DateYear_AddOverflow:
	lda		#0
	sta		R_Date_Year
DateYear_Add_Exit:
	jsr		L_DayOverflow_Juge					; 若当前日期超过当前月份允许的最大值，则日期变为当前允许最大日
	jsr		F_Is_Leap_Year
	jsr		L_DisDate_Year
	jsr		F_Display_Week
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts

; 年减少
L_DateYear_Sub:
	lda		R_Date_Year
	beq		DateYear_SubOverflow
	dec		R_Date_Year
	bra		DateYear_Sub_Exit
DateYear_SubOverflow:
	lda		#99
	sta		R_Date_Year
DateYear_Sub_Exit:
	jsr		L_DayOverflow_Juge					; 若当前日期超过当前月份允许的最大值，则日期变为当前允许最大日
	jsr		F_Is_Leap_Year
	jsr		L_DisDate_Year
	jsr		F_Display_Week
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts




; 月增加
L_DateMonth_Add:
	lda		R_Date_Month
	cmp		#12
	bcs		DateMonth_AddOverflow
	inc		R_Date_Month
	jsr		L_DayOverflow_Juge					; 若当前日期超过当前月份允许的最大值，则日期变为当前允许最大日
	bra		DateMonth_Add_Exit
DateMonth_AddOverflow:
	lda		#1
	sta		R_Date_Month
DateMonth_Add_Exit:
	jsr		F_Display_Date
	jsr		F_Display_Week
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts

; 月减少
L_DateMonth_Sub:
	lda		R_Date_Month
	cmp		#1
	beq		DateMonth_SubOverflow
	dec		R_Date_Month
	jsr		L_DayOverflow_Juge					; 若当前日期超过当前月份允许的最大值，则日期变为当前允许最大日
	bra		DateMonth_Sub_Exit
DateMonth_SubOverflow:
	lda		#12
	sta		R_Date_Month
DateMonth_Sub_Exit:
	jsr		F_Display_Date
	jsr		F_Display_Week
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts




; 日增加
L_DateDay_Add:
	inc		R_Date_Day
	jsr		L_DayOverflow_To_1					; 若当前日期超过当前月份允许的最大值，则日期变为1日
	jsr		F_Display_Date
	jsr		F_Display_Week
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts

; 日减少
L_DateDay_Sub:
	lda		R_Date_Day
	cmp		#1
	beq		DateDay_SubOverflow
	dec		R_Date_Day
	bra		DateDay_Sub_Exit
DateDay_SubOverflow:
	bbr0	Calendar_Flag,Common_Year_Get
	ldx		R_Date_Month
	dex
	lda		L_Table_Month_Leap,x
	sta		R_Date_Day
	bra		DateDay_Sub_Exit
Common_Year_Get:
	ldx		R_Date_Month
	dex
	lda		L_Table_Month_Common,x
	sta		R_Date_Day
DateDay_Sub_Exit:
	jsr		F_Display_Date
	jsr		F_Display_Week
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts





; 闹钟开关
; A闹钟组（按bit）
L_Alarm_Switch:
	eor		Alarm_Switch
	sta		Alarm_Switch
	;smb1	Timer_Flag
	;rmb0	Timer_Flag
	;jsr		F_Alarm_SwitchStatue				; 刷新一次闹钟开关显示
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts


; 闹钟分增加
; X闹钟组，0~1
L_AlarmMin_Add:
	lda		Alarm_MinAddr,x
	cmp		#59
	bcs		AlarmMin_AddOverflow
	clc
	adc		#1
	sta		Alarm_MinAddr,x
	bra		AlarmMin_Add_Exit
AlarmMin_AddOverflow:
	lda		#0
	sta		Alarm_MinAddr,x
AlarmMin_Add_Exit:
	;smb1	Timer_Flag
	;rmb0	Timer_Flag
	;jsr		F_AlarmMin_Set
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts

; 闹钟分减少
; X闹钟组，0~1
L_AlarmMin_Sub:
	lda		Alarm_MinAddr,x
	beq		AlarmMin_SubOverflow
	sec
	sbc		#1
	sta		Alarm_MinAddr,x
	bra		AlarmMin_Sub_Exit
AlarmMin_SubOverflow:
	lda		#59
	sta		Alarm_MinAddr,x
AlarmMin_Sub_Exit:
	;smb1	Timer_Flag
	;rmb0	Timer_Flag
	;jsr		F_AlarmMin_Set
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts


; 闹钟时增加
; X闹钟组，0~1
L_AlarmHour_Add:
	lda		Alarm_HourAddr,x
	cmp		#23
	bcs		AlarmHour_AddOverflow
	clc
	adc		#1
	sta		Alarm_HourAddr,x
	bra		AlarmHour_Add_Exit
AlarmHour_AddOverflow:
	lda		#0
	sta		Alarm_HourAddr,x
AlarmHour_Add_Exit:
	;smb1	Timer_Flag
	;rmb0	Timer_Flag
	;jsr		F_AlarmHour_Set
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts

; 闹钟时减少
; X闹钟组，0~1
L_AlarmHour_Sub:
	lda		Alarm_HourAddr,x
	beq		AlarmHour_SubOverflow
	sec
	sbc		#1
	sta		Alarm_HourAddr,x
	bra		AlarmHour_Sub_Exit
AlarmHour_SubOverflow:
	lda		#23
	sta		Alarm_HourAddr,x
AlarmHour_Sub_Exit:
	;smb1	Timer_Flag
	;rmb0	Timer_Flag
	;jsr		F_AlarmHour_Set
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts


; 闹钟工作日增加
; X闹钟组，0~1
L_AlarmWorkDay_Add:
	lda		Alarm_WorkDayAddr,x
	cmp		#2
	bcs		AlarmWorkDay_AddOverflow
	clc
	adc		#1
	sta		Alarm_WorkDayAddr,x
	bra		AlarmWorkDay_Add_Exit
AlarmWorkDay_AddOverflow:
	lda		#0
	sta		Alarm_WorkDayAddr,x
AlarmWorkDay_Add_Exit:
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts

; 闹钟工作日减少
; X闹钟组，0~1
L_AlarmWorkDay_Sub:
	lda		Alarm_WorkDayAddr,x
	beq		AlarmWorkDay_SubOverflow
	sec
	sbc		#1
	sta		Alarm_WorkDayAddr,x
	bra		AlarmWorkDay_Sub_Exit
AlarmWorkDay_SubOverflow:
	lda		#2
	sta		Alarm_WorkDayAddr,x
AlarmWorkDay_Sub_Exit:
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts




; 倒计时模式设置计时时间
Timekeep_NumSet:
	lda		Timekeep_NumberSet
	cmp		#2
	bne		?Juge_Over							; 判断是否是设置秒十位
	lda		P_Temp
	cmp		#6
	bcc		?Juge_Over							; 判断秒十位是否超过5
	lda		#4									; 设置错误提示音的响铃序列
	sta		Beep_Serial
	rmb4	Key_Flag							; 不合法的数值不再使用按键提示音
	smb6	Key_Flag							; 使用错误提示音
	rts
?Juge_Over:
	lda		Timekeep_NumberSet
	clc
	ror											; 通过Timekeep_NumberSet的第一位判断是设置十位还是个位
	bcs		SetSingle_Number
	tax											; 设置分/秒的十位数
	lda		P_Temp
	jsr		L_ASL_4Bit
	sta		P_Temp								; 设置的数字左移到十位

	lda		TimekeepAddr,x
	and		#$0f
	ora		P_Temp
	sta		TimekeepAddr,x
	bra		NumSet_Inc
SetSingle_Number:								; 设置分/秒的个位数
	tax
	lda		TimekeepAddr,x
	and		#$f0
	ora		P_Temp
	sta		TimekeepAddr,x
NumSet_Inc:
	inc		Timekeep_NumberSet					; 每次设置完后递增Timekeep_NumberSet
	lda		Timekeep_NumberSet
	cmp		#4
	bcc		NumSet_Exit
	lda		#0
	sta		Timekeep_NumberSet					; 溢出后回到0
NumSet_Exit:
	REFLASH_DISPLAY								; 修改完成后刷新显示
	rts




; 计时模式下启停计时
Timekeep_Pause_Continue:
	lda		Timekeep_Flag
	eor		#%01
	sta		Timekeep_Flag

	bbr0	Sys_Status_Ordinal,TimeDown_BakOver
	bbs0	Timekeep_Flag,TimeDown_BakOver
	lda		R_Timekeep_Min						; 倒计时模式下若计时开始，会备份一次初值，等待计时完成还原
	sta		R_TimekeepBak_Min
	lda		R_Timekeep_Sec
	sta		R_TimekeepBak_Sec
TimeDown_BakOver:
	rts


; 计时模式下清空计时
Timekeep_ClearCount:
	lda		#0
	sta		R_Timekeep_Min
	sta		R_Timekeep_Sec
	sta		R_TimekeepBak_Min
	sta		R_TimekeepBak_Sec
	rts




; 天数上溢的判断（不增加）
L_DayOverflow_Juge:
	jsr		F_Is_Leap_Year
	bbs0	Calendar_Flag,L_LeapYear_Handle		; 平年闰年的表分开查
	ldx		R_Date_Month						; 查平年每月份天数表
	dex
	lda		L_Table_Month_Common,x
	sta		P_Temp
	bra		Day_Overflow_Juge
L_LeapYear_Handle:
	ldx		R_Date_Month						; 查闰年每月份天数表
	dex
	lda		L_Table_Month_Leap,x
	sta		P_Temp
Day_Overflow_Juge:
	lda		P_Temp								; 当前日期和天数表的日期对比
	cmp		R_Date_Day
	bcs		DateDay_NoOverflow
	lda		P_Temp
	sta		R_Date_Day
DateDay_NoOverflow:
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts

; 天数上溢的判断（回到1日）
L_DayOverflow_To_1:
	jsr		F_Is_Leap_Year
	bbs0	Calendar_Flag,L_LeapYear_Handle2	; 平年闰年的表分开查
	ldx		R_Date_Month						; 查平年每月份天数表
	dex
	lda		L_Table_Month_Common,x
	sta		P_Temp
	bra		Day_Overflow_Juge2
L_LeapYear_Handle2:
	ldx		R_Date_Month						; 查闰年每月份天数表
	dex
	lda		L_Table_Month_Leap,x
	sta		P_Temp
Day_Overflow_Juge2:
	lda		P_Temp								; 当前日期和天数表的日期对比
	cmp		R_Date_Day
	bcs		DateDay_NoOverflow2
	lda		#1
	sta		R_Date_Day
DateDay_NoOverflow2:
	REFLASH_DISPLAY								; 按键操作结束刷新显示
	rts
