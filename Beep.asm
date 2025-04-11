F_BeepManage:
	jsr		L_LoudManage
	bbs3	Timer_Flag,L_Beeping
	rts
L_Beeping:
	rmb3	Timer_Flag

	lda		Beep_Serial
	beq		L_NoBeep_Serial_Mode
	dec		Beep_Serial
	bbr0	Beep_Serial,L_NoBeep_Serial_Mode
	smb3	PB_TYPE								; PB3 ����CMOS���
	lda		PB
	and		#$f7
	sta		PB
	smb7	Timer_Switch						; ����PB3���PWM���
	rts

L_NoBeep_Serial_Mode:
	rmb7	Timer_Switch						; �ر�PB3���PWM���
	rmb3	PB_TYPE								; PB3ѡ��NMOS���1����©��
	smb3	PB

	lda		Beep_Serial
	bne		No_KeyBeep_Over	
	bbs4	Key_Flag,No_KeyBeep_Over
	bbs6	Key_Flag,No_KeyBeep_Over			; ���ڴ������򰴼���������Ҫ�����������ر�21Hz��ʱ
	rmb4	Key_Flag
	rmb6	Key_Flag
	rmb1	RFC_Flag							; �������������������ȡ������RFC����
	rmb3	Timer_Switch						; �ر�21Hz��ʱ
No_KeyBeep_Over:
	rts




; ���ֹ���
L_LoudManage:
	bbr2	Clock_Flag,NoLouding				; �������ֱ�־λʱ�Ž�����
	bbs1	Time_Flag,LoudHandle_Start
NoLouding:
	rts
LoudHandle_Start:
	rmb1	Time_Flag

	bbs1	Clock_Flag,Alarm_LoudHandle
	bbs1	Timekeep_Flag,Timekeep_LoudHandle
	rts
Alarm_LoudHandle:
	lda		#8									; �������ֵ�����Ϊ8��4��
	sta		Beep_Serial
	bra		LoudCounter_Juge
Timekeep_LoudHandle:
	lda		#4									; ��ʱ���ֵ�����Ϊ4��2��
	sta		Beep_Serial
LoudCounter_Juge:
	inc		Louding_Counter
	lda		Louding_Counter
	cmp		#60
	bcs		L_CloseLoud							; ���ּ�ʱ�ﵽ60S��ر�
	rts

L_CloseLoud:									; �������ر�����
	rmb1	RFC_Flag							; ȡ������RFC����
	lda		#0
	sta		Louding_Counter
	bbs4	Key_Flag,L_Beep_NoClose				; ����а�����ʾ�����򲻹رշ�����
	rmb7	Timer_Switch						; �رշ�����ʱ��Դ��ʱ����
	rmb3	Timer_Switch						; �ر�21Hz��ʱ
	rmb3	PB
	rmb3	Timer_Flag
L_Beep_NoClose:
	rmb1	Time_Flag
	rmb2	Clock_Flag							; ��λ����ģʽ�����ּ�ʱ1S

	bbs1	Clock_Flag,?AlarmLoud_Over
	bbs1	Timekeep_Flag,?TimekeepLoud_Over
	rts
?AlarmLoud_Over:
	lda		#0
	sta		Triggered_AlarmGroup
	rmb1	Clock_Flag							; ��λ���Ӵ�����־
	rts
?TimekeepLoud_Over:
	lda		R_TimekeepBak_Min
	sta		R_Timekeep_Min
	lda		R_TimekeepBak_Sec
	sta		R_Timekeep_Sec
	rmb1	Timekeep_Flag						; ��λ����ʱ��ɱ�־
	REFLASH_DISPLAY
	rts
