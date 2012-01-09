# TODO: 剔除掉 CoffeeScript 里本身就有的功能

# Baseline setup
# --------------

# Establish the root object, `window` in the browser, or `global` on the server.
root = @

# Save the previous value of the `_` variable.
previousUnderscore = root._

# Establish the object that gets returned to break out of a loop iteration.
breaker = {}

# Save bytes in the minified (but not gzipped) version:
[ArrayProto, ObjProto, FuncProto] = [Array.prototype, Object.prototype, Function.prototype]

# Create quick reference variables for speed access to core prototypes.
slice             = ArrayProto.slice
unshift           = ArrayProto.unshift
toString          = ObjProto.toString
hasOwnProperty    = ObjProto.hasOwnProperty

# All **ECMAScript 5** native function implementations that we hope to use
# are declared here.
nativeForEach     = ArrayProto.forEach
nativeMap         = ArrayProto.map
nativeReduce      = ArrayProto.reduce
nativeReduceRight = ArrayProto.reduceRight
nativeFilter      = ArrayProto.filter
nativeEvery       = ArrayProto.every
nativeSome        = ArrayProto.some
nativeIndexOf     = ArrayProto.indexOf
nativeLastIndexOf = ArrayProto.lastIndexOf
nativeIsArray     = Array.isArray
nativeKeys        = Object.keys
nativeBind        = FuncProto.bind

# Create a safe reference to the Underscore object for use below.
_ = (obj) ->
    return new wrapper obj

# Export the Underscore object for **Node.js** and **"CommonJS"**, with
# backwards-compatibility for the old `require()` API. If we're not in
# CommonJS, add `_` to the global object.
if exports?
    exports = module.exports = _ if module? and module.exports
    exports._ = _
else if typeof define is 'function' and define.amd?
    # Register as a named module with AMD.
    define 'underscore', ->
        return _
else
    # Exported as a string, for Closure Compiler "advanced" mode.
    root._ = _

# Current version.
_.VERSION = '1.2.3'



# Collection Functions
# --------------------

# The cornerstone, an `each` implementation, aka `forEach`.
# Handles objects with the built-in `forEach`, arrays, and raw objects.
# Delegates to **ECMAScript 5**'s native `forEach` if available.
each = _.each = _.forEach = (obj, iterator, context) ->
    return unless obj?
    if nativeForEach and obj.forEach is nativeForEach
        return obj.forEach(iterator, context)
    else if obj.length is +obj.length
        for i in [0...obj.length]
            # TODO: 不理解, 什么情况下 iterator.call 会返回一个 {} ?
            return if `i in obj` and iterator.call(context, obj[i], i, obj) is breaker
    else
        for key of obj
            return if hasOwnProperty.call(obj, key) and iterator.call(context, obj[key], key, obj) is breaker

# Return the results of applying the iterator to each element.
# Delegates to **ECMAScript 5**'s native `map` if available.
_.map = (obj, iterator, context) ->
    results = []
    return results unless obj?
    if nativeMap and obj.map is nativeMap
        return obj.map iterator, context
    each obj, (value, index, list) ->
        results.push iterator.call context, value, index, list
    return results

# **Reduce** builds up a single result from a list of values, aka `inject`,
# or `foldl`. Delegates to **ECMAScript 5**'s native `reduce` if available.
_.reduce = _.foldl = _.inject = (obj, iterator, memo, context) ->
    initial = arguments.length > 2
    obj = [] unless obj?
    if nativeReduce and obj.reduce is nativeReduce
        iterator = _.bind iterator, context if context
        return if initial then obj.reduce iterator, memo else obj.reduce iterator
    each obj, (value, index, list) ->
        if not initial
            memo = value
            initial = true
        else
            memo = iterator.call context, memo, value, index, list
    throw new TypeError 'Reduce of empty array with no initial value' unless initial
    return memo

# The right-associative version of reduce, also known as `foldr`.
# Delegates to **ECMAScript 5**'s native `reduceRight` if available.
_.reduceRight = _.foldr = (obj, iterator, memo, context) ->
    initial = arguments.length > 2
    obj = [] unless obj?
    if nativeReduceRight and obj.reduceRight is nativeReduceRight
        iterator = _.bind iterator, context if context
        return if initial then obj.reduceRight iterator, memo else obj.reduceRight iterator
    reversed = _.toArray(obj).reverse()
    iterator = _.bind iterator, context if context and not initial
    return if initial then _.reduce reversed, iterator, memo, context else _.reduce reversed, iterator

