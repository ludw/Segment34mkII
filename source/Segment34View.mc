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

/* Indexes for the colors in the following array */
enum {
    labelFieldBg = 0,
    labelFieldLabel,
    labelTimeBg,
    labelTimeDisplay,
    labelTimeDisplayDim,
    labelDateDisplay,
    labelDateDisplayDim,
    labelDawnDuskLabel,
    labelDawnDuskValue,
    labelNotifications,
    labelStress,
    labelBodybattery,
    labelBackground,
    labelValueDisplay,
    labelMoonDisplay,
    labelLowBatt,
    /* Must stay last to count number of labels */
    labelNumber
}

/* All screen heights available. */
enum {
    screenHeight240,    /* 240px */
    screenHeight260,    /* 260px */
    screenHeight280,    /* 280px */
    screenHeight360,    /* 360px */
    screenHeight390,    /* 390px */
    screenHeight416,    /* 416px */
    screenHeight454,    /* 454px */
    screenHeightDefault
}

class Segment34View extends WatchUi.WatchFace {

    private var isSleeping as Boolean = false;
    private var doesPartialUpdate as Boolean = false;
    private var lastUpdate as Number or Null = null;
    private var canBurnIn as Boolean = false;

    private var screenWidth as Integer = 0;
    private var screenHeight as Number = 0;
    private var screenIndex as Integer = screenHeightDefault;
    private var clip_x as Integer = 0;
    private var clip_y as Integer = 0;
    private var clip_width as Integer = 0;
    private var clip_height as Integer = 0;

    private var previousEssentialsVis as Boolean or Null = null;
    private var batt as Number = 0;
    private var stress as Number = 0;
    private var weatherCondition as CurrentConditions or Null = null;
    private var nightMode as Boolean = false;
    private var ledSmallFont as Resource or Null = null;
    private var ledMidFont as Resource or Null = null;

    private var drawablesLoaded as Boolean = false;

    private var dbackground as Drawable or Null = null;
    private var dSecondsLabel as Text or Null = null;
    private var dAodPattern as Drawable or Null = null;
    private var dGradient as Drawable or Null = null;
    private var dAodDateLabel as Text or Null = null;
    private var dAodRightLabel as Text or Null  = null;
    private var dTimeLabel as Text or Null = null;
    private var dDateLabel as Text or Null = null;
    private var dTimeBg as Text or Null = null;
    private var dTtrBg as Text or Null = null;
    private var dHrBg as Text or Null = null;
    private var dActiveBg as Text or Null = null;
    private var dTtrDesc as Text or Null = null;
    private var dHrDesc as Text or Null = null;
    private var dActiveDesc as Text or Null = null;
    private var dMoonLabel as Text or Null = null;
    private var dDusk as Text or Null = null;
    private var dDawn as Text or Null = null;
    private var dSunUpLabel as Text or Null = null;
    private var dSunDownLabel as Text or Null = null;
    private var dWeatherLabel1 as Text or Null = null;
    private var dWeatherLabel2 as Text or Null = null;
    private var dNotifLabel as Text or Null = null;
    private var dTtrLabel as Text or Null = null;
    private var dActiveLabel as Text or Null = null;
    private var dStepBg as Text or Null = null;
    private var dStepLabel as Text or Null = null;
    private var dBattLabel as Text or Null = null;
    private var dBattBg as Text or Null = null;
    private var dHrLabel as Text or Null = null;
    private var dIcon1 as Text or Null = null;
    private var dIcon2 as Text or Null = null;

    private var propColorTheme as Number = 0;
    private var propOldColorTheme as Number = -1;
    private var propColorValues as Array<Lang.Integer> = new [labelNumber];
    private var propNightColorTheme as Number = -1;
    private var propOldNightColorTheme as Number = -1;
    private var propNightColorValues as Array<Lang.Integer> = new [labelNumber];
    private var propNightThemeActivation as Number = 0;
    private var propBatteryVariant as Number = 3;
    private var propShowSeconds as Boolean = true;
    private var propLeftValueShows as Number = 6;
    private var propMiddleValueShows as Number = 10;
    private var propRightValueShows as Number = 0;
    private var propAlwaysShowSeconds as Boolean = false;
    private var propHrUpdateFreq as Number = 0;
    private var propShowClockBg as Boolean = true;
    private var propShowDataBg as Boolean = false;
    private var propAodFieldShows as Number = -1;
    private var propAodRightFieldShows as Number = -2;
    private var propDateFieldShows as Number = -1;
    private var propBottomFieldShows as Number = 17;
    private var propAodAlignment as Number = 0;
    private var propDateAlignment as Number = 0;
    private var propIcon1 as Number = 1;
    private var propIcon2 as Number = 2;
    private var propHemisphere as Number = 0;
    private var propHourFormat as Number = 0;
    private var propZeropadHour as Boolean = true;
    private var propShowMoonPhase as Boolean = true;
    private var propTempUnit as Number = 0;
    private var propWindUnit as Number = 0;
    private var propPressureUnit as Number = 0;
    private var propWeatherLine1Shows as Number = 49;
    private var propWeatherLine2Shows as Number = 50;
    private var propSunriseFieldShows as Number = 39;
    private var propSunsetFieldShows as Number = 40;
    private var propDateFormat as Number = 0;
    private var propShowStressAndBodyBattery as Boolean = true;
    private var propShowNotificationCount as Boolean = true;
    private var propTzOffset1 as Number = 0;
    private var propTzOffset2 as Number = 0;
    private var propTzName1 as String = "";
    private var propTzName2 as String = "";
    private var propWeekOffset as Number = 0;
    private var propLabelVisibility as Number = 0;

    /* Complication data */

    /* AoD Data */
    private var aodDateMethod = self.method(:complicationType_Empty) as Method;
    private var aodDateUnit = "" as String;
    private var aodRightMethod = self.method(:complicationType_Empty) as Method;

    /* Date Data */
    private var dateFieldMethod = self.method(:complicationType_Empty) as Method;
    private var dateFieldUnit = "" as String;

    /* Top Data */
    private var sunriseFieldMethod = null as Method;
    private var sunriseFieldDesc = "" as String;
    private var sunsetFieldMethod = null as Method;
    private var sunsetFieldDesc = "" as String;

    private var weatherLine1Method = null as Method;
    private var weatherLine1Unit = null as String;
    private var weatherLine2Method = null as Method;
    private var weatherLine2Unit = null as String;

    /* Bottom data */
    private var leftCompLabel = null as String;
    private var leftCompMethod = null as Method;
    private var leftCompWidth = 0 as Integer;
    private var leftCompLabelSize = 2 as Integer;

    private var centerCompLabel = null;
    private var centerCompMethod = null as Method;
    private var centerCompWidth = 0 as Integer;
    private var centerCompLabelSize = 2 as Integer;

    private var rightCompLabel = null;
    private var rightCompMethod = null as Method;
    private var rightCompWidth = 0 as Integer;
    private var rightCompLabelSize = 3 as Integer;

    private var bottomCompMethod = null as Method;

