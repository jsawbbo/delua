/*
Copyright (C) 2024-2026
                   Max Planck Institute f. Neurobiol. of Behavior — caesar,
                   Bonn, Germany

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
/** @file */
#ifndef DELUA_HPP
#define DELUA_HPP

#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>

#include <cstdarg>

/**@todo
 * - auxilliary methods below
 */

namespace lua {
  class exception;

  using number = lua_Number;    ///< Lua number type.
  using integer = lua_Integer;  ///< Lua integral type.
  using natural = lua_Unsigned; ///< Lua unsigned integral type.

  using cfunction = lua_CFunction; ///< Function type.

  namespace continuation {
    using context = lua_KContext;   ///< Context for a continuation function.
    using function = lua_KFunction; ///< Continuation function type.
  } // namespace continuation

  namespace warning {
    using function = lua_WarnFunction; ///< Warning handler function type.
  }

  using reader =
    lua_Reader; ///< Function type for reading data (e.g. from a stream).
  using writer =
    lua_Writer; ///< Function type for writing data (e.g. to a stream).

  using stream = luaL_Stream;

  using alloc = lua_Alloc; ///< Allocator function type.

  enum
  {
    /** Multiple-return value tag.
     * */
    multret = LUA_MULTRET,

    /** Stack index for the registry.
     * */
    registry = LUA_REGISTRYINDEX
  };

  /** Lua types.
   * */
  enum class type
  {
    none = LUA_TNONE,
    nil = LUA_TNIL,
    boolean = LUA_TBOOLEAN,
    light_userdata = LUA_TLIGHTUSERDATA,
    number = LUA_TNUMBER,
    string = LUA_TSTRING,
    table = LUA_TTABLE,
    function = LUA_TFUNCTION,
    userdata = LUA_TUSERDATA,
    thread = LUA_TTHREAD
  };

  /** Thread status.
   * */
  enum class status
  {
    ok = LUA_OK,
    yield = LUA_YIELD,
    error_run = LUA_ERRRUN,
    syntax = LUA_ERRSYNTAX,
    memory = LUA_ERRMEM,
    error = LUA_ERRERR
  };

  /** Return condition.
   * */
  enum class condition : bool
  {
    bad = false,
    good = true
  };

  /** Predefined references.
   * */
  enum reference : int
  {
    none = LUA_NOREF, ///< No reference indicator.
    nil = LUA_REFNIL  ///< Reference for a nil value.
  };

  using debug = lua_Debug;

  using libreg = luaL_Reg;

  /** Lua state.
   *
   * This class exposes all library function (including debug and auxilliary)
   * wrapping the opague lua state (`lua_State`).
   * */
  class LUA_API_CLASS state
  {
  private:
    friend class exception;

  public:
    using size_type = size_t; ///< Size type.
    using index_type = int;   ///< Stack index type.
    using count_type =
      int; ///< Type for stack items or value counts, respectively.

    using pointer = void *;             ///< Memory pointer.
    using const_pointer = const void *; ///< Const memory pointer.
    using userdata = pointer;           ///< User-data pointer.

    struct thread
    {
      using type = struct lua_State *;
    };

  public:
    state() = default;
    state(thread::type thr) : L(thr) {}

  protected:
    thread::type L = nullptr;

  public: // Standard library.
    //** state manipulation

    /** Create a new state.
     * @param a   Allocation function.
     * @param ud  User data for allocation function.
     * */
    static state newstate(alloc a, userdata ud = nullptr)
    {
      return lua_newstate(a, ud);
    }

    /** Create a new state.
     * */
    static state newstate() { return luaL_newstate(); }

    /** Return internal Lua state.
     * */
    operator thread::type() const noexcept { return L; }

    /** Close all active to-be-closed variables in the main thread.
     * */
    void close() { lua_close(L); }

    /** Create a new thread.
     * */
    state newthread() { return lua_newthread(L); }

    /** Close a thread.
     * */
    status closethread(state from = nullptr)
    {
      return static_cast<lua::status>(lua_closethread(L, from.L));
    }

    /** Set panic function.
     * @param panicfn New panic function.
     * @returns Previous panic function.
     * */
    cfunction atpanic(cfunction panicfn) { return lua_atpanic(L, panicfn); }

    /** Get encoded version number.
     * */
    number version() { return lua_version(L); }

    //** basic stack manipulation

