IR_ReceiveHandle:
	jsr		RepeatCode_Handle

	lda		IR_ReceivePhase
	clc
	rol
	tax
	lda		Receive_Phase_Table+1,x
	pha
	lda		Receive_Phase_Table,x
	pha
	rts										; ���ݵ�ǰ����׶Σ���ת����Ӧ�����봦����

Receive_Phase_Table:
	dw		IR_Receive_Phase_0-1
	dw		IR_Receive_Phase_1-1
	dw		IR_Receive_Phase_2-1
	dw		IR_Receive_Phase_3-1
	dw		IR_Receive_Phase_4-1
	dw		IR_Receive_Phase_5-1



; ����׶�0������ʱ���У��½��ص���ʱ��ʼ����
IR_Receive_Phase_0:
	lda		PD
	and		#$10
	beq		IR_Turn2Phase1
	rts
IR_Turn2Phase1:
	lda		#1
	sta		IR_ReceivePhase					; �������׶�1
	smb3	IR_Flag							; IR��ʼ����

	;smb0	IER
	lda		#0
	sta		IR_Counter						; ��ʼ������
	lda		#32
	sta		Code_Counter
	rts


; ����׶�1�����������/�ظ���ĵ�һ����ƽʱ���Ƿ�Ϸ�
IR_Receive_Phase_1:
	IR_RISING_EDGE_JUGE
	bbs0	IR_Flag,?IR_Level_Juge
	rts
?IR_Level_Juge:
	lda		IR_Counter
	cmp		#50
	bcc		Phase1_Abort					; ���磬��ֹ����
	lda		#95
	cmp		IR_Counter
	bcc		Phase1_Abort					; ���磬��ֹ����
	lda		#2
	sta		IR_ReceivePhase					; �������׶�2
	lda		#0
	sta		IR_Counter
	rts
Phase1_Abort:
	jmp		Receive_Abort


; ����׶�2�������������뻹���ظ���
IR_Receive_Phase_2:
	IR_FALLING_EDGE_JUGE
	bbs1	IR_Flag,?IR_Level_Juge
	rts
?IR_Level_Juge:
	lda		IR_Counter
	cmp		#32
	bcc		Phase2_NoGuid					; ���������磬�ж��Ƿ�Ϊ�ظ���
	lda		#40
	cmp		IR_Counter
	bcc		Phase2_Abort					; ���������磬��ֹ����
	lda		#3
	sta		IR_ReceivePhase					; �������׶�3
	lda		#0
	sta		IR_Counter
	rts
Phase2_NoGuid:
	lda		IR_Counter
	cmp		#8
	bcc		Phase2_Abort					; �ظ������磬��ֹ����
	lda		#28
	cmp		IR_Counter
	bcc		Phase2_Abort					; �ظ������磬��ֹ����
	lda		Repeat_Counter
	cmp		#19
	bcs		RepeatCounter_NoAdd
	inc		Repeat_Counter					; �յ��ظ�������ظ������������19��
RepeatCounter_NoAdd:
	lda		#8
	sta		Interval_Counter				; ˢ���ظ�������ʱ����

	lda		#5
	sta		IR_ReceivePhase					; ���յ��ظ��룬����Ҳ��ɹ�����λ�������Ӧ��Դ
	lda		#0
	sta		IR_Counter
	lda		IR_Flag
	and		#%00110000
	sta		IR_Flag
	;rmb0	IER
	rts
Phase2_Abort:
	jmp		Receive_Abort


; ����׶�3�������Ԫ��һ����ƽʱ���Ƿ�Ϸ�
IR_Receive_Phase_3:
	IR_RISING_EDGE_JUGE
	bbs0	IR_Flag,?IR_Level_Juge
	rts
?IR_Level_Juge:
	lda		#7
	cmp		IR_Counter
	bcc		Phase3_Abort					; ���磬��ֹ����
	lda		#4
	sta		IR_ReceivePhase					; �������׶�4
	lda		#0
	sta		IR_Counter
	rts
