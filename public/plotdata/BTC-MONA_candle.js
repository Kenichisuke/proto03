      (function() {
        var plot1;
        plot1 = $.jqplot(
          "BTC-MONA_candle",
          [
            [["2015-07-11 21:00", 1767.3, 1835.8, 1663.3, 1663.3], ["2015-07-11 22:00", 1705.4, 1904.2, 1705.4, 1822.0], ["2015-07-11 23:00", 1884.7, 1942.4, 1784.1, 1821.8], ["2015-07-12 00:00", 1768.6, 1847.2, 1706.4, 1800.5], ["2015-07-12 01:00", 1760.7, 1774.9, 1632.8, 1695.9], ["2015-07-12 02:00", 1691.4, 1760.6, 1599.5, 1760.6], ["2015-07-12 03:00", 1783.9, 1837.8, 1694.3, 1776.0], ["2015-07-12 04:00", 1819.3, 1940.2, 1819.3, 1929.4], ["2015-07-12 05:00", 2006.7, 2124.1, 1983.2, 2076.8], ["2015-07-12 06:00", 2130.9, 2158.8, 2012.1, 2012.1], ["2015-07-12 07:00", 1941.6, 2010.4, 1775.3, 1848.0], ["2015-07-12 08:00", 1834.3, 1895.4, 1484.6, 1498.9], ["2015-07-12 09:00", 1468.9, 1509.4, 1417.6, 1430.2], ["2015-07-12 10:00", 1443.2, 1443.2, 1254.2, 1271.3], ["2015-07-12 11:00", 1269.5, 1277.7, 1164.0, 1229.1], ["2015-07-12 12:00", 1246.3, 1268.7, 1180.3, 1180.3], ["2015-07-12 13:00", 1222.8, 1297.4, 1184.9, 1257.9], ["2015-07-12 14:00", 1249.2, 1333.6, 1249.2, 1301.4], ["2015-07-12 15:00", 1274.9, 1434.8, 1274.9, 1370.8], ["2015-07-12 16:00", 1398.5, 1426.4, 1266.6, 1312.3], ["2015-07-12 17:00", 1364.9, 1403.5, 1292.1, 1390.8], ["2015-07-12 18:00", 1386.9, 1503.5, 1338.2, 1503.5], ["2015-07-12 19:00", 1557.5, 1557.5, 1438.1, 1504.9], ["2015-07-12 20:00", 1526.0, 1556.6, 1453.4, 1527.6], ["2015-07-12 21:00", 1474.6, 1523.9, 1398.3, 1399.6], ["2015-07-12 22:00", 1364.0, 1411.0, 1258.2, 1310.4], ["2015-07-12 23:00", 1299.4, 1447.6, 1299.4, 1416.5], ["2015-07-13 00:00", 1444.1, 1550.7, 1444.1, 1538.4], ["2015-07-13 01:00", 1575.2, 1808.9, 1575.2, 1808.9], ["2015-07-13 02:00", 1788.1, 1812.7, 1733.9, 1772.6], ["2015-07-13 03:00", 1809.1, 1895.1, 1792.5, 1829.8], ["2015-07-13 04:00", 1759.9, 1838.1, 1680.9, 1786.9], ["2015-07-13 05:00", 1839.5, 1940.8, 1748.7, 1940.8], ["2015-07-13 06:00", 2004.1, 2074.9, 1860.6, 1975.9], ["2015-07-13 07:00", 1983.1, 2061.3, 1927.3, 2052.3], ["2015-07-13 08:00", 1974.1, 2025.6, 1880.6, 1880.6], ["2015-07-13 09:00", 1903.7, 1999.5, 1863.4, 1937.9], ["2015-07-13 10:00", 2002.8, 2227.5, 1957.1, 2167.3], ["2015-07-13 11:00", 2100.1, 2133.0, 1869.1, 1925.2], ["2015-07-13 12:00", 1912.0, 1923.9, 1778.5, 1788.1], ["2015-07-13 13:00", 1815.7, 1854.7, 1705.1, 1753.9], ["2015-07-13 14:00", 1733.2, 1819.3, 1592.8, 1611.3], ["2015-07-13 15:00", 1654.8, 1770.7, 1654.8, 1705.2], ["2015-07-13 16:00", 1749.5, 1857.6, 1622.9, 1857.6], ["2015-07-13 17:00", 1886.6, 1900.5, 1810.0, 1810.0]] 
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
