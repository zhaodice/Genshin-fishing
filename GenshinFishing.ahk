﻿#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, ignore
#Persistent
SetBatchLines, -1

update_log:="
(

> 增加了 2560x1080 分辨率支持
> Added support for 2560x1440 resolution

)"

if A_IsCompiled
debug:=0
Else
debug:=1

version:="0.2.3"
if A_Args.Length() > 0
{
	for n, param in A_Args
	{
		RegExMatch(param, "--out=(\w+)", outName)
		if(outName1=="version") {
			f := FileOpen("version.txt","w")
			f.Write(version)
			f.Close()
			ExitApp
		}
	}
}


#Include menu.ahk

UAC()
#include notice.ahk

IniRead, logLevel, setting.ini, update, log, 0
IniRead, lastUpdate, setting.ini, update, last, 0
IniRead, autoUpdate, setting.ini, update, autoupdate, 1
IniRead, updateMirror, setting.ini, update, mirror, fastgit
IniWrite, % updateMirror, setting.ini, update, mirror
IniRead, debugmode, setting.ini, update, debug, 0
Gosub, log_init
log("Start at " A_YYYY "-" A_MM "-" A_DD)
today:=A_MM . A_DD
IfExist, updater.exe
{
	FileDelete, updater.exe
}
if(autoUpdate) {
	if(lastUpdate!=today) {
		log("Getting Update",0)
		update()
	} else {
		IniRead, version_str, setting.ini, update, ver, "0"
		if(version_str!=version) {
			IniWrite, % version, setting.ini, update, ver
			MsgBox, % version "`nUpdate log`n更新日志`n`n" update_log
		}
	}
} else {
	log("Update Skiped",0)
	; MsgBox,,Update,Update Skiped`n跳过升级`n`nCurrent version`n当前版本`nv%version%,2
}

ttm("Genshin Fishing automata Start`nv" version "`n原神钓鱼人偶启动")

img_list:=Object("bar",Object("filename","bar.png")
,"casting",Object("filename","casting.png")
,"cur",Object("filename","cur.png")
,"left",Object("filename","left.png")
,"ready",Object("filename","ready.png")
,"reel",Object("filename","reel.png")
,"right",Object("filename","right.png"))
; for k, v in img_list
; {
; 	pBitmap := Gdip_CreateBitmapFromFile( v.path )
; 	v.w:= Gdip_GetImageWidth( pBitmap )
; 	v.h:= Gdip_GetImageHeight( pBitmap )
; 	Gdip_DisposeImage( pBitmap )
; 	msgbox, % k "`n" v.path "`nw[" v.w "]`nh[" v.h "]"
; }

; #Include, Gdip_ImageSearch.ahk
; #Include, Gdip.ahk
; pToken := Gdip_Startup()

#include, fileinstalls.ahk


DllCall("QueryPerformanceFrequency", "Int64P", freq)
freq/=1000
CoordMode, Pixel, Client
state:="unknown"
statePredict:="unknown"
stateUnknownStart:=0
isResolutionValid:=0
OnExit, exit
SetTimer, main, -100
Return

log_init:
pLogfile:=FileOpen("genshinfishing.log", "a")
Return

log(txt,level=0)
{
	global logLevel, pLogfile
	if(logLevel >= level) {
		pLogfile.WriteLine(A_Hour ":" A_Min ":" A_Sec "." A_MSec "[" level "]:" txt)
	}
}

genshin_window_exist()
{
	genshinHwnd := WinExist("ahk_exe GenshinImpact.exe")
	if not genshinHwnd
	{
		genshinHwnd := WinExist("ahk_exe YuanShen.exe")
	}
	return genshinHwnd
}

ttm(txt, delay=1500)
{
	ToolTip, % txt
	SetTimer, kttm, % -delay
	Return
	kttm:
	ToolTip,
	Return
}

tt(txt, delay=2000)
{
	ToolTip, % txt, 1, 1
	SetTimer, ktt, % -delay
	Return
	ktt:
	ToolTip,
	Return
}
; 图标位置
; 右下角 w 82.5% h 87.5%
; Bar
; w 25%~75%
; h 0%~30%
; 浮漂
; w 25%~75%
; h 由 bar 参数 barY-10 ~ barY+30

