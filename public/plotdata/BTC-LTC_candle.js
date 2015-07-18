      (function() {
        var plot1;
        plot1 = $.jqplot(
          "BTC-LTC_candle",
          [
            [["2015-07-17 16:00", 10.0, 10.0, 10.0, 10.0], ["2015-07-17 17:00", 10.0, 10.0, 10.0, 10.0]] 
          ],
          {
            title: '07/16-11:00 ~ 07/18-11:00',
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
                  min: '2015-07-16 10:00',
                  max: '2015-07-18 11:00',
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
