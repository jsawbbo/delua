/*
Copyright (C) 2024 Max Planck Institute f. Neurobiol. of Behavior — caesar, Bonn, Germany

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
#ifndef DELUA_HPP
#define DELUA_HPP

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

namespace lua
{
    /** Lua error (C++ only).
     * */
    using exception = lua_Exception;

    using number = lua_Number;    ///< Lua number type.
    using integer = lua_Integer;  ///< Lua integral type.
    using natural = lua_Unsigned; ///< Lua unsigned integral type.

    using cfunction = lua_CFunction; ///< Function type.

    namespace continuation {
        using context = lua_KContext; ///< Context for a continuation function.
        using function = lua_KFunction; ///< Continuation function type.
    }

    using warn_function = lua_WarnFunction; ///< Warning handler function type.

    using reader = lua_Reader; ///< Function type for reading data (e.g. from a stream).
    using writer = lua_Writer; ///< Function type for writing data (e.g. to a stream).

    using allocf = lua_Alloc; ///< Allocator function type.

    /** Multiple-return value tag.
     * */
    enum
    {
        multret = LUA_MULTRET
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

    /** Lua engine.
     * */
    class LUA_API_CLASS engine
    {
    public:
        using state = struct lua_State *; ///< Internal opaque Lua state pointer.

        using index_type = int; ///< Stack index type.
        using count_type = int; ///< Value count type.
        using size_type = size_t;

        using pointer = void *;   ///< Memory pointer.
        using const_pointer = const void *;   ///< Memory pointer.
        using userdata = pointer; ///< User-data pointer.

    public:
        engine() : L(luaL_newstate()) {}
        engine(allocf a, userdata ud = nullptr) : L(lua_newstate(a, ud)) {}

    protected:
        state L = nullptr;

    public:
        /** Get absolute stack index.
         * @param idx Relative stack index.
         * @returns
         *      absolute stack index
         * */
        index_type absindex(index_type idx)
        {
            return lua_absindex(L, idx);
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
        void arith(arithmetic op)
        {
            lua_arith(L, static_cast<int>(op));
        }

        /** Set panic funciton.
         * @param panicfn New panic function.
         * @returns Previous panic function.
         * */
        cfunction atpanic(cfunction panicfn)
        {
            return lua_atpanic(L, panicfn);
        }

        /** Call function on the stack.
         * @param nargs Number of input arguments.
         * @param nresults Number of output arguments.
         * */
        void call(int nargs, int nresults = multret)
        {
            lua_call(L, nargs, nresults);
        }

        // callk

        /** Ensures that the stack has space for at least @a n extra elements.
         * */
        condition checkstack(count_type n)
        {
            return static_cast<condition>(lua_checkstack(L, n));
        }

        /** Close all active to-be-closed variables in the main thread.
         * */
        void close()
        {
            lua_close(L);
        }

        /** Close all active to-be-closed variables in the main thread @a idx. */
        void closeslot(index_type idx)
        {
            lua_closeslot(L, idx);
        }

        /** Close a thread.
         * */
        status closethread(state from = nullptr)
        {
            return static_cast<lua::status>(lua_closethread(L, from));
        }

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
        void concat(count_type n)
        {
            lua_concat(L, n);
        }

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
        void error()
        {
            lua_error(L);
        }

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

        pointer extraspace()
        {
            // see LUA_EXTRASPACE
            return lua_getextraspace(L);
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
        count_type getmetatable(index_type idx)
        {
            return lua_getmetatable(L, idx);
        }

        /** Get a value from a table.
         * @param idx Stack index of the table.
         * */
        lua::type gettable(index_type idx)
        {
            return static_cast<lua::type>(lua_gettable(L, idx));
        }

        /** Get current stack index.
         * */
        index_type gettop()
        {
            return lua_gettop(L);
        }

        /** Moves the top element into the given valid index @a idx.
         * */
        void insert(index_type idx)
        {
            lua_insert(L, idx);
        }

        /** Check if value at stack index @a idx is boolean.
         * */
        bool isboolean(index_type idx)
        {
            return lua_isboolean(L, idx);
        }

        /** Check if value at stack index @a idx is a C function.
         * */
        bool iscfunction(index_type idx)
        {
            return lua_iscfunction(L, idx);
        }

        /** Check if value at stack index @a idx is a function.
         * */
        bool isfunction(index_type idx)
        {
            return lua_isfunction(L, idx);
        }

        /** Check if value at stack index @a idx is an integer.
         * */
        bool isinteger(index_type idx)
        {
            return lua_isinteger(L, idx);
        }

        /** Check if value at stack index @a idx is light user-data.
         * */
        bool islightuserdata(index_type idx)
        {
            return lua_islightuserdata(L, idx);
        }

        /** Check if value at stack index @a idx is a 'nil'.
         * */
        bool isnil(index_type idx)
        {
            return lua_isnil(L, idx);
        }

        /** Check if value at stack index @a idx is none.
         * */
        bool isnone(index_type idx)
        {
            return lua_isnone(L, idx);
        }

        /** Check if value at stack index @a idx is none or 'nil'.
         * */
        bool isnoneornil(index_type idx)
        {
            return lua_isnoneornil(L, idx);
        }

        /** Check if value at stack index @a idx is a number.
         * */
        bool isnumber(index_type idx)
        {
            return lua_isnumber(L, idx);
        }

        /** Check if value at stack index @a idx is a string.
         * */
        bool isstring(index_type idx)
        {
            return lua_isstring(L, idx);
        }

        /** Check if value at stack index @a idx is a table.
         * */
        bool istable(index_type idx)
        {
            return lua_istable(L, idx);
        }

        /** Check if value at stack index @a idx is a thread.
         * */
        bool isthread(index_type idx)
        {
            return lua_isthread(L, idx);
        }

        /** Check if value at stack index @a idx is user-data.
         * */
        bool isuserdata(index_type idx)
        {
            return lua_isuserdata(L, idx);
        }

        /** Check if coroutine may yield.
         * */
        bool isyieldable()
        {
            return lua_isyieldable(L);
        }

        /** Get the length of the value at the given index @a idx. */
        void len(index_type idx)
        {
            lua_len(L, idx);
        }

        /** Load a Lua chunk without running it.
         * */
        status load(reader rd, pointer data, const char *chunkname, const char *mode)
        {
            return static_cast<lua::status>(lua_load(L, rd, data, chunkname, mode));
        }

        /** Create an empty table.
         * */
        void newtable()
        {
            createtable(0, 0);
        }

        /** Create a new thread.
         * */
        state newthread()
        {
            return lua_newthread(L);
        }

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
        bool next(index_type t)
        {
            return lua_next(L, t);
        }

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
            return static_cast<lua::status>(L, nargs, nresults, msgh);
        }

        // FIXME pcallk

        /** Pop @a n value from the stack.
         * */
        void pop(count_type n = 1)
        {
            lua_pop(L, n);
        }

        /** Push a boolean value on the stack.
         * */
        void pushboolean(bool x)
        {
            lua_pushboolean(L, x);
        }

        /** Push a closure onto the stack.
         * @param fn The closure function.
         * @param n Number of upvalues.
         * */
        void pushclosure(cfunction fn, count_type n)
        {
            lua_pushcclosure(L, fn, n);
        }

        /** Push a function onto the stack.
         * */
        void pushfunction(cfunction fn)
        {
            lua_pushcfunction(L, fn);
        }

        /** Push a formatted string onto the stack.
         * */
        ///@{
        const char *pushvfstring(const char *fmt, va_list ap)
        {
            return lua_pushvfstring(L, fmt, ap);
        }
        const char *pushfstring(const char *fmt, ...) __attribute__((format(printf, 2, 3)))
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
        void pushglobal()
        {
            lua_pushglobaltable(L);
        }

        /** Push an integer onto the stack.
         * */
        void pushinteger(integer i)
        {
            lua_pushinteger(L, i);
        }

        /** Push light user-data onto the stack.
         * */
        void pushlightuserdata(userdata ud)
        {
            lua_pushlightuserdata(L, ud);
        }

        /** Push a string onto the stack.
         * */
        void pushlstring(const char *s, size_type len)
        {
            lua_pushlstring(L, s, len);
        }

        /** Push 'nil' onto the stack.
         * */
        void pushnil()
        {
            lua_pushnil(L);
        }

        /** Push a number onto the stack.
         * */
        void pushnumber(number n)
        {
            lua_pushnumber(L, n);
        }

        /** Push a string onto the stack.
         * */
        void pushstring(const char *s)
        {
            lua_pushstring(L, s);
        }

        /** Push a thread onto the stack.
         * */
        bool pushthtread(state L)
        {
            return lua_pushthread(L);
        }

        /** Push a copy onto the stack.
         * @param idx Value stack index.
         * */
        void pushvalue(index_type idx)
        {
            lua_pushvalue(L, idx);
        }

        /** Check for value equality avoiding meta-methods. 
         * */
        bool rawequal(index_type idx1, index_type idx2) {
            return lua_rawequal(L, idx1, idx2);
        }

        /** As gettable() but avoiding meta-methods.
         * */
        lua::type rawget(index_type idx) {
            return static_cast<lua::type>(lua_rawget(L, idx));
        }

        /** As geti() but avoiding meta-methods.
         * */
        lua::type rawgeti(index_type idx, integer n) {
            return static_cast<lua::type>(lua_rawgeti(L, idx, n));
        }

        /** FIXME
         * */
        lua::type rawgetp(index_type idx, const userdata p) {
            return static_cast<lua::type>(lua_rawgetp(L, idx, p));
        }

        /** Get length of value at stack index @a idx without invoking meta-methods. 
         * */
        natural rawlen(index_type idx) {
            return lua_rawlen(L, idx);
        }

        /** As settable() but without invoking meta-methods. 
         * */
        void rawset(index_type idx) {
            lua_rawset(L, idx);
        }

        /** As seti() but without invoking meta-methods. 
         * */
        void rawseti(index_type idx, integer i) {
            lua_rawseti(L, idx, i);
        }

        /** FIXME
         * */
        void rawsetp(index_type idx, const userdata p) {
            lua_rawsetp(L, idx, p);
        }

        /** Register a global function.
         * @param name Function name (in global table).
         * @param f The function. 
         * */
        void do_register(const char *name, cfunction f) {
            lua_register(L, name, f);
        }

        /** Removes the element at given index.
         * */
        void remove(index_type idx) {
            lua_remove(L, idx);
        }

        /** Move top element to given valid stack index.
         * */
        void replace(index_type idx) {
            lua_replace(L, idx);
        }

        /** Start and resume coroutine in given thread.
         * */
        status resume(state thr, count_type nargs, count_type &nresults) {
            return static_cast<lua::status>(lua_resume(thr, L, nargs, &nresults));
        }

        /** Rotate stack elements between the valid index @a idx and the top of the stack. 
         * */
        void rotate(index_type idx, count_type n) {
            lua_rotate(L, idx, n);
        }

        /** Set memory allocator function.
         * */
        void setallocf(allocf fn, userdata ud) {
            lua_setallocf(L, fn, ud);
        }

        /** FIXME
         * */
        void setfield(index_type idx, const char *k) {
            lua_setfield(L, idx, k);
        }

        /** FIXME
         * */
        void setglobal(const char *name) {
            lua_setglobal(L, name);
        }

        /** FIXME
         * */
        void seti(index_type idx, integer n) {
            lua_seti(L, idx, n);
        }

        /** FIXME
         * */
        bool setiuservalue(index_type idx, integer n) {
            return lua_setiuservalue(L, idx, n);
        }

        /** FIXME
         * */
        void setmetatable(index_type idx) {
            (void) lua_setmetatable(L, idx);
        }

        /** FIXME
         * */
        void settable(index_type idx) {
            lua_settable(L, idx);
        }

        /** FIXME
         * */
        void settop(index_type idx) {
            lua_settop(L, idx);
        }

        /** FIXME
         * */
        void setwarnf(warn_function f, userdata ud) {
            lua_setwarnf(L, f, ud);
        }

        /** FIXME
         * */
        status getstatus() {
            return static_cast<lua::status>(lua_status(L));
        }

        operator lua::status() const {
            return static_cast<lua::status>(lua_status(L));
        }

        /** Converts the zero-terminated string s to a number, pushes that number into the stack. 
         * */
        size_type stringtonumber(const char *s) {
            return lua_stringtonumber(L, s);
        }

        /** FIXME
         * */
        bool toboolean(index_type idx) {
            return lua_toboolean(L, idx);
        }

        /** FIXME
         * */
        cfunction tocfunction(index_type idx) {
            return lua_tocfunction(L, idx);
        }

        /** FIXME
         * */
        void toclose(index_type idx) {
            return lua_toclose(L, idx);
        }

        /** FIXME
         * */
        integer tointeger(index_type idx) {
            return lua_tointeger(L, idx);
        }

        /** FIXME
         * */
        integer tointeger(index_type idx, int &success) {
            return lua_tointegerx(L, idx, &success);
        }

        /** FIXME
         * */
        const char *tostring(index_type idx, size_type &len) {
            return lua_tolstring(L, idx, &len);
        }

        /** FIXME
         * */
        number tonumber(index_type idx) {
            return lua_tonumber(L, idx);
        }

        /** FIXME
         * */
        number tonumber(index_type idx, int &success) {
            return lua_tonumberx(L, idx, &success);
        }

        /** FIXME
         * */
        const_pointer topointer(index_type idx) {
            return lua_topointer(L, idx);
        }

        /** FIXME
         * */
        const char *tostring(index_type idx) {
            return lua_tostring(L, idx);
        }

        /** FIXME
         * */
        state tothread(index_type idx) {
            return lua_tothread(L, idx);
        }

        /** FIXME
         * */
        userdata touserdata(index_type idx) {
            return lua_touserdata(L, idx);
        }

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

        /** FIXME */
        static index_type upvalueindex(index_type idx)
        {
            return lua_upvalueindex(idx);
        }

        /** Get encoded version number.
         *
         */
        number version()
        {
            return lua_version(L);
        }

        /** Emit a warning.
         * @param msg Warning message.
         * @param tocont  FIXME
         * */
        void warning(const char *msg, bool tocont = true)
        {
            lua_warning(L, msg, tocont);
        }

        /** Transfer @a n element from one to another thread.
         * */
        static void xmove(state from, state to, count_type n)
        {
            lua_xmove(from, to, n);
        }

    public:
        // FIXME debug library

    public:
        // FIXME auxiliary library
    };

}

#endif