genshin_hwnd := genshin_window_exist()
if(genshin_hwnd)
{
	; pBitmap:=Gdip_BitmapFromHWND(genshin_hwnd)
	; Gdip_SaveBitmapToFile(pBitmap, "output.jpg")
	; MsgBox, DONE

	; hdc := GetDC(genshin_hwnd)
	; CreateCompatibleDC(hdc)
	; Gdip_GraphicsFromHDC
	; Gdip_CreateBitmapFromHBITMAP
	; Gdip_SetBitmapToClipboard
}

getClientSize(hWnd, ByRef w := "", ByRef h := "")
{
	VarSetCapacity(rect, 16, 0)
	DllCall("GetClientRect", "ptr", hWnd, "ptr", &rect)
	w := NumGet(rect, 8, "int")
	h := NumGet(rect, 12, "int")
}

dLinePt(p)
{
	global dLine
	return Ceil(p*dLine)
}

getState:
; k:=(((winW**2)+(winH**2))**0.5)/(((1920**2)+(1080**2))**0.5)
ImageSearch, iconX, iconY, winW-dLinePt(0.167), winH-dLinePt(0.084), winW, winH, % "*32 *TransFuchsia " A_Temp "/genshinfishing/" winW winH "/" img_list.ready.filename
if(!ErrorLevel){
	state:="ready"
	statePredict:=state
	stateUnknownStart := 0
	log("state->" statePredict, 1)
	return
}
ImageSearch, iconX, iconY, winW-dLinePt(0.167), winH-dLinePt(0.084), winW, winH, % "*32 *TransFuchsia " A_Temp "/genshinfishing/" winW winH "/" img_list.reel.filename
if(!ErrorLevel){
	state:="reel"
	statePredict:=state
	stateUnknownStart := 0
	log("state->" statePredict, 1)
	return
}
ImageSearch, iconX, iconY, winW-dLinePt(0.167), winH-dLinePt(0.084), winW, winH, % "*32 *TransFuchsia " A_Temp "/genshinfishing/" winW winH "/" img_list.casting.filename
if(!ErrorLevel){
	state:="casting"
	statePredict:=state
	stateUnknownStart := 0
	log("state->" statePredict, 1)
	return
}
state:="unknown"
if(stateUnknownStart == 0) {
	stateUnknownStart := A_TickCount
}
if(statePredict!="unknown" && A_TickCount - stateUnknownStart>=2000){
	statePredict:="unknown"
	; Click, Up
	log("state->" statePredict, 1)
}
Return

main:
genshin_hwnd := genshin_window_exist()
if(!genshin_hwnd){
	SetTimer, main, -800
	Return
}
if(WinExist("A") != genshin_hwnd)
{
	SetTimer, main, -500
	Return
}
getClientSize(genshin_hwnd, winW, winH)

if(oldWinW!=winW || oldWinH!=winH) {
	log("Get dimension=" winW "x" winH,1)
	if(InStr(FileExist(A_Temp "/genshinfishing/" winW winH), "D")) {
		fileCount:=0
		for k, v in img_list
		{
			if(FileExist(A_Temp "/genshinfishing/" winW winH "/" v.filename)) {
				fileCount += 1
			}
		}
		if(fileCount < img_list.Count()) {
			isResolutionValid:=0
		} else {
			isResolutionValid:=1
			dline:=Ceil(((winW**2)+(winH**2))**0.5)
			barR_left:=dLinePt(0.27)
			barR_top:=dLinePt(0.03)
			barR_right:=dLinePt(0.59)
			barR_bottom:=dLinePt(0.1)
			
			delta_left:=dLinePt(0.025)
			delta_top:=dLinePt(0.005)
			delta_right:=dLinePt(0.035)
			delta_bottom:=dLinePt(0.014)

			barS_left:=dLinePt(0.22)
			barS_right:=dLinePt(0.64)
		}
	} else {
		isResolutionValid:=0
	}
}
oldWinW:=winW
oldWinH:=winH
if(!isResolutionValid) {
	tt("Unsupported resolution`n不支持的分辨率`n" winW "x" winH)
	SetTimer, main, -800
	Return
}

