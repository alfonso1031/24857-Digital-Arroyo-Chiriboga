org 100h

; Inicio del programa
inicio:
    mov dx, offset msg_num_students
    mov ah, 9
    int 21h
    call leer_numero
    mov bl, al
    cmp bl, 1
    jb error_num
    cmp bl, 10
    ja error_num
    mov num_students, bl
    jmp ingresar_notas

error_num:
    mov dx, offset msg_error_num
    mov ah, 9
    int 21h
    call nueva_linea
    jmp inicio

ingresar_notas:
    mov cl, num_students
    mov si, 0
    mov byte ptr contador, 0  ; Inicializar contador
    mov word ptr suma, 0
    mov nota_max, 0
    mov nota_min, 20

bucle_estudiantes:
    mov dx, offset msg_grade
    mov ah, 9
    int 21h
    mov al, contador
    inc al                    ; Número del estudiante (contador + 1)
    call imprimir_num_estudiante
    mov dx, offset msg_colon
    mov ah, 9
    int 21h

leer_nota:
    call leer_numero
    mov bl, al
    cmp bl, 20
    ja error_nota
    mov notas[si], bl
    mov ax, 0
    mov al, bl
    add suma, ax
    cmp bl, nota_max
    jbe no_max
    mov nota_max, bl
no_max:
    cmp bl, nota_min
    jae no_min
    mov nota_min, bl
no_min:
    inc si
    inc contador              ; Incrementar contador
    dec cl
    jnz bucle_estudiantes
    jmp calcular_resultados

error_nota:
    mov dx, offset msg_error_nota
    mov ah, 9
    int 21h
    call nueva_linea
    jmp leer_nota

calcular_resultados:
    call nueva_linea

    ; Mostrar promedio
    mov dx, offset msg_promedio
    mov ah, 9
    int 21h
    mov ax, suma
    mov bl, num_students
    xor dx, dx         ; Limpiar dx para división de 16 bits
    div bl             ; al = cociente, ah = residuo
    mov cociente, al
    mov residuo, ah
    mov al, cociente
    call imprimir_dos_digitos  ; Imprimir parte entera
    mov dl, '.'
    mov ah, 2
    int 21h
    ; Calcular decimal
    mov al, residuo
    mov ah, 0          ; Limpiar ah
    mov bl, 10
    mul bl             ; residuo * 10
    div num_students   ; (residuo * 10) / num_students
    mov bl, al
    cmp bl, 10         ; Evitar valores mayores a 9
    jae decimal_cero   ; Etiqueta corregida
    add bl, '0'
    mov dl, bl
    mov ah, 2
    int 21h
    jmp fin_decimal
decimal_cero:          ; Etiqueta corregida
    mov dl, '0'
    mov ah, 2
    int 21h
fin_decimal:
    call nueva_linea

    ; Mostrar nota máxima
    mov dx, offset msg_max
    mov ah, 9
    int 21h
    mov al, nota_max
    call imprimir_dos_digitos
    call nueva_linea

    ; Mostrar nota mínima
    mov dx, offset msg_min
    mov ah, 9
    int 21h
    mov al, nota_min
    call imprimir_dos_digitos
    call nueva_linea

    ; Terminar programa
    mov ah, 4Ch
    int 21h

; Procedimiento para leer un número de dos dígitos
leer_numero PROC
    mov ah, 1
    int 21h            ; Leer primer dígito
    sub al, '0'
    mov bl, al
    mov ah, 1
    int 21h            ; Leer segundo dígito
    sub al, '0'
    mov bh, al
    mov al, bl
    mov bl, 10
    mul bl             ; Primer dígito * 10
    add al, bh         ; Sumar segundo dígito
    ret
leer_numero ENDP

; Procedimiento para imprimir un número en dos dígitos
imprimir_dos_digitos PROC
    mov ah, 0          ; Limpiar ah antes de la división
    mov bl, 10
    div bl             ; al = cociente, ah = residuo
    add al, '0'        ; Convertir decenas a ASCII
    add ah, '0'        ; Convertir unidades a ASCII
    push ax            ; Guardar ax
    mov dl, al
    mov ah, 2
    int 21h            ; Imprimir decenas
    pop ax
    mov dl, ah
    mov ah, 2
    int 21h            ; Imprimir unidades
    ret
imprimir_dos_digitos ENDP

; Procedimiento para imprimir número de estudiante (1-10) - Mejorado
imprimir_num_estudiante PROC
    cmp al, 10
    je mostrar_10
    add al, '0'        ; Convertir a carácter (1-9)
    mov dl, al
    mov ah, 2
    int 21h
    ret
mostrar_10:
    mov dl, '1'
    mov ah, 2
    int 21h
    mov dl, '0'
    int 21h            ; Imprimir "10"
    ret
imprimir_num_estudiante ENDP

; Procedimiento para nueva línea
nueva_linea PROC
    mov dl, 0Dh
    mov ah, 2
    int 21h
    mov dl, 0Ah
    int 21h
    ret
nueva_linea ENDP

; Sección de datos
num_students db 0
contador db 0         ; Nueva variable para el contador
notas db 10 dup(0)
suma dw 0
nota_max db 0
nota_min db 20
cociente db 0
residuo db 0
msg_num_students db 13,10, "Enter number of students (1-10): $"
msg_grade db 13,10, "Ingrese la nota del estudiante $"
msg_colon db ": $"
msg_error_num db 13,10, "El numero debe estar entre 1-10$"
msg_error_nota db 13,10, "La nota debe estar entre 0 y 20$"
msg_promedio db "Promedio: $"
msg_max db "Nota mas alta: $"
msg_min db "Nota mas baja: $"