# Return the first value which passes a truth test. Aliased as `detect`.
# TODO: 可以正常使用，但在 UnitTest 里死活通不过
_.find = _.detect = (obj, iterator, context) ->
    result = undefined
    any obj, (value, index, list) ->
        if iterator.call context, value, index, list
            result = value
            return true
    return result

# Return all the elements that pass a truth test.
# Delegates to **ECMAScript 5**'s native `filter` if available.
# Aliased as `select`.
_.filter = _.select = (obj, iterator, context) ->
    results = []
    return results unless obj?
    return obj.filter iterator, context if nativeFilter and obj.filter is nativeFilter
    each obj, (value, index, list) ->
        results[results.length] = value if iterator.call context, value, index, list
    return results

# Return all the elements for which a truth test fails.
_.reject = (obj, iterator, context) ->
    results = []
    return results unless obj?
    each obj, (value, index, list) ->
        results[results.length] = value unless iterator.call context, value, index, list
    return results

# Determine whether all of the elements match a truth test.
# Delegates to **ECMAScript 5**'s native `every` if available.
# Aliased as `all`.
_.every = _.all = (obj, iterator, context) ->
    result = true
    return result unless obj?
    return obj.every iterator, context if nativeEvery and obj.every is nativeEvery
    each obj, (value, index, list) ->
        return breaker unless result = result and iterator.call context, value, index, list
    return result

# Determine if at least one element in the object matches a truth test.
# Delegates to **ECMAScript 5**'s native `some` if available.
# Aliased as `any`.
any = _.some = _.any = (obj, iterator, context) ->
    iterator or= _.identity
    result = false
    return result unless obj?
    return obj.some iterator, context if nativeSome and obj.some is nativeSome
    # TODO: 有趣的技巧
    each obj, (value, index, list) ->
        return breaker if result or= iterator.call context, value, index, list
    return !!result

# Determine if a given value is included in the array or object using `===`.
# Aliased as `contains`.
_.include = _.contains = (obj, target) ->
    found = false
    return found unless obj?
    return obj.indexOf(target) isnt -1 if nativeIndexOf and obj.indexOf is nativeIndexOf
    found = any obj, (value) ->
        return value is target
    return found

# Invoke a method (with arguments) on every item in a collection.
_.invoke = (obj, method) ->
    args = slice.call arguments, 2
    return _.map obj, (value) ->
        return (if _.isFunction(method) then method or value else value[method]).apply value, args

# Convenience version of a common use case of `map`: fetching a property.
_.pluck = (obj, key) ->
    return _.map obj, (value) ->
        return value[key]

# Return the maximum element or (element-based computation).
_.max = (obj, iterator, context) ->
    unless iterator
        return Math.max.apply Math, obj if _.isArray(obj)
        return -Infinity if _.isEmpty(obj)
    result = computed: -Infinity
    each obj, (value, index, list) ->
        computed = if iterator then iterator.call context, value, index, list else value
        computed >= result.computed and (result = value: value, computed: computed)
    return result.value

# Return the minimum element (or element-based computation).
_.min = (obj, iterator, context) ->
    unless iterator
        return Math.min.apply Math, obj if _.isArray obj
        return Infinity if _.isEmpty obj
    result = computed: Infinity
    each obj, (value, index, list) ->
        computed = if iterator then iterator.call context, value, index, list else value
        computed < result.computed and (result = value: value, computed: computed)
    return result.value
        
# Shuffle an array.
_.shuffle = (obj) ->
    shuffled = []
    rand = undefined
    each obj, (value, index, list) ->
        if index is 0
            shuffled[0] = value
        else
            rand = Math.floor Math.random() * (index + 1)
            shuffled[index] = shuffled[rand]
            shuffled[rand] = value
    return shuffled

