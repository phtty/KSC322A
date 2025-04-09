; �л���������ʾ״̬
SwitchState_AlarmDis:
	lda		#5
	sta		Return_MaxTime						; ����ģʽ��5S����ʱ��
	smb3	Clock_Flag							; ��λ���س�ʼ״̬��־

	lda		Sys_Status_Flag
	cmp		#00010B
	beq		L_Change_Group_AD					; �жϵ�ǰ״̬�Ƿ��Ѿ���������ʾ
	lda		#00010B
	sta		Sys_Status_Flag						; ��ǰ״̬���������л�������
	lda		#0
	sta		Sys_Status_Ordinal					; ������ģʽ��ź�������
	sta		Alarm_Group
	rts
L_Change_Group_AD:
	inc		Alarm_Group							; ��ǰ״̬Ϊ���ԣ������������
	lda		Alarm_Group
	cmp		#2
	bcc		L_Group_Exit_AD
	lda		#0
	sta		Alarm_Group							; ���������1ʱ���ص�ʱ��ģʽ
L_Group_Exit_AD:
	REFLASH_DISPLAY								; ������������ˢ����ʾ
	REFLASH_HALF_SEC
	rts




; �л���ʱ������ģʽ
SwitchState_ClockSet:
	lda		#10
	sta		Return_MaxTime						; ����ģʽ��10S����ʱ��
	smb3	Clock_Flag							; ��λ���س�ʼ״̬��־

	lda		Sys_Status_Flag
	cmp		#0100B
	beq		L_Change_Ordinal_CS					; �жϵ�ǰ״̬�Ƿ��Ѿ���ʱ������
	lda		#0100B
	sta		Sys_Status_Flag						; ��ǰ״̬��ʱ�����л���ʱ��
	lda		#0
	sta		Sys_Status_Ordinal					; ������ģʽ���
	bra		L_Ordinal_Exit_CS
L_Change_Ordinal_CS:
	inc		Sys_Status_Ordinal					; ��ǰ״̬Ϊʱ�裬�������ģʽ���
	lda		Sys_Status_Ordinal
	cmp		#6
	bcc		L_Ordinal_Exit_CS
Return_CD_Mode:
	lda		#0
	sta		Sys_Status_Ordinal					; ��ģʽ��Ŵ���5ʱ����ص�ʱ��ģʽ����������
	lda		#0001B
	sta		Sys_Status_Flag
	rmb3	Clock_Flag							; ��λ���س�ʼ״̬��־
L_Ordinal_Exit_CS:
	REFLASH_DISPLAY								; ������������ˢ����ʾ
	REFLASH_HALF_SEC
	rts




; �л�����������ģʽ
SwitchState_AlarmSet:
	lda		#10
	sta		Return_MaxTime						; ����ģʽ��10S����ʱ��
	smb3	Clock_Flag							; ��λ���س�ʼ״̬��־

	lda		Sys_Status_Flag
	cmp		#1000B
	beq		L_Change_Ordinal_AS					; �жϵ�ǰ״̬�Ƿ��Ѿ�����������
	bbr1	Sys_Status_Flag,No_AlarmDis2Set
	lda		#1000B
	sta		Sys_Status_Flag						; ��ǰ״̬���������л�������
	lda		Sys_Status_Ordinal					; ����ǰ��������״̬
	clc
	rol
	clc
	adc		Sys_Status_Ordinal					; ��Ե�ǰ��ʾ����������
	sta		Sys_Status_Ordinal
	bra		L_Ordinal_Exit_AS
No_AlarmDis2Set:
	lda		#0
	sta		Sys_Status_Ordinal					; ������ģʽ���
	lda		#1000B
	sta		Sys_Status_Flag						; ��ǰ״̬���������л�������
	bra		L_Ordinal_Exit_AS
L_Change_Ordinal_AS:
	inc		Sys_Status_Ordinal					; ��ǰ״̬Ϊ���裬�������ģʽ���
	lda		Sys_Status_Ordinal
	cmp		#4
	bcc		L_Ordinal_Exit_AS
	lda		#0
	sta		Sys_Status_Ordinal					; ��ģʽ��Ŵ���3ʱ����ص�ʱ��ģʽ����������
	lda		#0001B
	sta		Sys_Status_Flag