    /** Get absolute stack index.
     * @param idx Relative stack index.
     * @returns Absolute stack index.
     * */
    index_type absindex(index_type idx) { return lua_absindex(L, idx); }

    /** Get current stack index.
     * */
    index_type gettop() { return lua_gettop(L); }

    /** FIXME
     * */
    void settop(index_type idx) { lua_settop(L, idx); }

    /** Push a copy onto the stack.
     * @param idx Value stack index.
     * */
    void pushvalue(index_type idx) { lua_pushvalue(L, idx); }

    /** Rotate stack elements between the valid index @a idx and the top of the
     * stack.
     * */
    void rotate(index_type idx, count_type n) { lua_rotate(L, idx, n); }

    /** Copy element at index @a from to the valid index @a to, replacing the
     * value.
     * */
    void copy(index_type from, index_type to) { lua_copy(L, from, to); }

    /** Ensures that the stack has space for at least @a n extra elements.
     * */
    condition checkstack(count_type n)
    {
      return static_cast<condition>(lua_checkstack(L, n));
    }

    /** Transfer @a n elements to another thread.
     * */
    void xmove(state to, count_type n) { lua_xmove(L, to.L, n); }

    // access functions (stack -> C)

    /** Check if value at stack index @a idx is a number.
     * */
    bool isnumber(index_type idx) { return lua_isnumber(L, idx); }

    /** Check if value at stack index @a idx is a string.
     * */
    bool isstring(index_type idx) { return lua_isstring(L, idx); }

    /** Check if value at stack index @a idx is a C function.
     * */
    bool iscfunction(index_type idx) { return lua_iscfunction(L, idx); }

    /** Check if value at stack index @a idx is an integer.
     * */
    bool isinteger(index_type idx) { return lua_isinteger(L, idx); }

    /** Check if value at stack index @a idx is user-data.
     * */
    bool isuserdata(index_type idx) { return lua_isuserdata(L, idx); }

    /** Get the type of a value on the stack at index @a idx.
     * */
    lua::type type(index_type idx)
    {
      return static_cast<lua::type>(lua_type(L, idx));
    }

    /** Get the string representation of a type @a id.
     * */
    const char *type_name(lua::type id)
    {
      return lua_typename(L, static_cast<int>(id));
    }

    /** Convert element to a number.
     * @param idx Valid stack index.
     * */
    number tonumber(index_type idx) { return lua_tonumber(L, idx); }

    /** Convert element to a number.
     * @param idx Valid stack index.
     * @param success Returns if coercion was possible/succesful.
     * */
    number tonumber(index_type idx, int &success)
    {
      return lua_tonumberx(L, idx, &success);
    }

    /** Convert element to an integer.
     * @param idx Valid stack index.
     * */
    integer tointeger(index_type idx) { return lua_tointeger(L, idx); }

    /** Convert element to an integer.
     * @param idx Valid stack index.
     * @param success Returns if coercion was possible/succesful.
     * */
    integer tointeger(index_type idx, int &success)
    {
      return lua_tointegerx(L, idx, &success);
    }

    /** Convert element to a boolean value.
     * @param idx Valid stack index.
     * */
    bool toboolean(index_type idx) { return lua_toboolean(L, idx); }

    /** Convert element to a string.
     * @param idx Valid stack index.
     * */
    const char *tostring(index_type idx) { return lua_tostring(L, idx); }

    /** Convert element to a string.
     * @param idx Valid stack index.
     * @param len Returns the string length.
     * */
    const char *tostring(index_type idx, size_type &len)
    {
      return lua_tolstring(L, idx, &len);
    }

    /** Get length of value at stack index @a idx without invoking meta-methods.
     * @param idx Valid stack index.
     * */
    size_type rawlen(index_type idx)
    {
      return static_cast<size_type>(lua_rawlen(L, idx));
    }

    /** Convert element to a `cfunction`.
     * @param idx Valid stack index.
     * */
    cfunction tocfunction(index_type idx) { return lua_tocfunction(L, idx); }

    /** Convert element to `userdata`.
     * @param idx Valid stack index.
     * */
    userdata touserdata(index_type idx) { return lua_touserdata(L, idx); }

    /** Convert element to a thread state.
     * @param idx Valid stack index.
     * */
    state tothread(index_type idx) { return lua_tothread(L, idx); }

    /** Convert element to a thread.
     * @param idx Valid stack index.
     * */
    const_pointer topointer(index_type idx) { return lua_topointer(L, idx); }

