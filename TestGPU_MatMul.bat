@echo off
set TEST_DIR=Dataset\Test\
set APP=GPU_MatMul\x64\Release\GPU_MatMul.exe
set PRT=ON
set LOGFILE=MarkGPU.log
DEL /S %TEST_DIR%*myOutput.raw
call :LOG > %LOGFILE%
exit /B

:LOG 

echo %DATE%
echo %TIME%
echo GPU MatMul Testing Test 0...
set TEST=%TEST_DIR%0\

%APP%  %TEST%output.raw %TEST%input0.raw %TEST%input1.raw %TEST%myOutput.raw %PRT%

echo GPU MatMul Testing Test 1...
set TEST=%TEST_DIR%1\

%APP%  %TEST%output.raw %TEST%input0.raw %TEST%input1.raw %TEST%myOutput.raw %PRT%

echo GPU MatMul Testing Test 2...
set TEST=%TEST_DIR%2\

%APP%  %TEST%output.raw %TEST%input0.raw %TEST%input1.raw %TEST%myOutput.raw %PRT%

echo GPU MatMul Testing Test 3...
set TEST=%TEST_DIR%3\

%APP%  %TEST%output.raw %TEST%input0.raw %TEST%input1.raw %TEST%myOutput.raw %PRT%

echo GPU MatMul Testing Test 4...
set TEST=%TEST_DIR%4\

%APP%  %TEST%output.raw %TEST%input0.raw %TEST%input1.raw %TEST%myOutput.raw %PRT%

echo GPU MatMul Testing Test 5...
set TEST=%TEST_DIR%5\

%APP%  %TEST%output.raw %TEST%input0.raw %TEST%input1.raw %TEST%myOutput.raw %PRT%

echo GPU MatMul Testing Test 6...
set TEST=%TEST_DIR%6\

%APP%  %TEST%output.raw %TEST%input0.raw %TEST%input1.raw %TEST%myOutput.raw %PRT%

echo GPU MatMul Testing Test 7...
set TEST=%TEST_DIR%7\

%APP%  %TEST%output.raw %TEST%input0.raw %TEST%input1.raw %TEST%myOutput.raw %PRT%

echo GPU MatMul Testing Test 8...
set TEST=%TEST_DIR%8\

%APP%  %TEST%output.raw %TEST%input0.raw %TEST%input1.raw %TEST%myOutput.raw %PRT%

echo GPU MatMul Testing Test 9...
set TEST=%TEST_DIR%9\

%APP%  %TEST%output.raw %TEST%input0.raw %TEST%input1.raw %TEST%myOutput.raw %PRT%

@echo on