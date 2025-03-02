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
    labelFieldBg,
    labelFieldLabel,
    labelTimeBg,
    labelTimeDisplay,
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
    labelLowBatt
}

/*
    For each theme, one MIP profile, one amoled profile.
    The color we want is at the row : 
     - MIP    --> 2*propColorTheme
     - Amoled --> 2*propColorTheme + 1
    Then at the index based on the color name (which is now an enum)
*/
const labelToColor = [
 /*  [n] propColorTheme,                    fieldBg, fieldLabel, timeBg,   timeDisplay, dateDisplay, dateDisplayDim, dawnDuskLabel, dawnDuskValue, notifications, stress,   bodybattery, background, valueDisplay,             moonDisplay,          lowBatt */
 /*  [0] Yellow on turquoise MIP */      [ 0x005555, 0x55AAAA,   0x005555, 0xFFFF00,    0xFFFF00,    0xa98753,       0x005555,      0xAAAAAA,      0x00AAFF,      0xFFAA00, 0x00AAFF,    0x000000,   Graphics.COLOR_WHITE,     Graphics.COLOR_WHITE, 0xFF0000 ],
 /*  [0] Yellow on turquoise AMOLED */   [ 0x0e333c, 0x55AAAA,   0x0d333c, 0xfbcb77,    0xfbcb77,    0xa98753,       0x005555,      0xFFFFFF,      0x00AAFF,      0xFFAA00, 0x00AAFF,    0x000000,   Graphics.COLOR_WHITE,     Graphics.COLOR_WHITE, 0xFF0000 ],
 /*  [1] Hot pink            MIP */      [ 0x005555, 0xAA55AA,   0x005555, 0xFF55AA,    0xFFFFFF,    0xa95399,       0xAA55AA,      0xAAAAAA,      0xFF55AA,      0xFF55AA, 0x00FFAA,    0x000000,   Graphics.COLOR_WHITE,     Graphics.COLOR_WHITE, 0xFF0000 ],
 /*  [1] Hot pink            AMOLED */   [ 0x0e333c, 0xAA55AA,   0x0f3b46, 0xf988f2,    0xFFFFFF,    0xa95399,       0xAA55AA,      0xFFFFFF,      0xFF55AA,      0xFF55AA, 0x00FFAA,    0x000000,   Graphics.COLOR_WHITE,     Graphics.COLOR_WHITE, 0xFF0000 ],
 /*  [2] Blueish green       MIP */      [ 0x0055AA, 0x55AAAA,   0x0055AA, 0x00FFFF,    0x00FFFF,    0x5ca28f,       0x005555,      0xAAAAAA,      0x00AAFF,      0xFFAA00, 0x00AAFF,    0x000000,   Graphics.COLOR_WHITE,     Graphics.COLOR_WHITE, 0xFF0000 ],
 /*  [2] Blueish green       AMOLED */   [ 0x0f2246, 0x55AAAA,   0x0f2246, 0x89efd2,    0x89efd2,    0x5ca28f,       0x005555,      0xFFFFFF,      0x00AAFF,      0xFFAA00, 0x00AAFF,    0x000000,   Graphics.COLOR_WHITE,     Graphics.COLOR_WHITE, 0xFF0000 ],
 /*  [3] Very green          MIP */      [ 0x005500, 0x00AA55,   0x005500, 0x00FF00,    0x00FF00,    0x5ca28f,       0x00AA55,      0xAAAAAA,      0x00AAFF,      0xFFAA00, 0x00AAFF,    0x000000,   Graphics.COLOR_WHITE,     Graphics.COLOR_WHITE, 0xFF0000 ],
 /*  [3] Very green          AMOLED */   [ 0x152b19, 0x00AA55,   0x152b19, 0x96e0ac,    0x96e0ac,    0x5ca28f,       0x00AA55,      0xFFFFFF,      0x00AAFF,      0xffc884, 0x59b9fe,    0x000000,   Graphics.COLOR_WHITE,     Graphics.COLOR_WHITE, 0xFF0000 ],

 /*  [n] propColorTheme,                    fieldBg, fieldLabel, timeBg,   timeDisplay, dateDisplay, dateDisplayDim, dawnDuskLabel, dawnDuskValue, notifications, stress,   bodybattery, background, valueDisplay,             moonDisplay,          lowBatt */
 /*  [4] White on turquoise  MIP */      [ 0x005555, 0x55AAAA,   0x005555, 0xFFFFFF,    0xFFFFFF,    0x114a5a,       0x005555,      0xAAAAAA,      0xAAAAAA,      0xFFAA55, 0x55AAFF,    0x000000,   Graphics.COLOR_WHITE,     Graphics.COLOR_WHITE, 0xFF0000 ],
 /*  [4] White on turquoise  AMOLED */   [ 0x0e333c, 0x55AAAA,   0x0d333c, 0xFFFFFF,    0xFFFFFF,    0x114a5a,       0x005555,      0xFFFFFF,      0xAAAAAA,      0xFFAA55, 0x55AAFF,    0x000000,   Graphics.COLOR_WHITE,     Graphics.COLOR_WHITE, 0xFF0000 ],
 /*  [5] Orange              MIP */      [ 0x5500AA, 0xFFAAAA,   0x5500AA, 0xFF5500,    0xFFAAAA,    0xaa6e56,       0xFFAAAA,      0xAAAAAA,      0xFFFFFF,      0xFF5555, 0x00AAFF,    0x000000,   Graphics.COLOR_WHITE,     Graphics.COLOR_WHITE, 0xFF0000 ],
 /*  [5] Orange              AMOLED */   [ 0x1b263d, 0xFFAAAA,   0x1b263d, 0xff9161,    0xffb383,    0xaa6e56,       0xFFAAAA,      0xFFFFFF,      0xFFFFFF,      0xFF5555, 0x00AAFF,    0x000000,   Graphics.COLOR_WHITE,     Graphics.COLOR_WHITE, 0xFF0000 ],
 /*  [6] Red & White         MIP */      [ 0xAA0000, 0xFF0000,   0xAA0000, 0xFFFFFF,    0xFFFFFF,    0xAA0000,       0xAA0000,      0xAAAAAA,      0xFF0000,      0xAA0000, 0x00AAFF,    0x000000,   Graphics.COLOR_WHITE,     Graphics.COLOR_WHITE, 0xFF0000 ],
 /*  [6] Red & White         AMOLED */   [ 0x550000, 0xFF0000,   0x550000, 0xffffff,    0xffffff,    0xAA0000,       0xAA0000,      0xFFFFFF,      0xFF0000,      0xAA0000, 0x00AAFF,    0x000000,   Graphics.COLOR_WHITE,     Graphics.COLOR_WHITE, 0xFF0000 ],
 /*  [7] White on Blue       MIP */      [ 0x0055AA, 0x0055AA,   0x0055AA, 0xFFFFFF,    0xFFFFFF,    0x0055AA,       0x0055AA,      0xAAAAAA,      0x55AAFF,      0xFFAA00, 0x55AAFF,    0x000000,   Graphics.COLOR_WHITE,     Graphics.COLOR_WHITE, 0xFF0000 ],
 /*  [7] White on Blue       AMOLED */   [ 0x0b2051, 0x0055AA,   0x0b2051, 0xffffff,    0xffffff,    0x0055AA,       0x0055AA,      0xFFFFFF,      0x55AAFF,      0xFFAA00, 0x55AAFF,    0x000000,   Graphics.COLOR_WHITE,     Graphics.COLOR_WHITE, 0xFF0000 ],

 /*  [n] propColorTheme,                    fieldBg, fieldLabel, timeBg,   timeDisplay, dateDisplay, dateDisplayDim, dawnDuskLabel, dawnDuskValue, notifications, stress,   bodybattery, background, valueDisplay,             moonDisplay,          lowBatt */
 /*  [8] Yellow on Blue      MIP */      [ 0x0055AA, 0x0055AA,   0x0055AA, 0xFFFF00,    0xFFFF00,    0xa98753,       0x0055AA,      0xAAAAAA,      0x55AAFF,      0xFFAA00, 0x55AAFF,    0x000000,   Graphics.COLOR_WHITE,     Graphics.COLOR_WHITE, 0xFF0000 ],
 /*  [8] Yellow on Blue      AMOLED */   [ 0x0b2051, 0x0055AA,   0x0b2051, 0xfbcb77,    0xfbcb77,    0xa98753,       0x0055AA,      0xFFFFFF,      0x55AAFF,      0xFFAA00, 0x55AAFF,    0x000000,   Graphics.COLOR_WHITE,     Graphics.COLOR_WHITE, 0xFF0000 ],
 /*  [9] White & Orange      MIP */      [ 0xaa5500, 0xFF5500,   0xaa5500, 0xFFFFFF,    0xFFFFFF,    0xAA5500,       0xFF5500,      0xAAAAAA,      0x00AAFF,      0xFFAA00, 0x00AAFF,    0x000000,   Graphics.COLOR_WHITE,     Graphics.COLOR_WHITE, 0xFF0000 ],
 /*  [9] White & Orange      AMOLED */   [ 0x58250b, 0xFF5500,   0x7d3f01, 0xffffff,    0xffffff,    0xAA5500,       0xFF5500,      0xFFFFFF,      0x00AAFF,      0xFFAA00, 0x00AAFF,    0x000000,   Graphics.COLOR_WHITE,     Graphics.COLOR_WHITE, 0xFF0000 ],
 /* [10] Blue                MIP */      [ 0x555555, 0x0055AA,   0x000055, 0x0055AA,    0xFFFFFF,    0x0055AA,       0x0055AA,      0xAAAAAA,      0x55AAFF,      0xFFAA00, 0x55AAFF,    0x000000,   Graphics.COLOR_WHITE,     Graphics.COLOR_WHITE, 0xFF0000 ],
 /* [10] Blue                AMOLED */   [ 0x191b33, 0x0055AA,   0x191b33, 0x3495d4,    0xffffff,    0x0055AA,       0x0055AA,      0xFFFFFF,      0x55AAFF,      0xFFAA00, 0x55AAFF,    0x000000,   Graphics.COLOR_WHITE,     Graphics.COLOR_WHITE, 0xFF0000 ],
 /* [11] Orange              MIP */      [ 0x555555, 0xFFAA00,   0x555555, 0xFFAA00,    0xFFFFFF,    0x555555,       0xFFAA00,      0xAAAAAA,      0x55AAFF,      0xFFAA00, 0x55AAFF,    0x000000,   Graphics.COLOR_WHITE,     Graphics.COLOR_WHITE, 0xFF0000 ],
 /* [11] Orange              AMOLED */   [ 0x333333, 0xFFAA00,   0x333333, 0xff7600,    0xffffff,    0x555555,       0xFFAA00,      0xFFFFFF,      0x55AAFF,      0xFFAA00, 0x55AAFF,    0x000000,   Graphics.COLOR_WHITE,     Graphics.COLOR_WHITE, 0xFF0000 ],

 /*  [n] propColorTheme,                    fieldBg, fieldLabel, timeBg,   timeDisplay, dateDisplay, dateDisplayDim, dawnDuskLabel, dawnDuskValue, notifications, stress,   bodybattery, background, valueDisplay,             moonDisplay,          lowBatt */
 /* [12] White on black      MIP */      [ 0x555555, 0xFFFFFF,   0x555555, 0xFFFFFF,    0xFFFFFF,    0x555555,       0xFFFFFF,      0xFFFFFF,      0x55AAFF,      0xFFAA00, 0x55AAFF,    0x000000,   0xFFFFFF,                 Graphics.COLOR_WHITE, 0xFF0000 ],
 /* [12] White on black      AMOLED */   [ 0x333333, 0xFFFFFF,   0x333333, 0xFFFFFF,    0xFFFFFF,    0x555555,       0xFFFFFF,      0xFFFFFF,      0x55AAFF,      0xFFAA00, 0x55AAFF,    0x000000,   0xFFFFFF,                 Graphics.COLOR_WHITE, 0xFF0000 ],
 /* [13] Black on White      MIP */      [ 0xAAAAAA, 0x000000,   0xAAAAAA, 0x000000,    0x000000,    0x555555,       0x000000,      0x555555,      0x000000,      0xFFAA00, 0x55AAFF,    0xFFFFFF,   0x000000,                 0x555555,             0xFF0000 ],
 /* [13] Black on White      AMOLED */   [ 0xCCCCCC, 0x000000,   0xCCCCCC, 0x000000,    0x000000,    0x555555,       0x000000,      0x000000,      0x000000,      0xFFAA00, 0x55AAFF,    0xFFFFFF,   0x000000,                 0x555555,             0xFF0000 ],
 /* [14] Red on White        MIP */      [ 0xAAAAAA, 0xAA0000,   0xAAAAAA, 0xAA0000,    0x000000,    0x555555,       0xAA0000,      0x555555,      0x000000,      0xFFAA00, 0x55AAFF,    0xFFFFFF,   0x000000,                 0x555555,             0xFF0000 ],
 /* [14] Red on White        AMOLED */   [ 0xCCCCCC, 0xAA0000,   0xCCCCCC, 0xAA0000,    0x000000,    0x555555,       0xAA0000,      0x000000,      0x000000,      0xFFAA00, 0x55AAFF,    0xFFFFFF,   0x000000,                 0x555555,             0xFF0000 ],
 /* [15] Blue on White       MIP */      [ 0xAAAAAA, 0x0000AA,   0xAAAAAA, 0x0000AA,    0x000000,    0x555555,       0x0000AA,      0x555555,      0x000000,      0xFFAA00, 0x55AAFF,    0xFFFFFF,   0x000000,                 0x555555,             0xFF0000 ],
 /* [15] Blue on White       AMOLED */   [ 0xCCCCCC, 0x0000AA,   0xCCCCCC, 0x0000AA,    0x000000,    0x555555,       0x0000AA,      0x000000,      0x000000,      0xFFAA00, 0x55AAFF,    0xFFFFFF,   0x000000,                 0x555555,             0xFF0000 ],

 /*  [n] propColorTheme,                    fieldBg, fieldLabel, timeBg,   timeDisplay, dateDisplay, dateDisplayDim, dawnDuskLabel, dawnDuskValue, notifications, stress,   bodybattery, background, valueDisplay,             moonDisplay,          lowBatt */
 /* [16] Green on White      MIP */      [ 0xAAAAAA, 0x00AA00,   0xAAAAAA, 0x00AA00,    0x000000,    0x555555,       0x00AA00,      0x555555,      0x000000,      0xFFAA00, 0x55AAFF,    0xFFFFFF,   0x000000,                 0x555555,             0xFF0000 ],
 /* [16] Green on White      AMOLED */   [ 0xCCCCCC, 0x00AA00,   0xCCCCCC, 0x00AA00,    0x000000,    0x555555,       0x00AA00,      0x000000,      0x000000,      0xFFAA00, 0x55AAFF,    0xFFFFFF,   0x000000,                 0x555555,             0xFF0000 ],
 /* [17] Orange on White     MIP */      [ 0xAAAAAA, 0x555555,   0xAAAAAA, 0xFF5500,    0x000000,    0x555555,       0x555555,      0x555555,      0x000000,      0xFF5500, 0x55AAFF,    0xFFFFFF,   0x000000,                 0x555555,             0xFF0000 ],
 /* [17] Orange on White     AMOLED */   [ 0xCCCCCC, 0x555555,   0xCCCCCC, 0xFF5500,    0x000000,    0x555555,       0x555555,      0x000000,      0x000000,      0xFF5500, 0x55AAFF,    0xFFFFFF,   0x000000,                 0x555555,             0xFF0000 ],
 /* [18] Green & Orange      MIP */      [ 0x005500, 0xFF5500,   0x005500, 0xFF5500,    0x00FF00,    0x5ca28f,       0xFF5500,      0xAAAAAA,      0x55FF55,      0xFF5500, 0x00AAFF,    0x000000,   0x00FF00,                 Graphics.COLOR_WHITE, 0xFF0000 ],
 /* [18] Green & Orange      AMOLED */   [ 0x152b19, 0xFF5500,   0x152b19, 0xff7600,    0x55FF55,    0x5ca28f,       0xFF5500,      0xFFFFFF,      0x55FF55,      0xff7600, 0x59b9fe,    0x000000,   0x55FF55,                 Graphics.COLOR_WHITE, 0xFF0000 ],
 /* [19] Green Camo          MIP */      [ 0x005500, 0xAAAA00,   0x005500, 0xAAAA55,    0xAAAA55,    0x546a36,       0xAAAA00,      0x00FF00,      0x00FF55,      0xAAAA55, 0x00FF00,    0x000000,   0x00FF00,                 0xFFFFFF,             0xFF0000 ],
 /* [19] Green Camo          AMOLED */   [ 0x152b19, 0xa8aa6c,   0x152b19, 0x889f4a,    0x889f4a,    0x546a36,       0xa8aa6c,      0x55AA55,      0x00FF55,      0x889f4a, 0x55AA55,    0x000000,   0x55AA55,                 0xe3efd2,             0xFF0000 ],

 /*  [n] propColorTheme,                    fieldBg, fieldLabel, timeBg,   timeDisplay, dateDisplay, dateDisplayDim, dawnDuskLabel, dawnDuskValue, notifications, stress,   bodybattery, background, valueDisplay,             moonDisplay,          lowBatt */
 /* [20] Red on Black        MIP */      [ 0x555555, 0xFF0000,   0x555555, 0xFF0000,    0xFFFFFF,    0x555555,       0xFF0000,      0xFFFFFF,      0x55AAFF,      0xFF5555, 0x55AAFF,    0x000000,   0xFFFFFF,                 0xFFFFFF,             0xFF0000 ],
 /* [20] Red on Black        AMOLED */   [ 0x282828, 0xFF0000,   0x282828, 0xFF0000,    0xFFFFFF,    0x555555,       0xFF0000,      0xFFFFFF,      0x55AAFF,      0xFF5555, 0x55AAFF,    0x000000,   0xFFFFFF,                 0xe3efd2,             0xFF0000 ]
];