    //** Comparison and arithmetic functions

    // FIXME

  public: // Debug library.
          // FIXME
    // ==================================================
    // UNSORTED
    /** Set warning handler.
     * @param warnf The warning handler function.
     * @param ud Optional warning handler user-data.
     * */
    void setwarnf(warning::function warnf, userdata ud)
    {
      lua_setwarnf(L, warnf, ud);
    }

    pointer extraspace()
    {
      // see LUA_EXTRASPACE
      return lua_getextraspace(L);
    }

    /** Emit a warning.
     * @param msg Warning message.
     * @param tocont  FIXME
     * */
    void warning(const char *msg, bool tocont = true)
    {
      lua_warning(L, msg, tocont);
    }

    /** Get an up-value index.
     * */
    static index_type upvalueindex(index_type idx)
    {
      return lua_upvalueindex(idx);
    }

    /** Arithmetic operation type.
     * */
    enum class arithmetic
    {
      add = LUA_OPADD,
      sub = LUA_OPSUB,
      mul = LUA_OPMUL,
      div = LUA_OPDIV,
      idiv = LUA_OPIDIV,
      mod = LUA_OPMOD,
      pow = LUA_OPPOW,
      unm = LUA_OPUNM,
      bnot = LUA_OPBNOT,
      band = LUA_OPBAND,
      bor = LUA_OPBOR,
      bxor = LUA_OPBXOR,
      shl = LUA_OPSHL,
      shr = LUA_OPSHR
    };

    /** Perform arithmetic [-(2|1), +1, e].
     * */
    void arith(arithmetic op) { lua_arith(L, static_cast<int>(op)); }

    /** Call function on the stack.
     * @param nargs Number of input arguments.
     * @param nresults Number of output arguments.
     * */
    void call(int nargs, int nresults = multret)
    {
      lua_call(L, nargs, nresults);
    }

    // callk

    /** Close all active to-be-closed variables in the main thread @a idx. */
    void closeslot(index_type idx) { lua_closeslot(L, idx); }

    /** Comparison operation.
     * */
    enum class comparison
    {
      eq = LUA_OPEQ,
      lt = LUA_OPLT,
      le = LUA_OPLE
    };

    /** Compare two values.
     * */
    bool compare(index_type idx1, index_type idx2, comparison op)
    {
      return lua_compare(L, idx1, idx2, static_cast<int>(op));
    }

    /** Concatenate @a n elements on the top of the stack.
     * */
    void concat(count_type n) { lua_concat(L, n); }

    /** Create a table.
     * @param narr Number of free array members.
     * @param nrec Number of free records (key-value pairs).
     * */
    void createtable(count_type narr, count_type nrec = 0)
    {
      lua_createtable(L, narr, nrec);
    }

    /** Dump a function as a binary chunk. */
    int dump(writer wr, pointer data, bool strip = true)
    {
      return lua_dump(L, wr, data, strip);
    }

    /** Raise an error.
     * */
    int error() { return lua_error(L); }

    // FIXME
    // gc()

    /** Get a value by key.
     * @param idx Stack index of a table.
     * @param k The key.
     * */
    lua::type getfield(index_type idx, const char *k)
    {
      return static_cast<lua::type>(lua_getfield(L, idx, k));
    }

    /** Get a global variable.
     * @param k The key.
     * */
    lua::type getglobal(const char *k)
    {
      return static_cast<lua::type>(lua_getglobal(L, k));
    }

    /** Get a table entry.
     * @param idx Stack index of the table.
     * @param i Array index.
     * */
    lua::type geti(index_type idx, integer i)
    {
      return static_cast<lua::type>(lua_geti(L, idx, i));
    }

    /** Get the metatable of a value.
     * @param idx Stack index of the value.
     * */
    count_type getmetatable(index_type idx) { return lua_getmetatable(L, idx); }

    /** Get a value from a table.
     * @param idx Stack index of the table.
     * */
    lua::type gettable(index_type idx)
    {
      return static_cast<lua::type>(lua_gettable(L, idx));
    }

    /** Moves the top element into the given valid index @a idx.
     * */
    void insert(index_type idx) { lua_insert(L, idx); }

    /** Check if value at stack index @a idx is boolean.
     * */
    bool isboolean(index_type idx) { return lua_isboolean(L, idx); }

