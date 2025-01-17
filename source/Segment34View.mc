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

const INTEGER_FORMAT = "%d";

class Segment34View extends WatchUi.WatchFace {

    private var isSleeping = false;
    private var lastCondition = null;
    private var lastUpdate = null;

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
        // Get and show the current time
        var clockTime = System.getClockTime();
        var now = Time.now().value();

        var secLabel = View.findDrawableById("SecondsLabel") as Text;
        if(isSleeping) {
            secLabel.setText("");
        } else {
            var secString = Lang.format("$1$", [clockTime.sec.format("%02d")]);
            secLabel.setText(secString);
        }

        if(clockTime.sec % 2 == 0) {
            setHR(dc);
            setHRIcons(dc);
            setNotif(dc);
        }
        
        if(lastUpdate != null && now - lastUpdate < 30 && clockTime.sec % 60 != 0) {
            View.onUpdate(dc);
            setStressAndBodyBattery(dc);
            return;
        }
        var hour = clockTime.hour;
        if(!System.getDeviceSettings().is24Hour) {
            hour = hour % 12;
        }
        var timeString = Lang.format("$1$:$2$", [hour.format("%02d"), clockTime.min.format("%02d")]);
        var timelabel = View.findDrawableById("TimeLabel") as Text;
        timelabel.setText(timeString);
        

        // time background 
        var timebg = View.findDrawableById("TimeBg") as Text;
        timebg.setText("#####");

        setMoon(dc);
        setWeather(dc);
        setSunUpDown(dc);
        setDate(dc);
        setStep(dc);
        setTraining(dc);
        setBatt(dc);
        
        View.onUpdate(dc);
        setStressAndBodyBattery(dc);
        setWeatherLabel();

