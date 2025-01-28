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
    private var dimOnSleep = false;
    private var previousEssentialsVis = null;

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

        var canBurnIn=System.getDeviceSettings().requiresBurnInProtection;
        if(canBurnIn) {
            dimOnSleep = true;
        }
        if(isSleeping and canBurnIn) {
            toggleNonEssentials(false, dc);
        }
        if(!isSleeping and canBurnIn) {
            toggleNonEssentials(true, dc);
        }

        setSeconds(dc);

        if(isSleeping) {
            if(clockTime.sec % 30 == 0) {
                setHR(dc);
                setNotif(dc);
            }
        } else {
            if(clockTime.sec % 2 == 0) {
                setHR(dc);
                setNotif(dc);
            }
        }

        if(lastUpdate != null && now - lastUpdate < 30 && clockTime.sec % 60 != 0) {
            if(!isSleeping) {
                View.onUpdate(dc);
                setStressAndBodyBattery(dc);
            }
            return;
        }

        setClock(dc);
        setMoon(dc);
        setWeather(dc);
        setWeatherLabel();
        setSunUpDown(dc);
        setDate(dc);
        setStep(dc);
        setTraining(dc);
        setBatt(dc);

        View.onUpdate(dc);
        setStressAndBodyBattery(dc);
        
        lastUpdate = now;
    }

    function onPartialUpdate(dc) {
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
        if(previousEssentialsVis == visible) {
            return;
        }

        (View.findDrawableById("TimeBg") as Text).setVisible(visible);
        (View.findDrawableById("TTRBg") as Text).setVisible(visible);
        (View.findDrawableById("HRBg") as Text).setVisible(visible);
        (View.findDrawableById("ActiveBg") as Text).setVisible(visible);
        (View.findDrawableById("StepBg") as Text).setVisible(visible);
        (View.findDrawableById("SecondsLabel") as Text).setVisible(visible);

        if(visible) {
            (View.findDrawableById("TTRDesc") as Text).setColor(0x55AAAA);
            (View.findDrawableById("HRDesc") as Text).setColor(0x55AAAA);
            (View.findDrawableById("ActiveDesc") as Text).setColor(0x55AAAA);

            (View.findDrawableById("TimeLabel") as Text).setColor(0xfbcb77);
            (View.findDrawableById("DateLabel") as Text).setColor(0xfbcb77);
            (View.findDrawableById("NotifLabel") as Text).setColor(0x00AAFF);
            (View.findDrawableById("MoonLabel") as Text).setColor(Graphics.COLOR_WHITE);
            (View.findDrawableById("Dusk") as Text).setColor(0x005555);
            (View.findDrawableById("Dawn") as Text).setColor(0x005555);
            (View.findDrawableById("SunUpLabel") as Text).setColor(0xAAAAAA);
            (View.findDrawableById("SunDownLabel") as Text).setColor(0xAAAAAA);
            (View.findDrawableById("WeatherLabel1") as Text).setColor(Graphics.COLOR_WHITE);
            (View.findDrawableById("WeatherLabel2") as Text).setColor(Graphics.COLOR_WHITE);
            (View.findDrawableById("TTRLabel") as Text).setColor(Graphics.COLOR_WHITE);
            (View.findDrawableById("ActiveLabel") as Text).setColor(Graphics.COLOR_WHITE);
            (View.findDrawableById("StepLabel") as Text).setColor(Graphics.COLOR_WHITE);

            (View.findDrawableById("BattBg") as Text).setColor(0xAAAAAA);
            (View.findDrawableById("BattLabel") as Text).setColor(Graphics.COLOR_WHITE);
        } else {
            var gradient = View.findDrawableById("gradient") as Drawable;
            var basey = 110;
            if(dc.getHeight() == 454) {
                basey = 145;
            }
            gradient.setLocation(Math.rand() % 10, basey - Math.rand() % 10);
            (View.findDrawableById("TTRDesc") as Text).setColor(0x0e333c);
            (View.findDrawableById("HRDesc") as Text).setColor(0x0e333c);
            (View.findDrawableById("ActiveDesc") as Text).setColor(0x0e333c);

            (View.findDrawableById("TimeLabel") as Text).setColor(0xa98753);
            (View.findDrawableById("DateLabel") as Text).setColor(0xa98753);
            (View.findDrawableById("NotifLabel") as Text).setColor(0x0567a1);
            (View.findDrawableById("MoonLabel") as Text).setColor(Graphics.COLOR_DK_GRAY);
            (View.findDrawableById("Dusk") as Text).setColor(0x0e333c);
            (View.findDrawableById("Dawn") as Text).setColor(0x0e333c);
            (View.findDrawableById("SunUpLabel") as Text).setColor(Graphics.COLOR_DK_GRAY);
            (View.findDrawableById("SunDownLabel") as Text).setColor(Graphics.COLOR_DK_GRAY);
            (View.findDrawableById("WeatherLabel1") as Text).setColor(Graphics.COLOR_DK_GRAY);
            (View.findDrawableById("WeatherLabel2") as Text).setColor(Graphics.COLOR_DK_GRAY);
            (View.findDrawableById("TTRLabel") as Text).setColor(Graphics.COLOR_DK_GRAY);
            (View.findDrawableById("HRLabel") as Text).setColor(Graphics.COLOR_DK_GRAY);
            (View.findDrawableById("ActiveLabel") as Text).setColor(Graphics.COLOR_DK_GRAY);
            (View.findDrawableById("StepLabel") as Text).setColor(Graphics.COLOR_DK_GRAY);

            (View.findDrawableById("BattBg") as Text).setColor(0x555555);
            (View.findDrawableById("BattLabel") as Text).setColor(0x777777);
        }

        previousEssentialsVis = visible;
    }
    
    hidden function setSeconds(dc) as Void {
        var secLabel = View.findDrawableById("SecondsLabel") as Text;
        var showSeconds = Application.Properties.getValue("showSeconds");
        if(isSleeping and lastUpdate == null) {
            secLabel.setText("");
        } else {
            if(showSeconds) {
                var clockTime = System.getClockTime();
                var secString = Lang.format("$1$", [clockTime.sec.format("%02d")]);
                secLabel.setText(secString);
            }
        }
    }

    hidden function setClock(dc) as Void {
        var clockTime = System.getClockTime();
        var hour = clockTime.hour;
        if(!System.getDeviceSettings().is24Hour) {
            hour = hour % 12;
            if(hour == 0) { hour = 12; }
        }
        var timeString = Lang.format("$1$:$2$", [hour.format("%02d"), clockTime.min.format("%02d")]);
        var timelabel = View.findDrawableById("TimeLabel") as Text;
        timelabel.setText(timeString);
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
                hrLabel.setColor(Graphics.COLOR_WHITE);
                if(isSleeping and dimOnSleep) {
                    hrLabel.setColor(Graphics.COLOR_DK_GRAY);
                }
            } else if (ActivityMonitor has :getHeartRateHistory) {
                // Falling back to historical HR from ActivityMonitor
                var hist = ActivityMonitor.getHeartRateHistory(1, /* newestFirst */ true).next();
                if ((hist != null) && (hist.heartRate != ActivityMonitor.INVALID_HR_SAMPLE)) {
                    hrLabel.setText(hist.heartRate.format("%01d"));
                    hrLabel.setColor(0x55AAAA);
                    if(isSleeping and dimOnSleep) {
                        hrLabel.setColor(Graphics.COLOR_DK_GRAY);
                    }
                }
            }
        } else {
            hrDesc.setText(getComplicationDesc(middleValueShows));
            hrLabel.setText(getComplicationValue(middleValueShows));

            hrLabel.setColor(Graphics.COLOR_WHITE);
            if(isSleeping and dimOnSleep) {
                hrLabel.setColor(Graphics.COLOR_DK_GRAY);
            }
        }

        hrLabel.draw(dc);
    }

    hidden function setBatt(dc) as Void {
        var battLabel = View.findDrawableById("BattLabel") as Text;
        var sample = System.getSystemStats().battery;
        var value = Lang.format("$1$", [sample.format("%03d")]);
        if(System.getSystemStats() has :batteryInDays) {
            if (System.getSystemStats().batteryInDays != null and System.getSystemStats().batteryInDays != 0){
                sample = System.getSystemStats().batteryInDays;
                value = Lang.format("$1$D", [sample.format("%01d")]);
            }
        }
        
        battLabel.setText(value);
    }

    hidden function setWeather(dc) as Void {
        var weather = Weather.getCurrentConditions();
        var tempUnitSetting = System.getDeviceSettings().temperatureUnits;
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

            if(tempUnitSetting == System.UNIT_METRIC) {
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
                if(tempUnitSetting != System.UNIT_METRIC) {
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
        var weather = Weather.getCurrentConditions();
        var condition;
        var perp = "";
        if (weather == null) { return; }
        if(weather.condition == null) { return; }

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
        
        var weatherLabel = View.findDrawableById("WeatherLabel2") as Text;
        weatherLabel.setText(condition);
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
        sunUpLabel.setText(Lang.format("$1$:$2$", [sunrise.hour.format("%02d"), sunrise.min.format("%02d")]));
        sunDownLabel.setText(Lang.format("$1$:$2$", [sunset.hour.format("%02d"), sunset.min.format("%02d")]));
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
    }

    hidden function setStep(dc) as Void {
        var stepLabel = View.findDrawableById("StepLabel") as Text;
        var val = "";
        var bottomValueShows = Application.Properties.getValue("bottomValueShows");

        if(bottomValueShows == 0) {
            if(ActivityMonitor.getInfo().steps != null) {
                val = ActivityMonitor.getInfo().steps.format("%05d");
            }
        } else if(bottomValueShows == 1) {
            if(ActivityMonitor.getInfo().distance != null) {
                val = (ActivityMonitor.getInfo().distance / 100).format("%05d");
            }
        } else if(bottomValueShows == 2) {
            if(ActivityMonitor.getInfo().calories != null) {
                val = ActivityMonitor.getInfo().calories.format("%05d");
            }   
        } else if(bottomValueShows == 3) {
            if(ActivityMonitor.getInfo() has :pushes) {
                if(ActivityMonitor.getInfo().pushes != null) {
                    val = ActivityMonitor.getInfo().pushes.format("%05d");
                } 
            }  
        } else if(bottomValueShows == 4) { // Altitude (m)
            if(Position.getInfo().altitude != null and Position.getInfo().accuracy != Position.QUALITY_NOT_AVAILABLE) {
                val = Position.getInfo().altitude.format("%05d");
            }
        } else if(bottomValueShows == 5) { // Altitude (ft)
            if(Position.getInfo().altitude != null and Position.getInfo().accuracy != Position.QUALITY_NOT_AVAILABLE) {
                val = (Position.getInfo().altitude * 3.281).format("%05d");
            }
        }
        
        stepLabel.setText(val);
    }

    hidden function setStressAndBodyBattery(dc) as Void {
        var batt = 0;
        var stress = 0;
        var showStressAndBodyBattery = Application.Properties.getValue("showStressAndBodyBattery");
        if(!showStressAndBodyBattery) { return; }

        if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory) && (Toybox.SensorHistory has :getStressHistory)) {
            // Set up the method with parameters
            var bbIterator = Toybox.SensorHistory.getBodyBatteryHistory({:period => 1});
            var stIterator = Toybox.SensorHistory.getStressHistory({:period => 1});
            var bb = bbIterator.next();
            var st = stIterator.next();
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

            if(bb != null) {
                batt = Math.round(bb.data * (barHeight / 100.0));
                dc.setColor(0x00AAFF, -1);
                if(isSleeping and dimOnSleep) {
                    dc.setColor(0x046fa8, -1);
                }
                dc.fillRectangle(dc.getWidth() - fromEdge - barWidth - bbAdjustment, barTop + (barHeight - batt), barWidth, batt);
            }
            if(st != null) {
                stress = Math.round(st.data * (barHeight / 100.0));
                dc.setColor(0xFFAA00, -1);
                if(isSleeping and dimOnSleep) {
                    dc.setColor(0xa8721c, -1);
                }
                dc.fillRectangle(fromEdge, barTop + (barHeight - stress), barWidth, stress);
            }
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
            if(Position.getInfo().altitude != null and Position.getInfo().accuracy != Position.QUALITY_NOT_AVAILABLE) {
                val = Position.getInfo().altitude.format("%01d");
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
                val = bb.data.format("%01d");
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
        }
        return desc;
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