L_Ordinal_Exit_AS:
	REFLASH_DISPLAY								; ������������ˢ����ʾ
	REFLASH_HALF_SEC
	rts




; �л�������ʱģʽ
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
	REFLASH_DISPLAY								; ������������ˢ����ʾ
	REFLASH_HALF_SEC
	rts


; �л�������ʱģʽ
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
	REFLASH_DISPLAY								; ������������ˢ����ʾ
	REFLASH_HALF_SEC
	rts




; �л������ƹ�����
; 0������1������2������3�Զ�����
LightLevel_Change:
	lda		#0
	sta		Counter_LL

	inc		Light_Level
	lda		Light_Level
	cmp		#4
	bcc		LightLevel_CHG_Exit
	lda		#0
	sta		Light_Level							; ���ȵȼ����
LightLevel_CHG_Exit:
	smb3	Backlight_Flag						; ��ʾ���ȵȼ�
	smb0	Timer_Flag							; ���̽���һ����ʾ
	rts




; ʱ�������µ�12��24hģʽ�л�
ClockSet_SW_TimeMode:
	lda		Clock_Flag
	eor		#%01								; ��ת12/24hģʽ��״̬
	sta		Clock_Flag

	jsr		L_Dis_xxHr
	REFLASH_DISPLAY								; ������������ˢ����ʾ
	REFLASH_HALF_SEC
	rts

; ��ʾģʽ��12��24hģʽ�л�
DM_SW_TimeMode:
	lda		Clock_Flag
	eor		#%01								; ��ת12/24hģʽ��״̬
	sta		Clock_Flag

	REFLASH_DISPLAY								; ������������ˢ����ʾ
	REFLASH_HALF_SEC
	rts




; �л��¶ȵ�λ
TemperMode_Change:
	lda		RFC_Flag							; ȡ����־λ���л����϶Ⱥ����϶�
	eor		#%01000
	sta		RFC_Flag
	jsr		F_Display_Temper					; �����¶ȵ�λ���¶�

	REFLASH_DISPLAY								; ������������ˢ����ʾ
	rts




; ʱ��ģʽ����
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




; ����ģʽ����
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
	jmp		L_AlarmHour_Add						; ����Сʱ����
No_AlarmHourSet_Add:
	cmp		#2
	bne		No_AlarmWorkdaySet_Add
	jmp		L_AlarmMin_Add						; ���ӷ��Ӽ���
No_AlarmWorkdaySet_Add:
	jmp		L_AlarmWorkDay_Add



; ʱ��ģʽ����
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




; ����ģʽ����
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
	jmp		L_AlarmHour_Sub						; ����Сʱ����
No_AlarmHourSet_Sub:
	cmp		#2
	bne		No_AlarmWorkdaySet_Sub
	jmp		L_AlarmMin_Sub						; ���ӷ��Ӽ���
No_AlarmWorkdaySet_Sub:
	jmp		L_AlarmWorkDay_Sub




; ʱ����
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
	REFLASH_DISPLAY								; ������������ˢ����ʾ
	rts

; ʱ����
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
	REFLASH_DISPLAY								; ������������ˢ����ʾ
	rts




; ������
L_TimeMin_Add:
	lda		#0
	sta		R_Time_Sec							; �������ӻ������

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
	REFLASH_DISPLAY								; ������������ˢ����ʾ
	rts

; �ּ���
L_TimeMin_Sub:
	lda		#0
	sta		R_Time_Sec							; �������ӻ������

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
	REFLASH_DISPLAY								; ������������ˢ����ʾ
	rts




; ������
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
	jsr		L_DayOverflow_Juge					; ����ǰ���ڳ�����ǰ�·���������ֵ�������ڱ�Ϊ��ǰ���������
	jsr		F_Is_Leap_Year
	jsr		L_DisDate_Year
	jsr		F_Display_Week
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; ������������ˢ����ʾ
	rts