        lastUpdate = now;
    }

    function onPartialUpdate(dc) {
    }

    function onPowerBudgetExceeded() {
        System.println("Power budget exceeded");
    }

    hidden function setHRIcons(dc) as Void {
        /*var hrIconW = View.findDrawableById("HRIconW") as Text;
        var hrIconR = View.findDrawableById("HRIconR") as Text;

        if (isSleeping) {
            hrIconR.setText("h");
            hrIconW.setText("H");
        } else {
            hrIconR.setText("H");
            hrIconW.setText("h");
        }
        */
    }

    hidden function setMoon(dc) as Void {
        var now = Time.now();
        var today = Time.Gregorian.info(now, Time.FORMAT_SHORT);
        var moonVal = moon_phase(today);
        var moonLabel = View.findDrawableById("MoonLabel") as Text;
        moonLabel.setText(moonVal);
    }
    
    hidden function setHR(dc) as Void {
        var value = "";
        // Try to retrieve live HR from Activity::Info
        var activityInfo = Activity.getActivityInfo();
        var sample = activityInfo.currentHeartRate;
        if (sample != null) {
            value = sample.format(INTEGER_FORMAT);
        } else if (ActivityMonitor has :getHeartRateHistory) {
            // Falling back to historical HR from ActivityMonitor
            sample = ActivityMonitor.getHeartRateHistory(1, /* newestFirst */ true).next();
            if ((sample != null) && (sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE)) {
                value = sample.heartRate.format(INTEGER_FORMAT);
            }
        }

        var hrLabel = View.findDrawableById("HRLabel") as Text;
        hrLabel.setText(value);
        hrLabel.draw(dc);
    }

    hidden function setBatt(dc) as Void {
        var value = "";
        var sample = System.getSystemStats().battery / 5;
        for(var i = 0; i < sample; i++) {
            value += "&";
        }
        var battLabel = View.findDrawableById("BattLabel") as Text;
        battLabel.setText(value);
    }

    hidden function setWeather(dc) as Void {
        var weather = Weather.getCurrentConditions();
        if (weather == null) { return; }
        lastCondition = weather.condition;
        if(lastCondition == null) { return; }

        if(weather.temperature != null) {
            var tempUnit = System.getDeviceSettings().temperatureUnits;
            var temp = weather.temperature;
            var tempLabel = View.findDrawableById("TempLabel") as Text;
            if(tempUnit != System.UNIT_METRIC) {
                temp = (temp * 9/5) + 32;
            }
            tempLabel.setText(temp.format(INTEGER_FORMAT));
        }
        
        var windLabel = View.findDrawableById("WindLabel") as Text;
        if(weather.windSpeed != null) {
            windLabel.setText(weather.windSpeed.format(INTEGER_FORMAT));
        }

        if(weather.windBearing != null) {
            var windIcon = View.findDrawableById("WindIcon") as Text;
            var bearing = (Math.round((weather.windBearing.toFloat() + 180) / 45.0).toNumber() % 8).format(INTEGER_FORMAT);
            windIcon.setText(bearing);
        }
    }

    hidden function setWeatherIcon(dc) as Void {
        var icon;
        if(lastCondition == null) {
            return;
        }

        switch(lastCondition) {
            case Weather.CONDITION_CLEAR:
                icon = Application.loadResource( Rez.Drawables.w_clear ) as BitmapResource;
                break;
            case Weather.CONDITION_PARTLY_CLOUDY:
                icon = Application.loadResource( Rez.Drawables.w_partly_cloudy ) as BitmapResource;
                break;
            case Weather.CONDITION_MOSTLY_CLOUDY:
                icon = Application.loadResource( Rez.Drawables.w_mostly_cloudy ) as BitmapResource;
                break;
            case Weather.CONDITION_CLOUDY:
                icon = Application.loadResource( Rez.Drawables.w_cloudy ) as BitmapResource;
                break;
            case Weather.CONDITION_RAIN:
                icon = Application.loadResource( Rez.Drawables.w_rain ) as BitmapResource;
                break;
            case Weather.CONDITION_LIGHT_RAIN:
                icon = Application.loadResource( Rez.Drawables.w_light_rain ) as BitmapResource;
            break;
                case Weather.CONDITION_HEAVY_RAIN:
                icon = Application.loadResource( Rez.Drawables.w_heavy_rain ) as BitmapResource;
                break;
            case Weather.CONDITION_SNOW:
                icon = Application.loadResource( Rez.Drawables.w_snow ) as BitmapResource;
                break;
            case Weather.CONDITION_LIGHT_SNOW:
                icon = Application.loadResource( Rez.Drawables.w_light_snow ) as BitmapResource;
                break;
            case Weather.CONDITION_FOG:
                icon = Application.loadResource( Rez.Drawables.w_fog ) as BitmapResource;
                break;
            case Weather.CONDITION_THUNDERSTORMS:
                icon = Application.loadResource( Rez.Drawables.w_thunder ) as BitmapResource;
                break;
            case Weather.CONDITION_SCATTERED_THUNDERSTORMS:
                icon = Application.loadResource( Rez.Drawables.w_thunder ) as BitmapResource;
                break;
            default:
                icon = Application.loadResource( Rez.Drawables.w_default ) as BitmapResource;
        }
        dc.drawBitmap((dc.getWidth() / 2) - 30, 23, icon);

    }

    hidden function setWeatherLabel() as Void {
        var condition;
        if(lastCondition == null) {
            return;
        }

        switch(lastCondition) {
            case Weather.CONDITION_CLEAR:
                condition = "CLEAR";
                break;
            case Weather.CONDITION_PARTLY_CLOUDY:
                condition = "PARTLY CLOUDY";
                break;
            case Weather.CONDITION_MOSTLY_CLOUDY:
                condition = "MOSTLY CLOUDY";
                break;
            case Weather.CONDITION_CLOUDY:
                condition = "CLOUDY";
                break;
            case Weather.CONDITION_RAIN:
                condition = "RAIN";
                break;
            case Weather.CONDITION_LIGHT_RAIN:
                condition = "LIGHT RAIN";
                break;
            case Weather.CONDITION_HEAVY_RAIN:
                condition = "HEAVY RAIN";
                break;
            case Weather.CONDITION_SNOW:
                condition = "SNOW";
                break;
            case Weather.CONDITION_LIGHT_SNOW:
                condition = "LIGHT SNOW";
                break;
            case Weather.CONDITION_FOG:
                condition = "FOG";
                break;
            case Weather.CONDITION_THUNDERSTORMS:
                condition = "THUNDER";
                break;
            case Weather.CONDITION_SCATTERED_THUNDERSTORMS:
                condition = "SCATTERED\nTHUNDERSTORMS";
                break;
            default:
                condition = "WEATHER";
        }
        
        var weatherLabel = View.findDrawableById("WeatherLabel") as Text;
        weatherLabel.setText(condition);
    }

    hidden function setSunUpDown(dc) as Void {
        /*var weather = Weather.getCurrentConditions();
        var sunUpLabel = View.findDrawableById("SunUpLabel") as Text;
        var sunDownLabel = View.findDrawableById("SunDownLabel") as Text;
        var now = Time.now();
        if(weather == null) {
            return;
        }
        var loc = weather.observationLocationPosition;
        if(loc == null) {
            return;
        }
        var sunrise = Time.Gregorian.info(Weather.getSunrise(loc, now), Time.FORMAT_SHORT);
        var sunset = Time.Gregorian.info(Weather.getSunset(loc, now), Time.FORMAT_SHORT);
        sunUpLabel.setText(sunrise.hour.format(INTEGER_FORMAT));
        sunDownLabel.setText(sunset.hour.format(INTEGER_FORMAT));*/
    }

    hidden function setNotif(dc) as Void {
        var value = "";
        var sample = System.getDeviceSettings().notificationCount;
        if(sample > 0) {
            value = sample.format("%01d");
        }
        var notifLabel = View.findDrawableById("NotifLabel") as Text;
        notifLabel.setText(value);
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
        var stepCount = ActivityMonitor.getInfo().steps.format("%05d");
        stepLabel.setText(stepCount);
    }

    hidden function setStressAndBodyBattery(dc) as Void {
        var batt = 0;
        var stress = 0;

        if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory) && (Toybox.SensorHistory has :getStressHistory)) {
            // Set up the method with parameters
            var bbIterator = Toybox.SensorHistory.getBodyBatteryHistory({:period => 1});
            var stIterator = Toybox.SensorHistory.getStressHistory({:period => 1});
            var bb = bbIterator.next();
            var st = stIterator.next();
            var barTop = 91;
            var fromEdge = 10;
            var barWidth = 3;
            var bbAdjustment = 0;
            if(dc.getHeight() == 240) {
                barTop = 81;
                fromEdge = 6;
                barWidth = 2;
                bbAdjustment = 1;
            }
            if(dc.getHeight() == 280) {
                fromEdge = 14;
                barWidth = 4;
                bbAdjustment = -1;
            }
            if(bb != null) {
                batt = Math.round(bb.data * 0.80);
                dc.setColor(0x00AAFF, -1);
                dc.fillRectangle(dc.getWidth() - fromEdge - barWidth - bbAdjustment, barTop + (80 - batt), barWidth, batt);
            }
            if(st != null) {
                stress = Math.round(st.data * 0.80);
                dc.setColor(0xFFAA00, -1);
                dc.fillRectangle(fromEdge, barTop + (80 - stress), barWidth, stress);
            }
        }
    }

    hidden function setTraining(dc) as Void {
        var TTRDesc = View.findDrawableById("TTRDesc") as Text;
        var TTRLabel = View.findDrawableById("TTRLabel") as Text;
        var TTRReady = View.findDrawableById("TTRReady") as Text;

        if(ActivityMonitor.getInfo().timeToRecovery == null || ActivityMonitor.getInfo().timeToRecovery == 0) {
            TTRReady.setText("FULLY\nRECOVERED");
            TTRLabel.setText("");
            TTRDesc.setText("");
        } else { 
            TTRReady.setText("");
            TTRDesc.setText("HOURS TO\nRECOVERY");
            if(dc.getHeight() == 240) {
                TTRDesc.setText("HRS TO\nRECOV.");
            }

            var ttr = ActivityMonitor.getInfo().timeToRecovery.format("%03d");
            TTRLabel.setText(ttr);
        }
        
        var ActiveDesc = View.findDrawableById("ActiveDesc") as Text;
        ActiveDesc.setText("WEEKLY\nACTIVE MIN");

        if(dc.getHeight() == 240) {
            ActiveDesc.setText("WEEKLY\nMIN");
        }

        var ActiveLabel = View.findDrawableById("ActiveLabel") as Text;
        if(ActivityMonitor.getInfo().activeMinutesWeek != null) {
            var active = ActivityMonitor.getInfo().activeMinutesWeek.total.format("%03d");
            ActiveLabel.setText(active);
        }

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