# Sort the object's values by a criterion produced by an iterator.
_.sortBy = (obj, iterator, context) ->
    return _.pluck _.map(obj, (value, index, list) ->
        return value: value, criteria: iterator.call context, value, index, list
    ).sort((left, right) ->
        a = left.criteria
        b = right.criteria
        return if a < b then -1 else if a > b then 1 else 0
    ), 'value'

# Groups the object's values by a criterion. Pass either a string attribute
# to group by, or a function that returns the criterion.
_.groupBy = (obj, val) ->
    result = {}
    iterator = if _.isFunction val then val else (obj) -> return obj[val]
    each obj, (value, index) ->
        key = iterator value, index
        (result[key] or= []).push value
    return result

# Use a comparator function to figure out at what index an object should
# be inserted so as to maintain order. Uses binary search.
_.sortedIndex = (array, obj, iterator) ->
    iterator or= _.identity
    low = 0
    high = array.length
    while low < high
        mid = (low + high) >> 1
        if iterator(array[mid]) < iterator obj then low = mid + 1 else high = mid
    return low

# Safely convert anything iterable into a real, live array.
_.toArray = (iterable) ->
    return [] if not iterable
    return iterable.toArray() if iterable.toArray
    return slice.call(iterable) if _.isArray(iterable) or _.isArguments iterable
    return _.values iterable

#Return the number of elements in an object.
_.size = (obj) ->
    return _.toArray(obj).length


# Array Functions
# ---------------

# Get the first element of an array. Passing **n** will return the first N
# values in the array. Aliased as `head`. The **guard** check allows it to work
# with `_.map`.
_.first = _.head = (array, n, guard) ->
    return if n? and not guard then slice.call array, 0, n else array[0]

# Returns everything but the last entry of the array. Especcialy useful on
# the arguments object. Passing **n** will return all the values in
# the array, excluding the last N. The **guard** check allows it to work with
# `_.map`.
_.initial = (array, n, guard) ->
    return slice.call array, 0, array.length - if not n? or guard then 1 else n

# Get the last element of an array. Passing **n** will return the last N
# values in the array. The **guard** check allows it to work with `_.map`.
_.last = (array, n, guard) ->
    if n? and not guard
        return slice.call array, Math.max array.length - n, 0
    else
        return array[array.length - 1]

# Returns everything but the first entry of the array. Aliased as `tail`.
# Especially useful on the arguments object. Passing an **index** will return
# the rest of the values in the array from that index onward. The **guard**
# check allows it to work with `_.map`.
_.rest = _.tail = (array, index, guard) ->
    return slice.call array, if not index? or guard then 1 else index

# Trim out all falsy values from an array.
_.compact = (array) ->
    return _.filter array, (value) -> return !!value

# Return a completely flattened version of an array.
_.flatten = (array, shallow) ->
    return _.reduce array, (memo, value) ->
        return memo.concat(if shallow then value else _.flatten value) if _.isArray value
        memo[memo.length] = value
        return memo
    , []

# Return a version of the array that does not contain the specified value(s).
_.without = (array) ->
    return _.difference array, slice.call arguments, 1

# Produce a duplicate-free version of the array. If the array has already
# been sorted, you have the option of using a faster algorithm.
# Aliased as `unique`.
_.uniq = _.unique = (array, isSorted, iterator) ->
    initial = if iterator then _.map array, iterator else array
    result = []
    _.reduce initial, (memo, el, i) ->
        if 0 is i or (if isSorted is true then _.last(memo) isnt el else not _.include memo, el)
            memo.push el
            result.push array[i]
        return memo
    , []
    return result

# Produce an array that contains the union: each distinct element from all of
# the passed-in arrays.
_.union = ->
    _.uniq _.flatten arguments, true

# Produce an array that contains every item shared between all the
# passed-in arrays. (Aliased as "intersect" for back-compat.)
_.intersection = _.intersect = (array) ->
    rest = slice.call arguments, 1
    return _.filter _.uniq(array), (item) ->
        return _.every rest, (other) ->
            return _.indexOf(other, item) >= 0

# Take the difference between one array and a number of other arrays.
# Only the elements present in just the first array will remain.
_.difference = (array) ->
    rest = _.flatten slice.call arguments, 1
    return _.filter array, (value) -> not _.include rest, value