; �����
L_DateYear_Sub:
	lda		R_Date_Year
	beq		DateYear_SubOverflow
	dec		R_Date_Year
	bra		DateYear_Sub_Exit
DateYear_SubOverflow:
	lda		#99
	sta		R_Date_Year
DateYear_Sub_Exit:
	jsr		L_DayOverflow_Juge					; ����ǰ���ڳ�����ǰ�·���������ֵ�������ڱ�Ϊ��ǰ���������
	jsr		F_Is_Leap_Year
	jsr		L_DisDate_Year
	jsr		F_Display_Week
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; ������������ˢ����ʾ
	rts




; ������
L_DateMonth_Add:
	lda		R_Date_Month
	cmp		#12
	bcs		DateMonth_AddOverflow
	inc		R_Date_Month
	jsr		L_DayOverflow_Juge					; ����ǰ���ڳ�����ǰ�·���������ֵ�������ڱ�Ϊ��ǰ���������
	bra		DateMonth_Add_Exit
DateMonth_AddOverflow:
	lda		#1
	sta		R_Date_Month
DateMonth_Add_Exit:
	jsr		F_Display_Date
	jsr		F_Display_Week
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; ������������ˢ����ʾ
	rts

; �¼���
L_DateMonth_Sub:
	lda		R_Date_Month
	cmp		#1
	beq		DateMonth_SubOverflow
	dec		R_Date_Month
	jsr		L_DayOverflow_Juge					; ����ǰ���ڳ�����ǰ�·���������ֵ�������ڱ�Ϊ��ǰ���������
	bra		DateMonth_Sub_Exit
DateMonth_SubOverflow:
	lda		#12
	sta		R_Date_Month
DateMonth_Sub_Exit:
	jsr		F_Display_Date
	jsr		F_Display_Week
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; ������������ˢ����ʾ
	rts




; ������
L_DateDay_Add:
	inc		R_Date_Day
	jsr		L_DayOverflow_To_1					; ����ǰ���ڳ�����ǰ�·���������ֵ�������ڱ�Ϊ1��
	jsr		F_Display_Date
	jsr		F_Display_Week
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; ������������ˢ����ʾ
	rts

; �ռ���
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
	REFLASH_DISPLAY								; ������������ˢ����ʾ
	rts





; ���ӿ���
; A�����飨��bit��
L_Alarm_Switch:
	eor		Alarm_Switch
	sta		Alarm_Switch
	;smb1	Timer_Flag
	;rmb0	Timer_Flag
	;jsr		F_Alarm_SwitchStatue				; ˢ��һ�����ӿ�����ʾ
	REFLASH_HALF_SEC
	REFLASH_DISPLAY								; ������������ˢ����ʾ
	rts


; ���ӷ�����
; X�����飬0~1
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
	REFLASH_DISPLAY								; ������������ˢ����ʾ
	rts

; ���ӷּ���
; X�����飬0~1
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
	REFLASH_DISPLAY								; ������������ˢ����ʾ
	rts


; ����ʱ����
; X�����飬0~1
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
	REFLASH_DISPLAY								; ������������ˢ����ʾ
	rts

; ����ʱ����
; X�����飬0~1
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
	REFLASH_DISPLAY								; ������������ˢ����ʾ
	rts


; ���ӹ���������
; X�����飬0~1
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
	REFLASH_DISPLAY								; ������������ˢ����ʾ
	rts

; ���ӹ����ռ���
; X�����飬0~1
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
	REFLASH_DISPLAY								; ������������ˢ����ʾ
	rts




; ����ʱģʽ���ü�ʱʱ��
Timekeep_NumSet:
	lda		Timekeep_NumberSet
	cmp		#2
	bne		?Juge_Over							; �ж��Ƿ���������ʮλ
	lda		P_Temp
	cmp		#6
	bcc		?Juge_Over							; �ж���ʮλ�Ƿ񳬹�5
	lda		#4									; ���ô�����ʾ������������
	sta		Beep_Serial
	rmb4	Key_Flag							; ���Ϸ�����ֵ����ʹ�ð�����ʾ��
	smb6	Key_Flag							; ʹ�ô�����ʾ��
	rts