if(statePredict=="unknown" || statePredict=="ready")
{
	Gosub, getState
	if(statePredict!="unknown" && debugmode){
		tt("state = " state "`nstatePredict = " statePredict "`n" winW "," winH)
	}
	if(statePredict=="reel"){
		SetTimer, main, -40
	} else {
		barY := 0
		SetTimer, main, -800
	}
	Return
} else if(statePredict=="casting") {
	Gosub, getState
	if(debugmode){
		tt("state = " statePredict)
	}
	if(statePredict=="reel") {
		Click, Down
		SetTimer, main, -40
	} else{
		SetTimer, main, -200
	}
	Return
} else if(statePredict=="reel") {
	DllCall("QueryPerformanceCounter", "Int64P",  startTime)
	if(barY<2) {
		ImageSearch, _, barY, barR_left, barR_top, barR_right, barR_bottom, % "*20 *TransFuchsia " A_Temp "/genshinfishing/" winW winH "/" img_list.bar.filename
		if(ErrorLevel){
			if(barY == 0) {
				barY := 1
				Click, Down
			} else if(barY == 1) {
				barY := 0
				Click, Up
			}
		} else {
			Click, Up
			avrDetectTime:=[]
			leftX:=0
			rightX:=0
			curX:=0
			log("get barY=" barY,2)
		}
		DllCall("QueryPerformanceCounter", "Int64P",  endTime)
	} else {
		if(leftX > 0) {
			ImageSearch, leftX, leftY, leftX-delta_left, barY-delta_top, leftX+delta_right, barY+delta_bottom, % "*16 *TransFuchsia " A_Temp "/genshinfishing/" winW winH "/" img_list.left.filename
		} else {
			ImageSearch, leftX, leftY, barS_left, barY-delta_top, barS_right, barY+delta_bottom, % "*16 *TransFuchsia " A_Temp "/genshinfishing/" winW winH "/" img_list.left.filename
		}
		if(ErrorLevel){
			leftX := 0
			leftY := "Null"
		} else {
			leftPredictX := 2*leftX - leftXOld
			leftXOld := leftX
		}
		
		if(rightX > 0) {
			ImageSearch, rightX, rightY, rightX-delta_left, barY-delta_top, rightX+delta_right, barY+delta_bottom, % "*16 *TransFuchsia " A_Temp "/genshinfishing/" winW winH "/" img_list.right.filename
		} else {
			ImageSearch, rightX, rightY, barS_left, barY-delta_top, barS_right, barY+delta_bottom, % "*16 *TransFuchsia " A_Temp "/genshinfishing/" winW winH "/" img_list.right.filename
		}
		if(ErrorLevel){
			rightX := 0
			rightY := "Null"
		} else {
			rightPredictX := 2*rightX - rightXOld
			rightXOld := rightX
		}

		if(curX > 0) {
			ImageSearch, curX, curY, curX-delta_left, barY-delta_top, curX+delta_right, barY+delta_bottom, % "*16 *TransFuchsia " A_Temp "/genshinfishing/" winW winH "/" img_list.cur.filename
		} else {
			ImageSearch, curX, curY, barS_left, barY-delta_top, barS_right, barY+delta_bottom, % "*16 *TransFuchsia " A_Temp "/genshinfishing/" winW winH "/" img_list.cur.filename
		}
		if(ErrorLevel){
			curX := 0
			curY := "Null"
		} else {
			curPredictX := 2*curX - curXOld
			curXOld := curX
		}
		if(leftY == "Null" && rightY == "Null" && curY == "Null") {
			Gosub, getState
			Click, Up
		} else {
			if(leftX+rightX < leftXOld+rightXOld) {
				k := 0.2
			} else if(leftX+rightX > leftXOld+rightXOld) {
				k:= 0.8
			} else {
				k = 0.4
			}
			if(curPredictX<(k*rightPredictX + (1-k)*leftPredictX)){
				Click, Down
			} else {
				Click, Up
			}
		}
		DllCall("QueryPerformanceCounter", "Int64P",  endTime)

		detectTime:=(endTime-startTime)//freq
		if(avrDetectTime.Length()<8){
			avrDetectTime.Push(detectTime)
		} else {
			avrDetectTime.Pop()
			avrDetectTime.Push(detectTime)
		}
		sum := 0
		For index, value in avrDetectTime
			sum += value

		avrDetectMs := sum//avrDetectTime.Length()

		log("dt=" detectTime "ms`tleftX="leftX "`trightX="rightX "`t" "curX="curX "`tleftXpre="leftPredictX "`trightXpre="rightPredictX "`tcurXpre="curPredictX,2)
		if(debugmode){
			tt("barY = " barY "`n" "leftX = " leftX "`n" "rightX = " rightX "`n" "curX = " curX "`n" "barMove = " (leftX+rightX)-(leftXOld+rightXOld) "`n" state "`n" avrDetectMs "ms")
		}
	}
	lastTime:=(endTime-startTime)//freq
	if(lastTime>60) {
		SetTimer, main, -10
	} else {
		SetTimer, main, % lastTime-70
	}
	Return
}