Phase3_Abort:
	jmp		Receive_Abort


; ����׶�4������0���1�룬����ӻ�������ͬʱ�жϽ����Ƿ����
IR_Receive_Phase_4:
	IR_FALLING_EDGE_JUGE
	bbs1	IR_Flag,?IR_Level_Juge
	rts
?IR_Level_Juge:
	lda		IR_Counter
	cmp		#2
	bcc		Phase4_No0Code					; ��0��
	lda		#7
	cmp		IR_Counter
	bcc		Phase4_No0Code
	clc										; ���0��
	jmp		Receive_AfterHandle				; ����1bit�ĺ���
Phase4_No0Code:
	lda		IR_Counter
	cmp		#9
	bcc		Phase4_Abort					; Ҳ��1�룬��ֹ����
	lda		#20
	cmp		IR_Counter
	bcc		Phase4_Abort					; Ҳ��1�룬��ֹ����
	sec										; ���1��
	jmp		Receive_AfterHandle				; ����1bit�ĺ���
Phase4_Abort:
	jmp		Receive_Abort


; ����׶�5���ȴ���ֹ������������ڿ��еȴ��׶�������׶�1
IR_Receive_Phase_5:
	IR_RISING_EDGE_JUGE
	bbs0	IR_Flag,?IR_Level_Juge
	rts
?IR_Level_Juge:
	;rmb0	IER
	lda		#0
	sta		IR_ReceivePhase
	lda		#8
	sta		Interval_Counter
	rts


Receive_Abort:
	lda		#0
	sta		IR_ReceivePhase
	sta		IR_Counter						; ��ռ���
	sta		IR_Flag
L_Clr_CodeBuffer:
	jsr		DepressKey_Handle				; �ɼ�����
	lda		#0
	sta		ID_Code							; ��ս��뻺����
	sta		D_Code
	sta		IA_Code
	sta		A_Code
	sta		Repeat_Counter					; ÿ������ʧ�ܻ�ϵ����������ظ��룬����ظ����������
	rmb4	IR_Flag							; �ر��ظ�������ʱ��ʱ�ͼ�������
	rmb4	Timer_Switch
	;rmb0	IER
	rts


; ����1bit�ĺ���
Receive_AfterHandle:
	ror		ID_Code							; �����յ�����Ԫ���
	ror		D_Code
	ror		IA_Code
	ror		A_Code

	dec		Code_Counter
	beq		Receive_Complete				; ���ѽ���32���룬���������
	lda		#3
	sta		IR_ReceivePhase					; ����ص��׶�3��������һ����
	lda		#0
	sta		IR_Counter
	rts
Receive_Complete:
	lda		#5
	sta		IR_ReceivePhase					; �������׶�5
	lda		#0
	sta		IR_Counter						; ��ռ���
	sta		Repeat_Counter					; ÿ������ɹ�Ҳ��ϵ����������ظ��룬����ظ����������
	lda		#%00010100						; ��λ��ر�־λ���򿪽����־λ
	sta		IR_Flag
	smb4	Timer_Switch					; ��32Hz�������أ���ʼ�����ظ��벢����
	rts




RepeatCode_Handle:
	bbr4	IR_Flag,?Handle_Exit			; Ҫͬʱ���ظ�������ʼ������32Hz��־�Ŵ���
	bbs4	Timer_Flag,RepeatCounter_Handle
?Handle_Exit:
	rts
RepeatCounter_Handle:
	rmb4	Timer_Flag
	dec		Interval_Counter				; �ظ����������ݼ�
	beq		Interval_Timeout				; ����0��Ϊ��ʱ
	lda		Repeat_Counter
	cmp		#19
	bcc		L_IR_NoLongPress				; �����յ�19���ظ����򴥷���������
	bbs5	IR_Flag,?Handle_Exit			; ��������ÿ�γ���ֻ��һ��
	smb5	IR_Flag							; �������ܴ�������������лᴦ����
	smb2	Timer_Switch					; ��4Hz��������
?Handle_Exit:
	rts
