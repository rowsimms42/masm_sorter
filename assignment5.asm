TITLE assignment5.asm    (assignment5.asm)

; Author: Rowan Simmons
; Last Modified: March 3, 2020
; OSU email address: simmonrow@oregonstate.edu
; Course number/section: CS271
; Project Number: 5             Due Date: March 2, 2020
; Description: Create an array, generate random numbers, display array sorted and unsorted, and display median

INCLUDE Irvine32.inc

	;global constants
	ARRAYSIZE = 200
	lo = 10
	hi = 29

.data
	EC			BYTE	"**EC: Derive counts before sorting array, then use counts to sort array.", 0
	intro_1		BYTE	"Sorting and Counting Random Integers			by Rowan Simmons", 0
	intro_2		BYTE	"This program generates 200 random numbers in the range [10,29]. It displays ", 0
	intro_3		BYTE	"the original list, displays the number of instances of each generated value, sorts ", 0
	intro_4		BYTE	"the list, displays the median value, and displays the list sorted in ascending order.", 0
	goodBye		BYTE	"Results certified by Rowan Simmons. Goodbye.", 0
	list_s		BYTE	"Sorted list:",0
	list_u		BYTE	"Unsorted list:",0
	median		BYTE	"List median: ",0
	list_count	BYTE	"List of instances of each generated number, starting with number of 10s:", 0
	spaces		BYTE	"  ",0
	count		DWORD	20
	theArray	DWORD	ARRAYSIZE		DUP(?)
	tempArray	DWORD	ARRAYSIZE		DUP(?)
	counter		DWORD	10
	arrayCounts	DWORD	20 DUP(?)
	sizeCounts	DWORD	20

.code
;***************************************************
; Main Procedure
; description: start program, call procedures
;***************************************************
main PROC
;-----------------------------------intro
	call	Randomize				;random number seed
	push	OFFSET EC				;pass by reference
	push	OFFSET intro_1			;pass by reference
	push	OFFSET intro_2			;pass by reference
	push	OFFSET intro_3			;pass by reference
	push	OFFSET intro_4			;pass by reference
	call	introduction
;-----------------------------------fill array with numbers [10,29]
	push	lo						;pass by value
	push	hi						;pass by value
	push	OFFSET theArray			;pass by reference
	push	ARRAYSIZE				;pass by value
	call	fillArray
;-----------------------------------display unsorted array
	push	count					;pass by value
	push	OFFSET spaces			;pass by reference
	push	OFFSET theArray			;pass by reference
	push	ARRAYSIZE				;pass by value
	push	OFFSET list_u			;pass by reference
	call	displayList
;-----------------------------------sort using count array
	push	OFFSET arrayCounts		;pass by reference
	push	ARRAYSIZE				;pass by value
	push	counter					;pass by value
	push	OFFSET theArray			;pass by reference
	push	OFFSET tempArray		;pass by reference
	call	countList
;-----------------------------------display count array	
	push	count					;pass by value
	push	OFFSET spaces			;pass by reference
	push	OFFSET arrayCounts		;pass by reference
	push	sizeCounts				;pass by value
	push	OFFSET list_count		;pass by reference
	call	displayList				
;-----------------------------------display median
	push	OFFSET median			;pass by reference
	push	OFFSET tempArray		;pass by reference
	push	ARRAYSIZE				;pass by value
	call	displayMedian
;-----------------------------------display the sorted array (ascending order)
	push	count					;pass by value
	push	OFFSET spaces			;pass by reference
	push	OFFSET tempArray		;pass by reference
	push	ARRAYSIZE				;pass by value
	push	OFFSET list_s			;pass by reference
	call	displayList
;-----------------------------------end program
	push	OFFSET goodBye
	call	farewell

	exit	

main ENDP
;***************************************************
;description: start program, call procedures
;receives: string addresses ec, intro_1,2,3,4
;returns: strings ec, intro_1,2,3,4
;pre-condition: string addresses are pushed on stack
;registers changed: edx, ebp
;***************************************************

introduction PROC
;-----------------------------------print out intros

	push	ebp
	mov		ebp, esp

	mov		edx, [ebp+20]
	call	WriteString
	call	CrLf
	call	CrLf

	mov		edx, [ebp+24]
	call	WriteString
	call	CrLf
	call	CrLf

	mov		edx, [ebp+16]
	call	WriteString
	call	CrLf

	mov		edx, [ebp+12]
	call	WriteString
	call	CrLf

	mov		edx, [ebp+8]
	call	WriteString
	call	CrLf
	call	CrLf

	pop		ebp
	ret		20

introduction ENDP

