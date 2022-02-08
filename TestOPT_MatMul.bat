@echo off
set TEST_DIR=Dataset\Test\
set APP=OPT_MatMul\x64\Release\OPT_MatMul.exe
set PRT=ON
set LOGFILE=MarkOPT.log
DEL /S %TEST_DIR%*myOutput.raw
call :LOG > %LOGFILE%
exit /B

:LOG 

echo %DATE%
echo %TIME%
echo OPT MatMul Testing Test 0...
set TEST=%TEST_DIR%0\

%APP%  %TEST%output.raw %TEST%input0.raw %TEST%input1.raw %TEST%myOutput.raw %PRT%

echo OPT MatMul Testing Test 1...
set TEST=%TEST_DIR%1\

%APP%  %TEST%output.raw %TEST%input0.raw %TEST%input1.raw %TEST%myOutput.raw %PRT%

echo OPT MatMul Testing Test 2...
set TEST=%TEST_DIR%2\

%APP%  %TEST%output.raw %TEST%input0.raw %TEST%input1.raw %TEST%myOutput.raw %PRT%

echo OPT MatMul Testing Test 3...
set TEST=%TEST_DIR%3\

%APP%  %TEST%output.raw %TEST%input0.raw %TEST%input1.raw %TEST%myOutput.raw %PRT%

echo OPT MatMul Testing Test 4...
set TEST=%TEST_DIR%4\

%APP%  %TEST%output.raw %TEST%input0.raw %TEST%input1.raw %TEST%myOutput.raw %PRT%

echo OPT MatMul Testing Test 5...
set TEST=%TEST_DIR%5\

%APP%  %TEST%output.raw %TEST%input0.raw %TEST%input1.raw %TEST%myOutput.raw %PRT%

echo OPT MatMul Testing Test 6...
set TEST=%TEST_DIR%6\

%APP%  %TEST%output.raw %TEST%input0.raw %TEST%input1.raw %TEST%myOutput.raw %PRT%

echo OPT MatMul Testing Test 7...
set TEST=%TEST_DIR%7\

%APP%  %TEST%output.raw %TEST%input0.raw %TEST%input1.raw %TEST%myOutput.raw %PRT%

echo OPT MatMul Testing Test 8...
set TEST=%TEST_DIR%8\

%APP%  %TEST%output.raw %TEST%input0.raw %TEST%input1.raw %TEST%myOutput.raw %PRT%

echo OPT MatMul Testing Test 9...
set TEST=%TEST_DIR%9\

%APP%  %TEST%output.raw %TEST%input0.raw %TEST%input1.raw %TEST%myOutput.raw %PRT%

@echo on