g_timer2 = null

$(document).on('ready page:change', function() {
  if ($('#BTC-LTC_hist_ja').get(0)) {
    (function showg3() {
      clearTimeout(g_timer2);
      $('#BTC-LTC_hist_ja').load('/plotdata/BTC-LTC_hist_ja.html');
      g_timer2 = setTimeout(function() {
        showg3();
      }, 30 * 1000);
    })();
  } 
  else if ($('#BTC-LTC_hist_en').get(0)) {
    (function showg4() {
      clearTimeout(g_timer2);
      $('#BTC-LTC_hist_en').load('/plotdata/BTC-LTC_hist_en.html');
      g_timer2 = setTimeout(function() {
        showg4();
      }, 30 * 1000);
    })();
  } 
  else if ($('#BTC-MONA_hist_ja').get(0)) {
    (function showg1() {
      clearTimeout(g_timer2);
      $('#BTC-MONA_hist_ja').load('/plotdata/BTC-MONA_hist_ja.html');
      g_timer2 = setTimeout(function() {
        showg1();
      }, 30 * 1000);
    })();
  } 
  else if ($('#BTC-MONA_hist_en').get(0)) {
    (function showg2() {
      clearTimeout(g_timer2);
      $('#BTC-MONA_hist_en').load('/plotdata/BTC-MONA_hist_en.html');
      g_timer2 = setTimeout(function() {
        showg2();
      }, 30 * 1000);
    })();
  } 
  else if ($('#BTC-DOGE_hist_ja').get(0)) {
    (function showg2() {
      clearTimeout(g_timer2);
      $('#BTC-DOGE_hist_ja').load('/plotdata/BTC-DOGE_hist_ja.html');
      g_timer2 = setTimeout(function() {
        showg2();
      }, 30 * 1000);
    })();
  }   
  else if ($('#BTC-DOGE_hist_en').get(0)) {
    (function showg2() {
      clearTimeout(g_timer2);
      $('#BTC-DOGE_hist_en').load('/plotdata/BTC-DOGE_hist_en.html');
      g_timer2 = setTimeout(function() {
        showg2();
      }, 30 * 1000);
    })();
  } 
  else if ($('#LTC-MONA_hist_ja').get(0)) {
    (function showg5() {
      clearTimeout(g_timer2);
      $('#LTC-MONA_hist_ja').load('/plotdata/LTC-MONA_hist_ja.html');
      g_timer2 = setTimeout(function() {
        showg5();
      }, 30 * 1000);
    })();
  } 
  else if ($('#LTC-MONA_hist_en').get(0)) {
    (function showg6() {
      clearTimeout(g_timer2);
      $('#LTC-MONA_hist_en').load('/plotdata/LTC-MONA_hist_en.html');
      g_timer2 = setTimeout(function() {
        showg6();
      }, 30 * 1000);
    })();
  } 
  else if ($('#LTC-DOGE_hist_ja').get(0)) {
    (function showg5() {
      clearTimeout(g_timer2);
      $('#LTC-DOGE_hist_ja').load('/plotdata/LTC-DOGE_hist_ja.html');
      g_timer2 = setTimeout(function() {
        showg5();
      }, 30 * 1000);
    })();
  } 
  else if ($('#LTC-DOGE_hist_en').get(0)) {
    (function showg6() {
      clearTimeout(g_timer2);
      $('#LTC-DOGE_hist_en').load('/plotdata/LTC-DOGE_hist_en.html');
      g_timer2 = setTimeout(function() {
        showg6();
      }, 30 * 1000);
    })();
  } 
  else if ($('#MONA-DOGE_hist_ja').get(0)) {
    (function showg5() {
      clearTimeout(g_timer2);
      $('#MONA-DOGE_hist_ja').load('/plotdata/MONA-DOGE_hist_ja.html');
      g_timer2 = setTimeout(function() {
        showg5();
      }, 30 * 1000);
    })();
  } 
  else if ($('#MONA-DOGE_hist_en').get(0)) {
    (function showg6() {
      clearTimeout(g_timer2);
      $('#MONA-DOGE_hist_en').load('/plotdata/MONA-DOGE_hist_en.html');
      g_timer2 = setTimeout(function() {
        showg6();
      }, 30 * 1000);
    })();
  } 
  else if (g_timer2) {
    clearTimeout(g_timer2);
    g_timer2 = null;
  }
});


