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

const INTEGER_FORMAT = "%d";

class Segment34View extends WatchUi.WatchFace {

    private var isSleeping = false;
    private var lastUpdate = null;
    private var canBurnIn = false;
    private var previousEssentialsVis = null;
    private var batt = 0;
    private var stress = 0;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        var clockTime = System.getClockTime();
        var now = Time.now().value();
        var updateEverything = false;

        if(lastUpdate == null or now - lastUpdate > 30 or clockTime.sec % 60 == 0) {
            updateEverything = true;
            canBurnIn = System.getDeviceSettings().requiresBurnInProtection;
        }

        toggleNonEssentials(!isSleeping, dc);

        if(!isSleeping && !updateEverything) {
            setSeconds(dc);
            setHR(dc);
            View.onUpdate(dc);
            drawStressAndBodyBattery(dc);
            return;
        }

        if(updateEverything) {
            setClock(dc);

            if(!isSleeping or !canBurnIn) {
                setNotif(dc);
                setMoon(dc);
                setWeather(dc);
                setWeatherLabel();
                setSunUpDown(dc);
                setDate(dc);
                setStep(dc);
                setTraining(dc);
                setBatt(dc);
                updateStressAndBodyBatteryData();
            }
            
            View.onUpdate(dc);

            if(!isSleeping or !canBurnIn) {
                drawStressAndBodyBattery(dc);
            }
            
            lastUpdate = now;
        }
    }

    function onPartialUpdate(dc) {
    }

    function onSettingsChanged() {
        lastUpdate = null;
        previousEssentialsVis = null;
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
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        isSleeping = true;
        lastUpdate = null;
        WatchUi.requestUpdate();
    }

    hidden function toggleNonEssentials(visible, dc){
        if(!visible and canBurnIn) {
            dc.setAntiAlias(false);

            var clockTime = System.getClockTime();
            var aodPattern = View.findDrawableById("aodPattern") as Drawable;
            var AODDateLabel = View.findDrawableById("AODDateLabel") as Text;
            (View.findDrawableById("gradient") as Text).setVisible(false);

            aodPattern.setVisible(true);
            AODDateLabel.setVisible(true);
            aodPattern.setLocation(clockTime.min % 2, aodPattern.locY);
            AODDateLabel.setLocation(Math.floor(dc.getWidth() / 2) - 1 + clockTime.min % 3, AODDateLabel.locY);
            AODDateLabel.setColor(getColor("dateDisplayDim"));
        }

        if(previousEssentialsVis == visible) {
            return;
        }

        var hideInAOD = (visible or !canBurnIn);

        (View.findDrawableById("SecondsLabel") as Text).setVisible(visible);
        (View.findDrawableById("HRLabel") as Text).setVisible(visible);

        (View.findDrawableById("DateLabel") as Text).setVisible(hideInAOD);
        (View.findDrawableById("TimeBg") as Text).setVisible(hideInAOD);
        (View.findDrawableById("TTRBg") as Text).setVisible(hideInAOD);
        (View.findDrawableById("HRBg") as Text).setVisible(hideInAOD);
        (View.findDrawableById("ActiveBg") as Text).setVisible(hideInAOD);
        (View.findDrawableById("TTRDesc") as Text).setVisible(hideInAOD);
        (View.findDrawableById("HRDesc") as Text).setVisible(hideInAOD);
        (View.findDrawableById("ActiveDesc") as Text).setVisible(hideInAOD);
        (View.findDrawableById("MoonLabel") as Text).setVisible(hideInAOD);
        (View.findDrawableById("Dusk") as Text).setVisible(hideInAOD);
        (View.findDrawableById("Dawn") as Text).setVisible(hideInAOD);
        (View.findDrawableById("SunUpLabel") as Text).setVisible(hideInAOD);
        (View.findDrawableById("SunDownLabel") as Text).setVisible(hideInAOD);
        (View.findDrawableById("WeatherLabel1") as Text).setVisible(hideInAOD);
        (View.findDrawableById("WeatherLabel2") as Text).setVisible(hideInAOD);
        (View.findDrawableById("NotifLabel") as Text).setVisible(hideInAOD);
        (View.findDrawableById("TTRLabel") as Text).setVisible(hideInAOD);
        (View.findDrawableById("ActiveLabel") as Text).setVisible(hideInAOD);
        (View.findDrawableById("WeatherLabel2") as Text).setVisible(hideInAOD);
        (View.findDrawableById("StepBg") as Text).setVisible(hideInAOD);
        (View.findDrawableById("StepLabel") as Text).setVisible(hideInAOD);
        (View.findDrawableById("BattLabel") as Text).setVisible(hideInAOD);
        (View.findDrawableById("BattBg") as Text).setVisible(hideInAOD);

        if(visible) {
            (View.findDrawableById("TimeBg") as Text).setColor(getColor("timeBg"));
            (View.findDrawableById("TTRBg") as Text).setColor(getColor("fieldBg"));
            (View.findDrawableById("HRBg") as Text).setColor(getColor("fieldBg"));
            (View.findDrawableById("ActiveBg") as Text).setColor(getColor("fieldBg"));
            (View.findDrawableById("StepBg") as Text).setColor(getColor("fieldBg"));
            (View.findDrawableById("TTRDesc") as Text).setColor(getColor("fieldLabel"));
            (View.findDrawableById("HRDesc") as Text).setColor(getColor("fieldLabel"));
            (View.findDrawableById("ActiveDesc") as Text).setColor(getColor("fieldLabel"));
            (View.findDrawableById("TimeLabel") as Text).setColor(getColor("timeDisplay"));
            (View.findDrawableById("DateLabel") as Text).setColor(getColor("dateDisplay"));
            (View.findDrawableById("SecondsLabel") as Text).setColor(getColor("dateDisplay"));
            (View.findDrawableById("NotifLabel") as Text).setColor(getColor("notifications"));
            (View.findDrawableById("MoonLabel") as Text).setColor(Graphics.COLOR_WHITE);
            (View.findDrawableById("Dusk") as Text).setColor(getColor("dawnDuskLabel"));
            (View.findDrawableById("Dawn") as Text).setColor(getColor("dawnDuskLabel"));
            (View.findDrawableById("SunUpLabel") as Text).setColor(getColor("dawnDuskValue"));
            (View.findDrawableById("SunDownLabel") as Text).setColor(getColor("dawnDuskValue"));
            (View.findDrawableById("WeatherLabel1") as Text).setColor(Graphics.COLOR_WHITE);
            (View.findDrawableById("WeatherLabel2") as Text).setColor(Graphics.COLOR_WHITE);
            (View.findDrawableById("TTRLabel") as Text).setColor(Graphics.COLOR_WHITE);
            (View.findDrawableById("ActiveLabel") as Text).setColor(Graphics.COLOR_WHITE);
            (View.findDrawableById("StepLabel") as Text).setColor(Graphics.COLOR_WHITE);
            (View.findDrawableById("BattBg") as Text).setColor(0x555555);
            (View.findDrawableById("BattLabel") as Text).setColor(Graphics.COLOR_WHITE);

            if(canBurnIn) {
                (View.findDrawableById("aodPattern") as Text).setVisible(false);
                (View.findDrawableById("AODDateLabel") as Text).setVisible(false);
                (View.findDrawableById("gradient") as Text).setVisible(true);
            }
        }

        previousEssentialsVis = visible;
    }
    
    hidden function getColor(colorName) as Graphics.ColorType {
        var amoled = System.getDeviceSettings().requiresBurnInProtection;
        var colorTheme = Application.Properties.getValue("colorTheme");

        if(colorTheme == 0) {
            switch(colorName) {
                case "fieldBg":
                    if(amoled) {
                        return 0x0e333c;
                    }
                    return 0x005555;
                case "fieldLabel":
                    return 0x55AAAA;
                case "timeBg":
                    if(amoled) {
                        return 0x0d333c;
                    }
                    return 0x005555;
                case "timeDisplay":
                case "dateDisplay":
                    if(amoled) {
                        return 0xfbcb77;
                    }
                    return 0xFFFF00;
                case "dateDisplayDim":
                    return 0xa98753;
                case "dawnDuskLabel":
                    return 0x005555;
                case "dawnDuskValue":
                    if(amoled) {
                        return 0xFFFFFF;
                    }
                    return 0xAAAAAA;
                case "notifications":
                    return 0x00AAFF;
                case "stress":
                    return 0xFFAA00;
                case "bodybattery":
                    return 0x00AAFF;
                case "HRActive":
                    return 0xFFFFFF;
                case "HRInactive":
                    return 0x55AAAA;
            }
        } else if(colorTheme == 1) {
            switch(colorName) {
                case "fieldBg":
                    if(amoled) {
                        return 0x0e333c;
                    }
                    return 0x005555;
                case "fieldLabel":
                    return 0xAA55AA;
                case "timeBg":
                    if(amoled) {
                        return 0x0f3b46;
                    }
                    return 0x005555;
                case "timeDisplay":
                    if(amoled) {
                        return 0xf988f2;
                    }
                    return 0xFF55AA;
                case "dateDisplay":
                    return 0xFFFFFF;
                case "dateDisplayDim":
                    return 0xa95399;
                case "dawnDuskLabel":
                    return 0xAA55AA;
                case "dawnDuskValue":
                    if(amoled) {
                        return 0xFFFFFF;
                    }
                    return 0xAAAAAA;
                case "notifications":
                    return 0xFF55AA;
                case "stress":
                    return 0xFF55AA;
                case "bodybattery":
                    return 0x00FFAA;
                case "HRActive":
                    return 0xFFFFFF;
                case "HRInactive":
                    return 0x55AAAA;
            }
        } else if(colorTheme == 2) {
            switch(colorName) {
                case "fieldBg":
                    if(amoled) {
                        return 0x0f2246;
                    }
                    return 0x0055AA;
                case "fieldLabel":
                    return 0x55AAAA;
                case "timeBg":
                    if(amoled) {
                        return 0x0f2246;
                    }
                    return 0x0055AA;
                case "timeDisplay":
                case "dateDisplay":
                    if(amoled) {
                        return 0x89efd2;
                    }
                    return 0x00FFFF;
                case "dateDisplayDim":
                    return 0x5ca28f;
                case "dawnDuskLabel":
                    return 0x005555;
                case "dawnDuskValue":
                    if(amoled) {
                        return 0xFFFFFF;
                    }
                    return 0xAAAAAA;
                case "notifications":
                    return 0x00AAFF;
                case "stress":
                    return 0x00FFAA;
                case "bodybattery":
                    return 0x00AAFF;
                case "HRActive":
                    return 0xFFFFFF;
                case "HRInactive":
                    return 0x55AAAA;
            }
        } else if(colorTheme == 3) {
            switch(colorName) {
                case "fieldBg":
                    if(amoled) {
                        return 0x0d3c12;
                    }
                    return 0x005500;
                case "fieldLabel":
                    return 0x00AA55;
                case "timeBg":
                    if(amoled) {
                        return 0x0d3c12;
                    }
                    return 0x005500;
                case "timeDisplay":
                case "dateDisplay":
                    if(amoled) {
                        return 0x46d102;
                    }
                    return 0x00FF00;
                case "dateDisplayDim":
                    return 0x5ca28f;
                case "dawnDuskLabel":
                    return 0x00AA55;
                case "dawnDuskValue":
                    if(amoled) {
                        return 0xFFFFFF;
                    }
                    return 0xAAAAAA;
                case "notifications":
                    return 0x00AAFF;
                case "stress":
                    return 0x55FF00;
                case "bodybattery":
                    return 0x00AAFF;
                case "HRActive":
                    return 0xFFFFFF;
                case "HRInactive":
                    return 0x55FF55;
            }
        } else if (colorTheme == 4) {
             switch(colorName) {
                case "fieldBg":
                    if(amoled) {
                        return 0x0e333c;
                    }
                    return 0x005555;
                case "fieldLabel":
                    return 0x55AAAA;
                case "timeBg":
                    if(amoled) {
                        return 0x0d333c;
                    }
                    return 0x005555;
                case "timeDisplay":
                case "dateDisplay":
                    return 0xFFFFFF;
                case "dateDisplayDim":
                    return 0xa98753;
                case "dawnDuskLabel":
                    return 0x005555;
                case "dawnDuskValue":
                    if(amoled) {
                        return 0xFFFFFF;
                    }
                    return 0xAAAAAA;
                case "notifications":
                    return 0xAAAAAA;
                case "stress":
                    return 0xFFFFFF;
                case "bodybattery":
                    return 0xAAAAAA;
                case "HRActive":
                    return 0xFFFFFF;
                case "HRInactive":
                    return 0x55AAAA;
            }
        }

        return Graphics.COLOR_WHITE;
    }

    hidden function setSeconds(dc) as Void {
        var secLabel = View.findDrawableById("SecondsLabel") as Text;
        var showSeconds = Application.Properties.getValue("showSeconds");

        if(showSeconds) {
            var clockTime = System.getClockTime();
            var secString = Lang.format("$1$", [clockTime.sec.format("%02d")]);
            secLabel.setText(secString);
        } else {
            secLabel.setText("");
        }
    }

    hidden function setClock(dc) as Void {
        var clockTime = System.getClockTime();
        var hour = formatHour(clockTime.hour);

        var timeString = Lang.format("$1$:$2$", [hour.format("%02d"), clockTime.min.format("%02d")]);
        var timelabel = View.findDrawableById("TimeLabel") as Text;
        timelabel.setText(timeString);
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
        var now = Time.now();
        var today = Time.Gregorian.info(now, Time.FORMAT_SHORT);
        var moonVal = moon_phase(today);
        var moonLabel = View.findDrawableById("MoonLabel") as Text;
        moonLabel.setText(moonVal);
    }
    
    hidden function setHR(dc) as Void {
        var hrLabel = View.findDrawableById("HRLabel") as Text;
        var hrDesc = View.findDrawableById("HRDesc") as Text;
        var middleValueShows = Application.Properties.getValue("middleValueShows");

        if(middleValueShows == 10) {
            hrDesc.setText("HEART RATE:");

            // Try to retrieve live HR from Activity::Info
            var activityInfo = Activity.getActivityInfo();
            var sample = activityInfo.currentHeartRate;
            if(sample != null) {
                hrLabel.setText(sample.format("%01d"));
                hrLabel.setColor(getColor("HRActive"));
            } else if (ActivityMonitor has :getHeartRateHistory) {
                // Falling back to historical HR from ActivityMonitor
                var hist = ActivityMonitor.getHeartRateHistory(1, /* newestFirst */ true).next();
                if ((hist != null) && (hist.heartRate != ActivityMonitor.INVALID_HR_SAMPLE)) {
                    hrLabel.setText(hist.heartRate.format("%01d"));
                    hrLabel.setColor(getColor("HRInactive"));
                }
            }
        } else {
            hrDesc.setText(getComplicationDesc(middleValueShows));
            hrLabel.setText(getComplicationValue(middleValueShows));

            hrLabel.setColor(Graphics.COLOR_WHITE);
            if(isSleeping and canBurnIn) {
                hrLabel.setColor(Graphics.COLOR_DK_GRAY);
            }
        }

        hrLabel.draw(dc);
    }

    hidden function setBatt(dc) as Void {
        var battLabel = View.findDrawableById("BattLabel") as Text;
        var battBg = View.findDrawableById("BattBg") as Text;
        var sample = System.getSystemStats().battery;
        var value = "";
        var batteryVariant = Application.Properties.getValue("batteryVariant");
        var visible = (!isSleeping or !canBurnIn);

        if(batteryVariant == 0) {
            if(System.getSystemStats() has :batteryInDays) {
                if (System.getSystemStats().batteryInDays != null){
                    sample = System.getSystemStats().batteryInDays;
                    value = Lang.format("$1$D", [sample.format("%d")]);
                }
            } else {
                batteryVariant = 1;
            }
        }
        if(batteryVariant == 1) {
            if(sample < 100) {
                value = Lang.format("$1$%", [sample.format("%d")]);
            } else {
                value = Lang.format("$1$", [sample.format("%d")]);
            }
        } else if(batteryVariant == 2) {
            visible = false;
        }

        battBg.setVisible(visible);
        battLabel.setText(value);
    }

    hidden function setWeather(dc) as Void {
        var weather = Weather.getCurrentConditions();
        var tempUnitSetting = System.getDeviceSettings().temperatureUnits;
        var tempUnitAppSetting = Application.Properties.getValue("tempUnit");
        var temp = "";
        var tempUnit = "";
        var windspeed = "";
        var bearing = "";
        var fl = "";
        var weatherText = "";
        if (weather == null) { return; }
        if (weather.condition == null) { return; }

        if(weather.temperature != null) {
            var tempVal = weather.temperature;

            if((tempUnitSetting == System.UNIT_METRIC and tempUnitAppSetting == 0) or tempUnitAppSetting == 1) {
                temp = tempVal.format("%01d");
                tempUnit = "C";
            } else {
                temp = ((tempVal * 9/5) + 32).format("%01d");
                tempUnit = "F";
            }
            weatherText = Lang.format("$1$$2$", [temp, tempUnit]);
        }
        
        if(weather.windSpeed != null) {
            var windUnit = Application.Properties.getValue("windUnit");
            var windspeed_mps = weather.windSpeed;
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

        if(weather.windBearing != null) {
            bearing = ((Math.round((weather.windBearing.toFloat() + 180) / 45.0).toNumber() % 8) + 97).toChar().toString();
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
            if(weather.feelsLikeTemperature != null) {
                var fltemp = weather.feelsLikeTemperature;
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
        
        var weatherLabel = View.findDrawableById("WeatherLabel1") as Text;
        weatherLabel.setText(weatherText);
    }

    hidden function setWeatherLabel() as Void {
        var weatherLabel = View.findDrawableById("WeatherLabel2") as Text;
        var weatherLine2Shows = Application.Properties.getValue("weatherLine2Shows");
        var unit = getComplicationUnit(weatherLine2Shows);
        if (unit.length() > 0) {
            unit = Lang.format(" $1$", [unit]);
        }
        weatherLabel.setText(Lang.format("$1$$2$", [getComplicationValue(weatherLine2Shows), unit]));
    }

    hidden function getWeatherCondition() as String {
        var weather = Weather.getCurrentConditions();
        var condition;
        var perp = "";
        if (weather == null) { return ""; }
        if(weather.condition == null) { return ""; }

        if(weather has :precipitationChance) {
            if(weather.precipitationChance != null) {
             perp = Lang.format(" ($1$%)", [weather.precipitationChance.format("%02d")]);
            }
        }

        switch(weather.condition) {
            case Weather.CONDITION_CLEAR:
                condition = "CLEAR";
                break;
            case Weather.CONDITION_PARTLY_CLOUDY:
                condition = "PARTLY CLOUDY";
                break;
            case Weather.CONDITION_MOSTLY_CLOUDY:
                condition = "MOSTLY CLOUDY";
                break;
            case Weather.CONDITION_RAIN:
                condition = "RAIN" + perp;
                break;
            case Weather.CONDITION_SNOW:
                condition = "SNOW" + perp;
                break;
            case Weather.CONDITION_WINDY:
                condition = "WINDY";
                break;
            case Weather.CONDITION_THUNDERSTORMS:
                condition = "THUNDERSTORMS";
                break;
            case Weather.CONDITION_WINTRY_MIX:
                condition = "WINTRY MIX";
                break;
            case Weather.CONDITION_FOG:
                condition = "FOG";
                break;
            case Weather.CONDITION_HAZY:
                condition = "HAZY";
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
                condition = "CLOUDY";
                break;
            case Weather.CONDITION_RAIN_SNOW:
                condition = "RAIN & SNOW" + perp;
                break;
            case Weather.CONDITION_PARTLY_CLEAR:
                condition = "PARTLY CLEAR";
                break;
            case Weather.CONDITION_MOSTLY_CLEAR:
                condition = "MOSTLY CLEAR";
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
                condition = "MIST";
                break;
            case Weather.CONDITION_DUST:
                condition = "DUST";
                break;
            case Weather.CONDITION_DRIZZLE:
                condition = "DRIZZLE";
                break;
            case Weather.CONDITION_TORNADO:
                condition = "TORNADO";
                break;
            case Weather.CONDITION_SMOKE:
                condition = "SMOKE";
                break;
            case Weather.CONDITION_ICE:
                condition = "ICE";
                break;
            case Weather.CONDITION_SAND:
                condition = "SAND";
                break;
            case Weather.CONDITION_SQUALL:
                condition = "SQUALL";
                break;
            case Weather.CONDITION_SANDSTORM:
                condition = "SANDSTORM";
                break;
            case Weather.CONDITION_VOLCANIC_ASH:
                condition = "VOLCANIC ASH";
                break;
            case Weather.CONDITION_HAZE:
                condition = "HAZE";
                break;
            case Weather.CONDITION_FAIR:
                condition = "FAIR";
                break;
            case Weather.CONDITION_HURRICANE:
                condition = "HURRICANE";
                break;
            case Weather.CONDITION_TROPICAL_STORM:
                condition = "TROPICAL STORM";
                break;
            case Weather.CONDITION_CHANCE_OF_SNOW:
                condition = "CHC OF SNOW";
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
                condition = "FLURRIES";
                break;
            case Weather.CONDITION_FREEZING_RAIN:
                condition = "FREEZING RAIN" + perp;
                break;
            case Weather.CONDITION_SLEET:
                condition = "SLEET" + perp;
                break;
            case Weather.CONDITION_ICE_SNOW:
                condition = "ICE & SNOW";
                break;
            case Weather.CONDITION_THIN_CLOUDS:
                condition = "THIN CLOUDS";
                break;
            default:
                condition = "UNKNOWN";
        }

        return condition;
    }

    hidden function setSunUpDown(dc) as Void {
        var weather = Weather.getCurrentConditions();
        var sunUpLabel = View.findDrawableById("SunUpLabel") as Text;
        var sunDownLabel = View.findDrawableById("SunDownLabel") as Text;
        var dawnLabel = View.findDrawableById("Dawn") as Text;
        var duskLabel = View.findDrawableById("Dusk") as Text;
        var now = Time.now();
        if(weather == null) {
            dawnLabel.setText("");
            duskLabel.setText("");
            return;
        }
        var loc = weather.observationLocationPosition;
        if(loc == null) {
            dawnLabel.setText("");
            duskLabel.setText("");
            return;
        }
        dawnLabel.setText("DAWN:");
        duskLabel.setText("DUSK:");
        var sunrise = Time.Gregorian.info(Weather.getSunrise(loc, now), Time.FORMAT_SHORT);
        var sunset = Time.Gregorian.info(Weather.getSunset(loc, now), Time.FORMAT_SHORT);
        var sunriseHour = formatHour(sunrise.hour);
        var sunsetHour = formatHour(sunset.hour);
        sunUpLabel.setText(Lang.format("$1$:$2$", [sunriseHour.format("%02d"), sunrise.min.format("%02d")]));
        sunDownLabel.setText(Lang.format("$1$:$2$", [sunsetHour.format("%02d"), sunset.min.format("%02d")]));
    }

    hidden function setNotif(dc) as Void {
        var value = "";
        var notifLabel = View.findDrawableById("NotifLabel") as Text;

        var showNotificationCount = Application.Properties.getValue("showNotificationCount");
        if(showNotificationCount) {
            var sample = System.getDeviceSettings().notificationCount;
            if(sample > 0) {
                value = sample.format("%01d");
            }

            notifLabel.setText(value);
        } else {
            notifLabel.setText("");
        }
    }

    hidden function setDate(dc) as Void {
        var dateLabel = View.findDrawableById("DateLabel") as Text;
        var now = Time.now();
        var today = Time.Gregorian.info(now, Time.FORMAT_SHORT);

        var value = Lang.format("$1$, $2$ $3$ $4$" , [
            day_name(today.day_of_week),
            today.day,
            month_name(today.month),
            today.year
        ]).toUpper();
        dateLabel.setText(value);

        if(canBurnIn) {
            var AODDateLabel = View.findDrawableById("AODDateLabel") as Text;
            AODDateLabel.setText(value);
        }
        
    }

    hidden function setStep(dc) as Void {
        var stepLabel = View.findDrawableById("StepLabel") as Text;
        var bottomFieldShows = Application.Properties.getValue("bottomFieldShows");
        stepLabel.setText(getComplicationValue(bottomFieldShows));
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

            if(dc.getHeight() == 260) {
                barTop = 77;
                fromEdge = 10;
                barWidth = 3;
                barHeight = 80;
                bbAdjustment = 1;
            }
            if(dc.getHeight() == 280) {
                barTop = 83;
                fromEdge = 14;
                barWidth = 3;
                barHeight = 80;
                bbAdjustment = -1;
            }
            if(dc.getHeight() == 360) {
                barTop = 103;
                fromEdge = 3;
                barWidth = 3;
                barHeight = 125;
                bbAdjustment = -1;
                if(isSleeping) {
                    fromEdge = 0;
                }
            }
            if(dc.getHeight() == 390) {
                barTop = 111;
                fromEdge = 8;
                barWidth = 4;
                barHeight = 125;
                bbAdjustment = 0;
                if(isSleeping) {
                    fromEdge = 4;
                }
            }
            if(dc.getHeight() == 416) {
                barTop = 122;
                fromEdge = 15;
                barWidth = 4;
                barHeight = 125;
                bbAdjustment = 0;
                if(isSleeping) {
                    fromEdge = 10;
                }
            }
            if(dc.getHeight() == 454) {
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
        var TTRDesc = View.findDrawableById("TTRDesc") as Text;
        var TTRLabel = View.findDrawableById("TTRLabel") as Text;
        var leftValueShows = Application.Properties.getValue("leftValueShows");
        TTRDesc.setText(getComplicationDesc(leftValueShows));
        TTRLabel.setText(getComplicationValue(leftValueShows));
        
        var ActiveDesc = View.findDrawableById("ActiveDesc") as Text;
        var ActiveLabel = View.findDrawableById("ActiveLabel") as Text;
        var rightValueShows = Application.Properties.getValue("rightValueShows");
        ActiveDesc.setText(getComplicationDesc(rightValueShows));
        ActiveLabel.setText(getComplicationValue(rightValueShows));
    }

    function getComplicationValue(complicationType) as String {
        var val = "";

        if(complicationType == 0) { // Active min / week
            if(ActivityMonitor.getInfo() has :activeMinutesWeek) {
                if(ActivityMonitor.getInfo().activeMinutesWeek != null) {
                    val = ActivityMonitor.getInfo().activeMinutesWeek.total.format("%01d");
                }
            }
        } else if(complicationType == 1) { // Active min / day
            if(ActivityMonitor.getInfo() has :activeMinutesWeek) {
                if(ActivityMonitor.getInfo().activeMinutesDay != null) {
                    val = ActivityMonitor.getInfo().activeMinutesDay.total.format("%01d");
                }
            }
        } else if(complicationType == 2) { // distance (km) / day
            if(ActivityMonitor.getInfo() has :distance) {
                if(ActivityMonitor.getInfo().distance != null) {
                    val = (ActivityMonitor.getInfo().distance / 100000).format("%01d");
                }
            }
        } else if(complicationType == 3) { // distance (miles) / day
            if(ActivityMonitor.getInfo() has :distance) {
                if(ActivityMonitor.getInfo().distance != null) {
                    val = (ActivityMonitor.getInfo().distance / 160900).format("%01d");
                }
            }
        } else if(complicationType == 4) { // floors climbed / day
            if(ActivityMonitor.getInfo() has :floorsClimbed) {
                if(ActivityMonitor.getInfo().floorsClimbed != null) {
                    val = ActivityMonitor.getInfo().floorsClimbed.format("%01d");
                }
            }
        } else if(complicationType == 5) { // meters climbed / day
            if(ActivityMonitor.getInfo() has :metersClimbed) {
                if(ActivityMonitor.getInfo().metersClimbed != null) {
                    val = ActivityMonitor.getInfo().metersClimbed.format("%01d");
                }
            }
        } else if(complicationType == 6) { // Time to Recovery (h)
            if(ActivityMonitor.getInfo() has :timeToRecovery) {
                if(ActivityMonitor.getInfo().timeToRecovery != null) {
                    val = ActivityMonitor.getInfo().timeToRecovery.format("%01d");
                }
            }
        } else if(complicationType == 7) { // VO2 Max Running
            var profile = UserProfile.getProfile();
            if(profile has :vo2maxRunning) {
                if(profile.vo2maxRunning != null) {
                    val = profile.vo2maxRunning.format("%01d");
                }
            }
        } else if(complicationType == 8) { // VO2 Max Cycling
            var profile = UserProfile.getProfile();
            if(profile has :vo2maxCycling) {
                if(profile.vo2maxCycling != null) {
                    val = profile.vo2maxCycling.format("%01d");
                }
            }
        } else if(complicationType == 9) { // Respiration rate
            if(ActivityMonitor.getInfo() has :respirationRate) {
                if(ActivityMonitor.getInfo().respirationRate != null) {
                    val = ActivityMonitor.getInfo().respirationRate.format("%01d");
                }
            }
        } else if(complicationType == 11) { // Calories
            if(ActivityMonitor.getInfo() has :calories) {
                if(ActivityMonitor.getInfo().calories != null) {
                    val = ActivityMonitor.getInfo().calories.format("%01d");
                }
            }
        } else if(complicationType == 12) { // Altitude (m)
            if ((Toybox has :SensorHistory) and (Toybox.SensorHistory has :getElevationHistory)) {
                var elvIterator = Toybox.SensorHistory.getElevationHistory({:period => 1});
                var elv = elvIterator.next();
                if(elv != null and elv.data != null) {
                    val = elv.data.format("%01d");
                }
            }
        } else if(complicationType == 13) { // Stress
            if(ActivityMonitor.getInfo() has :stressScore) {
                if(ActivityMonitor.getInfo().stressScore != null) {
                    val = ActivityMonitor.getInfo().stressScore.format("%01d");
                }
            }
        } else if(complicationType == 14) { // Body battery
            if ((Toybox has :SensorHistory) and (Toybox.SensorHistory has :getBodyBatteryHistory)) {
                var bbIterator = Toybox.SensorHistory.getBodyBatteryHistory({:period => 1});
                var bb = bbIterator.next();
                if(bb != null and bb.data != null) {
                    val = bb.data.format("%01d");
                }
            }
        } else if(complicationType == 15) { // Altitude (ft)
            if ((Toybox has :SensorHistory) and (Toybox.SensorHistory has :getElevationHistory)) {
                var elvIterator = Toybox.SensorHistory.getElevationHistory({:period => 1});
                var elv = elvIterator.next();
                if(elv != null and elv.data != null) {
                    val = (elv.data * 3.28084).format("%01d");
                }
            }
        } else if(complicationType == 16) { // UTC time
            var now = Time.now();
            var utc = Time.Gregorian.utcInfo(now, Time.FORMAT_MEDIUM);
            val = Lang.format("$1$$2$", [utc.hour.format("%02d"), utc.min.format("%02d")]);
        } else if(complicationType == 17) { // Steps / day
            if(ActivityMonitor.getInfo().steps != null) {
                val = ActivityMonitor.getInfo().steps.format("%05d");
            }
        } else if(complicationType == 18) { // Distance (m) / day
            if(ActivityMonitor.getInfo().distance != null) {
                val = (ActivityMonitor.getInfo().distance / 100).format("%05d");
            }
        } else if(complicationType == 19) { // Wheelchair pushes
            if(ActivityMonitor.getInfo() has :pushes) {
                if(ActivityMonitor.getInfo().pushes != null) {
                    val = ActivityMonitor.getInfo().pushes.format("%05d");
                } 
            }  
        } else if(complicationType == 20) { // Weather condition
            val = getWeatherCondition();
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
        }
        return unit;
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

}
