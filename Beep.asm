F_BeepManage:
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

	bbr4	Key_Flag,No_KeyBeep_Over			; ����ǰ���������Ҫ�����������ر�21Hz��ʱ
	rmb4	Key_Flag
	rmb1	RFC_Flag							; �������������������ȡ������RFC����
	rmb3	Timer_Switch						; �ر�21Hz��ʱ
No_KeyBeep_Over:
	rts