?Juge_Over:
	lda		Timekeep_NumberSet
	clc
	ror											; ͨ��Timekeep_NumberSet�ĵ�һλ�ж�������ʮλ���Ǹ�λ
	bcs		SetSingle_Number
	tax											; ���÷�/���ʮλ��
	lda		P_Temp
	jsr		L_ASL_4Bit
	sta		P_Temp								; ���õ��������Ƶ�ʮλ

	lda		TimekeepAddr,x
	and		#$0f
	ora		P_Temp
	sta		TimekeepAddr,x
	bra		NumSet_Inc
SetSingle_Number:								; ���÷�/��ĸ�λ��
	tax
	lda		TimekeepAddr,x
	and		#$f0
	ora		P_Temp
	sta		TimekeepAddr,x
NumSet_Inc:
	inc		Timekeep_NumberSet					; ÿ������������Timekeep_NumberSet
	lda		Timekeep_NumberSet
	cmp		#4
	bcc		NumSet_Exit
	lda		#0
	sta		Timekeep_NumberSet					; �����ص�0
NumSet_Exit:
	REFLASH_DISPLAY								; �޸���ɺ�ˢ����ʾ
	rts




; ��ʱģʽ����ͣ��ʱ
Timekeep_Pause_Continue:
	lda		Timekeep_Flag
	eor		#%01
	sta		Timekeep_Flag

	bbr0	Sys_Status_Ordinal,TimeDown_BakOver
	bbs0	Timekeep_Flag,TimeDown_BakOver
	lda		R_Timekeep_Min						; ����ʱģʽ������ʱ��ʼ���ᱸ��һ�γ�ֵ���ȴ���ʱ��ɻ�ԭ
	sta		R_TimekeepBak_Min
	lda		R_Timekeep_Sec
	sta		R_TimekeepBak_Sec
TimeDown_BakOver:
	rts


; ��ʱģʽ����ռ�ʱ
Timekeep_ClearCount:
	lda		#0
	sta		R_Timekeep_Min
	sta		R_Timekeep_Sec
	sta		R_TimekeepBak_Min
	sta		R_TimekeepBak_Sec
	rts




; ����������жϣ������ӣ�
L_DayOverflow_Juge:
	jsr		F_Is_Leap_Year
	bbs0	Calendar_Flag,L_LeapYear_Handle		; ƽ������ı�ֿ���
	ldx		R_Date_Month						; ��ƽ��ÿ�·�������
	dex
	lda		L_Table_Month_Common,x
	sta		P_Temp
	bra		Day_Overflow_Juge
L_LeapYear_Handle:
	ldx		R_Date_Month						; ������ÿ�·�������
	dex
	lda		L_Table_Month_Leap,x
	sta		P_Temp
Day_Overflow_Juge:
	lda		P_Temp								; ��ǰ���ں�����������ڶԱ�
	cmp		R_Date_Day
	bcs		DateDay_NoOverflow
	lda		P_Temp
	sta		R_Date_Day
DateDay_NoOverflow:
	REFLASH_DISPLAY								; ������������ˢ����ʾ
	rts

; ����������жϣ��ص�1�գ�
L_DayOverflow_To_1:
	jsr		F_Is_Leap_Year
	bbs0	Calendar_Flag,L_LeapYear_Handle2	; ƽ������ı�ֿ���
	ldx		R_Date_Month						; ��ƽ��ÿ�·�������
	dex
	lda		L_Table_Month_Common,x
	sta		P_Temp
	bra		Day_Overflow_Juge2
L_LeapYear_Handle2:
	ldx		R_Date_Month						; ������ÿ�·�������
	dex
	lda		L_Table_Month_Leap,x
	sta		P_Temp
Day_Overflow_Juge2:
	lda		P_Temp								; ��ǰ���ں�����������ڶԱ�
	cmp		R_Date_Day
	bcs		DateDay_NoOverflow2
	lda		#1
	sta		R_Date_Day
DateDay_NoOverflow2:
	REFLASH_DISPLAY								; ������������ˢ����ʾ
	rts