L_IR_NoLongPress:
	rmb5	IR_Flag							; �ظ������û��19����û�г�������
	rmb2	Timer_Switch					; �ر�4Hz��������
	rts
Interval_Timeout:
	rmb5	IR_Flag							; ��λ���������־
	jmp		L_Clr_CodeBuffer




; �ɼ���Ч�İ�������
DepressKey_Handle:
	lda		IR_DepressJuge
	bne		DepressKey_Handle_Start
	rts
DepressKey_Handle_Start:
	bbs0	IR_DepressJuge,OK_DepressFunc
	bbs1	IR_DepressJuge,TimeUp_DepressFunc
	bbs2	IR_DepressJuge,TimeDown_DepressFunc
	rts

OK_DepressFunc:
	rmb0	IR_DepressJuge
	lda		Sys_Status_Ordinal
	bne		?TimeDown_Mode
	jmp		Timekeep_Pause_Continue			; ����ʱģʽֱ����ͣ��ʱ
?TimeDown_Mode:
	lda		R_Timekeep_Min
	bne		?TimeDown_FuncOK
	lda		R_Timekeep_Sec
	bne		?TimeDown_FuncOK
	rts										; ����ʱģʽ�ڼ�ʱΪ0ʱû�з�Ӧ
?TimeDown_FuncOK:
	jmp		Timekeep_Pause_Continue			; ����ʱģʽ�ڼ�ʱ��Ϊ0ʱ�Ż���ͣ��ʱ

TimeUp_DepressFunc:
	rmb1	IR_DepressJuge
	bbs0	Sys_Status_Ordinal,?TimeUp_NoFunc_TimeUp
	bbs0	Timekeep_Flag,?TimeUp_NoFunc_TimeUp
	jsr		F_RFC_Abort						; ��ֹRFC������������ʾ
	jmp		SwitchState_TimeUpMode			; ����ʱģʽδ���ü�ʱ״̬�£��л�������ʱģʽ
?TimeUp_NoFunc_TimeUp:
	rts

TimeDown_DepressFunc:
	rmb2	IR_DepressJuge
	bbs0	Sys_Status_Ordinal,?TimeDown_NoFunc_TimeDown
	bbs0	Timekeep_Flag,?TimeDown_NoFunc_TimeDown
	jsr		F_RFC_Abort						; ��ֹRFC������������ʾ
	jmp		SwitchState_TimeDownMode		; ����ʱģʽδ���ü�ʱ״̬�£��л�������ʱģʽ
?TimeDown_NoFunc_TimeDown:
	rts





; ��ѭ����ʽ����ʱ������ѭ����ȫ�ֹ��ܲ��ֵ��øú�������
; ������ɻ�����ֹʱ�˳�ѭ��
IR_Receive_Loop:
	jsr		IR_ReceiveHandle				; �������
	lda		IR_ReceivePhase
	beq		No_IR_Receiveing
	bra		IR_Receive_Loop					; ����ǰ���ս׶η�0����ѭ������ֱ������׶�����Ϊ0
No_IR_Receiveing:
	jsr		F_IR_Decode						; �������
	rts




; ������յ�NEC��ִ�ж�Ӧ�Ĺ��ܺ���
F_IR_Decode:
	bbr5	IR_Flag,L_No_LongPress
	bbr2	Timer_Flag,L_No_LongPress
	rmb2	Timer_Flag
	bra		IR_Decode_Start					; ���г�����־ʱ��4Hz��һ�ν������ִ�й���
L_No_LongPress:
	bbs2	IR_Flag,IR_Decode_Start
	rts
IR_Decode_Start:
	rmb2	IR_Flag							; ÿ��������ɺ�ֻ����1��
	lda		D_Code
	eor		ID_Code							; У�������룬��У��ʧ���򲻽��벢��ջ�����
	cmp		#$ff
	beq		IR_Code_CheckOK
	jmp		Receive_Abort

IR_Code_CheckOK:
	ldx		#0
