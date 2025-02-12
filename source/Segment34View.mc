import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;
import Toybox.Application;
import Toybox.Weather;
import Toybox.Time;
import Toybox.Math;
import Toybox.SensorHistory;
import Toybox.Position;
import Toybox.Complications;

const INTEGER_FORMAT = "%d";

class Segment34View extends WatchUi.WatchFace {

    private var isSleeping = false;
    private var doesPartialUpdate = false;
    private var lastUpdate = null;
    private var canBurnIn = false;
    private var screenHeight = 0;
    private var previousEssentialsVis = null;
    private var batt = 0;
    private var stress = 0;
    private var weatherCondition = null;

    private var secondsFont = null;
    private var dSecondsLabel = null;
    private var dAodPattern = null;
    private var dGradient = null;
    private var dAodDateLabel = null;
    private var dTimeLabel = null;
    private var dDateLabel = null;
    private var dTimeBg = null;
    private var dTtrBg = null;
    private var dHrBg = null;
    private var dActiveBg = null;
    private var dTtrDesc = null;
    private var dHrDesc = null;
    private var dActiveDesc = null;
    private var dMoonLabel = null;
    private var dDusk = null;
    private var dDawn = null;
    private var dSunUpLabel = null;
    private var dSunDownLabel = null;
    private var dWeatherLabel1 = null;
    private var dWeatherLabel2 = null;
    private var dNotifLabel = null;
    private var dTtrLabel = null;
    private var dActiveLabel = null;
    private var dStepBg = null;
    private var dStepLabel = null;
    private var dBattLabel = null;
    private var dBattBg = null;
    private var dHrLabel = null;

    private var propColorTheme = null;
    private var propBatteryVariant = null;
    private var propShowSeconds = null;
    private var propMiddleValueShows = null;
    private var propAlwaysShowSeconds = null;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
        cacheDrawables(dc);
        cacheProps();
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        updateWeather();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        var clockTime = System.getClockTime();
        var now = Time.now().value();
        var updateEverything = false;

        if(doesPartialUpdate) {
            dc.clearClip();
            doesPartialUpdate = false;
        }

        if(lastUpdate == null or now - lastUpdate > 30 or clockTime.sec % 60 == 0) {
            updateEverything = true;
            canBurnIn = System.getDeviceSettings().requiresBurnInProtection;
            lastUpdate = now;

            if(clockTime.min % 5 == 0) {
                updateWeather();
            }
        }

        toggleNonEssentials(!isSleeping, dc);

        if(!isSleeping && !updateEverything) {
            if(propShowSeconds) {
                setSeconds(dc);
            }
            if(clockTime.sec % 5 == 0 and propMiddleValueShows == 10) {
                setHR(dc);
            }
        }

        if(updateEverything) {
            setClock(dc);
            setDate(dc);
            if(!isSleeping or !canBurnIn) {
                setSeconds(dc);
                setHR(dc);
                setNotif(dc);
                setMoon(dc);
                setWeather(dc);
                setWeatherLabel();
                setSunUpDown(dc);
                setStep(dc);
                setTraining(dc);
                setBatt(dc);
                updateStressAndBodyBatteryData();
            }
        }