    /** Check if value at stack index @a idx is a function.
     * */
    bool isfunction(index_type idx) { return lua_isfunction(L, idx); }

    /** Check if value at stack index @a idx is light user-data.
     * */
    bool islightuserdata(index_type idx) { return lua_islightuserdata(L, idx); }

    /** Check if value at stack index @a idx is a 'nil'.
     * */
    bool isnil(index_type idx) { return lua_isnil(L, idx); }

    /** Check if value at stack index @a idx is none.
     * */
    bool isnone(index_type idx) { return lua_isnone(L, idx); }

    /** Check if value at stack index @a idx is none or 'nil'.
     * */
    bool isnoneornil(index_type idx) { return lua_isnoneornil(L, idx); }

    /** Check if value at stack index @a idx is a table.
     * */
    bool istable(index_type idx) { return lua_istable(L, idx); }

    /** Check if value at stack index @a idx is a thread.
     * */
    bool isthread(index_type idx) { return lua_isthread(L, idx); }

    /** Check if coroutine may yield.
     * */
    bool isyieldable() { return lua_isyieldable(L); }

    /** Get the length of the value at the given index @a idx. */
    void len(index_type idx) { lua_len(L, idx); }

    /** Load a Lua chunk without running it.
     * */
    status load(reader rd, pointer data, const char *chunkname,
                const char *mode)
    {
      return static_cast<lua::status>(lua_load(L, rd, data, chunkname, mode));
    }

    /** Create an empty table.
     * */
    void newtable() { createtable(0, 0); }

    /** FIXME
     * */
    pointer newuserdatauv(size_type size, count_type nuvalue)
    {
      return lua_newuserdatauv(L, size, nuvalue);
    }

    /** Traverse a table.
     * @param t Stack index of the table (preferrably absolute).
     *
     * Example:
     * @code
     * // table is in the stack at index 't'
     * L.pushnil();
     * while(L.next(t)) {
     *     // use 'key' at index -2 and 'value' at index -1
     *
     *     // remove 'value', keep 'key' for iteration
     *     L.pop();
     * }
     * @endcode
     *
     * */
    bool next(index_type t) { return lua_next(L, t); }

    /** Convert a number to an integer.
     * @return `true` if successful.
     * */
    static bool numbertointeger(number n, integer &i)
    {
      return lua_numbertointeger(n, &i);
    }

    /** Protected call.
     * @param nargs Number of input arguments.
     * @param nresults Number of output arguments.
     * @param msgh Message handler (0 for none).
     *
     * */
    status pcall(count_type nargs, count_type nresults, index_type msgh = 0)
    {
      return static_cast<lua::status>(lua_pcall(L, nargs, nresults, msgh));
    }

    // FIXME pcallk

    /** Pop @a n value from the stack.
     * */
    void pop(count_type n = 1) { lua_pop(L, n); }

    /** Push a boolean value on the stack.
     * */
    void pushboolean(bool x) { lua_pushboolean(L, x); }

    /** Push a closure onto the stack.
     * @param fn The closure function.
     * @param n Number of upvalues.
     * */
    void pushclosure(cfunction fn, count_type n) { lua_pushcclosure(L, fn, n); }

    /** Push a function onto the stack.
     * */
    void pushfunction(cfunction fn) { lua_pushcfunction(L, fn); }

    /** Push a formatted string onto the stack.
     * */
    ///@{
    const char *pushvfstring(const char *fmt, va_list ap)
    {
      return lua_pushvfstring(L, fmt, ap);
    }
    const char *pushfstring(const char *fmt, ...)
      __attribute__((format(printf, 2, 3)))
    {
      const char *ret;
      va_list argp;
      va_start(argp, fmt);
      ret = pushvfstring(fmt, argp);
      va_end(argp);
      return ret;
    }
    ///@}

    /** Push the global table onto the stack.
     * */
    void pushglobal() { lua_pushglobaltable(L); }

    /** Push an integer onto the stack.
     * */
    void pushinteger(integer i) { lua_pushinteger(L, i); }

    /** Push light user-data onto the stack.
     * */
    void pushlightuserdata(userdata ud) { lua_pushlightuserdata(L, ud); }

    /** Push a string onto the stack.
     * */
    void pushlstring(const char *s, size_type len)
    {
      lua_pushlstring(L, s, len);
    }

    /** Push 'nil' onto the stack.
     * */
    void pushnil() { lua_pushnil(L); }

