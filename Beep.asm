F_Louding:
	bbs6	Timer_Flag,L_Beeping
	rts
L_Beeping:
	rmb6	Timer_Flag

	lda		Beep_Serial
	beq		L_NoBeep_Serial_Mode
	dec		Beep_Serial
	bbr0	Beep_Serial,L_NoBeep_Serial_Mode
	smb4	PADF0								; PB3����ΪIO��
	smb3	PB_TYPE								; PB3 ����CMOS���
	smb1	PADF0								; PB3 PWM�������
	rts
L_NoBeep_Serial_Mode:
	rmb1	PADF0								; PB3 PWM�������
	rmb4	PADF0								; PB3����ΪIO��
	rmb3	PB_TYPE								; PB3ѡ��NMOS���1����©��
	smb3	PB

	bbr4	Key_Flag,No_KeyBeep_Over			; ����ǰ���������Ҫ�����������رշ�����ʱ��
	rmb4	Key_Flag
	rmb1	RFC_Flag							; �������������������ȡ������RFC����
	rmb0	TMRC
No_KeyBeep_Over:
	rts
