def multiply(a, b):
    return a * b


def divide(a, b):
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b


if __name__ == "__main__":
    print(f"3 * 4 = {multiply(3, 4)}")
    print(f"10 / 3 = {divide(10, 3):.2f}")