# Zip together multiple lists into a single array -- elements that share
# an index go together.
_.zip = ->
    args = slice.call arguments
    length = _.max _.pluck args, 'length'
    results = new Array length
    for i in [0...length]
        results[i] = _.pluck args, "" + i
    return results

# If the browser doesn't supply us with indexOf (I'm looking at you, **MSIE**),
# we need this function. Return the position of the first occurrence of an
# item in an array, or -1 if the item is not included in the array.
# Delegates to **ECMAScript 5**'s native `indexOf` if available.
# If the array is large and already in sort order, pass `true`
# for **isSorted** to use binary search.
_.indexOf = (array, item, isSorted) ->
    return -1 unless array?
    if isSorted
        i = _.sortedIndex array, item
        return if array[i] is item then i else -1
    return array.indexOf item if nativeIndexOf and array.indexOf is nativeIndexOf
    for i in [0...array.length]
        return i if `i in array` and array[i] is item
    return -1

# Delegates to **ECMAScript 5**'s native `lastIndexOf` if available.
_.lastIndexOf = (array, item) ->
    return -1 unless array?
    return array.lastIndexOf item if nativeLastIndexOf and array.lastIndexOf is nativeLastIndexOf
    for i in [array.length...0]
        return i if `i in array` and array[i] is item
    return -1


# Generate an integer Array containing an arithmetic progression. A port of
# the native Python `range()` function. See
# [the Python documentation](http://docs.python.org/library/functions.html#range).
_.range = (start, stop, step) ->
    if arguments.length <= 1
        stop = start || 0
        start = 0
    step = arguments[2] || 1

    len = Math.max Math.ceil((stop - start) / step), 0
    idx = 0
    range = new Array len

    while idx < len
        range[idx++] = start
        start += step

    return range

# Function (ahem) Functions
# ------------------

# Reusable constructor function for prototype setting.
ctor = ->

# Create a function bound to a given object (assigning `this`, and arguments,
# optionally). Binding with arguments is also known as `curry`.
# Delegates to **ECMAScript 5**'s native `Function.bind` if available.
# We check for `func.bind` first, to fail fast when `func` is undefined.
_.bind = bind = (func, context) ->
    return nativeBind.apply func, slice.call arguments, 1 if nativeBind and func.bind is nativeBind
    throw new TypeError unless _.isFunction func
    args = slice.call arguments, 2
    return bound = ->
        return func.apply context, args.concat slice.call arguments unless @ instanceof bound
        ctor.prototype = func.prototype
        self = new ctor
        result = func.apply self, args.concat slice.call arguments
        return result if Object(result) is result
        return self

# Bind all of an object's methods to that object. Useful for ensuring that
# all callbacks defined on an object belong to it.
_.bindAll = (obj) ->
    funcs = slice.call arguments, 1
    funcs = _.functions obj if funcs.length is 0
    each funcs, (f) -> obj[f] = _.bind obj[f], obj
    return obj

# Memoize an expensive function by storing its results.
_.memoize = (func, hasher) ->
    memo = {}
    hasher or= _.identity
    return ->
        key = hasher.apply @, arguments
        return if hasOwnProperty.call memo, key then memo[key] else memo[key] = func.apply @, arguments

# Delays a function for the given number of milliseconds, and then calls
# it with the arguments supplied.
_.delay = (func, wait) ->
    args = slice.call arguments, 2
    return setTimeout ->
        func.apply func, args
    , wait

# Defers a function, scheduling it to run after the current call stack has
# cleared.
_.defer = (func) ->
    return _.delay.apply _, [func, 1].concat slice.call arguments, 1

# Returns a function, that, when invoked, will only be triggered at most once
# during a given window of time.
_.throttle = (func, wait) ->
    context = args = timeout = throttling = more = undefined
    whenDone = _.debounce ->
        more = throttling = false
    , wait
    return ->
        context = @
        args = arguments
        later = ->
            timeout = null
            func.apply context, args if more
            whenDone()
        timeout = setTimeout later, wait unless timeout
        if throttling then more = true else func.apply context, args
        whenDone()
        throttling = true