    /** Push a number onto the stack.
     * */
    void pushnumber(number n) { lua_pushnumber(L, n); }

    /** Push a string onto the stack.
     * */
    void pushstring(const char *s) { lua_pushstring(L, s); }

    /** Push a thread onto the stack.
     * */
    bool pushthtread(state thr) { return lua_pushthread(thr.L); }

    /** Check for value equality avoiding meta-methods.
     * */
    bool rawequal(index_type idx1, index_type idx2)
    {
      return lua_rawequal(L, idx1, idx2);
    }

    /** As gettable() but avoiding meta-methods.
     * */
    lua::type rawget(index_type idx)
    {
      return static_cast<lua::type>(lua_rawget(L, idx));
    }

    /** As geti() but avoiding meta-methods.
     * */
    lua::type rawgeti(index_type idx, integer n)
    {
      return static_cast<lua::type>(lua_rawgeti(L, idx, n));
    }

    /** FIXME
     * */
    lua::type rawgetp(index_type idx, const userdata p)
    {
      return static_cast<lua::type>(lua_rawgetp(L, idx, p));
    }

    /** As settable() but without invoking meta-methods.
     * */
    void rawset(index_type idx) { lua_rawset(L, idx); }

    /** As seti() but without invoking meta-methods.
     * */
    void rawseti(index_type idx, integer i) { lua_rawseti(L, idx, i); }

    /** FIXME
     * */
    void rawsetp(index_type idx, const userdata p) { lua_rawsetp(L, idx, p); }

    /** Register a global function.
     * @param name Function name (in global table).
     * @param f The function.
     * */
    void do_register(const char *name, cfunction f)
    {
      lua_register(L, name, f);
    }

    /** Removes the element at given index.
     * */
    void remove(index_type idx) { lua_remove(L, idx); }

    /** Move top element to given valid stack index.
     * */
    void replace(index_type idx) { lua_replace(L, idx); }

    /** Start and resume coroutine in given thread.
     * */
    status resume(state thr, count_type nargs, count_type &nresults)
    {
      return static_cast<lua::status>(lua_resume(thr.L, L, nargs, &nresults));
    }

    /** Set memory allocator function.
     * */
    void setalloc(alloc fn, userdata ud) { lua_setallocf(L, fn, ud); }

    /** FIXME
     * */
    void setfield(index_type idx, const char *k) { lua_setfield(L, idx, k); }

    /** FIXME
     * */
    void setglobal(const char *name) { lua_setglobal(L, name); }

    /** FIXME
     * */
    void seti(index_type idx, integer n) { lua_seti(L, idx, n); }

    /** FIXME
     * */
    bool setiuservalue(index_type idx, integer n)
    {
      return lua_setiuservalue(L, idx, n);
    }

    /** FIXME
     * */
    void setmetatable(index_type idx) { (void)lua_setmetatable(L, idx); }

    /** FIXME
     * */
    void settable(index_type idx) { lua_settable(L, idx); }

    /** FIXME
     * */
    status getstatus() { return static_cast<lua::status>(lua_status(L)); }

    operator lua::status() const
    {
      return static_cast<lua::status>(lua_status(L));
    }

    /** Converts the zero-terminated string s to a number, pushes that number
     * into the stack.
     * */
    size_type stringtonumber(const char *s) { return lua_stringtonumber(L, s); }

    /** FIXME
     * */
    void toclose(index_type idx) { return lua_toclose(L, idx); }

  public: // Auxilliary library.
    /** String buffer.
     * */
    class LUA_API_CLASS buffer
    {
    public:
      /** Initial buffer size.
       * */
      constexpr static size_t size = LUAL_BUFFERSIZE;

    public:
      buffer() = delete;

      /** Construct string buffer.
       * @param s Lua state.
       */
      buffer(state &s, size_t n = 0) { luaL_buffinit(s.L, &buf_); }

    protected:
      luaL_Buffer buf_{};

    public:
      /** Get character array address.
       * */
      char *addr() { return luaL_buffaddr(&buf_); }

      /** Get content length.
       * */
      size_t length() const { return luaL_bufflen(&buf_); }

      /** Append character.
       * */
      buffer &append(char c)
      {
        luaL_addchar(&buf_, c);
        return *this;
      }

      /** Append string.
       * */
      buffer &append(const char *str, size_t n)
      {
        luaL_addlstring(&buf_, str, n);
        return *this;
      }