/* Indexes for the following array */
enum {
    shortDesc,
    midDesc,
    longDesc,
    unitDesc
}

const complicationToDesc = [
    /* short,     mid,           long,              unit     */
    ["W MIN:",    "WEEK MIN:",   "WEEK ACT MIN:",   ""       ], //  [0] Active min / week
    ["D MIN:",    "MIN TODAY:",  "DAY ACT MIN:",    ""       ], //  [1] Active min / day
    ["D KM:",     "KM TODAY:",   "KM TODAY:",       ""       ], //  [2] distance (km) / day
    ["D MI:",     "MI TODAY:",   "MILES TODAY:",    ""       ], //  [3] distance (miles) / day
    ["FLRS:",     "FLOORS:",     "FLOORS:",         ""       ], //  [4] floors climbed / day
    ["CLIMB:",    "M CLIMBED:",  "M CLIMBED:",      ""       ], //  [5] meters climbed / day
    ["RECOV:",    "RECOV HRS:",  "RECOVERY HRS:",   ""       ], //  [6] Time to Recovery (h)
    ["V02:",      "V02 MAX:",    "RUN V02 MAX:",    ""       ], //  [7] VO2 Max Running
    ["V02:",      "V02 MAX:",    "BIKE V02 MAX:",   ""       ], //  [8] VO2 Max Cycling
    ["RESP:",     "RESP RATE:",  "RESP. RATE:",     ""       ], //  [9] Respiration rate
    [ null,       null,          null,              ""       ], // [10] HR, done in function
    ["CAL:",      "CALORIES:",   "DLY CALORIES:",   "KCAL"   ], // [11] Calories / day
    ["ALT:",      "ALTITUDE:",   "ALTITUDE M:",     "M"      ], // [12] Altitude (m)
    ["STRSS:",    "STRESS:",     "STRESS:",         ""       ], // [13] Stress
    ["B BAT:",    "BODY BATT:",  "BODY BATTERY:",   ""       ], // [14] Body battery
    ["ALT:",      "ALTITUDE:",   "ALTITUDE FT:",    "FT"     ], // [15] Altitude (ft)
    [ null,       null,          null,              ""       ], // [16] Alt TZ 1, done in function
    ["STEPS:",    "STEPS:",      "STEPS:",          "STEPS"  ], // [17] Steps / day
    ["DIST:",     "M TODAY:",    "METERS TODAY:",   ""       ], // [18] Distance (m) / day
    ["PUSHES:",   "PUSHES:",     "PUSHES:",         "PUSHES" ], // [19] Wheelchair pushes
    ["",          "",            "",                ""       ], // [20] Weather condition
    ["W KM:",     "W RUN KM:",   "WEEK RUN KM:",    ""       ], // [21] Weekly run distance (km)
    ["W MI:",     "W RUN MI:",   "WEEK RUN MI:",    ""       ], // [22] Weekly run distance (miles)
    ["W KM:",     "W BIKE KM:",  "WEEK BIKE KM:",   ""       ], // [23] Weekly bike distance (km)
    ["W MI:",     "W BIKE MI:",  "WEEK BIKE MI:",   ""       ], // [24] Weekly bike distance (miles)
    ["TRAINING:", "TRAINING:",   "TRAINING:",       ""       ], // [25] Training status
    ["PRESSURE:", "PRESSURE:",   "PRESSURE:",       ""       ], // [26] Barometric pressure (hPA)
    ["KG:",       "WEIGHT:",     "WEIGHT KG:",      ""       ], // [27] Weight kg
    ["LBS:",      "WEIGHT:",     "WEIGHT KG:",      ""       ], // [28] Weight lbs
    ["A CAL:",    "ACT. CAL:",   "ACT. CALORIES:",  "KCAL"   ], // [29] Act Calories / day
    ["PRESSURE:", "PRESSURE:",   "PRESSURE:",       ""       ], // [30] Sea level pressure (hPA)
    ["WEEK:",     "WEEK:",       "WEEK:",           ""       ], // [31] Week number
    ["W KM:",     "WEEK KM:",    "WEEK DIST KM:",   ""       ], // [32] Weekly distance (km)
    ["W MI:",     "WEEK MI:",    "WEEKLY MILES:",   ""       ], // [33] Weekly distance (miles)
    ["BATT:",     "BATT %:",     "BATTERY %:",      ""       ], // [34] Battery percentage
    ["BATT D:",   "BATT DAYS:",  "BATTERY DAYS:",   ""       ], // [35] Battery days remaining
    ["NOTIFS:",   "NOTIFS:",     "NOTIFICATIONS:",  ""       ], // [36] Notification count
    ["SUN:",      "SUN INT:",    "SUN INTENSITY:",  ""       ], // [37] Solar intensity
    ["TEMP:",     "TEMP:",       "SENSOR TEMP:",    ""       ], // [38] Sensor temp
    ["DAWN:",     "SUNRISE:",    "SUNRISE:",        ""       ], // [39] Sunrise
    ["DUSK:",     "SUNSET:",     "SUNSET:",         ""       ], // [40] Sunset
    [ null,       null,          null,              ""       ], // [41] Alt TZ 2:
    ["ALARM:",    "ALARMS:",     "ALARMS:",         ""       ], // [42] Alarms
    ["HIGH:",     "DAILY HIGH:", "DAILY HIGH:",     ""       ], // [43] Daily high temp
    ["LOW:",      "DAILY LOW:",  "DAILY LOW:",      ""       ], // [44] Daily low temp
    [ null,       null,           null,             ""       ], // [45] empty for offset 45
    [ null,       null,           null,             ""       ], // [46] empty for offset 46
    [ null,       null,           null,             ""       ], // [47] empty for offset 47
    [ null,       null,           null,             ""       ], // [48] empty for offset 48
    [ null,       null,           null,             ""       ], // [49] empty for offset 49
    [ null,       null,           null,             ""       ], // [50] empty for offset 50
    [ null,       null,           null,             ""       ], // [51] empty for offset 51
    [ null,       null,           null,             ""       ], // [52] empty for offset 52
    ["TEMP:",     "TEMP:",        "TEMPERATURE:",   ""       ], // [53] Temperature
    ["PRECIP:",   "PRECIP:",      "PRECIPITATION:", ""       ]  // [54] Precipitation
];

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

    private var isSleeping = false;
    private var doesPartialUpdate = false;
    private var lastUpdate = null;
    private var canBurnIn = false;

    private var screenHeight = 0;
    private var screenIndex = screenHeightDefault;
    private var clipX = 0;
    private var clipY = 0;
    private var clipWidth = 0;
    private var clipHeight = 0;

    private var previousEssentialsVis = null;
    private var batt = 0;
    private var stress = 0;
    private var weatherCondition = null;
    private var nightMode = false;
    private var ledSmallFont = null;
    private var ledMidFont = null;
    private var dbackground = null;
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
    private var dIcon1 = null;
    private var dIcon2 = null;

    private var propColorTheme = null;
    private var propNightColorTheme = null;
    private var propBatteryVariant = null;
    private var propShowSeconds = null;
    private var propLeftValueShows = null;
    private var propMiddleValueShows = null;
    private var propRightValueShows = null;
    private var propAlwaysShowSeconds = null;
    private var propShowClockBg = null;
    private var propShowDataBg = null;
    private var propAodFieldShows = null;
    private var propBottomFieldShows = null;
    private var propAodAlignment = null;
    private var propDateAlignment = null;
    private var propIcon1 = null;
    private var propIcon2 = null;
    private var propHemisphere = null;

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

            if(clockTime.min % 5 == 0 or weatherCondition == null) {
                updateWeather();
            }

            if (updateNightMode()){
                previousEssentialsVis = null;
            }
        }

        toggleNonEssentials(dc);

        if(!isSleeping && !updateEverything) {
            if(propShowSeconds) {
                setSeconds(dc);
            }
            if(clockTime.sec % 5 == 0 and (propLeftValueShows == 10 or propMiddleValueShows == 10 or propRightValueShows == 10)) {
                setBottomFields(dc);
            }
        }

        if(updateEverything) {
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

    private const screenClipValues = [
        /* size         clipX, clipY, clipWidth, clipHeight */
        /* 240px */   [   205,   157,        24,        20 ],
        /* 260px */   [   220,   162,        24,        20 ],
        /* 280px */   [   235,   170,        24,        20 ],
        /* 360px */   [     0,     0,         0,         0 ],
        /* 390px */   [     0,     0,         0,         0 ],
        /* 416px */   [     0,     0,         0,         0 ],
        /* 454px */   [     0,     0,         0,         0 ],
        /* Default */ [     0,     0,         0,         0 ]
    ];

    function onPartialUpdate(dc) {
        if(canBurnIn) { return; }
        if(!propAlwaysShowSeconds) { return; }
        doesPartialUpdate = true;

        var clockTime = System.getClockTime();
        var secString = Lang.format("$1$", [clockTime.sec.format("%02d")]);

        /* No clipping for big screens */
        if(screenHeight > 280) { return; }

        dc.setClip(clipX, clipY, clipWidth, clipHeight);
        dc.setColor(getColor(labelBackground), getColor(labelBackground));
        dc.clear();
        dc.setColor(getColor(labelDateDisplay), Graphics.COLOR_TRANSPARENT);
        dc.drawText(clipX, clipY, ledSmallFont, secString, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function onSettingsChanged() {
        lastUpdate = null;
        previousEssentialsVis = null;
        cacheProps();
        updateNightMode();
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
        updateNightMode();
        WatchUi.requestUpdate();
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        isSleeping = true;
        lastUpdate = null;
        WatchUi.requestUpdate();
    }

    hidden function cacheDrawables(dc) as Void {
        /* Update all screen data */
        screenHeight = dc.getHeight();


        dbackground = View.findDrawableById("background") as Drawable;
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
        dIcon1 = View.findDrawableById("Icon1") as Text;
        dIcon2 = View.findDrawableById("Icon2") as Text;

        /* Setting index */
        if      (screenHeight == 240) { screenIndex = screenHeight240; }
        else if (screenHeight == 260) { screenIndex = screenHeight260; }
        else if (screenHeight == 280) { screenIndex = screenHeight280; }
        else if (screenHeight == 360) { screenIndex = screenHeight360; }
        else if (screenHeight == 390) { screenIndex = screenHeight390; }
        else if (screenHeight == 416) { screenIndex = screenHeight416; }
        else if (screenHeight == 454) { screenIndex = screenHeight454; }
        else                          { screenIndex = screenHeightDefault; }

        clipX      = screenClipValues[screenIndex][0];
        clipY      = screenClipValues[screenIndex][1];
        clipWidth  = screenClipValues[screenIndex][2];
        clipHeight = screenClipValues[screenIndex][3];
    }

    hidden function cacheProps() as Void {
        propColorTheme = Application.Properties.getValue("colorTheme");
        propNightColorTheme = Application.Properties.getValue("nightColorTheme");
        propBatteryVariant = Application.Properties.getValue("batteryVariant");
        propShowSeconds = Application.Properties.getValue("showSeconds");
        propAlwaysShowSeconds = Application.Properties.getValue("alwaysShowSeconds");
        propShowClockBg = Application.Properties.getValue("showClockBg");
        propShowDataBg = Application.Properties.getValue("showDataBg");
        propAodFieldShows = Application.Properties.getValue("aodFieldShows");
        propLeftValueShows = Application.Properties.getValue("leftValueShows");
        propMiddleValueShows = Application.Properties.getValue("middleValueShows");
        propRightValueShows = Application.Properties.getValue("rightValueShows");
        propBottomFieldShows = Application.Properties.getValue("bottomFieldShows");
        propAodAlignment = Application.Properties.getValue("aodAlignment");
        propDateAlignment = Application.Properties.getValue("dateAlignment");
        propIcon1 = Application.Properties.getValue("icon1");
        propIcon2 = Application.Properties.getValue("icon2");
        propHemisphere = Application.Properties.getValue("hemisphere");

        var fontVariant = Application.Properties.getValue("smallFontVariant");
        if(fontVariant == 0) {
            ledSmallFont = Application.loadResource( Rez.Fonts.id_led_small );
            ledMidFont = Application.loadResource( Rez.Fonts.id_led );
        } else if(fontVariant == 1) {
            ledSmallFont = Application.loadResource( Rez.Fonts.id_led_small_readable );
            ledMidFont = Application.loadResource( Rez.Fonts.id_led_inbetween );
        } else {
            ledSmallFont = Application.loadResource( Rez.Fonts.id_led_small_lines );
            ledMidFont = Application.loadResource( Rez.Fonts.id_led_lines );
        }

        /* Setting up fonts */
        var font = ledSmallFont;

        if(screenHeight > 280) {
            font = ledMidFont;
            dAodDateLabel.setFont(ledMidFont);
        }

        dDateLabel.setFont(font);
        dSecondsLabel.setFont(font);
        dNotifLabel.setFont(font);
        dWeatherLabel1.setFont(font);
        dWeatherLabel2.setFont(font);
    }

    hidden function toggleNonEssentials(dc){
        var awake = !isSleeping;
        if(isSleeping and canBurnIn) {
            dc.setAntiAlias(false);
            var clockTime = System.getClockTime();
            dGradient.setVisible(false);
            dAodPattern.setVisible(true);
            if(propAodFieldShows != -2) {
                dAodDateLabel.setVisible(true);
            } else {
                dAodDateLabel.setVisible(false);
            }
            dAodPattern.setLocation(clockTime.min % 2, dAodPattern.locY);
            setAlignment(propAodAlignment, dAodDateLabel, (clockTime.min % 3) - 1);
            dAodDateLabel.setColor(getColor(labelDateDisplayDim));
            dbackground.setVisible(false);
        } else {
            dc.setAntiAlias(true);
        }

        if(previousEssentialsVis == awake) {
            return;
        }

        var hideInAOD = (awake or !canBurnIn);
        var hideBattery = (hideInAOD && propBatteryVariant != 2);

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

        dDateLabel.setVisible(hideInAOD);
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
        dWeatherLabel2.setVisible(hideInAOD);
        dTimeBg.setVisible(hideInAOD and propShowClockBg);
        dBattLabel.setVisible(hideBattery);
        dBattBg.setVisible(hideBattery);
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
        
        if(hideInAOD) {
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

                if(getColor(labelBackground) == 0xFFFFFF) {
                    dGradient.setVisible(false);
                } else {
                    dGradient.setVisible(true);
                }
            }
        }

        previousEssentialsVis = awake;
    }

    hidden function setVisibility2(setting as Number, label as Text, bg as Text) {
        var hideInAOD = (!isSleeping or !canBurnIn);
        if(setting == -2) {
            label.setVisible(false);
            bg.setVisible(false);
        } else {
            label.setVisible(hideInAOD);
            bg.setVisible(hideInAOD and propShowDataBg);
        }
    }

    hidden function setVisibility3(setting as Number, desc as Text, label as Text, bg as Text) {
        var hideInAOD = (!isSleeping or !canBurnIn);
        if(setting == -2) {
            desc.setVisible(false);
            label.setVisible(false);
            bg.setVisible(false);
        } else {
            desc.setVisible(hideInAOD);
            label.setVisible(hideInAOD);
            bg.setVisible(hideInAOD and propShowDataBg);
        }
    }

    /* Screen alignement values :           240px, 260px 280px, 360px, 390px, 416px, 454px, Default */
    private const screenAlignValues = [ 10,    16,   25,    15,    17,    31,    23,    0 ];

    hidden function setAlignment(setting as Number, label as Text, offset as Number) {
        var x = screenAlignValues[screenIndex];

        if(setting == 0) { // Left align
            label.setJustification(Graphics.TEXT_JUSTIFY_LEFT);
            label.setLocation(x + offset, label.locY);
        } else { // Center align
            label.setJustification(Graphics.TEXT_JUSTIFY_CENTER);
            label.setLocation(Math.floor(screenHeight / 2) + offset, label.locY);
        }
    }

    /* Screen notification alignement :    240px, 260px 280px, 360px, 390px, 416px, 454px, Default */
    private const screenNotifLeft  = [ 10,    16,   25,    15,    17,    31,    23,    0 ];
    private const screenNotifAfter = [ 195,   210,  220,   297,   317,   331,   379,   0 ];
 
    hidden function alignNotification(setting as Number) {
        var x = 0;
        var alignment = Graphics.TEXT_JUSTIFY_RIGHT;

        if(setting == 1) { // Date is centered, left align notif
            x = screenNotifLeft[screenIndex];
            alignment = Graphics.TEXT_JUSTIFY_LEFT;
        } else { // Date is left aligned, put notif after
            x = screenNotifAfter[screenIndex];
            alignment = Graphics.TEXT_JUSTIFY_LEFT;
        }

        dNotifLabel.setJustification(alignment);
        dNotifLabel.setLocation(x, dNotifLabel.locY);
    }

    hidden function getColor(colorName) as Graphics.ColorType {
        /* Check whether we are AMOLED or MIP */ 
        var amoled = canBurnIn ?    1   :   0;
        var themeToUse = propColorTheme;
        if (propNightColorTheme != -1 && nightMode) {
            themeToUse = propNightColorTheme;
        }

        var color = labelToColor[2*themeToUse + amoled][colorName];

        /* Handle special cases */
        if(colorName == labelTimeDisplay && isSleeping && amoled) {
            /* Use color offset   12,       13,       14,       15,       16,       17 */
            var arraySleeping = [ 0xAAAAAA, 0xAAAAAA, 0xAA5555, 0x5555AA, 0x55AA55, 0xff7600 ];
            color = arraySleeping[themeToUse - 12];
        }

        return color;
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

    hidden function setBatt(dc) as Void {
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

    hidden function getTempUnit() as String {
        var tempUnitSetting = System.getDeviceSettings().temperatureUnits;
        var tempUnitAppSetting = Application.Properties.getValue("tempUnit");

        if((tempUnitSetting == System.UNIT_METRIC and tempUnitAppSetting == 0) or tempUnitAppSetting == 1) {
            return "C";
        } else {
            return "F";
        }
    }

    hidden function setWeather(dc) as Void {
        var weatherLine1Shows = Application.Properties.getValue("weatherLine1Shows");
        var unit = getComplicationUnit(weatherLine1Shows);
        if (unit.length() > 0) {
            unit = Lang.format(" $1$", [unit]);
        }
        dWeatherLabel1.setText(Lang.format("$1$$2$", [getComplicationValue(weatherLine1Shows, 10), unit]));
    }

    hidden function setWeatherLabel() as Void {
        var weatherLine2Shows = Application.Properties.getValue("weatherLine2Shows");
        var unit = getComplicationUnit(weatherLine2Shows);
        if (unit.length() > 0) {
            unit = Lang.format(" $1$", [unit]);
        }
        dWeatherLabel2.setText(Lang.format("$1$$2$", [getComplicationValue(weatherLine2Shows, 10), unit]));
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

    hidden function setSunUpDown(dc) as Void {
        var sunriseFieldShows = Application.Properties.getValue("sunriseFieldShows");
        var sunsetFieldShows = Application.Properties.getValue("sunsetFieldShows");

        if(sunriseFieldShows == -2) {
            dDawn.setText("");
            dSunUpLabel.setText("");
        } else {
            dDawn.setText(getComplicationDesc(sunriseFieldShows, 1));
            dSunUpLabel.setText(getComplicationValue(sunriseFieldShows, 5));
        }

        if(sunsetFieldShows == -2) {
            dDusk.setText("");
            dSunDownLabel.setText("");
        } else {
            dDusk.setText(getComplicationDesc(sunsetFieldShows, 1));
            dSunDownLabel.setText(getComplicationValue(sunsetFieldShows, 5));
        }
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

    hidden function setIcons(dc) as Void {
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
            if(propAodFieldShows == -1) {
                dAodDateLabel.setText(value.toUpper());
            } else {
                var unit = getComplicationUnit(propAodFieldShows);
                if (unit.length() > 0) {
                    unit = Lang.format(" $1$", [unit]);
                }
                dAodDateLabel.setText(Lang.format("$1$$2$", [getComplicationValue(propAodFieldShows, 10), unit]));
            }
        }
    }

    hidden function setStep(dc) as Void {
        dStepLabel.setText(getComplicationValueWithFormat(propBottomFieldShows, "%05d", 5));
    }

    hidden function updateNightMode() as Boolean {
        var oldNightMode = nightMode;

        if (propNightColorTheme == -1 || propNightColorTheme == propColorTheme) {
            nightMode = false;
            return (oldNightMode != nightMode);
        }

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

        var now = Time.now(); // Moment
        var todayMidnight = Time.today(); // Moment
        var nowAsTimeSinceMidnight = now.subtract(todayMidnight) as Duration; // Duration

        nightMode = (nowAsTimeSinceMidnight.greaterThan(sleepTime) || nowAsTimeSinceMidnight.lessThan(wakeTime));
        return (oldNightMode != nightMode);
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

    private const stressAndBodyBatteryMeasures = [
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

    hidden function drawStressAndBodyBattery(dc) as Void {
        var showStressAndBodyBattery = Application.Properties.getValue("showStressAndBodyBattery");
        if(!showStressAndBodyBattery) { return; }

        if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory) && (Toybox.SensorHistory has :getStressHistory)) {
            var barTop =       stressAndBodyBatteryMeasures[screenIndex][0] as Number;
            var fromEdge =     stressAndBodyBatteryMeasures[screenIndex][1] as Number;
            var barWidth =     stressAndBodyBatteryMeasures[screenIndex][2] as Number;
            var barHeight =    stressAndBodyBatteryMeasures[screenIndex][3] as Number;
            var bbAdjustment = stressAndBodyBatteryMeasures[screenIndex][4] as Number;

            /* Taking data from the last column instead */
            if (isSleeping) {
                fromEdge =     stressAndBodyBatteryMeasures[screenIndex][5];
            }

            var battBar = Math.round(batt * (barHeight / 100.0));
            dc.setColor(getColor(labelBodybattery), -1);
            dc.fillRectangle(dc.getWidth() - fromEdge - barWidth - bbAdjustment, barTop + (barHeight - battBar), barWidth, battBar);

            var stressBar = Math.round(stress * (barHeight / 100.0));
            dc.setColor(getColor(labelStress), -1);
            dc.fillRectangle(fromEdge, barTop + (barHeight - stressBar), barWidth, stressBar);

        }
    }

    hidden function setBottomFields(dc) as Void {
        var leftWidth = 3;
        var leftLabelSize = 2;
        if(dc.getWidth() > 450) {
            leftWidth = 4;
            leftLabelSize = 3;
        }
        dTtrDesc.setText(getComplicationDesc(propLeftValueShows, leftLabelSize));
        dTtrLabel.setText(getComplicationValue(propLeftValueShows, leftWidth));

        var midWidth = 3;
        var midLabelSize = 2;
        if(dc.getWidth() > 450) {
            midWidth = 4;
            midLabelSize = 3;
        }
        dHrDesc.setText(getComplicationDesc(propMiddleValueShows, midLabelSize));
        dHrLabel.setText(getComplicationValue(propMiddleValueShows, midWidth));

        var rightWidth = 4;
        var rightLabelSize = 3;
        if(dc.getWidth() == 240) {
            rightWidth = 3;
            midLabelSize = 2;
        }
        dActiveDesc.setText(getComplicationDesc(propRightValueShows, rightLabelSize));
        dActiveLabel.setText(getComplicationValue(propRightValueShows, rightWidth));
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
        } else if(complicationType == 10) {
            // Try to retrieve live HR from Activity::Info
            var activityInfo = Activity.getActivityInfo();
            var sample = activityInfo.currentHeartRate;
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
                var elvIterator = Toybox.SensorHistory.getElevationHistory({:period => 1});
                var elv = elvIterator.next();
                if(elv != null and elv.data != null) {
                    val = elv.data.format(numberFormat);
                }
            }
        } else if(complicationType == 13) { // Stress
            if ((Toybox has :SensorHistory) and (Toybox.SensorHistory has :getStressHistory)) {
                var stIterator = Toybox.SensorHistory.getStressHistory({:period => 1});
                var st = stIterator.next();
                if(st != null and st.data != null) {
                    val = st.data.format(numberFormat);
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
        } else if(complicationType == 16) { // Alt TZ 1
            var offset = Application.Properties.getValue("tzOffset1");
            val = secondaryTimezone(offset, width);
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
            val = getWeatherCondition(true);
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
        } else if(complicationType == 37) { // Solar intensity
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
                    var sunrise = Time.Gregorian.info(Weather.getSunrise(loc, now), Time.FORMAT_SHORT);
                    var sunriseHour = formatHour(sunrise.hour);
                    if(width < 5) {
                        val = Lang.format("$1$$2$", [sunriseHour.format("%02d"), sunrise.min.format("%02d")]);
                    } else {
                        val = Lang.format("$1$:$2$", [sunriseHour.format("%02d"), sunrise.min.format("%02d")]);
                    }
                }
            }
        } else if(complicationType == 40) { // Sunset
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
        } else if(complicationType == 41) { // Alt TZ 2
            var offset = Application.Properties.getValue("tzOffset2");
            val = secondaryTimezone(offset, width);
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
        }

        return val;
    }

    function getComplicationDesc(complicationType, labelSize as Number) as String {
        /* Handle special cases or return from the array */
        var desc = complicationToDesc[complicationType][labelSize - 1];

        if (desc == null) {
            var name = "";
            switch (complicationType) {
                case 10:
                    if(Activity.getActivityInfo().currentHeartRate == null) {
                        var hrDesc = [ "HR:", "LAST HR:", "LAST HR:" ];
                        return hrDesc[labelSize - 1];
                    } else {
                        var hrDesc = [ "HR:", "LIVE HR:", "LIVE HR:" ];
                        return hrDesc[labelSize - 1];
                    }
                case 16:
                    name = Application.Properties.getValue("tzName1");
                    return Lang.format("$1$:", [name.toUpper()]);
                case 41:
                    name = Application.Properties.getValue("tzName2");
                    return Lang.format("$1$:", [name.toUpper()]);
                default:
                    return "";
            }
        } else {
            return desc;
        }
    }

    function getComplicationUnit(complicationType) as String {
        /* The index 3 is associated with the unit in the global array */
        return complicationToDesc[complicationType][unitDesc];
    }

    function join(array as Array<String>) as String {
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

    function getTemperature() as String {
        if(weatherCondition != null and weatherCondition.temperature != null) {
            var tempUnit = getTempUnit();
            var tempVal = weatherCondition.temperature;
            var temp = formatTemperature(tempVal, tempUnit).format("%01d");
            return Lang.format("$1$$2$", [temp, tempUnit]);
        }
        return "";
    }

    function getWind() as String {
        var windspeed = "";
        var bearing = "";

        if(weatherCondition != null and weatherCondition.windSpeed != null) {
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

        if(weatherCondition != null and weatherCondition.windBearing != null) {
            bearing = ((Math.round((weatherCondition.windBearing.toFloat() + 180) / 45.0).toNumber() % 8) + 97).toChar().toString();
        }

        return Lang.format("$1$$2$", [bearing, windspeed]);
    }

    function getFeelsLike() as String {
        var fl = "";
        var tempUnit = getTempUnit();
        if(weatherCondition != null and weatherCondition.feelsLikeTemperature != null) {
            var fltemp = formatTemperature(weatherCondition.feelsLikeTemperature, tempUnit);
            fl = Lang.format("FL:$1$$2$", [fltemp.format(INTEGER_FORMAT), tempUnit]);
        }

        return fl;
    }

    function getHumidity() as String {
        var ret = "";
        if(weatherCondition != null and weatherCondition.relativeHumidity != null) {
            ret = Lang.format("$1$%", [weatherCondition.relativeHumidity]);
        }
        return ret;
    }

    function getHighLow() as String {
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

    function getPrecip() as String {
        var ret = "";
        if(weatherCondition != null and weatherCondition.precipitationChance != null) {
            ret = Lang.format("$1$%", [weatherCondition.precipitationChance.format("%d")]);
        }
        return ret;
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

    hidden function secondaryTimezone(offset, width) {
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
