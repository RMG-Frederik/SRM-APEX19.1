var alv = {};
alv.util = {
        trim: function(t) {
            return t.replace(/^\s+|\s+$/g, "")
        },
        replaceCharInString: function(t, s, e) {
            return t.substr(0, s) + (e + "") + t.substr(s + (e + "").length)
        },
        getPageItemValue: function(t) {
            return (t + "").substring(0, 2) === "#P" ? $(t).val() : t
        },
        getConditionResult: function(pExpression) {
            var expressionResult = !0;
            return pExpression.length && (expressionResult = eval(pExpression)),
                expressionResult
        },
        getNumberFromString: function(t) {
            return (t + "").length ? Number(t) : ""
        },
        getDateFromString: function(t) {
            var s = t.split("/"),
                e = parseInt(s[2]),
                i = parseInt(s[1], 10),
                a = parseInt(s[0], 10);
            return new Date(e, i - 1, a)
        },
        convertDate: function(t, s) {
            var e, i, a, n = s.toUpperCase(),
                r = n.replace(/[A-Z]+/g, ""),
                l = t.replace(/\d+/g, "");
            return t.length === s.length && l === r && (e = n.indexOf("DD") === -1 ? "xx" : t.substring(n.indexOf("DD"), n.indexOf("DD") + 2),
                    i = n.indexOf("MM") === -1 ? "xx" : t.substring(n.indexOf("MM"), n.indexOf("MM") + 2),
                    a = n.indexOf("YYYY") === -1 ? n.indexOf("RRRR") === -1 ? n.indexOf("YY") === -1 ? n.indexOf("RR") === -1 ? "xxxx" : t.substring(n.indexOf("RR"), n.indexOf("RR") + 2) : t.substring(n.indexOf("YY"), n.indexOf("YY") + 2) : t.substring(n.indexOf("RRRR"), n.indexOf("RRRR") + 4) : t.substring(n.indexOf("YYYY"), n.indexOf("YYYY") + 4)),
                e + "/" + i + "/" + a
        }
    },
    alv.validators = {
        util: alv.util,
        isEmpty: function(t) {
            return t === ""
        },
        isEqual: function(t, s) {
            return t === s
        },
        regex: function(t, s) {
            return RegExp(s).test(t) || this.isEmpty(t)
        },
        isAlphanumeric: function(t) {
            return this.regex(t, /^[a-z0-9]+$/i)
        },
        isNumber: function(t) {
            return this.regex(t, /^-?(?:\d+|\d{1,3}(?:,\d{3})+)?(?:\.\d+)?$/)
        },
        isDigit: function(t) {
            return this.regex(t, /^\d+$/)
        },
        isEmail: function(t) {
            return this.regex(t, /^[^\s@]+@[^\s@]+\.[^\s@]+$/)
        },
        isUrl: function(t) {
            return this.regex(t, /(http|ftp|https):\/\/[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:\/~+#-]*[\w@?^=%&amp;\/~+#-])?/)
        },
        isDate: function(t, s) {
            var e = RegExp("^(3[01]|[12][0-9]|0?[1-9])/(1[0-2]|0?[1-9])/(?:[0-9]{2})?[0-9]{2}$"),
                i = this.util.convertDate(t, s);
            if (i.match(e)) {
                var a = i.split("/"),
                    n = parseInt(a[2]),
                    r = parseInt(a[1], 10),
                    l = parseInt(a[0], 10),
                    o = new Date(n, r - 1, l);
                if (o.getMonth() + 1 === r && o.getDate() === l && o.getFullYear() === n)
                    return !0
            }
            return this.isEmpty(t)
        },
        minLength: function(t, s) {
            return t.length >= s || this.isEmpty(t)
        },
        maxLength: function(t, s) {
            return s >= t.length || this.isEmpty(t)
        },
        rangeLength: function(t, s, e) {
            return this.minLength(t, s) && this.maxLength(t, e) || this.isEmpty(t)
        },
        minNumber: function(t, s) {
            return !this.isEmpty(t) && !this.isEmpty(s) && this.isNumber(t) && this.isNumber(s) ? t >= s : !0
        },
        maxNumber: function(t, s) {
            return !this.isEmpty(t) && !this.isEmpty(s) && this.isNumber(t) && this.isNumber(s) ? s >= t : !0
        },
        rangeNumber: function(t, s, e) {
            return this.isEmpty(t) || this.isEmpty(s) || this.isEmpty(e) || !(this.isNumber(t) && this.isNumber(s) && this.isNumber(e)) || s > e ? !0 : this.minNumber(t, s) && this.maxNumber(t, e)
        },
        minCheck: function(t, s, e) {
            var i = $(t).filter(":checked").length;
            return e ? this.minNumber(i, s) || i === 0 : this.minNumber(i, s)
        },
        maxCheck: function(t, s) {
            var e = $(t).filter(":checked").length;
            return this.maxNumber(e, s) || e === 0
        },
        rangeCheck: function(t, s, e) {
            var i = $(t).filter(":checked").length;
            return this.rangeNumber(i, s, e) || i === 0
        },
        minDate: function(t, s, e) {
            var i = new Date,
                a = new Date;
            return !this.isEmpty(t) && !this.isEmpty(s) && this.isDate(t, e) && this.isDate(s, e) ? (i = this.util.getDateFromString(this.util.convertDate(t, e)),
                a = this.util.getDateFromString(this.util.convertDate(s, e)),
                i >= a) : !0
        },
        maxDate: function(t, s, e) {
            var i = new Date,
                a = new Date;
            return !this.isEmpty(t) && !this.isEmpty(s) && this.isDate(t, e) && this.isDate(s, e) ? (i = this.util.getDateFromString(this.util.convertDate(t, e)),
                a = this.util.getDateFromString(this.util.convertDate(s, e)),
                a >= i) : !0
        },
        rangeDate: function(t, s, e, i) {
            var a = new Date,
                n = new Date,
                r = new Date;
            return this.isEmpty(t) || this.isEmpty(s) || this.isEmpty(e) || !(this.isDate(t, i) && this.isDate(s, i) && this.isDate(e, i)) || (a = this.util.getDateFromString(this.util.convertDate(t, i)),
                n = this.util.getDateFromString(this.util.convertDate(s, i)),
                r = this.util.getDateFromString(this.util.convertDate(e, i)),
                n > r) ? !0 : a >= n && r >= a
        }
    },
    function($, util, validators) {
        "use strict";
        $.fn.alv = function(method, options) {
            function restorePluginSettings(t) {
                var s = $(t);
                return s.data(constants.pluginId) !== void 0 ? ($.extend(settings, s.data(constants.pluginId)), !0) : !1
            }

            function extendSettings(t) {
                t && $.extend(settings, t)
            }

            function bindSettings(t, s) {
                extendSettings(s),
                    $(t).data(constants.pluginId, settings)
            }

            function init(t) {
                var s = $(t),
                    e = "#" + s.attr("id"),
                    i = $("body"),
                    a = settings.triggeringEvent + "." + constants.pluginPrefix,
                    n = "change." + constants.pluginPrefix;
                switch (settings.validate) {
                    case "notEmpty":
                        (s.hasClass(constants.apexCheckboxClass) || s.hasClass(constants.apexRadioClass) || s.hasClass(constants.apexShuttleClass) || s.prop("tagName") === "SELECT" || s.attr("type") === "file") && settings.triggeringEvent !== "change" && (a = a + " " + n),
                            i.delegate(e, a, isEmptyHandler);
                        break;
                    case "itemType":
                        settings.itemType === "date" && settings.triggeringEvent !== "change" && (a = a + " " + n),
                            i.delegate(e, a, itemTypeHandler);
                        break;
                    case "equal":
                        i.delegate(e, a, isEqualHandler);
                        break;
                    case "regex":
                        i.delegate(e, a, regexHandler);
                        break;
                    case "charLength":
                        i.delegate(e, a, charLengthHandler);
                        break;
                    case "numberSize":
                        i.delegate(e, a, numberSizeHandler);
                        break;
                    case "dateOrder":
                        settings.triggeringEvent !== "change" && (a = a + " " + n),
                            i.delegate(e, a, dateOrderHandler);
                        break;
                    case "totalChecked":
                        i.delegate(e, n, totalCheckedHandler);
                        break;
                    default:
                }
                return addValidationEvent(s, a),
                    t
            }

            function addValidationEvent(t, s) {
                var e = $(t),
                    i = e.data(constants.validationEvents),
                    a = !1;
                i !== void 0 ? ($.each(i.split(" "), function(t, e) {
                        e === s && (a = !0)
                    }),
                    a || e.data(constants.validationEvents, i + " " + s)) : e.data(constants.validationEvents, s)
            }

            function isEmptyHandler() {
                var t, s = setMsg(settings.errorMsg, "value required");
                allowValidation(this, constants.notEmptyClass) && (t = $(this).hasClass(constants.apexCheckboxClass) || $(this).hasClass(constants.apexRadioClass) ? !validators.minCheck($(this).find(":checkbox, :radio"), 1, !1) : $(this).hasClass(constants.apexShuttleClass) ? !$(this).find("select.shuttle_right").children().length : $(this).prop("tagName") === "SELECT" || $(this).attr("type") === "file" ? validators.isEmpty(this.value) : settings.allowWhitespace ? validators.isEmpty(this.value) : validators.isEmpty(util.trim(this.value)),
                    t && util.getConditionResult(settings.condition) ? (addValidationResult($(this), constants.notEmptyClass, "0"),
                        showMessage(this, s)) : (addValidationResult($(this), constants.notEmptyClass, "1"),
                        hideMessage(this)))
            }

            function isEqualHandler() {
                var t = setMsg(settings.errorMsg, "values do not equal");
                allowValidation(this, constants.equalClass) && validators.minLength(this.value, settings.validationMinLength) && (!validators.isEqual(this.value, $(settings.equal).val()) && util.getConditionResult(settings.condition) ? (addValidationResult($(this), constants.equalClass, "0"),
                    showMessage(this, t)) : (addValidationResult($(this), constants.equalClass, "1"),
                    hideMessage(this)))
            }

            function regexHandler() {
                var t = setMsg(settings.errorMsg, "invalid value");
                allowValidation(this, constants.regexClass) && validators.minLength(this.value, settings.validationMinLength) && (!validators.regex(this.value, settings.regex) && util.getConditionResult(settings.condition) ? (addValidationResult($(this), constants.regexClass, "0"),
                    showMessage(this, t)) : (addValidationResult($(this), constants.regexClass, "1"),
                    hideMessage(this)))
            }

            function itemTypeHandler() {
                var t, s;
                if (allowValidation(this, constants.itemTypeClass) && validators.minLength(this.value, settings.validationMinLength)) {
                    switch (settings.itemType) {
                        case "alphanumeric":
                            t = validators.isAlphanumeric(this.value),
                                s = setMsg(settings.errorMsg, "not an alphanumeric value");
                            break;
                        case "number":
                            t = validators.isNumber(this.value),
                                s = setMsg(settings.errorMsg, "not a valid number");
                            break;
                        case "digit":
                            t = validators.isDigit(this.value),
                                s = setMsg(settings.errorMsg, "not a valid digit combination");
                            break;
                        case "email":
                            t = validators.isEmail(this.value),
                                s = setMsg(settings.errorMsg, "not a valid e-mail address");
                            break;
                        case "url":
                            t = validators.isUrl(this.value),
                                s = setMsg(settings.errorMsg, "not a valid URL");
                            break;
                        case "date":
                            t = validators.isDate(this.value, settings.dateFormat),
                                s = replaceMsgVars(setMsg(settings.errorMsg, "not a valid date (&1)"), settings.dateFormat);
                            break;
                        default:
                    }!t && util.getConditionResult(settings.condition) ? (addValidationResult($(this), constants.itemTypeClass, "0"),
                        showMessage(this, s)) : (addValidationResult($(this), constants.itemTypeClass, "1"),
                        hideMessage(this))
                }
            }

            function charLengthHandler() {
                var t, s;
                allowValidation(this, constants.charLengthClass) && validators.minLength(this.value, settings.validationMinLength) && (validators.isEmpty(settings.max) ? (t = validators.minLength(this.value, settings.min),
                    s = replaceMsgVars(setMsg(settings.errorMsg, "value length too short - min. &1"), settings.min)) : validators.isEmpty(settings.min) ? (t = validators.maxLength(this.value, settings.max),
                    s = replaceMsgVars(setMsg(settings.errorMsg, "value length too long - max. &1"), settings.max)) : (t = validators.rangeLength(this.value, settings.min, settings.max),
                    s = replaceMsgVars(setMsg(settings.errorMsg, "invalid value length - between &1 and &2 only"), settings.min, settings.max)), !t && util.getConditionResult(settings.condition) ? (addValidationResult($(this), constants.charLengthClass, "0"),
                    showMessage(this, s)) : (addValidationResult($(this), constants.charLengthClass, "1"),
                    hideMessage(this)))
            }

            function numberSizeHandler() {
                var t, s, e = util.getNumberFromString(this.value),
                    i = util.getNumberFromString(util.getPageItemValue(settings.min)),
                    a = util.getNumberFromString(util.getPageItemValue(settings.max));
                allowValidation(this, constants.numberSizeClass) && validators.minLength(this.value, settings.validationMinLength) && (validators.isEmpty(settings.max) ? (t = validators.minNumber(e, i),
                    s = replaceMsgVars(setMsg(settings.errorMsg, "number too small - min. &1"), i)) : validators.isEmpty(settings.min) ? (t = validators.maxNumber(e, a),
                    s = replaceMsgVars(setMsg(settings.errorMsg, "number too large - max. &1"), a)) : (t = validators.rangeNumber(e, i, a),
                    s = replaceMsgVars(setMsg(settings.errorMsg, "invalid number size - between &1 and &2 only"), i, a)), !t && util.getConditionResult(settings.condition) ? (addValidationResult($(this), constants.numberSizeClass, "0"),
                    showMessage(this, s)) : (addValidationResult($(this), constants.numberSizeClass, "1"),
                    hideMessage(this)))
            }

            function totalCheckedHandler() {
                var t, s, e = $(this).find(":checkbox, :radio");
                allowValidation(this, constants.totalCheckedClass) && (validators.isEmpty(settings.max) ? (t = validators.minCheck(e, settings.min, !0),
                    s = replaceMsgVars(setMsg(settings.errorMsg, "please select at least &1 choice(s)"), settings.min)) : validators.isEmpty(settings.min) ? (t = validators.maxCheck(e, settings.max),
                    s = replaceMsgVars(setMsg(settings.errorMsg, "please select no more than &1 choice(s)"), settings.max)) : (t = validators.rangeCheck(e, settings.min, settings.max),
                    s = replaceMsgVars(setMsg(settings.errorMsg, "please select between &1 and &2 choice(s)"), settings.min, settings.max)), !t && util.getConditionResult(settings.condition) ? (addValidationResult($(this), constants.totalCheckedClass, "0"),
                    showMessage(this, s)) : (addValidationResult($(this), constants.totalCheckedClass, "1"),
                    hideMessage(this)))
            }

            function dateOrderHandler() {
                var t, s, e = util.getPageItemValue(settings.min),
                    i = util.getPageItemValue(settings.max);
                allowValidation(this, constants.dateOrderClass) && validators.minLength(this.value, settings.validationMinLength) && (validators.isEmpty(settings.max) ? (t = validators.minDate(this.value, e, settings.dateFormat),
                    s = replaceMsgVars(setMsg(settings.errorMsg, "this date should lie after &1"), e)) : validators.isEmpty(settings.min) ? (t = validators.maxDate(this.value, i, settings.dateFormat),
                    s = replaceMsgVars(setMsg(settings.errorMsg, "this date should lie before &1"), i)) : (t = validators.rangeDate(this.value, e, i, settings.dateFormat),
                    s = replaceMsgVars(setMsg(settings.errorMsg, "this date should lie between &1 and &2"), e, i)), !t && util.getConditionResult(settings.condition) ? (addValidationResult($(this), constants.dateOrderClass, "0"),
                    showMessage(this, s)) : (addValidationResult($(this), constants.dateOrderClass, "1"),
                    hideMessage(this)))
            }

            function showMessage(t, s) {
                var e = $(t),
                    i = '<span class="' + constants.errorMsgClass + " " + t.id + '">' + s + "</span>";
                if (e.hasClass(constants.itemErrorClass)) {
                    var a = $("span." + constants.errorMsgClass + "." + t.id),
                        n = a.index(),
                        r = e.index();
                    r > n && settings.errorMsgLocation === "before" ? a.text(s) : r > n && settings.errorMsgLocation === "after" ? (a.remove(),
                        e.after(i)) : n > r && settings.errorMsgLocation === "after" ? a.text(s) : (a.remove(),
                        e.before(i))
                } else
                    e.addClass(constants.itemErrorClass),
                    $("[for=" + t.id + "]").addClass(constants.labelErrorClass),
                    settings.errorMsgLocation === "before" ? e.before(i) : e.after(i)
            }

            function hideMessage(t) {
                var s = $(t);
                s.hasClass(constants.itemErrorClass) && (s.removeClass(constants.itemErrorClass),
                    $("[for=" + t.id + "]").removeClass(constants.labelErrorClass),
                    $("span." + constants.errorMsgClass + "." + t.id).remove())
            }

            function setMsg(t, s) {
                return validators.isEmpty(t) ? s : t
            }

            function replaceMsgVars(t) {
                for (var s = t, e = 1, i = arguments.length; i > e; e++)
                    s = s.replace("&" + e, arguments[e]);
                return s
            }

            function allowValidation(t, s) {
                var e = !0,
                    i = $(t),
                    a = i.data(constants.validationResults);
                return a !== void 0 && (a.indexOf(s) === -1 ? $.each(a.split(" "), function(t, s) {
                        e === !0 && s.slice(-1) !== "1" && (e = !1)
                    }) : i.removeData(constants.validationResults)),
                    e
            }

            function addValidationResult(t, s, e) {
                var i = $(t),
                    a = i.data(constants.validationResults),
                    n = !1,
                    r = s + ":" + e;
                a !== void 0 ? ($.each(a.split(" "), function(t, r) {
                            if (r.substr(0, r.indexOf(":")) === s) {
                                var l = a.indexOf(r) + r.length - 1;
                                a = util.replaceCharInString(a, l, e),
                                    i.data(constants.validationResults, a),
                                    n = !0
                            }
                        }),
                        n || i.data(constants.validationResults, a + " " + r)) : i.data(constants.validationResults, r),
                    e === "1" ? (settings.itemSuccess.call(this),
                        i.trigger("alvitemsuccess")) : (settings.itemFail.call(this),
                        i.trigger("alvitemfail"))
            }

            function formHasErrors(t) {
                var s, e = !1,
                    i = $(t).find("input, textarea, select, fieldset");
                return $.each(i, function() {
                        s = $(this),
                            s.data(constants.validationEvents) !== void 0 && $.each(s.data(constants.validationEvents).split(" "), function(t, e) {
                                s.trigger(e)
                            })
                    }),
                    i.hasClass(constants.itemErrorClass) && ($(i).filter("." + constants.itemErrorClass).first().focus(),
                        e = !0),
                    e
            }

            function validateFormBeforeSubmit(pFiringElem) {
                var firingElem = $(pFiringElem),
                    origClickEvent, fixErrorsMsg = setMsg(settings.errorMsg, "Please fix all errors before continuing"),
                    bodyElem = $("body"),
                    messageBoxId = "#alv-msg-box",
                    msgBox = '<div class="alv-alert-msg"><a href="#" class="alv-close" onclick="$(\'' + messageBoxId + "').children().fadeOut();return false;\">x</a><p>" + fixErrorsMsg + "</p></div>";
                firingElem.length && (firingElem.prop("tagName") === "A" ? (origClickEvent = firingElem.attr("href"),
                        firingElem.data(constants.origClickEvent, origClickEvent),
                        firingElem.removeAttr("href")) : (origClickEvent = firingElem.attr("onclick"),
                        firingElem.data(constants.origClickEvent, origClickEvent),
                        firingElem.removeAttr("onclick")),
                    bodyElem.delegate("#" + firingElem.attr("id"), "click", function() {
                        formHasErrors(settings.formsToSubmit) ? (settings.formFail.call(this),
                            firingElem.trigger("alvformfail"),
                            $(messageBoxId).length || bodyElem.append('<div id="' + messageBoxId.substring(1) + '"></div>'),
                            $(messageBoxId).html(msgBox)) : (settings.formSuccess.call(this),
                            firingElem.trigger("alvformsuccess"),
                            eval($(this).data(constants.origClickEvent)))
                    }))
            }
            var constants = {
                pluginId: "be.ctb.jq.alv",
                pluginName: "APEX Live Validation",
                pluginPrefix: "alv",
                apexCheckboxClass: "checkbox_group",
                apexRadioClass: "radio_group",
                apexShuttleClass: "shuttle"
            };
            $.extend(constants, {
                validationEvents: constants.pluginPrefix + "-valEvents",
                validationResults: constants.pluginPrefix + "-valResults",
                origClickEvent: constants.pluginPrefix + "-origClickEvent",
                notEmptyClass: constants.pluginPrefix + "-notEmpty",
                itemTypeClass: constants.pluginPrefix + "-itemType",
                equalClass: constants.pluginPrefix + "-equal",
                regexClass: constants.pluginPrefix + "-regex",
                charLengthClass: constants.pluginPrefix + "-charLength",
                numberSizeClass: constants.pluginPrefix + "-numberSize",
                dateOrderClass: constants.pluginPrefix + "-dateOrder",
                totalCheckedClass: constants.pluginPrefix + "-totalChecked",
                itemErrorClass: constants.pluginPrefix + "-item-error",
                labelErrorClass: constants.pluginPrefix + "-label-error",
                errorMsgClass: "t-Form-error"
            });
            var settings = {
                    validate: "notEmpty",
                    triggeringEvent: "blur",
                    condition: "",
                    validationMinLength: 0,
                    errorMsg: "",
                    errorMsgLocation: "after",
                    allowWhitespace: !0,
                    itemType: "",
                    dateFormat: "",
                    min: "",
                    max: "",
                    equal: "",
                    regex: "",
                    formsToSubmit: "",
                    itemSuccess: function() {},
                    itemFail: function() {},
                    formSuccess: function() {},
                    formFail: function() {}
                },
                methods = {
                    init: function(t) {
                        var s = $(this);
                        bindSettings(s, t),
                            init(s)
                    },
                    validateForm: function(t) {
                        var s = $(this);
                        bindSettings(s, t),
                            validateFormBeforeSubmit(s)
                    },
                    remove: function() {
                        var t = $(this);
                        restorePluginSettings(t) && method()
                    }
                };
            return $(this).each(function() {
                return methods[method] ? methods[method].call($(this), options) : typeof method != "object" && method ? ($.error("Method " + method + " does not exist on jQuery. " + constants.pluginName), !1) : methods.init.call($(this), method)
            })
        }
    }(jQuery, alv.util, alv.validators)