      buffer &append(const std::string &s)
      {
        return append(s.data(), s.size());
      }

      /** Add value from stack.
       * @note This pops the value from the Lua stack.
       */
      buffer &pop()
      {
        luaL_addvalue(&buf_);
        return *this;
      }

      /** Reserve space at end of buffer.
       * @param n Number of bytes to reserve.
       * @return Pointer to reserved space.
       * @note
       * After copying the string into this space you must call add() with the
       * size of the string to actually add it to the buffer.
       * */
      char *reserve(size_t n = size) { return luaL_prepbuffsize(&buf_, n); }

      /** Set number of characters added.
       * @see lua::state::buffer::reserve
       * */
      void add(size_t n) { luaL_addsize(&buf_, n); }

      /** Remove @a n elements from buffer.
       * */
      void sub(size_t n) { luaL_buffsub(&buf_, n); }

      /** Push to stack.
       * */
      void push() { luaL_pushresult(&buf_); }

      /** Push to stack.
       * @param n Number of characters to push as string.
       * */
      void push(size_t n) { luaL_pushresultsize(&buf_, n); }

      /** Add string, apply replacement by pattern.
       * @param str The string to add.
       * @param pattern The "gsub" pattern.
       * @param replace Replacement string for pattern.
       * */
      void gsub(const std::string &str, const std::string &pattern,
                const std::string &replace)
      {
        luaL_addgsub(&buf_, str.c_str(), pattern.c_str(), replace.c_str());
      }
    };

    /** Checks whether @a cond is true, if it is not, raises an error.
     * @param cond    Condition value.
     * @param arg     Argument index.
     * @param extra   Additional error message.
     * This emits an error message (see argerror()) if @a cond is @c true.
     * */
    void argcheck(bool cond, index_type arg, const char *extra)
    {
      luaL_argcheck(L, cond, arg, extra);
    }
    void argcheck(bool cond, index_type arg, const std::string &extra)
    {
      luaL_argcheck(L, cond, arg, extra.c_str());
    }

    /** Checks whether @a cond is true, if it is not, raises an error.
     * @param cond    Condition value.
     * @param arg     Argument index.
     * @param tname   Expected type.
     * This emits an error message (see typeerror()) if @a cond is @c true.
     * */
    void argexpected(bool cond, index_type arg, const char *tname)
    {
      luaL_argexpected(L, cond, arg, tname);
    }
    void argexpected(bool cond, index_type arg, const std::string &tname)
    {
      luaL_argexpected(L, cond, arg, tname.c_str());
    }

    /** Raise a type error for given argument.
     * @param arg     Argument index.
     * @param tname   Expected type.
     * */
    void typeerror(bool cond, index_type arg, const char *tname)
    {
      luaL_typeerror(L, arg, tname);
    }

    /** Raises an error reporting a problem with argument @a arg.
     * @param arg     Argument index.
     * @param extra   Additional error message.
     * */
    void argerror(index_type arg, const char *extra)
    {
      luaL_argerror(L, arg, extra);
    }

    /** Call a meta-method.
     * @param obj   Stack index of object with meta-table.
     * @param field Method name in the meta-table.
     * @returns @c true if method exists, leaving return values on the stack,
     *          @c false otherwise.
     * */
    bool callmeta(index_type obj, const char *field)
    {
      return luaL_callmeta(L, obj, field);
    }

    /** Check where function argument @a arg exist.
     * @param arg   Argument index.
     * @return Value at given index.
     * @throw exception if @a arg does not exist.
     * */
    void checkany(index_type arg) { luaL_checkany(L, arg); }

    /** Check where function argument @a arg exist and is an integer.
     * @param arg   Argument index.
     * @return Value at given index.
     * @throw exception if @a arg does not exist.
     * */
    integer checkinteger(index_type arg) { return luaL_checkinteger(L, arg); }

    /** Check where function argument @a arg exist and is a number.
     * @param arg   Argument index.
     * @return Value at given index.
     * @throw exception if @a arg does not exist.
     * */
    number checknumber(index_type arg) { return luaL_checknumber(L, arg); }

    /** Check where function argument @a arg exist and is a string.
     * @param arg   Argument index.
     * @param len   Reference to length of string.
     * @return Value at given index.
     * @throw exception if @a arg does not exist.
     * */
    const char *checkstring(index_type arg)
    {
      return luaL_checklstring(L, arg, nullptr);
    }
    const char *checkstring(index_type arg, size_t &len)
    {
      return luaL_checklstring(L, arg, &len);
    }

