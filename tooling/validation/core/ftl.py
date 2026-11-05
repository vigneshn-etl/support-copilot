"""
A FreeMarker subset interpreter — enough to render S5 pivotdefns the way darwin does
(FreeMarkerConfigurationFactory: number format 0.######, auto-import ch_sql_tools.ftl as
`ch`, includes from <config>/pivot/include then darwin's /com/darwin/mason).

Supported: ${expr}, <#if>/<#elseif>/<#else>, <#list … as x>[<#sep>] / <#list x><#items as k, v>,
<#assign>/<#global>/<#local> (inline and block), <#macro>/<@call/>, <#include>, <#--comments-->,
<#compress>, <#ftl>/<#setting> (ignored).
Expressions: literals, a.b / a[b], ?builtins, ??, x!default, ! && || == = != < > <= >= gt lt gte
lte, + - * / %, (…), [list], lambdas (x -> …).
Unsupported constructs raise FtlError naming the construct, never render silently wrong.
"""
import re
from pathlib import Path


class FtlError(Exception):
    pass


class _Missing:
    def __repr__(self):
        return "<missing>"


MISSING = _Missing()


# ---------------------------------------------------------------- template lexer
def _scan_tag_end(s, i):
    """index of the '>' closing a tag opened before i (depth 0, outside strings)."""
    depth, q = 0, None
    while i < len(s):
        c = s[i]
        if q:
            if c == "\\":
                i += 2
                continue
            if c == q:
                q = None
        elif c in "\"'":
            q = c
        elif c in "([{":
            depth += 1
        elif c in ")]}":
            depth -= 1
        elif c == ">" and depth <= 0:
            return i
        i += 1
    raise FtlError("unterminated tag")


def _scan_interp_end(s, i):
    depth, q = 1, None
    while i < len(s):
        c = s[i]
        if q:
            if c == "\\":
                i += 2
                continue
            if c == q:
                q = None
        elif c in "\"'":
            q = c
        elif c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    raise FtlError("unterminated ${")


_OPEN = re.compile(r"\$\{|<#--|</?#[A-Za-z]|</?@[A-Za-z]")


def lex(s):
    toks, i = [], 0
    while i < len(s):
        m = _OPEN.search(s, i)
        if not m:
            toks.append(("text", s[i:]))
            break
        if m.start() > i:
            toks.append(("text", s[i:m.start()]))
        t = m.group(0)
        if t == "${":
            e = _scan_interp_end(s, m.end())
            toks.append(("interp", s[m.end():e].strip()))
            i = e + 1
        elif t == "<#--":
            e = s.find("-->", m.end())
            i = len(s) if e < 0 else e + 3
        else:
            e = _scan_tag_end(s, m.end())
            body = s[m.start() + 1:e]
            selfclose = body.endswith("/")
            if selfclose:
                body = body[:-1]
            closing = body.startswith("/")
            body = body[1:] if closing else body
            kind = "macro" if body.startswith("@") else "dir"
            body = body[1:]
            name = re.match(r"[\w.]+", body).group(0)
            args = body[len(name):].strip()
            toks.append(("close" if closing else kind, name, args, selfclose))
            i = e + 1
    return toks


# ---------------------------------------------------------------- template parser
_BLOCK = {"if", "list", "items", "sep", "macro", "compress", "assign", "global", "local", "attempt",
          "recover", "noparse", "function", "switch"}


