(function() {
  var ArrayProto, FuncProto, ObjProto, addToWrapper, any, bind, breaker, ctor, each, eq, exports, hasOwnProperty, idCounter, nativeBind, nativeEvery, nativeFilter, nativeForEach, nativeIndexOf, nativeIsArray, nativeKeys, nativeLastIndexOf, nativeMap, nativeReduce, nativeReduceRight, nativeSome, noMatch, previousUnderscore, result, root, slice, toString, unescape, unshift, wrapper, _, _ref,
    __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  root = this;

  previousUnderscore = root._;

  breaker = {};

  _ref = [Array.prototype, Object.prototype, Function.prototype], ArrayProto = _ref[0], ObjProto = _ref[1], FuncProto = _ref[2];

  slice = ArrayProto.slice;

  unshift = ArrayProto.unshift;

  toString = ObjProto.toString;

  hasOwnProperty = ObjProto.hasOwnProperty;

  nativeForEach = ArrayProto.forEach;

  nativeMap = ArrayProto.map;

  nativeReduce = ArrayProto.reduce;

  nativeReduceRight = ArrayProto.reduceRight;

  nativeFilter = ArrayProto.filter;

  nativeEvery = ArrayProto.every;

  nativeSome = ArrayProto.some;

  nativeIndexOf = ArrayProto.indexOf;

  nativeLastIndexOf = ArrayProto.lastIndexOf;

  nativeIsArray = Array.isArray;

  nativeKeys = Object.keys;

  nativeBind = FuncProto.bind;

  _ = function(obj) {
    return new wrapper(obj);
  };

  if (typeof exports !== "undefined" && exports !== null) {
    if ((typeof module !== "undefined" && module !== null) && module.exports) {
      exports = module.exports = _;
    }
    exports._ = _;
  } else {
    root._ = _;
  }

  _.VERSION = '1.3.1';

  each = _.each = _.forEach = function(obj, iterator, context) {
    var i, key, _ref2;
    if (obj == null) return;
    if (nativeForEach && obj.forEach === nativeForEach) {
      return obj.forEach(iterator, context);
    } else if (obj.length === +obj.length) {
      for (i = 0, _ref2 = obj.length; 0 <= _ref2 ? i < _ref2 : i > _ref2; 0 <= _ref2 ? i++ : i--) {
        if (i in obj && iterator.call(context, obj[i], i, obj) === breaker) return;
      }
    } else {
      for (key in obj) {
        if (_.has(obj, key) && iterator.call(context, obj[key], key, obj) === breaker) {
          return;
        }
      }
    }
  };

  _.map = _.collect = function(obj, iterator, context) {
    var results;
    results = [];
    if (obj == null) return results;
    if (nativeMap && obj.map === nativeMap) return obj.map(iterator, context);
    each(obj, function(value, index, list) {
      return results.push(iterator.call(context, value, index, list));
    });
    if (obj.length === +obj.length) results.length = obj.length;
    return results;
  };

  _.reduce = _.foldl = _.inject = function(obj, iterator, memo, context) {
    var initial;
    initial = arguments.length > 2;
    if (obj == null) obj = [];
    if (nativeReduce && obj.reduce === nativeReduce) {
      if (context) iterator = _.bind(iterator, context);
      if (initial) {
        return obj.reduce(iterator, memo);
      } else {
        return obj.reduce(iterator);
      }
    }
    each(obj, function(value, index, list) {
      if (!initial) {
        memo = value;
        return initial = true;
      } else {
        return memo = iterator.call(context, memo, value, index, list);
      }
    });
    if (!initial) {
      throw new TypeError('Reduce of empty array with no initial value');
    }
    return memo;
  };

  _.reduceRight = _.foldr = function(obj, iterator, memo, context) {
    var initial, reversed;
    initial = arguments.length > 2;
    if (obj == null) obj = [];
    if (nativeReduceRight && obj.reduceRight === nativeReduceRight) {
      if (context) iterator = _.bind(iterator, context);
      if (initial) {
        return obj.reduceRight(iterator, memo);
      } else {
        return obj.reduceRight(iterator);
      }
    }
    reversed = _.toArray(obj).reverse();
    if (context && !initial) iterator = _.bind(iterator, context);
    if (initial) {
      return _.reduce(reversed, iterator, memo, context);
    } else {
      return _.reduce(reversed, iterator);
    }
  };

  _.find = _.detect = function(obj, iterator, context) {
    var result;
    result = void 0;
    any(obj, function(value, index, list) {
      if (iterator.call(context, value, index, list)) {
        result = value;
        return true;
      }
    });
    return result;
  };

  _.filter = _.select = function(obj, iterator, context) {
    var results;
    results = [];
    if (obj == null) return results;
    if (nativeFilter && obj.filter === nativeFilter) {
      return obj.filter(iterator, context);
    }
    each(obj, function(value, index, list) {
      if (iterator.call(context, value, index, list)) {
        return results[results.length] = value;
      }
    });
    return results;
  };

  _.reject = function(obj, iterator, context) {
    var results;
    results = [];
    if (obj == null) return results;
    each(obj, function(value, index, list) {
      if (!iterator.call(context, value, index, list)) {
        return results[results.length] = value;
      }
    });
    return results;
  };

  _.every = _.all = function(obj, iterator, context) {
    var result;
    result = true;
    if (obj == null) return result;
    if (nativeEvery && obj.every === nativeEvery) {
      return obj.every(iterator, context);
    }
    each(obj, function(value, index, list) {
      if (!(result = result && iterator.call(context, value, index, list))) {
        return breaker;
      }
    });
    return result;
  };

  any = _.some = _.any = function(obj, iterator, context) {
    var result;
    iterator || (iterator = _.identity);
    result = false;
    if (obj == null) return result;
    if (nativeSome && obj.some === nativeSome) return obj.some(iterator, context);
    each(obj, function(value, index, list) {
      if (result || (result = iterator.call(context, value, index, list))) {
        return breaker;
      }
    });
    return !!result;
  };

  _.include = _.contains = function(obj, target) {
    var found;
    found = false;
    if (obj == null) return found;
    if (nativeIndexOf && obj.indexOf === nativeIndexOf) {
      return obj.indexOf(target) !== -1;
    }
    found = any(obj, function(value) {
      return value === target;
    });
    return found;
  };

  _.invoke = function(obj, method) {
    var args;
    args = slice.call(arguments, 2);
    return _.map(obj, function(value) {
      return (_.isFunction(method) ? method || value : value[method]).apply(value, args);
    });
  };

  _.pluck = function(obj, key) {
    return _.map(obj, function(value) {
      return value[key];
    });
  };

  _.max = function(obj, iterator, context) {
    var result;
    if (!iterator) {
      if (_.isArray(obj) && obj[0] === +obj[0]) return Math.max.apply(Math, obj);
      if (_.isEmpty(obj)) return -Infinity;
    }
    result = {
      computed: -Infinity
    };
    each(obj, function(value, index, list) {
      var computed;
      computed = iterator ? iterator.call(context, value, index, list) : value;
      return computed >= result.computed && (result = {
        value: value,
        computed: computed
      });
    });
    return result.value;
  };

  _.min = function(obj, iterator, context) {
    var result;
    if (!iterator) {
      if (_.isArray(obj && obj[0] === +obj[0])) return Math.min.apply(Math, obj);
      if (_.isEmpty(obj)) return Infinity;
    }
    result = {
      computed: Infinity
    };
    each(obj, function(value, index, list) {
      var computed;
      computed = iterator ? iterator.call(context, value, index, list) : value;
      return computed < result.computed && (result = {
        value: value,
        computed: computed
      });
    });
    return result.value;
  };

  _.shuffle = function(obj) {
    var rand, shuffled;
    shuffled = [];
    rand = void 0;
    each(obj, function(value, index, list) {
      if (index === 0) {
        return shuffled[0] = value;
      } else {
        rand = Math.floor(Math.random() * (index + 1));
        shuffled[index] = shuffled[rand];
        return shuffled[rand] = value;
      }
    });
    return shuffled;
  };

  _.sortBy = function(obj, iterator, context) {
    return _.pluck(_.map(obj, function(value, index, list) {
      return {
        value: value,
        criteria: iterator.call(context, value, index, list)
      };
    }).sort(function(left, right) {
      var a, b;
      a = left.criteria;
      b = right.criteria;
      if (a < b) {
        return -1;
      } else if (a > b) {
        return 1;
      } else {
        return 0;
      }
    }), 'value');
  };

  _.groupBy = function(obj, val) {
    var iterator, result;
    result = {};
    iterator = _.isFunction(val) ? val : function(obj) {
      return obj[val];
    };
    each(obj, function(value, index) {
      var key;
      key = iterator(value, index);
      return (result[key] || (result[key] = [])).push(value);
    });
    return result;
  };

  _.sortedIndex = function(array, obj, iterator) {
    var high, low, mid;
    iterator || (iterator = _.identity);
    low = 0;
    high = array.length;
    while (low < high) {
      mid = (low + high) >> 1;
      if (iterator(array[mid]) < iterator(obj)) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }
    return low;
  };

  _.toArray = function(iterable) {
    if (!iterable) return [];
    if (iterable.toArray) return iterable.toArray();
    if (_.isArray(iterable) || _.isArguments(iterable)) {
      return slice.call(iterable);
    }
    return _.values(iterable);
  };

  _.size = function(obj) {
    return _.toArray(obj).length;
  };

  _.first = _.head = function(array, n, guard) {
    if ((n != null) && !guard) {
      return slice.call(array, 0, n);
    } else {
      return array[0];
    }
  };

  _.initial = function(array, n, guard) {
    return slice.call(array, 0, array.length - (!(n != null) || guard ? 1 : n));
  };

  _.last = function(array, n, guard) {
    if ((n != null) && !guard) {
      return slice.call(array, Math.max(array.length - n, 0));
    } else {
      return array[array.length - 1];
    }
  };

  _.rest = _.tail = function(array, index, guard) {
    return slice.call(array, !(index != null) || guard ? 1 : index);
  };

  _.compact = function(array) {
    return _.filter(array, function(value) {
      return !!value;
    });
  };

  _.flatten = function(array, shallow) {
    return _.reduce(array, function(memo, value) {
      if (_.isArray(value)) return memo.concat(shallow ? value : _.flatten(value));
      memo[memo.length] = value;
      return memo;
    }, []);
  };

  _.without = function(array) {
    return _.difference(array, slice.call(arguments, 1));
  };

  _.uniq = _.unique = function(array, isSorted, iterator) {
    var initial, result;
    initial = iterator ? _.map(array, iterator) : array;
    result = [];
    _.reduce(initial, function(memo, el, i) {
      if (0 === i || (isSorted === true ? _.last(memo) !== el : !_.include(memo, el))) {
        memo.push(el);
        result.push(array[i]);
      }
      return memo;
    }, []);
    return result;
  };

  _.union = function() {
    return _.uniq(_.flatten(arguments, true));
  };

  _.intersection = _.intersect = function(array) {
    var rest;
    rest = slice.call(arguments, 1);
    return _.filter(_.uniq(array), function(item) {
      return _.every(rest, function(other) {
        return _.indexOf(other, item) >= 0;
      });
    });
  };

  _.difference = function(array) {
    var rest;
    rest = _.flatten(slice.call(arguments, 1), true);
    return _.filter(array, function(value) {
      return !_.include(rest, value);
    });
  };

  _.zip = function() {
    var args, i, length, results;
    args = slice.call(arguments);
    length = _.max(_.pluck(args, 'length'));
    results = new Array(length);
    for (i = 0; 0 <= length ? i < length : i > length; 0 <= length ? i++ : i--) {
      results[i] = _.pluck(args, "" + i);
    }
    return results;
  };

  _.indexOf = function(array, item, isSorted) {
    var i, _ref2;
    if (array == null) return -1;
    if (isSorted) {
      i = _.sortedIndex(array, item);
      if (array[i] === item) {
        return i;
      } else {
        return -1;
      }
    }
    if (nativeIndexOf && array.indexOf === nativeIndexOf) {
      return array.indexOf(item);
    }
    for (i = 0, _ref2 = array.length; 0 <= _ref2 ? i < _ref2 : i > _ref2; 0 <= _ref2 ? i++ : i--) {
      if (i in array && array[i] === item) return i;
    }
    return -1;
  };

  _.lastIndexOf = function(array, item) {
    var i, _ref2;
    if (array == null) return -1;
    if (nativeLastIndexOf && array.lastIndexOf === nativeLastIndexOf) {
      return array.lastIndexOf(item);
    }
    for (i = _ref2 = array.length; _ref2 <= 0 ? i < 0 : i > 0; _ref2 <= 0 ? i++ : i--) {
      if (i in array && array[i] === item) return i;
    }
    return -1;
  };

  _.range = function(start, stop, step) {
    var idx, len, range;
    if (arguments.length <= 1) {
      stop = start || 0;
      start = 0;
    }
    step = arguments[2] || 1;
    len = Math.max(Math.ceil((stop - start) / step), 0);
    idx = 0;
    range = new Array(len);
    while (idx < len) {
      range[idx++] = start;
      start += step;
    }
    return range;
  };

  ctor = function() {};

  _.bind = bind = function(func, context) {
    var args, bound;
    if (nativeBind && func.bind === nativeBind) {
      return nativeBind.apply(func, slice.call(arguments, 1));
    }
    if (!_.isFunction(func)) throw new TypeError;
    args = slice.call(arguments, 2);
    return bound = function() {
      var result, self;
      if (!(this instanceof bound)) {
        return func.apply(context, args.concat(slice.call(arguments)));
      }
      ctor.prototype = func.prototype;
      self = new ctor;
      result = func.apply(self, args.concat(slice.call(arguments)));
      if (Object(result) === result) return result;
      return self;
    };
  };

  _.bindAll = function(obj) {
    var funcs;
    funcs = slice.call(arguments, 1);
    if (funcs.length === 0) funcs = _.functions(obj);
    each(funcs, function(f) {
      return obj[f] = _.bind(obj[f], obj);
    });
    return obj;
  };

  _.memoize = function(func, hasher) {
    var memo;
    memo = {};
    hasher || (hasher = _.identity);
    return function() {
      var key;
      key = hasher.apply(this, arguments);
      if (_.has(memo, key)) {
        return memo[key];
      } else {
        return memo[key] = func.apply(this, arguments);
      }
    };
  };

  _.delay = function(func, wait) {
    var args;
    args = slice.call(arguments, 2);
    return setTimeout(function() {
      return func.apply(func, args);
    }, wait);
  };

  _.defer = function(func) {
    return _.delay.apply(_, [func, 1].concat(slice.call(arguments, 1)));
  };

  _.throttle = function(func, wait) {
    var args, context, more, throttling, timeout, whenDone;
    context = args = timeout = throttling = more = void 0;
    whenDone = _.debounce(function() {
      return more = throttling = false;
    }, wait);
    return function() {
      var later;
      context = this;
      args = arguments;
      later = function() {
        timeout = null;
        if (more) func.apply(context, args);
        return whenDone();
      };
      if (!timeout) timeout = setTimeout(later, wait);
      if (throttling) {
        more = true;
      } else {
        func.apply(context, args);
      }
      whenDone();
      return throttling = true;
    };
  };

  _.debounce = function(func, wait, immediate) {
    var timeout;
    timeout = null;
    return function() {
      var args, later,
        _this = this;
      args = arguments;
      later = function() {
        timeout = null;
        if (!immediate) return func.apply(_this, args);
      };
      if (immediate && !timeout) func.apply(this, args);
      clearTimeout(timeout);
      return timeout = setTimeout(later, wait);
    };
  };

  _.once = function(func) {
    var memo, ran;
    ran = false;
    memo = void 0;
    return function() {
      if (ran) return memo;
      ran = true;
      return memo = func.apply(this, arguments);
    };
  };

  _.wrap = function(func, wrapper) {
    return function() {
      var args;
      args = [func].concat(slice.call(arguments, 0));
      return wrapper.apply(this, args);
    };
  };

  _.compose = function() {
    var funcs;
    funcs = arguments;
    return function() {
      var args, i, _ref2;
      args = arguments;
      for (i = _ref2 = funcs.length - 1; _ref2 <= -1 ? i < -1 : i > -1; _ref2 <= -1 ? i++ : i--) {
        args = [funcs[i].apply(this, args)];
      }
      return args[0];
    };
  };

  _.after = function(times, func) {
    if (times <= 0) return func();
    return function() {
      if (--times < 1) return func.apply(this, arguments);
    };
  };

  _.keys = nativeKeys || function(obj) {
    var key, keys;
    if (obj !== Object(obj)) throw new TypeError('Invalid object');
    keys = [];
    for (key in obj) {
      if (_.has(obj, key)) keys[keys.length] = key;
    }
    return keys;
  };

  _.values = function(obj) {
    return _.map(obj, _.identity);
  };

  _.functions = _.methods = function(obj) {
    var key, names;
    names = [];
    for (key in obj) {
      if (_.isFunction(obj[key])) names.push(key);
    }
    return names.sort();
  };

  _.extend = function(obj) {
    each(slice.call(arguments, 1), function(source) {
      var prop, _results;
      _results = [];
      for (prop in source) {
        _results.push(obj[prop] = source[prop]);
      }
      return _results;
    });
    return obj;
  };

  _.defaults = function(obj) {
    each(slice.call(arguments, 1), function(source) {
      var prop;
      for (prop in source) {
        if (obj[prop] == null) obj[prop] = source[prop];
      }
    });
    return obj;
  };

  _.clone = function(obj) {
    if (!_.isObject(obj)) return obj;
    if (_.isArray(obj)) {
      return obj.slice();
    } else {
      return _.extend({}, obj);
    }
  };

  _.tap = function(obj, interceptor) {
    interceptor(obj);
    return obj;
  };

  eq = function(a, b, stack) {
    var className, funcName, key, length, result, size;
    if (a === b) return a !== 0 || 1 / a === 1 / b;
    if (!(a != null) || !(b != null)) return a === b;
    if (a._chain) a = a._wrapped;
    if (b._chain) b = b._wrapped;
    if (a.isEqual && _.isFunction(a.isEqual)) return a.isEqual(b);
    if (b.isEqual && _.isFunction(b.isEqual)) return b.isEqual(a);
    className = toString.call(a);
    if (className !== toString.call(b)) return false;
    className = className.match(/[A-Z]\w+/)[0];
    switch (className) {
      case 'String':
        return a === String(b);
      case 'Number':
        if (a !== +a) {
          return b !== +b;
        } else {
          if (a === 0) {
            return 1 / a === 1 / b;
          } else {
            return a === +b;
          }
        }
      case 'Date':
      case 'Boolean':
        return +a === +b;
      case 'RegExp':
        result = true;
        for (funcName in ['source', 'global', 'multiline', 'ignoreCase']) {
          result = result && (a[funcName] === b[funcName]);
        }
        return result;
    }
    if (typeof a !== 'object' || typeof b !== 'object') return false;
    length = stack.length;
    while (length--) {
      if (stack[length] === a) return true;
    }
    stack.push(a);
    size = 0;
    result = true;
    if (className === 'Array') {
      size = a.length;
      result = size === b.length;
      if (result) {
        while (size--) {
          if (!(result = __indexOf.call(a, size) >= 0 === __indexOf.call(b, size) >= 0 && eq(a[size], b[size], stack))) {
            break;
          }
        }
      }
    } else {
      if ('constructor' in a !== 'constructor' in b || a.constructor !== b.constructor) {
        return false;
      }
      for (key in a) {
        if (_.has(a, key)) {
          size++;
          if (!(result = _.has(b, key) && eq(a[key], b[key], stack))) break;
        }
      }
      if (result) {
        for (key in b) {
          if (hasOwnProperty.call(b, key) && !(size--)) break;
        }
        result = !size;
      }
    }
    stack.pop();
    return result;
  };

  _.isEqual = function(a, b) {
    return eq(a, b, []);
  };

  _.isEmpty = function(obj) {
    var key;
    if (obj == null) return true;
    if (_.isArray(obj || _.isString(obj))) return obj.length === 0;
    for (key in obj) {
      if (_.has(obj, key)) return false;
    }
    return true;
  };

  _.isElement = function(obj) {
    return !!(obj && obj.nodeType === 1);
  };

  _.isObject = function(obj) {
    return obj === Object(obj);
  };

  'Arguments Function Number String Date RegExp'.replace(/[^, ]+/g, function(typeName) {
    return _["is" + typeName] = function(obj) {
      return toString.call(obj) === ("[object " + typeName + "]");
    };
  });

  if (!_.isArguments(arguments)) {
    _.isArguments = function(obj) {
      return !!(obj && _.has(obj, 'callee'));
    };
  }

  _.isArray = nativeIsArray || function(obj) {
    return toString.call(obj === '[object Array]');
  };

  _.isBoolean = function(obj) {
    return obj === true || obj === false || toString.call(obj === '[object Boolean]');
  };

  _.isNaN = function(obj) {
    return obj !== obj;
  };

  _.isNull = function(obj) {
    return obj === null;
  };

  _.isUndefined = function(obj) {
    return obj === void 0;
  };

  _.has = function(obj, key) {
    return hasOwnProperty.call(obj, key);
  };

  _.noConflict = function() {
    root._ = previousUnderscore;
    return this;
  };

  _.identity = function(value) {
    return value;
  };

  _.times = function(n, iterator, context) {
    var i, _results;
    _results = [];
    for (i = 0; 0 <= n ? i < n : i > n; 0 <= n ? i++ : i--) {
      _results.push(iterator.call(context, i));
    }
    return _results;
  };

  _.escape = function(string) {
    return ("" + string).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&qout;").replace(/'/g, "&#x27;").replace(/\//g, "&#x2F;");
  };

  _.mixin = function(obj) {
    return each(_.functions(obj), function(name) {
      return addToWrapper(name, _[name] = obj[name]);
    });
  };

  idCounter = 0;

  _.uniqueId = function(prefix) {
    var id;
    id = idCounter++;
    if (prefix) {
      return prefix + id;
    } else {
      return id;
    }
  };

  _.templateSettings = {
    evaluate: /<%([\s\S]+?)%>/g,
    interpolate: /<%=([\s\S]+?)%>/g,
    escape: /<%-([\s\S]+?)%>/g
  };

  noMatch = /.^/;

  unescape = function(code) {
    return code.replace(/\\\\/g, '\\').replace(/\\'/g, "'");
  };

  _.template = function(str, data) {
    var c, func, tmpl;
    c = _.templateSettings;
    tmpl = "    var __p = [], print = function() {        __p.push.apply(__p,arguments);    };    with(obj || {}) {        __p.push('" + (str.replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(c.escape || noMatch, function(match, code) {
      return "', _.escape(" + (unescape(code)) + "), '";
    }).replace(c.interpolate || noMatch, function(match, code) {
      return "', " + (unescape(code)) + ", '";
    }).replace(c.evaluate || noMatch, function(match, code) {
      return "'); " + (unescape(code).replace(/[\r\n\t]/g, ' ')) + "; __p.push('";
    }).replace(/\r/g, '\\r').replace(/\r/g, '\\r').replace(/\n/g, '\\n').replace(/\t/g, '\\t')) + "');    }    return __p.join('');";
    func = new Function('obj', '_', tmpl);
    if (data) return func(data, _);
    return function(data) {
      return func.call(this, data, _);
    };
  };

  _.chain = function(obj) {
    return _(obj).chain();
  };

  wrapper = _.wrapper = function(obj) {
    this._wrapped = obj;
  };

  _.prototype = wrapper.prototype;

  result = function(obj, chain) {
    if (chain) {
      return _(obj).chain();
    } else {
      return obj;
    }
  };

  addToWrapper = function(name, func) {
    return wrapper.prototype[name] = function() {
      var args;
      args = slice.call(arguments);
      unshift.call(args, this._wrapped);
      return result(func.apply(_, args), this._chain);
    };
  };

  _.mixin(_);

  each(['pop', 'push', 'reverse', 'shift', 'sort', 'splice', 'unshift'], function(name) {
    var method;
    method = ArrayProto[name];
    return wrapper.prototype[name] = function() {
      var length, wrapped;
      wrapped = this._wrapped;
      method.apply(wrapped, arguments);
      length = wrapped.length;
      if ((name === 'shift' || name === 'splice') && length === 0) {
        delete wrapped[0];
      }
      return result(wrapped, this._chain);
    };
  });

  each(['concat', 'join', 'slice'], function(name) {
    var method;
    method = ArrayProto[name];
    return wrapper.prototype[name] = function() {
      return result(method.apply(this._wrapped, arguments), this._chain);
    };
  });

  wrapper.prototype.chain = function() {
    this._chain = true;
    return this;
  };

  wrapper.prototype.value = function() {
    return this._wrapped;
  };

}).call(this);