    /** Check where function argument @a arg exist and is user-data.
     * @param arg   Argument index.
     * @param tname Type name.
     * @return Value at given index.
     * @throw exception if @a arg does not exist.
     * */
    userdata checkudata(index_type arg, const char *tname)
    {
      return luaL_checkudata(L, arg, tname);
    }

    /** Check if argument @a arg is given type.
     * */
    void checktype(index_type arg, lua::type t)
    {
      luaL_checktype(L, arg, (int)t);
    }

    /** Check if argument is string and contained in string array.
     * @param arg   Argument index.
     * @param lst   Null-terminated string array.
     * @param def   Default value.
     * @return Index in @a lst.
     * @throw exception if not found in @a lst.
     *
     * Checks whether the function argument arg is a string and searches for
     * this string in the array lst (which must be NULL-terminated). Returns the
     * index in the array where the string was found. Raises an error if the
     * argument is not a string or if the string cannot be found.
     *
     * If def is not NULL, the function uses def as a default value when there
     * is no argument arg or when this argument is nil.
     *
     * This is a useful function for mapping strings to C enums. (The usual
     * convention in Lua libraries is to use strings instead of numbers to
     * select options.)
     *
     * */
    int checkoption(index_type arg, const char *const lst[],
                    const char *def = nullptr)
    {
      return luaL_checkoption(L, arg, def, lst);
    }

    /** Increase stack size.
     * */
    void checkstack(size_type n, const char *extra = nullptr)
    {
      luaL_checkstack(L, n, extra);
    }

    /** Check code vs. library version.
     * Checks whether the code making the call and the Lua library being called
     * are using the same version of Lua and the same numeric types.
     * @throw exception on failure.
     * */
    void checkversion() { luaL_checkversion(L); }

    /** Loads and runs the given file.
     * */
    status dofile(const char *filename)
    {
      status retval = loadfile(filename);
      if (retval == lua::status::ok) retval = pcall(0, lua::multret, 0);
      return retval;
    }

    /** Load and run the given string.
     * */
    status dostring(const char *snippet)
    {
      status retval = loadstring(snippet);
      if (retval == lua::status::ok) retval = pcall(0, lua::multret, 0);
      return retval;
    }

    /** Raise an error.
     */
    int error(const char *fmt, ...) __attribute__((format(printf, 2, 3)))
    {
      va_list argp;
      va_start(argp, fmt);
      where(1);
      pushvfstring(fmt, argp);
      va_end(argp);
      concat(2);
      return error();
    }

    /** Pushes onto the stack the field from the metatable.
     * @param obj   Stack index of object.
     * @param e     Field name in meta-table.
     * */
    lua::type getmetafield(index_type obj, const char *e)
    {
      return static_cast<lua::type>(luaL_getmetafield(L, obj, e));
    }

    /** Pushes onto the stack the metatable associated with the name @a tname.
     * */
    lua::type getmetatable(const char *tname)
    {
      return static_cast<lua::type>(luaL_getmetatable(L, tname));
    }

    /** Retrieve or create sub-table.
     * @param idx   Stack index of table @c t.
     * @param fname Field-name of table.
     * @return @c true if table already exists, @c false otherwise
     *
     * Ensures that the value @c t[fname], where @c t is the value at index @a
     * idx, is a table, and pushes that table onto the stack.
     *
     */
    bool getsubtable(index_type idx, const char *fname)
    {
      return luaL_getsubtable(L, idx, fname);
    }

    /** Loads a buffer as a Lua chunk.
     * @param buff  Buffer pointer.
     * @param sz    Buffer size.
     * @param name  Chunk name.
     * */
    status loadbuffer(const char *buff, size_t sz, const char *name,
                      const char *mode = nullptr)
    {
      return static_cast<status>(luaL_loadbufferx(L, buff, sz, name, mode));
    }

    /** Load chunk from file.
     * */
    status loadfile(const char *filename, const char *mode = nullptr)
    {
      return static_cast<status>(luaL_loadfilex(L, filename, mode));
    }

    /** Loads a string as a Lua chunk.
     * */
    status loadstring(const char *snippet)
    {
      return (status)luaL_loadstring(L, snippet);
    }