# Returns a function, that, as long as it continues to be invoked, will not
# be triggered. The function will be called after it stops being called for
# N milliseconds.
_.debounce = (func, wait) ->
    timeout = null
    return ->
        args = arguments
        later = =>
            timeout = null
            func.apply @, args
        clearTimeout timeout
        timeout = setTimeout later, wait

# Returns a function that will be executed at most one time, no matter how
# often you call it. Useful for lazy initialization.
_.once = (func) ->
    ran = false
    memo = undefined
    return ->
        return memo if ran
        ran = true
        return memo = func.apply @, arguments

# Returns the first function passed as an argument to the second,
# allowing you to adjust arguments, run code before and after, and
# conditionally execute the original function.
_.wrap = (func, wrapper) ->
    return ->
        args = [func].concat slice.call arguments, 0
        return wrapper.apply @, args

# Returns a function that is the composition of a list of functions, each
# consuming the return value of the function that follows.
_.compose = ->
    funcs = arguments
    return ->
        args = arguments
        for i in [funcs.length-1...-1]
            args = [funcs[i].apply @, args]
        return args[0]

# Returns a function that will only be executed after being called N times.
_.after = (times, func) ->
    return func() if times <= 0
    return ->
        return func.apply @, arguments if --times < 1

# Object Functions
# ----------------

# Retrieve the names of an object's properties.
# Delegates to **ECMAScript 5**'s native `Object.keys`
_.keys = nativeKeys or (obj) ->
    throw new TypeError 'Invalid object' if obj isnt Object obj
    keys = []
    for key of obj
        keys[keys.length] = key if hasOwnProperty.call obj, key
        # TODO: 弄明白这个 keys.push key if hasOwnProperty.call obj, key 
        # 和上面的那句究竟有没有什么不同，或者优劣
    return keys

# Retrieve the values of an object's properties.
_.values = (obj) ->
    return _.map obj, _.identity

# Return a sorted list of the function names available on the object.
# Aliased as `methods`
_.functions = _.methods = (obj) ->
    names = []
    for key of obj
        names.push key if _.isFunction obj[key]
    return names.sort()

# Extend a given object with all the properties in passed-in object(s).
_.extend = (obj) ->
    each slice.call(arguments, 1), (source) ->
        for prop of source
            obj[prop] = source[prop] if source[prop] isnt undefined
        return
    return obj

# Fill in a given object with default properties.
_.defaults = (obj) ->
    each slice.call(arguments, 1), (source) ->
        for prop of source
            obj[prop] = source[prop] unless obj[prop]?
        return
    return obj

# Create a (shallow-cloned) duplicate of an object.
_.clone = (obj) ->
    return obj unless _.isObject obj
    return if _.isArray obj then obj.slice() else _.extend {}, obj

# Invokes interceptor with the obj, and then returns obj.
# The primary purpose of this method is to "tap into" a method chain, in
# order to perform operations on intermediate results within the chain.
_.tap = (obj, interceptor) ->
    interceptor obj
    return obj

