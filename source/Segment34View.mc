import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Weather;
import Toybox.Complications;
using Toybox.Position;

class Segment34View extends WatchUi.WatchFace {

    hidden var screenHeight as Number;
    hidden var screenWidth as Number;
    (:initialized) hidden var clockHeight as Number;
    (:initialized) hidden var clockWidth as Number;
    (:initialized) hidden var labelHeight as Number;
    (:initialized) hidden var labelMargin as Number;
    (:initialized) hidden var tinyDataHeight as Number;
    (:initialized) hidden var smallDataHeight as Number;
    (:initialized) hidden var largeDataHeight as Number;
    (:initialized) hidden var baseX as Number;
    (:initialized) hidden var baseY as Number;
    hidden var centerX as Number;
    hidden var centerY as Number;
    hidden var marginX as Number;
    hidden var marginY as Number;
    hidden var halfMarginY as Number;
    hidden var halfClockHeight as Number;
    hidden var halfClockWidth as Number;
    hidden var barBottomAdj as Number = 0;
    hidden var bottomFiveAdj as Number = 0;
    hidden var fieldSpaceingAdj as Number = 0;
    hidden var textSideAdj as Number = 0;
    hidden var iconYAdj as Number = 0;
    hidden var histogramBarWidth as Number = 2;
    hidden var histogramBarSpacing as Number = 2;
    hidden var histogramHeight as Number = 20;
    hidden var histogramTargetWidth as Number = 40;

    hidden var fontMoon as WatchUi.FontResource;
    hidden var fontIcons as WatchUi.FontResource;
    (:initialized) hidden var fontClock as WatchUi.FontResource;
    (:initialized) hidden var fontClockOutline as WatchUi.FontResource;
    (:initialized) hidden var fontLabel as WatchUi.FontResource;
    (:initialized) hidden var fontTinyData as WatchUi.FontResource;
    (:initialized) hidden var fontSmallData as WatchUi.FontResource;
    (:initialized) hidden var fontLargeData as WatchUi.FontResource;
    (:initialized) hidden var fontAODData as WatchUi.FontResource;
    (:initialized) hidden var fontBottomData as WatchUi.FontResource;
    (:initialized) hidden var fontBattery as WatchUi.FontResource;
    (:initialized) hidden var weekNames as Array<String>;
    (:initialized) hidden var monthNames as Array<String>;

    hidden var drawGradient as BitmapResource?;
    hidden var drawAODPattern as BitmapResource?;
    
    hidden var dataMoon as String = "";
    hidden var dataTopLeft as String = "";
    hidden var dataTopRight as String = "";
    hidden var dataAboveLine1 as String = "";
    hidden var dataAboveLine2 as String = "";
    hidden var dataClock as String = "";
    hidden var dataBelow as String = "";
    hidden var dataNotifications as String = "";
    hidden var dataSeconds as String = "";
    hidden var dataBottomLeft as String = "";
    hidden var dataBottomMiddle as String = "";
    hidden var dataBottomRight as String = "";
    hidden var dataBottomFourth as String = "";
    hidden var dataBottom as String = "";
    hidden var dataIcon1 as String = "";
    hidden var dataIcon2 as String = "";
    hidden var dataBattery as String = "";
    hidden var dataAODLeft as String = "";
    hidden var dataAODRight as String = "";
    hidden var dataBbatt as Number = 0;
    hidden var dataStress as Number = 0;
    hidden var dataGraph1 as Array<Number>?;

    hidden var dataLabelTopLeft as String = "";
    hidden var dataLabelTopRight as String = "";
    hidden var dataLabelBottomLeft as String = "";
    hidden var dataLabelBottomMiddle as String = "";
    hidden var dataLabelBottomRight as String = "";
    hidden var dataLabelBottomFourth as String = "";

    public var infoMessage as String = "";
    public var nightModeOverride as Number = -1;
    hidden var themeColors as Array<Graphics.ColorType> = [];
    hidden var nightMode as Boolean?;
    hidden var weatherCondition as CurrentConditions or StoredWeather or Null;
    hidden var hrHistoryData as Array<Number>?;
    hidden var canBurnIn as Boolean = false;
    hidden var isSleeping as Boolean = false;
    hidden var lastUpdate as Number? = null;
    hidden var lastSlowUpdate as Number? = null;
    hidden var doesPartialUpdate as Boolean = false;
    hidden var hasComplications as Boolean = false;
    
    hidden var propIs24H as Boolean = false;
    hidden var propTheme as Integer = 0;
    hidden var propNightTheme as Integer = -1;
    hidden var propNightThemeActivation as Number = 0;
    hidden var propColorOverride as String = "";
    hidden var propClockOutlineStyle as Number = 0;
    hidden var propBatteryVariant as Number = 3;
    hidden var propShowSeconds as Boolean = true;
    hidden var propFieldLayout as Number = 0;
    hidden var propLeftValueShows as Number = 6;
    hidden var propMiddleValueShows as Number = 10;
    hidden var propRightValueShows as Number = 0;
    hidden var propFourthValueShows as Number = 0;
    hidden var propAlwaysShowSeconds as Boolean = false;
    hidden var propUpdateFreq as Number = 5;
    hidden var propShowClockBg as Boolean = true;
    hidden var propShowDataBg as Boolean = false;
    hidden var propAodFieldShows as Number = -1;
    hidden var propAodRightFieldShows as Number = -2;
    hidden var propDateFieldShows as Number = -1;
    hidden var propBottomFieldShows as Number = 17;
    hidden var propAodAlignment as Number = 0;
    hidden var propDateAlignment as Number = 0;
    hidden var propBottomFieldAlignment as Number = 2;
    hidden var propIcon1 as Number = 1;
    hidden var propIcon2 as Number = 2;
    hidden var propHemisphere as Number = 0;
    hidden var propHourFormat as Number = 0;
    hidden var propZeropadHour as Boolean = true;
    hidden var propTimeSeparator as Number = 0;
    hidden var propTempUnit as Number = 0;
    hidden var propWindUnit as Number = 0;
    hidden var propPressureUnit as Number = 0;
    hidden var propTopPartShows as Number = 0;
    hidden var propHistogramData as Number = 0;
    hidden var propSunriseFieldShows as Number = 39;
    hidden var propSunsetFieldShows as Number = 40;
    hidden var propWeatherLine1Shows as Number = 49;
    hidden var propWeatherLine2Shows as Number = 50;
    hidden var propDateFormat as Number = 0;
    hidden var propShowStressAndBodyBattery as Boolean = true;
    hidden var propShowNotificationCount as Boolean = true;
    hidden var propTzOffset1 as Number = 0;
    hidden var propTzOffset2 as Number = 0;
    hidden var propTzName1 as String = "";
    hidden var propTzName2 as String = "";
    hidden var propWeekOffset as Number = 0;
    hidden var propLabelVisibility as Number = 0;
    hidden var propSmallFontVariant as Number = 0;

    enum colorNames {
        bg = 0,
        clock,
        clockBg,
        outline,
        dataVal,
        fieldBg,
        fieldLbl,
        date,
        dateDim,
        notif,
        stress,
        bodybatt,
        moon,
        lowBatt
    }

    var clockBgText = "#####";
    (:MIP) const bottomFieldBg = "#";
    (:Round390) const bottomFieldBg = "#";
    (:Round416) const bottomFieldBg = "#";
    (:Round454) const bottomFieldBg = "#";
    (:Round360) const bottomFieldBg = "$";

    (:Round240) const bottomFieldWidths = [3, 3, 3, 0];
    (:Round260) const bottomFieldWidths = [3, 4, 3, 0];
    (:Round280) const bottomFieldWidths = [4, 3, 4, 0];
    (:Round360) const bottomFieldWidths = [3, 4, 3, 0];
    (:Round390) const bottomFieldWidths = [4, 3, 4, 0];
    (:Round416) const bottomFieldWidths = [4, 4, 4, 0];
    (:Round454) const bottomFieldWidths = [4, 4, 4, 0];

    (:Round240) const barWidth = 3;
    (:Round260) const barWidth = 3;
    (:Round280) const barWidth = 3;
    (:Round360) const barWidth = 3;
    (:Round390) const barWidth = 4;
    (:Round416) const barWidth = 4;
    (:Round454) const barWidth = 4;

    function initialize() {
        WatchFace.initialize();

        if(System.getDeviceSettings() has :requiresBurnInProtection) { canBurnIn = System.getDeviceSettings().requiresBurnInProtection; }
        updateProperties();
        
        screenHeight = Toybox.System.getDeviceSettings().screenHeight;
        screenWidth = Toybox.System.getDeviceSettings().screenWidth;

        fontMoon = Application.loadResource(Rez.Fonts.moon);
        fontIcons = Application.loadResource(Rez.Fonts.icons);
        weekNames = [Application.loadResource(Rez.Strings.DAY_OF_WEEK_SUN), Application.loadResource(Rez.Strings.DAY_OF_WEEK_MON),
                     Application.loadResource(Rez.Strings.DAY_OF_WEEK_TUE), Application.loadResource(Rez.Strings.DAY_OF_WEEK_WED),
                     Application.loadResource(Rez.Strings.DAY_OF_WEEK_THU), Application.loadResource(Rez.Strings.DAY_OF_WEEK_FRI),
                     Application.loadResource(Rez.Strings.DAY_OF_WEEK_SAT)];
        monthNames = [Application.loadResource(Rez.Strings.MONTH_JAN), Application.loadResource(Rez.Strings.MONTH_FEB), Application.loadResource(Rez.Strings.MONTH_MAR),
                      Application.loadResource(Rez.Strings.MONTH_APR), Application.loadResource(Rez.Strings.MONTH_MAY), Application.loadResource(Rez.Strings.MONTH_JUN),
                      Application.loadResource(Rez.Strings.MONTH_JUL), Application.loadResource(Rez.Strings.MONTH_AUG), Application.loadResource(Rez.Strings.MONTH_SEP),
                      Application.loadResource(Rez.Strings.MONTH_OCT), Application.loadResource(Rez.Strings.MONTH_NOV), Application.loadResource(Rez.Strings.MONTH_DEC)];

        centerX = Math.round(screenWidth / 2);
        centerY = Math.round(screenHeight / 2);
        marginY = Math.round(screenHeight / 30);
        marginX = Math.round(screenWidth / 20);
        
        loadResources();

        halfClockHeight = Math.round(clockHeight / 2);

        if(clockBgText.length() == 4) {
            halfClockWidth = Math.round((clockWidth / 5 * 4.2) / 2);
        } else {
            halfClockWidth = Math.round(clockWidth / 2);
        }
        
        halfMarginY = Math.round(marginY / 2);

        hasComplications = Toybox has :Complications;

        updateWeather();
    }

    (:Round240)
    hidden function loadResources() as Void {
        fontClock = Application.loadResource(Rez.Fonts.segments80narrow);
        fontTinyData = Application.loadResource(Rez.Fonts.smol);
        if(propSmallFontVariant == 0) { fontSmallData = Application.loadResource(Rez.Fonts.led_small); }
        if(propSmallFontVariant == 1) { fontSmallData = Application.loadResource(Rez.Fonts.led_small_readable); }
        if(propSmallFontVariant == 2) { fontSmallData = Application.loadResource(Rez.Fonts.led_small_lines); }
        fontLargeData = Application.loadResource(Rez.Fonts.led);
        fontBottomData = Application.loadResource(Rez.Fonts.led_small);
        fontLabel = Application.loadResource(Rez.Fonts.xsmol);
        fontBattery = fontTinyData;

        clockHeight = 80;
        clockWidth = 220;
        labelHeight = 5;
        labelMargin = 6;
        tinyDataHeight = 8;
        smallDataHeight = 13;
        largeDataHeight = 20;

        baseX = centerX;
        baseY = centerY - smallDataHeight + 4;
        fieldSpaceingAdj = 10;
        barBottomAdj = 1;
        histogramBarWidth = 1;
        histogramBarSpacing = 1;
        histogramHeight = 15;
        histogramTargetWidth = 30;
    }

    (:Round260)
    hidden function loadResources() as Void {
        fontClock = Application.loadResource(Rez.Fonts.segments80);
        fontTinyData = Application.loadResource(Rez.Fonts.smol);
        if(propSmallFontVariant == 0) { fontSmallData = Application.loadResource(Rez.Fonts.led_small); }
        if(propSmallFontVariant == 1) { fontSmallData = Application.loadResource(Rez.Fonts.led_small_readable); }
        if(propSmallFontVariant == 2) { fontSmallData = Application.loadResource(Rez.Fonts.led_small_lines); }
        fontLargeData = Application.loadResource(Rez.Fonts.led);
        fontBottomData = fontLargeData;
        fontLabel = Application.loadResource(Rez.Fonts.xsmol);
        fontBattery = fontTinyData;

        clockHeight = 80;
        clockWidth = 227;
        labelHeight = 5;
        labelMargin = 6;
        tinyDataHeight = 8;
        smallDataHeight = 13;
        largeDataHeight = 20;

        baseX = centerX + 1;
        baseY = centerY - smallDataHeight - 1;
        fieldSpaceingAdj = 15;
        bottomFiveAdj = 2;
        barBottomAdj = 1;
        histogramBarWidth = 1;
        histogramBarSpacing = 1;
        histogramHeight = 18;
    }

    (:Round280)
    hidden function loadResources() as Void {
        fontClock = Application.loadResource(Rez.Fonts.segments80wide);
        fontTinyData = Application.loadResource(Rez.Fonts.storre);
        if(propSmallFontVariant == 0) { fontSmallData = Application.loadResource(Rez.Fonts.led_small); }
        if(propSmallFontVariant == 1) { fontSmallData = Application.loadResource(Rez.Fonts.led_small_readable); }
        if(propSmallFontVariant == 2) { fontSmallData = Application.loadResource(Rez.Fonts.led_small_lines); }
        fontLargeData = Application.loadResource(Rez.Fonts.led);
        fontBottomData = fontLargeData;
        fontLabel = Application.loadResource(Rez.Fonts.smol);
        fontBattery = fontLabel;

        clockHeight = 80;
        clockWidth = 236;
        labelHeight = 8;
        labelMargin = 6;
        tinyDataHeight = 10;
        smallDataHeight = 13;
        largeDataHeight = 20;

        baseX = centerX;
        baseY = centerY - smallDataHeight - 4;
        bottomFiveAdj = 5;
        barBottomAdj = 1;
        histogramBarWidth = 1;
        histogramBarSpacing = 1;
        histogramHeight = 20;
    }

