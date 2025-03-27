F_Alarm_GroupDis:
	jsr		L_AlarmDot_Blink

	lda		Sys_Status_Ordinal
	clc
	rol
	tax
	lda		AlarmGroupHandle_Table+1,x
	pha
	lda		AlarmGroupHandle_Table,x
	pha
	rts											; ���ݵ�ǰ��ģʽ����ת����Ӧ����ʾ����

AlarmGroupHandle_Table:
	dw		F_Display_Alarm-1
	dw		F_Alarm_SwitchStatue-1
	dw		F_AlarmHour_Set-1
	dw		F_AlarmMin_Set-1
	dw		F_AlarmWorkDay_Set-1



L_AlarmDot_Blink:
	lda		Alarm_Group
	eor		#1
	sta		P_Temp
	tax											; ȡ�ǵ�ǰ����
	lda		#1
	jsr		L_A_LeftShift_XBit					; ��1������Ӧλ�������ǰ�����ӿ��ص�λ��
	and		Alarm_Switch						; �����ӿ���״̬����ó���λ���ǿ����ǹ�
	clc
	rol
	clc
	adc		P_Temp								; �ǵ�ǰ������Ϸǵ�ǰ����״̬*2��ΪҪ��ת�ĺ���
	jsr		L_Control_ALDot

	bbs1	Symbol_Flag,L_AlarmDot_Out
	rts
L_AlarmDot_Out:									; ��˸��ǰ����
	rmb1	Symbol_Flag
	bbs0	Symbol_Flag,No_ALDot_Display
	lda		Alarm_Group
	clc
	adc		#2
	jmp		L_Control_ALDot						; ��ǰ��AL�������
No_ALDot_Display:
	rmb0	Symbol_Flag
	lda		Alarm_Group
	jmp		L_Control_ALDot						; ��ǰ��AL��1����




; ���ӿ�����ʾ
F_Alarm_SwitchStatue:
	bbs1	Timer_Flag,?AlarmSW_BlinkStart
	rts
?AlarmSW_BlinkStart:
	rmb1	Timer_Flag
	bbs0	Timer_Flag,AlarmSW_UnDisplay
	ldx		Alarm_Group
	lda		#1
	jsr		L_A_LeftShift_XBit					; ��1������Ӧλ�������ǰ�����ӿ��ص�λ��
	and		Alarm_Switch						; �����ӿ���״̬����ó���λ���ǿ����ǹ�

	beq		ALSwitch_DisOff
	lda		#2
	ldx		#led_d0
	jsr		L_Dis_7Bit_WordDot					; ��ʾON

	lda		#3
	ldx		#led_d1
	jsr		L_Dis_7Bit_WordDot
	bra		ALSwitch_DisNum

ALSwitch_DisOff:
	lda		#9
	ldx		#led_d0
	jsr		L_Dis_7Bit_WordDot					; ��ʾ--

	lda		#9
	ldx		#led_d1
	jsr		L_Dis_7Bit_WordDot
	bra		ALSwitch_DisNum

AlarmSW_UnDisplay:
	rmb0	Timer_Flag
	jmp		F_UnDisplay_D0_1
	jmp		F_UnDisplay_D2_3

ALSwitch_DisNum:								; ��ʾ�������
	lda		#4
	ldx		#led_d2
	jsr		L_Dis_7Bit_WordDot

	lda		Alarm_Group							; +1Ϊʵ���������
	clc
	adc		#1
	ldx		#led_d3
	jsr		L_Dis_7Bit_DigitDot
	rts




F_AlarmHour_Set:
	bbs1	Timer_Flag,L_AlarmHour_Set
	rts
L_AlarmHour_Set:
	rmb1	Timer_Flag

	jsr		F_DisCol

	bbs2	Key_Flag,L_AlarmHour_Display		; �п��ʱ����
	bbs0	Timer_Flag,L_AlarmHour_Clear
L_AlarmHour_Display:
	jmp		F_Display_Alarm
L_AlarmHour_Clear:
	rmb0	Timer_Flag							; ��1S��־
	jmp		F_UnDisplay_D0_1




F_AlarmMin_Set:
	bbs1	Timer_Flag,L_AlarmMin_Set
	rts
L_AlarmMin_Set:
	rmb1	Timer_Flag

	jsr		F_DisCol

	bbs2	Key_Flag,L_AlarmMin_Display			; �п��ʱֱ�ӳ���
	bbs0	Timer_Flag,L_AlarmMin_Clear
L_AlarmMin_Display:
	jmp		F_Display_Alarm
L_AlarmMin_Clear:
	rmb0	Timer_Flag							; ��1S��־
	jmp		F_UnDisplay_D2_3




F_AlarmWorkDay_Set:
	bbs1	Timer_Flag,L_AlarmWorkDay_Set
	rts