def parse(toks):
    pos = [0]

    def parse_body(stops, dstops=()):
        """stops: closing tags ending this body; dstops: directives (else/elseif) that do."""
        out = []
        while pos[0] < len(toks):
            t = toks[pos[0]]
            if t[0] == "close" and t[1] in stops:
                return out, t
            if t[0] == "dir" and t[1] in dstops:
                return out, t
            pos[0] += 1
            if t[0] == "text":
                out.append(("text", t[1]))
            elif t[0] == "interp":
                out.append(("interp", t[1]))
            elif t[0] == "macro":
                node = ("call", t[1], t[2])
                if not t[3]:                            # <@x>…</@x> with nested content
                    body, _ = parse_body({t[1]})
                    pos[0] += 1
                    node = ("call", t[1], t[2], body)
                out.append(node)
            elif t[0] == "close":
                raise FtlError(f"unexpected </#{t[1]}>")
            else:
                out.append(parse_dir(t))
        if stops:
            raise FtlError(f"missing close for {sorted(stops)}")
        return out, None

    def parse_dir(t):
        _, name, args, selfclose = t
        if name == "if":
            branches, else_body = [], []
            cond = args
            while True:
                body, stop = parse_body({"if"}, {"elseif", "else"})
                pos[0] += 1
                branches.append((cond, body))
                if stop[0] == "close":
                    break
                if stop[1] == "elseif":
                    cond = stop[2]
                    continue
                else_body, stop = parse_body({"if"})
                pos[0] += 1
                break
            return ("if", branches, else_body)
        if name == "list":
            m = re.match(r"(.*)\s+as\s+([\w\s,]+)$", args, re.S)
            expr, vars_ = (m.group(1), [v.strip() for v in m.group(2).split(",")]) if m else (args, None)
            body, stop = parse_body({"list"}, {"else"})
            pos[0] += 1
            else_body = []
            if stop[0] == "dir" and stop[1] == "else":
                else_body, _ = parse_body({"list"})
                pos[0] += 1
            return ("list", expr, vars_, body, else_body)
        if name == "items":
            vars_ = [v.strip() for v in re.match(r"as\s+(.*)$", args, re.S).group(1).split(",")]
            body, _ = parse_body({"items"})
            pos[0] += 1
            return ("items", vars_, body)
        if name == "sep":
            if selfclose:
                return ("sep", [])
            # <#sep> body runs to </#sep> or the end of the enclosing items/list body
            body, stop = parse_body({"sep", "items", "list"})
            if stop and stop[0] == "close" and stop[1] == "sep":
                pos[0] += 1
            return ("sep", body)
        if name in ("assign", "global", "local"):
            if "=" in args or selfclose:
                return ("assign", name, args)
            body, _ = parse_body({name})
            pos[0] += 1
            return ("assign_block", name, args.strip(), body)
        if name == "macro":
            parts = args.split(None, 1)
            body, _ = parse_body({"macro"})
            pos[0] += 1
            return ("macro", parts[0], parts[1] if len(parts) > 1 else "", body)
        if name == "include":
            return ("include", args)
        if name in ("compress", "noparse"):
            body, _ = parse_body({name})
            pos[0] += 1
            return ("seq", body)
        if name in ("ftl", "setting", "flush", "t", "lt", "rt", "nt", "import"):
            return ("seq", [])
        if name == "return":
            return ("seq", [])
        raise FtlError(f"unsupported directive <#{name}>")

    body, _ = parse_body(set())
    return body


# ---------------------------------------------------------------- expressions
_TOK = re.compile(r"""\s*(?:
   (?P<str>r?"(?:\\.|[^"\\])*"|r?'(?:\\.|[^'\\])*')
 | (?P<num>\d+(?:\.\d+)?)
 | (?P<op>\?\?|->|&&|\|\||==|!=|<=|>=|\.\.|[?!=<>+\-*/%().,\[\]{}:])
 | (?P<id>[A-Za-z_$][\w$]*)
)""", re.X)


def tokenize(s):
    out, i = [], 0
    while i < len(s):
        if s[i].isspace():
            i += 1
            continue
        m = _TOK.match(s, i)
        if not m or m.end() == i:
            raise FtlError(f"bad expression near: {s[i:i + 30]!r}")
        for k in ("str", "num", "op", "id"):
            if m.group(k) is not None:
                v = m.group(k)
                if k == "id" and v in ("gt", "lt", "gte", "lte"):
                    k = "op"
                out.append((k, v))
                break
        i = m.end()
    out.append(("end", None))
    return out