Return

donate:
Run, https://ko-fi.com/xianii
Return
pages:
Run, https://github.com/Nigh/Genshin-fishing
Return
exit:
pLogfile.Close()
ExitApp
donothing:
Return

#If debug
F5::ExitApp
F6::Reload
#If

update(){
	global
	req := ComObjCreate("MSXML2.ServerXMLHTTP")
	if(updateMirror=="fastgit") {
		updateSite:="https://download.fastgit.org"
	} else if(updateMirror=="cnpmjs") {
		updateSite:="https://github.com.cnpmjs.org"
	} else {
		updateSite:="https://github.com"
	}
	req.open("GET", updateSite "/Nigh/Genshin-fishing/releases/latest/download/version.txt", true)
	req.onreadystatechange := Func("updateReady")
	req.send()
}

; with MSXML2.ServerXMLHTTP method, there would be multiple callback called
updateReqDone:=0
updateReady(){
	global req, version, updateReqDone, updateSite
	log("update req.readyState=" req.readyState, 1)
    if (req.readyState != 4){  ; Not done yet.
        return
	}
	if(updateReqDone){
		log("state already changed", 1)
		Return
	}
	updateReqDone := 1
	log("update req.status=" req.status, 1)
    if (req.status == 200){ ; OK.
        ; MsgBox % "Latest version: " req.responseText
		RegExMatch(version, "(\d+)\.(\d+)\.(\d+)", verNow)
		RegExMatch(req.responseText, "(\d+)\.(\d+)\.(\d+)", verNew)
		if(verNow1*10000+verNow2*100+verNow3<verNew1*10000+verNew2*100+verNew3) {
			MsgBox, 0x24, Download, % "Found new version " req.responseText ", download?`n`n发现新版本 " req.responseText " 是否下载?"
			IfMsgBox Yes
			{
				UrlDownloadToFile, % updateSite "/Nigh/Genshin-fishing/releases/latest/download/GenshinFishing.zip", ./GenshinFishing.zip
				if(ErrorLevel) {
					log("Err[" ErrorLevel "]Download failed", 0)
					MsgBox, 16,, % "Err" ErrorLevel "`n`nDownload failed`n下载失败"
				} else {
					MsgBox, ,, % "File saved as GenshinFishing.zip`n更新下载完成 GenshinFishing.zip`n`nProgram will restart now`n软件即将重启", 3
					IniWrite, % A_MM A_DD, setting.ini, update, last
					FileInstall, updater.exe, updater.exe, 1
					Run, updater.exe
					ExitApp
				}
			}
		} else {
			; MsgBox, ,, % "Current version: v" version "`n`nIt is the latest version`n`n软件已是最新版本", 2
			IniWrite, % A_MM A_DD, setting.ini, update, last
		}
	} else {
        MsgBox, 16,, % "Update failed`n`n更新失败`n`nStatus=" req.status
	}
}

UAC()
{
	full_command_line := DllCall("GetCommandLine", "str")
	if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
	{
		try
		{
			if A_IsCompiled
				Run *RunAs "%A_ScriptFullPath%" /restart
			else
				Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
		}
		ExitApp
	}
}
