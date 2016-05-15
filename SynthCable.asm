.include "tn85def.inc" 
rjmp init


.org $000A
	clr r16
	out TCNT0,r16

	tst XL
	breq intEnd


	sub ZL,r5
	sbci ZH,0
	
	dec r7
	brne arpeg0
	mov r7,r8
	
	push ZH
	push ZL
	
	subi r22,1
	brcc mod1
	ldi r22,31
mod1:
	
	ldi ZH, HIGH(modLookup*2)
	ldi ZL,  LOW(modLookup*2)
	
	add ZL, r6
	add ZL, r22
	lpm r5,Z
	
	pop ZL
	pop ZH

arpeg0:
	

	inc r9
	cp r9,r4
	brcs intMod
	clr r9



	cp XL,YL
	brne arpeg1
	clr YL
arpeg1:
	ld r19, Y+
	rcall setNote
	reti
	
intMod:
	clr r17 
	add ZL, r5
	adc ZH, r17
	rcall setNoteLoadb



intEnd:
	reti




init:
	ldi r16, 0b000010
	out DDRB,r16

	ldi r16,0b000100
	out PORTB,r16



	; Stack Pointer Setup Code 
	;ldi r16,HIGH(RAMEND)
	;out SPH,r16
	;ldi r16, LOW(RAMEND)
	;out SPL,r16





	ldi r16,0
	out TCNT0,r16
	ldi r16, (1<<CS02|1<<CS00)	;clk/1024
	out TCCR0B, r16
	ldi r16, 8
	out OCR0A,r16
	ldi r16, (1<<OCIE0A)
	out TIMSK,r16


	ldi r19,1
	out OCR1A,r19


	ldi XH,1
	ldi XL,0
	ldi YH,1
	ldi YL,0

	clr r20
	clr r22
	sbiw Y,1
	st Y+,r20

	ldi r16,64
	mov r3,r16
	ldi r16,45
	mov r4,r16

	ldi r16, 0
	mov r6,r16
	ldi r16,127
	mov r5,r16

	ldi r16,4
	mov r8,r16
	
main:
	sei

	rcall receiveByte

	cpi r20,0b10010000
	breq noteon

	cpi r20,0b10000000
	breq noteoff

	cpi r20,0b10110000
	breq midiCC

	cpi r20,0b11100000
	breq pitchBend

	cpi r20,0b11010000
	breq afterTouch
	
	rjmp main
	

noteon:
	sbrc r18,7
	rcall receiveByte
	mov r19,r18
	rcall receiveByte

	cpi r18,0
	breq noteoffb

	movw Y,X
	st X+, r19

	rcall setNote
	rjmp main




noteoff:
	sbrc r18,7
	rcall receiveByte
	mov r19,r18
	rcall receiveByte
noteoffb:

	movw Y,X

noteOffLook:
	ld r16,-Y
	cp r19,r16
	brne noteOffLook
	
	

noteOffMove:
	ldd r16,Y+1
	st Y+,r16
	cp YL,XL
	brne noteOffMove

	sbiw X,1
	sbiw Y,1
	
	ld r19,-Y
	rcall setNote

	rjmp main



midiCC:
	sbrc r18,7
	rcall receiveByte
	mov r19,r18
	rcall receiveByte
	
	cpi r19,7
	breq setArpegSpeed


	cpi r19,1
	breq setModDepth
	
	cpi r19,5
	breq setModSpeed


	rjmp main


pitchBend:
	sbrc r18,7
	rcall receiveByte
	;mov r19,r18
	rcall receiveByte



	sub ZL,r3
	sbci ZH,0
	mov r3,r18
	;clr r17 ; cleared by receiveByte
	add ZL, r3
	adc ZH, r17
	rcall setNoteLoadb

	rjmp main


afterTouch:
	sbrc r18,7
	rcall receiveByte


setModDepth:
	lsl r18
	andi r18,0b11100000
	mov r6,r18
	rjmp main


setArpegSpeed:
	subi r18,-3
	mov r4,r18
	rjmp main

setModSpeed:
	swap r18
	andi r18,0b00000111
	inc r18
	mov r8,r18
	
	rjmp main



receiveByte:
	
;	ret

	sbic PINB, 2
	rjmp receiveByte
	cli

	ldi r16,32
rbWait1:
	nop
	dec r16
	brne rbWait1

	ldi r17,8
	ldi r18,0

rbBit:
	ldi r16,62
rbWait2:
	clc
	dec r16
	brne rbWait2
	

	nop
	nop

	sbic PINB, 2
	sec
	ror r18
	
	dec r17
	brne rbBit

rbEnd:
	sbis PINB, 2
	rjmp rbEnd

	sbrc r18,7
	mov r20,r18

	ret



	




setNote:
	subi r19, 13
	brcs outputOff
	subi r19, 12
	brcs PC+19
	subi r19, 12
	brcs PC+19
	subi r19, 12
	brcs PC+19
	subi r19, 12
	brcs PC+19
	subi r19, 12
	brcs PC+19
	subi r19, 12
	brcs PC+19
	subi r19, 12
	brcs PC+19
	subi r19, 12
	brcs PC+19
	subi r19,12
	rjmp PC+19

	ldi r17, (1<<COM1A0|1<<CTC1) ; Off
	rjmp setNoteLoad
	ldi r17, (1<<COM1A0|1<<CTC1|1<<CS13|1<<CS11|1<<CS10) ; 1024
	rjmp setNoteLoad
	ldi r17, (1<<COM1A0|1<<CTC1|1<<CS13|1<<CS11) ; 512
	rjmp setNoteLoad
	ldi r17, (1<<COM1A0|1<<CTC1|1<<CS13|1<<CS10) ; 256
	rjmp setNoteLoad
	ldi r17, (1<<COM1A0|1<<CTC1|1<<CS13) ; 128
	rjmp setNoteLoad
	ldi r17, (1<<COM1A0|1<<CTC1|1<<CS12|1<<CS11|1<<CS10) ; 64
	rjmp setNoteLoad
	ldi r17, (1<<COM1A0|1<<CTC1|1<<CS12|1<<CS11) ; 32
	rjmp setNoteLoad
	ldi r17, (1<<COM1A0|1<<CTC1|1<<CS12|1<<CS10) ; 16
	rjmp setNoteLoad
	ldi r17, (1<<COM1A0|1<<CTC1|1<<CS12) ; 8
	rjmp setNoteLoad
	ldi r17, (1<<COM1A0|1<<CTC1|1<<CS10|1<<CS11) ; 4
setNoteLoad:


	subi r19,-12

	ldi ZH, HIGH(noteLookup*2-127+7)
	ldi ZL,  LOW(noteLookup*2-127+7)
	swap r19
	clr r16
	lsl r19
	adc ZH,r16

	add ZL, r19
	adc ZH,r16

	out TCCR1,r17

	add ZL, r3
	adc ZH, r16

	add ZL, r5
	adc ZH, r16

setNoteLoadb:
	lpm r19,Z

	
	out OCR1C,r19

	in r16,TCNT1

	cp r19,r16
	brcc setNoteEnd
	
	
	;dec r19
	ldi r19,(1<<PSR1)
	out GTCCR,r19
	
	
	clr r19
	out TCNT1,r19

setNoteEnd:
	ret


outputOff:
	clr r17
	out TCCR1,r17

	ret


noteLookup:
.db 255,255,254,254,253,253,252,252,251,251,250,250,250,249,249,248,248,247,247,246,246,246,245,245,244,244,243,243,242,242,242,241
.db 241,240,240,239,239,239,238,238,237,237,236,236,236,235,235,234,234,233,233,233,232,232,231,231,230,230,230,229,229,228,228,228
.db 227,227,226,226,226,225,225,224,224,224,223,223,222,222,222,221,221,220,220,220,219,219,218,218,218,217,217,216,216,216,215,215
.db 214,214,214,213,213,213,212,212,211,211,211,210,210,209,209,209,208,208,208,207,207,206,206,206,205,205,205,204,204,203,203,203
.db 202,202,202,201,201,201,200,200,199,199,199,198,198,198,197,197,197,196,196,196,195,195,195,194,194,193,193,193,192,192,192,191
.db 191,191,190,190,190,189,189,189,188,188,188,187,187,187,186,186,186,185,185,185,184,184,184,183,183,183,182,182,182,181,181,181
.db 180,180,180,179,179,179,178,178,178,177,177,177,176,176,176,175,175,175,175,174,174,174,173,173,173,172,172,172,171,171,171,170
.db 170,170,170,169,169,169,168,168,168,167,167,167,167,166,166,166,165,165,165,164,164,164,164,163,163,163,162,162,162,162,161,161
.db 161,160,160,160,159,159,159,159,158,158,158,157,157,157,157,156,156,156,156,155,155,155,154,154,154,154,153,153,153,152,152,152
.db 152,151,151,151,151,150,150,150,149,149,149,149,148,148,148,148,147,147,147,147,146,146,146,145,145,145,145,144,144,144,144,143
.db 143,143,143,142,142,142,142,141,141,141,141,140,140,140,140,139,139,139,139,138,138,138,138,137,137,137,137,136,136,136,136,135
.db 135,135,135,134,134,134,134,133,133,133,133,132,132,132,132,131,131,131,131,131,130,130,130,130,129,129,129,129,128,128,128,128
.db 128,127,127,127,127,126,126,126,126,125,125,125,125,125,124,124,124,124,123,123,123,123,123,122,122,122,122,121,121,121,121,121
.db 120,120,120,120,119,119,119,119,119,118,118,118,118,118,117,117,117,117,116,116,116,116,116,115,115,115,115,115,114,114,114,114
.db 114,113,113,113,113,113,112,112,112,112,112,111,111,111,111,111,110,110,110,110,110,109,109,109,109,109,108,108,108,108,108,107
.db 107,107,107,107,106,106,106,106,106,105,105,105,105,105,105,104,104,104,104,104,103,103,103,103,103,102,102,102,102,102,102,101
.db 101,101,101,101,100,100,100,100,100,100,99,99,99,99,99,98,98,98,98,98,98,97,97,97,97,97,97,96,96,96,96,96



.org 1280
modLookup:
.db 127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127
.db 127,127,127,128,128,128,128,128,128,128,128,128,128,128,127,127,127,127,127,126,126,126,126,126,126,126,126,126,126,126,127,127
.db 127,127,128,128,128,129,129,129,129,129,129,129,128,128,128,127,127,127,126,126,126,125,125,125,125,125,125,125,126,126,126,127
.db 127,128,128,129,129,129,130,130,130,130,130,129,129,129,128,128,127,126,126,125,125,125,124,124,124,124,124,125,125,125,126,126
.db 127,128,129,129,130,130,131,131,131,131,131,130,130,129,129,128,127,126,125,125,124,124,123,123,123,123,123,124,124,125,125,126
.db 127,128,129,130,131,131,132,132,132,132,132,131,131,130,129,128,127,126,125,124,123,123,122,122,122,122,122,123,123,124,125,126
.db 127,128,129,130,131,132,133,133,133,133,133,132,131,130,129,128,127,126,125,124,123,122,121,121,121,121,121,122,123,124,125,126
.db 127,128,130,131,132,133,133,134,134,134,133,133,132,131,130,128,127,126,124,123,122,121,121,120,120,120,121,121,122,123,124,126