def _unq(s):
    raw = s.startswith("r")
    s = s[1:] if raw else s
    body = s[1:-1]
    if raw:
        return body
    return re.sub(r"\\(.)", lambda m: {"n": "\n", "t": "\t"}.get(m.group(1), m.group(1)), body)


class Expr:
    """Pratt parser producing closures over an env."""
    BIN = {"||": 1, "&&": 2, "==": 3, "=": 3, "!=": 3, "<": 4, ">": 4, "<=": 4, ">=": 4,
           "gt": 4, "lt": 4, "gte": 4, "lte": 4, "+": 5, "-": 5, "*": 6, "/": 6, "%": 6}

    def __init__(self, src):
        self.t, self.i, self.src = tokenize(src), 0, src

    def peek(self, k=0):
        return self.t[self.i + k]

    def take(self, v=None):
        tok = self.t[self.i]
        if v is not None and tok[1] != v:
            raise FtlError(f"expected {v!r} in {self.src!r}, got {tok[1]!r}")
        self.i += 1
        return tok

    def parse(self):
        e = self.expr(0)
        if self.peek()[0] != "end":
            raise FtlError(f"trailing tokens in {self.src!r}: {self.peek()}")
        return e

    def expr(self, minp):
        # lambda: id -> expr
        if self.peek()[0] == "id" and self.peek(1)[1] == "->":
            name = self.take()[1]
            self.take("->")
            body = self.expr(0)
            return lambda env: ("lambda", name, body, env)
        left = self.unary()
        while True:
            tok = self.peek()
            op = tok[1] if tok[0] == "op" else None
            if op not in self.BIN or self.BIN[op] < minp:
                return left
            self.take()
            right = self.expr(self.BIN[op] + 1)
            left = self._bin(op, left, right)

    def _bin(self, op, l, r):
        def f(env):
            if op == "&&":
                return truthy(l(env)) and truthy(r(env))
            if op == "||":
                return truthy(l(env)) or truthy(r(env))
            a, b = val(l(env)), val(r(env))
            if op in ("==", "="):
                return a == b
            if op == "!=":
                return a != b
            if op in ("<", "lt"):
                return a < b
            if op in (">", "gt"):
                return a > b
            if op in ("<=", "lte"):
                return a <= b
            if op in (">=", "gte"):
                return a >= b
            if op == "+":
                if isinstance(a, str) or isinstance(b, str):
                    return fmt(a) + fmt(b)
                if isinstance(a, list):
                    return a + b
                if isinstance(a, dict):
                    return {**a, **b}
                return a + b
            if op == "-":
                return a - b
            if op == "*":
                return a * b
            if op == "/":
                return a / b
            if op == "%":
                return a % b
        return f

    def unary(self):
        tok = self.peek()
        if tok[1] == "!" and tok[0] == "op":
            self.take()
            e = self.unary()
            return lambda env: not truthy(e(env))
        if tok[1] == "-" and tok[0] == "op":
            self.take()
            e = self.unary()
            return lambda env: -val(e(env))
        return self.postfix(self.primary())

    def primary(self):
        k, v = self.take()
        if k == "str":
            s = _unq(v)
            return lambda env: s
        if k == "num":
            n = float(v) if "." in v else int(v)
            return lambda env: n
        if k == "id":
            if v in ("true", "false"):
                b = v == "true"
                return lambda env: b
            return lambda env: env.get(v)
        if v == "(":
            e = self.expr(0)
            self.take(")")
            return e
        if v == "[":
            items = []
            while self.peek()[1] != "]":
                items.append(self.expr(0))
                if self.peek()[1] == ",":
                    self.take()
            self.take("]")
            return lambda env: [val(x(env)) for x in items]
        if v == "{":
            pairs = []
            while self.peek()[1] != "}":
                kk = self.expr(0)
                self.take(":")
                pairs.append((kk, self.expr(0)))
                if self.peek()[1] == ",":
                    self.take()
            self.take("}")
            return lambda env: {val(a(env)): val(b(env)) for a, b in pairs}
        raise FtlError(f"unexpected {v!r} in {self.src!r}")

    def postfix(self, e):
        while True:
            tok = self.peek()
            if tok[1] == "." and tok[0] == "op":
                self.take()
                name = self.take()[1]
                e = (lambda b, n: lambda env: getattr_(b(env), n))(e, name)
            elif tok[1] == "[" and tok[0] == "op":
                self.take()
                idx = self.expr(0)
                self.take("]")
                e = (lambda b, x: lambda env: getitem_(b(env), val(x(env))))(e, idx)
            elif tok[1] == "??":
                self.take()
                e = (lambda b: lambda env: b(env) is not MISSING and b(env) is not None)(e)
            elif tok[1] == "?" and tok[0] == "op":
                self.take()
                name = self.take()[1]
                args = []
                if self.peek()[1] == "(":
                    self.take()
                    while self.peek()[1] != ")":
                        args.append(self.expr(0))
                        if self.peek()[1] == ",":
                            self.take()
                    self.take(")")
                e = (lambda b, n, a: lambda env: builtin(n, b(env), [x(env) for x in a]))(e, name, args)
            elif tok[1] == "!" and tok[0] == "op":
                # default operator: x!  or  x!default   (not '!=')
                self.take()
                nxt = self.peek()
                if nxt[0] in ("str", "num", "id") or nxt[1] in ("(", "["):
                    d = self.primary()
                    d = self.postfix(d)
                else:
                    d = lambda env: ""
                e = (lambda b, dd: lambda env: (lambda v: dd(env) if v is MISSING or v is None else v)(b(env)))(e, d)
            else:
                return e


