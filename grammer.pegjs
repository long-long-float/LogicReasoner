{
  function binary_ope(left, ope, right) {
    return {left: left, ope: ope, right: right};
  }
}

expr = equiv

equiv
  = left:impli "<->" right:equiv { return binary_ope(left, "<->", right); }
  / impli

impli
  = left:disjunc "->" right:impli { return binary_ope(left, "->", right); }
  / disjunc

disjunc
  = left:conjunc "v" right:disjunc { return binary_ope(left, "v", right); }
  / conjunc

conjunc
  = left:neg "^" right:conjunc { return binary_ope(left, "^", right); }
  / neg

neg
  = "~" right:neg { return { ope: "~", right: right }; }
  / primary

primary
  = [a-zA-Z]
  / "(" expr:expr ")" { return expr; }