# Internal recursive comparison function.
eq = (a, b, stack) ->
    # Identical objects are equal. `0 === -0`, but they aren't identical.
    # See the Harmony `egal` proposal: http://wiki.ecmascript.org/doku.php?id=harmony:egal.
    return a isnt 0 or 1 / a is 1 / b if a is b
    # A strict comparison is necessary because `null == undefined`.
    return a is b if not a? or not b?
    # Unwrap any wrapped objects.
    a = a._wrapped if a._chain
    b = b._wrapped if b._chain
    # Invoke a custom `isEqual` method if one is provided.
    return a.isEqual b if a.isEqual and _.isFunction a.isEqual
    return b.isEqual a if b.isEqual and _.isFunction b.isEqual
    # Compare `[[Class]]` names.
    className = toString.call a
    return false if className isnt toString.call b
    className = className.match(/[A-Z]\w+/)[0]
    switch className
        # Strings, numbers, dates, and booleans are compared by value.
        when 'String'
            # Primitives and their corresponding object wrappers are equivalent; thus, `"5"` is
            # equivalent to `new String("5")`.
            return a is String b
        when 'Number'
            # `NaN`s are equivalent, but non-reflexive. An `egal` comparison is performed for
            # other numeric values.
            return if a isnt +a then b isnt +b else (if a is 0 then 1 / a is 1 / b else a is +b)
        when 'Date', 'Boolean'
            # Coerce dates and booleans to numeric primitive values. Dates are compared by their
            # millisecond representations. Note that invalid dates with millisecond representations
            # of `NaN` are not equivalent.
            return +a is +b
        # RegExps are compared by their source patterns and flags.
        when 'RegExp'
            result = true
            for funcName of ['source', 'global', 'multiline', 'ignoreCase']
                result = result and (a[funcName] is b[funcName])
            return result
    return false if typeof a isnt 'object' or typeof b isnt 'object'
    # Assume equality for cyclic structures. The algorithm for detecting cyclic
    # structures is adapted from ES 5.1 section 15.12.3, abstract operation `JO`.
    length = stack.length
    while length--
        # Linear search. Performance is inversely proportional to the number of
        # unique nested structures.
        return true if stack[length] is a
    stack.push a
    size = 0
    result = true
    # Recursively compare objects and arrays.
    if className is 'Array'
        # Compare array lengths to determine if a deep comparison is necessary.
        size = a.length
        result = size is b.length
        if result
            # Deep compare the contents, ignoring non-numeric properties.
            while size--
                # Ensure commutative equality for sparse arrays.
                break unless result = size in a is size in b and eq a[size], b[size], stack
    else
        # Objects with different constructors are not equivalent.
        return false if `'constructor' in a` isnt `'constructor' in b` or a.constructor isnt b.constructor
        # Deep compare objects.
        for key of a
            if hasOwnProperty.call a, key
                # Count the expected number of properties.
                size++
                # Deep compare each member.
                break unless result = hasOwnProperty.call(b, key) and eq a[key], b[key], stack
        # Ensure that both objects contain the same number of properties.
        if result
            for key of b
                break if hasOwnProperty.call(b, key) and not (size--)
            result = !size
    # Remove the first object from the stack of traversed objects.
    stack.pop()
    return result

# Perform a deep comparison to check if two objects are equal.
_.isEqual = (a, b) ->
    return eq a, b, []
    
# Is a given array, string, or object empty?
# An "empty" object has no enumerable own-properties.
_.isEmpty = (obj) ->
    return obj.length is 0 if _.isArray obj or _.isString obj
    for key of obj
        return false if hasOwnProperty.call obj, key
    return true

# Is a given value a DOM element?
_.isElement = (obj) ->
    return !!(obj and obj.nodeType is 1)

# Is a given variable an object?
_.isObject = (obj) ->
    return obj is Object obj

# Is a given value a XX?
'Arguments Function Number String Date RegExp'.replace /[^, ]+/g, (typeName) ->
    _["is#{typeName}"] = (obj) ->
        return toString.call(obj) is "[object #{typeName}]"

# Is a given variable an arguments object?
if not _.isArguments arguments
    _.isArguments = (obj) ->
        return !!(obj && hasOwnProperty.call obj, 'callee')

# Is a given value an array?
# Delegates to ECMA5's native Array.isArray
_.isArray = nativeIsArray or (obj) ->
    return toString.call obj is '[object Array]'

# Is a given value a boolean?
_.isBoolean = (obj) ->
    return obj is true or obj is false or toString.call obj is '[object Boolean]'

# Is the given value `NaN`?
_.isNaN = (obj) ->
    # `NaN` is the only value for which `===` is not reflexive.
    return obj isnt obj
    
# Is a given value equal to null?
_.isNull = (obj) ->
    return obj is null

# Is a given variable undefined?
_.isUndefined = (obj) ->
    return obj is undefined

# Utility Functions
# -----------------

# Run Underscore.js in *noConflict* mode, returning the `_` variable to its
# previous owner. Returns a reference to the Underscore object.
_.noConflict = ->
    root._ = previousUnderscore
    return @

# Keep the identity function around for default iterators.
_.identity = (value) ->
    return value

# Run a function **n** times.
_.times = (n, iterator, context) ->
    for i in [0...n]
        iterator.call context, i