def getattr_(o, n):
    if o is MISSING or o is None:
        return MISSING
    if isinstance(o, dict):
        return o.get(n, MISSING)
    if isinstance(o, Namespace):
        return o.get(n)
    return MISSING


def getitem_(o, k):
    if o is MISSING or o is None:
        return MISSING
    if isinstance(o, dict):
        return o.get(k, MISSING)
    if isinstance(o, (list, str)):
        try:
            return o[int(k)]
        except (IndexError, ValueError):
            return MISSING
    return MISSING


def val(v):
    if v is MISSING:
        raise FtlError("reference to a missing value")
    return v


def truthy(v):
    if v is MISSING:
        raise FtlError("missing value used as a condition")
    return bool(v)


def fmt(v):
    v = val(v)
    if isinstance(v, bool):
        raise FtlError("boolean interpolated without ?c")
    if isinstance(v, float):
        s = f"{v:.6f}".rstrip("0").rstrip(".")
        return s if s not in ("-0", "") else "0"
    if isinstance(v, (list, dict)):
        raise FtlError("sequence/hash interpolated")
    return str(v)


def _java_regex(p):
    return p.replace("\\\\", "\\") if "\\\\" in p else p


def builtin(name, v, args):
    a = [val(x) if not (isinstance(x, tuple) and x and x[0] == "lambda") else x for x in args]
    if name == "has_content":
        return v is not MISSING and v is not None and v != "" and v != [] and v != {}
    if name in ("exists", "is_null"):
        return (v is not MISSING and v is not None) if name == "exists" else (v is MISSING or v is None)
    v = val(v)
    if name == "contains":
        return a[0] in v
    if name == "matches":
        return re.fullmatch(_java_regex(a[0]), v, re.S) is not None
    if name == "split":
        return v.split(a[0])
    if name in ("size", "length"):
        return len(v)
    if name == "keys":
        return list(v.keys())
    if name == "values":
        return list(v.values())
    if name in ("filter", "map"):
        lam = a[0]
        _, var, body, env = lam
        out = []
        for x in v:
            r = body(env.child({var: x}))
            if name == "filter":
                if truthy(r):
                    out.append(x)
            else:
                out.append(val(r))
        return out
    if name == "replace":
        return v.replace(a[0], a[1])
    if name == "trim":
        return v.strip()
    if name == "upper_case":
        return v.upper()
    if name == "lower_case":
        return v.lower()
    if name == "cap_first":
        return v[:1].upper() + v[1:]
    if name == "first":
        return v[0]
    if name == "last":
        return v[-1]
    if name == "join":
        return a[0].join(fmt(x) for x in v)
    if name in ("seq_contains", "seqContains"):
        return a[0] in v
    if name == "starts_with":
        return v.startswith(a[0])
    if name == "ends_with":
        return v.endswith(a[0])
    if name == "index_of":
        return v.find(a[0])
    if name in ("c", "string"):
        if isinstance(v, bool):
            return "true" if v else "false"
        return fmt(v)
    if name == "number":
        return float(v) if "." in str(v) else int(v)
    if name == "then":
        return a[0] if v else a[1]
    if name == "sequence":
        return list(v)
    if name == "is_string":
        return isinstance(v, str)
    if name in ("is_sequence", "is_enumerable"):
        return isinstance(v, list)
    if name == "is_hash":
        return isinstance(v, dict)
    raise FtlError(f"unsupported builtin ?{name}")


