      (function() {
        var plot1;
        plot1 = $.jqplot(
          "BTC-DOGE_candle",
          [
            [] 
          ],
          {
            title: '07/31-17:00 ~ 08/02-17:00',
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
                  min: '2015-07-31 16:00',
                  max: '2015-08-02 17:00',
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
