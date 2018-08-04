/*
** $Id: luaxx.hpp $
** Configuration file for Lua
** See Copyright Notice in lua.h
*/
#ifndef luaxx_hpp
#define luaxx_hpp

#include "lua.hpp"

#include <stdexcept>

#define noexcept // FIXME

namespace lua {

	/** Lua exception. */
	class except : public virtual std::exception {
	public:
		except(lua_State *L, int status) noexcept: std::exception(), __vm(L), __status(status) {}

	protected:
		lua_State *__vm;
		int __status;

	public:
		virtual int status() const { return __status; }
		virtual lua_State *vm() const { return __vm; }
	};

	/** Panic exception and handling. */
	class panic : public virtual std::exception {
	public:
		panic(lua_State *L) noexcept: std::exception(), __vm(L) {}

	protected:
		lua_State *__vm;

	public:
		/** Panic handler.
		 * The panic handler must be explicitly loaded using
		 * @code
		 * L.atpanic(Lua::Panic::Handler);
		 * @endcode
		 * Otherwise, the program will be simply aborted. */
		static int handler(lua_State *L) {
			throw panic(L);
		}
	};

#if !defined(__lua_exception_only)

	/** C++ wrapper for lua. */
	class vm {
	public:
		/** Pointer to %Lua's internal state. */
		typedef lua_State *State;

	public:
		vm(State L_ = 0) : L(L_) {}

	protected:
		State L;

	public:
		/** Validity check. */
		operator bool() const { return L != 0; }

		/** Returns the pseudo-index that represents the @a i-th upvalue of the running function. */
		static int upvalueindex(int i) { return lua_upvalueindex(i); }

		/** Type IDs. */
		enum TypeID {
			TNone           = LUA_TNONE,            ///< Return value of @c type() for non-valid (but acceptable) index.
			TNil            = LUA_TNIL,             ///< Nil type.
			TBoolean        = LUA_TBOOLEAN,         ///< Boolean type.
			TLightUserdata  = LUA_TLIGHTUSERDATA,   ///< Light userdata type.
			TNumber         = LUA_TNUMBER,          ///< Number type.
			TString         = LUA_TSTRING,          ///< String type.
			TTable          = LUA_TTABLE,           ///< Table type.
			TFunction       = LUA_TFUNCTION,        ///< Function type.
			TUserdata       = LUA_TUSERDATA,        ///< User-data type.
			TThread         = LUA_TTHREAD,          ///< Thread type.
		};

		/** Status codes. */
		enum StatusCode {
			Ok              = LUA_OK,               ///< Success.
			Yield           = LUA_YIELD,            ///< Function yielded (succesfully).
			ErrorRun        = LUA_ERRRUN,           ///< Runtime error.
			ErrorSyntax     = LUA_ERRSYNTAX,        ///< Syntax error.
			ErrorMemory     = LUA_ERRMEM,           ///< Out-of-memory error.
			ErrorGC         = LUA_ERRGCMM,          ///< Garbage-collector failure.
			ErrorInternal   = LUA_ERRERR,           ///< Error occured insided error handler.
		};

		enum {
			MultRet         = LUA_MULTRET,          ///< All return values remain on stack after function call.
		};

		/** Pre-defined pseudo indexes. */
		enum PseudoIndexType {
			RegistryIndex   = LUA_REGISTRYINDEX,    ///< Pseudo-index of the registry table.
		};

		/** Predefined registry indexes. */
		enum {
			RegIdxMainThread= LUA_RIDX_MAINTHREAD,  ///< Registry-index of the main thread.
			RegIdxGlobals   = LUA_RIDX_GLOBALS,     ///< Registry-index of the global table.
		};

		/** Arithmetic operators. */
		enum OperatorType {
			OpAdd           = LUA_OPADD,            ///< Addition (+)
			OpSub           = LUA_OPSUB,            ///< Subtraction (-)
			OpMul           = LUA_OPMUL,            ///< Multiplication (*).
			OpMod           = LUA_OPMOD,            ///< Modulo (%)
			OpPow           = LUA_OPPOW,            ///< Exponentiation (^)
			OpDiv           = LUA_OPDIV,            ///< Division (/).
			OpIDiv          = LUA_OPIDIV,           ///< Floor division (//).
			OpBAnd          = LUA_OPBAND,           ///< Bitwise and (&).
			OpBOr           = LUA_OPBOR,            ///< Bitwise or (|).
			OpBXor          = LUA_OPBXOR,           ///< Bitwise exclusive or (~).
			OpShl           = LUA_OPSHL,            ///< Bitwise shift left (<<).
			OpShr           = LUA_OPSHR,            ///< Bitwise shift right (>>).
			OpUnm           = LUA_OPUNM,            ///< Unary minus (-).
			OpBNot          = LUA_OPBNOT,           ///< Bit-wise not (~).
		};

		/** Comparison operators. */
		enum ComparisonType {
			OpEQ            = LUA_OPEQ,             ///< Equality.
			OpLT            = LUA_OPLT,             ///< Less than.
			OpLE            = LUA_OPLE              ///< Less-equal than.
		};

		/** Garbage-collector control types. */
		enum GCType {
			GCStop          = LUA_GCSTOP,           ///< Stop the garbage collector.
			GCRestart       = LUA_GCRESTART,        ///< Restart garbage collector.
			GCCollect       = LUA_GCCOLLECT,        ///< Perform full garbage collection cycle.
			GCCount         = LUA_GCCOUNT,          ///< Get the current amount of memory (in Kbytes) in use by Lua.
			GCCountB        = LUA_GCCOUNTB,         ///< Get the remainder of dividing the current amount of bytes of memory in use by Lua by 1024.
			GCStep          = LUA_GCSTEP,           ///< Perform an incremental step of garbage collection.
			GCSetPause      = LUA_GCSETPAUSE,       ///< Set new value for the pause (see <a href=">FIXME</a>).
			GCSetStepMul    = LUA_GCSETSTEPMUL,     ///< Set new value for the step multiplier (see <a href=">FIXME</a>).
			GCIsRunning     = LUA_GCISRUNNING,      ///< Check if garbage collector is running.
		};

		/** Default %Lua integer type. */
		typedef lua_Integer Integer;

		/** Default %Lua unsigned integer type. */
		typedef lua_Unsigned Unsigned;

		/** Default %Lua nubmer type. */
		typedef lua_Number Number;

		/** String type. */
		typedef const char *String;

		/** User-data and light user-data pointer type. */
		typedef void *Userdata;

		/** User-data and light user-data const pointer type. */
		typedef const void *LightUserdata;

		/** Callback function type.
		 *
		 * <b>Implementing %Lua callbacks</b><br/>
		 *
		 * Example:
		 * @code
		 * LUA_API int lua_callback_function(lua::State L);
		 *
		 * int lua_callback_function(lua::State L) {
		 *     // do something ...
		 *     return 0;
		 * }
		 * @endcode
		 * */
		typedef lua_CFunction CFunction;

		/** Continuation context. */
		typedef lua_KContext KContext;
		/** Continuation function. */
		typedef lua_KFunction KFunction;

		/** Reader function type. */
		typedef lua_Reader Reader;
		/** Writer function type. */
		typedef lua_Writer Writer;

		/** Memory allocation function type. */
		typedef lua_Alloc Alloc;

