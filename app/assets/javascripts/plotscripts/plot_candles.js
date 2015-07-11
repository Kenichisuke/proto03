
g_timer = null

$(document).on('ready page:change', function() {
  if ($('#BTC-LTC_candle').get(0)) {
    console.log("#BTC-LTC_candle, start set time out");
    (function showg2() {
      clearTimeout(g_timer);
      $.getScript('/plotdata/BTC-LTC_candle.js');
      g_timer = setTimeout(function() {
        showg2();
      }, 100 * 1000);
      console.log("g_timer: " + g_timer)
    })();
  }
  else if ($('#BTC-MONA_candle').get(0)) {
    console.log("#BTC-MONA_candle, start set time out");
    (function showg1() {
      clearTimeout(g_timer);
      $.getScript("/plotdata/BTC-MONA_candle.js");
      g_timer = setTimeout(function() {
        showg1();
      }, 10 * 1000);
      console.log("g_timer: " + g_timer)
    })();
  } 
  else if ($('#BTC-DOGE_candle').get(0)) {
    (function showg1() {
      clearTimeout(g_timer);
      $.getScript("/plotdata/BTC-DOGE_candle.js");
      g_timer = setTimeout(function() {
        showg1();
      }, 10 * 1000);
      console.log("g_timer: " + g_timer)
    })();
  } 
  else if ($('#LTC-MONA_candle').get(0)) {
    console.log("#LTC-MONA_candle, start set time out");
    (function showg3() {
      clearTimeout(g_timer);
      $.getScript('/plotdata/LTC-MONA_candle.js');
      g_timer = setTimeout(function() {
        showg3();
      }, 100 * 1000);
      console.log("g_timer: " + g_timer)
    })();
  } 
  else if ($('#LTC-DOGE_candle').get(0)) {
    console.log("#LTC-DOGE_candle, start set time out");
    (function showg3() {
      clearTimeout(g_timer);
      $.getScript('/plotdata/LTC-DOGE_candle.js');
      g_timer = setTimeout(function() {
        showg3();
      }, 100 * 1000);
      console.log("g_timer: " + g_timer)
    })();
  } 
  else if ($('#MONA-DOGE_candle').get(0)) {
    console.log("#MONA-DOGE_candle, start set time out");
    (function showg3() {
      clearTimeout(g_timer);
      $.getScript('/plotdata/MONA-DOGE_candle.js');
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