Compare_DCode_Loop:
	lda		Table_IR_KeyCode,x
	cmp		D_Code
	beq		IR_KeyHandle					; �ȶԽ��յ�������ͱ�����ݣ�����Ӧ�İ�������
	inx
	cpx		#21
	bcc		Compare_DCode_Loop
	rts

; ��ת����Ӧ���ܺ���
IR_KeyHandle:
	jsr		L_ShutDown_Loud					; ����ʱ�������֣���ر����ӣ�����ִ�а�������
	lda		#0
	sta		Return_Counter					; ��շ��س�ʼ״̬����

	cpx		#0
	beq		No_KeyOnOff
	bbs1	Backlight_Flag,No_KeyOnOff
	rts										; ��OnOff����Ϩ��ģʽ��û��Ч��
No_KeyOnOff:

	txa
	clc
	rol
	tax
	lda		IR_Func_JumpTable+1,x
	pha
	lda		IR_Func_JumpTable,x
	pha
	rts

IR_Func_JumpTable:
	dw		L_IR_Func_OnOff-1
	dw		L_IR_Func_12_24-1
	dw		L_IR_Func_Alarm-1
	dw		L_IR_Func_Inc-1
	dw		L_IR_Func_Set-1
	dw		L_IR_Func_Dec-1
	dw		L_IR_Func_LightStaue-1
	dw		L_IR_Func_OK-1
	dw		L_IR_Func_CF-1
	dw		L_IR_Func_TimerUp-1
	dw		L_IR_Func_TimerDown-1
	dw		L_IR_Func_0-1
	dw		L_IR_Func_1-1
	dw		L_IR_Func_2-1
	dw		L_IR_Func_3-1
	dw		L_IR_Func_4-1
	dw		L_IR_Func_5-1
	dw		L_IR_Func_6-1
	dw		L_IR_Func_7-1
	dw		L_IR_Func_8-1
	dw		L_IR_Func_9-1


IR_ShutDown_KeyScan:
	jmp		Interval_Timeout


L_ShutDown_Loud:							; �����ر�����
	bbs2	Clock_Flag,?No_AlarmLouding
	bbs1	Timekeep_Flag,?No_TimekeepLouding
	rts
?No_AlarmLouding:
	jsr		L_CloseLoud						; �������
	pla
	pla
	jmp		IR_ShutDown_KeyScan
?No_TimekeepLouding:
	jsr		CloseBeep						; �������
	pla
	pla
	jmp		IR_ShutDown_KeyScan




L_IR_Func_OnOff:
	jsr		L_KeyBeep_ON

	bbr1	Backlight_Flag,?WakeUp_Screen
	rmb1	Backlight_Flag
	LED_SET_HIGH
	jmp		IR_ShutDown_KeyScan				; ִֻ��1�ΰ�������

?WakeUp_Screen:
	jsr		WakeUp_Event
	jmp		IR_ShutDown_KeyScan				; ִֻ��1�ΰ�������




L_IR_Func_12_24:
	jsr		L_KeyBeep_ON					; ������

	lda		Sys_Status_Flag
	and		#%01100
	beq		?No_DisMode						; ��ʾģʽ��Ч
	jsr		Return_CD_Mode					; ����ģʽ�»᷵��ʱ��
	jmp		IR_ShutDown_KeyScan				; ִֻ��1�ΰ�������
?No_DisMode:
	bbs4	Sys_Status_Flag,IR_12_24_Exit	; ��ʱģʽ�´˰����޹���
	jsr		DM_SW_TimeMode					; ������ģʽ�л�12/24ģʽ
IR_12_24_Exit:
	jmp		IR_ShutDown_KeyScan




L_IR_Func_Alarm:
	jsr		L_KeyBeep_ON					; ������

	lda		Sys_Status_Flag
	and		#%01100
	beq		?No_SetMode
	jsr		Return_CD_Mode					; ����ģʽ�᷵��ʱ��
	jmp		IR_ShutDown_KeyScan				; ִֻ��1�ΰ�������
