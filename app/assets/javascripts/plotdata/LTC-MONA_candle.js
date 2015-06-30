      (function() {
        var plot1;
        plot1 = $.jqplot(
          "LTC-MONA_candle",
          [
            [] 
          ],
          {
            title: '06/28-00:00 ~ 06/30-00:55',
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
                  min: '2015-06-27 23:00',
                  max: '2015-06-30 00:00',
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
