"""
python-cicd-demo  |  app/main.py
A simple Calculator application used as the teaching subject for
understanding local CI/CD quality gates.
"""

from typing import Union

Number = Union[int, float]


def add(a: Number, b: Number) -> Number:
    """Return the sum of a and b."""
    return a + b


def subtract(a: Number, b: Number) -> Number:
    """Return the difference of a and b."""
    return a - b


def multiply(a: Number, b: Number) -> Number:
    """Return the product of a and b."""
    return a * b


def divide(a: Number, b: Number) -> float:
    """Return the quotient of a divided by b.

    Raises:
        ValueError: If b is zero.
    """
    if b == 0:
        raise ValueError("Cannot divide by zero.")
    return a / b


def power(base: Number, exponent: Number) -> Number:
    """Return base raised to the power of exponent."""
    return base**exponent


def square_root(n: Number) -> float:
    """Return the square root of n.

    Raises:
        ValueError: If n is negative.
    """
    if n < 0:
        raise ValueError("Cannot take square root of a negative number.")
    return float(n**0.5)


def main() -> None:
    """Interactive calculator entry point."""
    print("=" * 40)
    print("   Welcome to Python CI/CD Calculator")
    print("=" * 40)

    operations = {
        "1": ("Add", add),
        "2": ("Subtract", subtract),
        "3": ("Multiply", multiply),
        "4": ("Divide", divide),
        "5": ("Power", power),
        "6": ("Square Root (single number)", None),
    }

    for key, (name, _) in operations.items():
        print(f"  {key}. {name}")

    choice = input("\nSelect operation (1-6): ").strip()

    if choice not in operations:
        print("Invalid choice. Exiting.")
        return

    if choice == "6":
        try:
            num = float(input("Enter number: "))
            result = square_root(num)
            print(f"\n  √{num} = {result}")
        except ValueError as exc:
            print(f"  Error: {exc}")
        return

    try:
        a = float(input("Enter first number : "))
        b = float(input("Enter second number: "))
        _, func = operations[choice]
        result = func(a, b)  # type: ignore[misc]
        print(f"\n  Result = {result}")
    except ValueError as exc:
        print(f"  Error: {exc}")


if __name__ == "__main__":
    main()