    (:Round360)
    hidden function loadResources() as Void {
        fontClock = Application.loadResource(Rez.Fonts.segments125narrow);
        fontClockOutline = Application.loadResource(Rez.Fonts.segments125narrowoutline);
        fontTinyData = Application.loadResource(Rez.Fonts.storre);
        if(propSmallFontVariant == 0) { fontSmallData = Application.loadResource(Rez.Fonts.led); }
        if(propSmallFontVariant == 1) { fontSmallData = Application.loadResource(Rez.Fonts.led_inbetween); }
        if(propSmallFontVariant == 2) { fontSmallData = Application.loadResource(Rez.Fonts.led_lines); }
        fontLargeData = Application.loadResource(Rez.Fonts.led_big);
        fontBottomData = Application.loadResource(Rez.Fonts.led);
        fontLabel = Application.loadResource(Rez.Fonts.smol);
        fontAODData = fontBottomData;
        fontBattery = Application.loadResource(Rez.Fonts.led_small_lines);

        drawGradient = Application.loadResource(Rez.Drawables.gradient) as BitmapResource;
        if(propClockOutlineStyle == 0 or propClockOutlineStyle == 2 or propClockOutlineStyle == 4) {
            drawAODPattern = Application.loadResource(Rez.Drawables.aod) as BitmapResource;
        } else {
            drawAODPattern = Application.loadResource(Rez.Drawables.aod2) as BitmapResource;
        }

        clockHeight = 125;
        clockWidth = 345;
        labelHeight = 8;
        labelMargin = 8;
        tinyDataHeight = 10;
        smallDataHeight = 20;
        largeDataHeight = 27;

        baseX = centerX;
        baseY = centerY - smallDataHeight + 4;
        fieldSpaceingAdj = 20;
        barBottomAdj = 2;
        textSideAdj = 10;
        iconYAdj = -4;
        marginY = 10;
        histogramHeight = 20;
        histogramTargetWidth = 30;
    }

    (:Round390)
    hidden function loadResources() as Void {
        fontClock = Application.loadResource(Rez.Fonts.segments125);
        fontClockOutline = Application.loadResource(Rez.Fonts.segments125outline);
        fontTinyData = Application.loadResource(Rez.Fonts.led_small_lines);
        if(propSmallFontVariant == 0) { fontSmallData = Application.loadResource(Rez.Fonts.led); }
        if(propSmallFontVariant == 1) { fontSmallData = Application.loadResource(Rez.Fonts.led_inbetween); }
        if(propSmallFontVariant == 2) { fontSmallData = Application.loadResource(Rez.Fonts.led_lines); }
        fontLargeData = Application.loadResource(Rez.Fonts.led_big);
        fontBottomData = fontLargeData;
        fontLabel = Application.loadResource(Rez.Fonts.storre);
        fontAODData = Application.loadResource(Rez.Fonts.led);
        fontBattery = fontTinyData;

        drawGradient = Application.loadResource(Rez.Drawables.gradient) as BitmapResource;
        if(propClockOutlineStyle == 0 or propClockOutlineStyle == 2 or propClockOutlineStyle == 4) {
            drawAODPattern = Application.loadResource(Rez.Drawables.aod) as BitmapResource;
        } else {
            drawAODPattern = Application.loadResource(Rez.Drawables.aod2) as BitmapResource;
        }

        clockHeight = 125;
        clockWidth = 355;
        labelHeight = 10;
        labelMargin = 8;
        tinyDataHeight = 13;
        smallDataHeight = 20;
        largeDataHeight = 27;

        baseX = centerX;
        baseY = centerY - smallDataHeight - 3;
        barBottomAdj = 2;
        bottomFiveAdj = 6;
        marginY = 10;
        histogramHeight = 25;
    }

    (:Round416)
    hidden function loadResources() as Void {
        fontClock = Application.loadResource(Rez.Fonts.segments125);
        fontClockOutline = Application.loadResource(Rez.Fonts.segments125outline);
        fontTinyData = Application.loadResource(Rez.Fonts.led_small_lines);
        if(propSmallFontVariant == 0) { fontSmallData = Application.loadResource(Rez.Fonts.led); }
        if(propSmallFontVariant == 1) { fontSmallData = Application.loadResource(Rez.Fonts.led_inbetween); }
        if(propSmallFontVariant == 2) { fontSmallData = Application.loadResource(Rez.Fonts.led_lines); }
        fontLargeData = Application.loadResource(Rez.Fonts.led_big);
        fontBottomData = fontLargeData;
        fontLabel = Application.loadResource(Rez.Fonts.storre);
        fontAODData = Application.loadResource(Rez.Fonts.led);
        fontBattery = fontTinyData;

        drawGradient = Application.loadResource(Rez.Drawables.gradient) as BitmapResource;
        if(propClockOutlineStyle == 0 or propClockOutlineStyle == 2 or propClockOutlineStyle == 4) {
            drawAODPattern = Application.loadResource(Rez.Drawables.aod) as BitmapResource;
        } else {
            drawAODPattern = Application.loadResource(Rez.Drawables.aod2) as BitmapResource;
        }

        clockHeight = 125;
        clockWidth = 360;
        labelHeight = 10;
        labelMargin = 8;
        tinyDataHeight = 13;
        smallDataHeight = 20;
        largeDataHeight = 27;

        baseX = centerX;
        baseY = centerY - smallDataHeight - 5;
        barBottomAdj = 2;
        bottomFiveAdj = 8;
        histogramHeight = 25;
    }

