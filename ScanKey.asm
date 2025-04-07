; ��������
F_KeyHandler:
	bbs2	Key_Flag,L_Key4Hz					; ��ӵ�����4Hzɨһ�Σ����ƿ��Ƶ��
	bbr1	Key_Flag,L_KeyScan					; �״ΰ�������
	rmb1	Key_Flag							; ��λ�״δ���
	jsr		L_KeyDelay
	lda		PA
	eor		#$3c								; �����Ƿ��߼��ģ���ָ���ļ�λ������ȡ��
	and		#$3c
	bne		L_KeyYes							; ����Ƿ��а�������
	jmp		L_KeyNoScanExit
L_KeyYes:
	rmb4	IER									; ����ȷ�������󣬹ر��жϱ����󴥷�
	sta		PA_IO_Backup
	bra		L_KeyHandle							; �״δ����������

L_Key4Hz:
	bbr2	Timer_Flag,L_KeyScanExit
	rmb2	Timer_Flag
L_KeyScan:										; ����������
	bbr0	Key_Flag,L_KeyNoScanExit			; û��ɨ����־��Ϊ�ް��������ˣ��ж��Ƿ�ȡ������RFC����

	bbr4	Timer_Flag,L_KeyScanExit			; û��ʼ���ʱ����16Hzɨ��
	rmb4	Timer_Flag
	lda		PA
	eor		#$3c								; �����Ƿ��߼��ģ���ָ���ļ�λ������ȡ��
	and		#$3c
	cmp		PA_IO_Backup						; ����⵽�а�����״̬�仯���˳�����жϲ�����
	beq		L_4_32Hz_Count
	jsr		F_SpecialKey_Handle					; ������ֹʱ������һ�����ⰴ���Ĵ���
	bra		L_KeyExit
L_4_32Hz_Count:
	bbs2	Key_Flag,Counter_NoAdd				; �ڿ�Ӵ������ټ������Ӽ���
	inc		QuickAdd_Counter					; ������������ᵼ�²�������������
Counter_NoAdd:
	lda		QuickAdd_Counter
	cmp		#64
	bcs		L_QuikAdd
	rts											; ������ʱ��������2S���п��
L_QuikAdd:
	bbs2	Key_Flag,NoQuikAdd_Beep
	jsr		L_KeyBeep_ON
NoQuikAdd_Beep:
	smb2	Key_Flag
	rmb2	Timer_Flag
	smb2	Timer_Switch						; ����4Hz��ʱ


L_KeyHandle:
	lda		PA
	eor		#$3c								; �����Ƿ��߼��ģ���ָ���ļ�λ������ȡ��
	and		#$3c
	cmp		#$04
	bne		No_KeySTrigger						; ������תָ��Ѱַ���������⣬�������jmp������ת
	jmp		L_KeySTrigger						; S������
No_KeySTrigger:
	cmp		#$08
	bne		No_KeyUTrigger
	jmp		L_KeyUTrigger						; U������
No_KeyUTrigger:
	cmp		#$10
	bne		No_KeyDTrigger
	jmp		L_KeyDTrigger						; D������
No_KeyDTrigger:
	cmp		#$20
	bne		L_KeyExit
	jmp		L_KeyFTrigger						; F������

L_KeyExit:
	rmb4	Timer_Switch						; �ر�32Hz��4Hz��ʱ
	rmb2	Timer_Switch
	rmb0	Key_Flag							; ����ر�־λ
	rmb2	Key_Flag
	lda		#0									; ������ر���
	sta		QuickAdd_Counter
	sta		SpecialKey_Flag
	sta		Counter_DP
	rmb4	IFR									; ��λ��־λ,�����жϿ���ʱֱ�ӽ����жϷ���
	smb4	IER									; ����������������¿���PA���ж�
L_KeyScanExit:
	rts

L_KeyNoScanExit:								; û��ɨ����������ǿ���״̬����ʱ�ж��Ƿ�ȡ������RFC����
	bbs4	Key_Flag,L_KeyScanExit				; ������������ģʽ�£���ȡ������
	bbs2	Clock_Flag,L_KeyScanExit
	rmb1	RFC_Flag							; ȡ������RFC����						
	rts


F_SpecialKey_Handle:							; ���ⰴ���Ĵ���
	lda		SpecialKey_Flag
	bne		SpecialKey_Handle
	rts
SpecialKey_Handle:
	bbs2	Key_Flag,SpecialKey_NoBeep
	jsr		L_KeyBeep_ON
SpecialKey_NoBeep:
	bbs0	SpecialKey_Flag,L_KeyS_ShortHandle	; �̰������⹦�ܴ���
	bbs1	SpecialKey_Flag,L_KeyU_ShortHandle
	bbs2	SpecialKey_Flag,L_KeyD_ShortHandle
	bbs3	SpecialKey_Flag,L_KeyF_ShortHandle

