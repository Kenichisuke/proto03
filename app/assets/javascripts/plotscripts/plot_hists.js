g_timer2 = null

$(document).on('ready page:change', function() {
  if ($('#BTC-MONA_hist_ja').get(0)) {
    (function showg1() {
      clearTimeout(g_timer2);
      $('#BTC-MONA_hist_ja').load('/plotdata/BTC-MONA_hist_ja.html');
      g_timer2 = setTimeout(function() {
        showg1();
      }, 100 * 1000);
      console.log("g_timer2: " + g_timer2)
    })();
  } 
  else if ($('#BTC-MONA_hist_en').get(0)) {
    console.log('debug');
    (function showg2() {
      clearTimeout(g_timer2);
      $('#BTC-MONA_hist_en').load('/plotdata/BTC-MONA_hist_en.html');
      g_timer2 = setTimeout(function() {
        showg2();
      }, 100 * 1000);
      console.log("g_timer2: " + g_timer2)
    })();
  } 
  else if ($('#BTC-LTC_hist_ja').get(0)) {
    (function showg3() {
      clearTimeout(g_timer2);
      $('#BTC-LTC_hist_ja').load('/plotdata/BTC-LTC_hist_ja.html');
      g_timer2 = setTimeout(function() {
        showg3();
      }, 100 * 1000);
      console.log("g_timer2: " + g_timer2)
    })();
  } 
  else if ($('#BTC-LTC_hist_en').get(0)) {
    (function showg4() {
      clearTimeout(g_timer2);
      $('#BTC-LTC_hist_en').load('/plotdata/BTC-LTC_hist_en.html');
      g_timer2 = setTimeout(function() {
        showg4();
      }, 100 * 1000);
      console.log("g_timer2: " + g_timer2)
    })();
  } 
  else if ($('#LTC-MONA_hist_ja').get(0)) {
    (function showg5() {
      clearTimeout(g_timer2);
      $('#LTC-MONA_hist_ja').load('/plotdata/LTC-MONA_hist_ja.html');
      g_timer2 = setTimeout(function() {
        showg5();
      }, 100 * 1000);
      console.log("g_timer2: " + g_timer2)
    })();
  } 
  else if ($('#LTC-MONA_hist_en').get(0)) {
    (function showg6() {
      clearTimeout(g_timer2);
      $('#LTC-MONA_hist_en').load('/plotdata/LTC-MONA_hist_en.html');
      g_timer2 = setTimeout(function() {
        showg6();
      }, 100 * 1000);
      console.log("g_timer2: " + g_timer2)
    })();
  } 
  else if (g_timer2) {
    console.log("will remove g_timer2: " + g_timer2);
    clearTimeout(g_timer2);
    g_timer2 = null;
    console.log("removed");
  }
});


