      (function() {
        var plot1;
        plot1 = $.jqplot(
          "BTC-LTC_candle",
          [
            [["2015-07-11 21:00", 32.9, 33.7, 29.3, 33.7], ["2015-07-11 22:00", 32.6, 32.8, 29.9, 32.5], ["2015-07-11 23:00", 31.8, 33.2, 29.6, 33.2], ["2015-07-12 00:00", 33.7, 34.6, 30.5, 31.9], ["2015-07-12 01:00", 32.4, 33.3, 29.6, 32.0], ["2015-07-12 02:00", 31.0, 35.1, 31.0, 33.9], ["2015-07-12 03:00", 35.4, 35.6, 33.6, 35.5], ["2015-07-12 04:00", 35.1, 39.6, 35.1, 39.4], ["2015-07-12 05:00", 40.5, 47.5, 39.9, 47.5], ["2015-07-12 06:00", 47.7, 49.3, 45.0, 45.0], ["2015-07-12 07:00", 44.2, 47.0, 44.2, 45.9], ["2015-07-12 08:00", 46.4, 48.0, 45.2, 48.0], ["2015-07-12 09:00", 46.2, 49.3, 46.2, 48.5], ["2015-07-12 10:00", 47.1, 52.4, 46.7, 52.4], ["2015-07-12 11:00", 53.8, 54.1, 50.7, 51.0], ["2015-07-12 12:00", 52.5, 54.1, 50.1, 50.1], ["2015-07-12 13:00", 49.9, 53.7, 49.9, 51.8], ["2015-07-12 14:00", 53.2, 58.6, 53.2, 53.8], ["2015-07-12 15:00", 52.0, 57.8, 52.0, 56.5], ["2015-07-12 16:00", 58.4, 60.9, 56.3, 56.3], ["2015-07-12 17:00", 54.8, 54.8, 49.2, 50.1], ["2015-07-12 18:00", 49.6, 50.4, 48.3, 50.4], ["2015-07-12 19:00", 48.6, 48.7, 46.1, 48.0], ["2015-07-12 20:00", 49.9, 50.2, 45.8, 48.4], ["2015-07-12 21:00", 47.5, 47.5, 38.3, 40.0], ["2015-07-12 22:00", 39.7, 43.1, 39.0, 41.7], ["2015-07-12 23:00", 42.1, 47.0, 41.3, 47.0], ["2015-07-13 00:00", 48.1, 51.6, 48.1, 51.6], ["2015-07-13 01:00", 51.2, 56.0, 51.2, 56.0], ["2015-07-13 02:00", 54.4, 55.0, 52.1, 52.9], ["2015-07-13 03:00", 52.6, 59.8, 51.0, 59.8], ["2015-07-13 04:00", 61.5, 67.9, 61.0, 66.7], ["2015-07-13 05:00", 67.0, 68.2, 63.5, 65.3], ["2015-07-13 06:00", 63.6, 65.3, 59.4, 65.3], ["2015-07-13 07:00", 65.4, 72.6, 65.4, 70.9], ["2015-07-13 08:00", 70.2, 70.8, 67.1, 69.8], ["2015-07-13 09:00", 71.2, 78.3, 71.2, 72.4], ["2015-07-13 10:00", 74.7, 78.5, 73.5, 73.6], ["2015-07-13 11:00", 73.2, 77.7, 71.3, 77.7], ["2015-07-13 12:00", 79.3, 79.3, 66.6, 66.6], ["2015-07-13 13:00", 69.1, 75.6, 69.1, 72.2], ["2015-07-13 14:00", 71.7, 76.2, 68.4, 76.2], ["2015-07-13 15:00", 73.3, 77.3, 68.4, 69.7], ["2015-07-13 16:00", 69.6, 69.6, 59.0, 62.1], ["2015-07-13 17:00", 62.1, 62.2, 59.4, 60.3]] 
          ],
          {
            title: '07/11-21:00 ~ 07/13-21:00',
            seriesDefaults: {
              renderer: jQuery . jqplot . OHLCRenderer,
              rendererOptions: {
                  candleStick: true,
                  fillUpBody: true,
                  fillDownBody: true,
                  upBodyColor: 'blue',
                  downBodyColor: 'red'
              }
            },
            axes:{
              xaxis:{
                  renderer: jQuery . jqplot . DateAxisRenderer,
                  min: '2015-07-11 20:00',
                  max: '2015-07-13 21:00',
                  tickInterval: '2 hours',
                  tickOptions:{
                      formatString: '%H'
                  }
              },
              yaxis: {
                  tickOptions:{formatString:'$%d'}
              }
            }
          }
        );
        plot1.replot();
        } )();
