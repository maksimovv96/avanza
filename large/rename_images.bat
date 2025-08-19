@echo off
setlocal enabledelayedexpansion
set FILE_TYPE=jpg
set INDEX_FILE=rename_index.txt

REM Шаг 1: Создаем индексный файл с правильным порядком сортировки
(
    for %%f in (*.%FILE_TYPE%) do (
        set "name=%%~nf"
        
        REM Извлекаем числовую часть из имени (последнюю группу цифр)
        set "num="
        set "is_num=0"
        for /f "delims=" %%c in ('cmd /u /c echo "!name!"^| find /v ""') do (
            set "char=%%c"
            if "!char!" geq "0" if "!char!" leq "9" (
                set /a "is_num=1"
                set "num=!num!!char!"
            ) else if !is_num! equ 1 (
                set "num="
                set "is_num=0"
            )
        )
        
        REM Если не нашли число, используем 0
        if "!num!"=="" set "num=0000000000"
        
        REM Форматируем число с ведущими нулями
        set "num=0000000000!num!"
        set "num=!num:~-10!"
        
        echo !num!;"%%f"
    )
) > unsorted.txt

REM Сортируем по числовой части
sort /r unsorted.txt > %INDEX_FILE%
del unsorted.txt

REM Шаг 2: Переименовываем файлы во временные имена
set COUNT=1000000001
for /f "tokens=2 delims=;" %%f in (%INDEX_FILE%) do (
    ren "%%~f" "tmp_!COUNT!.%FILE_TYPE%"
    set /a COUNT+=1
)

REM Шаг 3: Переименовываем в окончательные имена
set COUNT=1
for /f "tokens=*" %%f in ('dir /b /a-d tmp_*.%FILE_TYPE% 2^>nul ^| sort') do (
    ren "%%f" "!COUNT!.%FILE_TYPE%"
    set /a COUNT+=1
)

REM Удаляем временные файлы
del %INDEX_FILE% 2>nul
echo Files successfully renamed to sequential numbers: 1, 2, 3...
pause