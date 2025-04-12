while True:
    original = input("> ")
    tokens = original.split("<")
    output = tokens.pop(0)
    for t in tokens:
        line = t.split(">")[1].strip()

        # Insert for %
        pos = line.find("%")
        if pos >= 0:
            line = line[:pos] + "\\" + line[pos:]

        if t[0] == "y":
            line = "$\\color{#efd27b}\\textsf{" + line + "}$"
        elif t[0] == "g":
            line = "$\\color{#7eb686}\\textsf{" + line + "}$"
        elif t[0] == "b":
            line = "$\\color{#319ad2}\\textsf{" + line + "}$"
        elif t[0] == "r":
            line = "$\\color{#cf6666}\\textsf{" + line + "}$"
        elif t[0] == "c":
            line = "$\\color{#555555}\\textsf{" + line + "}$"

        if output[-1] == "$":
            line = " " + line
        output += line + " "
    
    print(tokens)
    print(output)

# Activating an interactable <g>heals you</c> for <g>9% <c_stack>(+4.5% per stack, hyperbolic) <g>health</c>.