L_AlarmWorkDay_Set:
	rmb1	Timer_Flag

	jsr		F_DisCol

	bbs0	Timer_Flag,L_AlarmWorkDay_Clear
	ldx		#led_d1
	lda		#1
	jsr		L_Dis_7Bit_DigitDot					; �̶���ʾ1-
	ldx		#led_d2
	lda		#10
	jsr		L_Dis_7Bit_DigitDot
	ldx		#led_d2+6
	jsr		F_DisSymbol

	ldx		Alarm_Group
	lda		Alarm_WorkDayAddr,x					; ��ʾ��Ӧ����Ĺ�����
	ldx		#led_d3
	jsr		L_Dis_7Bit_DigitDot
	rts
L_AlarmWorkDay_Clear:
	rmb0	Timer_Flag							; ��1S��־
	jsr		F_UnDisplay_D0_1
	jmp		F_UnDisplay_D2_3




F_Alarm_Handler:
	jsr		L_IS_AlarmTrigger					; �ж������Ƿ񴥷�
	bbr2	Clock_Flag,L_No_Alarm_Process		; �����ֱ�־λ�ٽ�����
	jsr		L_Alarm_Process
	rts
L_No_Alarm_Process:
	bbs4	Key_Flag,L_LoudingNoClose			; ����а�����ʾ�����򲻹رշ�����
	rmb1	PADF0								; PB3 PWM�������
	rmb4	PADF0								; PB3����ΪIO��
	rmb3	PB_TYPE								; PB3ѡ��NMOS���1����©��
	smb3	PB

	rmb3	Timer_Flag
	rmb1	Time_Flag
L_LoudingNoClose:
	lda		#0
	sta		AlarmLoud_Counter
	rts

L_IS_AlarmTrigger:
	lda		Alarm_Switch
	bne		Alarm_Juge_Start					; û���κ����ӿ����򲻻�����ж�
	rmb1	Clock_Flag
	rts
Alarm_Juge_Start:
	bbs2	Clock_Flag,L_Alarm_NoStop			; ���ʱ�������֣���ֱ�ӽ������ֳ�������
	jsr		Is_Alarm_Trigger					; �ж��������Ӵ���
	bbr1	Clock_Flag,Is_Snooze				; �����Ӵ�����־λ�Ż�����жϣ������ж�̰˯
L_Start_Loud_Juge:
	lda		R_Alarm_Hour						; ��������ʱ��ͬ������������������̰˯����
	sta		R_Snooze_Hour						; ֮��̰˯����ʱֻ��Ҫ��̰˯���ӵĻ����ϼ�5min
	lda		R_Alarm_Min
	sta		R_Snooze_Min
	bra		L_AlarmTrigger
Is_Snooze:
	bbs3	Clock_Flag,L_Snooze					; ���ж������Ƿ񴥷������ж��Ƿ����̰˯
	rts											; ��������Ӵ���������̰˯������Ҫ���Ӵ���ֱ���˳�
L_Snooze:
	lda		R_Time_Hour							; ̰˯ģʽ��,��̰˯���Ӻ͵�ǰʱ��ƥ��
	cmp		R_Snooze_Hour						; ̰˯���Ӻ͵�ǰʱ�䲻ƥ�䲻�������ģʽ
	bne		L_Snooze_CloseLoud
	lda		R_Time_Min
	cmp		R_Snooze_Min
	bne		L_Snooze_CloseLoud
	bbs2	Clock_Flag,L_Alarm_NoStop
	lda		R_Time_Sec
	cmp		#00
	bne		L_Snooze_CloseLoud
L_AlarmTrigger:
	jsr		F_RFC_Abort							; ��ֹRFC���������ö�ʱ��Ϊ����ģʽ
	smb1	Time_Flag
	smb0	TMRC								; ���嶨ʱ��TIM0����
	smb2	Clock_Flag							; ��������ģʽ
	rmb1 	Clock_Flag							; �ر����Ӵ�����־�������ظ������Ӵ���
L_Alarm_NoStop:
	bbs5	Clock_Flag,L_AlarmTrigger_Exit
	smb5	Clock_Flag							; ��������ģʽ��ֵ,�������ֽ���״̬��δ����״̬
L_AlarmTrigger_Exit:
	rts
L_Snooze_CloseLoud:
	bbr5	Clock_Flag,L_AlarmTrigger_Exit		; last==1 && now==0
	rmb5	Clock_Flag							; ���ֽ���״̬ͬ������ģʽ�ı���ֵ
	bbr6	Clock_Flag,L_NoSnooze_CloseLoud		; û��̰˯��������&&̰˯ģʽ&&���ֽ���״̬�Ż���Ȼ����̰˯ģʽ
	rmb6	Clock_Flag							; ��̰˯��������
	bra		L_CloseLoud
