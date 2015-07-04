      (function() {
        var plot1;
        plot1 = $.jqplot(
          "BTC-LTC_candle",
          [
            [] 
          ],
          {
            title: '06/29-10:00 ~ 07/01-09:59',
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
                  min: '2015-06-29 09:00',
                  max: '2015-07-01 09:00',
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