L_KeyS_ShortHandle:
	lda		Sys_Status_Flag
	and		#0011B
	beq		KeyS_NoDisMode
	rts
KeyS_NoDisMode:
	lda		Sys_Status_Flag
	cmp		#0100B
	bne		StatusCS_No_KeyS_Short
	jsr		SubNum_CS							; ʱ��ģʽ����
	rts
StatusCS_No_KeyS_Short:
	cmp		#1000B
	bne		KeyS_ShortHandle_Exit
	jsr		SubNum_AS							; ����ģʽ����
KeyS_ShortHandle_Exit:
	rts


L_KeyU_ShortHandle:
	lda		Sys_Status_Flag
	and		#0011B
	beq		KeyU_NoDisMode
	lda		#0001B
	sta		Sys_Status_Flag
	jsr		DM_SW_TimeMode						; ��ʾģʽ���л�12/24hģʽ
	rts
KeyU_NoDisMode:
	lda		Sys_Status_Flag
	cmp		#0100B
	bne		StatusCS_No_KeyU
	jsr		AddNum_CS							; ʱ��ģʽ����
	rts
StatusCS_No_KeyU:
	cmp		#1000B
	bne		KeyU_ShortHandle_Exit
	jsr		AddNum_AS							; ����ģʽ����
KeyU_ShortHandle_Exit:
	rts


L_KeyD_ShortHandle:
	rts


L_KeyF_ShortHandle:
	lda		Sys_Status_Flag
	cmp		#1000B
	bne		No_SwitchState_AlarmSet				; ����ģʽ�л���������
	jsr		SwitchState_AlarmSet
	rts
No_SwitchState_AlarmSet:
	jsr		SwitchState_AlarmDis				; �л�������ʾ״̬
	rts



; ������������������ÿ���������������Ӧ����
L_KeyFTrigger:
	jsr		L_Universal_TriggerHandle			; ͨ�ð�������
	jsr		L_Key_ShutdownLoud					; ������������

	lda		Sys_Status_Flag
	cmp		#0100B
	bne		StatusCS_No_KeyF
	jmp		L_KeyExit							; ʱ������ģʽA����Ч
StatusCS_No_KeyF:
	cmp		#1000B
	bne		StatusAS_No_KeyF
	bbr2	Key_Flag,L_ASMode_KeyF_ShortTri
	jsr		L_KeyBeep_OFF
	jmp		L_KeyExit							; ��������ģʽA��������Ч
L_ASMode_KeyF_ShortTri:
	smb0	SpecialKey_Flag						; ����ģʽ�£�A��Ϊ���⹦�ܰ���
	rts
StatusAS_No_KeyF:
	bbs2	Key_Flag,L_DisMode_KeyF_LongTri
	smb0	SpecialKey_Flag						; ��ʾģʽ�£�A��Ϊ���⹦�ܰ���
	rts
L_DisMode_KeyF_LongTri:
	jsr		SwitchState_AlarmSet				; ����ʾģʽ�л�����������ģʽ
	jmp		L_KeyExit							; ���ʱ�����ظ�ִ�й��ܺ���


L_KeyDTrigger:
	jsr		L_Universal_TriggerHandle			; ͨ�ð�������

	bbr2	Clock_Flag,StatusLM_No_KeyD
	jmp		L_KeyExit
StatusLM_No_KeyD:
	bbs2	Key_Flag,L_DisMode_KeyD_LongTri
	smb1	SpecialKey_Flag
	rts
L_DisMode_KeyD_LongTri:
	jsr		TemperMode_Change					; �л�����-���϶�
	jmp		L_KeyExit							; ���ʱ�����ظ�ִ�й��ܺ���


L_KeyMTrigger:
	jsr		L_Universal_TriggerHandle			; ͨ�ð�������
	jsr		L_Key_ShutdownLoud					; ������������

	lda		Sys_Status_Flag
	cmp		#0100B
	bne		StatusCS_No_KeyM
	bbr2	Key_Flag,L_CSMode_KeyM_ShortTri
	jsr		L_KeyBeep_OFF
	jmp		L_KeyExit							; ʱ��ģʽM��������Ч
L_CSMode_KeyM_ShortTri:
	smb2	SpecialKey_Flag
	rts
StatusCS_No_KeyM:
	cmp		#1000B
	bne		StatusAS_No_KeyM
	jmp		L_KeyExit							; ����ģʽM����Ч
StatusAS_No_KeyM:
	bbs2	Key_Flag,L_DisMode_KeyM_LongTri		; �ж���ʾģʽ�µ�M����
	lda		Sys_Status_Flag
	and		#0011B
	beq		StatusDM_No_KeyM
	smb2	SpecialKey_Flag						; ��ʾģʽ�£�M��Ϊ���⹦�ܰ���
StatusDM_No_KeyM:
	rts
L_DisMode_KeyM_LongTri:
	jsr		SwitchState_ClockSet				; ����ʾģʽ�л���ʱ������ģʽ
	jmp		L_KeyExit							; ���ʱ�����ظ�ִ�й��ܺ���


L_KeyUTrigger:
	jsr		L_Universal_TriggerHandle			; ͨ�ð�������
	jsr		L_Key_ShutdownLoud					; ������������

	lda		Sys_Status_Flag
	and		#0011B
	beq		Status_NoDisMode_KeyU				; ʱ���Ժ�����U���л�12/24h
	bbr2	Key_Flag,L_DMode_KeyU_ShortTri
	jsr		L_KeyBeep_OFF
	jmp		L_KeyExit							; ��ʾģʽU��������Ч
L_DMode_KeyU_ShortTri:
	smb3	SpecialKey_Flag
	rts
Status_NoDisMode_KeyU:
	bbr2	Key_Flag,KeyU_NoQuikAdd
	rmb3	SpecialKey_Flag
	lda		Sys_Status_Flag
	cmp		#0100B
	bne		StatusCS_No_KeyU_Short
	jmp		AddNum_CS							; ʱ��ģʽ����
StatusCS_No_KeyU_Short:
	cmp		#1000B
	bne		L_KeyUTrigger_Exit
	jmp		AddNum_AS							; ����ģʽ����
KeyU_NoQuikAdd:
	smb3	SpecialKey_Flag
L_KeyUTrigger_Exit:
	rts


L_KeySTrigger:
	jsr		L_Universal_TriggerHandle			; ͨ�ð�������
	jsr		L_Key_ShutdownLoud					; ������������

	lda		Sys_Status_Flag
	and		#0011B
	beq		Status_NoDisMode_KeyS				; �ж��Ƿ�Ϊ��ʾģʽ
	bbr2	Key_Flag,L_DMode_KeyS_ShortTri
	jsr		L_KeyBeep_OFF
	jmp		L_KeyExit							; ��ʾģʽD��������Ч
L_DMode_KeyS_ShortTri:
	smb4	SpecialKey_Flag
	rts
Status_NoDisMode_KeyS:
	bbr2	Key_Flag,KeyS_NoQuikAdd
	rmb4	SpecialKey_Flag
	lda		Sys_Status_Flag
	cmp		#0100B
	bne		StatusCS_No_KeyS
	jmp		SubNum_CS							; ʱ��ģʽ����
StatusCS_No_KeyS:
	cmp		#1000B
	bne		L_KeySTrigger_Exit
	jmp		SubNum_AS							; ����ģʽ����
KeyS_NoQuikAdd:
	smb4	SpecialKey_Flag
L_KeySTrigger_Exit:
	rts


; �������̰˯������
L_Key_ShutdownLoud:
	bbs2	Clock_Flag,?No_AlarmLouding
	jsr		L_CloseLoud							; �������
	pla
	pla
	jmp		L_KeyExit
?No_AlarmLouding:
	rts


; ��������ͨ�ù��ܣ�������������GPIO״̬���ã�������Ļ
; ͬʱ������Ƿ���ڻ����¼�
; ���ڴ��̰˯�����ֵĹ���B��û�У��ʲ��ڱ������ڴ���
L_Universal_TriggerHandle:
	lda		#0
	sta		Return_Counter						; ���÷���ʱ��ģʽ��ʱ

	bbs4	PD,WakeUp_Event						; ����ʱϨ���������ᵼ������
	bbs2	Key_Flag,?Handle_Exit
	rmb5	Time_Flag
	lda		#0
	sta		Backlight_Counter
?Handle_Exit:
	rts
WakeUp_Event:
	rmb4	PD
	smb3	Key_Flag							; Ϩ��״̬�а������򴥷������¼�
	lda		#0
	sta		Sys_Status_Ordinal					; ʱ����ʾģʽ��Ϩ��������ص�ʱ��
	bbr2	Backlight_Flag,No_RFCMesure_KeyDeep	; �ֶ�Ϩ�����������ʪ��
	rmb2	Backlight_Flag
	jsr		F_RFC_MeasureStart					; �Զ�Ϩ�����Ѻ����̽���һ����ʪ�Ȳ���
No_RFCMesure_KeyDeep:
	pla
	pla
	jmp		L_KeyExit							; ���Ѵ������Ǵΰ�����û�а�������
WakeUp_Event_Exit:
	rts




L_KeyBeep_ON:
	lda		#10B								; ���ð�����ʾ������������
	sta		Beep_Serial
	smb4	Key_Flag							; ��λ������ʾ����־
	smb3	Timer_Switch
	rts

L_KeyBeep_OFF:
	lda		#0									; ���������ʾ������������
	sta		Beep_Serial
	rmb4	Key_Flag							; ��λ������ʾ����־
	rmb3	Timer_Switch
	rts



L_KeyDelay:
	lda		#0
	sta		P_Temp
DelayLoop:
	inc		P_Temp
	bne		DelayLoop
	
	rts
