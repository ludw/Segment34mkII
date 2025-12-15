# Bold0
This is a fork of Segment34 mkII with stock fonts.

![Screenshot of the watchface](screenshot.png "Screenshot")

The watchface features the following (because this was included in Segment34):

- Phase of the moon with graphic display
- Heartrate or Respiration rate
- Weather (conditions, temperature and windspeed)
- Sunrise/Sunset
- Date
- Notification count
- Configurable: Active minutes / Distance / Floors / Time to Recovery / VO2 Max
- Configurable: Steps / Calories / Distance
- Battery days remaining (or percentage on some watches)
- Always on mode
- Settings in the Garmin app


## Link to the original watchface
https://github.com/ludw/Segment34mkII/


## Contributing (code)
Pull requests are welcome, but please follow the following guidelines:
- For larger changes, **please open an issue first** and discuss what you have in mind.
- Keep PRs small, don't do a lot of different changes at once.
- Explain what you have changed and why.
- Only submit code you have actually run and tested (on all supported screen sizes).
- Remeber that watch faces has to be performant and memory efficient.
  Changes that significantly increase memory use or degrade performance will be rejected.
- For optimizations, please provide memory and profiler comparisons.
- Try to keep the code in the same style as the rest of the project.
   - Indent with four spaces.
   - local variables with snake_case.
   - function and global variables names with camelCase.
   - cache all properties.
   - use comments only when they add value.
     Explain things that look strange or values that has to be looked up to be understood.

 ## TODO / Things people have asked for
- Implement/fix for other resolutions than Fenix 7 Pro (Round260)
- Check Vector Fonts just on demand (for older watches like Forerunner 255)
- Remove bars (would work only with fixed with font)
- AOD outline
- Clean code

## Change log
2025-12-15 v0.1
- First implementation for Fenix 7 Pro