    /** Retrieve or create registered meta-table.
     * @param tname   Meta-table name.
     *
     * If the registry already has the key @a tname, returns @c 0. Otherwise,
     * creates a new table to be used as a metatable for userdata, adds to this
     * new table the pair __name = tname, adds to the registry the pair [tname]
     * = new table, and returns 1.
     *
     * In both cases, the function pushes onto the stack the final value
     * associated with @a tname in the registry.
     *
     * */
    bool newmetatable(const char *tname) { return luaL_newmetatable(L, tname); }

    /** Open all standard Lua libraries.
     * */
    void openlibs() { luaL_openlibs(L); }

    // FIXME luaL_opt

    /** Get optional integer.
     * @param arg   Stack index of argument.
     * @param d     Default value.
     * */
    integer optinteger(index_type arg, integer d)
    {
      return luaL_optinteger(L, arg, d);
    }

    /** Get optional number.
     * @param arg   Stack index of argument.
     * @param d     Default value.
     * */
    number optnumber(index_type arg, number d)
    {
      return luaL_optnumber(L, arg, d);
    }

    /** Get optional string.
     * @param arg   Stack index of argument.
     * @param d     Default value.
     * @param l     Length of returned string as result.
     * */
    const char *optstring(index_type arg, const char *d)
    {
      return luaL_optstring(L, arg, d);
    }
    const char *optstring(index_type arg, const char *d, size_t &l)
    {
      return luaL_optlstring(L, arg, d, &l);
    }

    /** Push "fail" value on the stack.
     * */
    void pushfail() { luaL_pushfail(L); }

    /** Create reference in table @t for object on top of stack.
     * */
    index_type ref(index_type t = registry) { return luaL_ref(L, t); }

    // FIXME luaL_requiref

    /** Registers functions.
     *
     * Registers all functions in the array @a l (see @c libreg) into the table
     * on the top of the stack (below optional upvalues, see next).
     *
     * When @a nup is not zero, all functions are created with @a nup upvalues,
     * initialized with copies of the nup values previously pushed on the stack
     * on top of the library table. These values are popped from the stack after
     * the registration.
     *
     * A function with a NULL value represents a placeholder, which is filled
     * with false.
     *
     *
     * */
    void setfuncs(const libreg *l, count_type nup = 0)
    {
      luaL_setfuncs(L, l, nup);
    }

    /** Sets the metatable of the object on the top of the stack.
     * */
    void setmetatable(const char *tname) { luaL_setmetatable(L, tname); }

    /** Test for userdata.
     * This function works like @c checkudata, except that, when the test fails,
     * it returns NULL instead of raising an error.
     */
    userdata testudata(index_type arg, const char *tname)
    {
      return luaL_testudata(L, arg, tname);
    }

    /** Convert to string (calls __tostring if present).
     * */
    const char *tolstring(index_type idx, size_t *len = nullptr)
    {
      return luaL_tolstring(L, idx, len);
    }

    /** Returns the name of the type of the value at the given index.
     * */
    const char *type_name(index_type idx) {
      return luaL_typename(L, idx);
    }

    /** Releases the reference @a ref from the table at index @a t.
     * @see ref()
     * */
    void unref(index_type ref, index_type t = registry)
    {
      luaL_unref(L, t, ref);
    }

  public: ///** Debug.
    /** Creates and pushes a traceback of the stack.
     * @param other The state for which to create the traceback.
     * @param lvl   Stack level (0 is current function).
     * @param extra Extra message at the beginning of the traceback.
     *
     * */
    void traceback(count_type lvl, const char *extra = nullptr)
    {
      luaL_traceback(L, L, extra, lvl);
    }
    void traceback(state &other, count_type lvl, const char *extra = nullptr)
    {
      luaL_traceback(L, other.L, extra, lvl);
    }

    /** Pushes onto the stack a string identifying the current position.
     * @param lvl  Stack level (0 is current function).
     *
     * Typically this string has the following format:
     *
     *      chunkname:currentline:
     *
     * Level 0 is the running function, level 1 is the function that called the
     * running function, etc.
     *
     * This function is used to build a prefix for error messages.
     *
     * */
    void where(count_type lvl = 0) { luaL_where(L, lvl); }
  };

  /** Lua error (C++ only).
   * @note
   *    The C-library uses long jumps.
   * */
  class LUA_API_CLASS exception : public lua_Exception
  {
  public:
    exception(state &L, lua::status s) : lua_Exception(L, (int)s) {}
  };

} // namespace lua

#endif