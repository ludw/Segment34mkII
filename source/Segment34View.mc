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

    hidden var visible as Boolean = true;
    hidden var screenHeight as Number;
    hidden var screenWidth as Number;
    (:initialized) hidden var clockHeight as Number;
    (:initialized) hidden var clockWidth as Number;
    (:initialized) hidden var labelHeight as Number;
    (:initialized) hidden var labelMargin as Number;
    (:initialized) hidden var tinyDataHeight as Number;
    (:initialized) hidden var smallDataHeight as Number;
    (:initialized) hidden var largeDataHeight as Number;
    (:initialized) hidden var largeDataWidth as Number;
    (:initialized) hidden var bottomDataWidth as Number;
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
    hidden var weekNames as Array<String>?;
    hidden var monthNames as Array<String>?;

    // Layout Caching
    hidden var fieldXCoords as Array<Number> = [0, 0, 0, 0];
    hidden var fieldY as Number = 0;
    hidden var bottomFiveY as Number = 0;

    hidden var drawGradient as BitmapResource?;
    hidden var drawAODPattern as BitmapResource?;
    
    public var infoMessage as String = "";
    public var nightModeOverride as Number = -1;
    hidden var themeColors as Array<Graphics.ColorType> = [];
    hidden var nightMode as Boolean?;
    (:WeatherCache) hidden var weatherCondition as CurrentConditions or StoredWeather or Null;
    (:NoWeatherCache) hidden var weatherCondition as CurrentConditions or Null;
    hidden var hrHistoryData as Array<Number>?;
    hidden var canBurnIn as Boolean = false;
    hidden var isSleeping as Boolean = false;
    hidden var lastUpdate as Number? = null;
    hidden var lastSlowUpdate as Number? = null;
    hidden var cachedValues as Dictionary = {};

    hidden var isWeatherRequired as Boolean = false;
    (:WeatherCache) hidden var lastHfTime as Number? = null;
    (:WeatherCache) hidden var lastCcHash as Number? = null;
    hidden var isLowMem as Boolean = false;

    hidden var doesPartialUpdate as Boolean = false;
    hidden var hasComplications as Boolean = false;

    // CGM Connect Widget complication IDs
    hidden var cgmComplicationId as Complications.Id? = null;
    hidden var cgmAgeComplicationId as Complications.Id? = null;
    
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
    hidden var propAodStyle as Number = 1;
    hidden var propAodFieldShows as Number = -1;
    hidden var propAodRightFieldShows as Number = -2;
    hidden var propDateFieldShows as Number = -1;
    hidden var propBottomFieldShows as Number = 17;
    hidden var propAodAlignment as Number = 0;
    hidden var propDateAlignment as Number = 0;
    hidden var propBottomFieldAlignment as Number = 2;
    hidden var propBottomFieldLabelAlignment as Number = 0;
    hidden var propLeftBarShows as Number = 1;
    hidden var propRightBarShows as Number = 2;
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
    hidden var propShowNotificationCount as Boolean = true;
    hidden var propTzOffset1 as Number = 0;
    hidden var propTzOffset2 as Number = 0;
    hidden var propTzName1 as String = "";
    hidden var propTzName2 as String = "";
    hidden var propWeekOffset as Number = 0;
    hidden var propLabelVisibility as Number = 0;
    hidden var propSmallFontVariant as Number = 0;
    hidden var propStressDynamicColor as Boolean = false;

    // Cached Labels
    hidden var strLabelTopLeft as String = "";
    hidden var strLabelTopRight as String = "";
    hidden var strLabelBottomLeft as String = "";
    hidden var strLabelBottomMiddle as String = "";
    hidden var strLabelBottomRight as String = "";
    hidden var strLabelBottomFourth as String = "";

    const battFull = "|||||||||||||||||||||||||||||||||||";
    const battEmpty = "{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{";

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

    (:Round240) const bottomFieldWidths = [3, 3, 3, 0];
    (:Round260) const bottomFieldWidths = [3, 4, 3, 0];
    (:Round280) const bottomFieldWidths = [4, 3, 4, 0];
    (:Round360) const bottomFieldWidths = [3, 4, 3, 0];
    (:Round390) const bottomFieldWidths = [4, 3, 4, 0];
    (:InstinctCrossover) const bottomFieldWidths = [4, 3, 4, 0];
    (:Round416) const bottomFieldWidths = [4, 4, 4, 0];
    (:Round454) const bottomFieldWidths = [4, 4, 4, 0];

    (:Round240) const barWidth = 3;
    (:Round260) const barWidth = 3;
    (:Round280) const barWidth = 3;
    (:Round360) const barWidth = 3;
    (:Round390) const barWidth = 4;
    (:InstinctCrossover) const barWidth = 4;
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
        
        calculateLayout();

        updateWeather();
    }

    hidden function updateActiveLabels() as Void {
        var fieldWidths = getFieldWidths();
        strLabelTopLeft = getLabelByType(propSunriseFieldShows, 1);
        strLabelTopRight = getLabelByType(propSunsetFieldShows, 1);
        strLabelBottomLeft = getLabelByType(propLeftValueShows, fieldWidths[0] - 1);
        strLabelBottomMiddle = getLabelByType(propMiddleValueShows, fieldWidths[1] - 1);
        strLabelBottomRight = getLabelByType(propRightValueShows, fieldWidths[2] - 1);
        strLabelBottomFourth = getLabelByType(propFourthValueShows, fieldWidths[3] - 1);
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
        largeDataWidth = 18;
        bottomDataWidth = 12;

        baseX = centerX;
        baseY = centerY - smallDataHeight + 4;
        marginY = Math.round(screenHeight / 35);
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
        largeDataWidth = 18;
        bottomDataWidth = 18;

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
        largeDataWidth = 18;
        bottomDataWidth = 18;

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
        largeDataWidth = 24;
        bottomDataWidth = 18;

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
        largeDataWidth = 24;
        bottomDataWidth = 24;

        baseX = centerX;
        baseY = centerY - smallDataHeight - 3;
        barBottomAdj = 2;
        bottomFiveAdj = 6;
        marginY = 10;
        histogramHeight = 25;
    }

    (:InstinctCrossover)
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
        clockWidth = 350;
        labelHeight = 10;
        labelMargin = 8;
        tinyDataHeight = 15;
        smallDataHeight = 20;
        largeDataHeight = 27;
        largeDataWidth = 24;
        bottomDataWidth = 24;

        baseX = centerX;
        baseY = centerY;  // Centered for analog hands
        barBottomAdj = 2;
        bottomFiveAdj = 10;
        marginY = 9;
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
        largeDataWidth = 24;
        bottomDataWidth = 24;

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
        largeDataWidth = 24;
        bottomDataWidth = 24;

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

    hidden function computeDisplayValues(now as Gregorian.Info) as Dictionary {
        var values = {};
        
        // From updateSlowData logic
        values[:dataClock] = getClockData(now);
        values[:dataMoon] = moonPhase(now);
        if(propTopPartShows == 2) {
            values[:dataGraph1] = getDataArrayByType(propHistogramData);
        } else {
            values[:dataGraph1] = null;
        }

        values[:dataLabelTopLeft] = strLabelTopLeft;
        values[:dataLabelTopRight] = strLabelTopRight;
        values[:dataLabelBottomLeft] = strLabelBottomLeft;
        values[:dataLabelBottomMiddle] = strLabelBottomMiddle;
        values[:dataLabelBottomRight] = strLabelBottomRight;
        values[:dataLabelBottomFourth] = strLabelBottomFourth;

        // From updateData logic
        var fieldWidths = getFieldWidths();
        values[:dataTopLeft] = getValueByType(propSunriseFieldShows, 5);
        values[:dataTopRight] = getValueByType(propSunsetFieldShows, 5);
        values[:dataAboveLine1] = getValueByTypeWithUnit(propWeatherLine1Shows, 10);
        values[:dataAboveLine2] = getValueByTypeWithUnit(propWeatherLine2Shows, 10);
        values[:dataBelow] = getValueByTypeWithUnit(propDateFieldShows, 10);
        values[:dataNotifications] = getNotificationsData();
        values[:dataBottomLeft] = getValueByType(propLeftValueShows, fieldWidths[0]);
        values[:dataBottomMiddle] = getValueByType(propMiddleValueShows, fieldWidths[1]);
        values[:dataBottomRight] = getValueByType(propRightValueShows, fieldWidths[2]);
        values[:dataBottomFourth] = getValueByType(propFourthValueShows, fieldWidths[3]);
        values[:dataBottom] = getValueByType(propBottomFieldShows, 5);
        values[:dataIcon1] = getIconState(propIcon1);
        values[:dataIcon2] = getIconState(propIcon2);
        values[:dataBattery] = getBattData();
        values[:dataAODLeft] = getValueByType(propAodFieldShows, 10);
        values[:dataAODRight] = getValueByType(propAodRightFieldShows, 5);
        values[:dataLeftBar] = getBarData(propLeftBarShows);
        values[:dataRightBar] = getBarData(propRightBarShows);

        if(!infoMessage.length() == 0) {
            values[:dataBelow] = infoMessage;
            infoMessage = ""; 
        }
        
        // updateSeconds logic
        if(isSleeping and (!propAlwaysShowSeconds or canBurnIn)) {
            values[:dataSeconds] = "";
        } else {
            values[:dataSeconds] = now.sec.format("%02d");
        }

        return values;
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
    }

    // Called when this View is brought to the foreground.
    // Restore the state of this View and prepare it to be shown.
    // This includes loading resources into memory.
    function onShow() as Void {
        visible = true;
        lastUpdate = null;
        lastSlowUpdate = null;
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        if(!visible) { return; }

        var now = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var unix_timestamp = Time.now().value();

        if(doesPartialUpdate) {
            dc.clearClip();
            doesPartialUpdate = false;
        }

        if(now.sec % 60 == 0 or lastSlowUpdate == null or unix_timestamp - lastSlowUpdate >= 60) {
            lastSlowUpdate = unix_timestamp;
            updateColorTheme();
            updateWeather();
        }

        if(lastUpdate == null or unix_timestamp - lastUpdate >= propUpdateFreq) {
            lastUpdate = unix_timestamp;
            cachedValues = computeDisplayValues(now);
        } else {
            // Only update time-sensitive values
            cachedValues[:dataClock] = getClockData(now);
            if(isSleeping and (!propAlwaysShowSeconds or canBurnIn)) {
                cachedValues[:dataSeconds] = "";
            } else {
                cachedValues[:dataSeconds] = now.sec.format("%02d");
            }
        }

        if(isSleeping and canBurnIn) {
            drawAOD(dc, now, cachedValues);
        } else {
            drawWatchface(dc, now, false, cachedValues);
        }
    }

    // Called when this View is removed from the screen.
    // Save the state of this View here.
    // This includes freeing resources from memory.
    function onHide() as Void {
        visible = false;
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

        var seconds = now.sec.format("%02d");
        
        dc.setClip(baseX + halfClockWidth - textSideAdj - clip_width, y1, clip_width, clip_height);
        dc.setColor(themeColors[bg], themeColors[bg]);
        dc.clear();

        dc.setColor(themeColors[date], Graphics.COLOR_TRANSPARENT);
        dc.drawText(baseX + halfClockWidth - textSideAdj, y1, fontSmallData, seconds, Graphics.TEXT_JUSTIFY_RIGHT);
    }

    (:DefaultLayout)
    hidden function calculateLayout() as Void {
        var y1 = baseY + halfClockHeight + marginY;
        var y2 = y1 + smallDataHeight + marginY;
        var y3 = y2 + labelHeight + labelMargin + largeDataHeight;
        
        fieldY = y2;
        
        var data_width = Math.sqrt(centerY*centerY - (y3 - centerY)*(y3 - centerY)) * 2 + fieldSpaceingAdj;
        var left_edge = Math.round((screenWidth - data_width) / 2);
        
        calculateFieldXCoords(data_width, left_edge);

        bottomFiveY = y3 + halfMarginY + bottomFiveAdj;
        if((propLabelVisibility == 1 or propLabelVisibility == 3)) { bottomFiveY = bottomFiveY - labelHeight; }
    }
    
    (:InstinctCrossover)
    hidden function calculateLayout() as Void {
        var y1 = baseY + halfClockHeight + marginY;
        var y2 = y1 + labelHeight + labelMargin + largeDataHeight;
        
        fieldY = y1;
        
        var data_width = Math.sqrt(centerY*centerY - (y2 - centerY)*(y2 - centerY)) * 2 + fieldSpaceingAdj;
        var left_edge = Math.round((screenWidth - data_width) / 2);
        
        calculateFieldXCoords(data_width, left_edge);

        bottomFiveY = y2 + halfMarginY + bottomFiveAdj;
        if((propLabelVisibility == 1 or propLabelVisibility == 3)) { bottomFiveY = bottomFiveY - labelHeight; }
    }
    
    hidden function calculateFieldXCoords(data_width as Float, left_edge as Number) as Void {
        var digits = getFieldWidths();
        var tot_digits = digits[0] + digits[1] + digits[2] + digits[3];
        if (tot_digits == 0) { return; } 
        var dw1 = Math.round(digits[0] * data_width / tot_digits);
        var dw2 = Math.round(digits[1] * data_width / tot_digits);
        var dw3 = Math.round(digits[2] * data_width / tot_digits);
        var dw4 = Math.round(digits[3] * data_width / tot_digits);

        fieldXCoords[0] = left_edge + Math.round(dw1 / 2);
        fieldXCoords[1] = left_edge + Math.round(dw1 + (dw2 / 2));
        fieldXCoords[2] = left_edge + Math.round(dw1 + dw2 + (dw3 / 2));
        fieldXCoords[3] = left_edge + Math.round(dw1 + dw2 + dw3 + (dw4 / 2));
    }

    (:DefaultLayout)
    hidden function drawWatchface(dc as Dc, now as Gregorian.Info, aod as Boolean, values as Dictionary) as Void {
        // Clear
        dc.setColor(themeColors[bg], themeColors[bg]);
        dc.clear();
        var yn1 = baseY - halfClockHeight - marginY - smallDataHeight;
        var yn2 = yn1 - marginY - smallDataHeight;
        var yn3 = yn2 - marginY - histogramHeight;

        // Draw Top data fields or histogram
        if(propTopPartShows == 2) {
            drawHistogram(dc, values[:dataGraph1], centerX, yn3, histogramHeight);
        } else {
            var top_data_height = halfMarginY;
            var top_field_font = fontTinyData;
            var top_field_center_offset = 20;
            if(propTopPartShows == 1) { top_field_center_offset = labelHeight; }
            if(propLabelVisibility == 0 or propLabelVisibility == 3) {
                dc.setColor(themeColors[fieldLbl], Graphics.COLOR_TRANSPARENT);
                dc.drawText(centerX - top_field_center_offset, marginY, fontLabel, values[:dataLabelTopLeft], Graphics.TEXT_JUSTIFY_RIGHT);
                dc.drawText(centerX + top_field_center_offset, marginY, fontLabel, values[:dataLabelTopRight], Graphics.TEXT_JUSTIFY_LEFT);

                top_data_height = labelHeight + halfMarginY;
            }

            dc.setColor(themeColors[dataVal], Graphics.COLOR_TRANSPARENT);
            if(propTopPartShows == 0) {
                dc.drawText(centerX - top_field_center_offset, marginY + top_data_height, top_field_font, values[:dataTopLeft], Graphics.TEXT_JUSTIFY_RIGHT);
                dc.drawText(centerX + top_field_center_offset, marginY + top_data_height, top_field_font, values[:dataTopRight], Graphics.TEXT_JUSTIFY_LEFT);

                // Draw Moon
                dc.setColor(themeColors[moon], Graphics.COLOR_TRANSPARENT);
                dc.drawText(centerX, marginY + ((top_data_height + tinyDataHeight) / 2), fontMoon, values[:dataMoon], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            } else {
                if(top_data_height == halfMarginY) { top_field_font = fontSmallData; }
                dc.drawText(centerX - top_field_center_offset, marginY + top_data_height, top_field_font, values[:dataTopLeft], Graphics.TEXT_JUSTIFY_RIGHT);
                dc.drawText(centerX + top_field_center_offset, marginY + top_data_height, top_field_font, values[:dataTopRight], Graphics.TEXT_JUSTIFY_LEFT);
            }
        }

        // Draw Lines above clock
        dc.setColor(themeColors[dataVal], Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, yn2, fontSmallData, values[:dataAboveLine1], Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, yn1, fontSmallData, values[:dataAboveLine2], Graphics.TEXT_JUSTIFY_CENTER);        

        // Draw Clock
        dc.setColor(themeColors[clockBg], Graphics.COLOR_TRANSPARENT);
        if(propShowClockBg and !aod) {
            dc.drawText(baseX, baseY, fontClock, clockBgText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
        dc.setColor(themeColors[clock], Graphics.COLOR_TRANSPARENT);
        dc.drawText(baseX, baseY, fontClock, values[:dataClock], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Draw clock gradient
        if(drawGradient != null and themeColors[bg] == 0x000000 and !aod) {
            dc.drawBitmap(centerX - halfClockWidth, baseY - halfClockHeight, drawGradient);
        }

        if(propClockOutlineStyle == 2 or propClockOutlineStyle == 3) {
            if(fontClockOutline != null) { // Someone has only bothered to draw this font for AMOLED sizes
                // Draw outline
                dc.setColor(themeColors[outline], Graphics.COLOR_TRANSPARENT);
                dc.drawText(baseX, baseY, fontClockOutline, values[:dataClock], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            }
        }

        // Draw stress and body battery bars
        drawSideBars(dc, values);

        // Draw Line below clock
        var y1 = baseY + halfClockHeight + marginY;
        dc.setColor(themeColors[date], Graphics.COLOR_TRANSPARENT);
        if(propDateAlignment == 0) {
            dc.drawText(baseX - halfClockWidth + textSideAdj, y1, fontSmallData, values[:dataBelow], Graphics.TEXT_JUSTIFY_LEFT);
        } else {
            dc.drawText(baseX, y1, fontSmallData, values[:dataBelow], Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Draw seconds
        if(propShowSeconds) {
            dc.drawText(baseX + halfClockWidth - textSideAdj, y1, fontSmallData, values[:dataSeconds], Graphics.TEXT_JUSTIFY_RIGHT);
        }

        // Draw Notification count
        dc.setColor(themeColors[notif], Graphics.COLOR_TRANSPARENT);
        if(propDateAlignment == 0) {
            if(!propShowSeconds) { // No seconds, notification on right side
                dc.drawText(baseX + halfClockWidth - textSideAdj, y1, fontSmallData, values[:dataNotifications], Graphics.TEXT_JUSTIFY_RIGHT);
            } else {
                var date_width = dc.getTextWidthInPixels(values[:dataBelow], fontSmallData);
                var sec_width = dc.getTextWidthInPixels(values[:dataSeconds], fontSmallData); 
                var date_right_edge = baseX - halfClockWidth + textSideAdj + date_width;
                var sec_left = baseX + halfClockWidth - textSideAdj - sec_width;
                var pos = sec_left - marginX;
                if((sec_left - date_right_edge) < 3 * marginX) {
                    pos = (date_right_edge + sec_left) / 2;
                }
                dc.drawText(pos, y1, fontSmallData, values[:dataNotifications], Graphics.TEXT_JUSTIFY_CENTER);
            }
        } else { // Date is centered, notification on left side
            dc.drawText(baseX - halfClockWidth, y1, fontSmallData, values[:dataNotifications], Graphics.TEXT_JUSTIFY_LEFT);
        }

        // Draw the three bottom data fields
        var digits = getFieldWidths();

        drawDataField(dc, fieldXCoords[0], fieldY, 3, values[:dataLabelBottomLeft], values[:dataBottomLeft], digits[0], fontLargeData, largeDataWidth * digits[0]);
        drawDataField(dc, fieldXCoords[1], fieldY, 3, values[:dataLabelBottomMiddle], values[:dataBottomMiddle], digits[1], fontLargeData, largeDataWidth * digits[1]);
        drawDataField(dc, fieldXCoords[2], fieldY, 3, values[:dataLabelBottomRight], values[:dataBottomRight], digits[2], fontLargeData, largeDataWidth * digits[2]);
        drawDataField(dc, fieldXCoords[3], fieldY, 3, values[:dataLabelBottomFourth], values[:dataBottomFourth], digits[3], fontLargeData, largeDataWidth * digits[3]);

        // Draw the 5 digit bottom field
        var step_width = 0;
        if(screenHeight == 240) {
            step_width = drawDataField(dc, centerX - 19, bottomFiveY + 3, 0, null, values[:dataBottom], 5, fontBottomData, bottomDataWidth * 5);
        } else {
            step_width = drawDataField(dc, centerX, bottomFiveY, 0, null, values[:dataBottom], 5, fontBottomData, bottomDataWidth * 5);
        }

        // Draw icons
        dc.setColor(themeColors[dataVal], Graphics.COLOR_TRANSPARENT);
        if(screenHeight == 240) { step_width += 30; }
        dc.drawText(centerX - (step_width / 2) - (marginX / 2), bottomFiveY + (largeDataHeight / 2) + iconYAdj, fontIcons, values[:dataIcon1], Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(centerX + (step_width / 2) + (marginX / 2) - 2, bottomFiveY + (largeDataHeight / 2) + iconYAdj, fontIcons, values[:dataIcon2], Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        
        // Draw battery icon
        if(screenHeight == 240 and propBottomFieldShows != -2) {
            drawBatteryIcon(dc, centerX + 32, bottomFiveY, values);
        } else {
            drawBatteryIcon(dc, null, null, values);
        }
    }

    (:InstinctCrossover)
    hidden function drawWatchface(dc as Dc, now as Gregorian.Info, aod as Boolean, values as Dictionary) as Void {
        // Clear
        dc.setColor(themeColors[bg], themeColors[bg]);
        dc.clear();

        // Shifted positions: date line is now above clock
        var yn0 = baseY - halfClockHeight - marginY - smallDataHeight;  // date line (above clock)
        var yn1 = yn0 - marginY - smallDataHeight;  // weather line 2
        var yn2 = yn1 - marginY - smallDataHeight;  // weather line 1
        var yn3 = yn2 - marginY - histogramHeight;

        // Draw Top data fields or histogram
        if(propTopPartShows == 2) {
            drawHistogram(dc, values[:dataGraph1], centerX, yn3, histogramHeight);
        } else {
            var top_data_height = halfMarginY;
            var top_field_font = fontTinyData;
            var top_field_center_offset = 20;
            if(propTopPartShows == 1) { top_field_center_offset = labelHeight; }
            if(propLabelVisibility == 0 or propLabelVisibility == 3) {
                dc.setColor(themeColors[fieldLbl], Graphics.COLOR_TRANSPARENT);
                dc.drawText(centerX - top_field_center_offset, marginY, fontLabel, values[:dataLabelTopLeft], Graphics.TEXT_JUSTIFY_RIGHT);
                dc.drawText(centerX + top_field_center_offset, marginY, fontLabel, values[:dataLabelTopRight], Graphics.TEXT_JUSTIFY_LEFT);

                top_data_height = labelHeight + halfMarginY + 2;
            }

            dc.setColor(themeColors[dataVal], Graphics.COLOR_TRANSPARENT);
            if(propTopPartShows == 0) {
                dc.drawText(centerX - top_field_center_offset, marginY + top_data_height, top_field_font, values[:dataTopLeft], Graphics.TEXT_JUSTIFY_RIGHT);
                dc.drawText(centerX + top_field_center_offset, marginY + top_data_height, top_field_font, values[:dataTopRight], Graphics.TEXT_JUSTIFY_LEFT);

                // Draw Moon
                dc.setColor(themeColors[moon], Graphics.COLOR_TRANSPARENT);
                dc.drawText(centerX, marginY + ((top_data_height + tinyDataHeight) / 2), fontMoon, values[:dataMoon], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            } else {
                if(top_data_height == halfMarginY) { top_field_font = fontSmallData; }
                dc.drawText(centerX - top_field_center_offset, marginY + top_data_height, top_field_font, values[:dataTopLeft], Graphics.TEXT_JUSTIFY_RIGHT);
                dc.drawText(centerX + top_field_center_offset, marginY + top_data_height, top_field_font, values[:dataTopRight], Graphics.TEXT_JUSTIFY_LEFT);
            }
        }

        // Draw Lines above clock (shifted up by one row)
        dc.setColor(themeColors[dataVal], Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, yn2, fontSmallData, values[:dataAboveLine1], Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, yn1, fontSmallData, values[:dataAboveLine2], Graphics.TEXT_JUSTIFY_CENTER);

        // Draw date line ABOVE clock (at yn0)
        dc.setColor(themeColors[date], Graphics.COLOR_TRANSPARENT);
        if(propDateAlignment == 0) {
            dc.drawText(baseX - halfClockWidth + textSideAdj, yn0, fontSmallData, values[:dataBelow], Graphics.TEXT_JUSTIFY_LEFT);
        } else {
            dc.drawText(baseX, yn0, fontSmallData, values[:dataBelow], Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Draw seconds (above clock)
        if(propShowSeconds) {
            dc.drawText(baseX + halfClockWidth - textSideAdj, yn0, fontSmallData, values[:dataSeconds], Graphics.TEXT_JUSTIFY_RIGHT);
        }

        // Draw Notification count (above clock)
        dc.setColor(themeColors[notif], Graphics.COLOR_TRANSPARENT);
        if(propDateAlignment == 0) {
            if(!propShowSeconds) {
                dc.drawText(baseX + halfClockWidth - textSideAdj, yn0, fontSmallData, values[:dataNotifications], Graphics.TEXT_JUSTIFY_RIGHT);
            } else {
                var date_width = dc.getTextWidthInPixels(values[:dataBelow], fontSmallData);
                var sec_width = dc.getTextWidthInPixels(values[:dataSeconds], fontSmallData);
                var date_right_edge = baseX - halfClockWidth + textSideAdj + date_width;
                var sec_left = baseX + halfClockWidth - textSideAdj - sec_width;
                var pos = sec_left - marginX;
                if((sec_left - date_right_edge) < 3 * marginX) {
                    pos = (date_right_edge + sec_left) / 2;
                }
                dc.drawText(pos, yn0, fontSmallData, values[:dataNotifications], Graphics.TEXT_JUSTIFY_CENTER);
            }
        } else {
            dc.drawText(baseX - halfClockWidth, yn0, fontSmallData, values[:dataNotifications], Graphics.TEXT_JUSTIFY_LEFT);
        }

        // Draw Clock
        dc.setColor(themeColors[clockBg], Graphics.COLOR_TRANSPARENT);
        if(propShowClockBg and !aod) {
            dc.drawText(baseX, baseY, fontClock, clockBgText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
        dc.setColor(themeColors[clock], Graphics.COLOR_TRANSPARENT);
        dc.drawText(baseX, baseY, fontClock, values[:dataClock], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Draw clock gradient
        if(drawGradient != null and themeColors[bg] == 0x000000 and !aod) {
            dc.drawBitmap(centerX - halfClockWidth, baseY - halfClockHeight, drawGradient);
        }

        if(propClockOutlineStyle == 2 or propClockOutlineStyle == 3) {
            if(fontClockOutline != null) {
                dc.setColor(themeColors[outline], Graphics.COLOR_TRANSPARENT);
                dc.drawText(baseX, baseY, fontClockOutline, values[:dataClock], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            }
        }

        // Draw stress and body battery bars
        drawSideBars(dc, values);

        // Draw the three bottom data fields (directly below clock, no date row)
        var digits = getFieldWidths();

        drawDataField(dc, fieldXCoords[0], fieldY, 3, values[:dataLabelBottomLeft], values[:dataBottomLeft], digits[0], fontLargeData, largeDataWidth * digits[0]);
        drawDataField(dc, fieldXCoords[1], fieldY, 3, values[:dataLabelBottomMiddle], values[:dataBottomMiddle], digits[1], fontLargeData, largeDataWidth * digits[1]);
        drawDataField(dc, fieldXCoords[2], fieldY, 3, values[:dataLabelBottomRight], values[:dataBottomRight], digits[2], fontLargeData, largeDataWidth * digits[2]);
        drawDataField(dc, fieldXCoords[3], fieldY, 3, values[:dataLabelBottomFourth], values[:dataBottomFourth], digits[3], fontLargeData, largeDataWidth * digits[3]);

        // Draw the 5 digit bottom field
        var step_width = drawDataField(dc, centerX, bottomFiveY, 0, null, values[:dataBottom], 5, fontBottomData, bottomDataWidth * 5);

        // Draw icons
        dc.setColor(themeColors[dataVal], Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX - (step_width / 2) - (marginX / 2), bottomFiveY + (largeDataHeight / 2) + iconYAdj, fontIcons, values[:dataIcon1], Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(centerX + (step_width / 2) + (marginX / 2) - 2, bottomFiveY + (largeDataHeight / 2) + iconYAdj, fontIcons, values[:dataIcon2], Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Draw battery icon
        drawBatteryIcon(dc, null, null, values);
    }

    (:MIP)
    hidden function drawAOD(dc as Dc, now as Gregorian.Info, values as Dictionary) as Void { }

    (:AMOLED)
    hidden function drawAOD(dc as Dc, now as Gregorian.Info, values as Dictionary) as Void {
        dc.setColor(0x000000, 0x000000);
        dc.clear();

        if(propAodStyle == 2) {
            drawWatchface(dc, now, true, values);
            drawPattern(dc, 0x000000, (now.min % 3));
        } else if (propAodStyle == 1) {
            var clock_color = themeColors[clock];
            if(clock_color == 0x000000) { clock_color = 0x555555; }

            if(propClockOutlineStyle == 0 or propClockOutlineStyle == 2 or propClockOutlineStyle == 5) {
                // Draw Clock
                dc.setColor(clock_color, Graphics.COLOR_TRANSPARENT);
                dc.drawText(baseX, baseY, fontClock, values[:dataClock], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            }

            if(propClockOutlineStyle == 1 or propClockOutlineStyle == 2 or propClockOutlineStyle == 3) {
                dc.setColor(themeColors[outline], Graphics.COLOR_TRANSPARENT);
                dc.drawText(baseX, baseY, fontClockOutline, values[:dataClock], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            }

            if(propClockOutlineStyle == 4) {
                // Filled clock but outline color
                dc.setColor(themeColors[outline], Graphics.COLOR_TRANSPARENT);
                dc.drawText(baseX, baseY, fontClock, values[:dataClock], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            }

            // Draw clock gradient
            dc.drawBitmap(centerX - halfClockWidth - (now.min % 2), baseY - halfClockHeight, drawAODPattern);

            // Draw Line below clock
            var y1 = baseY + halfClockHeight + marginY;
            dc.setColor(themeColors[dateDim], Graphics.COLOR_TRANSPARENT);
            if(propAodAlignment == 0) {
                dc.drawText(baseX - halfClockWidth + textSideAdj - (now.min % 3), y1, fontAODData, values[:dataAODLeft], Graphics.TEXT_JUSTIFY_LEFT);
            } else {
                dc.drawText(baseX - (now.min % 3), y1, fontAODData, values[:dataAODLeft], Graphics.TEXT_JUSTIFY_CENTER);
            }
            dc.drawText(baseX + halfClockWidth - textSideAdj - 2 - (now.min % 3), y1, fontAODData, values[:dataAODRight], Graphics.TEXT_JUSTIFY_RIGHT);
        }
    }

    (:AMOLED)
    hidden function drawPattern(dc as Dc, color as ColorType, offset as Number) as Void {
        var text = "";
        for(var i = 0; i < Math.ceil(screenWidth / 20) + 1; i++) {
                text += "S";
        }

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        var i = 0;
        while(i < Math.ceil(screenHeight / 20) + 1) {
            dc.drawText(0, i*20 + offset, fontIcons, text, Graphics.TEXT_JUSTIFY_LEFT);
            i++;
        }
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

    hidden function drawDataField(dc as Dc, x as Number, y as Number, adjX as Number, label as String?, value as String, width as Number, font as FontResource, bgwidth as Number) as Number {
        if(value.length() == 0 and (label == null or label.length() == 0)) { return 0; }
        if(width == 0) { return 0; }
        var valueBg = "";
        var bgChar = "#";
        if(screenHeight == 360 and width == 5 and label == null) { bgChar = "$"; }
        for(var i=0; i<width; i++) { valueBg += bgChar; }

        var value_bg_width = bgwidth;//dc.getTextWidthInPixels(valueBg, font);
        var half_bg_width = Math.round(value_bg_width / 2);
        var data_y = y;

        if((propLabelVisibility == 0 or propLabelVisibility == 2) and !(label == null)) {
            dc.setColor(themeColors[fieldLbl], Graphics.COLOR_TRANSPARENT);
            if(propBottomFieldLabelAlignment == 0) {
                dc.drawText(x - half_bg_width + adjX, y, fontLabel, label, Graphics.TEXT_JUSTIFY_LEFT);
            } else {
                dc.drawText(x, y, fontLabel, label, Graphics.TEXT_JUSTIFY_CENTER);
            }
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

    hidden function drawSideBars(dc as Dc, values as Dictionary) as Void {
        var barVal;
        var barHeight;
        var barColor;

        if (values[:dataLeftBar] != null) {
            barVal = values[:dataLeftBar];
            barHeight = Math.round(barVal * (clockHeight / 100.0));
            if (propLeftBarShows == 1 && propStressDynamicColor) {
                barColor = getStressColor(barVal);
            } else {
                barColor = themeColors[stress]; 
            }
            dc.setColor(barColor, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(
                centerX - halfClockWidth - barWidth - barWidth, baseY + halfClockHeight - barHeight + barBottomAdj, barWidth, barHeight
            );

            if(propLeftBarShows == 6) {
                drawMoveBarTicks(dc, centerX - halfClockWidth - barWidth - barWidth, centerX - halfClockWidth);
            }
        }

        if (values[:dataRightBar] != null) {
            barVal = values[:dataRightBar];
            barHeight = Math.round(barVal * (clockHeight / 100.0));
            if (propRightBarShows == 1 && propStressDynamicColor) {
                barColor = getStressColor(barVal);
            } else {
                barColor = themeColors[bodybatt]; 
            }
            dc.setColor(barColor, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(
                centerX + halfClockWidth + barWidth, baseY + halfClockHeight - barHeight + barBottomAdj, barWidth, barHeight
            );
            
            if(propRightBarShows == 6) {
                drawMoveBarTicks(dc, centerX + halfClockWidth + barWidth + barWidth, centerX + halfClockWidth);
            }
        }
    }

    hidden function drawMoveBarTicks(dc as Dc, x1, x2) as Void {
        dc.setColor(themeColors[bg], Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(x1, baseY + halfClockHeight - (40 * (clockHeight / 100.0)), x2, baseY + halfClockHeight - (40 * (clockHeight / 100.0)));
        dc.drawLine(x1, baseY + halfClockHeight - (55 * (clockHeight / 100.0)), x2, baseY + halfClockHeight - (55 * (clockHeight / 100.0)));
        dc.drawLine(x1, baseY + halfClockHeight - (70 * (clockHeight / 100.0)), x2, baseY + halfClockHeight - (70 * (clockHeight / 100.0)));
        dc.drawLine(x1, baseY + halfClockHeight - (85 * (clockHeight / 100.0)), x2, baseY + halfClockHeight - (85 * (clockHeight / 100.0)));
        dc.setPenWidth(1);
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
                dc.setColor(getStressColor(data[i]), Graphics.COLOR_TRANSPARENT);
            }
            bar_height = Math.round(data[i] / scale);
            dc.drawRectangle(x - half_width + i * (histogramBarWidth + histogramBarSpacing), y + (h - bar_height), histogramBarWidth, bar_height);
        }
    }

    (:AMOLED)
    hidden function drawBatteryIcon(dc as Dc, x as Number?, y as Number?, values as Dictionary) {
        if(propBatteryVariant == 2) { return; }
        if(x == null) { x = centerX; }
        if(y == null) { y =  screenHeight - 25; }

        dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, fontIcons, "C", Graphics.TEXT_JUSTIFY_CENTER);
        if(System.getSystemStats().battery <= 15) {
            dc.setColor(0xFF0000, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(themeColors[dataVal], Graphics.COLOR_TRANSPARENT);
        }
        if(propBatteryVariant == 3) {
            dc.drawText(x - 19, y + 4, fontBattery, values[:dataBattery], Graphics.TEXT_JUSTIFY_LEFT);
        } else { // centered when not a bar
            dc.drawText(x - 1, y + 4, fontBattery, values[:dataBattery], Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    (:MIP)
    hidden function drawBatteryIcon(dc as Dc, x as Number?, y as Number?, values as Dictionary) {
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
        if(propBatteryVariant == 3) {
            dc.drawText(x - 11, y + 3, fontBattery, values[:dataBattery], Graphics.TEXT_JUSTIFY_LEFT);
        } else {
            dc.drawText(x - 1, y + 3, fontBattery, values[:dataBattery], Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    hidden function setColorTheme(theme as Number) as Array<Graphics.ColorType> {
        if(theme == 30) { return parseCustomThemeString(propColorOverride); }

        var themeRes = [
            Rez.Strings.theme_0, Rez.Strings.theme_1, Rez.Strings.theme_2, Rez.Strings.theme_3,
            Rez.Strings.theme_4, Rez.Strings.theme_5, Rez.Strings.theme_6, Rez.Strings.theme_7,
            Rez.Strings.theme_8, Rez.Strings.theme_9, Rez.Strings.theme_10, Rez.Strings.theme_11,
            Rez.Strings.theme_12, Rez.Strings.theme_13, Rez.Strings.theme_14, Rez.Strings.theme_15,
            Rez.Strings.theme_16, Rez.Strings.theme_17, Rez.Strings.theme_18, Rez.Strings.theme_19,
            Rez.Strings.theme_20, Rez.Strings.theme_21, Rez.Strings.theme_22, Rez.Strings.theme_23
        ];

        var str = "";
        if(theme >= 0 and theme < themeRes.size()) {
            str = WatchUi.loadResource(themeRes[theme]);
        } else {
            str = WatchUi.loadResource(Rez.Strings.theme_0);
        }

        return parseThemeString(str);
    }

    hidden function parseThemeString(csv as String) as Array<Graphics.ColorType> {
        var res = new [13]; 
        var comma = 0;
        for(var i=0; i<13; i++) {
            comma = csv.find(",");
            var hex = "";
            if(comma != null) {
                hex = csv.substring(0, comma);
                csv = csv.substring(comma + 1, csv.length());
            } else {
                hex = csv;
            }
            
            if(hex.equals("FFFFFFFF")) {
                res[i] = Graphics.COLOR_TRANSPARENT; 
            } else {
                res[i] = hex.toNumberWithBase(16);
            }
        }
        return res;
    }

    hidden function parseCustomThemeString(str as String) as Array<Graphics.ColorType> {
        if(str.length() == 0) { return setColorTheme(-1); }
        
        var ret = [];
        var color_str = "";
        var color = null;
        var len = str.length();

        for(var i=0; i<len; i += 8) {
            if(i+7 > len) { break; }
            color_str = str.substring(i+1, i+7);
            color = color_str.toNumberWithBase(16);
            
            if(color == null or color < 0 or color > 16777215) {
                 return setColorTheme(-1);
            }
            ret.add(color as Graphics.ColorType);
        }

        if(ret.size() != 13) {
            return setColorTheme(-1);
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
        propLeftBarShows = getValueOrDefault("leftBarShows", 1) as Number;
        propRightBarShows = getValueOrDefault("rightBarShows", 2) as Number;
        propIcon1 = getValueOrDefault("icon1", 1) as Number;
        propIcon2 = getValueOrDefault("icon2", 2) as Number;
        propBatteryVariant = getValueOrDefault("batteryVariant", 3) as Number;
        
        propUpdateFreq = getValueOrDefault("updateFreq", 5) as Number;
        propShowClockBg = getValueOrDefault("showClockBg", true) as Boolean;
        propShowDataBg = getValueOrDefault("showDataBg", true) as Boolean;
        propAodStyle = getValueOrDefault("aodStyle", 1) as Number;
        propAodFieldShows = getValueOrDefault("aodFieldShows", -1) as Number;
        propAodRightFieldShows = getValueOrDefault("aodRightFieldShows", -2) as Number;
        propAodAlignment = getValueOrDefault("aodAlignment", 0) as Number;
        propDateAlignment = getValueOrDefault("dateAlignment", 0) as Number;
        propBottomFieldAlignment = getValueOrDefault("bottomFieldAlignment", 2) as Number;
        propBottomFieldLabelAlignment = getValueOrDefault("bottomFieldLabelAlignment", 0) as Number;
        propHemisphere = getValueOrDefault("hemisphere", 0) as Number;
        propHourFormat = getValueOrDefault("hourFormat", 0) as Number;
        propZeropadHour = getValueOrDefault("zeropadHour", true) as Boolean;
        propTimeSeparator = getValueOrDefault("timeSeparator", 0) as Number;
        propTempUnit = getValueOrDefault("tempUnit", 0) as Number;
        propWindUnit = getValueOrDefault("windUnit", 0) as Number;
        propPressureUnit = getValueOrDefault("pressureUnit", 0) as Number;
        propLabelVisibility = getValueOrDefault("labelVisibility", 0) as Number;
        propDateFormat = getValueOrDefault("dateFormat", 0) as Number;
        propShowNotificationCount = getValueOrDefault("showNotificationCount", true) as Boolean;
        propTzOffset1 = getValueOrDefault("tzOffset1", 0) as Number;
        propTzOffset2 = getValueOrDefault("tzOffset2", 0) as Number;
        propTzName1 = getValueOrDefault("tzName1", "UTC TIME") as String;
        propTzName2 = getValueOrDefault("tzName2", "TZ2") as String;
        propWeekOffset = getValueOrDefault("weekOffset", 0) as Number;
        propSmallFontVariant = getValueOrDefault("smallFontVariant", 2) as Number;
        propIs24H = System.getDeviceSettings().is24Hour;
        propStressDynamicColor = getValueOrDefault("stressDynamicColor", false) as Boolean;

        nightMode = null; // force update color theme
        updateColorTheme();
        updateActiveLabels();

        isWeatherRequired = false;

        var weatherFields = [
            propSunriseFieldShows, propSunsetFieldShows,
            propWeatherLine1Shows, propWeatherLine2Shows,
            propDateFieldShows,
            propLeftValueShows, propMiddleValueShows, 
            propRightValueShows, propFourthValueShows,
            propBottomFieldShows,
            propAodFieldShows, propAodRightFieldShows
        ];

        for(var i=0; i<weatherFields.size(); i++) {
            if (isWeatherSource(weatherFields[i])) {
                isWeatherRequired = true;
                break;
            }
        }

        initializeWeatherData();

        if(propTimeSeparator == 2) { clockBgText = "####"; } else { clockBgText = "#####"; }
    }

    hidden function getAltitudeValue() as Float? {
        // 1. Best: Complications (Modern approach)
        if (hasComplications) {
            try {
                var comp = Complications.getComplication(new Id(Complications.COMPLICATION_TYPE_ALTITUDE));
                if (comp != null && comp.value != null) {
                    return comp.value.toFloat(); 
                }
            } catch(e) {}
        }

        // 2. From Sensor History
        if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getElevationHistory)) {
            var elv_iterator = Toybox.SensorHistory.getElevationHistory({:period => 1});
            if (elv_iterator != null) {
                var sample = elv_iterator.next();
                if (sample != null && sample.data != null) {
                    return sample.data.toFloat();
                }
            }
        }

        // 3. Fallback: Activity Info
        var info = Activity.getActivityInfo();
        if (info != null && info.altitude != null) {
            return info.altitude.toFloat();
        }

        return null;
    }

    hidden function getClockData(now as Gregorian.Info) as String {
        var separator = ":";
        if(propTimeSeparator == 1) { separator = " "; }
        if(propTimeSeparator == 2) { separator = ""; }

        if(propZeropadHour) {
            return formatHour(now.hour).format("%02d") + separator + now.min.format("%02d");
        } else {
            return formatHour(now.hour).format("%2d") + separator + now.min.format("%02d");
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

    hidden function getBarData(data_source as Number) as Number? {
        if(data_source == 1) {
            return getStressData();
        } else if (data_source == 2) {
            return getBBData();
        } else if (data_source == 3) {
            return getStepGoalProgress();
        } else if (data_source == 4) {
            return getFloorGoalProgress();
        } else if (data_source == 5) {
            return getActMinGoalProgress();
        } else if (data_source == 6) {
            return getMoveBar();
        }
        return null;
    }

    hidden function getStressData() as Number? {
        if (hasComplications) {
            try {
                var complication_stress = Complications.getComplication(new Id(Complications.COMPLICATION_TYPE_STRESS));
                if (complication_stress != null && complication_stress.value != null) {
                    return complication_stress.value;
                }
            } catch(e) {
                // Complication not found
            }
        }

        if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory) && (Toybox.SensorHistory has :getStressHistory)) {
            var st_iterator = Toybox.SensorHistory.getStressHistory({:period => 1});
            if (st_iterator != null) {
                var st = st_iterator.next();

                if(st != null) {
                    return st.data;
                }
            }
        }
        return null;
    }

    hidden function getStressColor(val as Number) as Graphics.ColorType {
        if (val <= 25) { return 0x00AAFF; } // Rest (Blue)
        if (val <= 50) { return 0xFFAA00; } // Low (Yellow/Orange)
        if (val <= 75) { return 0xFF5500; } // Medium (Orange)
        return 0xAA0000;                   // High (Red)
    }

    hidden function getBBData() as Number? {
        if (hasComplications) {
            try {
                var complication_bb = Complications.getComplication(new Id(Complications.COMPLICATION_TYPE_BODY_BATTERY));
                if (complication_bb != null && complication_bb.value != null) {
                    return complication_bb.value;
                }
            } catch(e) {
                // Complication not found
            }
        }

        if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory) && (Toybox.SensorHistory has :getStressHistory)) {
            var bb_iterator = Toybox.SensorHistory.getBodyBatteryHistory({:period => 1});
            if (bb_iterator != null) {
                var bb = bb_iterator.next();

                if(bb != null) {
                    return bb.data;
                }
            }
        }
        return null;
    }

    hidden function getStepGoalProgress() as Number? {
        if(ActivityMonitor.getInfo().steps != null and ActivityMonitor.getInfo().stepGoal != null) {
            var steps = ActivityMonitor.getInfo().steps;
            var goal = ActivityMonitor.getInfo().stepGoal;
            if(goal == null or goal == 0) { return 0; }
            if(steps == null or steps == 0) { return 0; }
            return Math.round(steps.toFloat() / goal.toFloat() * 100.0);
        }
        return null;
    }

    hidden function getFloorGoalProgress() as Number? {
        if(ActivityMonitor.getInfo() has :floorsClimbed and ActivityMonitor.getInfo() has :floorsClimbedGoal) {
            if(ActivityMonitor.getInfo().floorsClimbed != null and ActivityMonitor.getInfo().floorsClimbedGoal != null) {
                var floors = ActivityMonitor.getInfo().floorsClimbed;
                var goal = ActivityMonitor.getInfo().floorsClimbedGoal;
                if(goal == null or goal == 0) { return 0; }
                if(floors == null or floors == 0) { return 0; }
                return Math.round(floors.toFloat() / goal.toFloat() * 100.0);
            }
        }
        return null;
    }

    hidden function getActMinGoalProgress() as Number? {
        if(ActivityMonitor.getInfo().activeMinutesWeek != null and ActivityMonitor.getInfo().activeMinutesWeekGoal != null) {
            var actmin = ActivityMonitor.getInfo().activeMinutesWeek;
            var val = actmin.total;
            var goal = ActivityMonitor.getInfo().activeMinutesWeekGoal;
            if(goal == null or goal == 0) { return 0; }
            if(val == null or val == 0) { return 0; }
            return Math.round(val.toFloat() / goal.toFloat() * 100.0);
        }
        return null;
    }

    hidden function getMoveBar() as Number? {
        if(ActivityMonitor.getInfo() has :moveBarLevel) {
            if(ActivityMonitor.getInfo().moveBarLevel != null) {
                var mov = ActivityMonitor.getInfo().moveBarLevel;
                if(mov == 1) { return 40; }
                if(mov == 2) { return 55; }
                if(mov == 3) { return 70; }
                if(mov == 4) { return 85; }
                if(mov == 5) { return 100; }
            }
        }
        return null;
    }

    hidden function getBattData() as String {
        var value = "";

        if(propBatteryVariant == 0) {
            if(System.getSystemStats() has :batteryInDays) {
                if (System.getSystemStats().batteryInDays != null){
                    var sample = Math.round(System.getSystemStats().batteryInDays);
                    value = sample.format("%0d") + "D";
                }
            } else {
                propBatteryVariant = 1;  // Fall back to percentage if days not available
            }
        }
        if(propBatteryVariant == 1) {
            var sample = System.getSystemStats().battery;
            if(sample < 100) {
                value = sample.format("%d") + "%";
            } else {
                value = sample.format("%d");
            }
        } else if(propBatteryVariant == 3) {
                var sample = 0;
                var max = 0;
                var batLevel = System.getSystemStats().battery; 

                if(screenHeight > 280) {
                    sample = Math.round(batLevel / 100.0 * 35).toNumber();
                    max = 35;
                } else {
                    sample = Math.round(batLevel / 100.0 * 20).toNumber();
                    max = 20;
                }
                if (sample > 0) {
                    value += battFull.substring(0, sample);
                }
                
                if (sample < max) {
                    value += battEmpty.substring(0, max - sample);
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

    (:WeatherCache)
    hidden function initializeWeatherData() as Void {
        if (isWeatherRequired && weatherCondition == null) {
            try { weatherCondition = readWeatherData(); } catch(e) {}
            if (weatherCondition == null) {
                if(Toybox has :Weather && Weather has :getCurrentConditions) {
                    weatherCondition = Weather.getCurrentConditions();
                }
            }
        }
    }

    (:NoWeatherCache)
    hidden function initializeWeatherData() as Void {
        if (isWeatherRequired && weatherCondition == null) {
            if(Toybox has :Weather && Weather has :getCurrentConditions) {
                weatherCondition = Weather.getCurrentConditions();
            }
        }
    }

    (:WeatherCache)
    hidden function updateWeather() as Void {
        if (!isWeatherRequired) { return; }
        if(!(Toybox has :Weather) or !(Weather has :getCurrentConditions)) { return; }

        if(Weather.getCurrentConditions() != null) {
            weatherCondition = Weather.getCurrentConditions();
            try { storeWeatherData(); } catch(e) {}
        } else {
            try { weatherCondition = readWeatherData(); } catch(e) {}
        }
    }

    (:NoWeatherCache)
    hidden function updateWeather() as Void {
        if (!isWeatherRequired) { return; }
        if(!(Toybox has :Weather) or !(Weather has :getCurrentConditions)) { return; }
        weatherCondition = Weather.getCurrentConditions();
    }

    hidden function isWeatherSource(id as Number) as Boolean {
        if (id == 20 || id == 39 || id == 40 || (id >= 43 && id <= 55) || (id >= 63 && id <= 70)) {
            return true;
        }
        return false;
    }

    (:WeatherCache)
    hidden function computeCcHash(cc) as Number {
        if (cc == null) { return 0; }
        
        var h = 17;

        var t = (cc.temperature != null) ? cc.temperature : -127;
        h = 31 * h + t;
        var c = (cc.condition != null) ? cc.condition : -1;
        h = 31 * h + c;
        var w = (cc.windSpeed != null) ? cc.windSpeed.toNumber() : -1;
        h = 31 * h + w;
        var b = (cc.windBearing != null) ? cc.windBearing : -1;
        h = 31 * h + b;

        return h;
    }

    (:WeatherCache)
    hidden function storeWeatherData() as Void {
        var now = Time.now().value();
        var sysStats = System.getSystemStats();

        if (!isLowMem && sysStats.freeMemory < 15000) {
            isLowMem = true;
            Application.Storage.setValue("hourly_forecast", []); 
            lastHfTime = null; 
        } else if (isLowMem && sysStats.freeMemory > 17000) {
            isLowMem = false;
        }

        var cc = Weather.getCurrentConditions();
        var newCcHash = computeCcHash(cc);

        if (lastCcHash == null || lastCcHash != newCcHash) {
            var cc_data = {};
            if(cc != null) {
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
                if (cc has :uvIndex && cc.uvIndex != null) {
                    cc_data["uvIndex"] = cc.uvIndex;
                } else {
                    cc_data["uvIndex"] = -1;
                }
            }

            cc_data["timestamp"] = now;
            Application.Storage.setValue("current_conditions", cc_data);
            
            lastCcHash = newCcHash;
        }

        if (isLowMem) { return; }

        var hf = Weather.getHourlyForecast();
        
        if (hf == null || hf.size() == 0) { return; }

        var firstForecastTime = hf[0].forecastTime.value();

        if (lastHfTime == null || lastHfTime != firstForecastTime) {
            var hf_data = [];
            
            for(var i=0; i<hf.size(); i++) {
                var tmp = {
                    "forecastTime" => hf[i].forecastTime.value(),
                    "condition" => hf[i].condition,
                    "precipitationChance" => hf[i].precipitationChance,
                    "temperature" => hf[i].temperature,
                    "windBearing" => hf[i].windBearing,
                    "windSpeed" => hf[i].windSpeed
                };
                if(hf[i] has :uvIndex && hf[i].uvIndex != null) { 
                    tmp["uvIndex"] = hf[i].uvIndex; 
                } else {
                    tmp["uvIndex"] = -1;
                }
                
                hf_data.add(tmp);
            }

            Application.Storage.setValue("hourly_forecast", hf_data);
            lastHfTime = firstForecastTime;
        }
    }

    (:WeatherCache)
    hidden function readWeatherData() as StoredWeather {
        var ret = new StoredWeather();
        var now = Time.now().value();
        var cc_data = Application.Storage.getValue("current_conditions") as Dictionary<String, Application.PropertyValueType>?;
        if(cc_data == null) { return ret; }
        
        var data_age_s = now - (cc_data.get("timestamp") as Number);
        var pos = cc_data.get("observationLocationPosition") as Array?;
        if (pos != null) {
            ret.observationLocationPosition = new Position.Location({:latitude => pos[0], :longitude => pos[1], :format => :degrees});
        }
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

    hidden function getValueByTypeWithUnit(complicationType as Number, width as Number) as String {
        var unit = getUnitByType(complicationType);
        if (unit.length() > 0) {
            unit = " " + unit;
        }
        return getValueByType(complicationType, width) + unit;
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
                        if(recovery_h < 9.9 and recovery_h != 0) { val = recovery_h.format("%.1f"); } else { val = Math.round(recovery_h).format(numberFormat); }
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
                var history = ActivityMonitor.getHeartRateHistory(1, /* newestFirst */ true);
                if (history != null) {
                    var hist = history.next();
                    if ((hist != null) && (hist.heartRate != ActivityMonitor.INVALID_HR_SAMPLE)) {
                        val = hist.heartRate.format("%01d");
                    }
                }
            }
        } else if(complicationType == 11) { // Calories
            if (ActivityMonitor.getInfo() has :calories) {
                if(ActivityMonitor.getInfo().calories != null) {
                    val = ActivityMonitor.getInfo().calories.format(numberFormat);
                }
            }
        } else if(complicationType == 12) { // Altitude (m)
                var alt = getAltitudeValue();
                if (alt != null) {
                    val = alt.format(numberFormat);
            }
        } else if(complicationType == 13) { // Stress
        var st = getStressData();
            if(st != null) {
                val = st.format(numberFormat);
            }
        } else if(complicationType == 14) { // Body battery
            var bb = getBBData();
            if(bb != null) {
                val = bb.format(numberFormat);
            }
        } else if(complicationType == 15) { // Altitude (ft)
            var alt = getAltitudeValue();
            if (alt != null) {
                val = (alt * 3.28084).format(numberFormat);
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
                        val = steps_k.format("%.1f") + "K";
                    } else {
                        val = steps_k.format("%d") + "K";
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
                } else { val = "0"; }
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
            val = battery.format("%d");
        } else if(complicationType == 35) { // Battery days remaining
            if(System.getSystemStats() has :batteryInDays) {
                if (System.getSystemStats().batteryInDays != null){
                    var sample = Math.round(System.getSystemStats().batteryInDays);
                    val = sample.format(numberFormat);
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
                if (tempIterator != null) {
                    var temp = tempIterator.next();
                    if(temp != null and temp.data != null) {
                        var tempUnit = getTempUnit();
                        val = formatTemperature(temp.data, tempUnit).format(numberFormat) + tempUnit;
                    }
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
                            val = sunriseHour.format("%02d") + sunrise.min.format("%02d");
                        } else {
                            val = sunriseHour.format("%02d") + ":" + sunrise.min.format("%02d");
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
                            val = sunsetHour.format("%02d") + sunset.min.format("%02d");
                        } else {
                            val = sunsetHour.format("%02d") + ":" + sunset.min.format("%02d");
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
                val = temp + tempUnit;
            }
        } else if(complicationType == 44) { // Low temp
            if(weatherCondition != null and weatherCondition.lowTemperature != null) {
                var tempVal = weatherCondition.lowTemperature;
                var tempUnit = getTempUnit();
                var temp = formatTemperature(tempVal, tempUnit).format("%01d");
                val = temp + tempUnit;
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
                    val = nextSunEventHour.format("%02d") + nextSunEvent.min.format("%02d");
                } else {
                    val = nextSunEventHour.format("%02d") + ":" + nextSunEvent.min.format("%02d");
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
                    if (it != null) {
                        var ox = it.next();
                        if(ox != null and ox.data != null) {
                            val = ox.data.format("%d");
                        }
                    }
                }
            }
        } else if(complicationType == 60) { // Location Long Lat dec deg
            var pos = Activity.getActivityInfo().currentLocation;
            if(pos != null) {
                val = pos.toDegrees()[0] + " " + pos.toDegrees()[1];
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
        } else if(complicationType == 68) { // Temperature, UV, Precip
            var temp = getTemperature();
            var uv = getUVIndex();
            var precip = getPrecip();
            val = join([temp, uv, precip]);
        } else if(complicationType == 69) { // Temperature, UV, Wind
            var temp = getTemperature();
            var uv = getUVIndex();
            var wind = getWind();
            val = join([temp, uv, wind]);
        } else if(complicationType == 70) { // Weather condition, Temperature
            var condition = getWeatherCondition(false);
            var temp = getTemperature();
            val = join([condition, temp]);
        } else if(complicationType == 71) { // CGM Glucose + Trend
            val = getCgmReading();
        } else if(complicationType == 72) { // CGM Age (minutes)
            val = getCgmAge();
        }

        return val;
    }

    hidden function getDataArrayByType(dataSource as Number) as Array<Number> {
        var ret = [];
        var iterator = null;
        var max = null;
        var twoHours = new Time.Duration(7200);
        
        if(dataSource == 0 and Toybox.SensorHistory has :getBodyBatteryHistory) {
            iterator = Toybox.SensorHistory.getBodyBatteryHistory({:period => twoHours, :order => Toybox.SensorHistory.ORDER_OLDEST_FIRST});
            max = 100;
        } else if(dataSource == 1 and Toybox.SensorHistory has :getElevationHistory) {
            iterator = Toybox.SensorHistory.getElevationHistory({:period => twoHours, :order => Toybox.SensorHistory.ORDER_OLDEST_FIRST});
        } else if(dataSource == 2 and Toybox.SensorHistory has :getHeartRateHistory) {
            iterator = Toybox.SensorHistory.getHeartRateHistory({:period => twoHours, :order => Toybox.SensorHistory.ORDER_OLDEST_FIRST});
        } else if(dataSource == 3 and Toybox.SensorHistory has :getOxygenSaturationHistory) {
            iterator = Toybox.SensorHistory.getOxygenSaturationHistory({:period => twoHours, :order => Toybox.SensorHistory.ORDER_OLDEST_FIRST});
            max = 100;
        } else if(dataSource == 4 and Toybox.SensorHistory has :getPressureHistory) {
            iterator = Toybox.SensorHistory.getPressureHistory({:period => twoHours, :order => Toybox.SensorHistory.ORDER_OLDEST_FIRST});
        } else if((dataSource == 5 or dataSource == 7) and Toybox.SensorHistory has :getStressHistory) {
            iterator = Toybox.SensorHistory.getStressHistory({:period => twoHours, :order => Toybox.SensorHistory.ORDER_OLDEST_FIRST});
            max = 100;
        } else if(dataSource == 6 and Toybox.SensorHistory has :getTemperatureHistory) {
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
            return propTzName1.toUpper() + ":";
        }

        if(complicationType == 41) {
            return propTzName2.toUpper() + ":";
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
            case 71: return WatchUi.loadResource(Rez.Strings.LABEL_CGM) as String;
            case 72: return WatchUi.loadResource(Rez.Strings.LABEL_CGMAGE) as String;
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
                value = dayName(today.day_of_week) + ", " + today.day + " " + monthName(today.month) + " " + today.year;
                break;
            case 1: // ISO: 2024-03-14
                value = today.year + "-" + today.month.format("%02d") + "-" + today.day.format("%02d");
                break;
            case 2: // US: 03/14/2024
                value = today.month.format("%02d") + "/" + today.day.format("%02d") + "/" + today.year;
                break;
            case 3: // EU: 14.03.2024
                value = today.day.format("%02d") + "." + today.month.format("%02d") + "." + today.year;
                break;
            case 4: // THU, 14 MAR (Week number)
                value = dayName(today.day_of_week) + ", " + today.day + " " + monthName(today.month) + " (W" + isoWeekNumber(today.year, today.month, today.day) + ")";
                break;
            case 5: // THU, 14 MAR 2024 (Week number)
                value = dayName(today.day_of_week) + ", " + today.day + " " + monthName(today.month) + " " + today.year + " (W" + isoWeekNumber(today.year, today.month, today.day) + ")";
                break;
            case 6: // WEEKDAY, DD MONTH
                value = dayName(today.day_of_week) + ", " + today.day + " " + monthName(today.month);
                break;
            case 7: // WEEKDAY, YYYY-MM-DD
                value = dayName(today.day_of_week) + ", " + today.year + "-" + today.month.format("%02d") + "-" + today.day.format("%02d");
                break;
            case 8: // WEEKDAY, MM/DD/YYYY
                value = dayName(today.day_of_week) + ", " + today.month.format("%02d") + "/" + today.day.format("%02d") + "/" + today.year;
                break;
            case 9: // WEEKDAY, DD.MM.YYYY
                value = dayName(today.day_of_week) + ", " + today.day.format("%02d") + "." + today.month.format("%02d") + "." + today.year;
                break;
        }

        return value;
    }

    hidden function join(array as Array<String>) as String {
        var ret = "";
        for(var i=0; i<array.size(); i++) {
            if(array[i].length() == 0) {
                continue;
            }
            if(ret.length() == 0) {
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
        var value = utc.day.format("%02d") + utc.hour.format("%02d") + utc.min.format("%02d") + "Z" + monthName(utc.month) + utc.year.toString().substring(2,4);

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
            return distance < 9.9 ? distance.format("%.1f") : Math.round(distance).format("%d");
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
                    perp = " (" + weatherCondition.precipitationChance.format("%02d") + "%)";
                }
            }
        }

        var weatherStrings = [
            Rez.Strings.WEATHER_0, Rez.Strings.WEATHER_1, Rez.Strings.WEATHER_2, Rez.Strings.WEATHER_3,
            Rez.Strings.WEATHER_4, Rez.Strings.WEATHER_5, Rez.Strings.WEATHER_6, Rez.Strings.WEATHER_7,
            Rez.Strings.WEATHER_8, Rez.Strings.WEATHER_9, Rez.Strings.WEATHER_10, Rez.Strings.WEATHER_11,
            Rez.Strings.WEATHER_12, Rez.Strings.WEATHER_13, Rez.Strings.WEATHER_14, Rez.Strings.WEATHER_15,
            Rez.Strings.WEATHER_16, Rez.Strings.WEATHER_17, Rez.Strings.WEATHER_18, Rez.Strings.WEATHER_19,
            Rez.Strings.WEATHER_20, Rez.Strings.WEATHER_21, Rez.Strings.WEATHER_22, Rez.Strings.WEATHER_23,
            Rez.Strings.WEATHER_24, Rez.Strings.WEATHER_25, Rez.Strings.WEATHER_26, Rez.Strings.WEATHER_27,
            Rez.Strings.WEATHER_28, Rez.Strings.WEATHER_29, Rez.Strings.WEATHER_30, Rez.Strings.WEATHER_31,
            Rez.Strings.WEATHER_32, Rez.Strings.WEATHER_33, Rez.Strings.WEATHER_34, Rez.Strings.WEATHER_35,
            Rez.Strings.WEATHER_36, Rez.Strings.WEATHER_37, Rez.Strings.WEATHER_38, Rez.Strings.WEATHER_39,
            Rez.Strings.WEATHER_40, Rez.Strings.WEATHER_41, Rez.Strings.WEATHER_42, Rez.Strings.WEATHER_43,
            Rez.Strings.WEATHER_44, Rez.Strings.WEATHER_45, Rez.Strings.WEATHER_46, Rez.Strings.WEATHER_47,
            Rez.Strings.WEATHER_48, Rez.Strings.WEATHER_49, Rez.Strings.WEATHER_50, Rez.Strings.WEATHER_51,
            Rez.Strings.WEATHER_52, Rez.Strings.WEATHER_53
        ];
        var idx = weatherCondition.condition;
        if (idx < 0 || idx >= weatherStrings.size()) { idx = 53; }
        var ret = weatherStrings[idx];

        return Application.loadResource(ret) + perp;
    }

    hidden function getTemperature() as String {
        if(weatherCondition != null and weatherCondition.temperature != null) {
            var temp_unit = getTempUnit();
            var temp_val = weatherCondition.temperature;
            var temp = formatTemperature(temp_val, temp_unit).format("%01d");
            return temp + temp_unit;
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

        return bearing + windspeed;
    }

    hidden function getFeelsLike() as String {
        var fl = "";
        var tempUnit = getTempUnit();
        if(weatherCondition != null and weatherCondition.feelsLikeTemperature != null) {
            var fltemp = formatTemperatureFloat(weatherCondition.feelsLikeTemperature, tempUnit);
            var fllabel = Application.loadResource(Rez.Strings.LABEL_FL);
            fl = fllabel + fltemp.format("%d") + tempUnit;
        }

        return fl;
    }

    hidden function getHumidity() as String {
        var ret = "";
        if(weatherCondition != null and weatherCondition.relativeHumidity != null) {
            ret = weatherCondition.relativeHumidity.format("%d") + "%";
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
                ret = high.format("%d") + tempUnit + "/" + low.format("%d") + tempUnit;
            }
        }
        return ret;
    }

    hidden function getPrecip() as String {
        var ret = "";
        if(weatherCondition != null and weatherCondition.precipitationChance != null) {
            ret = weatherCondition.precipitationChance.format("%d") + "%";
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

    // CGM Connect Widget helper functions
    hidden function getCgmComplicationByLabel(targetLabel as String) as Complications.Id? {
        if (!hasComplications) { return null; }
        try {
            var iter = Complications.getComplications();
            if (iter == null) { return null; }
            var comp = iter.next();
            while (comp != null) {
                var compType = comp.getType();
                var compLabel = comp.shortLabel;
                if (compType == Complications.COMPLICATION_TYPE_INVALID && compLabel != null) {
                    if (compLabel.equals(targetLabel)) {
                        Complications.subscribeToUpdates(comp.complicationId);
                        return comp.complicationId;
                    }
                }
                comp = iter.next();
            }
        } catch (e) {}
        return null;
    }

    hidden function convertCgmTrendToArrow(trend as String) as String {
        if (trend.equals("R")) { return "a"; }  // Rapidly rising ↑
        if (trend.equals("r")) { return "b"; }  // Rising ↗
        if (trend.equals("n")) { return "c"; }  // Neutral →
        if (trend.equals("d")) { return "d"; }  // Falling ↘
        if (trend.equals("D")) { return "e"; }  // Rapidly falling ↓
        return "";
    }

    hidden function getCgmReading() as String {
        if (!hasComplications) { return ""; }
        try {
            if (cgmComplicationId == null) {
                cgmComplicationId = getCgmComplicationByLabel("CGM");
            }
            if (cgmComplicationId == null) { return ""; }

            var comp = Complications.getComplication(cgmComplicationId);
            if (comp == null || comp.value == null) { return ""; }

            var valueStr = comp.value.toString();
            if (valueStr.equals("---")) { return "---"; }

            var spaceIndex = valueStr.find(" ");
            if (spaceIndex == null) { return valueStr; }

            var reading = valueStr.substring(0, spaceIndex);
            var trend = valueStr.substring(spaceIndex + 1, valueStr.length());
            var arrow = convertCgmTrendToArrow(trend);
            return reading + arrow;
        } catch (e) {}
        return "";
    }

    hidden function getCgmAge() as String {
        if (!hasComplications) { return ""; }
        try {
            if (cgmAgeComplicationId == null) {
                cgmAgeComplicationId = getCgmComplicationByLabel("CGM Age");
            }
            if (cgmAgeComplicationId == null) { return ""; }
            var comp = Complications.getComplication(cgmAgeComplicationId);
            if (comp == null || comp.value == null) { return ""; }
            var timestamp = comp.value.toString().toLong();
            if (timestamp == null || timestamp < 0) { return "---"; }
            var ageMin = (Time.now().value() - timestamp) / 60;
            if (ageMin < 0) { return "---"; }
            return ageMin.format("%d");
        } catch (e) {}
        return "";
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
            val = hour.format("%02d") + min.format("%02d");
        } else {
            val = hour.format("%02d") + ":" + min.format("%02d");
        }
        return val;
    }

    hidden function dayName(day_of_week as Number) as String {
        if(weekNames == null) { init_week_month_names(); }
        return weekNames[day_of_week - 1];
    }

    hidden function monthName(month as Number) as String {
        if(monthNames == null) { init_week_month_names(); }
        return monthNames[month - 1];
    }

    hidden function init_week_month_names() as Void {
        weekNames = [Application.loadResource(Rez.Strings.DAY_OF_WEEK_SUN), Application.loadResource(Rez.Strings.DAY_OF_WEEK_MON),
                     Application.loadResource(Rez.Strings.DAY_OF_WEEK_TUE), Application.loadResource(Rez.Strings.DAY_OF_WEEK_WED),
                     Application.loadResource(Rez.Strings.DAY_OF_WEEK_THU), Application.loadResource(Rez.Strings.DAY_OF_WEEK_FRI),
                     Application.loadResource(Rez.Strings.DAY_OF_WEEK_SAT)];
        monthNames = [Application.loadResource(Rez.Strings.MONTH_JAN), Application.loadResource(Rez.Strings.MONTH_FEB), Application.loadResource(Rez.Strings.MONTH_MAR),
                      Application.loadResource(Rez.Strings.MONTH_APR), Application.loadResource(Rez.Strings.MONTH_MAY), Application.loadResource(Rez.Strings.MONTH_JUN),
                      Application.loadResource(Rez.Strings.MONTH_JUL), Application.loadResource(Rez.Strings.MONTH_AUG), Application.loadResource(Rez.Strings.MONTH_SEP),
                      Application.loadResource(Rez.Strings.MONTH_OCT), Application.loadResource(Rez.Strings.MONTH_NOV), Application.loadResource(Rez.Strings.MONTH_DEC)];
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

(:WeatherCache)
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