;*********************************************************************
;description: fill array using randomize
;receives: array address, value of hi and lo
;returns: filled array
;pre-condition: array address, value of hi and lo are pushed on stack
;registers changed: edi, ecx, eax, ebp
;*********************************************************************
fillArray PROC
;-----------------------------------initilize stack and array
	push	ebp
	mov		ebp, esp
	mov		edi, [ebp+12]	;@array in edi
	mov		ecx, [ebp+8]	;value of count in ecx
;-----------------------------------get random numbers
getNumbers:
	mov		eax, [ebp+16]			;hi	    
	sub		eax, [ebp+20]			;lo
	inc		eax
	call	RandomRange
	add		eax, [ebp+20]			
;-----------------------------------move number into array, increment array and loop back up
	mov		[edi], eax
	add		edi, 4
	loop	getNumbers
;-----------------------------------restore stack
	pop		ebp
	ret		16

fillArray ENDP

;**************************************************************************
;description: prints arrays (sorted, unsorted, and counts)
;receives: array address, title address, address for spaces and line count
;returns: printed array
;pre-condition: array is filled with random values
;registers changed: esi, ecx, eax, ebp, ebx, edx
;**************************************************************************
displayList PROC

	push	ebp
	mov		ebp, esp
	mov		esi, [ebp+16]				;@array
	mov		edx, [ebp+8]				;title 
	call	WriteString
	call	CrLf
	mov		ebx, 0
	mov		ecx, [ebp+12]				;loop counter for array size
;---------------------------------------;displays array
moreNumbers:
	mov		eax, [esi]
	call	WriteDec
	inc		ebx
	add		esi, 4
	cmp		ebx, [ebp+24]				;20 elements per line
	je		newLine
	mov		edx, [ebp+20]				;2 spaces between elements
	call	WriteString
	loop	moreNumbers
;----------------------------------------print new line
newLine:
	call	CrLf
	mov		ebx, 0
	loop	moreNumbers
	call	CrLf
;----------------------------------------restore stack
	pop		ebp
	ret		20

displayList ENDP

;**************************************************************************************
;description: find number of occurances of each number, and store in array
;receives: size of array, array address, temp array address, and count array address
;returns: full arrays
;pre-condition: array is filled with random values [10,29]
;registers changed: edi, ecx, eax, ebp, ebx, edx, esi
;**************************************************************************************

countList PROC

	push	ebp
	mov		ebp, esp
	mov		edi, [ebp+12]				;@array in edi
	mov		esi, [ebp+8]				;@temp array
	mov		ecx, 0					
	mov		ebx, [ebp+16]
	mov		edx, [ebp+24]				;@count array
	mov		eax, 0
;---------------------------------------loop to check instances of numbers
getN:
	cmp		ebx, [edi]
	jnz		keepGoing
	inc		eax
	mov		[esi], ebx
	add		esi, 4
onWard:
	cmp		ebx, [edi]
	jnz		keepGoing
	inc		eax
	mov		[esi], ebx
	add		esi, 4
;---------------------------------------go to next element in array and loop back up
keepGoing:
	inc		ecx
	add		edi, 4
	cmp		ecx, 200
	je		endOfArray
	jmp		onWard
endOfArray:
	mov		[edx], eax					;fill count array
	add		edx, 4						;go to next spot in count array
	mov		eax, 0
	inc		ebx
	cmp		ebx, 30				
	je		finished					;range is [10,29], so terminates when out of range
	mov		edi, [ebp+12]				;@array back in edi to start from beginning
	mov		ecx, 0						;reset counter
	jmp		onWard
;---------------------------------------restore stack
finished:
	pop		ebp
	ret		20

countList ENDP

;**************************************************************************
;description: prints median
;receives: temp array address, title, size of array
;returns: median 
;pre-condition: array has been sorted into temp array
;registers changed: esi, edx, ebx, eax, ebp
;**************************************************************************

displayMedian PROC

	push	ebp
	mov		ebp, esp
	mov		esi, [ebp+12]
;------------------------------------find size of array/2
	mov		eax, [ebp+8]			 ;size of array
	mov		ebx, 2
	mov		edx, 0
	div		ebx
;------------------------------------account for index
	mov		ebx, 4
	mul		ebx
	add		esi, eax
	mov		eax, [esi]
	mov		edx, [ebp+16]			 ;display title
	call	WriteString
	call	writeDec
	call	CrLf
	call	CrLf
;------------------------------------restore stack
	pop		ebp
	ret		12

displayMedian ENDP

;**************************************************************************
;description: says goodble
;receives: address for goodbye text
;registers changed: ebp, edx
;**************************************************************************

farewell PROC
	push	ebp
	mov		ebp, esp

	mov		edx, [ebp+8]			;@goodbye
	call	WriteString
	call	CrLf

	pop		ebp
	ret		4

farewell ENDP

END main
