var availCalendar = (function () {

  // Config 
  const monthNames = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

  const monthFullNames = ["January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  var defaultConfig = {
    container: "", // must have
    date: new Date(),
    view: "m",
    firstY: (new Date()).getFullYear() - 9,
    lastY: (new Date()).getFullYear(),
    dateClasses: {},
    customObj: {},
    additionalFunc: function(){},
  };

  var module = {};

  module.buildComponent = function (container) {
    var container = $(container);
    var calendarWrap = "<div id='calendar-container'></div>";
    var controls = "<div class='dsh-calendar-header month-view'>" +
      "<div class='dsh-calendar-header-left'>" +
      "<a href='#' class='dsh-prev dsh-switch-btn'><i class='fa fa-angle-left'></i></a>" +
      "<a href='#' class='dsh-next dsh-switch-btn'><i class='fa fa-angle-right'></i></a>" +
      "<div class='dsh-switch-select'></div>" +
      "</div>" +
      "<div class='dsh-calendar-header-right'>" +
      "<a href='#' class='button btn-primary btn-switch-month'>Month</a>" +
      "<a href='#' class='button btn-outlined btn-switch-year'>Year</a>" +
      "</div>" +
      "</div>";
    container.empty();
    container.append(controls);
    container.append(calendarWrap);

    // Add switcher events
    $('.btn-switch-month').on('click', function (e) {
      e.preventDefault();
      if (!$(this).hasClass('btn-primary')) {
        $(this).addClass('btn-primary').removeClass('btn-outlined');
        $(this).siblings().addClass('btn-outlined').removeClass('btn-primary');
        $(this).parents('.dsh-calendar-header').addClass('month-view').removeClass('year-view');

        module.createMonthCalendar(module.date);
        module.buildMonthSwitcher(module.date.getFullYear());
      }
    });

    $('.btn-switch-year').on('click', function (e) {
      e.preventDefault();
      if (!$(this).hasClass('btn-primary')) {
        $(this).addClass('btn-primary').removeClass('btn-outlined');
        $(this).siblings().addClass('btn-outlined').removeClass('btn-primary');
        $(this).parents('.dsh-calendar-header').addClass('year-view').removeClass('month-view');

        module.createYearCalendar(module.date);
        module.buildYearSwitcher();
      }
    });

    $('.dsh-prev').on('click', function (e) {
      e.preventDefault();
      if($(this).parents(".month-view").length !== 0) {
        module.prevMonth();
      } else if ($(this).parents(".year-view").length !== 0) {
        module.prevYear();
      }
    });

    $('.dsh-next').on('click', function (e) {
      e.preventDefault();
      if($(this).parents(".month-view").length !== 0) {
        module.nextMonth();
      } else if ($(this).parents(".year-view").length !== 0) {
        module.nextYear();
      }
    });

  };

  module.buildMonthSwitcher = function (year) {
    var container = $(".dsh-switch-select"); // TO DO (Hardcode)
    var options = monthFullNames.map(function (month, index) {
      return "<option value=" + index + ">" + month + " " + year + "</option>"
    });
    var select = "<select class='ac-month-switcher'>" + options.join("") + "</select>";
    container.empty().append(select);

    $('.ac-month-switcher').val(this.date.getMonth());

    $('.ac-month-switcher').on("change", function () {
      module.setMonth($(this).val());
    });

    module.additionalFunc();
  };

  module.buildYearSwitcher = function () {
    var container = $(".dsh-switch-select"); // TO DO (Hardcode)

    var firstY = this.firstY;
    var lastY = this.lastY;

    var yearArray = [];
    while (firstY < lastY) {
      yearArray.push(firstY);
      firstY++;
    };
    yearArray.push(lastY);

    var options = yearArray.map(function (year) {
      return "<option value=" + year + ">" + year + "</option>"
    });
    var select = "<select class='ac-year-switcher'>" + options.join("") + "</select>";
    container.empty().append(select);

    $('.ac-year-switcher').val(this.date.getFullYear());

    $('.ac-year-switcher').on("change", function () {
      module.setYear($(this).val());
    });

    module.additionalFunc();
  };

  module.init = function (obj) {

    // Getting values
    if(obj) {
      var {
        container,
        view,
        date,
        firstY,
        lastY,
        dateClasses,
        customObj,
        additionalFunc,
      } = obj;
    }

    // Default values and rewritting
    this.container = container ? container : defaultConfig.container;
    this.date = date ? date : defaultConfig.date;
    this.view = view ? view : defaultConfig.view;
    this.firstY = firstY ? firstY : defaultConfig.firstY;
    this.lastY = lastY ? lastY : defaultConfig.lastY;
    this.dateClasses = dateClasses ? dateClasses : defaultConfig.dateClasses;
    this.customObj = customObj ? customObj : defaultConfig.customObj;
    this.additionalFunc = additionalFunc ? additionalFunc : defaultConfig.additionalFunc;

    this.update({}); // TO DO (Why need empty obj?)

  };

  module.update = function (obj) {

    // Getting values
    if(obj) {
      var {
        container,
        view,
        date,
        firstY,
        lastY,
        dateClasses,
        customObj,
        additionalFunc,
        dateClassesUpdateForce,
      } = obj;
    }

    // Update values and rewritting
    this.container = container ? container : this.container;
    this.date = date ? date : this.date;
    this.view = view ? view : this.view;
    this.firstY = firstY ? firstY : this.firstY;
    this.lastY = lastY ? lastY : this.lastY;
    
    if(dateClasses) {
      if(dateClassesUpdateForce) {
        this.dateClasses = dateClasses ? dateClasses : this.dateClasses;
      } else {
        var prevDateClasses = this.dateClasses;
        var newDateClasses = [];
        for (var key in dateClasses) {
          newDateClasses[key] = prevDateClasses[key].concat(dateClasses[key]);
        };
        this.dateClasses = newDateClasses;
      }
    };
    
    this.customObj = customObj ? customObj : this.customObj;
    this.additionalFunc = additionalFunc ? additionalFunc : this.additionalFunc;

    // Build grid
    if (this.view === "m") {
      this.buildComponent(this.container);
      this.createMonthCalendar(this.date);
      this.buildMonthSwitcher(this.date.getFullYear());
    };
    if (this.view === "y") {
      this.buildComponent(this.container);
      this.createYearCalendar(this.date);
      this.buildYearSwitcher();
    };
  };

  // Convert Date to String
  module.dateToStr = function (date) {
    var x = date;
    return (
              x.getFullYear() + '-' +
              String(x.getMonth() + 1).replace(/^(.)$/, "0$1") + '-' + 
              String(x.getDate()).replace(/^(.)$/, "0$1")
           );
  };

  // Check is last day
  module.isLastDay = function (dt) {
    var test = new Date(dt.getTime()),
        month = test.getMonth();
    test.setDate(test.getDate() + 1);
    return test.getMonth() !== month;
  };

  // Classes for TD
  module.calcClasses = function (date) {
    var d = date;
    var classNamesArray = [];
    var dateClasses = this.dateClasses;
    for (var key in dateClasses) {
      var arrayClasses = dateClasses[key];
      if (arrayClasses.indexOf(module.dateToStr(d)) != -1) {
        classNamesArray.push(key)
      };
    }
    return classNamesArray.join(" ");
  };

  // Custom Data
  module.calcCustomData = function (date) {
    var testDate = new Date(module.dateToStr(date)).getTime();
    var $output = "";
    if(!$.isEmptyObject(this.customObj)) {
      this.customObj.forEach(function(item) {
        var startDate = (new Date (item.booking.start_at)).getTime();
        var endDate = (new Date (item.booking.end_at)).getTime();
        if(startDate <= testDate && testDate <= endDate) {
          var periodClass;
          if(startDate == endDate) {
            periodClass = "";
          } else {
            periodClass = "period-td period-part-" + Math.ceil(Math.abs(testDate - startDate) / (1000 * 3600 * 24));
            if(endDate == testDate) {
              periodClass += " period-last";
            }
          }
          $output = '<div class="' + 'rental-show type-' + item.booking.rental_type + " " + periodClass + '">' +
          '<a href="' + item.conversation_url + '" class="rental-link" title="' + item.client.name + '">' +
          '<div class="avatar img-block rental-avatar">' +
          '<img src="' + item.client.photo + '"/>' +
          '</div>' +
          '</a>' +
          '</div>'; 
        };
      });
    }
    return $output
  };

  // Custom Classes from request
  module.calcCustomClasses = function (date) {
    var testDate = new Date(module.dateToStr(date)).getTime();
    var $output = "";
    if(!$.isEmptyObject(this.customObj)) {
      this.customObj.forEach(function(item) {
        var startDate = (new Date (item.booking.start_at)).getTime();
        var endDate = (new Date (item.booking.end_at)).getTime();
        if(startDate <= testDate && testDate <= endDate) {
          $output = item.booking.rental_type;
        };
      });
    }
    return $output
  };

  module.createMonthCalendar = function (date) {

    var year = date.getFullYear();
    var month = date.getMonth();
    var today = new Date();

    var table = '<table><tr>';
    var elem = $("#calendar-container");

    // First day of current month
    var d = new Date(year, month);

    // Getting fisrt TD day
    function getDay(date) {
      var day = date.getDay();
      if (day == 0) day = 7;
      // return day; TO DO First day of week
      return day - 1;
    };

    // First and last TD
    var firstTdDate = new Date(year, month);
    firstTdDate.setDate(firstTdDate.getDate() - getDay(d));
    var lastTdDate = new Date(year, month + 1);

    // Start dates
    for (var i = 0; i < getDay(d); i++) {
      var classNames = this.calcClasses(firstTdDate) + " " + module.calcCustomClasses(firstTdDate);
      var classNamesOld = classNames + " old";
      var customDataStr = this.calcCustomData(firstTdDate);
      table += '<td ' + 'class="' + ((d < today) ? classNamesOld : classNames) + '">' + "<div class='datebox'>" + firstTdDate.getDate() + "</div>" + customDataStr + '</td>';
      firstTdDate.setDate(firstTdDate.getDate() + 1);
    };

    // Main dates
    while (d.getMonth() == month) {

      var classNames = this.calcClasses(d) + " " + module.calcCustomClasses(d);
      var classNamesOld = classNames + " old";

      var customDataStr = this.calcCustomData(d);

      if (d > today) {

        if (d.getDate() == 1) {
          table += "<td class='" + classNames + "'>" + "<div class='datebox'>" + d.getDate() + ' ' + monthNames[d.getMonth()] + "</div>" + customDataStr + '</td>';
        } else {
          table += "<td class='" + classNames + "'>" + "<div class='datebox'>" + d.getDate() + "</div>" + customDataStr + '</td>';
        }

      } else {
        if (d.getFullYear() == today.getFullYear() && d.getMonth() == today.getMonth()) {

          if (d.getDate() < today.getDate()) {
            if (d.getDate() == 1) {
              table += '<td class="' + classNamesOld + '">' + "<div class='datebox'>" + d.getDate() + ' ' + monthNames[d.getMonth()] + "</div>" + customDataStr + '</td>';
            } else {
              table += '<td class="' + classNamesOld + '">' + "<div class='datebox'>" + d.getDate() + "</div>"  + customDataStr + '</td>';
            }
          } else if (d.getDate() == today.getDate()) {
            table += '<td class="' + classNames + '">' + "<div class='datebox'>" + d.getDate() + ' Today' + "</div>" + customDataStr + '</td>';
          } else if (d.getDate() > today.getDate()) {
            table += '<td class="' + classNames + '">' + "<div class='datebox'>" + d.getDate() + "</div>" + customDataStr + '</td>';
          }

        } else {

          if (d.getDate() == 1) {
            table += '<td class="' + classNamesOld + '">' + "<div class='datebox'>" + d.getDate() + ' ' + monthNames[d.getMonth()] + "</div>" + customDataStr + '</td>';
          } else {
            table += '<td class="' + classNamesOld + '">' + "<div class='datebox'>" + d.getDate() + "</div>" + customDataStr + '</td>';
          }

        }
      };

      if (getDay(d) % 7 == 6) {
        table += '</tr><tr>';
      };

      d.setDate(d.getDate() + 1);

    };

    // Last dates
    if (getDay(d) != 0) {
      for (var i = getDay(d); i < 7; i++) {
        // if(d < today) {
        //   classNames += " old";
        // };
        var classNames = this.calcClasses(lastTdDate) + " " + module.calcCustomClasses(lastTdDate);
        // Need Class .new
        var customDataStr = this.calcCustomData(lastTdDate);
        if (i == getDay(d)) {
          table += '<td class=' + classNames + '>' + "<div class='datebox'>" + lastTdDate.getDate() + ' ' + monthNames[lastTdDate.getMonth()] + "</div>" + customDataStr + '</td>';
        } else {
          table += '<td class=' + classNames + '>' + "<div class='datebox'>" + lastTdDate.getDate() + "</div>" + customDataStr + '</td>';
        };
        lastTdDate.setDate(lastTdDate.getDate() + 1);
      }
    }

    table += '</tr></table>';
    elem.html(table);

  };



  module.createYearCalendar = function (date) {

    var year = date.getFullYear();
    var elem = $("#calendar-container");
    var today = new Date();
    var d = new Date(year, 0);
    var table = '<div class="year-view-container">';

    // Getting fisrt TD day
    function getDay(date) {
      var day = date.getDay();
      if (day == 0) day = 7;
      // return day; TO DO First day of week
      return day - 1;
    };

    while (d.getFullYear() == year) {





      var oldDateClass = (d < today) ? "old" : "";
      var classNames = " " + this.calcClasses(d);

      var type_class = "type-yb-" + module.calcCustomClasses(d);
      
      if (d.getDate() == 1) {
        table += "<div class='year-view-month'>" +
                  "<div class='year-view-month-title'>" + 
                    monthFullNames[d.getMonth()] + " " + 
                    d.getFullYear() + 
                  "</div>" +
                  "<div class='weekdays-titles'>" +
                    "<div class='weekdays-title'>Mo</div>" +
                    "<div class='weekdays-title'>Tu</div>" +
                    "<div class='weekdays-title'>We</div>" +
                    "<div class='weekdays-title'>Th</div>" +
                    "<div class='weekdays-title'>Fr</div>" +
                    "<div class='weekdays-title'>St</div>" +
                    "<div class='weekdays-title'>Su</div>" +
                  "</div>" +
                  "<div class='year-view-month-inner'>";

        for (var i = 0; i < getDay(d); i++) {
          if(getDay(d) - i > 1) {
            table += '<div class="year-view-day prev-day"></div>';
          } else {
            table += '<div class="year-view-day prev-day last-prev-day"></div>';
          }
        };

        table += '<div class="year-view-day ' + oldDateClass + " " + type_class + " " + classNames + '">' + d.getDate() + '</div>';
      } else if (module.isLastDay(d)) {
        table += '<div class="year-view-day ' + oldDateClass + " " + type_class + " " + classNames + '">' + d.getDate() + '</div>';
        table += "</div></div>";
      } else {
        table += '<div class="year-view-day ' + oldDateClass + " " + type_class + " " + classNames + '">' + d.getDate() + '</div>';
      }

      // if (d.getDate() == 1) {
      //   if (d.getMonth() % 2 == 0) {
      //     table += '<div class="year-date-box">' + '<strong>' + d.getDate() + ' ' + monthNames[d.getMonth()] + '</strong></div>';
      //   } else {
      //     table += '<div class="year-date-box odd-row">' + '<strong>' + d.getDate() + ' ' + monthNames[d.getMonth()] + '</strong></div>';
      //   }
      // } else {
      //   if (d.getMonth() % 2 == 0) {
      //     table += '<div class="year-date-box">' + d.getDate() + '</div>';
      //   } else {
      //     table += '<div class="year-date-box odd-row">' + d.getDate() + '</div>';
      //   }
      // }

      d.setDate(d.getDate() + 1);

    };

    table += '</div>';
    elem.html(table);

  };

  module.prevMonth = function () {
    var date = this.date;
    date.setMonth(date.getMonth() - 1);
    this.date = date;
    this.createMonthCalendar(date);
    $(".ac-month-switcher").val(this.date.getMonth());
    module.additionalFunc();
  };

  module.nextMonth = function () {
    var date = this.date;
    date.setMonth(date.getMonth() + 1);
    this.date = date;
    this.createMonthCalendar(date);
    $(".ac-month-switcher").val(this.date.getMonth());
    module.additionalFunc();
  };

  module.setMonth = function (month) {
    var date = this.date;
    date.setMonth(month);
    this.date = date;
    this.createMonthCalendar(date);
  };

  module.prevYear = function () {
    var date = this.date;
    date.setYear(date.getFullYear() - 1);
    this.date = date;
    this.createYearCalendar(date);

    // TO DO Need if
    $(".ac-year-switcher").val(this.date.getFullYear());
    module.additionalFunc();
  };

  module.nextYear = function () {
    var date = this.date;
    date.setYear(date.getFullYear() + 1);
    this.date = date;
    this.createYearCalendar(date);

    // TO DO Need if
    $(".ac-year-switcher").val(this.date.getFullYear());
    module.additionalFunc();
  };

  module.setYear = function (year) {
    var date = this.date;
    date.setYear(year);
    this.date = date;
    this.createYearCalendar(date);
  };


  return module;
}());