?No_SetMode:
	bbs4	Sys_Status_Flag,IR_Alarm_Exit	; ��ʱģʽ��Ч
	jsr		SwitchState_AlarmDis			; ��ʾģʽ����������л�
IR_Alarm_Exit:
	jmp		IR_ShutDown_KeyScan




L_IR_Func_Inc:
	bbs5	IR_Flag,?LongPress_BeepOFF
	jsr		L_KeyBeep_ON					; ֻ�е�һ���а�����
?LongPress_BeepOFF:
	lda		Sys_Status_Flag
	and		#%10011
	beq		?SetMode
	jmp		IR_ShutDown_KeyScan				; ������ģʽ�˰�����Ч
?SetMode:
	bbr2	Sys_Status_Flag,?No_CS_Mode
	jmp		AddNum_CS						; ʱ��ģʽ����
?No_CS_Mode:
	bbr3	Sys_Status_Flag,?No_AS_Mode
	jmp		AddNum_AS						; ����ģʽ����
?No_AS_Mode:
	jmp		IR_ShutDown_KeyScan




L_IR_Func_Set:
	jsr		L_KeyBeep_ON					; ������
	lda		Sys_Status_Flag
	and		#%00101							; ʱ��ģʽ�л�������ģʽ
	beq		?No_CS_Mode
	jsr		SwitchState_ClockSet
	jmp		IR_ShutDown_KeyScan				; ִֻ��1�ΰ�������
?No_CS_Mode:
	lda		Sys_Status_Flag
	and		#%01010							; ����ģʽ�л�������ģʽ
	beq		IR_Set_Exit
	jsr		SwitchState_AlarmSet
IR_Set_Exit:
	jmp		IR_ShutDown_KeyScan




L_IR_Func_Dec:
	bbs5	IR_Flag,?LongPress_BeepOFF
	jsr		L_KeyBeep_ON					; ֻ�е�һ���а�����
?LongPress_BeepOFF:
	lda		Sys_Status_Flag
	and		#%10011
	beq		?SetMode
	jmp		IR_ShutDown_KeyScan				; ������ģʽ�˰�����Ч
?SetMode:
	bbr2	Sys_Status_Flag,?No_CS_Mode
	jmp		SubNum_CS						; ʱ��ģʽ����
?No_CS_Mode:
	bbr3	Sys_Status_Flag,?No_AS_Mode
	jmp		SubNum_AS						; ����ģʽ����
?No_AS_Mode:
	jmp		IR_ShutDown_KeyScan




L_IR_Func_LightStaue:
	jsr		L_KeyBeep_ON					; ������

	jsr		LightLevel_Change
	nop										; ���ȵȼ���ʾ
	jmp		IR_ShutDown_KeyScan				; ִֻ��1�ΰ�������




L_IR_Func_OK:
	bbs5	IR_Flag,?LongPress_BeepOFF
	jsr		L_KeyBeep_ON					; ֻ��һ��������
?LongPress_BeepOFF:

	bbs4	Sys_Status_Flag,FuncOK_TimekeepMode
	lda		Sys_Status_Flag
	and		#%01100
	beq		?No_SetMode
	jsr		Return_CD_Mode					; ����ģʽ�᷵��ʱ��
?No_SetMode:
	jmp		IR_ShutDown_KeyScan				; ִֻ��1��
FuncOK_TimekeepMode:
	bbs5	IR_Flag,?LongPress_Trigger
	smb0	IR_DepressJuge					; δ����ʱ����λ�ɼ������־
	rts
?LongPress_Trigger:
	rmb0	IR_DepressJuge					; ����������λ�ɼ������־
	bbs0	Timekeep_Flag,?TimekeepON		; ���ֻ�ڼ�ʱδ����ʱ��Ч
	jsr		Timekeep_ClearCount
?TimekeepON:
	jmp		IR_ShutDown_KeyScan				; ��������ִֻ��1��




L_IR_Func_CF:
	jsr		L_KeyBeep_ON					; ������
	bbs4	Sys_Status_Flag,IR_CF_Exit		; �ð�����ʱģʽ�޹���
	lda		Sys_Status_Flag
	and		#%01100
	beq		?No_SetMode
	jsr		Return_CD_Mode					; ����ģʽ�˰����᷵��ʱ��
	jmp		IR_ShutDown_KeyScan
?No_SetMode:
	jsr		TemperMode_Change
	bra		IR_CF_Exit
IR_CF_Exit:
	jmp		IR_ShutDown_KeyScan




L_IR_Func_TimerUp:
	bbs5	IR_Flag,?LongPress_BeepOFF
	jsr		L_KeyBeep_ON					; ֻ�е�һ���а�����
?LongPress_BeepOFF:

	lda		Sys_Status_Flag
	and		#%10011
	bne		Func_TimeUp_Effect
	jsr		Return_CD_Mode					; ����ģʽ�᷵��ʱ��
	jmp		IR_ShutDown_KeyScan				; ִֻ��1�ΰ�������
Func_TimeUp_Effect:
	bbs4	Sys_Status_Flag,TimeKeep_UpMode
	jsr		F_RFC_Abort						; ��ֹRFC������������ʾ
	jsr		SwitchState_TimeUpMode			; �л�������ʱģʽ
	jmp		IR_ShutDown_KeyScan				; ��������ִֻ��1��
TimeKeep_UpMode:
	bbs0	Timekeep_Flag,TimeKeep_UpMode_Exit
	bbs5	IR_Flag,?LongPress_Trigger
	smb1	IR_DepressJuge
	rts
?LongPress_Trigger:
	rmb1	IR_DepressJuge
	rmb1	RFC_Flag						; ��������RFC����
	jsr		Return_CD_Mode					; ����ʱ��
	jsr		F_Display_Date
	jsr		F_Display_Week
	jsr		F_Display_Temper
TimeKeep_UpMode_Exit:
	jmp		IR_ShutDown_KeyScan				; ��������ִֻ��1��




L_IR_Func_TimerDown:
	bbs5	IR_Flag,?LongPress_BeepOFF
	jsr		L_KeyBeep_ON					; ֻ�е�һ���а�����
?LongPress_BeepOFF:

	lda		Sys_Status_Flag
	and		#%10011
	bne		Func_TimeDown_Effect	
	jsr		Return_CD_Mode					; ����ģʽ�᷵��ʱ��
	jmp		IR_ShutDown_KeyScan				; ִֻ��1�ΰ�������
Func_TimeDown_Effect:
	bbs4	Sys_Status_Flag,TimeKeep_DownMode
	jsr		F_RFC_Abort						; ��ֹRFC������������ʾ
	jsr		SwitchState_TimeDownMode		; �л�������ʱģʽ
	jmp		IR_ShutDown_KeyScan				; ��������ִֻ��1��
TimeKeep_DownMode:
	bbs0	Timekeep_Flag,TimeKeep_DownMode_Exit
	bbs5	IR_Flag,?LongPress_Trigger
	smb2	IR_DepressJuge
	rts
?LongPress_Trigger:
	rmb2	IR_DepressJuge
	rmb1	RFC_Flag						; ��������RFC����
	jsr		Return_CD_Mode					; ����ʱ��
	jsr		F_Display_Date
	jsr		F_Display_Week
	jsr		F_Display_Temper
TimeKeep_DownMode_Exit:
	jmp		IR_ShutDown_KeyScan				; ��������ִֻ��1��




L_IR_Func_0:
	jsr		L_KeyBeep_ON					; ������

	lda		Sys_Status_Flag
	and		#%10011
	bne		?Func_Effect
	jsr		Return_CD_Mode					; ����ģʽ�᷵��ʱ��
	jmp		IR_ShutDown_KeyScan				; ִֻ��1�ΰ�������
?Func_Effect:
	bbr4	Sys_Status_Flag,?Display_Mode	; ��ʾģʽ��ִ���κβ���
	lda		Sys_Status_Ordinal
	beq		?Display_Mode
	bbs0	Timekeep_Flag,?Display_Mode		; ����ʱδ���ü�ʱ��������
	lda		#0
	sta		P_Temp
	jsr		Timekeep_NumSet