		/** Get (raw) %Lua state. */
		operator State() const { return L; }

		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_newstate">lua_newstate</a>
		 * Creates a new thread running in a new, independent state. Returns NULL if it
		 * cannot create the thread or the state (due to lack of memory). The argument f
		 * is the allocator function; Lua does all memory allocation for this state
		 * through this function (see lua_Alloc). The second argument, ud, is an opaque
		 * pointer that Lua passes to the allocator in every call.
		 */
		void        newstate(Alloc f, void *ud = 0) { L = lua_newstate(f, ud); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_close">lua_close</a>
		 * Destroys all objects in the given Lua state (calling the corresponding garbage-
		 * collection metamethods, if any) and frees all dynamic memory used by this
		 * state. On several platforms, you may not need to call this function, because
		 * all resources are naturally released when the host program ends. On the other
		 * hand, long-running programs that create multiple states, such as daemons or web
		 * servers, will probably need to close states as soon as they are not needed.
		 */
		void        close() { lua_close(L); L = 0; }
		/** [-0, +1, m] <a href="https://www.lua.org/manual/5.1/manual.html#lua_newthread">lua_newthread</a>
		 * Creates a new thread, pushes it on the stack, and returns a pointer to a
		 * lua_State that represents this new thread. The new thread returned by this
		 * function shares with the original thread its global environment, but has an
		 * independent execution stack.
		 * There is no explicit function to close or to destroy a thread. Threads are
		 * subject to garbage collection, like any Lua object.
		 */
		State          newthread() { return lua_newthread(L); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_atpanic">lua_atpanic</a>
		 * Sets a new panic function and returns the old one (see §4.6).
		 */
		CFunction   atpanic(CFunction panicf) { return lua_atpanic(L, panicf); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_version">lua_version</a>
		 * Returns the address of the version number (a C static variable) stored in the
		 * Lua core. When called with a valid lua_State, returns the address of the
		 * version used to create that state. When called with NULL, returns the address
		 * of the version running the call.
		 */
		const Number *version() { return lua_version(L); }

		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_absindex">lua_absindex</a>
		 * Converts the acceptable index idx into an equivalent absolute index (that is,
		 * one that does not depend on the stack top).
		 */
		int         absindex(int idx) { return lua_absindex(L, idx); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_gettop">lua_gettop</a>
		 * Returns the index of the top element in the stack. Because indices start at 1,
		 * this result is equal to the number of elements in the stack; in particular,
		 * 0 means an empty stack.
		 */
		int         gettop() const { return lua_gettop(L); }
		/** [-?, +?, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_settop">lua_settop</a>
		 * Accepts any index, or 0, and sets the stack top to this index. If the new top
		 * is larger than the old one, then the new elements are filled with nil. If index
		 * is 0, then all stack elements are removed.
		 */
		void        settop(int idx) { lua_settop(L, idx); }
		/** [-0, +1, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_pushvalue">lua_pushvalue</a>
		 * Pushes a copy of the element at the given index onto the stack.
		 */
		void        pushvalue(int idx) { lua_pushvalue(L, idx); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_rotate">lua_rotate</a>
		 * Rotates the stack elements between the valid index idx and the top of the
		 * stack. The elements are rotated n positions in the direction of the top, for a
		 * positive n, or -n positions in the direction of the bottom, for a negative n.
		 * The absolute value of n must not be greater than the size of the slice being
		 * rotated. This function cannot be called with a pseudo-index, because a pseudo-
		 * index is not an actual stack position.
		 */
		void        rotate(int idx, int n) { lua_rotate(L, idx, n); }
		/** [-1, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_remove">lua_remove</a>
		 * Removes the element at the given valid index, shifting down the elements above
		 * this index to fill the gap. This function cannot be called with a pseudo-index,
		 * because a pseudo-index is not an actual stack position.
		 */
		void        remove(int idx) { lua_remove(L, idx); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_copy">lua_copy</a>
		 * Copies the element at index fromidx into the valid index toidx, replacing the
		 * value at that position. Values at other positions are not affected.
		 */
		void        copy(int fromidx, int toidx) { lua_copy(L, fromidx, toidx); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_checkstack">lua_checkstack</a>
		 * Ensures that the stack has space for at least n extra slots (that is, that you
		 * can safely push up to n values into it). It returns false if it cannot fulfill
		 * the request, either because it would cause the stack to be larger than a fixed
		 * maximum size (typically at least several thousand elements) or because it
		 * cannot allocate memory for the extra space. This function never shrinks the
		 * stack; if the stack already has space for the extra slots, it is left
		 * unchanged.
		 */
		int         checkstack(int n) { return lua_checkstack(L, n); }

		/** [-?, +?, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_xmove">lua_xmove</a>
		 * Exchange values between different threads of the same state.
		 * This function pops n values from the stack from, and pushes them onto the stack
		 * to.
		 */
		static void xmove(State src, State dest, int n) { lua_xmove(src, dest, n); }

		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_isboolean">lua_isboolean</a>
		 * Returns 1 if the value at the given index is a boolean, and 0 otherwise.
		 */
		int         isboolean(int idx) { return lua_isboolean(L, idx); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_iscfunction">lua_iscfunction</a>
		 * Returns 1 if the value at the given index is a C function, and 0 otherwise.
		 */
		int         iscfunction(int idx) { return lua_iscfunction(L, idx); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_isfunction">lua_isfunction</a>
		 * Returns 1 if the value at the given index is a function (either C or Lua), and
		 * 0 otherwise.
		 */
		int         isfunction(int idx) { return lua_isfunction(L, idx); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_isinteger">lua_isinteger</a>
		 * Returns 1 if the value at the given index is an integer (that is, the value is
		 * a number and is represented as an integer), and 0 otherwise.
		 */
		int         isinteger(int idx) { return lua_isinteger(L, idx); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_islightuserdata">lua_islightuserdata</a>
		 * Returns 1 if the value at the given index is a light userdata, and 0 otherwise.
		 */
		int         islightuserdata(int idx) { return lua_islightuserdata(L, idx); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_isnil">lua_isnil</a>
		 * Returns 1 if the value at the given index is nil, and 0 otherwise.
		 */
		int         isnil(int idx) { return lua_isnil(L, idx); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_isnone">lua_isnone</a>
		 * Returns 1 if the given index is not valid, and 0 otherwise.
		 */
		int         isnone(int idx) { return lua_isnone(L, idx); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_isnoneornil">lua_isnoneornil</a>
		 * Returns 1 if the given index is not valid or if the value at this index is nil,
		 * and 0 otherwise.
		 */
		int         isnoneornil(int idx) { return lua_isnoneornil(L, idx); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_isnumber">lua_isnumber</a>
		 * Returns 1 if the value at the given index is a number or a string convertible
		 * to a number, and 0 otherwise.
		 */
		int         isnumber(int idx) { return lua_isnumber(L, idx); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_isstring">lua_isstring</a>
		 * Returns 1 if the value at the given index is a string or a number (which is
		 * always convertible to a string), and 0 otherwise.
		 */
		int         isstring(int idx) { return lua_isstring(L, idx); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_istable">lua_istable</a>
		 * Returns 1 if the value at the given index is a table, and 0 otherwise.
		 */
		int         istable(int idx) { return lua_istable(L, idx); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_isthread">lua_isthread</a>
		 * Returns 1 if the value at the given index is a thread, and 0 otherwise.
		 */
		int         isthread(int idx) { return lua_isthread(L, idx); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_isuserdata">lua_isuserdata</a>
		 * Returns 1 if the value at the given index is a userdata (either full or light),
		 * and 0 otherwise.
		 */
		int         isuserdata(int idx) { return lua_isuserdata(L, idx); }

		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_type">lua_type</a>
		 * Returns the type of the value in the given valid index, or LUA_TNONE for a non-
		 * valid (but acceptable) index. The types returned by lua_type are coded by the
		 * following constants defined in lua.h: LUA_TNIL (0), LUA_TNUMBER, LUA_TBOOLEAN,
		 * LUA_TSTRING, LUA_TTABLE, LUA_TFUNCTION, LUA_TUSERDATA, LUA_TTHREAD, and
		 * LUA_TLIGHTUSERDATA.
		 */
		int         type(int idx) { return lua_type(L, idx); }

		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_typename">lua_typename</a>
		 * Returns the name of the type encoded by the value tp, which must be one the
		 * values returned by lua_type.
		 */
		const char *typeName(int tp) { return lua_typename(L, tp); }

		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_toboolean">lua_toboolean</a>
		 * Converts the Lua value at the given index to a C boolean value (0 or 1). Like
		 * all tests in Lua, lua_toboolean returns true for any Lua value different from
		 * false and nil; otherwise it returns false. (If you want to accept only actual
		 * boolean values, use lua_isboolean to test the value's type.)
		 */
		int         toboolean(int idx) const { return lua_toboolean(L, idx); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_tocfunction">lua_tocfunction</a>
		 * Converts a value at the given index to a C function. That value must be a
		 * C function; otherwise, returns NULL.
		 */
		CFunction   tocfunction(int idx) const { return lua_tocfunction(L, idx); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_tointegerx">lua_tointegerx</a>
		 * Converts the Lua value at the given index to the signed integral type
		 * lua_Integer. The Lua value must be an integer, or a number or string
		 * convertible to an integer (see §3.4.3); otherwise, lua_tointegerx returns 0.
		 * If isnum is not NULL, its referent is assigned a boolean value that indicates
		 * whether the operation succeeded.
		 */
		Integer     tointeger(int idx, int *isnum = 0) const { return lua_tointegerx(L, idx, isnum); }
		/** [-0, +0, m] <a href="https://www.lua.org/manual/5.1/manual.html#lua_tolstring">lua_tolstring</a>
		 * Converts the Lua value at the given index to a C string. If len is not NULL, it
		 * sets *len with the string length. The Lua value must be a string or a number;
		 * otherwise, the function returns NULL. If the value is a number, then
		 * lua_tolstring also changes the actual value in the stack to a string. (This
		 * change confuses lua_next when lua_tolstring is applied to keys during a table
		 * traversal.)
		 * lua_tolstring returns a pointer to a string inside the Lua state. This string
		 * always has a zero ('\0') after its last character (as in C), but can contain
		 * other zeros in its body.
		 * Because Lua has garbage collection, there is no guarantee that the pointer
		 * returned by lua_tolstring will be valid after the corresponding Lua value is
		 * removed from the stack.
		 */
		String      tolstring(int idx, size_t *len) const { return lua_tolstring(L, idx, len); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_tonumberx">lua_tonumberx</a>
		 * Converts the Lua value at the given index to the C type lua_Number (see
		 * lua_Number). The Lua value must be a number or a string convertible to a number
		 * (see §3.4.3); otherwise, lua_tonumberx returns 0.
		 * If isnum is not NULL, its referent is assigned a boolean value that indicates
		 * whether the operation succeeded.
		 */
		Number      tonumber(int idx, int *isnum = 0) const { return lua_tonumberx(L, idx, isnum); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_topointer">lua_topointer</a>
		 * Converts the value at the given index to a generic C pointer (void*). The value
		 * can be a userdata, a table, a thread, or a function; otherwise, lua_topointer
		 * returns NULL. Different objects will give different pointers. There is no way
		 * to convert the pointer back to its original value.
		 * Typically this function is used only for hashing and debug information.
		 */
		LightUserdata topointer(int idx) const { return lua_topointer(L, idx); }
		/** [-0, +0, m] <a href="https://www.lua.org/manual/5.1/manual.html#lua_tostring">lua_tostring</a>
		 * Equivalent to lua_tolstring with len equal to NULL.
		 */
		String      tostring(int idx) const { return lua_tostring(L, idx); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_tothread">lua_tothread</a>
		 * Converts the value at the given index to a Lua thread (represented as
		 * lua_State*). This value must be a thread; otherwise, the function returns NULL.
		 */
		State       tothread(int idx) const { return lua_tothread(L, idx); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_touserdata">lua_touserdata</a>
		 * If the value at the given index is a full userdata, returns its block address.
		 * If the value is a light userdata, returns its pointer. Otherwise, returns NULL.
		 */
		Userdata    touserdata(int idx) const { return lua_touserdata(L, idx); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_rawlen">lua_rawlen</a>
		 * Returns the raw "length" of the value at the given index: for strings, this is
		 * the string length; for tables, this is the result of the length operator ('#')
		 * with no metamethods; for userdata, this is the size of the block of memory
		 * allocated for the userdata; for other values, it is 0.
		 */
		size_t      rawlen(int idx) const { return lua_rawlen(L, idx); }

		/** [-(2|1), +1, e] <a href="https://www.lua.org/manual/5.1/manual.html#lua_arith">lua_arith</a>
		 * Performs an arithmetic or bitwise operation over the two values (or one, in the
		 * case of negations) at the top of the stack, with the value at the top being the
		 * second operand, pops these values, and pushes the result of the operation. The
		 * function follows the semantics of the corresponding Lua operator (that is, it
		 * may call metamethods).
		 * The value of op must be one of the following constants:
		 *     * LUA_OPADD: performs addition (+)
		 *     * LUA_OPSUB: performs subtraction (-)
		 *     * LUA_OPMUL: performs multiplication (*)
		 *     * LUA_OPDIV: performs float division (/)
		 *     * LUA_OPIDIV: performs floor division (//)
		 *     * LUA_OPMOD: performs modulo (%)
		 *     * LUA_OPPOW: performs exponentiation (^)
		 *     * LUA_OPUNM: performs mathematical negation (unary -)
		 *     * LUA_OPBNOT: performs bitwise NOT (~)
		 *     * LUA_OPBAND: performs bitwise AND (&)
		 *     * LUA_OPBOR: performs bitwise OR (|)
		 *     * LUA_OPBXOR: performs bitwise exclusive OR (~)
		 *     * LUA_OPSHL: performs left shift (<<)
		 *     * LUA_OPSHR: performs right shift (>>)
		 */
		void        arith(int op) { lua_arith(L, op); }

		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_rawequal">lua_rawequal</a>
		 * Returns 1 if the two values in indices index1 and index2 are primitively equal
		 * (that is, without calling the __eq metamethod). Otherwise returns 0. Also
		 * returns 0 if any of the indices are not valid.
		 */
		int         rawequal( int idx1, int idx2) { return lua_rawequal(L, idx1, idx2); }
		/** [-0, +0, e] <a href="https://www.lua.org/manual/5.1/manual.html#lua_compare">lua_compare</a>
		 * Compares two Lua values. Returns 1 if the value at index index1 satisfies op
		 * when compared with the value at index index2, following the semantics of the
		 * corresponding Lua operator (that is, it may call metamethods). Otherwise
		 * returns 0. Also returns 0 if any of the indices is not valid.
		 * The value of op must be one of the following constants:
		 *     * LUA_OPEQ: compares for equality (==)
		 *     * LUA_OPLT: compares for less than (<)
		 *     * LUA_OPLE: compares for less or equal (<=)
		 */
		int         compare(int idx1, int idx2, int op) { return lua_compare(L, idx1, idx2, op); }

		/** [-n, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_pop">lua_pop</a>
		 * Pops n elements from the stack.
		 */
		void        pop(int n) { lua_pop(L, n); }

		/** [-0, +1, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_pushnil">lua_pushnil</a>
		 * Pushes a nil value onto the stack.
		 */
		void        pushnil() { lua_pushnil(L); }
		/** [-0, +1, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_pushnumber">lua_pushnumber</a>
		 * Pushes a float with value n onto the stack.
		 */
		void        pushnumber(Number n) { lua_pushnumber(L, n); }
		/** [-0, +1, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_pushinteger">lua_pushinteger</a>
		 * Pushes an integer with value n onto the stack.
		 */
		void        pushinteger(Integer n) { lua_pushinteger(L, n); }
		/** [-0, +1, m] <a href="https://www.lua.org/manual/5.1/manual.html#lua_pushlstring">lua_pushlstring</a>
		 * Pushes the string pointed to by s with size len onto the stack. Lua makes (or
		 * reuses) an internal copy of the given string, so the memory at s can be freed
		 * or reused immediately after the function returns. The string can contain any
		 * binary data, including embedded zeros.
		 * Returns a pointer to the internal copy of the string.
		 */
		String      pushlstring(const char *s, size_t len) {  return lua_pushlstring(L, s, len); }
		/** [-0, +1, m] <a href="https://www.lua.org/manual/5.1/manual.html#lua_pushstring">lua_pushstring</a>
		 * Pushes the zero-terminated string pointed to by s onto the stack. Lua makes (or
		 * reuses) an internal copy of the given string, so the memory at s can be freed
		 * or reused immediately after the function returns.
		 * Returns a pointer to the internal copy of the string.
		 * If s is NULL, pushes nil and returns NULL.
		 */
		String      pushstring(const char *s) { return lua_pushstring(L, s); }
		/** [-0, +1, m] <a href="https://www.lua.org/manual/5.1/manual.html#lua_pushvfstring">lua_pushvfstring</a>
		 *                               const char *fmt,
		 *                               va_list argp);
		 * Equivalent to lua_pushfstring, except that it receives a va_list instead of a
		 * variable number of arguments.
		 */
		String      pushvfstring(const char *fmt, va_list argp) { return lua_pushvfstring(L, fmt, argp); }
		/** FIXME */
		String      pushfstring(const char *fmt, ...) {
			va_list ap;

			va_start(ap, fmt);
			const char *retval = pushvfstring(fmt, ap);
			va_end(ap);

			return retval;
		}
		/** [-n, +1, m] <a href="https://www.lua.org/manual/5.1/manual.html#lua_pushcclosure">lua_pushcclosure</a>
		 * Pushes a new C closure onto the stack.
		 * When a C function is created, it is possible to associate some values with it,
		 * thus creating a C closure (see §4.4); these values are then accessible to the
		 * function whenever it is called. To associate values with a C function, first
		 * these values must be pushed onto the stack (when there are multiple values, the
		 * first value is pushed first). Then lua_pushcclosure is called to create and
		 * push the C function onto the stack, with the argument n telling how many values
		 * will be associated with the function. lua_pushcclosure also pops these values
		 * from the stack.
		 * The maximum value for n is 255.
		 * When n is zero, this function creates a light C function, which is just a
		 * pointer to the C function. In that case, it never raises a memory error.
		 */
		void        pushcclosure(CFunction fn, int n) { lua_pushcclosure(L, fn, n); }
		/** [-0, +1, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_pushboolean">lua_pushboolean</a>
		 * Pushes a boolean value with value b onto the stack.
		 */
		void        pushboolean(int b) { lua_pushboolean(L, b); }
		/** [-0, +1, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_pushlightuserdata">lua_pushlightuserdata</a>
		 * Pushes a light userdata onto the stack.
		 * Userdata represent C values in Lua. A light userdata represents a pointer, a
		 * void*. It is a value (like a number): you do not create it, it has no
		 * individual metatable, and it is not collected (as it was never created). A
		 * light userdata is equal to "any" light userdata with the same C address.
		 */
		void        pushlightuserdata(Userdata p) { lua_pushlightuserdata(L, p); }
		/** [-0, +1, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_pushthread">lua_pushthread</a>
		 * Pushes the thread represented by L onto the stack. Returns 1 if this thread is
		 * the main thread of its state.
		 */
		int         pushthread() { return lua_pushthread(L); }
		/** [-0, +1, e] <a href="https://www.lua.org/manual/5.1/manual.html#lua_getglobal">lua_getglobal</a>
		 * Pushes onto the stack the value of the global name. Returns the type of that
		 * value.
		 */
		int         getglobal(const char *name) { return lua_getglobal(L, name); }
		/** [-1, +1, e] <a href="https://www.lua.org/manual/5.1/manual.html#lua_gettable">lua_gettable</a>
		 * Pushes onto the stack the value t[k], where t is the value at the given index
		 * and k is the value at the top of the stack.
		 * This function pops the key from the stack, pushing the resulting value in its
		 * place. As in Lua, this function may trigger a metamethod for the "index" event
		 * (see §2.4).
		 * Returns the type of the pushed value.
		 */
		int         gettable(int idx) { return lua_gettable(L, idx); }
		/** [-0, +1, e] <a href="https://www.lua.org/manual/5.1/manual.html#lua_getfield">lua_getfield</a>
		 * Pushes onto the stack the value t[k], where t is the value at the given index.
		 * As in Lua, this function may trigger a metamethod for the "index" event (see
		 * §2.4).
		 * Returns the type of the pushed value.
		 */
		int         getfield(int idx, const char *k) { return lua_getfield(L, idx, k); }
		/** [-0, +1, e] <a href="https://www.lua.org/manual/5.1/manual.html#lua_geti">lua_geti</a>
		 * Pushes onto the stack the value t[i], where t is the value at the given index.
		 * As in Lua, this function may trigger a metamethod for the "index" event (see
		 * §2.4).
		 * Returns the type of the pushed value.
		 */
		int         geti(int idx, Integer i) { return lua_geti(L, idx, i); }
		/** [-1, +1, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_rawget">lua_rawget</a>
		 * Similar to lua_gettable, but does a raw access (i.e., without metamethods).
		 */
		int         rawget(int idx) { return lua_rawget(L, idx); }
		/** [-0, +1, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_rawgeti">lua_rawgeti</a>
		 * Pushes onto the stack the value t[n], where t is the table at the given index.
		 * The access is raw, that is, it does not invoke the __index metamethod.
		 * Returns the type of the pushed value.
		 */
		int         rawgeti(int idx, Integer n) { return lua_rawgeti(L, idx, n); }
		/** [-0, +1, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_rawgetp">lua_rawgetp</a>
		 * Pushes onto the stack the value t[k], where t is the table at the given index
		 * and k is the pointer p represented as a light userdata. The access is raw; that
		 * is, it does not invoke the __index metamethod.
		 * Returns the type of the pushed value.
		 */
		int         rawgetp(int idx, const void *p) { return lua_rawgetp(L, idx, p); }

		/** [-0, +1, m] <a href="https://www.lua.org/manual/5.1/manual.html#lua_createtable">lua_createtable</a>
		 * Creates a new empty table and pushes it onto the stack. Parameter narr is a
		 * hint for how many elements the table will have as a sequence; parameter nrec is
		 * a hint for how many other elements the table will have. Lua may use these hints
		 * to preallocate memory for the new table. This preallocation is useful for
		 * performance when you know in advance how many elements the table will have.
		 * Otherwise you can use the function lua_newtable.
		 */
		void        createtable(int narr = 0, int nrec = 0) { lua_createtable(L, narr, nrec); }
		/** [-0, +1, m] <a href="https://www.lua.org/manual/5.1/manual.html#lua_newuserdata">lua_newuserdata</a>
		 * This function allocates a new block of memory with the given size, pushes onto
		 * the stack a new full userdata with the block address, and returns this address.
		 * The host program can freely use this memory.
		 */
		Userdata    newuserdata(size_t sz) { return lua_newuserdata(L, sz); }
		/** [-0, +(0|1), –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_getmetatable">lua_getmetatable</a>
		 * If the value at the given index has a metatable, the function pushes that
		 * metatable onto the stack and returns 1. Otherwise, the function returns 0 and
		 * pushes nothing on the stack.
		 */
		int         getmetatable(int idx) { return lua_getmetatable(L, idx); }
		/** [-0, +1, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_getuservalue">lua_getuservalue</a>
		 * Pushes onto the stack the Lua value associated with the full userdata at the
		 * given index.
		 * Returns the type of the pushed value.
		 */
		int         getuservalue(int idx) { return lua_getuservalue(L, idx); }

		/** [-1, +0, e] <a href="https://www.lua.org/manual/5.1/manual.html#lua_setglobal">lua_setglobal</a>
		 * Pops a value from the stack and sets it as the new value of global name.
		 */
		void        setglobal(const char *name) { lua_setglobal(L, name); }
		/** [-2, +0, e] <a href="https://www.lua.org/manual/5.1/manual.html#lua_settable">lua_settable</a>
		 * Does the equivalent to t[k] = v, where t is the value at the given index, v is
		 * the value at the top of the stack, and k is the value just below the top.
		 * This function pops both the key and the value from the stack. As in Lua, this
		 * function may trigger a metamethod for the "newindex" event (see §2.4).
		 */
		void        settable(int idx) { lua_settable(L, idx); }
		/** [-1, +0, e] <a href="https://www.lua.org/manual/5.1/manual.html#lua_setfield">lua_setfield</a>
		 * Does the equivalent to t[k] = v, where t is the value at the given index and v
		 * is the value at the top of the stack.
		 * This function pops the value from the stack. As in Lua, this function may
		 * trigger a metamethod for the "newindex" event (see §2.4).
		 */
		void        setfield(int idx, const char *k) { lua_setfield(L, idx, k); }
		/** [-1, +0, e] <a href="https://www.lua.org/manual/5.1/manual.html#lua_seti">lua_seti</a>
		 * Does the equivalent to t[n] = v, where t is the value at the given index and v
		 * is the value at the top of the stack.
		 * This function pops the value from the stack. As in Lua, this function may
		 * trigger a metamethod for the "newindex" event (see §2.4).
		 */
		void        seti(int idx, Integer n) { lua_seti(L, idx, n); }
		/** [-2, +0, m] <a href="https://www.lua.org/manual/5.1/manual.html#lua_rawset">lua_rawset</a>
		 * Similar to lua_settable, but does a raw assignment (i.e., without metamethods).
		 */
		void        rawset(int idx) { lua_rawset(L, idx); }
		/** [-1, +0, m] <a href="https://www.lua.org/manual/5.1/manual.html#lua_rawseti">lua_rawseti</a>
		 * Does the equivalent of t[i] = v, where t is the table at the given index and v
		 * is the value at the top of the stack.
		 * This function pops the value from the stack. The assignment is raw, that is, it
		 * does not invoke the __newindex metamethod.
		 */
		void        rawseti(int idx, Integer n) { lua_rawseti(L, idx, n); }
		/** [-1, +0, m] <a href="https://www.lua.org/manual/5.1/manual.html#lua_rawsetp">lua_rawsetp</a>
		 * Does the equivalent of t[p] = v, where t is the table at the given index, p is
		 * encoded as a light userdata, and v is the value at the top of the stack.
		 * This function pops the value from the stack. The assignment is raw, that is, it
		 * does not invoke __newindex metamethod.
		 */
		void        rawsetp(int idx, const void *p) { lua_rawsetp(L, idx, p); }
		/** [-1, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_setmetatable">lua_setmetatable</a>
		 * Pops a table from the stack and sets it as the new metatable for the value at
		 * the given index.
		 */
		int         setmetatable(int objindex) { return lua_setmetatable(L, objindex); }
		/** [-1, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_setuservalue">lua_setuservalue</a>
		 * Pops a value from the stack and sets it as the new value associated to the full
		 * userdata at the given index.
		 */
		void        setuservalue(int idx) { lua_setuservalue(L, idx); }

		/** [-(nargs + 1), +nresults, e] <a href="https://www.lua.org/manual/5.1/manual.html#lua_callk">lua_callk</a>
		 * This function behaves exactly like lua_call, but allows the called function to
		 * yield (see §4.7).
		 */
		void        call(int nargs, int nresults, KContext ctx = 0, KFunction k = 0) { lua_callk(L, nargs, nresults, ctx, k); }
		/** [-(nargs + 1), +(nresults|1), –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_pcallk">lua_pcallk</a>
		 * This function behaves exactly like lua_pcall, but allows the called function to
		 * yield (see §4.7).
		 */
		int         pcall(int nargs, int nresults, int errfunc = 0, KContext ctx = 0, KFunction k = 0) {
			return lua_pcallk(L, nargs, nresults, errfunc, ctx, k); }
		/** [-0, +1, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_load">lua_load</a>
		 * Loads a Lua chunk without running it. If there are no errors, lua_load pushes
		 * the compiled chunk as a Lua function on top of the stack. Otherwise, it pushes
		 * an error message.
		 * The return values of lua_load are:
		 *     * LUA_OK: no errors;
		 *     * LUA_ERRSYNTAX: syntax error during precompilation;
		 *     * LUA_ERRMEM: memory allocation (out-of-memory) error;
		 *     * LUA_ERRGCMM: error while running a __gc metamethod. (This error has no
		 *       relation with the chunk being loaded. It is generated by the garbage
		 *       collector.)
		 * The lua_load function uses a user-supplied reader function to read the chunk
		 * (see lua_Reader). The data argument is an opaque value passed to the reader
		 * function.
		 *
		 * The chunkname argument gives a name to the chunk, which is used for error
		 * messages and in debug information (see §4.9).
		 *
		 * lua_load automatically detects whether the chunk is text or binary and loads it
		 * accordingly (see program luac). The string mode works as in function load, with
		 * the addition that a NULL value is equivalent to the string "bt".
		 * lua_load uses the stack internally, so the reader function must always leave
		 * the stack unmodified when returning.
		 *
		 * If the resulting function has upvalues, its first upvalue is set to the value
		 * of the global environment stored at index LUA_RIDX_GLOBALS in the registry (see
		 * §4.5). When loading main chunks, this upvalue will be the _ENV variable (see
		 * §2.2). Other upvalues are initialized with nil.
		 */
		int         load(Reader reader, void *dt,const char *chunkname, const char *mode) {
			return lua_load(L, reader, dt, chunkname, mode); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_dump">lua_dump</a>
		 *                         lua_Writer writer,
		 *                         void *data,
		 *                         int strip);
		 * Dumps a function as a binary chunk. Receives a Lua function on the top of the
		 * stack and produces a binary chunk that, if loaded again, results in a function
		 * equivalent to the one dumped. As it produces parts of the chunk, lua_dump calls
		 * function writer (see lua_Writer) with the given data to write them.
		 *
		 * If strip is true, the binary representation may not include all debug
		 * information about the function, to save space.
		 * The value returned is the error code returned by the last call to the writer;
		 * 0 means no errors.
		 *
		 * This function does not pop the Lua function from the stack.
		 */
		int         dump(Writer writer, void *data, int strip) { return lua_dump(L, writer, data, strip); }

		/** [-?, +?, e] <a href="https://www.lua.org/manual/5.1/manual.html#lua_yieldk">lua_yieldk</a>
		 * Yields a coroutine (thread).
		 * When a C function calls lua_yieldk, the running coroutine suspends its
		 * execution, and the call to lua_resume that started this coroutine returns. The
		 * parameter nresults is the number of values from the stack that will be passed
		 * as results to lua_resume.
		 * When the coroutine is resumed again, Lua calls the given continuation function
		 * k to continue the execution of the C function that yielded (see §4.7). This
		 * continuation function receives the same stack from the previous function, with
		 * the n results removed and replaced by the arguments passed to lua_resume.
		 * Moreover, the continuation function receives the value ctx that was passed to
		 * lua_yieldk.
		 * Usually, this function does not return; when the coroutine eventually resumes,
		 * it continues executing the continuation function. However, there is one special
		 * case, which is when this function is called from inside a line or a count hook
		 * (see §4.9). In that case, lua_yieldk should be called with no continuation
		 * (probably in the form of lua_yield) and no results, and the hook should return
		 * immediately after the call. Lua will yield and, when the coroutine resumes
		 * again, it will continue the normal execution of the (Lua) function that
		 * triggered the hook.
		 * This function can raise an error if it is called from a thread with a pending C
		 * call with no continuation function, or it is called from a thread that is not
		 * running inside a resume (e.g., the main thread).
		 */
		int         yield(int nresults, KContext ctx = 0, KFunction k = 0) { return lua_yieldk(L, nresults, ctx, k); }
		/** [-?, +?, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_resume">lua_resume</a>
		 * Starts and resumes a coroutine in the given thread L.
		 * To start a coroutine, you push onto the thread stack the main function plus any
		 * arguments; then you call lua_resume, with nargs being the number of arguments.
		 * This call returns when the coroutine suspends or finishes its execution. When
		 * it returns, the stack contains all values passed to lua_yield, or all values
		 * returned by the body function. lua_resume returns LUA_YIELD if the coroutine
		 * yields, LUA_OK if the coroutine finishes its execution without errors, or an
		 * error code in case of errors (see lua_pcall).
		 * In case of errors, the stack is not unwound, so you can use the debug API over
		 * it. The error object is on the top of the stack.
		 * To resume a coroutine, you remove any results from the last lua_yield, put on
		 * its stack only the values to be passed as results from yield, and then call
		 * lua_resume.
		 * The parameter from represents the coroutine that is resuming L. If there is no
		 * such coroutine, this parameter can be NULL.
		 */
		int         resume(State from, int narg) { return lua_resume(L, from, narg); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_status">lua_status</a>
		 * Returns the status of the thread L.
		 * The status can be 0 (LUA_OK) for a normal thread, an error code if the thread
		 * finished the execution of a lua_resume with an error, or LUA_YIELD if the
		 * thread is suspended.
		 * You can only call functions in threads with status LUA_OK. You can resume
		 * threads with status LUA_OK (to start a new coroutine) or LUA_YIELD (to resume a
		 * coroutine).
		 */
		int         status() { return lua_status(L); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_isyieldable">lua_isyieldable</a>
		 * Returns 1 if the given coroutine can yield, and 0 otherwise.
		 */
		int         isyieldable() { return lua_isyieldable(L); }

		/** [-0, +0, m] <a href="https://www.lua.org/manual/5.1/manual.html#lua_gc">lua_gc</a>
		 * Controls the garbage collector.
		 * This function performs several tasks, according to the value of the parameter
		 * what:
		 *     * LUA_GCSTOP: stops the garbage collector.
		 *     * LUA_GCRESTART: restarts the garbage collector.
		 *     * LUA_GCCOLLECT: performs a full garbage-collection cycle.
		 *     * LUA_GCCOUNT: returns the current amount of memory (in Kbytes) in use by
		 *       Lua.
		 *     * LUA_GCCOUNTB: returns the remainder of dividing the current amount of
		 *       bytes of memory in use by Lua by 1024.
		 *     * LUA_GCSTEP: performs an incremental step of garbage collection.
		 *     * LUA_GCSETPAUSE: sets data as the new value for the pause of the collector
		 *       (see §2.5) and returns the previous value of the pause.
		 *     * LUA_GCSETSTEPMUL: sets data as the new value for the step multiplier of
		 *       the collector (see §2.5) and returns the previous value of the step
		 *       multiplier.
		 *     * LUA_GCISRUNNING: returns a boolean that tells whether the collector is
		 *       running (i.e., not stopped).
		 * For more details about these options, see collectgarbage.
		 */
		int         gc(int what, int data) { return lua_gc(L, what, data); }

		/** [-1, +0, v] <a href="https://www.lua.org/manual/5.1/manual.html#lua_error">lua_error</a>
		 * Generates a Lua error, using the value at the top of the stack as the error
		 * object. This function does a long jump, and therefore never returns (see
		 * luaL_error).
		 */
		void        error() __attribute__((noreturn)) { lua_error(L); }

		/** [-1, +(2|0), e] <a href="https://www.lua.org/manual/5.1/manual.html#lua_next">lua_next</a>
		 * Pops a key from the stack, and pushes a key–value pair from the table at the
		 * given index (the "next" pair after the given key). If there are no more
		 * elements in the table, then lua_next returns 0 (and pushes nothing).
		 * A typical traversal looks like this:
		 * @code
		 *      // table is in the stack at index 't'
		 *      lua_pushnil(L);  // first key
		 *      while (lua_next(L, t) != 0) {
		 *        // uses 'key' (at index -2) and 'value' (at index -1)
		 *        printf("%s - %s\n",
		 *               lua_typename(L, lua_type(L, -2)),
		 *               lua_typename(L, lua_type(L, -1)));
		 *        // removes 'value'; keeps 'key' for next iteration
		 *        lua_pop(L, 1);
		 *      }
		 * @endcode
		 * While traversing a table, do not call lua_tolstring directly on a key, unless
		 * you know that the key is actually a string. Recall that lua_tolstring may
		 * change the value at the given index; this confuses the next call to lua_next.
		 * See function next for the caveats of modifying the table during its traversal.
		 */
		int         next(int idx) { return lua_next(L, idx); }

		/** [-n, +1, e] <a href="https://www.lua.org/manual/5.1/manual.html#lua_concat">lua_concat</a>
		 * Concatenates the n values at the top of the stack, pops them, and leaves the
		 * result at the top. If n is 1, the result is the single value on the stack (that
		 * is, the function does nothing); if n is 0, the result is the empty string.
		 * Concatenation is performed following the usual semantics of Lua (see §3.4.6).
		 */
		void        concat(int n) { lua_concat(L, n); }
		/** [-0, +1, e] <a href="https://www.lua.org/manual/5.1/manual.html#lua_len">lua_len</a>
		 * Returns the length of the value at the given index. It is equivalent to the '#'
		 * operator in Lua (see §3.4.7) and may trigger a metamethod for the "length"
		 * event (see §2.4). The result is pushed on the stack.
		 */
		void        pushlen(int idx) { lua_len(L, idx); }

		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_getallocf">lua_getallocf</a>
		 * Returns the memory-allocation function of a given state. If ud is not NULL, Lua
		 * stores in *ud the opaque pointer given when the memory-allocator function was
		 * set.
		 */
		Alloc       getallocf(void **ud) { return lua_getallocf(L, ud); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_setallocf">lua_setallocf</a>
		 * Changes the allocator function of a given state to f with user data ud.
		 */
		void        setallocf(Alloc f, void *ud) { lua_setallocf(L, f, ud); }

		/** [-0, +1, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_stringtonumber">lua_stringtonumber</a>
		 * Converts the zero-terminated string s to a number, pushes that number into the
		 * stack, and returns the total size of the string, that is, its length plus one.
		 * The conversion can result in an integer or a float, according to the lexical
		 * conventions of Lua (see §3.1). The string may have leading and trailing spaces
		 * and a sign. If the string is not a valid numeral, returns 0 and pushes nothing.
		 * (Note that the result can be used as a boolean, true if the conversion
		 * succeeds.)
		 */
		size_t      stringtonumber(String s) { return lua_stringtonumber(L, s); }

		/** FIXME */
		enum DebugHookType {
			HookCall = LUA_HOOKCALL,
			HookRet = LUA_HOOKRET,
			HookLine = LUA_HOOKLINE,
			HookCount = LUA_HOOKCOUNT,
			HookTailCall = LUA_HOOKTAILCALL,
		};

		/** FIXME */
		enum DebugMaskType {
			MaskCall = LUA_MASKCALL,
			MaskRet = LUA_MASKRET,
			MaskLine = LUA_MASKLINE,
			MaskCount = LUA_MASKCOUNT,
		};

		/** lua_Debug */
		typedef lua_Debug Debug;

		/** lua_Hook */
		typedef lua_Hook Hook;

		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_getstack">lua_getstack</a>
		 * Gets information about the interpreter runtime stack.
		 * This function fills parts of a lua_Debug structure with an identification of
		 * the activation record of the function executing at a given level. Level 0 is
		 * the current running function, whereas level n+1 is the function that has called
		 * level n (except for tail calls, which do not count on the stack). When there
		 * are no errors, lua_getstack returns 1; when called with a level greater than
		 * the stack depth, it returns 0.
		 */
		int         getstack(int level, Debug *ar) { return lua_getstack(L, level, ar); }
		/** [-(0|1), +(0|1|2), e] <a href="https://www.lua.org/manual/5.1/manual.html#lua_getinfo">lua_getinfo</a>
		 * Gets information about a specific function or function invocation.
		 * To get information about a function invocation, the parameter ar must be a
		 * valid activation record that was filled by a previous call to lua_getstack or
		 * given as argument to a hook (see lua_Hook).
		 */
	#if 0
		 * To get information about a function you push it onto the stack and start the
		 * what string with the character '>'. (In that case, lua_getinfo pops the
		 * function from the top of the stack.) For instance, to know in which line a
		 * function f was defined, you can write the following code:
		 *      lua_Debug ar;
		 *      lua_getglobal(L, "f");  // get global 'f'
		 *      lua_getinfo(L, ">S", &ar);
		 *      printf("%d\n", ar.linedefined);
		 * Each character in the string what selects some fields of the structure ar to be
		 * filled or a value to be pushed on the stack:
		 *     * 'n': fills in the field name and namewhat;
		 *     * 'S': fills in the fields source, short_src, linedefined, lastlinedefined,
		 *       and what;
		 *     * 'l': fills in the field currentline;
		 *     * 't': fills in the field istailcall;
		 *     * 'u': fills in the fields nups, nparams, and isvararg;
		 *     * 'f': pushes onto the stack the function that is running at the given
		 *       level;
		 *     * 'L': pushes onto the stack a table whose indices are the numbers of the
		 *       lines that are valid on the function. (A valid line is a line with some
		 *       associated code, that is, a line where you can put a break point. Non-
		 *       valid lines include empty lines and comments.)
		 *       If this option is given together with option 'f', its table is pushed
		 *       after the function.
		 * This function returns 0 on error (for instance, an invalid option in what).
		 */
	#endif
		int         getinfo(String what, Debug *ar) { return lua_getinfo(L, what, ar); }
		/** [-0, +(0|1), –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_getlocal">lua_getlocal</a>
		 * Gets information about a local variable of a given activation record or a given
		 * function.
		 * In the first case, the parameter ar must be a valid activation record that was
		 * filled by a previous call to lua_getstack or given as argument to a hook (see
		 * lua_Hook). The index n selects which local variable to inspect; see
		 * debug.getlocal for details about variable indices and names.
		 * lua_getlocal pushes the variable's value onto the stack and returns its name.
		 * In the second case, ar must be NULL and the function to be inspected must be at
		 * the top of the stack. In this case, only parameters of Lua functions are
		 * visible (as there is no information about what variables are active) and no
		 * values are pushed onto the stack.
		 * Returns NULL (and pushes nothing) when the index is greater than the number of
		 * active local variables.
		 */
		String      getlocal(const Debug *ar, int n) { return lua_getlocal(L, ar, n); }
		/** [-(0|1), +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_setlocal">lua_setlocal</a>
		 * Sets the value of a local variable of a given activation record. It assigns the
		 * value at the top of the stack to the variable and returns its name. It also
		 * pops the value from the stack.
		 * Returns NULL (and pops nothing) when the index is greater than the number of
		 * active local variables.
		 * Parameters ar and n are as in function lua_getlocal.
		 */
		String      setlocal(const Debug *ar, int n) { return lua_setlocal(L, ar, n); }
		/** [-0, +(0|1), –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_getupvalue">lua_getupvalue</a>
		 * Gets information about the n-th upvalue of the closure at index funcindex. It
		 * pushes the upvalue's value onto the stack and returns its name. Returns NULL
		 * (and pushes nothing) when the index n is greater than the number of upvalues.
		 * For C functions, this function uses the empty string "" as a name for all
		 * upvalues. (For Lua functions, upvalues are the external local variables that
		 * the function uses, and that are consequently included in its closure.)
		 * Upvalues have no particular order, as they are active through the whole
		 * function. They are numbered in an arbitrary order.
		 */
		String      getupvalue(int funcindex, int n) { return lua_getupvalue(L, funcindex, n); }
		/** [-(0|1), +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_setupvalue">lua_setupvalue</a>
		 * Sets the value of a closure's upvalue. It assigns the value at the top of the
		 * stack to the upvalue and returns its name. It also pops the value from the
		 * stack.
		 * Returns NULL (and pops nothing) when the index n is greater than the number of
		 * upvalues.
		 * Parameters funcindex and n are as in function lua_getupvalue.
		 */
		String      setupvalue(int funcindex, int n) { return lua_setupvalue(L, funcindex, n); }

		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_upvalueid">lua_upvalueid</a>
		 * Returns a unique identifier for the upvalue numbered n from the closure at
		 * index funcindex.
		 * These unique identifiers allow a program to check whether different closures
		 * share upvalues. Lua closures that share an upvalue (that is, that access a same
		 * external local variable) will return identical ids for those upvalue indices.
		 * Parameters funcindex and n are as in function lua_getupvalue, but n cannot be
		 * greater than the number of upvalues.
		 */
		void *      upvalueid(int fidx, int n) { return lua_upvalueid(L, fidx, n); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_upvaluejoin">lua_upvaluejoin</a>
		 *                                     int funcindex2, int n2);
		 * Make the n1-th upvalue of the Lua closure at index funcindex1 refer to the n2-
		 * th upvalue of the Lua closure at index funcindex2.
		 */
		void        upvaluejoin(int fidx1, int n1, int fidx2, int n2) { lua_upvaluejoin(L, fidx1, n1, fidx2, n2); }

		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_sethook">lua_sethook</a>
		 * Sets the debugging hook function.
		 * Argument f is the hook function. mask specifies on which events the hook will
		 * be called: it is formed by a bitwise OR of the constants LUA_MASKCALL,
		 * LUA_MASKRET, LUA_MASKLINE, and LUA_MASKCOUNT. The count argument is only
		 * meaningful when the mask includes LUA_MASKCOUNT. For each event, the hook is
		 * called as explained below:
		 *     * The call hook: is called when the interpreter calls a function. The hook
		 *       is called just after Lua enters the new function, before the function
		 *       gets its arguments.
		 *     * The return hook: is called when the interpreter returns from a function.
		 *       The hook is called just before Lua leaves the function. There is no
		 *       standard way to access the values to be returned by the function.
		 *     * The line hook: is called when the interpreter is about to start the
		 *       execution of a new line of code, or when it jumps back in the code (even
		 *       to the same line). (This event only happens while Lua is executing a Lua
		 *       function.)
		 *     * The count hook: is called after the interpreter executes every count
		 *       instructions. (This event only happens while Lua is executing a Lua
		 *       function.)
		 * A hook is disabled by setting mask to zero.
		 */
		void        sethook(Hook func, int mask, int count) { lua_sethook(L, func, mask, count); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_gethook">lua_gethook</a>
		 * Returns the current hook function.
		 */
		Hook        gethook() { return lua_gethook(L); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_gethookmask">lua_gethookmask</a>
		 * Returns the current hook mask.
		 */
		int         gethookmask() { return lua_gethookmask(L); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#lua_gethookcount">lua_gethookcount</a>
		 * Returns the current hook count.
		 */
		int         gethookcount() { return lua_gethookcount(L); }

		/* auxiliary =================================================== */

		/** luaL_Buffer */
		typedef luaL_Buffer Buffer;

		/** FIXME */
		enum {
			NoRef = LUA_NOREF,
			RefNil = LUA_REFNIL
		};

		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_buffinit>luaL_buffinit</a>
		 * Initializes a buffer B. This function does not allocate any space; the buffer
		 * must be declared as a variable (see luaL_Buffer).
		 */
		void        buffinit(Buffer *B) { luaL_buffinit(L, B); }
		/** [-?, +?, m] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_buffinitsize>luaL_buffinitsize</a>
		 * Equivalent to the sequence luaL_buffinit, luaL_prepbuffsize.
		 */
		char *      buffinitsize(Buffer *B, size_t sz) { return luaL_buffinitsize(L, B, sz); }
		/** [-?, +?, m] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_addchar>luaL_addchar</a>
		 * Adds the byte c to the buffer B (see luaL_Buffer).
		 */
		void        addchar(Buffer *B, char c) { luaL_addchar(B, c); }
		/** [-?, +?, m] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_addlstring>luaL_addlstring</a>
		 * Adds the string pointed to by s with length l to the buffer B (see
		 * luaL_Buffer). The string can contain embedded zeros.
		 */
		void        addlstring(Buffer *B, String s, size_t l) { luaL_addlstring(B, s, l); }
		/** [-?, +?, –] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_addsize>luaL_addsize</a>
		 * Adds to the buffer B (see luaL_Buffer) a string of length n previously copied
		 * to the buffer area (see luaL_prepbuffer).
		 */
		void        addsize(Buffer *B, size_t n) { luaL_addsize(B, n); }
		/** [-?, +?, m] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_addstring>luaL_addstring</a>
		 * Adds the zero-terminated string pointed to by s to the buffer B (see
		 * luaL_Buffer).
		 */
		void        addstring(Buffer *B, String s) { luaL_addstring(B, s); }
		/** [-1, +?, m] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_addvalue>luaL_addvalue</a>
		 * Adds the value at the top of the stack to the buffer B (see luaL_Buffer). Pops
		 * the value.
		 * This is the only function on string buffers that can (and must) be called with
		 * an extra element on the stack, which is the value to be added to the buffer.
		 */
		void        addvalue(Buffer *B) { luaL_addvalue(B); }
		/** [-?, +?, m] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_prepbuffer>luaL_prepbuffer</a>
		 * Equivalent to luaL_prepbuffsize with the predefined size LUAL_BUFFERSIZE.
		 */
		char *      prepbuf(Buffer *B) { return luaL_prepbuffer(B); }
		/** [-?, +?, m] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_prepbuffsize>luaL_prepbuffsize</a>
		 * Returns an address to a space of size sz where you can copy a string to be
		 * added to buffer B (see luaL_Buffer). After copying the string into this space
		 * you must call luaL_addsize with the size of the string to actually add it to
		 * the buffer.
		 */
		char *      prepbufsize(Buffer *B, size_t sz) { return luaL_prepbuffsize(B, sz); }
		/** [-?, +1, m] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_pushresult>luaL_pushresult</a>
		 * Finishes the use of buffer B leaving the final string on the top of the stack.
		 */
		void        pushresult(Buffer *B) { luaL_pushresult(B); }
		/** [-?, +1, m] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_pushresultsize>luaL_pushresultsize</a>
		 * Equivalent to the sequence luaL_addsize, luaL_pushresult.
		 */
		void        pushresultsize(Buffer *B, size_t sz) { luaL_pushresultsize(B, sz); }

		/** [-0, +0, v] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_argcheck>luaL_argcheck</a>
		 *                     int cond,
		 *                     int arg,
		 *                     String extramsg);
		 * Checks whether cond is true. If it is not, raises an error with a standard
		 * message (see luaL_argerror).
		 */
		void        argcheck(int cond, int arg, String extramsg) { luaL_argcheck(L, cond, arg, extramsg); }
		/** [-0, +0, v] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_argerror>luaL_argerror</a>
		 * Raises an error reporting a problem with argument arg of the C function that
		 * called it, using a standard message that includes extramsg as a comment:
		 *      bad argument @a arg to 'funcname' (extramsg)
		 * This function never returns.
		 */
		void        argerror(int arg, String extramsg) __attribute__((noreturn)) { luaL_argerror(L, arg, extramsg); }

		/** [-0, +(0|1), e] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_callmeta>luaL_callmeta</a>
		 * Calls a metamethod.
		 * If the object at index obj has a metatable and this metatable has a field e,
		 * this function calls this field passing the object as its only argument. In this
		 * case this function returns true and pushes onto the stack the value returned by
		 * the call. If there is no metatable or no metamethod, this function returns
		 * false (without pushing any value on the stack).
		 */
		int         callmeta(int obj, String e) { return luaL_callmeta(L, obj, e); }
		/** [-0, +0, v] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_checkany>luaL_checkany</a>
		 * Checks whether the function has an argument of any type (including nil) at
		 * position arg.
		 */
		void        checkany(int arg) { luaL_checkany(L, arg); }
		/** [-0, +0, v] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_checkinteger>luaL_checkinteger</a>
		 * Checks whether the function argument arg is an integer (or can be converted to
		 * an integer) and returns this integer cast to a lua_Integer.
		 */
		Integer     checkinteger(int arg) { return luaL_checkinteger(L, arg); }
		/** [-0, +0, v] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_checklstring>luaL_checklstring</a>
		 * Checks whether the function argument arg is a string and returns this string;
		 * if l is not NULL fills *l with the string's length.
		 * This function uses lua_tolstring to get its result, so all conversions and
		 * caveats of that function apply here.
		 */
		String      checklstring(int arg, size_t *l) { return luaL_checklstring(L, arg, l); }
		/** [-0, +0, v] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_checknumber>luaL_checknumber</a>
		 * Checks whether the function argument arg is a number and returns this number.
		 */
		Number      checknumber(int arg) { return luaL_checknumber(L, arg); }
		/** [-0, +0, v] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_checkoption>luaL_checkoption</a>
		 *                       int arg,
		 *                       String def,
		 *                       String const lst[]);
		 * Checks whether the function argument arg is a string and searches for this
		 * string in the array lst (which must be NULL-terminated). Returns the index in
		 * the array where the string was found. Raises an error if the argument is not a
		 * string or if the string cannot be found.
		 * If def is not NULL, the function uses def as a default value when there is no
		 * argument arg or when this argument is nil.
		 * This is a useful function for mapping strings to C enums. (The usual convention
		 * in Lua libraries is to use strings instead of numbers to select options.)
		 */
		int         checkoption(int arg, String def, String  const lst[]) { return luaL_checkoption(L, arg, def, lst); }
		/** [-0, +0, v] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_checkstack>luaL_checkstack</a>
		 * Grows the stack size to top + sz elements, raising an error if the stack cannot
		 * grow to that size. msg is an additional text to go into the error message (or
		 * NULL for no additional text).
		 */
		void        checkstack(int sz, String msg) { luaL_checkstack(L, sz, msg); }
		/** [-0, +0, v] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_checkstring>luaL_checkstring</a>
		 * Checks whether the function argument arg is a string and returns this string.
		 * This function uses lua_tolstring to get its result, so all conversions and
		 * caveats of that function apply here.
		 */
		String      checkstring(int arg) { return luaL_checkstring(L, arg); }
		/** [-0, +0, v] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_checktype>luaL_checktype</a>
		 * Checks whether the function argument arg has type t. See lua_type for the
		 * encoding of types for t.
		 */
		void        checktype(int arg, int t) { luaL_checktype(L, arg, t); }
		/** [-0, +0, v] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_checkudata>luaL_checkudata</a>
		 * Checks whether the function argument arg is a userdata of the type tname (see
		 * luaL_newmetatable) and returns the userdata address (see lua_touserdata).
		 */
		Userdata    checkudata(int arg, String tname) { return luaL_checkudata(L, arg, tname); }
		/** [-0, +0, v] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_checkversion>luaL_checkversion</a>
		 * Checks whether the core running the call, the core that created the Lua state,
		 * and the code making the call are all using the same version of Lua. Also checks
		 * whether the core running the call and the core that created the Lua state are
		 * using the same address space.
		 */
		void        checkversion() { luaL_checkversion(L); }
		/** [-0, +?, e] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_dofile>luaL_dofile</a>
		 * Loads and runs the given file. It is defined as the following macro:
		 *      (luaL_loadfile(L, filename) || lua_pcall(L, 0, LUA_MULTRET, 0))
		 * It returns false if there are no errors or true in case of errors.
		 */
		int         dofile(String filename) { return luaL_dofile(L, filename); }
		/** [-0, +?, –] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_dostring>luaL_dostring</a>
		 * Loads and runs the given string. It is defined as the following macro:
		 *      (luaL_loadstring(L, str) || lua_pcall(L, 0, LUA_MULTRET, 0))
		 * It returns false if there are no errors or true in case of errors.
		 */
		int         dostring(String str) { return luaL_dostring(L, str); }
		/** FIXME */
		void        verror(String fmt, va_list argp) __attribute__((noreturn)) {
			pushvfstring(fmt, argp);
			error();
		}
		/** FIXME */
		void        error(String fmt, ...)  __attribute__((noreturn)) {
			va_list ap;

			va_start(ap, fmt);
			verror(fmt, ap);
		}
		/** [-0, +3, m] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_execresult>luaL_execresult</a>
		 * This function produces the return values for process-related functions in the
		 * standard library (os.execute and io.close).
		 */
		int         execresult(int stat) { return luaL_execresult(L, stat); }
		/** [-0, +(1|3), m] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_fileresult>luaL_fileresult</a>
		 * This function produces the return values for file-related functions in the
		 * standard library (io.open, os.rename, file:seek, etc.).
		 */
		int         fileresult(int stat, String fname) { return luaL_fileresult(L, stat, fname); }
		/** [-0, +(0|1), m] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_getmetafield>luaL_getmetafield</a>
		 * Pushes onto the stack the field e from the metatable of the object at index obj
		 * and returns the type of pushed value. If the object does not have a metatable,
		 * or if the metatable does not have this field, pushes nothing and returns
		 * LUA_TNIL.
		 */
		int         getmetafield(int obj, String e) { return luaL_getmetafield(L, obj, e); }
		/** [-0, +1, m] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_getmetatable>luaL_getmetatable</a>
		 * Pushes onto the stack the metatable associated with name tname in the registry
		 * (see luaL_newmetatable) (nil if there is no metatable associated with that
		 * name). Returns the type of the pushed value.
		 */
		int         getmetatable(String tname) { return luaL_getmetatable(L, tname); }
		/** [-0, +1, e] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_getsubtable>luaL_getsubtable</a>
		 * Ensures that the value t[fname], where t is the value at index idx, is a table,
		 * and pushes that table onto the stack. Returns true if it finds a previous table
		 * there and false if it creates a new table.
		 */
		int         getsubtable(int idx, String fname) { return luaL_getsubtable(L, idx, fname); }
		/** [-0, +1, m] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_gsub>luaL_gsub</a>
		 *                        String s,
		 *                        String p,
		 *                        String r);
		 * Creates a copy of string s by replacing any occurrence of the string p with the
		 * string r. Pushes the resulting string on the stack and returns it.
		 */
		String gsub(String s, String p, String r) { return luaL_gsub(L, s, p, r); }
		/** [-0, +0, e] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_len>luaL_len</a>
		 * Returns the "length" of the value at the given index as a number; it is
		 * equivalent to the '#' operator in Lua (see §3.4.7). Raises an error if the
		 * result of the operation is not an integer. (This case only can happen through
		 * metamethods.)
		 */
		Integer     len(int index) { return luaL_len(L, index); }
		/** [-0, +1, –] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_loadbufferx>luaL_loadbufferx</a>
		 *                       String buff,
		 *                       size_t sz,
		 *                       String name,
		 *                       String mode);
		 * Loads a buffer as a Lua chunk. This function uses lua_load to load the chunk in
		 * the buffer pointed to by buff with size sz.
		 * This function returns the same results as lua_load. name is the chunk name,
		 * used for debug information and error messages. The string mode works as in
		 * function lua_load.
		 */
		int         loadbuffer(String buff, size_t sz, String name, String mode = 0) { return luaL_loadbufferx(L, buff, sz, name, mode); }
		/** [-0, +1, m] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_loadfilex>luaL_loadfilex</a>
		 *                                             String mode);
		 * Loads a file as a Lua chunk. This function uses lua_load to load the chunk in
		 * the file named filename. If filename is NULL, then it loads from the standard
		 * input. The first line in the file is ignored if it starts with a #.
		 * The string mode works as in function lua_load.
		 * This function returns the same results as lua_load, but it has an extra error
		 * code LUA_ERRFILE for file-related errors (e.g., it cannot open or read the
		 * file).
		 * As lua_load, this function only loads the chunk; it does not run it.
		 */
		int         loadfile(String filename, String mode = 0) { return luaL_loadfilex(L, filename, mode); }
		/** [-0, +1, –] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_loadstring>luaL_loadstring</a>
		 * Loads a string as a Lua chunk. This function uses lua_load to load the chunk in
		 * the zero-terminated string s.
		 * This function returns the same results as lua_load.
		 * Also as lua_load, this function only loads the chunk; it does not run it.
		 */
		int         loadstring(String s) { return luaL_loadstring(L, s); }

		/** luaL_Reg */
		typedef luaL_Reg Reg;
	#if 0
		// FIXME those are implemented as macros and will not get the size of l[] right
		void        Lnewlib(const Reg l[]) {
			Lcheckversion();
			Lnewlibtable(l);
			Lsetfuncs(l,0); }
		void        Lnewlibtable(const Reg l[]) { luaL_newlibtable(L, l); }
	#endif
		/** [-0, +1, m] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_newmetatable>luaL_newmetatable</a>
		 * If the registry already has the key tname, returns 0. Otherwise, creates a new
		 * table to be used as a metatable for userdata, adds to this new table the pair
		 * __name = tname, adds to the registry the pair [tname] = new table, and returns
		 * 1. (The entry __name is used by some error-reporting functions.)
		 * In both cases pushes onto the stack the final value associated with tname in
		 * the registry.
		 */
		void        newmetatable(String tname) { luaL_newmetatable(L, tname); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_newstate>luaL_newstate</a>
		 * Creates a new Lua state. It calls lua_newstate with an allocator based on the
		 * standard C realloc function and then sets a panic function (see §4.6) that
		 * prints an error message to the standard error output in case of fatal errors.
		 * Returns the new state, or NULL if there is a memory allocation error.
		 */
		static State newstate() { return luaL_newstate(); }
		/** [-0, +0, e] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_openlibs>luaL_openlibs</a>
		 * Opens all standard Lua libraries into the given state.
		 */
		void        openlibs() { luaL_openlibs(L); }

		/** [-0, +0, v] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_optinteger>luaL_optinteger</a>
		 *                              int arg,
		 *                              lua_Integer d);
		 * If the function argument arg is an integer (or convertible to an integer),
		 * returns this integer. If this argument is absent or is nil, returns d.
		 * Otherwise, raises an error.
		 */
		Integer     optinteger(int arg, Integer d) { return luaL_optinteger(L, arg, d); }
		/** [-0, +0, v] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_optlstring>luaL_optlstring</a>
		 *                              int arg,
		 *                              String d,
		 *                              size_t *l);
		 * If the function argument arg is a string, returns this string. If this argument
		 * is absent or is nil, returns d. Otherwise, raises an error.
		 * If l is not NULL, fills the position *l with the result's length. If the result
		 * is NULL (only possible when returning d and d == NULL), its length is
		 * considered zero.
		 * This function uses lua_tolstring to get its result, so all conversions and
		 * caveats of that function apply here.
		 */
		String      optlstring(int arg, String d, size_t *l) { return luaL_optlstring(L, arg, d, l); }
		/** [-0, +0, v] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_optnumber>luaL_optnumber</a>
		 * If the function argument arg is a number, returns this number. If this argument
		 * is absent or is nil, returns d. Otherwise, raises an error.
		 */
		Number      optnumber(int arg, Number d) { return luaL_optnumber(L, arg, d); }
		/** [-0, +0, v] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_optstring>luaL_optstring</a>
		 *                             int arg,
		 *                             String d);
		 * If the function argument arg is a string, returns this string. If this argument
		 * is absent or is nil, returns d. Otherwise, raises an error.
		 */
		String      optstring(int arg, String d) { return luaL_optstring(L, arg, d); }
		/** [-0, +1, e] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_requiref>luaL_requiref</a>
		 *                     lua_CFunction openf, int glb);
		 * If modname is not already present in package.loaded, calls function openf with
		 * string modname as an argument and sets the call result in package.loaded
		 * [modname], as if that function has been called through require.
		 * If glb is true, also stores the module into global modname.
		 * Leaves a copy of the module on the stack.
		 */
		void        requiref(String modname, CFunction openf, int glb) { luaL_requiref(L, modname, openf, glb); }
		/** [-nup, +0, m] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_setfuncs>luaL_setfuncs</a>
		 * Registers all functions in the array l (see luaL_Reg) into the table on the top
		 * of the stack (below optional upvalues, see next).
		 * When nup is not zero, all functions are created sharing nup upvalues, which
		 * must be previously pushed on the stack on top of the library table. These
		 * values are popped from the stack after the registration.
		 */
		void        setfuncs(const Reg *l, int nup) { luaL_setfuncs(L, l, nup); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_setmetatable>luaL_setmetatable</a>
		 * Sets the metatable of the object at the top of the stack as the metatable
		 * associated with name tname in the registry (see luaL_newmetatable).
		 */
		void        setmetatable(String tname) { luaL_setmetatable(L, tname); }

		/** luaL_Stream */
		typedef luaL_Stream Stream;

		/** [-0, +0, m] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_testudata>luaL_testudata</a>
		 * This function works like luaL_checkudata, except that, when the test fails, it
		 * returns NULL instead of raising an error.
		 */
		Userdata    testudata(int arg, String tname) { return luaL_testudata(L, arg, tname); }
		/** [-0, +1, e] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_tolstring>luaL_tolstring</a>
		 * Converts any Lua value at the given index to a C string in a reasonable format.
		 * The resulting string is pushed onto the stack and also returned by the
		 * function. If len is not NULL, the function also sets *len with the string
		 * length.
		 * If the value has a metatable with a __tostring field, then luaL_tolstring calls
		 * the corresponding metamethod with the value as argument, and uses the result of
		 * the call as its result.
		 */
		String      tolstring(int idx, size_t *len) { return luaL_tolstring(L, idx, len); }
		/** [-0, +1, m] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_traceback>luaL_traceback</a>
		 *                      int level);
		 * Creates and pushes a traceback of the stack L1. If msg is not NULL it is
		 * appended at the beginning of the traceback. The level parameter tells at which
		 * level to start the traceback.
		 */
		void        traceback(State L1, String msg, int level) { luaL_traceback(L, L1, msg, level); }
	#if 0
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_typename>luaL_typename</a>
		 * Returns the name of the type of the value at the given index.
		 */
		String typeName(int index) { return luaL_typename(L, index); }
	#endif

		/** [-1, +0, m] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_ref>luaL_ref</a>
		 * Creates and returns a reference, in the table at index t, for the object at the
		 * top of the stack (and pops the object).
		 * A reference is a unique integer key. As long as you do not manually add integer
		 * keys into table t, luaL_ref ensures the uniqueness of the key it returns. You
		 * can retrieve an object referred by reference r by calling lua_rawgeti(L, t, r).
		 * Function luaL_unref frees a reference and its associated object.
		 * If the object at the top of the stack is nil, luaL_ref returns the constant
		 * LUA_REFNIL. The constant LUA_NOREF is guaranteed to be different from any
		 * reference returned by luaL_ref.
		 */
		int         ref(int t) { return luaL_ref(L, t); }
		/** [-0, +0, –] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_unref>luaL_unref</a>
		 * Releases reference ref from the table at index t (see luaL_ref). The entry is
		 * removed from the table, so that the referred object can be collected. The
		 * reference ref is also freed to be used again.
		 * If ref is LUA_NOREF or LUA_REFNIL, luaL_unref does nothing.
		 */
		void        unref(int t, int ref) { luaL_unref(L, t, ref); }
		/** [-0, +1, m] <a href="https://www.lua.org/manual/5.1/manual.html#luaL_where>luaL_where</a>
		 * Pushes onto the stack a string identifying the current position of the control
		 * at level lvl in the call stack. Typically this string has the following format:
		 *      chunkname:currentline:
		 * Level 0 is the running function, level 1 is the function that called the
		 * running function, etc.
		 * This function is used to build a prefix for error messages.
		 */
		void        where(int lvl) { luaL_where(L, lvl); }
	};

#endif
}

#endif