# Escape a string for HTML interpolation.
_.escape = (string) ->
    return "#{string}".replace(/&/g, '&amp;')
                      .replace(/</g, '&lt;')
                      .replace(/>/g, '&gt;')
                      .replace(/"/g, '&qout;')
                      .replace(/'/g, '&#x27;')
                      .replace(/\//g, '&#x2F;')

# Add your own custom functions to the Underscore object, ensuring that
# they're correctly added to the OOP wrapper as well.
_.mixin = (obj) ->
    each _.functions(obj), (name) ->
        addToWrapper name, _[name] = obj[name]

# Generate a unique integer id (unique within the entire client session).
# Useful for temporary DOM ids.
idCounter = 0
_.uniqueId = (prefix) ->
    id = idCounter++
    return if prefix then prefix + id else id

# By default, Underscore uses ERB-style template delimiters, change the
# following template settings to use alternative delimiters.
_.templateSettings =
    evaluate    : /<%([\s\S]+?)%>/g
    interpolate : /<%=([\s\S]+?)%>/g
    escape      : /<%-([\s\S]+?)%>/g

# When customizing `templateSettings`, if you don't want to define an
# interpolation, evaluation or escaping regex, we need one that is
# guaranteed not to match.
noMatch = /.^/

# JavaScript micro-templating, similar to John Resig's implementation.
# Underscore templating handles arbitrary delimiters, preserves whitespace,
# and correctly escapes quotes within interpolated code.
_.template = (str, data) ->
    c = _.templateSettings
    tmpl = "
    var __p = [], print = function() {
        __p.push.apply(__p,arguments);
    };
    with(obj || {}) {
        __p.push('#{
            str.replace(/\\/g, '\\\\')
            .replace(/'/g, "\\'")
            .replace(c.escape or noMatch, (match, code) ->
                return "', _.escape(#{code.replace /\\'/g, "'" }), '"
            )
            .replace(c.interpolate or noMatch, (match, code) ->
                return "', #{code.replace /\\'/g, "'"}, '"
            )
            .replace(c.evaluate or noMatch, (match, code) ->
                code = code.replace(/\\'/g, "'").replace(/[\r\n\t]/g, ' ').replace(/\\\\/g, '\\')
                return "'); #{code}; __p.push('"
            )
            .replace(/\r/g, '\\r')
            .replace(/\r/g, '\\r')
            .replace(/\n/g, '\\n')
            .replace(/\t/g, '\\t')
        }');
    }
    return __p.join('');"
    func = new Function 'obj', '_', tmpl
    return func data, _ if data
    return (data) ->
        return func.call @, data, _

# Add a "chain" function, which will delegate to the wrapper.
_.chain = (obj) ->
    return _(obj).chain()

# The OOP Wrapper
# ---------------

# If Underscore is called as a function, it returns a wrapped object that
# can be used OO-style. This wrapper holds altered versions of all the
# underscore functions. Wrapped objects may be chained.
wrapper = _.wrapper = (obj) ->
    @_wrapped = obj
    return

# Expose `wrapper.prototype` as `_.prototype`
_.prototype = wrapper.prototype

# Helper function to continue chaining intermediate results.
result = (obj, chain) ->
    return if chain then _(obj).chain() else obj

# A method to easily add functions to the OOP wrapper.
addToWrapper = (name, func) ->
    wrapper.prototype[name] = ->
        args = slice.call arguments
        unshift.call args, @_wrapped
        return result func.apply(_, args), @_chain

# Add all of the Underscore functions to the wrapper object.
_.mixin _

# Add all mutator Array functions to the wrapper.
each ['pop', 'push', 'reverse', 'shift', 'sort', 'splice', 'unshift'], (name) ->
    method = ArrayProto[name]
    wrapper.prototype[name] = ->
        wrapped = @_wrapped
        method.apply wrapped, arguments
        length = wrapped.length
        delete wrapped[0] if (name is 'shift' or name is 'splice') and length is 0
        return result(wrapped, @_chain)

# Add all accessor Array functions to the wrapper.
each ['concat', 'join', 'slice'], (name) ->
    method = ArrayProto[name]
    wrapper.prototype[name] = ->
        return result method.apply(@_wrapped, arguments), @_chain

# Start chaining a wrapped Underscore object.
wrapper::chain = ->
    @_chain = true
    return @

# Extracts the result from a wrapped and chained object.
wrapper::value = ->
    return @_wrapped