    (:Round454)
    hidden function loadResources() as Void {
        fontClock = Application.loadResource(Rez.Fonts.segments145);
        fontClockOutline = Application.loadResource(Rez.Fonts.segments145outline);
        fontTinyData = Application.loadResource(Rez.Fonts.led_small_lines);
        if(propSmallFontVariant == 0) { fontSmallData = Application.loadResource(Rez.Fonts.led); }
        if(propSmallFontVariant == 1) { fontSmallData = Application.loadResource(Rez.Fonts.led_inbetween); }
        if(propSmallFontVariant == 2) { fontSmallData = Application.loadResource(Rez.Fonts.led_lines); }
        fontLargeData = Application.loadResource(Rez.Fonts.led_big);
        fontBottomData = fontLargeData;
        fontLabel = Application.loadResource(Rez.Fonts.storre);
        fontAODData = Application.loadResource(Rez.Fonts.led);
        fontBattery = fontTinyData;

        drawGradient = Application.loadResource(Rez.Drawables.gradient) as BitmapResource;
        if(propClockOutlineStyle == 0 or propClockOutlineStyle == 2 or propClockOutlineStyle == 4) {
            drawAODPattern = Application.loadResource(Rez.Drawables.aod) as BitmapResource;
        } else {
            drawAODPattern = Application.loadResource(Rez.Drawables.aod2) as BitmapResource;
        }

        clockHeight = 145;
        clockWidth = 413;
        labelHeight = 10;
        labelMargin = 8;
        tinyDataHeight = 13;
        smallDataHeight = 20;
        largeDataHeight = 27;

        baseX = centerX + 3;
        baseY = centerY - smallDataHeight + 4;
        fieldSpaceingAdj = 20;
        textSideAdj = 4;
        bottomFiveAdj = 4;
        barBottomAdj = 2;
        marginY = 17;
        histogramHeight = 30;
        histogramTargetWidth = 45;
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        lastUpdate = null;
        lastSlowUpdate = null;
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        var now = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var unix_timestamp = Time.now().value();

        if(doesPartialUpdate) {
            dc.clearClip();
            doesPartialUpdate = false;
        }

        if(lastUpdate == null or unix_timestamp - lastUpdate >= propUpdateFreq) {
            lastUpdate = unix_timestamp;
            updateData(now);
        }

        if(now.sec % 60 == 0 or lastSlowUpdate == null or unix_timestamp - lastSlowUpdate >= 60) {
            lastSlowUpdate = unix_timestamp;
            updateSlowData(now);
            updateWeather();
        }

        if(isSleeping and canBurnIn) {
            drawAOD(dc, now);
        } else {
            drawWatchface(dc, now);
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        lastUpdate = null;
        lastSlowUpdate = null;
        isSleeping = false;
        WatchUi.requestUpdate();
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        lastUpdate = null;
        lastSlowUpdate = null;
        isSleeping = true;
        WatchUi.requestUpdate();
    }

    function onSettingsChanged() as Void {
        initialize();
        lastUpdate = null;
        lastSlowUpdate = null;
        WatchUi.requestUpdate();
    }

    function onPartialUpdate(dc) {
        if(canBurnIn) { return; }
        if(!propAlwaysShowSeconds) { return; }
        doesPartialUpdate = true;

        var clip_width = 24;
        var clip_height = 20;
        var now = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var y1 = baseY + halfClockHeight + marginY;

        updateSeconds(now);
        
        dc.setClip(baseX + halfClockWidth - textSideAdj - clip_width, y1, clip_width, clip_height);
        dc.setColor(themeColors[bg], themeColors[bg]);
        dc.clear();

        dc.setColor(themeColors[date], Graphics.COLOR_TRANSPARENT);
        dc.drawText(baseX + halfClockWidth - textSideAdj, y1, fontSmallData, dataSeconds, Graphics.TEXT_JUSTIFY_RIGHT);
    }

    hidden function drawWatchface(dc as Dc, now as Gregorian.Info) as Void {
        // Clear
        dc.setColor(themeColors[bg], themeColors[bg]);
        dc.clear();
        var yn1 = baseY - halfClockHeight - marginY - smallDataHeight;
        var yn2 = yn1 - marginY - smallDataHeight;
        var yn3 = yn2 - marginY - histogramHeight;

        // Draw Top data fields or histogram
        if(propTopPartShows == 2) {
            drawHistogram(dc, dataGraph1, centerX, yn3, histogramHeight);
        } else {
            var top_data_height = halfMarginY;
            var top_field_font = fontTinyData;
            var top_field_center_offset = 20;
            if(propTopPartShows == 1) { top_field_center_offset = labelHeight; }
            if(propLabelVisibility == 0 or propLabelVisibility == 3) {
                dc.setColor(themeColors[fieldLbl], Graphics.COLOR_TRANSPARENT);
                dc.drawText(centerX - top_field_center_offset, marginY, fontLabel, dataLabelTopLeft, Graphics.TEXT_JUSTIFY_RIGHT);
                dc.drawText(centerX + top_field_center_offset, marginY, fontLabel, dataLabelTopRight, Graphics.TEXT_JUSTIFY_LEFT);

                top_data_height = labelHeight + halfMarginY;
            }

            dc.setColor(themeColors[dataVal], Graphics.COLOR_TRANSPARENT);
            if(propTopPartShows == 0) {
                dc.drawText(centerX - top_field_center_offset, marginY + top_data_height, top_field_font, dataTopLeft, Graphics.TEXT_JUSTIFY_RIGHT);
                dc.drawText(centerX + top_field_center_offset, marginY + top_data_height, top_field_font, dataTopRight, Graphics.TEXT_JUSTIFY_LEFT);

                // Draw Moon
                dc.setColor(themeColors[moon], Graphics.COLOR_TRANSPARENT);
                dc.drawText(centerX, marginY + ((top_data_height + tinyDataHeight) / 2), fontMoon, dataMoon, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            } else {
                if(top_data_height == halfMarginY) { top_field_font = fontSmallData; }
                dc.drawText(centerX - top_field_center_offset, marginY + top_data_height, top_field_font, dataTopLeft, Graphics.TEXT_JUSTIFY_RIGHT);
                dc.drawText(centerX + top_field_center_offset, marginY + top_data_height, top_field_font, dataTopRight, Graphics.TEXT_JUSTIFY_LEFT);
            }
        }

        // Draw Lines above clock
        dc.setColor(themeColors[dataVal], Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, yn2, fontSmallData, dataAboveLine1, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, yn1, fontSmallData, dataAboveLine2, Graphics.TEXT_JUSTIFY_CENTER);        

        // Draw Clock
        dc.setColor(themeColors[clockBg], Graphics.COLOR_TRANSPARENT);
        if(propShowClockBg) {
            dc.drawText(baseX, baseY, fontClock, clockBgText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
        dc.setColor(themeColors[clock], Graphics.COLOR_TRANSPARENT);
        dc.drawText(baseX, baseY, fontClock, dataClock, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Draw clock gradient
        if(drawGradient != null and themeColors[bg] == 0x000000) {
            dc.drawBitmap(centerX - halfClockWidth, baseY - halfClockHeight, drawGradient);
        }

        if(propClockOutlineStyle == 2 or propClockOutlineStyle == 3) {
            if(fontClockOutline != null) { // Someone has only bothered to draw this font for AMOLED sizes
                // Draw outline
                dc.setColor(themeColors[outline], Graphics.COLOR_TRANSPARENT);
                dc.drawText(baseX, baseY, fontClockOutline, dataClock, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            }
        }

        // Draw stress and body battery bars
        drawStressAndBodyBattery(dc);

        // Draw Line below clock
        var y1 = baseY + halfClockHeight + marginY;
        dc.setColor(themeColors[date], Graphics.COLOR_TRANSPARENT);
        if(propDateAlignment == 0) {
            dc.drawText(baseX - halfClockWidth + textSideAdj, y1, fontSmallData, dataBelow, Graphics.TEXT_JUSTIFY_LEFT);
        } else {
            dc.drawText(baseX, y1, fontSmallData, dataBelow, Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Draw seconds
        if(propShowSeconds) {
            updateSeconds(now);
            dc.drawText(baseX + halfClockWidth - textSideAdj, y1, fontSmallData, dataSeconds, Graphics.TEXT_JUSTIFY_RIGHT);
        }

        // Draw Notification count
        dc.setColor(themeColors[notif], Graphics.COLOR_TRANSPARENT);
        if(propDateAlignment == 0) {
            if(!propShowSeconds) { // No seconds, notification on right side
                dc.drawText(baseX + halfClockWidth - textSideAdj, y1, fontSmallData, dataNotifications, Graphics.TEXT_JUSTIFY_RIGHT);
            } else {
                var date_width = dc.getTextWidthInPixels(dataBelow, fontSmallData);
                var sec_width = dc.getTextWidthInPixels(dataSeconds, fontSmallData); 
                var date_right_edge = baseX - halfClockWidth + textSideAdj + date_width;
                var sec_left = baseX + halfClockWidth - textSideAdj - sec_width;
                var pos = sec_left - marginX;
                if((sec_left - date_right_edge) < 3 * marginX) {
                    pos = (date_right_edge + sec_left) / 2;
                }
                dc.drawText(pos, y1, fontSmallData, dataNotifications, Graphics.TEXT_JUSTIFY_CENTER);
            }
        } else { // Date is centered, notification on left side
            dc.drawText(baseX - halfClockWidth, y1, fontSmallData, dataNotifications, Graphics.TEXT_JUSTIFY_LEFT);
        }

        // Draw the three bottom data fields
        var y2 = y1 + smallDataHeight + marginY;
        var y3 = y2 + labelHeight + labelMargin + largeDataHeight;
        var data_width = Math.sqrt(centerY*centerY - (y3 - centerY)*(y3 - centerY)) * 2 + fieldSpaceingAdj;
        var left_edge = Math.round((screenWidth - data_width) / 2);
        var digits = getFieldWidths();
        var tot_digits = digits[0] + digits[1] + digits[2] + digits[3];
        var dw1 = Math.round(digits[0] * data_width / tot_digits);
        var dw2 = Math.round(digits[1] * data_width / tot_digits);
        var dw3 = Math.round(digits[2] * data_width / tot_digits);
        var dw4 = Math.round(digits[3] * data_width / tot_digits);

        drawDataField(dc, left_edge + Math.round(dw1 / 2), y2, 3, dataLabelBottomLeft, dataBottomLeft, "#", digits[0], fontLargeData);
        drawDataField(dc, left_edge + Math.round(dw1 + (dw2 / 2)), y2, 3, dataLabelBottomMiddle, dataBottomMiddle, "#", digits[1], fontLargeData);
        drawDataField(dc, left_edge + Math.round(dw1 + dw2 + (dw3 / 2)), y2, 3, dataLabelBottomRight, dataBottomRight, "#", digits[2], fontLargeData);
        drawDataField(dc, left_edge + Math.round(dw1 + dw2 + dw3 + (dw4 / 2)), y2, 3, dataLabelBottomFourth, dataBottomFourth, "#", digits[3], fontLargeData);

        // Draw the 5 digit bottom field
        var y4 = y3 + halfMarginY + bottomFiveAdj;
        if((propLabelVisibility == 1 or propLabelVisibility == 3)) { y4 = y4 - labelHeight; }
        var step_width = 0;
        if(screenHeight == 240) {
            step_width = drawDataField(dc, centerX - 19, y4 + 3, 0, null, dataBottom, bottomFieldBg, 5, fontBottomData);
        } else {
            step_width = drawDataField(dc, centerX, y4, 0, null, dataBottom, bottomFieldBg, 5, fontBottomData);
        }

        // Draw icons
        dc.setColor(themeColors[dataVal], Graphics.COLOR_TRANSPARENT);
        if(screenHeight == 240) { step_width += 30; }
        dc.drawText(centerX - (step_width / 2) - (marginX / 2), y4 + (largeDataHeight / 2) + iconYAdj, fontIcons, dataIcon1, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(centerX + (step_width / 2) + (marginX / 2) - 2, y4 + (largeDataHeight / 2) + iconYAdj, fontIcons, dataIcon2, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        
        // Draw battery icon
        if(screenHeight == 240) {
            drawBatteryIcon(dc, centerX + 32, y4);
        } else {
            drawBatteryIcon(dc, null, null);
        }
    }

    (:MIP)
    hidden function drawAOD(dc as Dc, now as Gregorian.Info) as Void { }

    (:AMOLED)
    hidden function drawAOD(dc as Dc, now as Gregorian.Info) as Void {
        // Clear
        dc.setColor(0x000000, 0x000000);
        dc.clear();

        var clock_color = themeColors[clock];
        if(clock_color == 0x000000) { clock_color = 0x555555; }

        if(propClockOutlineStyle == 0 or propClockOutlineStyle == 2 or propClockOutlineStyle == 5) {
            // Draw Clock
            dc.setColor(clock_color, Graphics.COLOR_TRANSPARENT);
            dc.drawText(baseX, baseY, fontClock, dataClock, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        if(propClockOutlineStyle == 1 or propClockOutlineStyle == 2 or propClockOutlineStyle == 3) {
            dc.setColor(themeColors[outline], Graphics.COLOR_TRANSPARENT);
            dc.drawText(baseX, baseY, fontClockOutline, dataClock, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        if(propClockOutlineStyle == 4) {
            // Filled clock but outline color
            dc.setColor(themeColors[outline], Graphics.COLOR_TRANSPARENT);
            dc.drawText(baseX, baseY, fontClock, dataClock, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        // Draw clock gradient
        dc.drawBitmap(centerX - halfClockWidth - (now.min % 2), baseY - halfClockHeight, drawAODPattern);

        // Draw Line below clock
        var y1 = baseY + halfClockHeight + marginY;
        dc.setColor(themeColors[dateDim], Graphics.COLOR_TRANSPARENT);
        if(propAodAlignment == 0) {
            dc.drawText(baseX - halfClockWidth + textSideAdj - (now.min % 3), y1, fontAODData, dataAODLeft, Graphics.TEXT_JUSTIFY_LEFT);
        } else {
            dc.drawText(baseX - (now.min % 3), y1, fontAODData, dataAODLeft, Graphics.TEXT_JUSTIFY_CENTER);
        }
        dc.drawText(baseX + halfClockWidth - textSideAdj - 2 - (now.min % 3), y1, fontAODData, dataAODRight, Graphics.TEXT_JUSTIFY_RIGHT);
    }

    hidden function getFieldWidths() as Array<Number> {
        if(propFieldLayout == 0) { // Auto
            return bottomFieldWidths;
        } else if(propFieldLayout == 1) {
            return [3, 3, 3, 0];
        } else if(propFieldLayout == 2) {
            return [3, 4, 3, 0];
        } else if(propFieldLayout == 3) {
            return [3, 3, 4, 0];
        } else if(propFieldLayout == 4) {
            return [4, 3, 3, 0];
        } else if(propFieldLayout == 5) {
            return [4, 3, 4, 0];
        } else if(propFieldLayout == 6) {
            return [3, 4, 4, 0];
        } else if(propFieldLayout == 7) {
            return [4, 4, 3, 0];
        } else if(propFieldLayout == 8) {
            return [4, 4, 4, 0];
        } else if(propFieldLayout == 9) {
            return [3, 3, 3, 3];
        } else if(propFieldLayout == 10) {
            return [3, 3, 3, 4];
        } else if(propFieldLayout == 11) {
            return [4, 3, 3, 3];
        } else if(propFieldLayout == 12) {
            return [4, 4, 0, 0];
        } else {
            return [5, 3, 3, 0];
        } 
    }

    hidden function drawDataField(dc as Dc, x as Number, y as Number, adjX as Number, label as String?, value as String, bgChar as String, width as Number, font as FontResource) as Number {
        if(value.equals("") and (label == null or label.equals(""))) { return 0; }
        if(width == 0) { return 0; }
        var valueBg = "";
        for(var i=0; i<width; i++) { valueBg += bgChar; }

        var value_bg_width = dc.getTextWidthInPixels(valueBg, font);
        var half_bg_width = Math.round(value_bg_width / 2);
        var data_y = y;

        if((propLabelVisibility == 0 or propLabelVisibility == 2) and !(label == null)) {
            dc.setColor(themeColors[fieldLbl], Graphics.COLOR_TRANSPARENT);
            dc.drawText(x - half_bg_width + adjX, y, fontLabel, label, Graphics.TEXT_JUSTIFY_LEFT);

            data_y += labelHeight + labelMargin;
        }

        if(propShowDataBg) {
            dc.setColor(themeColors[fieldBg], Graphics.COLOR_TRANSPARENT);
            dc.drawText(x - half_bg_width + adjX, data_y, font, valueBg, Graphics.TEXT_JUSTIFY_LEFT);
        }

        dc.setColor(themeColors[dataVal], Graphics.COLOR_TRANSPARENT);
        if(propBottomFieldAlignment == 0) {
            dc.drawText(x - half_bg_width + adjX, data_y, font, value, Graphics.TEXT_JUSTIFY_LEFT);
        } else if (propBottomFieldAlignment == 1) {
            dc.drawText(x + adjX, data_y, font, value, Graphics.TEXT_JUSTIFY_CENTER);
        } else if (propBottomFieldAlignment == 2) {
            dc.drawText(x + half_bg_width - 1 + adjX, data_y, font, value, Graphics.TEXT_JUSTIFY_RIGHT);
        } else if (propBottomFieldAlignment == 3 and width != 5) {
            dc.drawText(x - half_bg_width + adjX, data_y, font, value, Graphics.TEXT_JUSTIFY_LEFT);
        } else if (propBottomFieldAlignment == 3 and width == 5) {
            dc.drawText(x + adjX, data_y, font, value, Graphics.TEXT_JUSTIFY_CENTER);
        }

        return value_bg_width;
    }

    hidden function drawStressAndBodyBattery(dc as Dc) as Void {
        if(!propShowStressAndBodyBattery) { return; }

        if (dataBbatt != null and dataStress != null) {
            var batt_bar = Math.round(dataBbatt * (clockHeight / 100.0));
            dc.setColor(themeColors[bodybatt], Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(centerX + halfClockWidth + barWidth, baseY + halfClockHeight - batt_bar + barBottomAdj, barWidth, batt_bar);

            var stress_bar = Math.round(dataStress * (clockHeight / 100.0));
            dc.setColor(themeColors[stress], Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(centerX - halfClockWidth - barWidth - barWidth, baseY + halfClockHeight - stress_bar + barBottomAdj, barWidth, stress_bar);
        }
    }

    hidden function drawHistogram(dc as Dc, data as Array<Number>?, x as Number, y as Number, h as Number) as Void {
        if(data == null) { return; }
        var scale = 100.0 / h;
        var half_width = Math.round((data.size() * (histogramBarWidth + histogramBarSpacing)) / 2);
        var bar_height = 0;

        dc.setColor(themeColors[clock], Graphics.COLOR_TRANSPARENT);
        for(var i=0; i<data.size(); i++) {
            if(data[i] == null) { break; }
            if(propHistogramData == 7) {
                if(data[i] <= 25) {
                    dc.setColor(themeColors[bodybatt], Graphics.COLOR_TRANSPARENT);
                } else {
                    dc.setColor(themeColors[stress], Graphics.COLOR_TRANSPARENT);
                }
            }
            bar_height = Math.round(data[i] / scale);
            dc.drawRectangle(x - half_width + i * (histogramBarWidth + histogramBarSpacing), y + (h - bar_height), histogramBarWidth, bar_height);
        }
    }

    (:AMOLED)
    hidden function drawBatteryIcon(dc as Dc, x as Number?, y as Number?) {
        var visible = (!isSleeping) && propBatteryVariant != 2;  // Only show if not in AOD and battery is not hidden
        if(!visible) { return; }
        if(x == null) { x = centerX; }
        if(y == null) { y =  screenHeight - 25; }

        dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, fontIcons, "C", Graphics.TEXT_JUSTIFY_CENTER);
        if(System.getSystemStats().battery <= 15) {
            dc.setColor(0xFF0000, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(themeColors[dataVal], Graphics.COLOR_TRANSPARENT);
        }
        dc.drawText(x - 19, y + 4, fontBattery, dataBattery, Graphics.TEXT_JUSTIFY_LEFT);
    }

    (:MIP)
    hidden function drawBatteryIcon(dc as Dc, x as Number?, y as Number?) {
        if(propBatteryVariant == 2) { return; }
        if(x == null) { x = centerX; }
        if(y == null) { y =  screenHeight - 18; }

        dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, fontIcons, "B", Graphics.TEXT_JUSTIFY_CENTER);
        if(System.getSystemStats().battery <= 15) {
            dc.setColor(0xFF0000, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(themeColors[dataVal], Graphics.COLOR_TRANSPARENT);
        }
        dc.drawText(x - 11, y + 3, fontBattery, dataBattery, Graphics.TEXT_JUSTIFY_LEFT);
    }

    (:MIP)
    hidden function setColorTheme(theme as Number) as Array<Graphics.ColorType> {
        if(theme == 30) { return customColorTheme(); }
        var skip = Graphics.COLOR_TRANSPARENT;
        var colBlack = Graphics.COLOR_BLACK;
        var colWhite = Graphics.COLOR_WHITE;

        //                        bg,       clock,    clockBg,  outl, dataVal,  fieldBg,  fieldLbl, date,     dDim, notif,    stress,   bodybatt, moon
        if(theme == 0 ) { return [colBlack, 0xFFFF00, 0x005555, skip, colWhite, 0x005555, 0x55AAAA, 0xFFFF00, skip, 0x00AAFF, 0xFFAA00, 0x00AAFF, colWhite]; } // Yellow on turquoise MIP
        if(theme == 1 ) { return [colBlack, 0xFF55AA, 0x005555, skip, colWhite, 0x005555, 0xAA55AA, colWhite, skip, 0xFF55AA, 0xFF55AA, 0x00FFAA, colWhite]; } // Hot pink MIP
        if(theme == 2 ) { return [colBlack, 0x00FFFF, 0x0055AA, skip, colWhite, 0x0055AA, 0x55AAAA, 0x00FFFF, skip, 0x00AAFF, 0xFFAA00, 0x00AAFF, colWhite]; } // Blueish green MIP
        if(theme == 3 ) { return [colBlack, 0x00FF00, 0x005500, skip, colWhite, 0x005500, 0x00AA55, 0x00FF00, skip, 0x00AAFF, 0xFFAA00, 0x00AAFF, colWhite]; } // Very green MIP
        if(theme == 4 ) { return [colBlack, colWhite, 0x005555, skip, colWhite, 0x005555, 0x55AAAA, colWhite, skip, 0xAAAAAA, 0xFFAA55, 0x55AAFF, colWhite]; } // White on turquoise MIP
        if(theme == 5 ) { return [colBlack, 0xFF5500, 0x5500AA, skip, colWhite, 0x5500AA, 0xFFAAAA, 0xFFAAAA, skip, colWhite, 0xFF5555, 0x00AAFF, colWhite]; } // Peachy Orange MIP
        if(theme == 6 ) { return [colBlack, colWhite, 0xAA0000, skip, colWhite, 0xAA0000, 0xFF0000, colWhite, skip, 0xFF0000, 0xAA0000, 0x00AAFF, colWhite]; } // Red and White MIP
        if(theme == 7 ) { return [colBlack, colWhite, 0x0055AA, skip, colWhite, 0x0055AA, 0x0055AA, colWhite, skip, 0x55AAFF, 0xFFAA00, 0x55AAFF, colWhite]; } // White on Blue MIP
        if(theme == 8 ) { return [colBlack, 0xFFFF00, 0x0055AA, skip, colWhite, 0x0055AA, 0x0055AA, 0xFFFF00, skip, 0x55AAFF, 0xFFAA00, 0x55AAFF, colWhite]; } // Yellow on Blue MIP
        if(theme == 9 ) { return [colBlack, colWhite, 0xaa5500, skip, colWhite, 0xaa5500, 0xFF5500, colWhite, skip, 0x00AAFF, 0xFFAA00, 0x00AAFF, colWhite]; } // White and Orange MIP
        if(theme == 10) { return [colBlack, 0x0055AA, 0x000055, skip, colWhite, 0x555555, 0x0055AA, colWhite, skip, 0x55AAFF, 0xFFAA00, 0x55AAFF, colWhite]; } // Blue MIP
        if(theme == 11) { return [colBlack, 0xFFAA00, 0x555555, skip, colWhite, 0x555555, 0xFFAA00, colWhite, skip, 0x55AAFF, 0xFFAA00, 0x55AAFF, colWhite]; } // Orange MIP
        if(theme == 12) { return [colBlack, colWhite, 0x555555, skip, colWhite, 0x555555, colWhite, colWhite, skip, 0x55AAFF, 0xFFAA00, 0x55AAFF, colWhite]; } // White on black MIP
        if(theme == 13) { return [colWhite, colBlack, 0xAAAAAA, skip, colBlack, 0xAAAAAA, colBlack, colBlack, skip, colBlack, 0xFFAA00, 0x55AAFF, 0x555555]; } // Black on White MIP
        if(theme == 14) { return [colWhite, 0xAA0000, 0xAAAAAA, skip, colBlack, 0xAAAAAA, 0xAA0000, colBlack, skip, colBlack, 0xFFAA00, 0x55AAFF, 0x555555]; } // Red on White MIP
        if(theme == 15) { return [colWhite, 0x0000AA, 0xAAAAAA, skip, colBlack, 0xAAAAAA, 0x0000AA, colBlack, skip, colBlack, 0xFFAA00, 0x55AAFF, 0x555555]; } // Blue on White MIP
        if(theme == 16) { return [colWhite, 0x00AA00, 0xAAAAAA, skip, colBlack, 0xAAAAAA, 0x00AA00, colBlack, skip, colBlack, 0xFFAA00, 0x55AAFF, 0x555555]; } // Green on White MIP
        if(theme == 17) { return [colWhite, 0xFF5500, 0xAAAAAA, skip, colBlack, 0xAAAAAA, 0x555555, colBlack, skip, colBlack, 0xFF5500, 0x55AAFF, 0x555555]; } // Orange on White MIP
        if(theme == 18) { return [colBlack, 0xFF5500, 0x005500, skip, 0x00FF00, 0x005500, 0xFF5500, 0x00FF00, skip, 0x55FF55, 0xFF5500, 0x00AAFF, colWhite]; } // Green and Orange MIP
        if(theme == 19) { return [colBlack, 0xAAAA55, 0x005500, skip, 0x00FF00, 0x005500, 0xAAAA00, 0xAAAA55, skip, 0x00FF55, 0xAAAA55, 0x00FF00, colWhite]; } // Green Camo MIP
        if(theme == 20) { return [colBlack, 0xFF0000, 0x555555, skip, colWhite, 0x555555, 0xFF0000, colWhite, skip, 0x55AAFF, 0xFF5555, 0x55AAFF, colWhite]; } // Red on Black MIP
        if(theme == 21) { return [colWhite, 0xAA00FF, 0xAAAAAA, skip, colBlack, 0xAAAAAA, 0xAA00FF, colBlack, skip, colBlack, 0xFF5500, 0x55AAFF, 0x555555]; } // Purple on White MIP
        if(theme == 22) { return [colBlack, 0xAA00FF, 0x555555, skip, colWhite, 0x555555, 0xAA00FF, colWhite, skip, 0x55AAFF, 0xFFAA00, 0x55AAFF, colWhite]; } // Purple on black MIP
        if(theme == 23) { return [colBlack, 0xFFAA00, 0x555555, skip, 0xFFAA55, 0x555555, 0xFFAA00, 0xFFAA55, skip, 0x55AAAA, 0xFFAA00, 0x55AAAA, colWhite]; } // Amber MIP
        infoMessage = "THEME ERROR";
        return [0xff0000, 0x00ff00, 0x0000ff, 0x550000, 0x005500, 0x000055, 0xff00ff, 0x00ffff, 0xffff00, 0x005555, 0x550055, 0x555500, 0xffffff]; // error case
    }

    (:AMOLED)
    hidden function setColorTheme(theme as Number) as Array<Graphics.ColorType> {
        if(theme == 30) { return customColorTheme(); }

        //                        bg,       clock,    clockBg,  outline,  dataVal,  fieldBg,  fieldLbl,   date,   dateDim,  notif,   stress,    bodybatt, moon
        if(theme == 0 ) { return [0x000000, 0xfbcb77, 0x0d333c, 0xffeac4, 0xFFFFFF, 0x0e333c, 0x55AAAA, 0xfbcb77, 0xa98753, 0x00AAFF, 0xFFAA00, 0x00AAFF, 0xFFFFFF]; } // Yellow on turquoise AMOLED
        if(theme == 1 ) { return [0x000000, 0xffa5f9, 0x0f3b46, 0xffd9fc, 0xFFFFFF, 0x0e333c, 0xAA55AA, 0xFFFFFF, 0x984a8a, 0xFF55AA, 0xFF55AA, 0x00FFAA, 0xFFFFFF]; } // Hot pink AMOLED
        if(theme == 2 ) { return [0x000000, 0x89efd2, 0x0f2246, 0xb8efdf, 0xFFFFFF, 0x0f2246, 0x55AAAA, 0x89efd2, 0x5ca28f, 0x00AAFF, 0xFFAA00, 0x00AAFF, 0xFFFFFF]; } // Blueish green AMOLED
        if(theme == 3 ) { return [0x000000, 0x96e0ac, 0x152b19, 0xc3e0cc, 0xFFFFFF, 0x152b19, 0x00AA55, 0x96e0ac, 0x5ca28f, 0x00AAFF, 0xffc884, 0x59b9fe, 0xFFFFFF]; } // Very green AMOLED
        if(theme == 4 ) { return [0x000000, 0xFFFFFF, 0x0d333c, 0xadeffe, 0xFFFFFF, 0x0e333c, 0x55AAAA, 0xFFFFFF, 0x1d7e99, 0xAAAAAA, 0xFFAA55, 0x55AAFF, 0xFFFFFF]; } // White on turquoise AMOLED
        if(theme == 5 ) { return [0x000000, 0xff9161, 0x1b263d, 0xffb494, 0xFFFFFF, 0x1b263d, 0xFFAAAA, 0xffb383, 0xaa6e56, 0xFFFFFF, 0xFF5555, 0x00AAFF, 0xFFFFFF]; } // Peachy Orange AMOLED
        if(theme == 6 ) { return [0x000000, 0xffffff, 0x550000, 0xc00003, 0xFFFFFF, 0x550000, 0xFF0000, 0xffffff, 0xAA0000, 0xFF0000, 0xAA0000, 0x00AAFF, 0xFFFFFF]; } // Red and White AMOLED
        if(theme == 7 ) { return [0x000000, 0xffffff, 0x152a53, 0xaecaff, 0xFFFFFF, 0x152a53, 0x0055AA, 0xffffff, 0x0055AA, 0x55AAFF, 0xFFAA00, 0x55AAFF, 0xFFFFFF]; } // White on Blue AMOLED
        if(theme == 8 ) { return [0x000000, 0xfbcb77, 0x152a53, 0xfbdda8, 0xFFFFFF, 0x152a53, 0x0055AA, 0xffeac4, 0xa98753, 0x55AAFF, 0xFFAA00, 0x55AAFF, 0xFFFFFF]; } // Yellow on Blue AMOLED
        if(theme == 9 ) { return [0x000000, 0xffffff, 0x7d3f01, 0xffd6ae, 0xFFFFFF, 0x58250b, 0xFF5500, 0xffffff, 0xAA5500, 0x00AAFF, 0xFFAA00, 0x00AAFF, 0xFFFFFF]; } // White and Orange AMOLED
        if(theme == 10) { return [0x000000, 0x3495d4, 0x191b33, 0x5fa6d4, 0xFFFFFF, 0x191b33, 0x0055AA, 0xffffff, 0x0055AA, 0x55AAFF, 0xFFAA00, 0x55AAFF, 0xFFFFFF]; } // Blue AMOLED
        if(theme == 11) { return [0x000000, 0xff7600, 0x333333, 0xff9133, 0xFFFFFF, 0x333333, 0xFFAA00, 0xffffff, 0x9a9a9a, 0x55AAFF, 0xFFAA00, 0x55AAFF, 0xFFFFFF]; } // Orange AMOLED
        if(theme == 12) { return [0x000000, 0xFFFFFF, 0x333333, 0xcbcbcb, 0xFFFFFF, 0x333333, 0xFFFFFF, 0xFFFFFF, 0x9a9a9a, 0x55AAFF, 0xFFAA00, 0x55AAFF, 0xFFFFFF]; } // White on black AMOLED
        if(theme == 13) { return [0xFFFFFF, 0x000000, 0xCCCCCC, 0x666666, 0x000000, 0xCCCCCC, 0x000000, 0x000000, 0x9a9a9a, 0x000000, 0xFFAA00, 0x55AAFF, 0x555555]; } // Black on White AMOLED
        if(theme == 14) { return [0xFFFFFF, 0xAA0000, 0xCCCCCC, 0xaa2325, 0x000000, 0xCCCCCC, 0xAA0000, 0x000000, 0x9a9a9a, 0x000000, 0xFFAA00, 0x55AAFF, 0x555555]; } // Red on White AMOLED
        if(theme == 15) { return [0xFFFFFF, 0x0000AA, 0xCCCCCC, 0x2222aa, 0x000000, 0xCCCCCC, 0x0000AA, 0x000000, 0x9a9a9a, 0x000000, 0xFFAA00, 0x55AAFF, 0x555555]; } // Blue on White AMOLED
        if(theme == 16) { return [0xFFFFFF, 0x00AA00, 0xCCCCCC, 0x22aa22, 0x000000, 0xCCCCCC, 0x00AA00, 0x000000, 0x9a9a9a, 0x000000, 0xFFAA00, 0x55AAFF, 0x555555]; } // Green on White AMOLED
        if(theme == 17) { return [0xFFFFFF, 0xFF5500, 0xCCCCCC, 0xff7632, 0x000000, 0xCCCCCC, 0x555555, 0x000000, 0x9a9a9a, 0x000000, 0xFF5500, 0x55AAFF, 0x555555]; } // Orange on White AMOLED
        if(theme == 18) { return [0x000000, 0xff7600, 0x152b19, 0xe64322, 0x41cb41, 0x152b19, 0xFF5500, 0x41cb41, 0x5f9956, 0x41cb41, 0xff7600, 0x59b9fe, 0xFFFFFF]; } // Green and Orange AMOLED
        if(theme == 19) { return [0x000000, 0x889f4a, 0x152b19, 0x919f6b, 0x55AA55, 0x152b19, 0xa8aa6c, 0x889f4a, 0x7a9a4e, 0x00FF55, 0x889f4a, 0x55AA55, 0xe3efd2]; } // Green Camo AMOLED
        if(theme == 20) { return [0x000000, 0xFF0000, 0x282828, 0xff3236, 0xFFFFFF, 0x282828, 0xFF0000, 0xFFFFFF, 0x9a9a9a, 0x55AAFF, 0xFF5555, 0x55AAFF, 0xFFFFFF]; } // Red on Black AMOLED
        if(theme == 21) { return [0xFFFFFF, 0xAA00FF, 0xCCCCCC, 0xbb34ff, 0x000000, 0xCCCCCC, 0xAA00FF, 0x000000, 0x9a9a9a, 0x000000, 0xFF5500, 0x55AAFF, 0x555555]; } // Purple on White AMOLED
        if(theme == 22) { return [0x000000, 0xAA55AA, 0x282828, 0xaa77aa, 0xFFFFFF, 0x282828, 0xAA55AA, 0xFFFFFF, 0x9a9a9a, 0x55AAFF, 0xFFAA00, 0x55AAFF, 0xFFFFFF]; } // Purple on black AMOLED
        if(theme == 23) { return [0x000000, 0xff960c, 0x302b24, 0xffbf65, 0xffdeb4, 0x302b24, 0xffac3f, 0xffb759, 0x9a784d, 0xa8d6fd, 0xfdb500, 0xa8d6fd, 0xe3efd2]; } // Amber AMOLED
        infoMessage = "THEME ERROR";
        return [0xff0000, 0x00ff00, 0x0000ff, 0xff00ff, 0x00ffff, 0xffff00, 0x550000, 0x005500, 0x000055, 0x005555, 0x550055, 0x555500, 0xffffff];

    }

    hidden function customColorTheme() as Array<Graphics.ColorType>{
        var ret = [];
        if(propColorOverride.equals("")) { return setColorTheme(-1); }
        var color_str = "";
        var color = null;
        for(var i=0; i<propColorOverride.length(); i += 8) {
            color_str = propColorOverride.substring(i+1, i+7);
            color = color_str.toNumberWithBase(16) as Graphics.ColorType;
            ret.add(color);
        }

        if(ret.size() != 13) {
            ret = setColorTheme(-1);
        }

        for(var j=0; j<ret.size(); j++) {
            if(ret[j] == null or ret[j] < 0 or ret[j] > 16777215) {
                ret = setColorTheme(-1);
                break;
            }
        }

        return ret;
    }

    hidden function updateColorTheme() {
        var newValue = getNightModeValue();
        if(nightModeOverride == 0) { newValue = false; }
        if(nightModeOverride == 1) { newValue = true; }

        if(nightMode != newValue) {
            if(newValue == true and propNightTheme != -1) {
                themeColors = setColorTheme(propNightTheme);
            } else {
                themeColors = setColorTheme(propTheme);
            }
            nightMode = newValue;
        }
    }

    hidden function getNightModeValue() as Boolean {
        if (propNightTheme == -1 || propNightTheme == propTheme) {
            return false;
        }

        var now = Time.now(); // Moment
        var todayMidnight = Time.today(); // Moment
        var nowAsTimeSinceMidnight = now.subtract(todayMidnight) as Duration; // Duration

        if(propNightThemeActivation == 0 or propNightThemeActivation == 1) {
            var profile = UserProfile.getProfile();
            if ((profile has :wakeTime) == false || (profile has :sleepTime) == false) {
                return false;
            }

            var wakeTime = profile.wakeTime;
            var sleepTime = profile.sleepTime;

            if (wakeTime == null || sleepTime == null) {
                return false;
            }

            if(propNightThemeActivation == 1) {
                // Start two hours before sleep time
                var twoHours = new Time.Duration(7200);
                sleepTime = sleepTime.subtract(twoHours);
            }

            if(sleepTime.greaterThan(wakeTime)) {
                return (nowAsTimeSinceMidnight.greaterThan(sleepTime) || nowAsTimeSinceMidnight.lessThan(wakeTime));
            } else {
                return (nowAsTimeSinceMidnight.greaterThan(sleepTime) and nowAsTimeSinceMidnight.lessThan(wakeTime));
            }
        }

        // From Sunset to Sunrise
        if(weatherCondition != null) {
            var nextSunEventArray = getNextSunEvent();
            if(nextSunEventArray != null && nextSunEventArray.size() == 2) { 
                return nextSunEventArray[1] as Boolean;
            }
        }

        return false;
    }

    hidden function getValueOrDefault(propName as String, defaultVal as PropertyValueType) as PropertyValueType {
        var val = Application.Properties.getValue(propName);
        if(val == null) {
            return defaultVal;
        }
        return val;
    }

    hidden function updateProperties() as Void {
        propTheme = getValueOrDefault("colorTheme", 0) as Number;
        propNightTheme = getValueOrDefault("nightColorTheme", -1) as Number;
        propNightThemeActivation = getValueOrDefault("nightThemeActivation", 0) as Number;
        propColorOverride = getValueOrDefault("colorOverride", "") as String;
        propClockOutlineStyle = getValueOrDefault("clockOutlineStyle", 0) as Number;

        propTopPartShows = getValueOrDefault("topPartShows", 0) as Number;
        propHistogramData = getValueOrDefault("histogramData", 0) as Number;
        propSunriseFieldShows = getValueOrDefault("sunriseFieldShows", 39) as Number;
        propSunsetFieldShows = getValueOrDefault("sunsetFieldShows", 40) as Number;
        propWeatherLine1Shows = getValueOrDefault("weatherLine1Shows", 49) as Number;
        propWeatherLine2Shows = getValueOrDefault("weatherLine2Shows", 50) as Number;
        propDateFieldShows = getValueOrDefault("dateFieldShows", -1) as Number;
        propShowSeconds = getValueOrDefault("showSeconds", true) as Boolean;
        propAlwaysShowSeconds = getValueOrDefault("alwaysShowSeconds", false) as Boolean;
        propFieldLayout = getValueOrDefault("fieldLayout", 0) as Number;
        propLeftValueShows = getValueOrDefault("leftValueShows", 6) as Number;
        propMiddleValueShows = getValueOrDefault("middleValueShows", 10) as Number;
        propRightValueShows = getValueOrDefault("rightValueShows", 0) as Number;
        propFourthValueShows = getValueOrDefault("fourthValueShows", -2) as Number;
        propBottomFieldShows = getValueOrDefault("bottomFieldShows", 17) as Number;
        propIcon1 = getValueOrDefault("icon1", 1) as Number;
        propIcon2 = getValueOrDefault("icon2", 2) as Number;
        propBatteryVariant = getValueOrDefault("batteryVariant", 3) as Number;
        
        propUpdateFreq = getValueOrDefault("updateFreq", 5) as Number;
        propShowClockBg = getValueOrDefault("showClockBg", true) as Boolean;
        propShowDataBg = getValueOrDefault("showDataBg", true) as Boolean;
        propAodFieldShows = getValueOrDefault("aodFieldShows", -1) as Number;
        propAodRightFieldShows = getValueOrDefault("aodRightFieldShows", -2) as Number;
        propAodAlignment = getValueOrDefault("aodAlignment", 0) as Number;
        propDateAlignment = getValueOrDefault("dateAlignment", 0) as Number;
        propBottomFieldAlignment = getValueOrDefault("bottomFieldAlignment", 2) as Number;
        propHemisphere = getValueOrDefault("hemisphere", 0) as Number;
        propHourFormat = getValueOrDefault("hourFormat", 0) as Number;
        propZeropadHour = getValueOrDefault("zeropadHour", true) as Boolean;
        propTimeSeparator = getValueOrDefault("timeSeparator", 0) as Number;
        propTempUnit = getValueOrDefault("tempUnit", 0) as Number;
        propWindUnit = getValueOrDefault("windUnit", 0) as Number;
        propPressureUnit = getValueOrDefault("pressureUnit", 0) as Number;
        propLabelVisibility = getValueOrDefault("labelVisibility", 0) as Number;
        propDateFormat = getValueOrDefault("dateFormat", 0) as Number;
        propShowStressAndBodyBattery = getValueOrDefault("showStressAndBodyBattery", true) as Boolean;
        propShowNotificationCount = getValueOrDefault("showNotificationCount", true) as Boolean;
        propTzOffset1 = getValueOrDefault("tzOffset1", 0) as Number;
        propTzOffset2 = getValueOrDefault("tzOffset2", 0) as Number;
        propTzName1 = getValueOrDefault("tzName1", "UTC TIME") as String;
        propTzName2 = getValueOrDefault("tzName2", "TZ2") as String;
        propWeekOffset = getValueOrDefault("weekOffset", 0) as Number;
        propSmallFontVariant = getValueOrDefault("smallFontVariant", 2) as Number;
        propIs24H = System.getDeviceSettings().is24Hour;
        
        nightMode = null; // force update color theme
        updateColorTheme();

        if(propTimeSeparator == 2) { clockBgText = "####"; } else { clockBgText = "#####"; }
    }

    hidden function updateData(now as Gregorian.Info) as Void {
        updateStressAndBodyBatteryData();
        var fieldWidths = getFieldWidths();
        dataTopLeft = getValueByType(propSunriseFieldShows, 5);
        dataTopRight = getValueByType(propSunsetFieldShows, 5);
        dataAboveLine1 = getValueByTypeWithUnit(propWeatherLine1Shows, 10);
        dataAboveLine2 = getValueByTypeWithUnit(propWeatherLine2Shows, 10);
        dataBelow = getValueByTypeWithUnit(propDateFieldShows, 10);
        dataNotifications = getNotificationsData();
        dataBottomLeft = getValueByType(propLeftValueShows, fieldWidths[0]);
        dataBottomMiddle = getValueByType(propMiddleValueShows, fieldWidths[1]);
        dataBottomRight = getValueByType(propRightValueShows, fieldWidths[2]);
        dataBottomFourth = getValueByType(propFourthValueShows, fieldWidths[3]);
        dataBottom = getValueByType(propBottomFieldShows, 5);
        dataIcon1 = getIconState(propIcon1);
        dataIcon2 = getIconState(propIcon2);
        dataBattery = getBattData();
        dataAODLeft = getValueByType(propAodFieldShows, 10);
        dataAODRight = getValueByType(propAodRightFieldShows, 5);

        if(!infoMessage.equals("")) {
            dataBelow = infoMessage;
            infoMessage = "";
        }
    }

    hidden function updateSlowData(now as Gregorian.Info) as Void {
        dataClock = getClockData(now);
        dataMoon = moonPhase(now);
        if(propTopPartShows == 2) {
            dataGraph1 = getDataArrayByType(propHistogramData);
        }

        var fieldWidths = getFieldWidths();
        dataLabelTopLeft = getLabelByType(propSunriseFieldShows, 1);
        dataLabelTopRight = getLabelByType(propSunsetFieldShows, 1);
        dataLabelBottomLeft = getLabelByType(propLeftValueShows, fieldWidths[0] - 1);
        dataLabelBottomMiddle = getLabelByType(propMiddleValueShows, fieldWidths[1] - 1);
        dataLabelBottomRight = getLabelByType(propRightValueShows, fieldWidths[2] - 1);
        dataLabelBottomFourth = getLabelByType(propFourthValueShows, fieldWidths[3] - 1);

        updateColorTheme();
    }

    hidden function updateSeconds(now as Gregorian.Info) as Void {
        if(isSleeping and (!propAlwaysShowSeconds or canBurnIn)) {
            dataSeconds = "";
        } else {
            dataSeconds = now.sec.format("%02d");
        }
    }

    hidden function getClockData(now as Gregorian.Info) as String {
        var separator = ":";
        if(propTimeSeparator == 1) { separator = " "; }
        if(propTimeSeparator == 2) { separator = ""; }

        if(propZeropadHour) {
            return Lang.format("$1$$2$$3$", [formatHour(now.hour).format("%02d"), separator, now.min.format("%02d")]);
        } else {
            return Lang.format("$1$$2$$3$", [formatHour(now.hour).format("%2d"), separator, now.min.format("%02d")]);
        }
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

    hidden function updateStressAndBodyBatteryData() as Void {
        if (hasComplications) {
            try {
                var complication_stress = Complications.getComplication(new Id(Complications.COMPLICATION_TYPE_STRESS));
                if (complication_stress != null && complication_stress.value != null) {
                    dataStress = complication_stress.value;
                }
                var complication_bb = Complications.getComplication(new Id(Complications.COMPLICATION_TYPE_BODY_BATTERY));
                if (complication_bb != null && complication_bb.value != null) {
                    dataBbatt = complication_bb.value;
                }

                return;
            } catch(e) {
                // Complication not found
            }
            
        }

        if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory) && (Toybox.SensorHistory has :getStressHistory)) {
            var bb_iterator = Toybox.SensorHistory.getBodyBatteryHistory({:period => 1});
            var st_iterator = Toybox.SensorHistory.getStressHistory({:period => 1});
            var bb = bb_iterator.next();
            var st = st_iterator.next();

            if(bb != null) {
                dataBbatt = bb.data;
            }
            if(st != null) {
                dataStress = st.data;
            }
        }
    }

    hidden function getBattData() as String {
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

            for(var i = 0; i < max - sample; i++) {
                value += "{"; // rendered as 1px space to always fill the same number of px
            }
        }
        
        return value;
    }

    hidden function getNotificationsData() as String {
        var value = "";

        if(propShowNotificationCount) {
            var sample = System.getDeviceSettings().notificationCount;
            if(sample > 0) {
                value = sample.format("%01d");
            }
        }

        return value;
    }

    hidden function formatHour(hour as Number) as Number {
        if((!propIs24H and propHourFormat == 0) or propHourFormat == 2) {
            hour = hour % 12;
            if(hour == 0) { hour = 12; }
        }
        return hour;
    }

    hidden function updateWeather() as Void {
        if(!(Toybox has :Weather) or !(Weather has :getCurrentConditions)) { return; }

        if(Weather.getCurrentConditions() != null) {
            weatherCondition = Weather.getCurrentConditions();
            try {
                storeWeatherData();
            } catch(e) {}
        } else {
            try {
                weatherCondition = readWeatherData();
            } catch(e) {}
            
        }
        
    }

    hidden function storeWeatherData() as Void {
        var cc = Weather.getCurrentConditions();
        var cc_data = {};
        if(cc != null) {
            cc_data["timestamp"] = Time.now().value();
            if(cc.observationLocationPosition != null) {
                cc_data["observationLocationPosition"] = cc.observationLocationPosition.toDegrees();
            }
            if(cc.condition != null) { cc_data["condition"] = cc.condition; }
            if(cc.highTemperature != null) { cc_data["highTemperature"] = cc.highTemperature; }
            if(cc.lowTemperature != null) { cc_data["lowTemperature"] = cc.lowTemperature; }
            if(cc.precipitationChance != null) { cc_data["precipitationChance"] = cc.precipitationChance; }
            if(cc.relativeHumidity != null) { cc_data["relativeHumidity"] = cc.relativeHumidity; }
            if(cc.temperature != null) { cc_data["temperature"] = cc.temperature; }
            if(cc.feelsLikeTemperature != null) { cc_data["feelsLikeTemperature"] = cc.feelsLikeTemperature; }
            if(cc.windBearing != null) { cc_data["windBearing"] = cc.windBearing; }
            if(cc.windSpeed != null) { cc_data["windSpeed"] = cc.windSpeed; }
            if(cc has :uvIndex and cc.uvIndex != null) { cc_data["uvIndex"] = cc.uvIndex; }
        }
        Application.Storage.setValue("current_conditions", cc_data);
        cc_data = null;
        cc = null; 

        if(System.getSystemStats().freeMemory > 15000) {
            var hf = Weather.getHourlyForecast();
            var hf_data = [];
            var tmp = {};
            if(hf != null) {
                for(var i=0; i<hf.size(); i++) {
                    tmp = {
                        "forecastTime" => hf[i].forecastTime.value(),
                        "condition" => hf[i].condition,
                        "precipitationChance" => hf[i].precipitationChance,
                        "temperature" => hf[i].temperature,
                        "windBearing" => hf[i].windBearing,
                        "windSpeed" => hf[i].windSpeed
                    };
                    if(hf[i] has :uvIndex) { tmp["uvIndex"] = hf[i].uvIndex; }
                    hf_data.add(tmp);
                }
            }
            Application.Storage.setValue("hourly_forecast", hf_data);
        } else {
            Application.Storage.setValue("hourly_forecast", []);
        }
    }

    hidden function readWeatherData() as StoredWeather {
        var ret = new StoredWeather();
        var now = Time.now().value();
        var cc_data = Application.Storage.getValue("current_conditions") as Dictionary<String, Application.PropertyValueType>?;
        if(cc_data == null) { return ret; }
        
        var data_age_s = now - (cc_data.get("timestamp") as Number);
        var pos = cc_data.get("observationLocationPosition") as Array;
        ret.observationLocationPosition = new Position.Location({:latitude => pos[0], :longitude => pos[1], :format => :degrees});
        if(data_age_s > 0 and data_age_s < 3600) {
            ret.condition = cc_data.get("condition") as Number;
            ret.highTemperature = cc_data.get("highTemperature") as Number;
            ret.lowTemperature = cc_data.get("lowTemperature") as Number;
            ret.precipitationChance = cc_data.get("precipitationChance") as Number;
            ret.relativeHumidity = cc_data.get("relativeHumidity") as Number;
            ret.temperature = cc_data.get("temperature") as Number;
            ret.feelsLikeTemperature = cc_data.get("feelsLikeTemperature") as Float;
            ret.windBearing = cc_data.get("windBearing") as Number;
            ret.windSpeed = cc_data.get("windSpeed") as Float;
            ret.uvIndex = cc_data.get("uvIndex") as Float;
        } else {
            var hf_data = Application.Storage.getValue("hourly_forecast") as Array?;
            if(hf_data == null) { return ret; }
            for(var i=0; i<hf_data.size(); i++) {
                var forecast_age = now - (hf_data[i].get("forecastTime") as Number);
                if(forecast_age > 0 and forecast_age < 3600) {
                    ret.condition = hf_data[i].get("condition") as Number;
                    ret.temperature = hf_data[i].get("temperature") as Number;
                    ret.precipitationChance = hf_data[i].get("precipitationChance") as Number;
                    ret.windBearing = hf_data[i].get("windBearing") as Number;
                    ret.windSpeed = hf_data[i].get("windSpeed") as Float;
                    ret.uvIndex = cc_data.get("uvIndex") as Float;
                }
            }
        }
        
        return ret;
    }

    hidden function getBatteryBars() as String {
        var bat = Math.round(System.getSystemStats().battery / 100.0 * 6);
        var value = "";
        for(var i = 0; i < bat; i++) {
            value += "|";
        }
        return value;
    }

    hidden function getValueByTypeWithUnit(complicationType as Number, width as Number) as String {
        var unit = getUnitByType(complicationType);
        if (unit.length() > 0) {
            unit = Lang.format(" $1$", [unit]);
        }
        return Lang.format("$1$$2$", [getValueByType(complicationType, width), unit]);
    }

    hidden function getUnitByType(complicationType) as String {
        var unit = "";
        if(complicationType == 11) { // Calories / day
            unit = Application.loadResource(Rez.Strings.UNIT_KCAL);
        } else if(complicationType == 12) { // Altitude (m)
            unit = Application.loadResource(Rez.Strings.UNIT_M);
        } else if(complicationType == 15) { // Altitude (ft)
            unit = Application.loadResource(Rez.Strings.UNIT_FT);
        } else if(complicationType == 17) { // Steps / day
            unit = Application.loadResource(Rez.Strings.UNIT_STEPS);
        } else if(complicationType == 19) { // Wheelchair pushes
            unit = Application.loadResource(Rez.Strings.UNIT_PUSHES);
        } else if(complicationType == 29) { // Active calories / day
            unit = Application.loadResource(Rez.Strings.UNIT_KCAL);
        } else if(complicationType == 58) { // Active/Total calories / day
            unit = Application.loadResource(Rez.Strings.UNIT_KCAL);
        }
        return unit;
    }

    hidden function getValueByType(complicationType as Number, width as Number) as String {
        var val = "";
        var numberFormat = "%d";

        if(complicationType == -2) { // Hidden
            return "";
        } else if(complicationType == -1) { // Date
            val = formatDate();
        } else if(complicationType == 0) { // Active min / week
            if(ActivityMonitor.getInfo() has :activeMinutesWeek) {
                if(ActivityMonitor.getInfo().activeMinutesWeek != null) {
                    val = ActivityMonitor.getInfo().activeMinutesWeek.total.format(numberFormat);
                }
            }
        } else if(complicationType == 1) { // Active min / day
            if(ActivityMonitor.getInfo() has :activeMinutesDay) {
                if(ActivityMonitor.getInfo().activeMinutesDay != null) {
                    val = ActivityMonitor.getInfo().activeMinutesDay.total.format(numberFormat);
                }
            }
        } else if(complicationType == 2) { // distance (km) / day
            if(ActivityMonitor.getInfo() has :distance) {
                if(ActivityMonitor.getInfo().distance != null) {
                    var distance_km = ActivityMonitor.getInfo().distance / 100000.0;
                    val = formatDistanceByWidth(distance_km, width);
                }
            }
        } else if(complicationType == 3) { // distance (miles) / day
            if(ActivityMonitor.getInfo() has :distance) {
                if(ActivityMonitor.getInfo().distance != null) {
                    var distance_miles = ActivityMonitor.getInfo().distance / 160900.0;
                    val = formatDistanceByWidth(distance_miles, width);
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
            if (hasComplications) {
                try {
                    var complication = Complications.getComplication(new Id(Complications.COMPLICATION_TYPE_RECOVERY_TIME));
                    if (complication != null && complication.value != null) {
                        var recovery_h = complication.value / 60.0;
                        if(recovery_h < 10 and recovery_h != 0) { val = recovery_h.format("%.1f"); } else { val = recovery_h.format(numberFormat); }
                    }
                } catch(e) {}
            } else {
                if(ActivityMonitor.getInfo() has :timeToRecovery) {
                    if(ActivityMonitor.getInfo().timeToRecovery != null) {
                        val = ActivityMonitor.getInfo().timeToRecovery.format(numberFormat);
                    }
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
                var resp_rate = ActivityMonitor.getInfo().respirationRate;
                if(resp_rate != null) {
                    val = resp_rate.format(numberFormat);
                }
            }
        } else if(complicationType == 10) {
            // Try to retrieve live HR from Activity::Info
            var activity_info = Activity.getActivityInfo();
            var sample = activity_info.currentHeartRate;
            if(sample != null) {
                val = sample.format("%01d");
            } else if (ActivityMonitor has :getHeartRateHistory) {
                // Falling back to historical HR from ActivityMonitor
                var hist = ActivityMonitor.getHeartRateHistory(1, /* newestFirst */ true).next();
                if ((hist != null) && (hist.heartRate != ActivityMonitor.INVALID_HR_SAMPLE)) {
                    val = hist.heartRate.format("%01d");
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
                var elv_iterator = Toybox.SensorHistory.getElevationHistory({:period => 1});
                var elv = elv_iterator.next();
                if(elv != null and elv.data != null) {
                    val = elv.data.format(numberFormat);
                }
            }
        } else if(complicationType == 13) { // Stress
            if(dataStress != null) {
                val = dataStress.format(numberFormat);
            }
        } else if(complicationType == 14) { // Body battery
            if(dataBbatt != null) {
                val = dataBbatt.format(numberFormat);
            }
        } else if(complicationType == 15) { // Altitude (ft)
            if ((Toybox has :SensorHistory) and (Toybox.SensorHistory has :getElevationHistory)) {
                var elv_iterator = Toybox.SensorHistory.getElevationHistory({:period => 1});
                var elv = elv_iterator.next();
                if(elv != null and elv.data != null) {
                    val = (elv.data * 3.28084).format(numberFormat);
                }
            }
        } else if(complicationType == 16) { // Alt TZ 1
            val = secondaryTimezone(propTzOffset1, width);
        } else if(complicationType == 17) { // Steps / day
            if(ActivityMonitor.getInfo().steps != null) {
                if(width >= 5) {
                    val = ActivityMonitor.getInfo().steps.format(numberFormat);
                } else {
                    var steps_k = ActivityMonitor.getInfo().steps / 1000.0;
                    if(steps_k < 10 and width == 4) {
                        val = Lang.format("$1$K", [steps_k.format("%.1f")]);
                    } else {
                        val = Lang.format("$1$K", [steps_k.format("%d")]);
                    }
                }
                
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
            val = getWeatherCondition(true);
        } else if(complicationType == 21) { // Weekly run distance (km)
            val = getWeeklyDistanceFromComplication(Complications.COMPLICATION_TYPE_WEEKLY_RUN_DISTANCE, 0.001, width);
        } else if(complicationType == 22) { // Weekly run distance (miles)
            val = getWeeklyDistanceFromComplication(Complications.COMPLICATION_TYPE_WEEKLY_RUN_DISTANCE, 0.000621371, width);
        } else if(complicationType == 23) { // Weekly bike distance (km)
            val = getWeeklyDistanceFromComplication(Complications.COMPLICATION_TYPE_WEEKLY_BIKE_DISTANCE, 0.001, width);
        } else if(complicationType == 24) { // Weekly bike distance (miles)
            val = getWeeklyDistanceFromComplication(Complications.COMPLICATION_TYPE_WEEKLY_BIKE_DISTANCE, 0.000621371, width);
        } else if(complicationType == 25) { // Training status
            if (hasComplications) {
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
                val = formatPressure(info.rawAmbientPressure / 100.0, width);
            }
        } else if(complicationType == 27) { // Weight kg
            var profile = UserProfile.getProfile();
            if(profile has :weight) {
                if(profile.weight != null) {
                    var weight_kg = profile.weight / 1000.0;
                    if (width == 3) {
                        val = weight_kg.format(numberFormat);
                    } else {
                        val = weight_kg.format("%.1f");
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
            var rest_calories = getRestCalories();
            // Get total calories and subtract rest calories
            if (ActivityMonitor.getInfo() has :calories && ActivityMonitor.getInfo().calories != null && rest_calories > 0) {
                var active_calories = ActivityMonitor.getInfo().calories - rest_calories;
                if (active_calories > 0) {
                    val = active_calories.format(numberFormat);
                }
            }
        } else if(complicationType == 30) { // Sea level pressure (hPA)
            var info = Activity.getActivityInfo();
            if (info has :meanSeaLevelPressure && info.meanSeaLevelPressure != null) {
                val = formatPressure(info.meanSeaLevelPressure / 100.0, width);
            }
        } else if(complicationType == 31) { // Week number
            var today = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
            var week_number = isoWeekNumber(today.year, today.month, today.day);
            val = week_number.format(numberFormat);
        } else if(complicationType == 32) { // Weekly distance (km)
            var weekly_distance = getWeeklyDistance() / 100000.0;  // Convert to km
            val = formatDistanceByWidth(weekly_distance, width);
        } else if(complicationType == 33) { // Weekly distance (miles)
            var weekly_distance = getWeeklyDistance() * 0.00000621371;  // Convert to miles
            val = formatDistanceByWidth(weekly_distance, width);
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
            var notif_count = System.getDeviceSettings().notificationCount;
            if(notif_count != null) {
                val = notif_count.format(numberFormat);
            }
        } else if(complicationType == 37) { // Solar intensity
            if(System.getSystemStats() has :solarIntensity and System.getSystemStats().solarIntensity != null) {
                val = System.getSystemStats().solarIntensity.format(numberFormat);
            }
        } else if(complicationType == 38) { // Sensor temperature
            if ((Toybox has :SensorHistory) and (Toybox.SensorHistory has :getTemperatureHistory)) {
                var tempIterator = Toybox.SensorHistory.getTemperatureHistory({:period => 1});
                var temp = tempIterator.next();
                if(temp != null and temp.data != null) {
                    var tempUnit = getTempUnit();
                    val = Lang.format("$1$$2$", [formatTemperature(temp.data, tempUnit).format(numberFormat), tempUnit]);
                }
            }
        } else if(complicationType == 39) { // Sunrise
            var now = Time.now();
            if(weatherCondition != null) {
                var loc = weatherCondition.observationLocationPosition;
                if(loc != null) {
                    var s = Weather.getSunrise(loc, now);
                    if(s != null) {
                        var sunrise = Time.Gregorian.info(s, Time.FORMAT_SHORT);
                        var sunriseHour = formatHour(sunrise.hour);
                        if(width < 5) {
                            val = Lang.format("$1$$2$", [sunriseHour.format("%02d"), sunrise.min.format("%02d")]);
                        } else {
                            val = Lang.format("$1$:$2$", [sunriseHour.format("%02d"), sunrise.min.format("%02d")]);
                        }
                    } else {
                        val = Application.loadResource(Rez.Strings.LABEL_NA);
                    }
                }
            }
        } else if(complicationType == 40) { // Sunset
            var now = Time.now();
            if(weatherCondition != null) {
                var loc = weatherCondition.observationLocationPosition;
                if(loc != null) {
                    var s = Weather.getSunset(loc, now);
                    if(s != null) {
                        var sunset = Time.Gregorian.info(s, Time.FORMAT_SHORT);
                        var sunsetHour = formatHour(sunset.hour);
                        if(width < 5) {
                            val = Lang.format("$1$$2$", [sunsetHour.format("%02d"), sunset.min.format("%02d")]);
                        } else {
                            val = Lang.format("$1$:$2$", [sunsetHour.format("%02d"), sunset.min.format("%02d")]);
                        }
                    } else {
                        val = Application.loadResource(Rez.Strings.LABEL_NA);
                    }
                }
            }
        } else if(complicationType == 41) { // Alt TZ 2
            val = secondaryTimezone(propTzOffset2, width);
        } else if(complicationType == 42) { // Alarms
            val = System.getDeviceSettings().alarmCount.format(numberFormat);
        } else if(complicationType == 43) { // High temp
            if(weatherCondition != null and weatherCondition.highTemperature != null) {
                var tempVal = weatherCondition.highTemperature;
                var tempUnit = getTempUnit();
                var temp = formatTemperature(tempVal, tempUnit).format("%01d");
                val = Lang.format("$1$$2$", [temp, tempUnit]);
            }
        } else if(complicationType == 44) { // Low temp
            if(weatherCondition != null and weatherCondition.lowTemperature != null) {
                var tempVal = weatherCondition.lowTemperature;
                var tempUnit = getTempUnit();
                var temp = formatTemperature(tempVal, tempUnit).format("%01d");
                val = Lang.format("$1$$2$", [temp, tempUnit]);
            }
        } else if(complicationType == 45) { // Temperature, Wind, Feels like
            var temp = getTemperature();
            var wind = getWind();
            var feelsLike = getFeelsLike();
            val = join([temp, wind, feelsLike]);
        } else if(complicationType == 46) { // Temperature, Wind
            var temp = getTemperature();
            var wind = getWind();
            val = join([temp, wind]);
        } else if(complicationType == 47) { // Temperature, Wind, Humidity
            var temp = getTemperature();
            var wind = getWind();
            var humidity = getHumidity();
            val = join([temp, wind, humidity]);
        } else if(complicationType == 48) { // Temperature, Wind, High/Low
            var temp = getTemperature();
            var wind = getWind();
            var highlow = getHighLow();
            val = join([temp, wind, highlow]);
        } else if(complicationType == 49) { // Temperature, Wind, Precipitation chance
            var temp = getTemperature();
            var wind = getWind();
            var precip = getPrecip();
            val = join([temp, wind, precip]);
        } else if(complicationType == 50) { // Weather condition without precipitation
            val = getWeatherCondition(false);
        } else if(complicationType == 51) { // Temperature, Humidity, High/Low
            var temp = getTemperature();
            var humidity = getHumidity();
            var highlow = getHighLow();
            val = join([temp, humidity, highlow]);
        } else if(complicationType == 52) { // Temperature, Percipitation chance, High/Low
            var temp = getTemperature();
            var precip = getPrecip();
            var highlow = getHighLow();
            val = join([temp, precip, highlow]);
        } else if(complicationType == 53) { // Temperature
            val = getTemperature();
        } else if(complicationType == 54) { // Precipitation chance
            val = getPrecip();
            if(width == 3 and val.equals("100%")) { val = "100"; }
        } else if(complicationType == 55) { // Next Sun Event
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
        } else if(complicationType == 56) { // Millitary Date Time Group
            val = getDateTimeGroup();
        } else if(complicationType == 57) { // Time of the next Calendar Event
            if (hasComplications) {
                try {
                    var complication = Complications.getComplication(new Id(Complications.COMPLICATION_TYPE_CALENDAR_EVENTS));
                    var colon_index = null;
                    if (complication != null && complication.value != null) {
                        val = complication.value;
                        colon_index = val.find(":");
                        if (colon_index != null && colon_index < 2) {
                            val = "0" + val;
                        }
                    } else {
                        val = "--:--";
                    }
                    if (width < 5 and colon_index != null) {
                        val = val.substring(0, 2) + val.substring(3, 5);
                    }
                } catch(e) {
                    // Complication not found
                }
            }
        } else if(complicationType == 58) { // Active / Total calories
            var rest_calories = getRestCalories();
            var total_calories = 0;
            // Get total calories and subtract rest calories
            if (ActivityMonitor.getInfo() has :calories && ActivityMonitor.getInfo().calories != null) {
                total_calories = ActivityMonitor.getInfo().calories;
            }
            var active_calories = total_calories - rest_calories;
            active_calories = (active_calories > 0) ? active_calories : 0; // Ensure active calories is not negative
            val = active_calories.format(numberFormat) + "/" + total_calories.format(numberFormat);
        } else if(complicationType == 59) { // PulseOx
            if (hasComplications) {
                try {
                    var complication = Complications.getComplication(new Id(Complications.COMPLICATION_TYPE_PULSE_OX));
                    if (complication != null && complication.value != null) {
                        val = complication.value.format(numberFormat);
                    }
                } catch(e) {
                    // Complication not found
                }
            } else {
                if ((Toybox has :SensorHistory) and (Toybox.SensorHistory has :getOxygenSaturationHistory)) {
                    var it = Toybox.SensorHistory.getOxygenSaturationHistory({:period => 1});
                    var ox = it.next();
                    if(ox != null and ox.data != null) {
                        val = ox.data.format("%d");
                    }
                }
            }
        } else if(complicationType == 60) { // Location Long Lat dec deg
            var pos = Activity.getActivityInfo().currentLocation;
            if(pos != null) {
                val = Lang.format("$1$ $2$", [pos.toDegrees()[0], pos.toDegrees()[1]]);
            } else {
                val = Application.loadResource(Rez.Strings.LABEL_POS_NA);
            }
            
        } else if(complicationType == 61) { // Location Millitary format
            var pos = Activity.getActivityInfo().currentLocation;
            if(pos != null) {
                val = pos.toGeoString(Position.GEO_MGRS);
            } else {
                val = Application.loadResource(Rez.Strings.LABEL_POS_NA);
            }
            
        } else if(complicationType == 62) { // Location Accuracy
            var acc = Activity.getActivityInfo().currentLocationAccuracy;
            if(acc != null) {
                if(width < 4) {
                    val = (acc as Number).format("%d");
                } else {
                    val = ["N/A", "LAST", "POOR", "USBL", "GOOD"][acc];
                }
            }
        } else if(complicationType == 63) { // Temperature, Wind, Humidity, Precipitation chance
            var temp = getTemperature();
            var wind = getWind();
            var humidity = getHumidity();
            var precip = getPrecip();
            val = join([temp, wind, humidity, precip]);
        } else if(complicationType == 64) { // UV Index
            val = getUVIndex();
        } else if(complicationType == 65) { // Temperature, UV Index, High/Low
            var temp = getTemperature();
            var uv = getUVIndex();
            var highlow = getHighLow();
            val = join([temp, uv, highlow]);
        } else if(complicationType == 66) { // Humidity
            val = getHumidity();
        } else if(complicationType == 67) { // Temperature, Feels like, High/Low
            var temp = getTemperature();
            var fl = getFeelsLike();
            var highlow = getHighLow();
            val = join([temp, fl, highlow]);
        }

        return val;
    }

    hidden function getDataArrayByType(dataSource as Number) as Array<Number> {
        var ret = [];
        var iterator = null;
        var max = null;
        var twoHours = new Time.Duration(7200);
        
        if(dataSource == 0) {
            iterator = Toybox.SensorHistory.getBodyBatteryHistory({:period => twoHours, :order => Toybox.SensorHistory.ORDER_OLDEST_FIRST});
            max = 100;
        } else if(dataSource == 1) {
            iterator = Toybox.SensorHistory.getElevationHistory({:period => twoHours, :order => Toybox.SensorHistory.ORDER_OLDEST_FIRST});
        } else if(dataSource == 2) {
            iterator = Toybox.SensorHistory.getHeartRateHistory({:period => twoHours, :order => Toybox.SensorHistory.ORDER_OLDEST_FIRST});
        } else if(dataSource == 3) {
            iterator = Toybox.SensorHistory.getOxygenSaturationHistory({:period => twoHours, :order => Toybox.SensorHistory.ORDER_OLDEST_FIRST});
            max = 100;
        } else if(dataSource == 4) {
            iterator = Toybox.SensorHistory.getPressureHistory({:period => twoHours, :order => Toybox.SensorHistory.ORDER_OLDEST_FIRST});
        } else if(dataSource == 5 or dataSource == 7) {
            iterator = Toybox.SensorHistory.getStressHistory({:period => twoHours, :order => Toybox.SensorHistory.ORDER_OLDEST_FIRST});
            max = 100;
        } else if(dataSource == 6) {
            iterator = Toybox.SensorHistory.getTemperatureHistory({:period => twoHours, :order => Toybox.SensorHistory.ORDER_OLDEST_FIRST});
        }

        if(iterator == null) { return ret; }
        if(max == null) {
            max = iterator.getMax();
        }
        var min = iterator.getMin();
        if(min == null or max == null) {
            return ret;
        }
        var diff = max - (min * 0.9);
        var sample = iterator.next();
        var count = 0;
        while(sample != null) {
            if(dataSource == 2) {
                if(sample.data != null and sample.data != 0 and sample.data < 255) {
                    ret.add(Math.round(sample.data.toFloat() / max * 100).toNumber());
                }
            } else if(dataSource == 1 or dataSource == 4) {
                if(sample.data != null) {
                    ret.add(Math.round((sample.data.toFloat() - Math.round(min * 0.9)) / diff * 100).toNumber());
                }
            } else if(dataSource == 3) {
                if(sample.data != null) {
                    ret.add(Math.round((sample.data.toFloat() - 50.0) / 50.0 * 100).toNumber());
                }
            } else {
                if(sample.data != null) {
                    ret.add(Math.round(sample.data.toFloat() / max * 100).toNumber());
                }
            }
            
            sample = iterator.next();
            count++;
        }

        if(ret.size() > histogramTargetWidth) {
            var reduced_ret = [];
            var step = (ret.size() as Float) / histogramTargetWidth.toFloat();
            var closest_index = 0;
            for(var i=0; i<histogramTargetWidth; i++) {
                closest_index = Math.round(i * step).toNumber();
                if (closest_index >= ret.size()) {
                    closest_index = ret.size() - 1;
                }
                reduced_ret.add(ret[closest_index]);
            }
            return reduced_ret;
        }
        return ret;
    } 

    hidden function getLabelByType(complicationType as Number, labelSize as Number) as String {
        // labelSize 1 = short, 2 = mid, 3 = long

        if(complicationType == 16) {
            return Lang.format("$1$:", [propTzName1.toUpper()]);
        }

        if(complicationType == 41) {
            return Lang.format("$1$:", [propTzName2.toUpper()]);
        }
        
        switch(complicationType) {
            case 0: return formatLabel(Rez.Strings.LABEL_WMIN_1, Rez.Strings.LABEL_WMIN_2, Rez.Strings.LABEL_WMIN_3, labelSize);
            case 1: return formatLabel(Rez.Strings.LABEL_DMIN_1, Rez.Strings.LABEL_DMIN_2, Rez.Strings.LABEL_DMIN_3, labelSize);
            case 2: return formatLabel(Rez.Strings.LABEL_DKM_1, Rez.Strings.LABEL_DKM_2, Rez.Strings.LABEL_DKM_2, labelSize);
            case 3: return formatLabel(Rez.Strings.LABEL_DMI_1, Rez.Strings.LABEL_DMI_2, Rez.Strings.LABEL_DMI_3, labelSize);
            case 4: return Application.loadResource(Rez.Strings.LABEL_FLOORS);
            case 5: return formatLabel(Rez.Strings.LABEL_CLIMB_1, Rez.Strings.LABEL_CLIMB_2, Rez.Strings.LABEL_CLIMB_2, labelSize);
            case 6: return formatLabel(Rez.Strings.LABEL_RECOV_1, Rez.Strings.LABEL_RECOV_2, Rez.Strings.LABEL_RECOV_3, labelSize);
            case 7: return formatLabel(Rez.Strings.LABEL_VO2_1, Rez.Strings.LABEL_VO2_2, Rez.Strings.LABEL_VO2RUN_3, labelSize);
            case 8: return formatLabel(Rez.Strings.LABEL_VO2_1, Rez.Strings.LABEL_VO2_2, Rez.Strings.LABEL_VO2BIKE_3, labelSize);
            case 9: return formatLabel(Rez.Strings.LABEL_RESP_1, Rez.Strings.LABEL_RESP_2, Rez.Strings.LABEL_RESP_3, labelSize);
            case 10: return Application.loadResource(Rez.Strings.LABEL_HR);
            case 11: return formatLabel(Rez.Strings.LABEL_CAL_1, Rez.Strings.LABEL_CAL_2, Rez.Strings.LABEL_CAL_3, labelSize);
            case 12: return formatLabel(Rez.Strings.LABEL_ALT_1, Rez.Strings.LABEL_ALT_2, Rez.Strings.LABEL_ALTM_3, labelSize);
            case 13: return Application.loadResource(Rez.Strings.LABEL_STRESS);
            case 14: return formatLabel(Rez.Strings.LABEL_BBAT_1, Rez.Strings.LABEL_BBAT_2, Rez.Strings.LABEL_BBAT_3, labelSize);
            case 15: return formatLabel(Rez.Strings.LABEL_ALT_1, Rez.Strings.LABEL_ALT_2, Rez.Strings.LABEL_ALTFT_3, labelSize);
            case 17: return Application.loadResource(Rez.Strings.LABEL_STEPS);
            case 18: return formatLabel(Rez.Strings.LABEL_DIST_1, Rez.Strings.LABEL_DIST_2, Rez.Strings.LABEL_DIST_3, labelSize);
            case 19: return Application.loadResource(Rez.Strings.LABEL_PUSHES);
            case 20: return "";
            case 21: return formatLabel(Rez.Strings.LABEL_WKM_1, Rez.Strings.LABEL_WRUNM_2, Rez.Strings.LABEL_WRUNM_3, labelSize);
            case 22: return formatLabel(Rez.Strings.LABEL_WMI_1, Rez.Strings.LABEL_WRUNMI_2, Rez.Strings.LABEL_WRUNMI_3, labelSize);
            case 23: return formatLabel(Rez.Strings.LABEL_WKM_1, Rez.Strings.LABEL_WBIKEKM_2, Rez.Strings.LABEL_WBIKEKM_3, labelSize);
            case 24: return formatLabel(Rez.Strings.LABEL_WMI_1, Rez.Strings.LABEL_WBIKEMI_2, Rez.Strings.LABEL_WBIKEMI_3, labelSize);
            case 25: return Application.loadResource(Rez.Strings.LABEL_TRAINING);
            case 26: return Application.loadResource(Rez.Strings.LABEL_PRESSURE);
            case 27: return formatLabel(Rez.Strings.LABEL_KG_1, Rez.Strings.LABEL_WEIGHT_2, Rez.Strings.LABEL_KG_3, labelSize);
            case 28: return formatLabel(Rez.Strings.LABEL_LBS_1, Rez.Strings.LABEL_WEIGHT_2, Rez.Strings.LABEL_LBS_3, labelSize);
            case 29: return formatLabel(Rez.Strings.LABEL_ACAL_1, Rez.Strings.LABEL_ACAL_2, Rez.Strings.LABEL_ACAL_3, labelSize);
            case 30: return Application.loadResource(Rez.Strings.LABEL_PRESSURE);
            case 31: return Application.loadResource(Rez.Strings.LABEL_WEEK);
            case 32: return formatLabel(Rez.Strings.LABEL_WKM_1, Rez.Strings.LABEL_WDISTKM_2, Rez.Strings.LABEL_WDISTKM_3, labelSize);
            case 33: return formatLabel(Rez.Strings.LABEL_WMI_1, Rez.Strings.LABEL_WDISTMI_2, Rez.Strings.LABEL_WDISTMI_3, labelSize);
            case 34: return formatLabel(Rez.Strings.LABEL_BATT_1, Rez.Strings.LABEL_BATT_2, Rez.Strings.LABEL_BATT_3, labelSize);
            case 35: return formatLabel(Rez.Strings.LABEL_BATTD_1, Rez.Strings.LABEL_BATTD_2, Rez.Strings.LABEL_BATTD_3, labelSize);
            case 36: return formatLabel(Rez.Strings.LABEL_NOTIFS_1, Rez.Strings.LABEL_NOTIFS_1, Rez.Strings.LABEL_NOTIFS_3, labelSize);
            case 37: return formatLabel(Rez.Strings.LABEL_SUN_1, Rez.Strings.LABEL_SUNINT_2, Rez.Strings.LABEL_SUNINT_3, labelSize);
            case 38: return formatLabel(Rez.Strings.LABEL_TEMP_1, Rez.Strings.LABEL_TEMP_1, Rez.Strings.LABEL_STEMP_3, labelSize);
            case 39: return formatLabel(Rez.Strings.LABEL_DAWN_1, Rez.Strings.LABEL_DAWN_2, Rez.Strings.LABEL_DAWN_2, labelSize);
            case 40: return formatLabel(Rez.Strings.LABEL_DUSK_1, Rez.Strings.LABEL_DUSK_2, Rez.Strings.LABEL_DUSK_2, labelSize);
            case 42: return formatLabel(Rez.Strings.LABEL_ALARM_1, Rez.Strings.LABEL_ALARM_2, Rez.Strings.LABEL_ALARM_2, labelSize);
            case 43: return formatLabel(Rez.Strings.LABEL_HIGH_1, Rez.Strings.LABEL_HIGH_2, Rez.Strings.LABEL_HIGH_2, labelSize);
            case 44: return formatLabel(Rez.Strings.LABEL_LOW_1, Rez.Strings.LABEL_LOW_2, Rez.Strings.LABEL_LOW_2, labelSize);
            case 53: return formatLabel(Rez.Strings.LABEL_TEMP_1, Rez.Strings.LABEL_TEMP_1, Rez.Strings.LABEL_TEMP_3, labelSize);
            case 54: return formatLabel(Rez.Strings.LABEL_PRECIP_1, Rez.Strings.LABEL_PRECIP_1, Rez.Strings.LABEL_PRECIP_3, labelSize);
            case 55: return formatLabel(Rez.Strings.LABEL_NEXTSUN_1, Rez.Strings.LABEL_NEXTSUN_2, Rez.Strings.LABEL_NEXTSUN_3, labelSize);
            case 57: return formatLabel(Rez.Strings.LABEL_NEXTCAL_1, Rez.Strings.LABEL_NEXTCAL_2, Rez.Strings.LABEL_NEXTCAL_3, labelSize);
            case 59: return formatLabel(Rez.Strings.LABEL_OX_1, Rez.Strings.LABEL_OX_2, Rez.Strings.LABEL_OX_2, labelSize);
            case 62: return formatLabel(Rez.Strings.LABEL_ACC_1, Rez.Strings.LABEL_ACC_2, Rez.Strings.LABEL_ACC_3, labelSize);
            case 64: return formatLabel(Rez.Strings.LABEL_UV_1, Rez.Strings.LABEL_UV_2, Rez.Strings.LABEL_UV_2, labelSize);
            case 66: return formatLabel(Rez.Strings.LABEL_HUM_1, Rez.Strings.LABEL_HUM_2, Rez.Strings.LABEL_HUM_2, labelSize);
        }
        
        return "";
    }

    hidden function formatLabel(short as ResourceId, mid as ResourceId, long as ResourceId, size as Number) as String {
        if(size == 1) { return Application.loadResource(short) + ":"; }
        if(size == 2) { return Application.loadResource(mid) + ":"; }
        return Application.loadResource(long) + ":";
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

    hidden function join(array as Array<String>) as String {
        var ret = "";
        for(var i=0; i<array.size(); i++) {
            if(array[i].equals("")) {
                continue;
            }
            if(ret.equals("")) {
                ret = array[i];
            } else {
                ret = ret + ", " + array[i];
            }
        }
        return ret;
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

    hidden function formatPressure(pressureHpa as Float, width as Number) as String {
        var val = "";
        var nf = "%d";

        if (propPressureUnit == 0) { // hPA
            val = pressureHpa.format(nf);
        } else if (propPressureUnit == 1) { // mmHG
            val = (pressureHpa * 0.750062).format(nf);
        } else if (propPressureUnit == 2) { // inHG
            if(width == 5) {
                val = (pressureHpa * 0.02953).format("%.2f");
            } else {
                val = (pressureHpa * 0.02953).format("%.1f");
            }
        }

        return val;
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

    hidden function getWeatherCondition(includePrecipitation as Boolean) as String {
        // Early return if no weather data
        if (weatherCondition == null || weatherCondition.condition == null) {
            return "";
        }

        var perp = "";
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

        var ret = null;
        switch (weatherCondition.condition) {
            case 0: ret = Rez.Strings.WEATHER_0; break;
            case 1: ret = Rez.Strings.WEATHER_1; break;
            case 2: ret = Rez.Strings.WEATHER_2; break;
            case 3: ret = Rez.Strings.WEATHER_3; break;
            case 4: ret = Rez.Strings.WEATHER_4; break;
            case 5: ret = Rez.Strings.WEATHER_5; break;
            case 6: ret = Rez.Strings.WEATHER_6; break;
            case 7: ret = Rez.Strings.WEATHER_7; break;
            case 8: ret = Rez.Strings.WEATHER_8; break;
            case 9: ret = Rez.Strings.WEATHER_9; break;
            case 10: ret = Rez.Strings.WEATHER_10; break;
            case 11: ret = Rez.Strings.WEATHER_11; break;
            case 12: ret = Rez.Strings.WEATHER_12; break;
            case 13: ret = Rez.Strings.WEATHER_13; break;
            case 14: ret = Rez.Strings.WEATHER_14; break;
            case 15: ret = Rez.Strings.WEATHER_15; break;
            case 16: ret = Rez.Strings.WEATHER_16; break;
            case 17: ret = Rez.Strings.WEATHER_17; break;
            case 18: ret = Rez.Strings.WEATHER_18; break;
            case 19: ret = Rez.Strings.WEATHER_19; break;
            case 20: ret = Rez.Strings.WEATHER_20; break;
            case 21: ret = Rez.Strings.WEATHER_21; break;
            case 22: ret = Rez.Strings.WEATHER_22; break;
            case 23: ret = Rez.Strings.WEATHER_23; break;
            case 24: ret = Rez.Strings.WEATHER_24; break;
            case 25: ret = Rez.Strings.WEATHER_25; break;
            case 26: ret = Rez.Strings.WEATHER_26; break;
            case 27: ret = Rez.Strings.WEATHER_27; break;
            case 28: ret = Rez.Strings.WEATHER_28; break;
            case 29: ret = Rez.Strings.WEATHER_29; break;
            case 30: ret = Rez.Strings.WEATHER_30; break;
            case 31: ret = Rez.Strings.WEATHER_31; break;
            case 32: ret = Rez.Strings.WEATHER_32; break;
            case 33: ret = Rez.Strings.WEATHER_33; break;
            case 34: ret = Rez.Strings.WEATHER_34; break;
            case 35: ret = Rez.Strings.WEATHER_35; break;
            case 36: ret = Rez.Strings.WEATHER_36; break;
            case 37: ret = Rez.Strings.WEATHER_37; break;
            case 38: ret = Rez.Strings.WEATHER_38; break;
            case 39: ret = Rez.Strings.WEATHER_39; break;
            case 40: ret = Rez.Strings.WEATHER_40; break;
            case 41: ret = Rez.Strings.WEATHER_41; break;
            case 42: ret = Rez.Strings.WEATHER_42; break;
            case 43: ret = Rez.Strings.WEATHER_43; break;
            case 44: ret = Rez.Strings.WEATHER_44; break;
            case 45: ret = Rez.Strings.WEATHER_45; break;
            case 46: ret = Rez.Strings.WEATHER_46; break;
            case 47: ret = Rez.Strings.WEATHER_47; break;
            case 48: ret = Rez.Strings.WEATHER_48; break;
            case 49: ret = Rez.Strings.WEATHER_49; break;
            case 50: ret = Rez.Strings.WEATHER_50; break;
            case 51: ret = Rez.Strings.WEATHER_51; break;
            case 52: ret = Rez.Strings.WEATHER_52; break;
            default: ret = Rez.Strings.WEATHER_53;
        }

        return Application.loadResource(ret) + perp;
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

    hidden function getTempUnit() as String {
        var temp_unit_setting = System.getDeviceSettings().temperatureUnits;
        if((temp_unit_setting == System.UNIT_METRIC and propTempUnit == 0) or propTempUnit == 1) {
            return "C";
        } else {
            return "F";
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
            var fllabel = Application.loadResource(Rez.Strings.LABEL_FL);
            fl = Lang.format("$1$:$2$$3$", [fllabel, fltemp.format("%d"), tempUnit]);
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

    hidden function getUVIndex() as String {
        var ret = "";
        if(weatherCondition != null and weatherCondition has :uvIndex and weatherCondition.uvIndex != null) {
            ret = weatherCondition.uvIndex.format("%d");
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
                ret = Lang.format("$1$$2$/$3$$2$", [high.format("%d"), tempUnit, low.format("%d")]);
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

    hidden function getWeeklyDistanceFromComplication(complicationType as Complications.Type, conversionFactor as Float, width as Number) as String {
        var val = "";
        if (hasComplications) {
            try {
                var complication = Complications.getComplication(new Id(complicationType));
                if (complication != null && complication.value != null) {
                    var distance = complication.value * conversionFactor;
                    val = formatDistanceByWidth(distance, width);
                }
            } catch(e) {
                // Complication not found
            }
        }
        return val;
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

    hidden function dayName(day_of_week as Number) as String {
        return weekNames[day_of_week - 1];
    }

    hidden function monthName(month as Number) as String {
        return monthNames[month - 1];
    }

    hidden function isoWeekNumber(year as Number, month as Number, day as Number) as Number {
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
        } else {
            ret = week_of_year;
        }
        if(propWeekOffset != 0) {
            ret = ret + propWeekOffset;
        }
        return ret;
    }

    hidden function julianDay(year as Number, month as Number, day as Number) as Number {
        var a = (14 - month) / 12;
        var y = (year + 4800 - a);
        var m = (month + 12 * a - 3);
        return day + ((153 * m + 2) / 5) + (365 * y) + (y / 4) - (y / 100) + (y / 400) - 32045;
    }

    hidden function isLeapYear(year as Number) as Boolean {
        if (year % 4 != 0) {
            return false;
           } else if (year % 100 != 0) {
            return true;
        } else if (year % 400 == 0) {
            return true;
        }
        return false;
    }

}

class Segment34Delegate extends WatchUi.WatchFaceDelegate {
    var screenW = null;
    var screenH = null;
    var view as Segment34View;

    public function initialize(v as Segment34View) {
        WatchFaceDelegate.initialize();
        screenW = System.getDeviceSettings().screenWidth;
        screenH = System.getDeviceSettings().screenHeight;
        view = v;
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

        if(cID == -1) {
            switch(view.nightModeOverride) {
                case 1:
                    view.nightModeOverride = 0;
                    view.infoMessage = "DAY THEME";
                    break;
                case 0:
                    view.nightModeOverride = -1;
                    view.infoMessage = "THEME AUTO";
                    break;
                default:
                    view.nightModeOverride = 1;
                    view.infoMessage = "NIGHT THEME";
            }
            view.onSettingsChanged();
        }

        if(cID != null and cID > 0) {
            try {
                Complications.exitTo(new Id(cID));
            } catch (e) {}
        }
    }

}

class StoredWeather {
    public var observationLocationPosition as Position.Location or Null;
    public var precipitationChance as Lang.Number or Null;
    public var temperature as Lang.Numeric or Null;
    public var windBearing as Lang.Number or Null;
    public var windSpeed as Lang.Float or Null;
    public var highTemperature as Lang.Numeric or Null;
    public var lowTemperature as Lang.Numeric or Null;
    public var feelsLikeTemperature as Lang.Float or Null;
    public var relativeHumidity as Lang.Number or Null;
    public var condition as Lang.Number or Null;
    public var uvIndex as Lang.Float or Null;
}