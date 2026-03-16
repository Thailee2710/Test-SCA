def hello(name):
    return f"Hello, {name}!"


def add(a, b):
    return a + b


def test_hello():
    assert hello("World") == "Hello, World!"
    assert hello("Python") == "Hello, Python!"


def test_add():
    assert add(1, 2) == 3
    assert add(-1, 1) == 0
    assert add(0, 0) == 0