L_NoSnooze_CloseLoud:							; ����̰˯ģʽ���ر�����
	rmb3	Clock_Flag
	rmb6	Clock_Flag
	rmb1	RFC_Flag							; ȡ������RFC����
	lda		#0
	sta		Triggered_AlarmGroup
L_CloseLoud:
	lda		#0
	sta		AlarmLoud_Counter
	rmb1	Clock_Flag							; �ر����Ӵ�����־
	rmb2	Clock_Flag							; �ر�����ģʽ
	rmb5	Clock_Flag

	bbs4	Key_Flag,L_LoudingJuge_Exit			; ����а�����ʾ�����򲻹رշ�����
	rmb1	PADF0								; PB3 PWM�������
	rmb4	PADF0								; PB3����ΪIO��
	rmb3	PB_TYPE								; PB3ѡ��NMOS���1����©��
	smb3	PB

	rmb3	Timer_Flag
	rmb1	Time_Flag
	rmb0	TMRC
L_LoudingJuge_Exit:
	rts




L_Alarm_Process:
	bbs1	Time_Flag,L_BeepStart				; ÿ����1S��һ��
	rts
L_BeepStart:
	rmb1	Time_Flag
	lda		AlarmLoud_Counter
	cmp		#60
	beq		L_NoSnooze_CloseLoud				; ����60S��ر�����
	lda		#8									; ���ֵ�����Ϊ8��4��
	sta		Beep_Serial
	inc		AlarmLoud_Counter
	rts


; ����һ�������趨ֵ��ʱ���ַ��ϵ�ǰʱ�䣬���������Ӵ�����־λ,��ͬ������������
; �����ж�����3���������2���������1
Is_Alarm_Trigger:
	lda		Alarm_Switch
	and		#010B
	beq		L_Alarm2_NoMatch					; ���������û�п������򲻻��ж���
	lda		R_Time_Hour
	cmp		R_Alarm2_Hour
	beq		L_Alarm2_HourMatch
L_Alarm2_NoMatch:
	lda		Alarm_Switch
	and		#001B
	beq		L_Alarm1_NoMatch					; ���������û�п������򲻻��ж���
	lda		R_Time_Hour
	cmp		R_Alarm1_Hour
	beq		L_Alarm1_HourMatch
L_Alarm1_NoMatch:
	rmb1	Clock_Flag							; ����3Ҳ��ƥ�䣬����δ����
	rts

L_Alarm1_HourMatch:
	lda		R_Time_Min
	cmp		R_Alarm1_Min
	beq		L_Alarm1_MinMatch
	rmb1	Clock_Flag							; ����1���Ӳ�ƥ�䣬����δ����
	rts

L_Alarm2_HourMatch:
	lda		R_Time_Min
	cmp		R_Alarm2_Min
	beq		L_Alarm2_MinMatch
	bra		L_Alarm2_NoMatch					; ����2���Ӳ�ƥ�䣬�ж�����2


L_Alarm1_MinMatch:
	lda		R_Time_Sec
	cmp		#00
	beq		Alarm1_SecMatch
	rmb1	Clock_Flag							; ���벻ƥ�䣬�����Ӳ��������˳�
	rts
Alarm1_SecMatch:
	jsr		L_Alarm_Match_Handle
	lda		#001B
	sta		Triggered_AlarmGroup
	lda		R_Alarm1_Hour						; ���������������ӵ�ʱ����ͬ������������,����������ж��߼�
	sta		R_Alarm_Hour
	lda		R_Alarm1_Min
	sta		R_Alarm_Min
	rts

L_Alarm2_MinMatch:
	lda		R_Time_Sec
	cmp		#00
	beq		Alarm2_SecMatch
	rmb1	Clock_Flag							; ���벻ƥ�䣬�����Ӳ��������˳�
	rts
Alarm2_SecMatch:
	jsr		L_Alarm_Match_Handle
	lda		#010B
	sta		Triggered_AlarmGroup
	lda		R_Alarm2_Hour						; ���������������ӵ�ʱ����ͬ������������,����������ж��߼�
	sta		R_Alarm_Hour
	lda		R_Alarm2_Min
	sta		R_Alarm_Min
	rts




; ȷ�����Ӵ�����Ĵ�������ǰ��̰˯����Ҫ����̰˯״̬
L_Alarm_Match_Handle:
	jsr		L_NoSnooze_CloseLoud
	bbs4	Time_Flag,Alarm_Blocked
	smb1	Clock_Flag							; ͬʱ����Сʱ�ͷ��ӵ�ƥ�䣬�������Ӵ���
Alarm_Blocked:
	smb4	Time_Flag							; ���Ӵ�����������һ��1S�ڵ����Ӵ���
	rts




; X���̣�AΪ����
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


; ��A����Xλ
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