?Display_Mode:
	jmp		IR_ShutDown_KeyScan				; ִֻ��1�ΰ�������


L_IR_Func_1:
	jsr		L_KeyBeep_ON					; ������

	lda		Sys_Status_Flag
	and		#%10011
	bne		?Func_Effect
	jsr		Return_CD_Mode					; ����ģʽ�᷵��ʱ��
	jmp		IR_ShutDown_KeyScan				; ִֻ��1�ΰ�������
?Func_Effect:
	bbr4	Sys_Status_Flag,?Display_Mode	; ��ʾģʽ��ִ���κβ���
	lda		Sys_Status_Ordinal
	beq		?Display_Mode
	bbs0	Timekeep_Flag,?Display_Mode		; ����ʱδ���ü�ʱ��������
	lda		#1
	sta		P_Temp
	jsr		Timekeep_NumSet
?Display_Mode:
	jmp		IR_ShutDown_KeyScan				; ִֻ��1�ΰ�������


L_IR_Func_2:
	jsr		L_KeyBeep_ON					; ������
	
	lda		Sys_Status_Flag
	and		#%10011
	bne		?Func_Effect
	jsr		Return_CD_Mode					; ����ģʽ�᷵��ʱ��
	jmp		IR_ShutDown_KeyScan				; ִֻ��1�ΰ�������
?Func_Effect:
	bbr4	Sys_Status_Flag,?Display_Mode	; ��ʾģʽ��ִ���κβ���
	lda		Sys_Status_Ordinal
	beq		?Display_Mode
	bbs0	Timekeep_Flag,?Display_Mode		; ����ʱδ���ü�ʱ��������
	lda		#2
	sta		P_Temp
	jsr		Timekeep_NumSet
?Display_Mode:
	jmp		IR_ShutDown_KeyScan				; ִֻ��1�ΰ�������


L_IR_Func_3:
	jsr		L_KeyBeep_ON					; ������

	lda		Sys_Status_Flag
	and		#%10011
	bne		?Func_Effect
	jsr		Return_CD_Mode					; ����ģʽ�᷵��ʱ��
	jmp		IR_ShutDown_KeyScan				; ִֻ��1�ΰ�������
?Func_Effect:
	bbr4	Sys_Status_Flag,?Display_Mode	; ��ʾģʽ��ִ���κβ���
	lda		Sys_Status_Ordinal
	beq		?Display_Mode
	bbs0	Timekeep_Flag,?Display_Mode		; ����ʱδ���ü�ʱ��������
	lda		#3
	sta		P_Temp
	jsr		Timekeep_NumSet
?Display_Mode:
	jmp		IR_ShutDown_KeyScan				; ִֻ��1�ΰ�������


L_IR_Func_4:
	jsr		L_KeyBeep_ON					; ������

	lda		Sys_Status_Flag
	and		#%10011
	bne		?Func_Effect
	jsr		Return_CD_Mode					; ����ģʽ�᷵��ʱ��
	jmp		IR_ShutDown_KeyScan				; ִֻ��1�ΰ�������
?Func_Effect:
	bbr4	Sys_Status_Flag,?Display_Mode	; ��ʾģʽ��ִ���κβ���
	lda		Sys_Status_Ordinal
	beq		?Display_Mode
	bbs0	Timekeep_Flag,?Display_Mode		; ����ʱδ���ü�ʱ��������
	lda		#4
	sta		P_Temp
	jsr		Timekeep_NumSet
?Display_Mode:
	jmp		IR_ShutDown_KeyScan				; ִֻ��1�ΰ�������


L_IR_Func_5:
	jsr		L_KeyBeep_ON					; ������

	lda		Sys_Status_Flag
	and		#%10011
	bne		?Func_Effect
	jsr		Return_CD_Mode					; ����ģʽ�᷵��ʱ��
	jmp		IR_ShutDown_KeyScan				; ִֻ��1�ΰ�������
?Func_Effect:
	bbr4	Sys_Status_Flag,?Display_Mode	; ��ʾģʽ��ִ���κβ���
	lda		Sys_Status_Ordinal
	beq		?Display_Mode
	bbs0	Timekeep_Flag,?Display_Mode		; ����ʱδ���ü�ʱ��������
	lda		#5
	sta		P_Temp
	jsr		Timekeep_NumSet
?Display_Mode:
	jmp		IR_ShutDown_KeyScan				; ִֻ��1�ΰ�������


L_IR_Func_6:
	jsr		L_KeyBeep_ON					; ������

	lda		Sys_Status_Flag
	and		#%10011
	bne		?Func_Effect
	jsr		Return_CD_Mode					; ����ģʽ�᷵��ʱ��
	jmp		IR_ShutDown_KeyScan				; ִֻ��1�ΰ�������
?Func_Effect:
	bbr4	Sys_Status_Flag,?Display_Mode	; ��ʾģʽ��ִ���κβ���
	lda		Sys_Status_Ordinal
	beq		?Display_Mode
	bbs0	Timekeep_Flag,?Display_Mode		; ����ʱδ���ü�ʱ��������
	lda		#6
	sta		P_Temp
	jsr		Timekeep_NumSet
?Display_Mode:
	jmp		IR_ShutDown_KeyScan				; ִֻ��1�ΰ�������


L_IR_Func_7:
	jsr		L_KeyBeep_ON					; ������

	lda		Sys_Status_Flag
	and		#%10011
	bne		?Func_Effect
	jsr		Return_CD_Mode					; ����ģʽ�᷵��ʱ��
	jmp		IR_ShutDown_KeyScan				; ִֻ��1�ΰ�������
?Func_Effect:
	bbr4	Sys_Status_Flag,?Display_Mode	; ��ʾģʽ��ִ���κβ���
	lda		Sys_Status_Ordinal
	beq		?Display_Mode
	bbs0	Timekeep_Flag,?Display_Mode		; ����ʱδ���ü�ʱ��������
	lda		#7
	sta		P_Temp
	jsr		Timekeep_NumSet
?Display_Mode:
	jmp		IR_ShutDown_KeyScan				; ִֻ��1�ΰ�������


L_IR_Func_8:
	jsr		L_KeyBeep_ON					; ������

	lda		Sys_Status_Flag
	and		#%10011
	bne		?Func_Effect
	jsr		Return_CD_Mode					; ����ģʽ�᷵��ʱ��
	jmp		IR_ShutDown_KeyScan				; ִֻ��1�ΰ�������
?Func_Effect:
	bbr4	Sys_Status_Flag,?Display_Mode	; ��ʾģʽ��ִ���κβ���
	lda		Sys_Status_Ordinal
	beq		?Display_Mode
	bbs0	Timekeep_Flag,?Display_Mode		; ����ʱδ���ü�ʱ��������
	lda		#8
	sta		P_Temp
	jsr		Timekeep_NumSet
?Display_Mode:
	jmp		IR_ShutDown_KeyScan				; ִֻ��1�ΰ�������


L_IR_Func_9:
	jsr		L_KeyBeep_ON					; ������

	lda		Sys_Status_Flag
	and		#%10011
	bne		?Func_Effect
	jsr		Return_CD_Mode					; ����ģʽ�᷵��ʱ��
	jmp		IR_ShutDown_KeyScan				; ִֻ��1�ΰ�������
?Func_Effect:
	bbr4	Sys_Status_Flag,?Display_Mode	; ��ʾģʽ��ִ���κβ���
	lda		Sys_Status_Ordinal
	beq		?Display_Mode
	bbs0	Timekeep_Flag,?Display_Mode		; ����ʱδ���ü�ʱ��������
	lda		#9
	sta		P_Temp
	jsr		Timekeep_NumSet
?Display_Mode:
	jmp		IR_ShutDown_KeyScan				; ִֻ��1�ΰ�������
