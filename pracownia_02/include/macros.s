.macro load_word regh, regl, value
	ldi \regl\(), lo8(\value)
	ldi \regh\(), hi8(\value)
.endm

.macro load_register_8 reg, value
	ldi r16, \value
	sts \reg\(), r16
.endm

.macro load_register_16 regh, regl, value
	ldi r16, lo8(\value)
	sts \regl\(), r16
	ldi r16, hi8(\value)
	sts \regh\(), r16
.endm

.macro load_register_X value
	ldi r26, lo8(\value)
	ldi r27, hi8(\value)
.endm

.macro load_register_Y value
	ldi r28, lo8(\value)
	ldi r29, hi8(\value)
.endm

.macro load_register_Z value
	ldi r30, lo8(\value)
	ldi r31, hi8(\value)
.endm

.macro cpi16 regh, regl, value
	cpi \regl\(), lo8(\value)
	ldi r16, hi8(\value)
	cpc \regh\(), r16
.endm

.macro sub16 regh, regl, value
	ldi r16, \value
	sub \regl\(), r16
	ldi r16, 0
	sbc \regh\(), r16
.endm
