# Segment34 MkII - Frequently asked Questions

### How do I change the settings? Where are the settings?
The settings is only available through the Garmin Connect IQ app. Go to [the page for the watch face](https://apps.garmin.com/apps/aa85d03d-ab89-4e06-b8c6-71a014198593) and look for the big blue Settings button. You can also find it if you go to Device -> My Watch Faces -> Segment34 MkII.

The settings can not be changed on the watch itself.

### Do I need to buy you a coffee to unlock features of the watch face?
**No, everything is included for free**. Donating money / buying coffee through ko-fi does not unlock anything as there is nothing to unlock, everything is already included. You are however very welcome to support me anyway if you like the watch face: [![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/M4M51A1RGV)

### How does the custom themes work?
Custom themes are best created with the [Theme designer](https://ludw.github.io). When it looks they way you want just copy the string of color codes at the bottom and enter them into the "Custom colors" field in settings for the watchface. Make sure to also select "Custom colors" as the theme.

### What are that field called in settings? What is that number?
Most fields can be configures in settings what data they should display. This picture explains what everything is called:

![explainer](explainer.png)

For watches with an AMOLED screen you have two more fields shown in the Always On Display (if activated). These are called "Always On (below clock)" and "Second Always On Field (to the right)".

### Can I press values to open widgets on the watch?
Yes, but you have to configure what to open in settings (it's towards the bottom on the settings screen). There are 5 areas that when pressed can open something:

![image explaining the areas that can be configured to open things](press_to_open.png)

## Dissapearing or hidden fields

### Why are seconds disappearing?
If you have a watch with a Memory In Pixel (MIP) display, seconds can be displayed continuously. However, doing so uses a bit more battery so I have disabled it by default. If you want to always see seconds at the cost of slightly less battery life you can enable "Show Seconds in Inactive mode (MIP Screens only)" in settings.

If you have a AMOLED screen you can enable the Always On Display to always see the hours and minutes, but updating the screen every second is not possible (this is a limitation from Garmins side, not with this watch face).

### I added the value X, and it doesn't show up, why?
If a specific value does not show up (you see an empty spot instead) it's most likely because your watch does not have that value available. As a watch face developer there is nothing I can do to make it available. 

### Why is weather (or sunset/sunrise) disappearing after a while? Why is the top part of the screen empty?
The weather fields, including also sunset and sunrise, need weather data to be able to display something. This data comes from Garmins Weather API which in turn fetches the data over bluetooth from your phone running the Garmin Connect app. If the weather data doesn't show up, make sure your watch is connected to your phone via bluetooth. You can also try restarting the watch if you can't get it to work.

## Commonly requested features

### Can you translate the watch to <language>?
I might do that in the future, but it's a lot of work, especially for languages that requires more letters than A-Z. The fonts I use all have hand drawn letters in each font size. This means adding just a few Èážȳ Łëṱțẹrš is a lot of work. I have it on my list but no promises for when this might happen.

### Will you add support for Open Weather API?
Not short term at least. I don't want to add the complexity having multiple weather data sources would mean. I've also seen that other watch faces with support for it have recieved quite a lot of negative reviews from users that can't figure out how to get a API token which makes me a bit less keen on working on this...

### Can you make the font larger / configurable?
You can check out my other watchface Segment34 MAX, it is basically the same but with larger text.