        View.onUpdate(dc);
        if(!isSleeping or !canBurnIn) {
            drawStressAndBodyBattery(dc);
        }
    }

    function onPartialUpdate(dc) {
        if(canBurnIn) { return; }
        if(!propAlwaysShowSeconds) { return; }
        doesPartialUpdate = true;

        var clockTime = System.getClockTime();
        var secString = Lang.format("$1$", [clockTime.sec.format("%02d")]);

        var clipX = 0;
        var clipY = 0;
        var clipWidth = 0;
        var clipHeight = 0;

        if(screenHeight == 240) {
            clipX = 205;
            clipY = 157;
            clipWidth = 24;
            clipHeight = 20;
        } else if(screenHeight == 260) {
            clipX = 220;
            clipY = 162;
            clipWidth = 24;
            clipHeight = 20;
        } else if(screenHeight == 280) {
            clipX = 235;
            clipY = 170;
            clipWidth = 24;
            clipHeight = 20;
        } else if(screenHeight > 280) {
            return;
        }

        dc.setClip(clipX, clipY, clipWidth, clipHeight);
        dc.setColor(0x000000, 0x000000);
        dc.clear();
        dc.setColor(getColor("dateDisplay"), Graphics.COLOR_TRANSPARENT);
        dc.drawText(clipX, clipY, secondsFont, secString, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function onSettingsChanged() {
        lastUpdate = null;
        previousEssentialsVis = null;
        cacheProps();
        WatchUi.requestUpdate();
    }

    function onPowerBudgetExceeded() {
        System.println("Power budget exceeded");
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        isSleeping = false;
        lastUpdate = null;
        cacheProps();
        WatchUi.requestUpdate();
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        isSleeping = true;
        lastUpdate = null;
        WatchUi.requestUpdate();
    }

    hidden function cacheDrawables(dc) as Void {
        screenHeight = dc.getHeight();
        if(screenHeight == 240 or screenHeight == 260 or screenHeight == 280) {
            secondsFont = Application.loadResource( Rez.Fonts.id_led_small );
        }

        dSecondsLabel = View.findDrawableById("SecondsLabel") as Text;
        dAodPattern = View.findDrawableById("aodPattern") as Drawable;
        dGradient = View.findDrawableById("gradient") as Drawable;
        dAodDateLabel = View.findDrawableById("AODDateLabel") as Text;
        dTimeLabel = View.findDrawableById("TimeLabel") as Text;
        dDateLabel = View.findDrawableById("DateLabel") as Text;
        dTimeBg = View.findDrawableById("TimeBg") as Text;
        dTtrBg = View.findDrawableById("TTRBg") as Text;
        dHrBg = View.findDrawableById("HRBg") as Text;
        dActiveBg = View.findDrawableById("ActiveBg") as Text;
        dTtrDesc = View.findDrawableById("TTRDesc") as Text;
        dHrDesc = View.findDrawableById("HRDesc") as Text;
        dActiveDesc = View.findDrawableById("ActiveDesc") as Text;
        dMoonLabel = View.findDrawableById("MoonLabel") as Text;
        dDusk = View.findDrawableById("Dusk") as Text;
        dDawn = View.findDrawableById("Dawn") as Text;
        dSunUpLabel = View.findDrawableById("SunUpLabel") as Text;
        dSunDownLabel = View.findDrawableById("SunDownLabel") as Text;
        dWeatherLabel1 = View.findDrawableById("WeatherLabel1") as Text;
        dWeatherLabel2 = View.findDrawableById("WeatherLabel2") as Text;
        dNotifLabel = View.findDrawableById("NotifLabel") as Text;
        dTtrLabel = View.findDrawableById("TTRLabel") as Text;
        dActiveLabel = View.findDrawableById("ActiveLabel") as Text;
        dStepBg = View.findDrawableById("StepBg") as Text;
        dStepLabel = View.findDrawableById("StepLabel") as Text;
        dBattLabel = View.findDrawableById("BattLabel") as Text;
        dBattBg = View.findDrawableById("BattBg") as Text;
        dHrLabel = View.findDrawableById("HRLabel") as Text;
        
    }

    hidden function cacheProps() as Void {
        propColorTheme = Application.Properties.getValue("colorTheme");
        propBatteryVariant = Application.Properties.getValue("batteryVariant");
        propShowSeconds = Application.Properties.getValue("showSeconds");
        propMiddleValueShows = Application.Properties.getValue("middleValueShows");
        propAlwaysShowSeconds = Application.Properties.getValue("alwaysShowSeconds");
    }

    hidden function toggleNonEssentials(visible, dc){
        if(!visible and canBurnIn) {
            dc.setAntiAlias(false);
            var clockTime = System.getClockTime();
            dGradient.setVisible(false);
            dAodPattern.setVisible(true);
            dAodDateLabel.setVisible(true);
            dAodPattern.setLocation(clockTime.min % 2, dAodPattern.locY);
            dAodDateLabel.setLocation(Math.floor(dc.getWidth() / 2) - 1 + clockTime.min % 3, dAodDateLabel.locY);
            dAodDateLabel.setColor(getColor("dateDisplayDim"));
        }

        if(previousEssentialsVis == visible) {
            return;
        }

        var hideInAOD = (visible or !canBurnIn);
        var hideBattery = (hideInAOD && propBatteryVariant != 2);  

        if(propAlwaysShowSeconds and propShowSeconds and !canBurnIn) {
            dSecondsLabel.setVisible(true);
        } else {
            dSecondsLabel.setVisible(visible && propShowSeconds);
        }

        dHrLabel.setVisible(hideInAOD);
        dDateLabel.setVisible(hideInAOD);
        dTimeBg.setVisible(hideInAOD);
        dTtrBg.setVisible(hideInAOD);
        dHrBg.setVisible(hideInAOD);
        dActiveBg.setVisible(hideInAOD);
        dTtrDesc.setVisible(hideInAOD);
        dHrDesc.setVisible(hideInAOD);
        dActiveDesc.setVisible(hideInAOD);
        dMoonLabel.setVisible(hideInAOD);
        dDusk.setVisible(hideInAOD);
        dDawn.setVisible(hideInAOD);
        dSunUpLabel.setVisible(hideInAOD);
        dSunDownLabel.setVisible(hideInAOD);
        dWeatherLabel1.setVisible(hideInAOD);
        dWeatherLabel2.setVisible(hideInAOD);
        dNotifLabel.setVisible(hideInAOD);
        dTtrLabel.setVisible(hideInAOD);
        dActiveLabel.setVisible(hideInAOD);
        dWeatherLabel2.setVisible(hideInAOD);
        dStepBg.setVisible(hideInAOD);
        dStepLabel.setVisible(hideInAOD);

        dBattLabel.setVisible(hideBattery);
        dBattBg.setVisible(hideBattery);

        if(visible) {
            dTimeBg.setColor(getColor("timeBg"));
            dTtrBg.setColor(getColor("fieldBg"));
            dHrBg.setColor(getColor("fieldBg"));
            dActiveBg.setColor(getColor("fieldBg"));
            dStepBg.setColor(getColor("fieldBg"));
            dTtrDesc.setColor(getColor("fieldLabel"));
            dHrDesc.setColor(getColor("fieldLabel"));
            dActiveDesc.setColor(getColor("fieldLabel"));
            dTimeLabel.setColor(getColor("timeDisplay"));
            dDateLabel.setColor(getColor("dateDisplay"));
            dSecondsLabel.setColor(getColor("dateDisplay"));
            dNotifLabel.setColor(getColor("notifications"));
            dMoonLabel.setColor(Graphics.COLOR_WHITE);
            dDusk.setColor(getColor("dawnDuskLabel"));
            dDawn.setColor(getColor("dawnDuskLabel"));
            dSunUpLabel.setColor(getColor("dawnDuskValue"));
            dSunDownLabel.setColor(getColor("dawnDuskValue"));
            dWeatherLabel1.setColor(Graphics.COLOR_WHITE);
            dWeatherLabel2.setColor(Graphics.COLOR_WHITE);
            dTtrLabel.setColor(Graphics.COLOR_WHITE);
            dActiveLabel.setColor(Graphics.COLOR_WHITE);
            dStepLabel.setColor(Graphics.COLOR_WHITE);
            dBattBg.setColor(0x555555);
            dBattLabel.setColor(Graphics.COLOR_WHITE);

            if(canBurnIn) {
                dAodPattern.setVisible(false);
                dAodDateLabel.setVisible(false);
                dGradient.setVisible(true);
            }
        }

        previousEssentialsVis = visible;
    }
    
    hidden function getColor(colorName) as Graphics.ColorType {
        var amoled = System.getDeviceSettings().requiresBurnInProtection;
        
        if(propColorTheme == 0) { // Yellow on turquiose
            if(colorName.equals("fieldBg")) {
                if(amoled) { return 0x0e333c; }
                return 0x005555;
            } else if(colorName.equals("fieldLabel")) {
                return 0x55AAAA;
            } else if(colorName.equals("timeBg")) {
                if(amoled) { return 0x0d333c; }
                return 0x005555;
            } else if(colorName.equals("timeDisplay") || colorName.equals("dateDisplay")) {
                if(amoled) { return 0xfbcb77; }
                return 0xFFFF00;
            } else if(colorName.equals("dateDisplayDim")) {
                return 0xa98753;
            } else if(colorName.equals("dawnDuskLabel")) {
                return 0x005555;
            } else if(colorName.equals("dawnDuskValue")) {
                if(amoled) { return 0xFFFFFF; }
                return 0xAAAAAA;
            } else if(colorName.equals("notifications")) {
                return 0x00AAFF;
            } else if(colorName.equals("stress")) {
                return 0xFFAA00;
            } else if(colorName.equals("bodybattery")) {
                return 0x00AAFF;
            } else if(colorName.equals("HRActive")) {
                return 0xFFFFFF;
            } else if(colorName.equals("HRInactive")) {
                return 0x55AAAA;
            }
        } else if(propColorTheme == 1) { // Hot pink
            if(colorName.equals("fieldBg")) {
                if(amoled) { return 0x0e333c; }
                return 0x005555;
            } else if(colorName.equals("fieldLabel")) {
                return 0xAA55AA;
            } else if(colorName.equals("timeBg")) {
                if(amoled) { return 0x0f3b46; }
                return 0x005555;
            } else if(colorName.equals("timeDisplay")) {
                if(amoled) { return 0xf988f2; }
                return 0xFF55AA;
            } else if(colorName.equals("dateDisplay")) {
                return 0xFFFFFF;
            } else if(colorName.equals("dateDisplayDim")) {
                return 0xa95399;
            } else if(colorName.equals("dawnDuskLabel")) {
                return 0xAA55AA;
            } else if(colorName.equals("dawnDuskValue")) {
                if(amoled) { return 0xFFFFFF; }
                return 0xAAAAAA;
            } else if(colorName.equals("notifications")) {
                return 0xFF55AA;
            } else if(colorName.equals("stress")) {
                return 0xFF55AA;
            } else if(colorName.equals("bodybattery")) {
                return 0x00FFAA;
            } else if(colorName.equals("HRActive")) {
                return 0xFFFFFF;
            } else if(colorName.equals("HRInactive")) {
                return 0x55AAAA;
            }
        } else if(propColorTheme == 2) { // Blueish green
            if(colorName.equals("fieldBg")) {
                if(amoled) { return 0x0f2246; }
                return 0x0055AA;
            } else if(colorName.equals("fieldLabel")) {
                return 0x55AAAA;
            } else if(colorName.equals("timeBg")) {
                if(amoled) { return 0x0f2246; }
                return 0x0055AA;
            } else if(colorName.equals("timeDisplay") || colorName.equals("dateDisplay")) {
                if(amoled) { return 0x89efd2; }
                return 0x00FFFF;
            } else if(colorName.equals("dateDisplayDim")) {
                return 0x5ca28f;
            } else if(colorName.equals("dawnDuskLabel")) {
                return 0x005555;
            } else if(colorName.equals("dawnDuskValue")) {
                if(amoled) { return 0xFFFFFF; }
                return 0xAAAAAA;
            } else if(colorName.equals("notifications")) {
                return 0x00AAFF;
            } else if(colorName.equals("stress")) {
                return 0xFFAA00;
            } else if(colorName.equals("bodybattery")) {
                return 0x00AAFF;
            } else if(colorName.equals("HRActive")) {
                return 0xFFFFFF;
            } else if(colorName.equals("HRInactive")) {
                return 0x55AAAA;
            }
        } else if(propColorTheme == 3) { // Very green
            if(colorName.equals("fieldBg")) {
                if(amoled) { return 0x152b19; }
                return 0x005500;
            } else if(colorName.equals("fieldLabel")) {
                return 0x00AA55;
            } else if(colorName.equals("timeBg")) {
                if(amoled) { return 0x152b19; }
                return 0x005500;
            } else if(colorName.equals("timeDisplay") || colorName.equals("dateDisplay")) {
                if(amoled) { return 0x96e0ac; }
                return 0x00FF00;
            } else if(colorName.equals("dateDisplayDim")) {
                return 0x5ca28f;
            } else if(colorName.equals("dawnDuskLabel")) {
                return 0x00AA55;
            } else if(colorName.equals("dawnDuskValue")) {
                if(amoled) { return 0xFFFFFF; }
                return 0xAAAAAA;
            } else if(colorName.equals("notifications")) {
                return 0x00AAFF;
            } else if(colorName.equals("stress")) {
                if(amoled) { return 0xffc884; }
                return 0xFFAA00;
            } else if(colorName.equals("bodybattery")) {
                if(amoled) { return 0x59b9fe; }
                return 0x00AAFF;
            } else if(colorName.equals("HRActive")) {
                return 0xFFFFFF;
            } else if(colorName.equals("HRInactive")) {
                if(amoled) { return 0x96e0ac; }
                return 0x55FF55;
            }
        } else if(propColorTheme == 4) { // White on turquoise
            if(colorName.equals("fieldBg")) {
                if(amoled) { return 0x0e333c; }
                return 0x005555;
            } else if(colorName.equals("fieldLabel")) {
                return 0x55AAAA;
            } else if(colorName.equals("timeBg")) {
                if(amoled) { return 0x0d333c; }
                return 0x005555;
            } else if(colorName.equals("timeDisplay") || colorName.equals("dateDisplay")) {
                return 0xFFFFFF;
            } else if(colorName.equals("dateDisplayDim")) {
                return 0x114a5a;
            } else if(colorName.equals("dawnDuskLabel")) {
                return 0x005555;
            } else if(colorName.equals("dawnDuskValue")) {
                if(amoled) { return 0xFFFFFF; }
                return 0xAAAAAA;
            } else if(colorName.equals("notifications")) {
                return 0xAAAAAA;
            } else if(colorName.equals("stress")) {
                return 0xFFAA55;
            } else if(colorName.equals("bodybattery")) {
                return 0x55AAFF;
            } else if(colorName.equals("HRActive")) {
                return 0xFFFFFF;
            } else if(colorName.equals("HRInactive")) {
                return 0x55AAAA;
            }
        } else if(propColorTheme == 5) { // Orange
            if(colorName.equals("fieldBg")) {
                if(amoled) { return 0x1b263d; }
                return 0x5500AA;
            } else if(colorName.equals("fieldLabel")) {
                return 0xFFAAAA;
            } else if(colorName.equals("timeBg")) {
                if(amoled) { return 0x1b263d; }
                return 0x5500AA;
            } else if(colorName.equals("timeDisplay")) {
                if(amoled) { return 0xff9161; }
                return 0xFF5500;
            } else if(colorName.equals("dateDisplay")) {
                if(amoled) { return 0xffb383; }
                return 0xFFAAAA;
            } else if(colorName.equals("dateDisplayDim")) {
                return 0xaa6e56;
            } else if(colorName.equals("dawnDuskLabel")) {
                return 0xFFAAAA;
            } else if(colorName.equals("dawnDuskValue")) {
                if(amoled) { return 0xFFFFFF; }
                return 0xAAAAAA;
            } else if(colorName.equals("notifications")) {
                return 0xFFFFFF;
            } else if(colorName.equals("stress")) {
                return 0xFF5555;
            } else if(colorName.equals("bodybattery")) {
                return 0x00AAFF;
            } else if(colorName.equals("HRActive")) {
                return 0xFFFFFF;
            } else if(colorName.equals("HRInactive")) {
                if(amoled) { return 0x7878aa; }
                return 0x5555AA;
            }
        } else if(propColorTheme == 6) { // Red & White
            if(colorName.equals("fieldBg")) {
                if(amoled) { return 0x550000; }
                return 0xAA0000;
            } else if(colorName.equals("fieldLabel")) {
                return 0xFF0000;
            } else if(colorName.equals("timeBg")) {
                if(amoled) { return 0x550000; }
                return 0xAA0000;
            } else if(colorName.equals("timeDisplay") || colorName.equals("dateDisplay")) {
                if(amoled) { return 0xffffff; }
                return 0xFFFFFF;
            } else if(colorName.equals("dateDisplayDim")) {
                return 0xAA0000;
            } else if(colorName.equals("dawnDuskLabel")) {
                return 0xAA0000;
            } else if(colorName.equals("dawnDuskValue")) {
                if(amoled) { return 0xFFFFFF; }
                return 0xAAAAAA;
            } else if(colorName.equals("notifications")) {
                return 0xFF0000;
            } else if(colorName.equals("stress")) {
                return 0xAA0000;
            } else if(colorName.equals("bodybattery")) {
                return 0x00AAFF;
            } else if(colorName.equals("HRActive")) {
                return 0xFFFFFF;
            } else if(colorName.equals("HRInactive")) {
                return 0xFF0000;
            }
        } else if(propColorTheme == 7) { // White on Blue
            if(colorName.equals("fieldBg")) {
                if(amoled) { return 0x0b2051; }
                return 0x0055AA;
            } else if(colorName.equals("fieldLabel")) {
                return 0x0055AA;
            } else if(colorName.equals("timeBg")) {
                if(amoled) { return 0x0b2051; }
                return 0x0055AA;
            } else if(colorName.equals("timeDisplay") || colorName.equals("dateDisplay")) {
                if(amoled) { return 0xffffff; }
                return 0xFFFFFF;
            } else if(colorName.equals("dateDisplayDim")) {
                return 0x0055AA;
            } else if(colorName.equals("dawnDuskLabel")) {
                return 0x0055AA;
            } else if(colorName.equals("dawnDuskValue")) {
                if(amoled) { return 0xFFFFFF; }
                return 0xAAAAAA;
            } else if(colorName.equals("notifications")) {
                return 0x55AAFF;
            } else if(colorName.equals("stress")) {
                return 0xFFAA00;
            } else if(colorName.equals("bodybattery")) {
                return 0x55AAFF;
            } else if(colorName.equals("HRActive")) {
                return 0xFFFFFF;
            } else if(colorName.equals("HRInactive")) {
                return 0x0055ff;
            }
        } else if(propColorTheme == 8) { // Yellow on Blue
            if(colorName.equals("fieldBg")) {
                if(amoled) { return 0x0b2051; }
                return 0x0055AA;
            } else if(colorName.equals("fieldLabel")) {
                return 0x0055AA;
            } else if(colorName.equals("timeBg")) {
                if(amoled) { return 0x0b2051; }
                return 0x0055AA;
            } else if(colorName.equals("timeDisplay") || colorName.equals("dateDisplay")) {
                if(amoled) { return 0xfbcb77; }
                return 0xFFFF00;
            } else if(colorName.equals("dateDisplayDim")) {
                return 0xa98753;
            } else if(colorName.equals("dawnDuskLabel")) {
                return 0x0055AA;
            } else if(colorName.equals("dawnDuskValue")) {
                if(amoled) { return 0xFFFFFF; }
                return 0xAAAAAA;
            } else if(colorName.equals("notifications")) {
                return 0x55AAFF;
            } else if(colorName.equals("stress")) {
                return 0xFFAA00;
            } else if(colorName.equals("bodybattery")) {
                return 0x55AAFF;
            } else if(colorName.equals("HRActive")) {
                return 0xFFFFFF;
            } else if(colorName.equals("HRInactive")) {
                return 0x0055ff;
            }
        } else if(propColorTheme == 9) { // White & Orange
            if(colorName.equals("fieldBg")) {
                if(amoled) { return 0x58250b; }
                return 0xaa5500;
            } else if(colorName.equals("fieldLabel")) {
                return 0xFF5500;
            } else if(colorName.equals("timeBg")) {
                if(amoled) { return 0x7d3f01; }
                return 0xaa5500;
            } else if(colorName.equals("timeDisplay") || colorName.equals("dateDisplay")) {
                if(amoled) { return 0xffffff; }
                return 0xFFFFFF;
            } else if(colorName.equals("dateDisplayDim")) {
                return 0xAA5500;
            } else if(colorName.equals("dawnDuskLabel")) {
                return 0xFF5500;
            } else if(colorName.equals("dawnDuskValue")) {
                if(amoled) { return 0xFFFFFF; }
                return 0xAAAAAA;
            } else if(colorName.equals("notifications")) {
                return 0x00AAFF;
            } else if(colorName.equals("stress")) {
                return 0xFFAA00;
            } else if(colorName.equals("bodybattery")) {
                return 0x00AAFF;
            } else if(colorName.equals("HRActive")) {
                return 0xFFFFFF;
            } else if(colorName.equals("HRInactive")) {
                return 0xFFAA00;
            }
        } else if(propColorTheme == 10) { // Blue
            if(colorName.equals("fieldBg")) {
                if(amoled) { return 0x191b33; }
                return 0x555555;
            } else if(colorName.equals("fieldLabel")) {
                return 0x0055AA;
            } else if(colorName.equals("timeBg")) {
                if(amoled) { return 0x191b33; }
                return 0x000055;
            } else if(colorName.equals("timeDisplay")) {
                if(amoled) { return 0x3495d4; }
                return 0x0055AA;
            } else if(colorName.equals("dateDisplay")) {
                if(amoled) { return 0xffffff; }
                return 0xFFFFFF;
            } else if(colorName.equals("dateDisplayDim")) {
                return 0x0055AA;
            } else if(colorName.equals("dawnDuskLabel")) {
                return 0x0055AA;
            } else if(colorName.equals("dawnDuskValue")) {
                if(amoled) { return 0xFFFFFF; }
                return 0xAAAAAA;
            } else if(colorName.equals("notifications")) {
                return 0x55AAFF;
            } else if(colorName.equals("stress")) {
                return 0xFFAA00;
            } else if(colorName.equals("bodybattery")) {
                return 0x55AAFF;
            } else if(colorName.equals("HRActive")) {
                return 0xFFFFFF;
            } else if(colorName.equals("HRInactive")) {
                if(amoled) { return 0x0055AA; }
                return 0x55AAFF;
            }
        } else if(propColorTheme == 11) { // Orange
            if(colorName.equals("fieldBg")) {
                if(amoled) { return 0x333333; }
                return 0x555555;
            } else if(colorName.equals("fieldLabel")) {
                return 0xFFAA00;
            } else if(colorName.equals("timeBg")) {
                if(amoled) { return 0x333333; }
                return 0x555555;
            } else if(colorName.equals("timeDisplay")) {
                if(amoled) { return 0xff7600; }
                return 0xFFAA00;
            } else if(colorName.equals("dateDisplay")) {
                if(amoled) { return 0xffffff; }
                return 0xFFFFFF;
            } else if(colorName.equals("dateDisplayDim")) {
                return 0x555555;
            } else if(colorName.equals("dawnDuskLabel")) {
                return 0xFFAA00;
            } else if(colorName.equals("dawnDuskValue")) {
                if(amoled) { return 0xFFFFFF; }
                return 0xAAAAAA;
            } else if(colorName.equals("notifications")) {
                return 0x55AAFF;
            } else if(colorName.equals("stress")) {
                return 0xFFAA00;
            } else if(colorName.equals("bodybattery")) {
                return 0x55AAFF;
            } else if(colorName.equals("HRActive")) {
                return 0xFFFFFF;
            } else if(colorName.equals("HRInactive")) {
                return 0xFFAA00;
            }
        }

        return Graphics.COLOR_WHITE;
    }

    hidden function setSeconds(dc) as Void {
        var clockTime = System.getClockTime();
        var secString = Lang.format("$1$", [clockTime.sec.format("%02d")]);
        dSecondsLabel.setText(secString);
    }

    hidden function setClock(dc) as Void {
        var clockTime = System.getClockTime();
        var hour = formatHour(clockTime.hour);

        var timeString = Lang.format("$1$:$2$", [hour.format("%02d"), clockTime.min.format("%02d")]);
        dTimeLabel.setText(timeString);
    }

    hidden function formatHour(hour) as Number {
        var hourFormat = Application.Properties.getValue("hourFormat");
        if((!System.getDeviceSettings().is24Hour and hourFormat == 0) or hourFormat == 2) {
            hour = hour % 12;
            if(hour == 0) { hour = 12; }
        }
        return hour;
    }

    hidden function setMoon(dc) as Void {
        var showMoonPhase = Application.Properties.getValue("showMoonPhase");
        if(showMoonPhase) {
            var now = Time.now();
            var today = Time.Gregorian.info(now, Time.FORMAT_SHORT);
            var moonVal = moon_phase(today);
            dMoonLabel.setText(moonVal);
        } else {
            dMoonLabel.setText("");
        }
    }
    
    hidden function setHR(dc) as Void {
        if(propMiddleValueShows == 10) {
            dHrDesc.setText("HEART RATE:");

            // Try to retrieve live HR from Activity::Info
            var activityInfo = Activity.getActivityInfo();
            var sample = activityInfo.currentHeartRate;
            if(sample != null) {
                dHrLabel.setText(sample.format("%01d"));
                dHrLabel.setColor(getColor("HRActive"));
            } else if (ActivityMonitor has :getHeartRateHistory) {
                // Falling back to historical HR from ActivityMonitor
                var hist = ActivityMonitor.getHeartRateHistory(1, /* newestFirst */ true).next();
                if ((hist != null) && (hist.heartRate != ActivityMonitor.INVALID_HR_SAMPLE)) {
                    dHrLabel.setText(hist.heartRate.format("%01d"));
                    dHrLabel.setColor(getColor("HRInactive"));
                }
            }
        } else {
            var width = 3;
            if(dc.getWidth() > 450) {
                width = 4;
            }
            dHrDesc.setText(getComplicationDesc(propMiddleValueShows));
            dHrLabel.setText(getComplicationValue(propMiddleValueShows, width));

            dHrLabel.setColor(Graphics.COLOR_WHITE);
        }

        dHrLabel.draw(dc);
    }

    hidden function setBatt(dc) as Void {
        var visible = (!isSleeping or !canBurnIn) && propBatteryVariant != 2;  // Only show if not in AOD and battery is not hidden
        var value = "";

        if(propBatteryVariant == 0) {
            if(System.getSystemStats() has :batteryInDays) {
                if (System.getSystemStats().batteryInDays != null){
                    var sample = Math.round(System.getSystemStats().batteryInDays);
                    value = Lang.format("$1$D", [sample.format("%d")]);
                }
            } else {
                propBatteryVariant = 1;  // Fall back to percentage if days not available
            }
        }
        if(propBatteryVariant == 1) {
            var sample = System.getSystemStats().battery;
            if(sample < 100) {
                value = Lang.format("$1$%", [sample.format("%d")]);
            } else {
                value = Lang.format("$1$", [sample.format("%d")]);
            }
        }

        dBattBg.setVisible(visible);
        dBattLabel.setText(value);
    }

    hidden function updateWeather() as Void {
        weatherCondition = Weather.getCurrentConditions();
    }

    hidden function setWeather(dc) as Void {
        var tempUnitSetting = System.getDeviceSettings().temperatureUnits;
        var tempUnitAppSetting = Application.Properties.getValue("tempUnit");
        var temp = "";
        var tempUnit = "";
        var windspeed = "";
        var bearing = "";
        var fl = "";
        var weatherText = "";
        if (weatherCondition == null) { return; }
        if (weatherCondition.condition == null) { return; }

        if(weatherCondition.temperature != null) {
            var tempVal = weatherCondition.temperature;

            if((tempUnitSetting == System.UNIT_METRIC and tempUnitAppSetting == 0) or tempUnitAppSetting == 1) {
                temp = tempVal.format("%01d");
                tempUnit = "C";
            } else {
                temp = ((tempVal * 9/5) + 32).format("%01d");
                tempUnit = "F";
            }
            weatherText = Lang.format("$1$$2$", [temp, tempUnit]);
        }
        
        if(weatherCondition.windSpeed != null) {
            var windUnit = Application.Properties.getValue("windUnit");
            var windspeed_mps = weatherCondition.windSpeed;
            if(windUnit == 0) { // m/s
                windspeed = Math.round(windspeed_mps).format("%01d");
            } else if (windUnit == 1) { // km/h
                var windspeed_kmh = Math.round(windspeed_mps * 3.6);
                windspeed = windspeed_kmh.format("%01d");
            } else if (windUnit == 2) { // mph
                var windspeed_mph = Math.round(windspeed_mps * 2.237);
                windspeed = windspeed_mph.format("%01d");
            } else if (windUnit == 3) { // knots
                var windspeed_kt = Math.round(windspeed_mps * 1.944);
                windspeed = windspeed_kt.format("%01d");
            } else if(windUnit == 4) { // beufort
                if (windspeed_mps < 0.5f) {
                    windspeed = "0";  // Calm
                } else if (windspeed_mps < 1.5f) {
                    windspeed = "1";  // Light air
                } else if (windspeed_mps < 3.3f) {
                    windspeed = "2";  // Light breeze
                } else if (windspeed_mps < 5.5f) {
                    windspeed = "3";  // Gentle breeze
                } else if (windspeed_mps < 7.9f) {
                    windspeed = "4";  // Moderate breeze
                } else if (windspeed_mps < 10.7f) {
                    windspeed = "5";  // Fresh breeze
                } else if (windspeed_mps < 13.8f) {
                    windspeed = "6";  // Strong breeze
                } else if (windspeed_mps < 17.1f) {
                    windspeed = "7";  // Near gale
                } else if (windspeed_mps < 20.7f) {
                    windspeed = "8";  // Gale
                } else if (windspeed_mps < 24.4f) {
                    windspeed = "9";  // Strong gale
                } else if (windspeed_mps < 28.4f) {
                    windspeed = "10";  // Storm
                } else if (windspeed_mps < 32.6f) {
                    windspeed = "11";  // Violent storm
                } else {
                    windspeed = "12";  // Hurricane force
                }
            }
        }

        if(weatherCondition.windBearing != null) {
            bearing = ((Math.round((weatherCondition.windBearing.toFloat() + 180) / 45.0).toNumber() % 8) + 97).toChar().toString();
        }

        if(windspeed.length() > 0 and bearing.length() > 0) {
            if(weatherText.length() == 0) {
                weatherText = windspeed;
            } else {
                weatherText = Lang.format("$1$, $2$$3$", [weatherText, bearing, windspeed]);
            }
        }

        var showFeelsLike = Application.Properties.getValue("showFeelsLike");
        if(showFeelsLike) {
            if(weatherCondition.feelsLikeTemperature != null) {
                var fltemp = weatherCondition.feelsLikeTemperature;
                if((tempUnitSetting != System.UNIT_METRIC and tempUnitAppSetting == 0) or tempUnitAppSetting == 2) {
                    fltemp = ((fltemp * 9/5) + 32);
                }
                fl = Lang.format("FL: $1$$2$", [fltemp.format(INTEGER_FORMAT), tempUnit]);
            }

            if(weatherText.length() == 0) {
                weatherText = fl;
            } else {
                weatherText = Lang.format("$1$, $2$", [weatherText, fl]);
            }
        }
        
        dWeatherLabel1.setText(weatherText);
    }

    hidden function setWeatherLabel() as Void {
        var weatherLine2Shows = Application.Properties.getValue("weatherLine2Shows");
        var unit = getComplicationUnit(weatherLine2Shows);
        if (unit.length() > 0) {
            unit = Lang.format(" $1$", [unit]);
        }
        dWeatherLabel2.setText(Lang.format("$1$$2$", [getComplicationValue(weatherLine2Shows, 10), unit]));
    }

    hidden function getWeatherCondition() as String {
        var condition;
        var perp = "";

        // Early return if no weather data
        if (weatherCondition == null || weatherCondition.condition == null) {
            return "";
        }

        // Safely check precipitation chance
        if (weatherCondition has :precipitationChance &&
            weatherCondition.precipitationChance != null &&
            weatherCondition.precipitationChance instanceof Number) {
            if(weatherCondition.precipitationChance > 0) {
                perp = Lang.format(" ($1$%)", [weatherCondition.precipitationChance.format("%02d")]);
            }
        }

        switch(weatherCondition.condition) {
            case Weather.CONDITION_CLEAR:
                condition = "CLEAR" + perp;
                break;
            case Weather.CONDITION_PARTLY_CLOUDY:
                condition = "PARTLY CLOUDY" + perp;
                break;
            case Weather.CONDITION_MOSTLY_CLOUDY:
                condition = "MOSTLY CLOUDY" + perp;
                break;
            case Weather.CONDITION_RAIN:
                condition = "RAIN" + perp;
                break;
            case Weather.CONDITION_SNOW:
                condition = "SNOW" + perp;
                break;
            case Weather.CONDITION_WINDY:
                condition = "WINDY" + perp;
                break;
            case Weather.CONDITION_THUNDERSTORMS:
                condition = "THUNDERSTORMS" + perp;
                break;
            case Weather.CONDITION_WINTRY_MIX:
                condition = "WINTRY MIX" + perp;
                break;
            case Weather.CONDITION_FOG:
                condition = "FOG" + perp;
                break;
            case Weather.CONDITION_HAZY:
                condition = "HAZY" + perp;
                break;
            case Weather.CONDITION_HAIL:
                condition = "HAIL" + perp;
                break;
            case Weather.CONDITION_SCATTERED_SHOWERS:
                condition = "SCT SHOWERS" + perp;
                break;
            case Weather.CONDITION_SCATTERED_THUNDERSTORMS:
                condition = "SCT THUNDERSTORMS";
                break;
            case Weather.CONDITION_UNKNOWN_PRECIPITATION:
                condition = "UNKN PRECIPITATION";
                break;
            case Weather.CONDITION_LIGHT_RAIN:
                condition = "LIGHT RAIN" + perp;
                break;
            case Weather.CONDITION_HEAVY_RAIN:
                condition = "HEAVY RAIN" + perp;
                break;
            case Weather.CONDITION_LIGHT_SNOW:
                condition = "LIGHT SNOW" + perp;
                break;
            case Weather.CONDITION_HEAVY_SNOW:
                condition = "HEAVY SNOW" + perp;
                break;
            case Weather.CONDITION_LIGHT_RAIN_SNOW:
                condition = "LIGHT RAIN & SNOW";
                break;
            case Weather.CONDITION_HEAVY_RAIN_SNOW:
                condition = "HEAVY RAIN & SNOW";
                break;
            case Weather.CONDITION_CLOUDY:
                condition = "CLOUDY" + perp;
                break;
            case Weather.CONDITION_RAIN_SNOW:
                condition = "RAIN & SNOW" + perp;
                break;
            case Weather.CONDITION_PARTLY_CLEAR:
                condition = "PARTLY CLEAR" + perp;
                break;
            case Weather.CONDITION_MOSTLY_CLEAR:
                condition = "MOSTLY CLEAR" + perp;
                break;
            case Weather.CONDITION_LIGHT_SHOWERS:
                condition = "LIGHT SHOWERS" + perp;
                break;
            case Weather.CONDITION_SHOWERS:
                condition = "SHOWERS" + perp;
                break;
            case Weather.CONDITION_HEAVY_SHOWERS:
                condition = "HEAVY SHOWERS" + perp;
                break;
            case Weather.CONDITION_CHANCE_OF_SHOWERS:
                condition = "CHC OF SHOWERS" + perp;
                break;
            case Weather.CONDITION_CHANCE_OF_THUNDERSTORMS:
                condition = "CHC THUNDERSTORMS";
                break;
            case Weather.CONDITION_MIST:
                condition = "MIST" + perp;
                break;
            case Weather.CONDITION_DUST:
                condition = "DUST" + perp;
                break;
            case Weather.CONDITION_DRIZZLE:
                condition = "DRIZZLE" + perp;
                break;
            case Weather.CONDITION_TORNADO:
                condition = "TORNADO" + perp;
                break;
            case Weather.CONDITION_SMOKE:
                condition = "SMOKE" + perp;
                break;
            case Weather.CONDITION_ICE:
                condition = "ICE" + perp;
                break;
            case Weather.CONDITION_SAND:
                condition = "SAND" + perp;
                break;
            case Weather.CONDITION_SQUALL:
                condition = "SQUALL" + perp;
                break;
            case Weather.CONDITION_SANDSTORM:
                condition = "SANDSTORM" + perp;
                break;
            case Weather.CONDITION_VOLCANIC_ASH:
                condition = "VOLCANIC ASH" + perp;
                break;
            case Weather.CONDITION_HAZE:
                condition = "HAZE" + perp;
                break;
            case Weather.CONDITION_FAIR:
                condition = "FAIR" + perp;
                break;
            case Weather.CONDITION_HURRICANE:
                condition = "HURRICANE" + perp;
                break;
            case Weather.CONDITION_TROPICAL_STORM:
                condition = "TROPICAL STORM" + perp;
                break;
            case Weather.CONDITION_CHANCE_OF_SNOW:
                condition = "CHC OF SNOW" + perp;
                break;
            case Weather.CONDITION_CHANCE_OF_RAIN_SNOW:
                condition = "CHC OF RAIN & SNOW";
                break;
            case Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN:
                condition = "CLOUDY CHC RAIN";
                break;
            case Weather.CONDITION_CLOUDY_CHANCE_OF_SNOW:
                condition = "CLOUDY CHC SNOW";
                break;
            case Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN_SNOW:
                condition = "CLOUDY RAIN & SNOW";
                break;
            case Weather.CONDITION_FLURRIES:
                condition = "FLURRIES" + perp;
                break;
            case Weather.CONDITION_FREEZING_RAIN:
                condition = "FREEZING RAIN" + perp;
                break;
            case Weather.CONDITION_SLEET:
                condition = "SLEET" + perp;
                break;
            case Weather.CONDITION_ICE_SNOW:
                condition = "ICE & SNOW" + perp;
                break;
            case Weather.CONDITION_THIN_CLOUDS:
                condition = "THIN CLOUDS" + perp;
                break;
            default:
                condition = "UNKNOWN";
        }

        return condition;
    }

    hidden function setSunUpDown(dc) as Void {
        var showSunriseSunset = Application.Properties.getValue("showSunriseSunset");

        var now = Time.now();
        if(weatherCondition == null or !showSunriseSunset) {
            dDawn.setText("");
            dDusk.setText("");
            return;
        }
        var loc = weatherCondition.observationLocationPosition;
        if(loc == null) {
            dDawn.setText("");
            dDusk.setText("");
            return;
        }
        dDawn.setText("DAWN:");
        dDusk.setText("DUSK:");
        var sunrise = Time.Gregorian.info(Weather.getSunrise(loc, now), Time.FORMAT_SHORT);
        var sunset = Time.Gregorian.info(Weather.getSunset(loc, now), Time.FORMAT_SHORT);
        var sunriseHour = formatHour(sunrise.hour);
        var sunsetHour = formatHour(sunset.hour);
        dSunUpLabel.setText(Lang.format("$1$:$2$", [sunriseHour.format("%02d"), sunrise.min.format("%02d")]));
        dSunDownLabel.setText(Lang.format("$1$:$2$", [sunsetHour.format("%02d"), sunset.min.format("%02d")]));
    }

    hidden function setNotif(dc) as Void {
        var value = "";

        var showNotificationCount = Application.Properties.getValue("showNotificationCount");
        if(showNotificationCount) {
            var sample = System.getDeviceSettings().notificationCount;
            if(sample > 0) {
                value = sample.format("%01d");
            }

            dNotifLabel.setText(value);
        } else {
            dNotifLabel.setText("");
        }
    }

    hidden function setDate(dc) as Void {
        var now = Time.now();
        var today = Time.Gregorian.info(now, Time.FORMAT_SHORT);
        var dateFormat = Application.Properties.getValue("dateFormat");
        var value = "";

        switch(dateFormat) {
            case 0: // Default: THU, 14 MAR 2024
                value = Lang.format("$1$, $2$ $3$ $4$", [
                    day_name(today.day_of_week),
                    today.day,
                    month_name(today.month),
                    today.year
                ]);
                break;
            case 1: // ISO: 2024-03-14
                value = Lang.format("$1$-$2$-$3$", [
                    today.year,
                    today.month.format("%02d"),
                    today.day.format("%02d")
                ]);
                break;
            case 2: // US: 03/14/2024
                value = Lang.format("$1$/$2$/$3$", [
                    today.month.format("%02d"),
                    today.day.format("%02d"),
                    today.year
                ]);
                break;
            case 3: // EU: 14.03.2024
                value = Lang.format("$1$.$2$.$3$", [
                    today.day.format("%02d"),
                    today.month.format("%02d"),
                    today.year
                ]);
                break;
            case 4: // THU, 14 MAR (Week number)
                value = Lang.format("$1$, $2$ $3$ (W$4$)", [
                    day_name(today.day_of_week),
                    today.day,
                    month_name(today.month),
                    iso_week_number(today.year, today.month, today.day)
                ]);
                break;
            case 5: // THU, 14 MAR 2024 (Week number)
                value = Lang.format("$1$, $2$ $3$ $4$ (W$5$)", [
                    day_name(today.day_of_week),
                    today.day,
                    month_name(today.month),
                    today.year,
                    iso_week_number(today.year, today.month, today.day)
                ]);
                break;
            case 6: // WEEKDAY, DD MONTH
                value = Lang.format("$1$, $2$ $3$", [
                    day_name(today.day_of_week),
                    today.day,
                    month_name(today.month)
                ]);
                break;
            case 7: // WEEKDAY, YYYY-MM-DD
                value = Lang.format("$1$, $2$-$3$-$4$", [
                    day_name(today.day_of_week),
                    today.year,
                    today.month.format("%02d"),
                    today.day.format("%02d")
                ]);
                break;
            case 8: // WEEKDAY, MM/DD/YYYY
                value = Lang.format("$1$, $2$/$3$/$4$", [
                    day_name(today.day_of_week),
                    today.month.format("%02d"),
                    today.day.format("%02d"),
                    today.year
                ]);
                break;
            case 9: // WEEKDAY, DD.MM.YYYY
                value = Lang.format("$1$, $2$.$3$.$4$", [
                    day_name(today.day_of_week),
                    today.day.format("%02d"),
                    today.month.format("%02d"),
                    today.year
                ]);
                break;
        }
        
        dDateLabel.setText(value.toUpper());

        if(canBurnIn) {
            var aodFieldShows = Application.Properties.getValue("aodFieldShows");
            if(aodFieldShows == -1) {
                dAodDateLabel.setText(value.toUpper());
            } else {
                var unit = getComplicationUnit(aodFieldShows);
                if (unit.length() > 0) {
                    unit = Lang.format(" $1$", [unit]);
                }
                dAodDateLabel.setText(Lang.format("$1$$2$", [getComplicationValue(aodFieldShows, 10), unit]));
            }
        }
    }

    hidden function setStep(dc) as Void {
        var bottomFieldShows = Application.Properties.getValue("bottomFieldShows");
        dStepLabel.setText(getComplicationValueWithFormat(bottomFieldShows, "%05d", 5));
    }

    hidden function updateStressAndBodyBatteryData() as Void {
        var showStressAndBodyBattery = Application.Properties.getValue("showStressAndBodyBattery");
        if(!showStressAndBodyBattery) { return; }

        if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory) && (Toybox.SensorHistory has :getStressHistory)) {
            var bbIterator = Toybox.SensorHistory.getBodyBatteryHistory({:period => 1});
            var stIterator = Toybox.SensorHistory.getStressHistory({:period => 1});
            var bb = bbIterator.next();
            var st = stIterator.next();

            if(bb != null) {
                batt = bb.data;
            }
            if(st != null) {
                stress = st.data;
            }
        }
    }

    hidden function drawStressAndBodyBattery(dc) as Void {
        var showStressAndBodyBattery = Application.Properties.getValue("showStressAndBodyBattery");
        if(!showStressAndBodyBattery) { return; }

        if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory) && (Toybox.SensorHistory has :getStressHistory)) {
            var barTop = 110;
            var fromEdge = 8;
            var barWidth = 4;
            var barHeight = 125;
            var bbAdjustment = 0;

            if(screenHeight == 240) {
                barTop = 72;
                fromEdge = 5;
                barWidth = 3;
                barHeight = 80;
                bbAdjustment = 1;
            }
            if(screenHeight == 260) {
                barTop = 77;
                fromEdge = 10;
                barWidth = 3;
                barHeight = 80;
                bbAdjustment = 1;
            }
            if(screenHeight == 280) {
                barTop = 83;
                fromEdge = 14;
                barWidth = 3;
                barHeight = 80;
                bbAdjustment = -1;
            }
            if(screenHeight == 360) {
                barTop = 103;
                fromEdge = 3;
                barWidth = 3;
                barHeight = 125;
                bbAdjustment = -1;
                if(isSleeping) {
                    fromEdge = 0;
                }
            }
            if(screenHeight == 390) {
                barTop = 111;
                fromEdge = 8;
                barWidth = 4;
                barHeight = 125;
                bbAdjustment = 0;
                if(isSleeping) {
                    fromEdge = 4;
                }
            }
            if(screenHeight == 416) {
                barTop = 122;
                fromEdge = 15;
                barWidth = 4;
                barHeight = 125;
                bbAdjustment = 0;
                if(isSleeping) {
                    fromEdge = 10;
                }
            }
            if(screenHeight == 454) {
                barTop = 146;
                fromEdge = 12;
                barWidth = 4;
                barHeight = 145;
                bbAdjustment = 0;
                if(isSleeping) {
                    fromEdge = 8;
                }
            }

            var battBar = Math.round(batt * (barHeight / 100.0));
            dc.setColor(getColor("bodybattery"), -1);
            dc.fillRectangle(dc.getWidth() - fromEdge - barWidth - bbAdjustment, barTop + (barHeight - battBar), barWidth, battBar);
        
            var stressBar = Math.round(stress * (barHeight / 100.0));
            dc.setColor(getColor("stress"), -1);
            dc.fillRectangle(fromEdge, barTop + (barHeight - stressBar), barWidth, stressBar);
            
        }
    }

    hidden function setTraining(dc) as Void {
        var leftValueShows = Application.Properties.getValue("leftValueShows");
        var leftWidth = 3;
        if(dc.getWidth() > 450) {
            leftWidth = 4;
        }
        dTtrDesc.setText(getComplicationDesc(leftValueShows));
        dTtrLabel.setText(getComplicationValue(leftValueShows, leftWidth));
        
        var rightWidth = 4;
        if(dc.getWidth() == 240) {
            rightWidth = 3;
        }
        var rightValueShows = Application.Properties.getValue("rightValueShows");
        dActiveDesc.setText(getComplicationDesc(rightValueShows));
        dActiveLabel.setText(getComplicationValue(rightValueShows, rightWidth));
    }

    function getComplicationValue(complicationType as Number, width as Number) as String {
        return getComplicationValueWithFormat(complicationType, "%01d", width);
    }

    function getComplicationValueWithFormat(complicationType as Number, numberFormat as String, width as Number) as String {
        var val = "";

        if(complicationType == 0) { // Active min / week
            if(ActivityMonitor.getInfo() has :activeMinutesWeek) {
                if(ActivityMonitor.getInfo().activeMinutesWeek != null) {
                    val = ActivityMonitor.getInfo().activeMinutesWeek.total.format(numberFormat);
                }
            }
        } else if(complicationType == 1) { // Active min / day
            if(ActivityMonitor.getInfo() has :activeMinutesWeek) {
                if(ActivityMonitor.getInfo().activeMinutesDay != null) {
                    val = ActivityMonitor.getInfo().activeMinutesDay.total.format(numberFormat);
                }
            }
        } else if(complicationType == 2) { // distance (km) / day
            if(ActivityMonitor.getInfo() has :distance) {
                if(ActivityMonitor.getInfo().distance != null) {
                    var distanceKm = ActivityMonitor.getInfo().distance / 100000.0;
                    val = formatDistanceByWidth(distanceKm, width);
                }
            }
        } else if(complicationType == 3) { // distance (miles) / day
            if(ActivityMonitor.getInfo() has :distance) {
                if(ActivityMonitor.getInfo().distance != null) {
                    var distanceMiles = ActivityMonitor.getInfo().distance / 160900.0;
                    val = formatDistanceByWidth(distanceMiles, width);
                }
            }
        } else if(complicationType == 4) { // floors climbed / day
            if(ActivityMonitor.getInfo() has :floorsClimbed) {
                if(ActivityMonitor.getInfo().floorsClimbed != null) {
                    val = ActivityMonitor.getInfo().floorsClimbed.format(numberFormat);
                }
            }
        } else if(complicationType == 5) { // meters climbed / day
            if(ActivityMonitor.getInfo() has :metersClimbed) {
                if(ActivityMonitor.getInfo().metersClimbed != null) {
                    val = ActivityMonitor.getInfo().metersClimbed.format(numberFormat);
                }
            }
        } else if(complicationType == 6) { // Time to Recovery (h)
            if(ActivityMonitor.getInfo() has :timeToRecovery) {
                if(ActivityMonitor.getInfo().timeToRecovery != null) {
                    val = ActivityMonitor.getInfo().timeToRecovery.format(numberFormat);
                }
            }
        } else if(complicationType == 7) { // VO2 Max Running
            var profile = UserProfile.getProfile();
            if(profile has :vo2maxRunning) {
                if(profile.vo2maxRunning != null) {
                    val = profile.vo2maxRunning.format(numberFormat);
                }
            }
        } else if(complicationType == 8) { // VO2 Max Cycling
            var profile = UserProfile.getProfile();
            if(profile has :vo2maxCycling) {
                if(profile.vo2maxCycling != null) {
                    val = profile.vo2maxCycling.format(numberFormat);
                }
            }
        } else if(complicationType == 9) { // Respiration rate
            if(ActivityMonitor.getInfo() has :respirationRate) {
                if(ActivityMonitor.getInfo().respirationRate != null) {
                    val = ActivityMonitor.getInfo().respirationRate.format(numberFormat);
                }
            }
        } else if(complicationType == 11) { // Calories
            if (ActivityMonitor.getInfo() has :calories) {
                if(ActivityMonitor.getInfo().calories != null) {
                    val = ActivityMonitor.getInfo().calories.format(numberFormat);
                }
            }
        } else if(complicationType == 12) { // Altitude (m)
            if ((Toybox has :SensorHistory) and (Toybox.SensorHistory has :getElevationHistory)) {
                var elvIterator = Toybox.SensorHistory.getElevationHistory({:period => 1});
                var elv = elvIterator.next();
                if(elv != null and elv.data != null) {
                    val = elv.data.format(numberFormat);
                }
            }
        } else if(complicationType == 13) { // Stress
            if(ActivityMonitor.getInfo() has :stressScore) {
                if(ActivityMonitor.getInfo().stressScore != null) {
                    val = ActivityMonitor.getInfo().stressScore.format(numberFormat);
                }
            }
        } else if(complicationType == 14) { // Body battery
            if ((Toybox has :SensorHistory) and (Toybox.SensorHistory has :getBodyBatteryHistory)) {
                var bbIterator = Toybox.SensorHistory.getBodyBatteryHistory({:period => 1});
                var bb = bbIterator.next();
                if(bb != null and bb.data != null) {
                    val = bb.data.format(numberFormat);
                }
            }
        } else if(complicationType == 15) { // Altitude (ft)
            if ((Toybox has :SensorHistory) and (Toybox.SensorHistory has :getElevationHistory)) {
                var elvIterator = Toybox.SensorHistory.getElevationHistory({:period => 1});
                var elv = elvIterator.next();
                if(elv != null and elv.data != null) {
                    val = (elv.data * 3.28084).format(numberFormat);
                }
            }
        } else if(complicationType == 16) { // UTC time
            var now = Time.now();
            var utc = Time.Gregorian.utcInfo(now, Time.FORMAT_MEDIUM);
            val = Lang.format("$1$$2$", [utc.hour.format("%02d"), utc.min.format("%02d")]);
        } else if(complicationType == 17) { // Steps / day
            if(ActivityMonitor.getInfo().steps != null) {
                val = ActivityMonitor.getInfo().steps.format(numberFormat);
            }
        } else if(complicationType == 18) { // Distance (m) / day
            if(ActivityMonitor.getInfo().distance != null) {
                val = (ActivityMonitor.getInfo().distance / 100).format(numberFormat);
            }
        } else if(complicationType == 19) { // Wheelchair pushes
            if(ActivityMonitor.getInfo() has :pushes) {
                if(ActivityMonitor.getInfo().pushes != null) {
                    val = ActivityMonitor.getInfo().pushes.format(numberFormat);
                } 
            }  
        } else if(complicationType == 20) { // Weather condition
            val = getWeatherCondition();
        } else if(complicationType == 21) { // Weekly run distance (km)
            if (Toybox has :Complications) {
                try {
                    var complication = Complications.getComplication(new Id(Complications.COMPLICATION_TYPE_WEEKLY_RUN_DISTANCE));
                    if (complication != null && complication.value != null) {
                        var distanceKm = complication.value / 1000.0;  // Convert meters to km
                        val = formatDistanceByWidth(distanceKm, width);
                    }
                } catch(e) {
                    // Complication not found
                }
            }
        } else if(complicationType == 22) { // Weekly run distance (miles)
            if (Toybox has :Complications) {
                try {
                    var complication = Complications.getComplication(new Id(Complications.COMPLICATION_TYPE_WEEKLY_RUN_DISTANCE));
                    if (complication != null && complication.value != null) {
                        var distanceMiles = complication.value * 0.000621371;  // Convert meters to miles
                        val = formatDistanceByWidth(distanceMiles, width);
                    }
                } catch(e) {
                    // Complication not found
                }
            }
        } else if(complicationType == 23) { // Weekly bike distance (km)
            if (Toybox has :Complications) {
                try {
                    var complication = Complications.getComplication(new Id(Complications.COMPLICATION_TYPE_WEEKLY_BIKE_DISTANCE));
                    if (complication != null && complication.value != null) {
                        var distanceKm = complication.value / 1000.0;  // Convert meters to km
                        val = formatDistanceByWidth(distanceKm, width);
                    }
                } catch(e) {
                    // Complication not found
                }
            }
        } else if(complicationType == 24) { // Weekly bike distance (miles)
            if (Toybox has :Complications) {
                try {
                    var complication = Complications.getComplication(new Id(Complications.COMPLICATION_TYPE_WEEKLY_BIKE_DISTANCE));
                    if (complication != null && complication.value != null) {
                        var distanceMiles = complication.value * 0.000621371;  // Convert meters to miles
                        val = formatDistanceByWidth(distanceMiles, width);
                    }
                } catch(e) {
                    // Complication not found
                }
            }
        } else if(complicationType == 25) { // Training status
            if (Toybox has :Complications) {
                try {
                    var complication = Complications.getComplication(new Id(Complications.COMPLICATION_TYPE_TRAINING_STATUS));
                    if (complication != null && complication.value != null) {
                        val = complication.value.toUpper();
                    }
                } catch(e) {
                    // Complication not found
                }
            }
        } else if(complicationType == 26) { // Raw Barometric pressure (hPA)
            var info = Activity.getActivityInfo();
            if (info has :rawAmbientPressure && info.rawAmbientPressure != null) {
                val = formatPressure(info.rawAmbientPressure / 100.0, numberFormat);
            }
        } else if(complicationType == 27) { // Weight kg
            var profile = UserProfile.getProfile();
            if(profile has :weight) {
                if(profile.weight != null) {
                    var weightKg = profile.weight / 1000.0;
                    if (width == 3) {
                        val = weightKg.format(numberFormat);
                    } else {
                        val = weightKg.format("%.1f");
                    }
                }
            }
        } else if(complicationType == 28) { // Weight lbs
            var profile = UserProfile.getProfile();
            if(profile has :weight) {
                if(profile.weight != null) {
                    val = (profile.weight * 0.00220462).format(numberFormat);
                }
            }
        } else if(complicationType == 29) { // Act Calories
            var today = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
            var profile = UserProfile.getProfile();
            
            if (profile has :weight && profile has :height && profile has :birthYear) {
                var age = today.year - profile.birthYear;
                var weight = profile.weight / 1000.0;
                var restCalories = 0;
                
                if (profile.gender == UserProfile.GENDER_MALE) {
                    restCalories = 5.2 - 6.116 * age + 7.628 * profile.height + 12.2 * weight;
                } else {
                    restCalories = -197.6 - 6.116 * age + 7.628 * profile.height + 12.2 * weight;
                }
                
                // Calculate rest calories for the current time of day
                restCalories = Math.round((today.hour * 60 + today.min) * restCalories / 1440).toNumber();
                
                // Get total calories and subtract rest calories
                if (ActivityMonitor.getInfo() has :calories && ActivityMonitor.getInfo().calories != null) {
                    var activeCalories = ActivityMonitor.getInfo().calories - restCalories;
                    if (activeCalories > 0) {
                        val = activeCalories.format(numberFormat);
                    }
                }
            }
        } else if(complicationType == 30) { // Sea level pressure (hPA)
            var info = Activity.getActivityInfo();
            if (info has :meanSeaLevelPressure && info.meanSeaLevelPressure != null) {
                val = formatPressure(info.meanSeaLevelPressure / 100.0, numberFormat);
            }
        } else if(complicationType == 31) { // Week number
            var today = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
            var weekNumber = iso_week_number(today.year, today.month, today.day);
            val = weekNumber.format(numberFormat);
        } else if(complicationType == 32) { // Weekly distance (km)
            var weeklyDistance = getWeeklyDistance() / 100000.0;  // Convert to km
            val = formatDistanceByWidth(weeklyDistance, width);
        } else if(complicationType == 33) { // Weekly distance (miles)
            var weeklyDistance = getWeeklyDistance() * 0.00000621371;  // Convert to miles
            val = formatDistanceByWidth(weeklyDistance, width);
        } else if(complicationType == 34) { // Battery percentage
            var battery = System.getSystemStats().battery;
            val = Lang.format("$1$", [battery.format("%d")]);
        } else if(complicationType == 35) { // Battery days remaining
            if(System.getSystemStats() has :batteryInDays) {
                if (System.getSystemStats().batteryInDays != null){
                    var sample = Math.round(System.getSystemStats().batteryInDays);
                    val = Lang.format("$1$", [sample.format(numberFormat)]);
                }
            }
        } else if(complicationType == 36) { // Notification count
            var notifCount = System.getDeviceSettings().notificationCount;
            if(notifCount != null) {
                val = notifCount.format(numberFormat);
            }
        }
        return val;
    }

    function getComplicationDesc(complicationType) as String {
        var desc = "";

        if(complicationType == 0) { // Active min / week
            desc = "WEEKLY MIN:";
        } else if(complicationType == 1) { // Active min / day
           desc = "DAILY MIN:";
        } else if(complicationType == 2) { // distance (km) / day
            desc = "KM TODAY:";
        } else if(complicationType == 3) { // distance (miles) / day
            desc = "MILES TODAY:";
        } else if(complicationType == 4) { // floors climbed / day
            desc = "FLOORS:";
        } else if(complicationType == 5) { // meters climbed / day
            desc = "M CLIMBED:";
        } else if(complicationType == 6) { // Time to Recovery (h)
            desc = "RECOV. HRS:";
        } else if(complicationType == 7) { // VO2 Max Running
            desc = "VO2 MAX:";
        } else if(complicationType == 8) { // VO2 Max Cycling
            desc = "VO2 MAX:";
        } else if(complicationType == 9) { // Respiration rate
            desc = "RESP RATE:";
        } else if(complicationType == 11) { // Calories / day
            desc = "CALORIES:";
        } else if(complicationType == 12) { // Altitude (m)
            desc = "ALTITUDE:";
        } else if(complicationType == 13) { // Stress
            desc = "STRESS:";
        } else if(complicationType == 14) { // Body battery
            desc = "BODY BATT:";
        } else if(complicationType == 15) { // Altitude (ft)
            desc = "ALTITUDE:";
        } else if(complicationType == 16) { // UTC time
            desc = "UTC TIME:";
        } else if(complicationType == 17) { // Steps / day
            desc = "STEPS:";
        } else if(complicationType == 18) { // Distance (m) / day
            desc = "M TODAY:";
        } else if(complicationType == 19) { // Wheelchair pushes
            desc = "PUSHES:";
        } else if(complicationType == 20) { // Weather condition
            desc = "";
        } else if(complicationType == 21) { // Weekly run distance (km)
            desc = "W RUN KM:";
        } else if(complicationType == 22) { // Weekly run distance (miles)
            desc = "W RUN MI:";
        } else if(complicationType == 23) { // Weekly bike distance (km)
            desc = "W BIKE KM:";
        } else if(complicationType == 24) { // Weekly bike distance (miles)
            desc = "W BIKE MI:";
        } else if(complicationType == 25) { // Training status
            desc = "TRAINING:";
        } else if(complicationType == 26) { // Barometric pressure (hPA)
            desc = "PRESSURE:";
        } else if(complicationType == 27) { // Weight kg
            desc = "WEIGHT:";
        } else if(complicationType == 28) { // Weight lbs
            desc = "WEIGHT:";
        } else if(complicationType == 29) { // Act Calories / day
            desc = "ACT CAL:";
        } else if(complicationType == 30) { // Sea level pressure (hPA)
            desc = "PRESSURE:";
        } else if(complicationType == 31) { // Week number
            desc = "WEEK:";
        } else if(complicationType == 32) { // Weekly distance (km)
            desc = "WEEKLY KM:";
        } else if(complicationType == 33) { // Weekly distance (miles)
            desc = "WEEKLY MI:";
        } else if(complicationType == 34) { // Battery percentage
            desc = "BATTERY %:";
        } else if(complicationType == 35) { // Battery days remaining
            desc = "BATT DAYS:";
        } else if(complicationType == 36) { // Notification count
            desc = "NOTIFS:";
        }
        return desc;
    }

    function getComplicationUnit(complicationType) as String {
        var unit = "";
        if(complicationType == 11) { // Calories / day
            unit = "KCAL";
        } else if(complicationType == 12) { // Altitude (m)
            unit = "M";
        } else if(complicationType == 15) { // Altitude (ft)
            unit = "FT";
        } else if(complicationType == 17) { // Steps / day
            unit = "STEPS";
        } else if(complicationType == 19) { // Wheelchair pushes
            unit = "PUSHES";
        } else if(complicationType == 29) { // Active calories / day
            unit = "KCAL";
        }
        return unit;
    }

    function getWeeklyDistance() as Number {
        var weeklyDistance = 0;
        if(ActivityMonitor.getInfo() has :distance) {
            var history = ActivityMonitor.getHistory();
            if (history != null) {
                // Only take up to 6 previous days from history
                var daysToCount = history.size() < 6 ? history.size() : 6;
                for (var i = 0; i < daysToCount; i++) {
                    if (history[i].distance != null) {
                        weeklyDistance += history[i].distance;
                    }
                }
            }
            // Add today's distance
            if(ActivityMonitor.getInfo().distance != null) {
                weeklyDistance += ActivityMonitor.getInfo().distance;
            }
        }
        return weeklyDistance;
    }

    hidden function day_name(day_of_week) {
        var names = [
            "SUN",
            "MON",
            "TUE",
            "WED",
            "THU",
            "FRI",
            "SAT",
        ];
        return names[day_of_week - 1];
    }

    hidden function month_name(month) {
        var names = [
            "JAN",
            "FEB",
            "MAR",
            "APR",
            "MAY",
            "JUN",
            "JUL",
            "AUG",
            "SEP",
            "OCT",
            "NOV",
            "DEC"
        ];
        return names[month - 1];
    }

    hidden function iso_week_number(year, month, day) {
    	var first_day_of_year = julian_day(year, 1, 1);
    	var given_day_of_year = julian_day(year, month, day);
    	var day_of_week = (first_day_of_year + 3) % 7;
    	var week_of_year = (given_day_of_year - first_day_of_year + day_of_week + 4) / 7;
    	if (week_of_year == 53) {
			if (day_of_week == 6) {
            	return week_of_year;
        	} else if (day_of_week == 5 && is_leap_year(year)) {
            	return week_of_year;
        	} else {
            	return 1;
        	}
    	}
    	else if (week_of_year == 0) {
       		first_day_of_year = julian_day(year - 1, 1, 1);
        	day_of_week = (first_day_of_year + 3) % 7;
			return (given_day_of_year - first_day_of_year + day_of_week + 4) / 7;
    	}
    	else {
            return week_of_year;
    	}
	}
	
	
	hidden function julian_day(year, month, day) {
    	var a = (14 - month) / 12;
    	var y = (year + 4800 - a);
    	var m = (month + 12 * a - 3);
    	return day + ((153 * m + 2) / 5) + (365 * y) + (y / 4) - (y / 100) + (y / 400) - 32045;
	}
	
	
	hidden function is_leap_year(year) {
    	if (year % 4 != 0) {
        	return false;
   		 } else if (year % 100 != 0) {
        	return true;
    	} else if (year % 400 == 0) {
            return true;
    	}
		return false;
	}

    hidden function moon_phase(time) {
        var jd = julian_day(time.year, time.month, time.day);

        var days_since_new_moon = jd - 2459966;
        var lunar_cycle = 29.53;
        var phase = ((days_since_new_moon / lunar_cycle) * 100).toNumber() % 100;
        var into_cycle = (phase / 100.0) * lunar_cycle;

        if(time.month == 5 and time.day == 4) {
            return "8"; // That's no moon!
        }

        if (into_cycle < 3) { // 2+1
            return "0";
        } else if (into_cycle < 6) { // 4
            return "1";
        } else if (into_cycle < 10) { // 4
            return "2";
        } else if (into_cycle < 14) { // 4
            return "3";
        } else if (into_cycle < 18) { // 4
            return "4";
        } else if (into_cycle < 22) { // 4
            return "5";
        } else if (into_cycle < 26) { // 4
            return "6";
        } else if (into_cycle < 29) { // 3
            return "7";
        } else {
            return "0";
        }

    }

    hidden function formatDistanceByWidth(distance as Float, width as Number) as String {
        if (width == 3) {
            return distance < 10 ? distance.format("%.1f") : distance.format("%d");
        } else if (width == 4) {
            return distance < 100 ? distance.format("%.1f") : distance.format("%d");
        } else {  // width == 5
            return distance < 1000 ? distance.format("%05.1f") : distance.format("%05d");
        }
    }

    function formatPressure(pressureHpa as Float, numberFormat as String) as String {
        var pressureUnit = Application.Properties.getValue("pressureUnit");
        var val = "";

        if (pressureUnit == 0) { // hPA
            val = pressureHpa.format(numberFormat);
        } else if (pressureUnit == 1) { // mmHG
            val = (pressureHpa * 0.750062).format(numberFormat);
        } else if (pressureUnit == 2) { // inHG
            val = (pressureHpa * 0.02953).format("%.1f");
        }

        return val;
    }

}