    /* Implementation of existing functions */
    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
        cacheDrawables(dc);
        cacheProps();
    }

    function onShow() as Void {
        updateWeather();
    }

    function onUpdate(dc as Dc) as Void {
        var clock_time = System.getClockTime();
        var now = Time.now().value();
        var update_everything = false;

        if(doesPartialUpdate) {
            dc.clearClip();
            doesPartialUpdate = false;
        }

        if(lastUpdate == null or now - lastUpdate > 30 or clock_time.sec % 60 == 0) {
            update_everything = true;
            canBurnIn = System.getDeviceSettings().requiresBurnInProtection;
            lastUpdate = now;

            if(clock_time.min % 5 == 0 or weatherCondition == null) {
                updateWeather();
            }

            if (updateNightMode()){
                previousEssentialsVis = null;
            }
        }

        toggleNonEssentials(dc);

        if(!isSleeping && !update_everything) {
            if(propShowSeconds) {
                setSeconds(dc);
            }

            if(propHrUpdateFreq == 1 and clock_time.sec % 5 == 0) { // Every 5 seconds
                setBottomFields(dc);
            } else if(propHrUpdateFreq == 2) { // Every second
                setBottomFields(dc);
            }
        }

        if(update_everything) {
            setClock(dc);
            setDate(dc);
            if(!isSleeping or !canBurnIn) {
                setSeconds(dc);
                setBottomFields(dc);
                setNotif(dc);
                setMoon(dc);
                setWeather(dc);
                setWeatherLabel();
                setSunUpDown(dc);
                setStep(dc);
                setBatt(dc);
                setIcons(dc);
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

        var clock_time = System.getClockTime();
        var sec_string = Lang.format("$1$", [clock_time.sec.format("%02d")]);

        /* No clipping for big screens */
        if(screenHeight > 280) { return; }

        dc.setClip(clip_x, clip_y, clip_width, clip_height);
        dc.setColor(getColor(labelBackground), getColor(labelBackground));
        dc.clear();
        dc.setColor(getColor(labelDateDisplay), Graphics.COLOR_TRANSPARENT);
        dc.drawText(clip_x, clip_y, ledSmallFont, sec_string, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function onSettingsChanged() as Void {
        lastUpdate = null;
        previousEssentialsVis = null;

        /* Retrieve all properties values */
        cacheProps();

        /* Update ressources that might have changed */
        updateNightMode();

        /* Update interface after changed settings */
        WatchUi.requestUpdate();
    }

    function onPowerBudgetExceeded() as Void {
        System.println("Power budget exceeded");
    }

    function onHide() as Void {
    }

    function onExitSleep() as Void {
        isSleeping = false;
        lastUpdate = null;
        cacheProps();
        updateNightMode();
        WatchUi.requestUpdate();
    }

    function onEnterSleep() as Void {
        isSleeping = true;
        lastUpdate = null;
        WatchUi.requestUpdate();
    }

    hidden function cacheDrawables(dc) as Void {
        updateScreenData(dc);

        dbackground = View.findDrawableById("background") as Drawable;
        dSecondsLabel = View.findDrawableById("SecondsLabel") as Text;
        dAodPattern = View.findDrawableById("aodPattern") as Drawable;
        dGradient = View.findDrawableById("gradient") as Drawable;
        dAodDateLabel = View.findDrawableById("AODDateLabel") as Text;
        dAodRightLabel = View.findDrawableById("AODRightLabel") as Text;
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
        dIcon1 = View.findDrawableById("Icon1") as Text;
        dIcon2 = View.findDrawableById("Icon2") as Text;

        /* We can now work on items */
        drawablesLoaded = true;
    }

    hidden function cacheProps() as Void {
        propColorTheme = Application.Properties.getValue("colorTheme") as Number;
        propNightColorTheme = Application.Properties.getValue("nightColorTheme") as Number;
        propNightThemeActivation = Application.Properties.getValue("nightThemeActivation") as Number;
        propBatteryVariant = Application.Properties.getValue("batteryVariant") as Number;
        propShowSeconds = Application.Properties.getValue("showSeconds") as Boolean;
        propAlwaysShowSeconds = Application.Properties.getValue("alwaysShowSeconds") as Boolean;
        propHrUpdateFreq = Application.Properties.getValue("hrUpdateFreq") as Number;
        propShowClockBg = Application.Properties.getValue("showClockBg") as Boolean;
        propShowDataBg = Application.Properties.getValue("showDataBg") as Boolean;
        propAodFieldShows = Application.Properties.getValue("aodFieldShows") as Number;
        propAodRightFieldShows = Application.Properties.getValue("aodRightFieldShows") as Number;
        propDateFieldShows = Application.Properties.getValue("dateFieldShows") as Number;
        propLeftValueShows = Application.Properties.getValue("leftValueShows") as Number;
        propMiddleValueShows = Application.Properties.getValue("middleValueShows") as Number;
        propRightValueShows = Application.Properties.getValue("rightValueShows") as Number;
        propBottomFieldShows = Application.Properties.getValue("bottomFieldShows") as Number;
        propAodAlignment = Application.Properties.getValue("aodAlignment") as Number;
        propDateAlignment = Application.Properties.getValue("dateAlignment") as Number;
        propIcon1 = Application.Properties.getValue("icon1") as Number;
        propIcon2 = Application.Properties.getValue("icon2") as Number;
        propHemisphere = Application.Properties.getValue("hemisphere") as Number;
        propHourFormat = Application.Properties.getValue("hourFormat") as Number;
        propZeropadHour = Application.Properties.getValue("zeropadHour") as Boolean;
        propShowMoonPhase = Application.Properties.getValue("showMoonPhase") as Boolean;
        propTempUnit = Application.Properties.getValue("tempUnit") as Number;
        propWindUnit = Application.Properties.getValue("windUnit") as Number;
        propPressureUnit = Application.Properties.getValue("pressureUnit") as Number;
        propWeatherLine1Shows = Application.Properties.getValue("weatherLine1Shows") as Number;
        propWeatherLine2Shows = Application.Properties.getValue("weatherLine2Shows") as Number;
        propSunriseFieldShows = Application.Properties.getValue("sunriseFieldShows") as Number;
        propSunsetFieldShows = Application.Properties.getValue("sunsetFieldShows") as Number;
        propLabelVisibility = Application.Properties.getValue("labelVisibility") as Number;

        propDateFormat = Application.Properties.getValue("dateFormat") as Number;
        propShowStressAndBodyBattery = Application.Properties.getValue("showStressAndBodyBattery") as Boolean;
        propShowNotificationCount = Application.Properties.getValue("showNotificationCount") as Boolean;
        propTzOffset1 = Application.Properties.getValue("tzOffset1") as Number;
        propTzOffset2 = Application.Properties.getValue("tzOffset2") as Number;
        propTzName1 = Application.Properties.getValue("tzName1") as String;
        propTzName2 = Application.Properties.getValue("tzName2") as String;
        propWeekOffset = Application.Properties.getValue("weekOffset") as Number;

        /* Update all the colors used for this theme */
        if (propColorTheme != propOldColorTheme) {
            updateThemeColors(propColorTheme, propColorValues);
            propOldColorTheme = propColorTheme;
        }
        if ((propNightColorTheme >= 0) && (propNightColorTheme != propOldNightColorTheme)) {
            updateThemeColors(propNightColorTheme, propNightColorValues);
            propOldNightColorTheme = propNightColorTheme;
        }

        /* Update the settings for all complications */
        updateComplicationsData();

        /* Setting up fonts */
        loadFontResource();
    }

    hidden function toggleNonEssentials(dc as Dc) as Void {
        var awake = !isSleeping;
        if(isSleeping and canBurnIn) {
            dc.setAntiAlias(false);
            var clock_time = System.getClockTime();
            dGradient.setVisible(false);
            dAodPattern.setVisible(true);
            if(propAodFieldShows != -2) {
                dAodDateLabel.setVisible(true);
            } else {
                dAodDateLabel.setVisible(false);
            }
            if(propAodRightFieldShows != -2) {
                dAodRightLabel.setVisible(true);
            } else {
                dAodRightLabel.setVisible(false);
            }
            dAodPattern.setLocation(clock_time.min % 2, dAodPattern.locY);
            setAlignment(propAodAlignment, dAodDateLabel, (clock_time.min % 3) - 1);
            alignAODRightField((clock_time.min % 3) - 1);
            dAodDateLabel.setColor(getColor(labelDateDisplayDim));
            dAodRightLabel.setColor(getColor(labelDateDisplayDim));
            dbackground.setVisible(false);
        } else {
            dc.setAntiAlias(true);
        }

        if(previousEssentialsVis == awake) {
            return;
        }

        var hide_In_aod = (awake or !canBurnIn);
        var hide_battery = (hide_In_aod && propBatteryVariant != 2);

        if(propAlwaysShowSeconds and propShowSeconds and !canBurnIn) {
            dSecondsLabel.setVisible(true);
        } else {
            dSecondsLabel.setVisible(awake && propShowSeconds);
        }

        setVisibility3(propLeftValueShows, dTtrDesc, dTtrLabel, dTtrBg);
        setVisibility3(propMiddleValueShows, dHrDesc, dHrLabel, dHrBg);
        setVisibility3(propRightValueShows, dActiveDesc, dActiveLabel, dActiveBg);
        setVisibility2(propBottomFieldShows, dStepLabel, dStepBg);

        setAlignment(propDateAlignment, dDateLabel, 0);
        alignNotification(propDateAlignment);

        dDateLabel.setVisible(hide_In_aod);
        dHrDesc.setVisible(hide_In_aod);
        dActiveDesc.setVisible(hide_In_aod);
        dMoonLabel.setVisible(hide_In_aod);
        dDusk.setVisible(hide_In_aod);
        dDawn.setVisible(hide_In_aod);
        dSunUpLabel.setVisible(hide_In_aod);
        dSunDownLabel.setVisible(hide_In_aod);
        dWeatherLabel1.setVisible(hide_In_aod);
        dWeatherLabel2.setVisible(hide_In_aod);
        dNotifLabel.setVisible(hide_In_aod);
        dWeatherLabel2.setVisible(hide_In_aod);
        dTimeBg.setVisible(hide_In_aod and propShowClockBg);
        dBattLabel.setVisible(hide_battery);
        dBattBg.setVisible(hide_battery);
        dIcon1.setVisible(hide_In_aod);
        dIcon2.setVisible(hide_In_aod);
        
        dTimeLabel.setColor(getColor(labelTimeDisplay));
        dTimeBg.setColor(getColor(labelTimeBg));
        dTtrBg.setColor(getColor(labelFieldBg));
        dHrBg.setColor(getColor(labelFieldBg));
        dActiveBg.setColor(getColor(labelFieldBg));
        dStepBg.setColor(getColor(labelFieldBg));
        dTtrDesc.setColor(getColor(labelFieldLabel));
        dHrLabel.setColor(getColor(labelValueDisplay));
        dHrDesc.setColor(getColor(labelFieldLabel));
        dActiveDesc.setColor(getColor(labelFieldLabel));
        dDateLabel.setColor(getColor(labelDateDisplay));
        dSecondsLabel.setColor(getColor(labelDateDisplay));
        dNotifLabel.setColor(getColor(labelNotifications));
        dMoonLabel.setColor(getColor(labelMoonDisplay));
        dDusk.setColor(getColor(labelDawnDuskLabel));
        dDawn.setColor(getColor(labelDawnDuskLabel));
        dSunUpLabel.setColor(getColor(labelDawnDuskValue));
        dSunDownLabel.setColor(getColor(labelDawnDuskValue));
        dWeatherLabel1.setColor(getColor(labelValueDisplay));
        dWeatherLabel2.setColor(getColor(labelValueDisplay));
        dTtrLabel.setColor(getColor(labelValueDisplay));
        dActiveLabel.setColor(getColor(labelValueDisplay));
        dStepLabel.setColor(getColor(labelValueDisplay));
        dBattBg.setColor(0x555555);
        
        if(System.getSystemStats().battery > 15) {
            dBattLabel.setColor(getColor(labelValueDisplay));
        } else {
            dBattLabel.setColor(getColor(labelLowBatt));
        }

        if(hide_In_aod) {
            if(getColor(labelBackground) == 0xFFFFFF) {
                dbackground.setVisible(true);
            } else {
                dbackground.setVisible(false);
            }
        }

        if(awake) {
            if(canBurnIn) {
                dAodPattern.setVisible(false);
                dAodDateLabel.setVisible(false);
                dAodRightLabel.setVisible(false);

                if(getColor(labelBackground) == 0xFFFFFF) {
                    dGradient.setVisible(false);
                } else {
                    dGradient.setVisible(true);
                }
            }
        }

        previousEssentialsVis = awake;
    }

    hidden function updateScreenData(dc) as Void {
        /* Update all screen data */
        screenHeight = dc.getHeight();
        screenWidth = dc.getWidth();

        /* Setting index */
        if      (screenHeight == 240) { screenIndex = screenHeight240; }
        else if (screenHeight == 260) { screenIndex = screenHeight260; }
        else if (screenHeight == 280) { screenIndex = screenHeight280; }
        else if (screenHeight == 360) { screenIndex = screenHeight360; }
        else if (screenHeight == 390) { screenIndex = screenHeight390; }
        else if (screenHeight == 416) { screenIndex = screenHeight416; }
        else if (screenHeight == 454) { screenIndex = screenHeight454; }
        else                          { screenIndex = screenHeightDefault; }

        if (screenHeight <= 280) {
            /* No clipping above 280px so no entries in the array */
            var screenClipValues = [
                /* size         clipX, clipY, clipWidth, clipHeight */
                /* 240px */   [   205,   157,        24,        20 ],
                /* 260px */   [   220,   162,        24,        20 ],
                /* 280px */   [   235,   170,        24,        20 ],
            ] as Array<Array<Integer>>;

            clip_x      = screenClipValues[screenIndex][0];
            clip_y      = screenClipValues[screenIndex][1];
            clip_width  = screenClipValues[screenIndex][2];
            clip_height = screenClipValues[screenIndex][3];
        } else {
            clip_x      = 0;
            clip_y      = 0;
            clip_width  = 0;
            clip_height = 0;
        }
    }

    hidden function loadFontResource() as Void {
        var fontVariant = Application.Properties.getValue("smallFontVariant") as Number;

        // Only load the font we need for this watch size
        if (screenHeight <= 280) {
            ledMidFont = null;

            if(fontVariant == 0) {
                ledSmallFont = Application.loadResource( Rez.Fonts.id_led_small );
            } else if(fontVariant == 1) {
                ledSmallFont = Application.loadResource( Rez.Fonts.id_led_small_readable );
            } else {
                ledSmallFont = Application.loadResource( Rez.Fonts.id_led_small_lines );
            }
        } else {
            ledSmallFont = null;

            if(fontVariant == 0) {
                ledMidFont = Application.loadResource( Rez.Fonts.id_led );
            } else if(fontVariant == 1) {
                ledMidFont = Application.loadResource( Rez.Fonts.id_led_inbetween );
            } else {
                ledMidFont = Application.loadResource( Rez.Fonts.id_led_lines );
            }
        }

        /* Update components */
        /* First check if drawables are loaded */
        if (drawablesLoaded == false) { return; }

        var font = ledSmallFont as Application.ResourceReferenceType;
        if(screenHeight > 280) {
            font = ledMidFont;
            dAodDateLabel.setFont(font);
            dAodRightLabel.setFont(font);
        }

        dDateLabel.setFont    (font);
        dSecondsLabel.setFont (font);
        dNotifLabel.setFont   (font);
        dWeatherLabel1.setFont(font);
        dWeatherLabel2.setFont(font);
    }

    hidden function getComplicationMethod(compType as Integer) as Method {
        switch (compType) {
            case -1: return self.method(:complicationType_Date);// [-1] Date
            case 0: return self.method(:complicationType_0);    //  [0] Active min / week
            case 1: return self.method(:complicationType_1);    //  [1] Active min / day
            case 2: return self.method(:complicationType_2);    //  [2] distance (km) / day
            case 3: return self.method(:complicationType_3);    //  [3] distance (miles) / day
            case 4: return self.method(:complicationType_4);    //  [4] floors climbed / day
            case 5: return self.method(:complicationType_5);    //  [5] meters climbed / day
            case 6: return self.method(:complicationType_6);    //  [6] Time to Recovery (h)
            case 7: return self.method(:complicationType_7);    //  [7] VO2 Max Running
            case 8: return self.method(:complicationType_8);    //  [8] VO2 Max Cycling
            case 9: return self.method(:complicationType_9);    //  [9] Respiration rate
            case 10: return self.method(:complicationType_10);  // [10] HR, done in function
            case 11: return self.method(:complicationType_11);  // [11] Calories / day
            case 12: return self.method(:complicationType_12);  // [12] Altitude (m)
            case 13: return self.method(:complicationType_13);  // [13] Stress
            case 14: return self.method(:complicationType_14);  // [14] Body battery
            case 15: return self.method(:complicationType_15);  // [15] Altitude (ft)
            case 16: return self.method(:complicationType_16);  // [16] Alt TZ 1, done in function
            case 17: return self.method(:complicationType_17);  // [17] Steps / day
            case 18: return self.method(:complicationType_18);  // [18] Distance (m) / day
            case 19: return self.method(:complicationType_19);  // [19] Wheelchair pushes
            case 20: return self.method(:complicationType_20);  // [20] Weather condition
            case 21: return self.method(:complicationType_21);  // [21] Weekly run distance (km)
            case 22: return self.method(:complicationType_22);  // [22] Weekly run distance (miles)
            case 23: return self.method(:complicationType_23);  // [23] Weekly bike distance (km)
            case 24: return self.method(:complicationType_24);  // [24] Weekly bike distance (miles)
            case 25: return self.method(:complicationType_25);  // [25] Training status
            case 26: return self.method(:complicationType_26);  // [26] Barometric pressure (hPA)
            case 27: return self.method(:complicationType_27);  // [27] Weight kg
            case 28: return self.method(:complicationType_28);  // [28] Weight lbs
            case 29: return self.method(:complicationType_29);  // [29] Act Calories / day
            case 30: return self.method(:complicationType_30);  // [30] Sea level pressure (hPA)
            case 31: return self.method(:complicationType_31);  // [31] Week number
            case 32: return self.method(:complicationType_32);  // [32] Weekly distance (km)
            case 33: return self.method(:complicationType_33);  // [33] Weekly distance (miles)
            case 34: return self.method(:complicationType_34);  // [34] Battery percentage
            case 35: return self.method(:complicationType_35);  // [35] Battery days remaining
            case 36: return self.method(:complicationType_36);  // [36] Notification count
            case 37: return self.method(:complicationType_37);  // [37] Solar intensity
            case 38: return self.method(:complicationType_38);  // [38] Sensor temp
            case 39: return self.method(:complicationType_39);  // [39] Sunrise
            case 40: return self.method(:complicationType_40);  // [40] Sunset
            case 41: return self.method(:complicationType_41);  // [41] Alt TZ 2:
            case 42: return self.method(:complicationType_42);  // [42] Alarms
            case 43: return self.method(:complicationType_43);  // [43] Daily high temp
            case 44: return self.method(:complicationType_44);  // [44] Daily low temp
            case 45: return self.method(:complicationType_45);  // [45] empty for offset 45
            case 46: return self.method(:complicationType_46);  // [46] empty for offset 46
            case 47: return self.method(:complicationType_47);  // [47] empty for offset 47
            case 48: return self.method(:complicationType_48);  // [48] empty for offset 48
            case 49: return self.method(:complicationType_49);  // [49] empty for offset 49
            case 50: return self.method(:complicationType_50);  // [50] empty for offset 50
            case 51: return self.method(:complicationType_51);  // [51] empty for offset 51
            case 52: return self.method(:complicationType_52);  // [52] empty for offset 52
            case 53: return self.method(:complicationType_53);  // [53] Temperature
            case 54: return self.method(:complicationType_54);  // [54] Precipitation
            case 55: return self.method(:complicationType_55);  // [55] Next sun event
            case 56: return self.method(:complicationType_56);  // [56] Military Date Time
            case 57: return self.method(:complicationType_57);  // [57] Time of next calendar Event
            case 58: return self.method(:complicationType_58);  // [58] Active / Total Calories
            case 59: return self.method(:complicationType_59);  // [59] PulseOx
            default: return self.method(:complicationType_Empty); // Empty by default
        }
    }

    /* For each complication, update description, unit, and update method */
    hidden function updateComplicationsData() as Void {
        /*** Top Complications ***/

        /* AoD complication */
        if(canBurnIn) {
            if(propAodFieldShows != -1) {
                aodDateUnit = getComplicationUnit(propAodFieldShows);
                if (aodDateUnit.length() > 0) {
                    aodDateUnit = Lang.format(" $1$", [aodDateUnit]);
                }
                aodDateMethod = getComplicationMethod(propAodFieldShows);
            }

            aodRightMethod = getComplicationMethod(propAodRightFieldShows);
        }

        /*  Date complication */
        dateFieldUnit = getComplicationUnit(propDateFieldShows);
        if (dateFieldUnit.length() > 0) { dateFieldUnit = Lang.format(" $1$", [dateFieldUnit]); }
        dateFieldMethod = getComplicationMethod(propDateFieldShows);

        /* Sun events */
        if(propSunriseFieldShows == -2) {
            sunriseFieldDesc = "";
            sunriseFieldMethod = self.method(:complicationType_Empty);
        } else {
            sunriseFieldDesc = getComplicationDesc(propSunriseFieldShows, 1);
            sunriseFieldMethod = getComplicationMethod(propSunriseFieldShows);
        }

        if(propSunsetFieldShows == -2) {
            sunsetFieldDesc = "";
            sunsetFieldMethod = self.method(:complicationType_Empty);
        } else {
            sunsetFieldDesc = getComplicationDesc(propSunsetFieldShows, 1);
            sunsetFieldMethod = getComplicationMethod(propSunsetFieldShows);

            // hide labels if so configured
            if (propLabelVisibility == 1 or propLabelVisibility == 2) {
                dDawn.setVisible(false);
                dDusk.setVisible(false);
            }
        }

        /* Weather complications */
        weatherLine1Unit = getComplicationUnit(propWeatherLine1Shows);
        if (weatherLine1Unit.length() > 0) {
            weatherLine1Unit = Lang.format(" $1$", [weatherLine1Unit]);
        }
        weatherLine1Method = getComplicationMethod(propWeatherLine1Shows);

        weatherLine2Unit = getComplicationUnit(propWeatherLine2Shows);
        if (weatherLine2Unit.length() > 0) {
            weatherLine2Unit = Lang.format(" $1$", [weatherLine2Unit]);
        }
        weatherLine2Method = getComplicationMethod(propWeatherLine2Shows);

        /*** Bottom Complications ***/
        /* Left label */
        leftCompWidth = 3;
        leftCompLabelSize = 2;
        if(screenWidth > 450) {
            leftCompWidth = 4;
            leftCompLabelSize = 3;
        }
        leftCompLabel = getComplicationDesc(propLeftValueShows, leftCompLabelSize);
        leftCompMethod = getComplicationMethod(propLeftValueShows);

        /* Center label */
        centerCompWidth = 3;
        centerCompLabelSize = 2;
        if(screenWidth > 450) {
            centerCompWidth = 4;
            centerCompLabelSize = 3;
        }
        centerCompLabel = getComplicationDesc(propMiddleValueShows, centerCompLabelSize);
        centerCompMethod = getComplicationMethod(propMiddleValueShows);

        /* Right label */
        rightCompWidth = 4;
        rightCompLabelSize = 3;
        if(screenWidth == 240) {
            rightCompWidth = 3;
            rightCompLabelSize = 2;
        }
        rightCompLabel = getComplicationDesc(propRightValueShows, rightCompLabelSize);
        rightCompMethod = getComplicationMethod(propRightValueShows);

        /* Bottom field */
        bottomCompMethod = getComplicationMethod(propBottomFieldShows);
    }

    hidden function setVisibility2(setting as Number, label as Text, bg as Text) as Void {
        var hide_In_aod = (!isSleeping or !canBurnIn);
        if(setting == -2) {
            label.setVisible(false);
            bg.setVisible(false);
        } else {
            label.setVisible(hide_In_aod);
            bg.setVisible(hide_In_aod and propShowDataBg);
        }
    }

    hidden function setVisibility3(setting as Number, desc as Text, label as Text, bg as Text) as Void {
        var hide_In_aod = (!isSleeping or !canBurnIn);
        if(setting == -2) {
            desc.setVisible(false);
            label.setVisible(false);
            bg.setVisible(false);
        } else {
            desc.setVisible(hide_In_aod);
            label.setVisible(hide_In_aod);
            bg.setVisible(hide_In_aod and propShowDataBg);
        }
    }

    hidden function setAlignment(setting as Number, label as Text, offset as Number) as Void {
        /* Screen alignement values :   240px, 260px 280px, 360px, 390px, 416px, 454px, Default */
        var screenAlignValues =       [ 10,    16,   25,    15,    17,    31,    23,    0 ];
        var x = screenAlignValues[screenIndex];

        if(setting == 0) { // Left align
            label.setJustification(Graphics.TEXT_JUSTIFY_LEFT);
            label.setLocation(x + offset, label.locY);
        } else { // Center align
            label.setJustification(Graphics.TEXT_JUSTIFY_CENTER);
            label.setLocation(Math.floor(screenHeight / 2) + offset, label.locY);
        }
    }

    hidden function alignAODRightField(offset as Number) as Void {
        var x = 0;
        if(screenHeight == 360) { x = 345; }
        if(screenHeight == 390) { x = 371; }
        if(screenHeight == 416) { x = 385; }
        if(screenHeight == 454) { x = 433; }

        dAodRightLabel.setLocation(x + offset, dAodRightLabel.locY);
    }
 
    hidden function alignNotification(setting as Number) as Void {
        var x = 0;
        var alignment = Graphics.TEXT_JUSTIFY_RIGHT;

        if(setting == 1) { // Date is centered, left align notif
            /* Screen notification alignement :    240px, 260px 280px, 360px, 390px, 416px, 454px, Default */
            var screenNotifLeft  =     [ 10,    16,   25,    15,    17,    31,    23,    0 ];
            x = screenNotifLeft[screenIndex];
            alignment = Graphics.TEXT_JUSTIFY_LEFT;
        } else { // Date is left aligned, put notif after
            /* Screen notification alignement :    240px, 260px 280px, 360px, 390px, 416px, 454px, Default */
            var screenNotifAfter =     [ 195,   210,  220,   297,   317,   331,   379,   0 ];
            x = screenNotifAfter[screenIndex];
            alignment = Graphics.TEXT_JUSTIFY_RIGHT;
        }

        dNotifLabel.setJustification(alignment);
        dNotifLabel.setLocation(x, dNotifLabel.locY);
    }

    /* Update the current colors for the requested theme. This function is only called
       when settings are changed.
       The AMOLED values redundant with the MIP profiles are commented to save on memory.
     */
    hidden function updateThemeColors(themeSettings as Number, arrayToFill as Array<Number>) as Void {
        var amoled = canBurnIn ? 1 : 0 as Integer;

        /* Which theme are we using ? */
        var listOfThemes = [ 
            Rez.JsonData.yellow_on_turquoise,
            Rez.JsonData.hot_pink,
            Rez.JsonData.blueish_green,
            Rez.JsonData.very_green,
            Rez.JsonData.white_on_turquoise,
            Rez.JsonData.orange,
            Rez.JsonData.red_and_white,
            Rez.JsonData.white_on_blue,
            Rez.JsonData.yellow_on_blue,
            Rez.JsonData.white_and_orange,
            Rez.JsonData.blue,
            Rez.JsonData.peachy_orange,
            Rez.JsonData.white_on_black,
            Rez.JsonData.black_on_white,
            Rez.JsonData.red_on_white,
            Rez.JsonData.blue_on_white,
            Rez.JsonData.green_on_white,
            Rez.JsonData.orange_on_white,
            Rez.JsonData.green_and_orange,
            Rez.JsonData.green_camo,
            Rez.JsonData.red_on_black,
            Rez.JsonData.purple_on_white,
            Rez.JsonData.purple_on_black,
         ] as Array<ResourceId>;

        /* Load the color array in JSON */
        var themeArray = Application.loadResource(listOfThemes[themeSettings]) as Array<Array<String>>;

        for (var ii = 0; ii < labelNumber; ii++) {
            arrayToFill[ii] = themeArray[amoled][ii].toNumberWithBase(16);
        }
    }

    hidden function getColor(colorName) as Graphics.ColorType {
        /* Check whether we are AMOLED or MIP */ 
        var amoled = canBurnIn ?    1   :   0;
        var array_to_use = propColorValues;

        if (propNightColorTheme != -1 && nightMode) {
            array_to_use = propNightColorValues;
        }

        var color = array_to_use[colorName];

        /* Handle special cases */
        if(colorName == labelTimeDisplay && isSleeping && amoled) {
            /* Get the dimmed version instead */
            color = array_to_use[labelTimeDisplayDim];
        }

        return color;
    }

    hidden function setSeconds(dc as Dc) as Void {
        var clock_time = System.getClockTime();
        var sec_string = Lang.format("$1$", [clock_time.sec.format("%02d")]);
        dSecondsLabel.setText(sec_string);
    }

    hidden function setClock(dc as Dc) as Void {
        var clock_time = System.getClockTime();
        var hour = formatHour(clock_time.hour);
        var time_string = "";
        if(propZeropadHour) {
            time_string = Lang.format("$1$:$2$", [hour.format("%02d"), clock_time.min.format("%02d")]);
        } else {
            time_string = Lang.format("$1$:$2$", [hour.format("%2d"), clock_time.min.format("%02d")]);
        }

        dTimeLabel.setText(time_string);
    }

    hidden function formatHour(hour as Number) as Number {
        if((!System.getDeviceSettings().is24Hour and propHourFormat == 0) or propHourFormat == 2) {
            hour = hour % 12;
            if(hour == 0) { hour = 12; }
        }
        return hour;
    }

    hidden function setMoon(dc as Dc) as Void {
        if(propShowMoonPhase) {
            var now = Time.now();
            var today = Time.Gregorian.info(now, Time.FORMAT_SHORT);
            var moonVal = moonPhase(today);
            dMoonLabel.setText(moonVal);
        } else {
            dMoonLabel.setText("");
        }
    }

    hidden function setBatt(dc as Dc) as Void {
        var visible = (!isSleeping or !canBurnIn) && propBatteryVariant != 2;  // Only show if not in AOD and battery is not hidden
        var value = "";

        if(propBatteryVariant == 0) {
            if(System.getSystemStats() has :batteryInDays) {
                if (System.getSystemStats().batteryInDays != null){
                    var sample = Math.round(System.getSystemStats().batteryInDays);
                    value = Lang.format("$1$D", [sample.format("%0d")]);
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
        } else if(propBatteryVariant == 3) {
            var sample = 0;
            var max = 0;
            if(screenHeight > 280) {
                sample = Math.round(System.getSystemStats().battery / 100.0 * 35);
                max = 35;
            } else {
                sample = Math.round(System.getSystemStats().battery / 100.0 * 20);
                max = 20;
            }
            
            for(var i = 0; i < sample; i++) {
                value += "|";
            }

            for(var i = 0; i < max-sample; i++) {
                value += "{"; // rendered as 1px space to always fill the same number of px
            }
        }

        dBattBg.setVisible(visible);
        dBattLabel.setText(value);
    }

    hidden function updateWeather() as Void {
        var now = Time.now().value();
        // Clear cached weather if older than 3 hours
        if(weatherCondition != null 
           and weatherCondition.observationTime != null 
           and (now - weatherCondition.observationTime.value() > 3600 * 3)) {
            weatherCondition = null;
        }

        if(Weather.getCurrentConditions != null) {
            weatherCondition = Weather.getCurrentConditions();
        }
    }

    hidden function formatTemperature(temp as Number, unit as String) as Number {
        if(unit.equals("C")) {
            return temp;
        } else {
            return ((temp * 9/5) + 32);
        }
    }

    hidden function formatTemperatureFloat(temp as Float, unit as String) as Float {
        if(unit.equals("C")) {
            return temp;
        } else {
            return ((temp * 9/5) + 32);
        }
    }

    hidden function getTempUnit() as String {
        var temp_unit_setting = System.getDeviceSettings().temperatureUnits;
        if((temp_unit_setting == System.UNIT_METRIC and propTempUnit == 0) or propTempUnit == 1) {
            return "C";
        } else {
            return "F";
        }
    }

    hidden function setWeather(dc as Dc) as Void {
        dWeatherLabel1.setText(Lang.format("$1$$2$", [weatherLine1Method.invoke("%01d", 10), weatherLine1Unit]));
    }

    hidden function setWeatherLabel() as Void {
        dWeatherLabel2.setText(Lang.format("$1$$2$", [weatherLine2Method.invoke("%01d", 10), weatherLine2Unit]));
    }

    hidden function getWeatherCondition(includePrecipitation as Boolean) as String {
        var condition;
        var perp = "";

        // Early return if no weather data
        if (weatherCondition == null || weatherCondition.condition == null) {
            return "";
        }

        // Safely check precipitation chance
        if(includePrecipitation) {
            if (weatherCondition has :precipitationChance &&
                weatherCondition.precipitationChance != null &&
                weatherCondition.precipitationChance instanceof Number) {
                if(weatherCondition.precipitationChance > 0) {
                    perp = Lang.format(" ($1$%)", [weatherCondition.precipitationChance.format("%02d")]);
                }
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

    hidden function getRestCalories() as Number {
        var today = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var profile = UserProfile.getProfile();

        if (profile has :weight && profile has :height && profile has :birthYear) {
            var age = today.year - profile.birthYear;
            var weight = profile.weight / 1000.0;
            var rest_calories = 0;

            if (profile.gender == UserProfile.GENDER_MALE) {
                rest_calories = 5.2 - 6.116 * age + 7.628 * profile.height + 12.2 * weight;
            } else {
                rest_calories = -197.6 - 6.116 * age + 7.628 * profile.height + 12.2 * weight;
            }

            // Calculate rest calories for the current time of day
            rest_calories = Math.round((today.hour * 60 + today.min) * rest_calories / 1440).toNumber();
            return rest_calories;
        } else {
            return -1;
        }
    }

    hidden function setSunUpDown(dc as Dc) as Void {
        dDawn.setText(getLiveComplicationDesc(propSunriseFieldShows, 1, sunriseFieldDesc));
        dSunUpLabel.setText(sunriseFieldMethod.invoke("%01d", 5));

        dDusk.setText(getLiveComplicationDesc(propSunsetFieldShows, 1, sunsetFieldDesc));
        dSunDownLabel.setText(sunsetFieldMethod.invoke("%01d", 5));
        if (propLabelVisibility == 1 or propLabelVisibility == 2) {
            dDawn.setVisible(false);
            dDusk.setVisible(false);
        }
    }

    hidden function setNotif(dc as Dc) as Void {
        var value = "";

        if(propShowNotificationCount) {
            var sample = System.getDeviceSettings().notificationCount;
            if(sample > 0) {
                value = sample.format("%01d");
            }

            dNotifLabel.setText(value);
        } else {
            dNotifLabel.setText("");
        }
    }

    hidden function setIcons(dc as Dc) as Void {
        dIcon1.setText(getIconState(propIcon1));
        dIcon2.setText(getIconState(propIcon2));
    }

    hidden function getIconState(setting as Number) as String {
        if(setting == 1) { // Alarm
            var alarms = System.getDeviceSettings().alarmCount;
            if(alarms > 0) {
                return "A";
            } else {
                return "";
            }
        } else if(setting == 2) { // DND
            var dnd = System.getDeviceSettings().doNotDisturb;
            if(dnd) {
                return "D";
            } else {
                return "";
            }
        } else if(setting == 3) { // Bluetooth (on / off)
            var bl = System.getDeviceSettings().phoneConnected;
            if(bl) {
                return "L";
            } else {
                return "M";
            }
        } else if(setting == 4) { // Bluetooth (just off)
            var bl = System.getDeviceSettings().phoneConnected;
            if(bl) {
                return "";
            } else {
                return "M";
            }
        } else if(setting == 5) { // Move bar
            var mov = 0;
            if(ActivityMonitor.getInfo() has :moveBarLevel) {
                if(ActivityMonitor.getInfo().moveBarLevel != null) {
                    mov = ActivityMonitor.getInfo().moveBarLevel;
                }
            }
            if(mov == 0) { return ""; }
            if(mov == 1) { return "N"; }
            if(mov == 2) { return "O"; }
            if(mov == 3) { return "P"; }
            if(mov == 4) { return "Q"; }
            if(mov == 5) { return "R"; }
        }
        return "";
    }

    hidden function setDate(dc as Dc) as Void {
        dDateLabel.setText(Lang.format("$1$$2$", [dateFieldMethod.invoke("%01d", 10), dateFieldUnit]));

        if(canBurnIn) {
            dAodDateLabel.setText(Lang.format("$1$$2$", [aodDateMethod.invoke("%01d", 10), aodDateUnit]));
            dAodRightLabel.setText(aodRightMethod.invoke("%01d", 3));
        }
    }

    hidden function setStep(dc as Dc) as Void {
        dStepLabel.setText(bottomCompMethod.invoke("%05d", 5));
    }

    hidden function updateNightMode() as Boolean {
        var oldNightMode = nightMode;

        if (propNightColorTheme == -1 || propNightColorTheme == propColorTheme) {
            nightMode = false;
            return (oldNightMode != nightMode);
        }

        var now = Time.now(); // Moment
        var todayMidnight = Time.today(); // Moment
        var nowAsTimeSinceMidnight = now.subtract(todayMidnight) as Duration; // Duration

        if(propNightThemeActivation == 0 or propNightThemeActivation == 1) {
            var profile = UserProfile.getProfile();
            if ((profile has :wakeTime) == false || (profile has :sleepTime) == false) {
                nightMode = false;
                return (oldNightMode != nightMode);
            }

            var wakeTime = profile.wakeTime;
            var sleepTime = profile.sleepTime;

            if (wakeTime == null || sleepTime == null) {
                nightMode = false;
                return (oldNightMode != nightMode);
            }

            if(propNightThemeActivation == 0) {
                nightMode = (nowAsTimeSinceMidnight.greaterThan(sleepTime) || nowAsTimeSinceMidnight.lessThan(wakeTime));
                return (oldNightMode != nightMode);
            } else { // Start two hours before sleep time
                var twoHours = new Time.Duration(7200);
                sleepTime = sleepTime.subtract(twoHours);
                nightMode = (nowAsTimeSinceMidnight.greaterThan(sleepTime) || nowAsTimeSinceMidnight.lessThan(wakeTime));
                return (oldNightMode != nightMode);
            }
        }

        // From Sunset to Sunrise
        if(weatherCondition != null) {
            var nextSunEventArray = getNextSunEvent();
            if(nextSunEventArray != null && nextSunEventArray.size() == 2) { 
                nightMode = nextSunEventArray[1] as Boolean;
                return (oldNightMode != nightMode);
            }
        }

        return false;
    }

    hidden function updateStressAndBodyBatteryData() as Void {
        if(!propShowStressAndBodyBattery) { return; }

        if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory) && (Toybox.SensorHistory has :getStressHistory)) {
            var bb_iterator = Toybox.SensorHistory.getBodyBatteryHistory({:period => 1});
            var st_iterator = Toybox.SensorHistory.getStressHistory({:period => 1});
            var bb = bb_iterator.next();
            var st = st_iterator.next();

            if(bb != null) {
                batt = bb.data;
            }
            if(st != null) {
                stress = st.data;
            }
        }
    }

    hidden function drawStressAndBodyBattery(dc as Dc) as Void {
        if(!propShowStressAndBodyBattery) { return; }

        if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory) && (Toybox.SensorHistory has :getStressHistory)) {
            var stressAndBodyBatteryMeasures = [
                /* screenHeight, barTop, fromEdge, barWidth, barHeight, bbAdjustement, fromEdgeSleeping */
                /* 240px */    [  72,     5,       3,        80,        1,             5 ],
                /* 260px */    [  77,    10,       3,        80,        1,            10 ],
                /* 280px */    [  83,    14,       3,        80,       -1,            14 ],
                /* 360px */    [ 103,     3,       3,        125,      -1,             0 ],
                /* 390px */    [ 111,     8,       4,        125,       0,             4 ],
                /* 416px */    [ 122,    15,       4,        125,       0,            10 ],
                /* 454px */    [ 146,    12,       4,        145,       0,             8 ],
                /* Default */  [ 110,     8,       4,        125,       0,             8 ]
            ] as Array<Array<Number>>;

            var bar_top =       stressAndBodyBatteryMeasures[screenIndex][0] as Number;
            var from_edge =     stressAndBodyBatteryMeasures[screenIndex][1] as Number;
            var bar_width =     stressAndBodyBatteryMeasures[screenIndex][2] as Number;
            var bar_height =    stressAndBodyBatteryMeasures[screenIndex][3] as Number;
            var bb_adjustment = stressAndBodyBatteryMeasures[screenIndex][4] as Number;

            /* Taking data from the last column instead */
            if (isSleeping) {
                from_edge =     stressAndBodyBatteryMeasures[screenIndex][5];
            }

            var batt_bar = Math.round(batt * (bar_height / 100.0));
            dc.setColor(getColor(labelBodybattery), -1);
            dc.fillRectangle(dc.getWidth() - from_edge - bar_width - bb_adjustment, bar_top + (bar_height - batt_bar), bar_width, batt_bar);

            var stress_bar = Math.round(stress * (bar_height / 100.0));
            dc.setColor(getColor(labelStress), -1);
            dc.fillRectangle(from_edge, bar_top + (bar_height - stress_bar), bar_width, stress_bar);

        }
    }

    hidden function setBottomFields(dc as Dc) as Void {
        /* Left label */
        dTtrDesc.setText(getLiveComplicationDesc(propLeftValueShows, leftCompLabelSize, leftCompLabel));
        dTtrLabel.setText(leftCompMethod.invoke("%01d", leftCompWidth));

        dHrDesc.setText(getLiveComplicationDesc(propMiddleValueShows, centerCompLabelSize, centerCompLabel));
        dHrLabel.setText(centerCompMethod.invoke("%01d", centerCompWidth));

        dActiveDesc.setText(getLiveComplicationDesc(propRightValueShows, rightCompLabelSize, rightCompLabel));
        dActiveLabel.setText(rightCompMethod.invoke("%01d", rightCompWidth));

        // hide labels if so configured
       if (propLabelVisibility == 1 or propLabelVisibility == 3) {
            dTtrDesc.setVisible(false);
            dHrDesc.setVisible(false);
            dActiveDesc.setVisible(false);
        }
    }

    hidden function getComplicationDesc(complicationType as Integer, labelSize as Number) as String {
        /* Handle special cases or return from the array */
        switch (complicationType) {
            case 16:
                return Lang.format("$1$:", [propTzName1.toUpper()]);
            case 41:
                return Lang.format("$1$:", [propTzName2.toUpper()]);
            default:
                var labelResourceId = null as ResourceId;

                /* TODO : read from JSON */
                switch (labelSize) {
                    case 1: labelResourceId = Rez.JsonData.shortLabels; break;
                    case 2: labelResourceId = Rez.JsonData.midLabels;   break;
                    case 3: labelResourceId = Rez.JsonData.longLabels;  break;
                    /* Invalid size, return nothing */
                    default: return "";
                }

                var arrayJsonDesc = Application.loadResource(labelResourceId) as Array<String>;
                return arrayJsonDesc[complicationType];
        }
    }

    hidden function getLiveComplicationDesc(complicationType as Integer, labelSize as Number, currentValue as String) as String {
        /* Handle special cases here */
        switch (complicationType) {
            case 10:
                if(Activity.getActivityInfo().currentHeartRate == null) {
                    var hrDesc = [ "HR:", "LAST HR:", "LAST HR:" ];
                    return hrDesc[labelSize - 1];
                } else {
                    var hrDesc = [ "HR:", "LIVE HR:", "LIVE HR:" ];
                    return hrDesc[labelSize - 1];
                }
            default: return currentValue;
        }
    }

    hidden function getComplicationUnit(complicationType) as String {
        switch (complicationType) {
            case 11: return "KCAL";   // [11] Calories / day
            case 12: return "M";      // [12] Altitude (m)
            case 15: return "FT";     // [15] Altitude (ft)
            case 17: return "STEPS";  // [17] Steps / day
            case 19: return "PUSHES"; // [19] Wheelchair pushes
            case 29: return "KCAL";   // [29] Act Calories / day
            case 58: return "KCAL";   // [58] Active/Total calories / day
            default: return "";
        }
    }

    hidden function join(array as Array<String>) as String {
        var ret = "";
        for(var i=0; i<array.size(); i++) {
            if(ret.equals("")) {
                ret = array[i];
            } else {
                ret = ret + ", " + array[i];
            }
        }
        return ret;
    }

    hidden function formatDate() as String {
        var now = Time.now();
        var today = Time.Gregorian.info(now, Time.FORMAT_SHORT);
        var value = "";

        switch(propDateFormat) {
            case 0: // Default: THU, 14 MAR 2024
                value = Lang.format("$1$, $2$ $3$ $4$", [
                    dayName(today.day_of_week),
                    today.day,
                    monthName(today.month),
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
                    dayName(today.day_of_week),
                    today.day,
                    monthName(today.month),
                    isoWeekNumber(today.year, today.month, today.day)
                ]);
                break;
            case 5: // THU, 14 MAR 2024 (Week number)
                value = Lang.format("$1$, $2$ $3$ $4$ (W$5$)", [
                    dayName(today.day_of_week),
                    today.day,
                    monthName(today.month),
                    today.year,
                    isoWeekNumber(today.year, today.month, today.day)
                ]);
                break;
            case 6: // WEEKDAY, DD MONTH
                value = Lang.format("$1$, $2$ $3$", [
                    dayName(today.day_of_week),
                    today.day,
                    monthName(today.month)
                ]);
                break;
            case 7: // WEEKDAY, YYYY-MM-DD
                value = Lang.format("$1$, $2$-$3$-$4$", [
                    dayName(today.day_of_week),
                    today.year,
                    today.month.format("%02d"),
                    today.day.format("%02d")
                ]);
                break;
            case 8: // WEEKDAY, MM/DD/YYYY
                value = Lang.format("$1$, $2$/$3$/$4$", [
                    dayName(today.day_of_week),
                    today.month.format("%02d"),
                    today.day.format("%02d"),
                    today.year
                ]);
                break;
            case 9: // WEEKDAY, DD.MM.YYYY
                value = Lang.format("$1$, $2$.$3$.$4$", [
                    dayName(today.day_of_week),
                    today.day.format("%02d"),
                    today.month.format("%02d"),
                    today.year
                ]);
                break;
        }

        return value;
    }

    hidden function getDateTimeGroup() as String {
        // 052125ZMAR25
        // DDHHMMZmmmYY
        var now = Time.now();
        var utc = Time.Gregorian.utcInfo(now, Time.FORMAT_SHORT);
        var value = Lang.format("$1$$2$$3$Z$4$$5$", [
                    utc.day.format("%02d"),
                    utc.hour.format("%02d"),
                    utc.min.format("%02d"),
                    monthName(utc.month),
                    utc.year.toString().substring(2,4)
                ]);

        return value;
    }

    hidden function getTemperature() as String {
        if(weatherCondition != null and weatherCondition.temperature != null) {
            var temp_unit = getTempUnit();
            var temp_val = weatherCondition.temperature;
            var temp = formatTemperature(temp_val, temp_unit).format("%01d");
            return Lang.format("$1$$2$", [temp, temp_unit]);
        }
        return "";
    }

    hidden function getWind() as String {
        var windspeed = "";
        var bearing = "";

        if(weatherCondition != null and weatherCondition.windSpeed != null) {
            var windspeed_mps = weatherCondition.windSpeed;
            if(propWindUnit == 0) { // m/s
                windspeed = Math.round(windspeed_mps).format("%01d");
            } else if (propWindUnit == 1) { // km/h
                var windspeed_kmh = Math.round(windspeed_mps * 3.6);
                windspeed = windspeed_kmh.format("%01d");
            } else if (propWindUnit == 2) { // mph
                var windspeed_mph = Math.round(windspeed_mps * 2.237);
                windspeed = windspeed_mph.format("%01d");
            } else if (propWindUnit == 3) { // knots
                var windspeed_kt = Math.round(windspeed_mps * 1.944);
                windspeed = windspeed_kt.format("%01d");
            } else if(propWindUnit == 4) { // beufort
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

        if(weatherCondition != null and weatherCondition.windBearing != null) {
            bearing = ((Math.round((weatherCondition.windBearing.toFloat() + 180) / 45.0).toNumber() % 8) + 97).toChar().toString();
        }

        return Lang.format("$1$$2$", [bearing, windspeed]);
    }

    hidden function getFeelsLike() as String {
        var fl = "";
        var tempUnit = getTempUnit();
        if(weatherCondition != null and weatherCondition.feelsLikeTemperature != null) {
            var fltemp = formatTemperatureFloat(weatherCondition.feelsLikeTemperature, tempUnit);
            fl = Lang.format("FL:$1$$2$", [fltemp.format(INTEGER_FORMAT), tempUnit]);
        }

        return fl;
    }

    hidden function getHumidity() as String {
        var ret = "";
        if(weatherCondition != null and weatherCondition.relativeHumidity != null) {
            ret = Lang.format("$1$%", [weatherCondition.relativeHumidity]);
        }
        return ret;
    }

    hidden function getHighLow() as String {
        var ret = "";
        if(weatherCondition != null) {
            if(weatherCondition.highTemperature != null or weatherCondition.lowTemperature != null) {
                var tempUnit = getTempUnit();
                var high = formatTemperature(weatherCondition.highTemperature, tempUnit);
                var low = formatTemperature(weatherCondition.lowTemperature, tempUnit);
                ret = Lang.format("$1$$2$/$3$$2$", [high.format(INTEGER_FORMAT), tempUnit, low.format(INTEGER_FORMAT)]);
            }
        }
        return ret;
    }

    hidden function getPrecip() as String {
        var ret = "";
        if(weatherCondition != null and weatherCondition.precipitationChance != null) {
            ret = Lang.format("$1$%", [weatherCondition.precipitationChance.format("%d")]);
        }
        return ret;
    }

    hidden function getWeeklyDistance() as Number {
        var weekly_distance = 0;
        if(ActivityMonitor.getInfo() has :distance) {
            var history = ActivityMonitor.getHistory();
            if (history != null) {
                // Only take up to 6 previous days from history
                var daysToCount = history.size() < 6 ? history.size() : 6;
                for (var i = 0; i < daysToCount; i++) {
                    if (history[i].distance != null) {
                        weekly_distance += history[i].distance;
                    }
                }
            }
            // Add today's distance
            if(ActivityMonitor.getInfo().distance != null) {
                weekly_distance += ActivityMonitor.getInfo().distance;
            }
        }
        return weekly_distance;
    }

    hidden function secondaryTimezone(offset, width) as String {
        var val = "";
        var now = Time.now();
        var utc = Time.Gregorian.utcInfo(now, Time.FORMAT_MEDIUM);
        var min = utc.min + (offset % 60);
        var hour = (utc.hour + Math.floor(offset / 60)) % 24;

        if(min > 59) {
            min -= 60;
            hour += 1;
        }

        if(min < 0) {
            min += 60;
            hour -= 1;
        }

        if(hour < 0) {
            hour += 24;
        }
        if(hour > 23) {
            hour -= 24;
        }
        hour = formatHour(hour);
        if(width < 5) {
            val = Lang.format("$1$$2$", [hour.format("%02d"), min.format("%02d")]);
        } else {
            val = Lang.format("$1$:$2$", [hour.format("%02d"), min.format("%02d")]);
        }
        return val;
    }

    hidden function dayName(day_of_week) as String {
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

    hidden function monthName(month) as String {
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

    hidden function isoWeekNumber(year, month, day) as Number {
        var first_day_of_year = julianDay(year, 1, 1);
        var given_day_of_year = julianDay(year, month, day);
        var day_of_week = (first_day_of_year + 3) % 7;
        var week_of_year = (given_day_of_year - first_day_of_year + day_of_week + 4) / 7;
        var ret = 0;
        if (week_of_year == 53) {
            if (day_of_week == 6) {
                ret = week_of_year;
            } else if (day_of_week == 5 && isLeapYear(year)) {
                ret = week_of_year;
            } else {
                ret = 1;
            }
        } else if (week_of_year == 0) {
            first_day_of_year = julianDay(year - 1, 1, 1);
            day_of_week = (first_day_of_year + 3) % 7;
            ret = (given_day_of_year - first_day_of_year + day_of_week + 4) / 7;
        }
        else {
            ret = week_of_year;
        }
        if(propWeekOffset != 0) {
            ret = ret + propWeekOffset;
        }
        return ret;
    }


    hidden function julianDay(year, month, day) as Number {
        var a = (14 - month) / 12;
        var y = (year + 4800 - a);
        var m = (month + 12 * a - 3);
        return day + ((153 * m + 2) / 5) + (365 * y) + (y / 4) - (y / 100) + (y / 400) - 32045;
    }


    hidden function isLeapYear(year) as Boolean {
        if (year % 4 != 0) {
            return false;
           } else if (year % 100 != 0) {
            return true;
        } else if (year % 400 == 0) {
            return true;
        }
        return false;
    }

    hidden function moonPhase(time) as String {
        var jd = julianDay(time.year, time.month, time.day);

        var days_since_new_moon = jd - 2459966;
        var lunar_cycle = 29.53;
        var phase = ((days_since_new_moon / lunar_cycle) * 100).toNumber() % 100;
        var into_cycle = (phase / 100.0) * lunar_cycle;

        if(time.month == 5 and time.day == 4) {
            return "8"; // That's no moon!
        }

        var moonPhase;
        if (into_cycle < 3) { // 2+1
            moonPhase = 0;
        } else if (into_cycle < 6) { // 4
            moonPhase = 1;
        } else if (into_cycle < 10) { // 4
            moonPhase = 2;
        } else if (into_cycle < 14) { // 4
            moonPhase = 3;
        } else if (into_cycle < 18) { // 4
            moonPhase = 4;
        } else if (into_cycle < 22) { // 4
            moonPhase = 5;
        } else if (into_cycle < 26) { // 4
            moonPhase = 6;
        } else if (into_cycle < 29) { // 3
            moonPhase = 7;
        } else {
            moonPhase = 0;
        }

        // If hemisphere is 1 (southern), invert the phase index
        if (propHemisphere == 1) {
            moonPhase = (8 - moonPhase) % 8;
        }

        return moonPhase.toString();

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

    hidden function formatPressure(pressureHpa as Float, numberFormat as String) as String {
        var val = "";

        if (propPressureUnit == 0) { // hPA
            val = pressureHpa.format(numberFormat);
        } else if (propPressureUnit == 1) { // mmHG
            val = (pressureHpa * 0.750062).format(numberFormat);
        } else if (propPressureUnit == 2) { // inHG
            val = (pressureHpa * 0.02953).format("%.1f");
        }

        return val;
    }

    hidden function getNextSunEvent() as Array {
        var now = Time.now();
        if (weatherCondition != null) {
            var loc = weatherCondition.observationLocationPosition;
            if (loc != null) {
                var nextSunEvent = null;
                var sunrise = Weather.getSunrise(loc, now);
                var sunset = Weather.getSunset(loc, now);
                var isNight = false;

                if ((sunrise != null) && (sunset != null)) {
                    if (sunrise.lessThan(now)) { 
                        //if sunrise was already, take tomorrows
                        sunrise = Weather.getSunrise(loc, Time.today().add(new Time.Duration(86401)));
                    }
                    if (sunset.lessThan(now)) { 
                        //if sunset was already, take tomorrows
                        sunset = Weather.getSunset(loc, Time.today().add(new Time.Duration(86401)));
                    }
                    if (sunrise.lessThan(sunset)) { 
                        nextSunEvent = sunrise;
                        isNight = true;
                    } else {
                        nextSunEvent = sunset;
                        isNight = false;
                    }
                    return [nextSunEvent, isNight];
                }
                
            }
        }
        return [];
    }

    /**********************************************************/
    /* Define all method for complications. Might be worth a  */
    /* class. */

    function complicationType_Date(numberFormat as String, width as Integer) as String {
        return formatDate();
    }

    function complicationType_0 (numberFormat as String, width as Integer) as String { // Active min / week
        var val = "" as String;

        if(ActivityMonitor.getInfo() has :activeMinutesWeek) {
            if(ActivityMonitor.getInfo().activeMinutesWeek != null) {
                val = ActivityMonitor.getInfo().activeMinutesWeek.total.format(numberFormat);
            }
        }
        return val;
    } 

    function complicationType_1 (numberFormat as String, width as Integer) as String { // Active min / day
        var val = "" as String;

        if(ActivityMonitor.getInfo() has :activeMinutesWeek) {
            if(ActivityMonitor.getInfo().activeMinutesDay != null) {
                val = ActivityMonitor.getInfo().activeMinutesDay.total.format(numberFormat);
            }
        }
        return val;
    } 

    function complicationType_2 (numberFormat as String, width as Integer) as String { // distance (km) / day
        var val = "" as String;

        if(ActivityMonitor.getInfo() has :distance) {
            if(ActivityMonitor.getInfo().distance != null) {
                val = formatDistanceByWidth(ActivityMonitor.getInfo().distance / 100000.0, width);
            }
        }
        return val;
    } 

    function complicationType_3 (numberFormat as String, width as Integer) as String { // distance (miles) / day
        var val = "" as String;

        if(ActivityMonitor.getInfo() has :distance) {
            if(ActivityMonitor.getInfo().distance != null) {
                val = formatDistanceByWidth(ActivityMonitor.getInfo().distance / 160900.0, width);
            }
        }
        return val;
    } 

    function complicationType_4 (numberFormat as String, width as Integer) as String { // floors climbed / day
        var val = "" as String;

        if(ActivityMonitor.getInfo() has :floorsClimbed) {
            if(ActivityMonitor.getInfo().floorsClimbed != null) {
                val = ActivityMonitor.getInfo().floorsClimbed.format(numberFormat);
            }
        }
        return val;
    } 

    function complicationType_5 (numberFormat as String, width as Integer) as String { // meters climbed / day
        var val = "" as String;

        if(ActivityMonitor.getInfo() has :metersClimbed) {
            if(ActivityMonitor.getInfo().metersClimbed != null) {
                val = ActivityMonitor.getInfo().metersClimbed.format(numberFormat);
            }
        }
        return val;
    } 

    function complicationType_6 (numberFormat as String, width as Integer) as String { // Time to Recovery (h)
        var val = "" as String;

        if(ActivityMonitor.getInfo() has :timeToRecovery) {
            if(ActivityMonitor.getInfo().timeToRecovery != null) {
                val = ActivityMonitor.getInfo().timeToRecovery.format(numberFormat);
            }
        }
        return val;
    } 

    function complicationType_7 (numberFormat as String, width as Integer) as String { // VO2 Max Running
        var val = "" as String;

        var profile = UserProfile.getProfile();
        if(profile has :vo2maxRunning) {
            if(profile.vo2maxRunning != null) {
                val = profile.vo2maxRunning.format(numberFormat);
            }
        }
        return val;
    } 

    function complicationType_8 (numberFormat as String, width as Integer) as String { // VO2 Max Cycling
        var val = "" as String;

        var profile = UserProfile.getProfile();
        if(profile has :vo2maxCycling) {
            if(profile.vo2maxCycling != null) {
                val = profile.vo2maxCycling.format(numberFormat);
            }
        }
        return val;
    } 

    function complicationType_9 (numberFormat as String, width as Integer) as String { // Respiration rate
        var val = "" as String;

        if(ActivityMonitor.getInfo() has :respirationRate) {
            if(ActivityMonitor.getInfo().respirationRate != null) {
                val = ActivityMonitor.getInfo().respirationRate.format(numberFormat);
            }
        }
        return val;
    } 

    function complicationType_10 (numberFormat as String, width as Integer) as String {
        var val = "" as String;

        // Try to retrieve live HR from Activity::Info
        var sample = Activity.getActivityInfo().currentHeartRate;
        if(sample != null) {
            val = sample.format("%01d");
        } else if (ActivityMonitor has :getHeartRateHistory) {
            // Falling back to historical HR from ActivityMonitor
            var hist = ActivityMonitor.getHeartRateHistory(1, /* newestFirst */ true).next();
            if ((hist != null) && (hist.heartRate != ActivityMonitor.INVALID_HR_SAMPLE)) {
                val = hist.heartRate.format("%01d");
            }
        }
        return val;
    } 

    function complicationType_11 (numberFormat as String, width as Integer) as String { // Calories
        var val = "" as String;

        if (ActivityMonitor.getInfo() has :calories) {
            if(ActivityMonitor.getInfo().calories != null) {
                val = ActivityMonitor.getInfo().calories.format(numberFormat);
            }
        }
        return val;
    } 

    function complicationType_12 (numberFormat as String, width as Integer) as String { // Altitude (m)
        var val = "" as String;

        if ((Toybox has :SensorHistory) and (Toybox.SensorHistory has :getElevationHistory)) {
            var elv_iterator = Toybox.SensorHistory.getElevationHistory({:period => 1});
            var elv = elv_iterator.next();
            if(elv != null and elv.data != null) {
                val = elv.data.format(numberFormat);
            }
        }
        return val;
    } 

    function complicationType_13 (numberFormat as String, width as Integer) as String { // Stress
        var val = "" as String;

        if ((Toybox has :SensorHistory) and (Toybox.SensorHistory has :getStressHistory)) {
            var st_iterator = Toybox.SensorHistory.getStressHistory({:period => 1});
            var st = st_iterator.next();
            if(st != null and st.data != null) {
                val = st.data.format(numberFormat);
            }
        }
        return val;
    } 

    function complicationType_14 (numberFormat as String, width as Integer) as String { // Body battery
        var val = "" as String;

        if ((Toybox has :SensorHistory) and (Toybox.SensorHistory has :getBodyBatteryHistory)) {
            var bb_iterator = Toybox.SensorHistory.getBodyBatteryHistory({:period => 1});
            var bb = bb_iterator.next();
            if(bb != null and bb.data != null) {
                val = bb.data.format(numberFormat);
            }
        }
        return val;
    } 

    function complicationType_15 (numberFormat as String, width as Integer) as String { // Altitude (ft)
        var val = "" as String;

        if ((Toybox has :SensorHistory) and (Toybox.SensorHistory has :getElevationHistory)) {
            var elv_iterator = Toybox.SensorHistory.getElevationHistory({:period => 1});
            var elv = elv_iterator.next();
            if(elv != null and elv.data != null) {
                val = (elv.data * 3.28084).format(numberFormat);
            }
        }
        return val;
    } 

    function complicationType_16 (numberFormat as String, width as Integer) as String { // Alt TZ 1
        return secondaryTimezone(propTzOffset1, width);
    } 

    function complicationType_17 (numberFormat as String, width as Integer) as String { // Steps / day
        var val = "" as String;

        if(ActivityMonitor.getInfo().steps != null) {
            val = ActivityMonitor.getInfo().steps.format(numberFormat);
        }
        return val;
    } 

    function complicationType_18 (numberFormat as String, width as Integer) as String { // Distance (m) / day
        var val = "" as String;

        if(ActivityMonitor.getInfo().distance != null) {
            val = (ActivityMonitor.getInfo().distance / 100).format(numberFormat);
        }
        return val;
    } 

    function complicationType_19 (numberFormat as String, width as Integer) as String { // Wheelchair pushes
        var val = "" as String;

        if(ActivityMonitor.getInfo() has :pushes) {
            if(ActivityMonitor.getInfo().pushes != null) {
                val = ActivityMonitor.getInfo().pushes.format(numberFormat);
            }
        }
        return val;
    } 

    function complicationType_20 (numberFormat as String, width as Integer) as String { // Weather condition
        return getWeatherCondition(true);
    } 

    function complicationType_21 (numberFormat as String, width as Integer) as String { // Weekly run distance (km)
        var val = "" as String;

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
        return val;
    } 

    function complicationType_22 (numberFormat as String, width as Integer) as String { // Weekly run distance (miles)
        var val = "" as String;

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
        return val;
    } 

    function complicationType_23 (numberFormat as String, width as Integer) as String { // Weekly bike distance (km)
        var val = "" as String;

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
        return val;
    } 

    function complicationType_24 (numberFormat as String, width as Integer) as String { // Weekly bike distance (miles)
        var val = "" as String;

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
        return val;
    } 

    function complicationType_25 (numberFormat as String, width as Integer) as String { // Training status
        var val = "" as String;

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
        return val;
    } 

    function complicationType_26 (numberFormat as String, width as Integer) as String { // Raw Barometric pressure (hPA)
        var val = "" as String;

        var info = Activity.getActivityInfo();
        if (info has :rawAmbientPressure && info.rawAmbientPressure != null) {
            val = formatPressure(info.rawAmbientPressure / 100.0, numberFormat);
        }
        return val;
    } 

    function complicationType_27 (numberFormat as String, width as Integer) as String { // Weight kg
        var val = "" as String;

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
        return val;
    } 

    function complicationType_28 (numberFormat as String, width as Integer) as String { // Weight lbs
        var val = "" as String;

        var profile = UserProfile.getProfile();
        if(profile has :weight) {
            if(profile.weight != null) {
                val = (profile.weight * 0.00220462).format(numberFormat);
            }
        }
        return val;
    } 

    function complicationType_29 (numberFormat as String, width as Integer) as String { // Act Calories
        var val = "" as String;

        var rest_calories = getRestCalories();
        // Get total calories and subtract rest calories
        if (ActivityMonitor.getInfo() has :calories && ActivityMonitor.getInfo().calories != null && rest_calories > 0) {
            var active_calories = ActivityMonitor.getInfo().calories - rest_calories;
            if (active_calories > 0) {
                val = active_calories.format(numberFormat);
            }
        }
        return val;
    } 

    function complicationType_30 (numberFormat as String, width as Integer) as String { // Sea level pressure (hPA)
        var val = "" as String;

        var info = Activity.getActivityInfo();
        if (info has :meanSeaLevelPressure && info.meanSeaLevelPressure != null) {
            val = formatPressure(info.meanSeaLevelPressure / 100.0, numberFormat);
        }
        return val;
    } 

    function complicationType_31 (numberFormat as String, width as Integer) as String { // Week number
        var val = "" as String;

        var today = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var week_number = isoWeekNumber(today.year, today.month, today.day);
        val = week_number.format(numberFormat);
        return val;
    } 

    function complicationType_32 (numberFormat as String, width as Integer) as String { // Weekly distance (km)
        return formatDistanceByWidth(getWeeklyDistance() / 100000.0, width); // Convert to km
    } 

    function complicationType_33 (numberFormat as String, width as Integer) as String { // Weekly distance (miles)
        return formatDistanceByWidth(getWeeklyDistance() * 0.00000621371, width); // Convert to miles
    } 

    function complicationType_34 (numberFormat as String, width as Integer) as String { // Battery percentage
        return Lang.format("$1$", [System.getSystemStats().battery.format("%d")]);
    } 

    function complicationType_35 (numberFormat as String, width as Integer) as String { // Battery days remaining
        var val = "" as String;

        if(System.getSystemStats() has :batteryInDays) {
            if (System.getSystemStats().batteryInDays != null){
                var sample = Math.round(System.getSystemStats().batteryInDays);
                val = Lang.format("$1$", [sample.format(numberFormat)]);
            }
        }
        return val;
    } 

    function complicationType_36 (numberFormat as String, width as Integer) as String { // Notification count
        var val = "" as String;

        var notif_count = System.getDeviceSettings().notificationCount;
        if(notif_count != null) {
            val = notif_count.format(numberFormat);
        }
        return val;
    } 

    function complicationType_37 (numberFormat as String, width as Integer) as String { // Solar intensity
        var val = "" as String;

        if (Toybox has :Complications) {
            try {
                var complication = Complications.getComplication(new Id(Complications.COMPLICATION_TYPE_SOLAR_INPUT));
                if (complication != null && complication.value != null) {
                    val = complication.value.format(numberFormat);
                }
            } catch(e) {
                // Complication not found
            }
        }
        return val;
    } 

    function complicationType_38 (numberFormat as String, width as Integer) as String { // Sensor temperature
        var val = "" as String;

        if ((Toybox has :SensorHistory) and (Toybox.SensorHistory has :getTemperatureHistory)) {
            var tempIterator = Toybox.SensorHistory.getTemperatureHistory({:period => 1});
            var temp = tempIterator.next();
            if(temp != null and temp.data != null) {
                var tempUnit = getTempUnit();
                val = Lang.format("$1$$2$", [formatTemperature(temp.data, tempUnit).format(numberFormat), tempUnit]);
            }
        }
        return val;
    } 

    function complicationType_39 (numberFormat as String, width as Integer) as String { // Sunrise
        var val = "" as String;

        var now = Time.now();
        if(weatherCondition != null) {
            var loc = weatherCondition.observationLocationPosition;
            if(loc != null) {
                var sunrise = Time.Gregorian.info(Weather.getSunrise(loc, now), Time.FORMAT_SHORT);
                var sunriseHour = formatHour(sunrise.hour);
                if(width < 5) {
                    val = Lang.format("$1$$2$", [sunriseHour.format("%02d"), sunrise.min.format("%02d")]);
                } else {
                    val = Lang.format("$1$:$2$", [sunriseHour.format("%02d"), sunrise.min.format("%02d")]);
                }
            }
        }
        return val;
    } 

    function complicationType_40 (numberFormat as String, width as Integer) as String { // Sunset
        var val = "" as String;

        var now = Time.now();
        if(weatherCondition != null) {
            var loc = weatherCondition.observationLocationPosition;
            if(loc != null) {
                var sunset = Time.Gregorian.info(Weather.getSunset(loc, now), Time.FORMAT_SHORT);
                var sunsetHour = formatHour(sunset.hour);
                if(width < 5) {
                    val = Lang.format("$1$$2$", [sunsetHour.format("%02d"), sunset.min.format("%02d")]);
                } else {
                    val = Lang.format("$1$:$2$", [sunsetHour.format("%02d"), sunset.min.format("%02d")]);
                }
            }
        }
        return val;
    } 

    function complicationType_41 (numberFormat as String, width as Integer) as String { // Alt TZ 2
        return secondaryTimezone(propTzOffset2, width);
    } 

    function complicationType_42 (numberFormat as String, width as Integer) as String { // Alarms
        return System.getDeviceSettings().alarmCount.format(numberFormat);
    } 

    function complicationType_43 (numberFormat as String, width as Integer) as String { // High temp
        var val = "" as String;

        if(weatherCondition != null and weatherCondition.highTemperature != null) {
            var tempVal = weatherCondition.highTemperature;
            var tempUnit = getTempUnit();
            var temp = formatTemperature(tempVal, tempUnit).format("%01d");
            val = Lang.format("$1$$2$", [temp, tempUnit]);
        }
        return val;
    } 

    function complicationType_44 (numberFormat as String, width as Integer) as String { // Low temp
        var val = "" as String;

        if(weatherCondition != null and weatherCondition.lowTemperature != null) {
            var tempVal = weatherCondition.lowTemperature;
            var tempUnit = getTempUnit();
            var temp = formatTemperature(tempVal, tempUnit).format("%01d");
            val = Lang.format("$1$$2$", [temp, tempUnit]);
        }
        return val;
    } 

    function complicationType_45 (numberFormat as String, width as Integer) as String { // Temperature, Wind, Feels like
        var val = "" as String;

        var temp = getTemperature();
        var wind = getWind();
        var feelsLike = getFeelsLike();
        val = join([temp, wind, feelsLike]);
        return val;
    } 

    function complicationType_46 (numberFormat as String, width as Integer) as String { // Temperature, Wind
        var val = "" as String;

        var temp = getTemperature();
        var wind = getWind();
        val = join([temp, wind]);
        return val;
    } 

    function complicationType_47 (numberFormat as String, width as Integer) as String { // Temperature, Wind, Humidity
        var val = "" as String;

        var temp = getTemperature();
        var wind = getWind();
        var humidity = getHumidity();
        val = join([temp, wind, humidity]);
        return val;
    } 

    function complicationType_48 (numberFormat as String, width as Integer) as String { // Temperature, Wind, High/Low
        var val = "" as String;

        var temp = getTemperature();
        var wind = getWind();
        var highlow = getHighLow();
        val = join([temp, wind, highlow]);
        return val;
    } 

    function complicationType_49 (numberFormat as String, width as Integer) as String { // Temperature, Wind, Precipitation chance
        var val = "" as String;

        var temp = getTemperature();
        var wind = getWind();
        var precip = getPrecip();
        val = join([temp, wind, precip]);
        return val;
    } 

    function complicationType_50 (numberFormat as String, width as Integer) as String { // Weather condition without precipitation
        return getWeatherCondition(false);
    } 

    function complicationType_51 (numberFormat as String, width as Integer) as String { // Temperature, Humidity, High/Low
        var val = "" as String;

        var temp = getTemperature();
        var humidity = getHumidity();
        var highlow = getHighLow();
        val = join([temp, humidity, highlow]);
        return val;
    } 

    function complicationType_52 (numberFormat as String, width as Integer) as String { // Temperature, Percipitation chance, High/Low
        var val = "" as String;

        var temp = getTemperature();
        var precip = getPrecip();
        var highlow = getHighLow();
        val = join([temp, precip, highlow]);
        return val;
    } 

    function complicationType_53 (numberFormat as String, width as Integer) as String { // Temperature
        return getTemperature();
    } 

    function complicationType_54 (numberFormat as String, width as Integer) as String { // Precipitation chance
        var val = "" as String;

        val = getPrecip();
        if(width == 3 and val.equals("100%")) { val = "100"; }
        return val;
    }

    function complicationType_55 (numberFormat as String, width as Integer) as String { // Next Sun Event
        var val = "" as String;
        var nextSunEventArray = getNextSunEvent();
        if(nextSunEventArray != null && nextSunEventArray.size() == 2) { 
            var nextSunEvent = Time.Gregorian.info(nextSunEventArray[0], Time.FORMAT_SHORT);
            var nextSunEventHour = formatHour(nextSunEvent.hour);
            if(width < 5) {
                val = Lang.format("$1$$2$", [nextSunEventHour.format("%02d"), nextSunEvent.min.format("%02d")]);
            } else {
                val = Lang.format("$1$:$2$", [nextSunEventHour.format("%02d"), nextSunEvent.min.format("%02d")]);
            }
        }
        return val;
    }

    function complicationType_56 (numberFormat as String, width as Integer) as String { // Military Date Time Group
        return getDateTimeGroup();
    }

    function complicationType_57 (numberFormat as String, width as Integer) as String { // Time of the next Calendar Event
        var val = "" as String;

        if (Toybox has :Complications) {
            try {
                var complication = Complications.getComplication(new Id(Complications.COMPLICATION_TYPE_CALENDAR_EVENTS));
                if (complication != null && complication.value != null) {
                    val = complication.value;
                    var colon_index = val.find(":");
                    if (colon_index != null && colon_index < 2) {
                        val = "0" + val;
                    }
                } else {
                    val = "--:--";
                }
                if (width < 5) {
                    val = val.substring(0, 2) + val.substring(3, 5);
                }
            } catch(e) {
                // Complication not found
            }
        }

        return val;
    }

    function complicationType_58 (numberFormat as String, width as Integer) as String { // Active / Total calories
        var val = "" as String;
        var rest_calories = getRestCalories();
        var total_calories = 0;
        // Get total calories and subtract rest calories
        if (ActivityMonitor.getInfo() has :calories && ActivityMonitor.getInfo().calories != null) {
            total_calories = ActivityMonitor.getInfo().calories;
        }
        var active_calories = total_calories - rest_calories;
        active_calories = (active_calories > 0) ? active_calories : 0; // Ensure active calories is not negative
        val = active_calories.format(numberFormat) + "/" + total_calories.format(numberFormat);

        return val;
    }

    function complicationType_59 (numberFormat as String, width as Integer) as String { // PulseOx
        var val = "" as String;
        if (Toybox has :Complications) {
            try {
                var complication = Complications.getComplication(new Id(Complications.COMPLICATION_TYPE_PULSE_OX));
                if (complication != null && complication.value != null) {
                    val = complication.value.format(numberFormat);
                }
            } catch(e) {
                // Complication not found
            }
        }

        return val;
    }

    function complicationType_Empty (numberFormat as String, width as Integer) as String { // For empty complications
        return "";
    }

}

class Segment34Delegate extends WatchUi.WatchFaceDelegate {
    var screenW = null;
    var screenH = null;

    public function initialize() {
        WatchFaceDelegate.initialize();
        screenW = System.getDeviceSettings().screenWidth;
        screenH = System.getDeviceSettings().screenHeight;
    }

    public function onPress(clickEvent as WatchUi.ClickEvent) {
        var coords = clickEvent.getCoordinates();
        var x = coords[0];
        var y = coords[1];

        if(y < screenH / 3) {
            handlePress("pressToOpenTop");
        } else if (y < (screenH / 3) * 2) {
            handlePress("pressToOpenMiddle");
        } else if (x < screenW / 3) {
            handlePress("pressToOpenBottomLeft");
        } else if (x < (screenW / 3) * 2) {
            handlePress("pressToOpenBottomCenter");
        } else {
            handlePress("pressToOpenBottomRight");
        }

        return true;
    }

    function handlePress(areaSetting as String) {
        var cID = Application.Properties.getValue(areaSetting) as Complications.Type;
        if(cID != null and cID != 0) {
            try {
                Complications.exitTo(new Id(cID));
            } catch (e) {}
        }
    }

}
