
g_timer = null

$(document).on('ready page:change', function() {
  if ($('#BTC-MONA_candle').get(0)) {
    console.log("#BTC-MONA_candle, start set time out");
    (function showg1() {
      clearTimeout(g_timer);
      $.getScript("/assets/plotdata/BTC-MONA_candle.js");
      g_timer = setTimeout(function() {
        showg1();
      }, 10 * 1000);
      console.log("g_timer: " + g_timer)
    })();
  } 
  else if ($('#BTC-LTC_candle').get(0)) {
    console.log("#BTC-LTC_candle, start set time out");
    (function showg2() {
      clearTimeout(g_timer);
      $.getScript('/assets/plotdata/BTC-LTC_candle.js');
      g_timer = setTimeout(function() {
        showg2();
      }, 100 * 1000);
      console.log("g_timer: " + g_timer)
    })();
  } 
  else if ($('#LTC-MONA_candle').get(0)) {
    console.log("#LTC-MONA_candle, start set time out");
    (function showg3() {
      clearTimeout(g_timer);
      $.getScript('/assets/plotdata/LTC-MONA_candle.js');
      g_timer = setTimeout(function() {
        showg3();
      }, 100 * 1000);
      console.log("g_timer: " + g_timer)
    })();
  } 
  else if (g_timer) {
    console.log("will remove g_timer: " + g_timer);
    clearTimeout(g_timer);
    g_timer = null;
    console.log("removed");
  }
});