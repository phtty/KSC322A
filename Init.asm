F_Init_SystemRam:								; ϵͳ�ڴ��ʼ��
	lda		#0001B
	sta		Sys_Status_Flag

	lda		#12
	sta		R_Time_Hour
	;lda		#00
	;sta		R_Time_Min
	;lda		#00
	;sta		R_Time_Sec

	lda		#12
	sta		R_Alarm1_Hour
	;lda		#00
	;sta		R_Alarm1_Min

	lda		#12
	sta		R_Alarm2_Hour
	;lda		#00
	;sta		R_Alarm2_Min

	lda		#01
	sta		R_Date_Day
	lda		#01
	sta		R_Date_Month
	lda		#24
	sta		R_Date_Year
	;lda		#00
	;sta		R_Date_Week

	smb1	Backlight_Flag						; �ϵ�����

	lda		#15
	sta		Count_RFC							; RFC�������

	lda		#0
	sta		Light_Level							; ��ʼ����

	rts


F_Beep_Init:
	lda		PB									; PB3����Ϊ���0
	and		#$f7
	sta		PB
	lda		PB_TYPE
	ora		#$8

	rmb3	PB_TYPE								; PB3ѡ��NMOS���0����©��

	rts


F_Port_Init:
	lda		#$3c								; PA2~5����Ϊ�������룬���������жϻ���
	sta		PA_WAKE
	lda		#$2c
	sta		PA_DIR
	lda		#$2c
	sta		PA
	smb4	IER									; ��PA���ⲿ�ж�

	lda		#$20
	sta		PC_DIR								; PC5����Ϊ��̬���룬�������0
	lda		#$0
	sta		PC

	lda		PB									; PB3����Ϊ�������
	and		#$b7
	sta		PB
	lda		PB_TYPE
	ora		#$8

	lda		#$37
	sta		PD_DIR								; PD0~2��5����Ϊ��̬���룬PD4Ϊ��������
	lda		#$10
	sta		PD
	lda		#$00
	sta		PD_SEG								; PD��ȫ����IO��ʹ��

	lda		PD
	sta		PD_IO_Backup						; ͬ��PD�ڵ�ǰ״̬����ʷ״̬

	rts


F_Timer_Init:
	rmb1	IER									; ��TMR0��1��ʱ���ж�
	rmb1	IFR									; ���TMR0��1�жϱ�־λ
	rmb2	IER
	rmb2	IFR
	rmb0	TMRC								; �ر�TMR0
	rmb1	TMRC								; �ر�TMR1

	lda		#C_DIVC_Fsub_4
	sta		DIVC								; DIVʱ��ԴΪFsub/4(8192Hz)

	; TIM2ʱ��ԴDIV,Fsub 4��Ƶ8192Hz
	lda		#256-8
	sta		TMR2								; Tim2�ж�Ƶ������Ϊ1024Hz
	lda		#C_TMR2ON
	sta		TMRC								; ����TIM2

	lda		#C_COM_8_36_32+C_LCDIS_Rate_2		; ����Ϊ8COM��LCD�ж�ʱ��Դ����Ƶ
	sta		LCD_COM
	lda		#$0f
	sta		FRAME

	lda		#0
	sta		IFR									; �����жϱ�־λ
	lda		IER									; Tim2��ʱ���ж�����PWM���⡢����ɨ�衢������������Ƶ��
	;ora		#C_TMR2I+C_LCDI+C_DIVI				; LCD�ж�����2Hz��1Hz�İ�S����1S�������ʱ
	ora		#C_DIVI
	sta		IER									; DIV�ж����ں�����ա�����ʱ��Դ��RFC������ʱ

	rts




F_RFC_Init:
	rmb6	PC_SEG

	lda		RFCC0								; PD0-3����ΪRFC����
	ora		#$0f
	sta		RFCC0

	lda		#$00
	sta		RFCC1								; �ر�RFC��������
	sta		PD_SEG								; PD��ȫ����IO��ʹ��

	rts