# ---------------------------------------------------------------- render
class Namespace:
    def __init__(self, macros):
        self.macros = macros

    def get(self, n):
        return self.macros.get(n, MISSING)


class Env:
    def __init__(self, data, globals_, parent=None, locals_=None):
        self.data, self.globals, self.parent, self.locals = data, globals_, parent, locals_ or {}

    def child(self, locals_):
        return Env(self.data, self.globals, self, dict(locals_))

    def get(self, n):
        e = self
        while e is not None:
            if n in e.locals:
                return e.locals[n]
            e = e.parent
        if n in self.globals:
            return self.globals[n]
        return self.data.get(n, MISSING)

    def set_local(self, n, v):
        e = self
        while e.parent is not None and n not in e.locals:
            e = e.parent
        e.locals[n] = v


_ECACHE = {}


def ev(src, env):
    f = _ECACHE.get(src)
    if f is None:
        f = Expr(src).parse()
        _ECACHE[src] = f
    try:
        return f(env)
    except FtlError as e:
        if "[in " in str(e):
            raise
        raise FtlError(f"{e} [in {src!r}]") from None


class Renderer:
    def __init__(self, loaders, data, preserved=None):
        """loaders: dirs searched for includes; data: the data model; preserved: shared
        globals across parts (darwin's preservedContext)."""
        self.loaders = [Path(p) for p in loaders]
        self.data = data
        self.globals = preserved if preserved is not None else {}
        self.macros = {}
        self._parsed = {}
        ch = self.load("ch_sql_tools.ftl")
        if ch is not None:
            ns = {}
            self._collect_macros(ch, ns)
            self.globals.setdefault("ch", Namespace(ns))

    def load(self, name):
        if name in self._parsed:
            return self._parsed[name]
        for d in self.loaders:
            f = d / name
            if f.exists():
                self._parsed[name] = parse(lex(f.read_text(errors="replace")))
                return self._parsed[name]
        self._parsed[name] = None
        return None

    def _collect_macros(self, body, into):
        for n in body:
            if n[0] == "macro":
                into[n[1]] = n

    def render(self, text):
        out = []
        self.run(parse(lex(text)), Env(self.data, self.globals), out)
        return "".join(out)

    def run(self, body, env, out, sep_state=None):
        for n in body:
            k = n[0]
            if k == "text":
                out.append(n[1])
            elif k == "interp":
                try:
                    out.append(fmt(ev(n[1], env)))
                except FtlError as e:
                    if "[in " in str(e):
                        raise
                    raise FtlError(f"{e} [in ${{{n[1]}}}]") from None
            elif k == "seq":
                self.run(n[1], env, out, sep_state)
            elif k == "if":
                for cond, b in n[1]:
                    if truthy(ev(cond, env)):
                        self.run(b, env, out, sep_state)
                        break
                else:
                    self.run(n[2], env, out, sep_state)
            elif k == "list":
                self._list(n, env, out)
            elif k == "items":
                if sep_state is None or "seq" not in sep_state:
                    raise FtlError("<#items> outside <#list>")
                self._iterate(sep_state["seq"], n[1], n[2], env, out)
            elif k == "sep":
                if sep_state and not sep_state.get("last", True):
                    self.run(n[1], env, out, sep_state)
            elif k == "assign":
                self._assign(n[1], n[2], env)
            elif k == "assign_block":
                buf = []
                self.run(n[3], env, buf, sep_state)
                self._store(n[1], n[2], "".join(buf), env)
            elif k == "macro":
                self.macros[n[1]] = n
            elif k == "include":
                name = val(ev(n[1].split()[0], env))
                tpl = self.load(name)
                if tpl is None:
                    raise FtlError(f"include not found: {name}")
                self.run(tpl, env, out, sep_state)
            elif k == "call":
                self._call(n, env, out)
            else:
                raise FtlError(f"node {k}")

    def _list(self, n, env, out):
        _, expr, vars_, body, else_body = n
        seq = val(ev(expr, env))
        if isinstance(seq, dict) and vars_ and len(vars_) == 2:
            pass
        empty = (len(seq) == 0)
        if empty:
            self.run(else_body, env, out)
            return
        if vars_ is None:                              # <#list x> … <#items as …> … </#list>
            self.run(body, env, out, {"seq": seq})
        else:
            self._iterate(seq, vars_, body, env, out)

    def _iterate(self, seq, vars_, body, env, out):
        if isinstance(seq, dict):
            items = list(seq.items())
            for i, (k, v) in enumerate(items):
                loc = {vars_[0]: k} if len(vars_) == 1 else {vars_[0]: k, vars_[1]: v}
                self.run(body, env.child(loc), out, {"last": i == len(items) - 1, "index": i})
        else:
            seq = list(seq)
            for i, x in enumerate(seq):
                loc = {vars_[0]: x, vars_[0] + "_index": i, vars_[0] + "?index": i}
                self.run(body, env.child(loc), out, {"last": i == len(seq) - 1, "index": i})

    def _assign(self, scope, args, env):
        # a=1 b="x"  (space separated); values are expressions
        for m in re.finditer(r"([\w$]+)\s*=\s*", args):
            pass
        parts = re.split(r"\s+(?=[\w$]+\s*=)", args.strip())
        for p in parts:
            if not p:
                continue
            name, expr = p.split("=", 1)
            self._store(scope, name.strip(), val(ev(expr.strip(), env)), env)

    def _store(self, scope, name, value, env):
        if scope == "global":
            self.globals[name] = value
        elif scope == "local":
            env.set_local(name, value)
        else:                                          # assign: namespace (template) scope
            self.globals[name] = value

    def _call(self, n, env, out):
        name, args = n[1], n[2]
        if "." in name:
            ns, mname = name.split(".", 1)
            nsv = env.get(ns)
            m = nsv.get(mname) if isinstance(nsv, Namespace) else MISSING
        else:
            m = self.macros.get(name, MISSING)
        if m is MISSING:
            raise FtlError(f"macro not found: {name}")
        _, _, params, body = m
        # params: "a b=1"
        formal = []
        for p in re.findall(r"[\w$]+(?:\s*=\s*(?:\"[^\"]*\"|'[^']*'|[^\s]+))?", params):
            if "=" in p:
                k, d = p.split("=", 1)
                formal.append((k.strip(), d.strip()))
            else:
                formal.append((p.strip(), None))
        actual = {}
        for m2 in re.finditer(r"([\w$]+)\s*=\s*", args):
            pass
        for p in re.split(r"\s+(?=[\w$]+\s*=)", args.strip()) if args.strip() else []:
            k, e = p.split("=", 1)
            actual[k.strip()] = val(ev(e.strip(), env))
        loc = {}
        for k, d in formal:
            if k in actual:
                loc[k] = actual[k]
            elif d is not None:
                loc[k] = val(ev(d, env))
            else:
                raise FtlError(f"macro {name}: missing argument {k}")
        self.run(body, Env(self.data, self.globals, None, loc), out)
