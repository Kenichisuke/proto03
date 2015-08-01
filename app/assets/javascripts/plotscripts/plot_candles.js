
g_timer = null

$(document).on('ready page:change', function() {
  if ($('#BTC-LTC_candle').get(0)) {
    (function showg2() {
      clearTimeout(g_timer);
      $.getScript('/plotdata/BTC-LTC_candle.js');
      g_timer = setTimeout(function() {
        showg2();
      }, 100 * 1000);
    })();
  }
  else if ($('#BTC-MONA_candle').get(0)) {
    (function showg1() {
      clearTimeout(g_timer);
      $.getScript("/plotdata/BTC-MONA_candle.js");
      g_timer = setTimeout(function() {
        showg1();
      }, 10 * 1000);
    })();
  } 
  else if ($('#BTC-DOGE_candle').get(0)) {
    (function showg1() {
      clearTimeout(g_timer);
      $.getScript("/plotdata/BTC-DOGE_candle.js");
      g_timer = setTimeout(function() {
        showg1();
      }, 10 * 1000);
    })();
  } 
  else if ($('#LTC-MONA_candle').get(0)) {
    (function showg3() {
      clearTimeout(g_timer);
      $.getScript('/plotdata/LTC-MONA_candle.js');
      g_timer = setTimeout(function() {
        showg3();
      }, 100 * 1000);
    })();
  } 
  else if ($('#LTC-DOGE_candle').get(0)) {
    (function showg3() {
      clearTimeout(g_timer);
      $.getScript('/plotdata/LTC-DOGE_candle.js');
      g_timer = setTimeout(function() {
        showg3();
      }, 100 * 1000);
    })();
  } 
  else if ($('#MONA-DOGE_candle').get(0)) {
    (function showg3() {
      clearTimeout(g_timer);
      $.getScript('/plotdata/MONA-DOGE_candle.js');
      g_timer = setTimeout(function() {
        showg3();
      }, 100 * 1000);
    })();
  } 
  else if (g_timer) {
    clearTimeout(g_timer);
    g_timer = null;
  }
});